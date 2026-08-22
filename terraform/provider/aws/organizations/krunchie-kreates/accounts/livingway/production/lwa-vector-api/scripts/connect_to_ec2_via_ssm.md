# Steps To Connect to EC2 via SSM

1. Ensure you have the AWS CLI installed and configured with the necessary permissions to access SSM and the EC2 instance.

```bash
aws configure 
```

2. Install the Session Manager plugin for the AWS CLI if you haven't already. You can find installation instructions here: [Session Manager Plugin Installation](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

3. Or via user data script in the EC2 instance, you can install the SSM agent by running the following command:

```bash
sudo yum install -y amazon-ssm-agent
```

2. Use the following command to check if the EC2 instance is managed by SSM. Replace `<instance-id>` with your actual instance ID:

```bash
aws ssm describe-instance-information --region us-east-1 --filters Key=InstanceIds,Values=<instance-id>
```

3. Start a session with the EC2 instance using the following command, replacing `<instance-id>` with your actual instance ID:

```bash
aws ssm start-session --target i-0394622fc37cffa01   --region us-east-1
```
