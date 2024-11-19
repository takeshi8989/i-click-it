# I-Click-It: Automate Class Attendance
I-Click-It is a tool designed to help students automate class attendance by leveraging AWS Lambda and CloudWatch to manage class schedules and ensure seamless operations.

This guide will walk you through setting up I-Click-It step-by-step, even if you have little to no technical background.


### Prerequisites
Before getting started, ensure you have the following:

1. A computer with Bash (Linux, macOS, or WSL on Windows) and Python 3.x installed.
2. An active AWS account (if you don’t have one, follow Step 1 below).
3. Basic knowledge of your class schedule (start and end times, and days).


## Setup Instructions
### Step 1: Create an AWS Account
If you don’t already have an AWS account, follow this [official guide](https://repost.aws/knowledge-center/create-and-activate-aws-account) to create one.

### Step 2: Configure AWS Credentials
You’ll need to set up AWS credentials to allow the tool to interact with AWS services.
1. Install the AWS Command Line Interface (CLI) by following [this guide](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
2. Open a terminal and run:
``` bash
aws configure
```
3. Enter the following details when prompted:
- AWS Access Key ID: Retrieved from your AWS account.
- AWS Secret Access Key: Retrieved from your AWS account.
- Default region name: Use `us-east-1` (or the region of your choice).
- Default output format: Leave blank or use `json`.

### Step 3: Edit User Credentials
1. Navigate to the project’s root directory.
2. Open or create the file `user_credentials.json` and add your email and password in the following format:
``` json
{
  "email": "your_email@example.com",
  "password": "your_password"
}
```
Replace `"your_email@example.com"` and `"your_password"` with your actual credentials.

### Step 4: Edit Class Schedules
1. Open the file `class_schedules.json` in the project’s root directory.
2. Define your class schedules in the following format:
``` json
[
  {
    "classname": "PSYC102",
    "name_on_iclicker": "PSYC_V 102",
    "start_time": "11:00",
    "end_time": "12:30",
    "days": ["TUE", "THU"]
  },
  {
    "classname": "CPSC317",
    "name_on_iclicker": "CPSC 317",
    "start_time": "15:00",
    "end_time": "16:00",
    "days": ["MON", "WED", "FRI"]
  }
]
```
Replace:
- `classname`: Use a short, descriptive name of your class (e.g., `PSYC102`). **Avoid invalid names with spaces or special characters.**
- `name_on_iclicker` **This is critical!!** Use the exact title as shown on the iClicker website, but only include the relevant part of the title. For example, in the screenshot provided, `CPSC 317` or `PSYC_V 102` are the required portions. Check your courses on [iClicker Student](https://student.iclicker.com/#/courses) for the correct names.
- `start_time` and `end_time` with the class start and end times in 24-hour format.
- `days` with the days of the week your class occurs (use abbreviations: MON, TUE, etc.).

<img width="695" alt="Screenshot 2024-11-18 at 8 43 24 PM" src="https://github.com/user-attachments/assets/31bf6662-6435-4374-ad62-9fd791d1a746">


### Step 5: Deploy I-Click-It
Run the following command to deploy the tool:

```bash
bash scripts/deploy.sh
```
bash scripts/deploy.sh
The deployment process will:

1. Convert your class schedule into UTC format.
2. Create necessary AWS resources (Lambda, CloudWatch, etc.).
3. Deploy the tool to automate class attendance.


## How It Works
1. Class Schedules: The tool uses `class_schedules.json` to determine when your classes start and end.
2. AWS Lambda: A Lambda function interacts with the iClicker system based on your class schedule.
3. CloudWatch: CloudWatch triggers the Lambda functions at the appropriate times using cron schedules.



## Cost
This app is configured to minimize AWS EC2 instance costs by running instances only during class hours. However, AWS may charge a small amount (less than $1 per month) for VPC IP address reservations.

## FAQs
### 1. What if I don’t know my AWS region?
Use the AWS Management Console to check your region or use the default `us-east-1`.

### 2. How do I update my schedule?
Edit the `class_schedules.json` file and re-run `scripts/deploy.sh`.

### 3. Can I stop using the tool?
Yes, you can run the following command to remove all resources created by the tool:
```bash
bash scripts/destroy.sh
```

### 4. What happens if I enter the wrong credentials?
Update the `user_credentials.json` file with the correct details and re-run `scripts/deploy.sh`.


## Troubleshooting
- Error: Missing AWS credentials. Ensure you’ve run `aws configure` and that the credentials are valid.

- Error: Permission denied while running deploy.sh. Ensure the script is executable:
```
chmod +x scripts/deploy.sh
```
- CloudWatch logs are not working. Check your AWS Management Console for CloudWatch logs under the specified log group.


## Contributing
Contributions are welcome! If you encounter issues or have suggestions, feel free to create a pull request or raise an issue in the repository.


---

Enjoy automating your class attendance with I-Click-It! 🎉
