#!/bin/bash
# Update and install necessary packages
apt-get update
apt-get install -y python3 python3-pip awscli

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i amazon-cloudwatch-agent.deb

# Clone your repo and install dependencies
git clone https://github.com/takeshi8989/i-click-it.git /home/ubuntu/i-click-it
cd /home/ubuntu/i-click-it
pip3 install -r requirements.txt

# Create CloudWatch configuration file
cat <<EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
{
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/home/ubuntu/i-click-it/logs/app.log",
            "log_group_name": "/aws/ec2/iclicker",
            "log_stream_name": "{instance_id}",
            "timestamp_format": "%Y-%m-%d %H:%M:%S"
          }
        ]
      }
    }
  }
}
EOF

# Start the CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s

# Start your application
python3 main.py
