Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user data script execution"

# Update system and install required packages
dnf update -y
dnf install -y amazon-cloudwatch-agent python3-pip unzip wget
echo "Installed CloudWatch agent and pip3"

# Install Google Chrome
dnf install -y https://dl.google.com/linux/chrome/rpm/stable/x86_64/google-chrome-stable-${CHROME_VERSION}-1.x86_64.rpm

# Install ChromeDriver
echo "Installing ChromeDriver"
sudo apt-get install unzip
wget -N https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chromedriver-linux64.zip -P /home/ec2-user/tmp
unzip /home/ec2-user/tmp/chromedriver-linux64.zip -d /home/ec2-user/tmp
mkdir -p /home/ec2-user/bin
mv /home/ec2-user/tmp/chromedriver-linux64/chromedriver /home/ec2-user/bin
chmod +x /home/ec2-user/bin/chromedriver
rm -rf /home/ec2-user/tmp
echo "Installed ChromeDriver"

# Install additional dependencies
dnf install -y atk cups-libs gtk3 libXcomposite alsa-lib libXcursor libXdamage libXext libXi libXrandr libXScrnSaver libXtst pango at-spi2-atk libXt xorg-x11-server-Xvfb xorg-x11-xauth dbus-glib dbus-glib-devel
echo "Installed additional dependencies"

# Install Python packages in a virtual environment
python3 -m venv /home/ec2-user/venv
source /home/ec2-user/venv/bin/activate
pip install --upgrade pip
pip install boto3 selenium pytz
deactivate
echo "Installed Python packages in virtual environment"

# Configure CloudWatch agent
cat > /opt/aws/amazon-cloudwatch-agent/bin/config.json << CWCONF
{
    "agent": {
      "metrics_collection_interval": 60,
      "run_as_user": "root",
      "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
    },
    "logs": {
      "logs_collected": {
          "files": {
          "collect_list": [
              {
                "file_path": "/home/ec2-user/main.py.log",
                "log_group_name": "${CLOUDWATCH_LOG_GROUP_NAME}",
                "log_stream_name":  "${CLOUDWATCH_LOG_STREAM_NAME}",
                "timezone": "UTC"
              }
          ]
        }
      }
    }
}
CWCONF
echo "Created CloudWatch agent config"

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json
echo "Started CloudWatch agent"

# Download main.py and class_schedules_utc.json from S3
aws s3 cp s3://${S3_BUCKET_NAME}/main.py /home/ec2-user/main.py
aws s3 cp s3://${S3_BUCKET_NAME}/class_schedules_utc.json /home/ec2-user/class_schedules_utc.json

# Set correct permissions
chown -R ec2-user:ec2-user /home/ec2-user
echo "Copied main.py from S3 and set permissions"

# Run the Python script
source /home/ec2-user/venv/bin/activate
python /home/ec2-user/main.py > /home/ec2-user/main.py.log 2>&1 &
