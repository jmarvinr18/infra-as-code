from flask import Flask, request
import boto3
import json
app = Flask(__name__)


@app.route("/ec2")

def get():
    aws_management_console = boto3.session.Session(profile_name="lower-torrospin")
    iam_console_resource = aws_management_console.resource("iam")
    iam_console_client = aws_management_console.client("iam")

    for each_user in iam_console_resource.users.all():
        print("Hello {} World!".format(each_user.name))

    return "test"

@app.get("/api/ec2/describe")

def describe_instances():
    session = start_session()

    ec2 = session.client('ec2')

    response = ec2.describe_instances()    
    return response["Reservations"][0], 201


@app.post("/api/ec2/create")
def create_instance():
    ec2 = start_session().client("ec2")
    instance = ec2.run_instances(
    ImageId='ami-03dcb45259c690711',
    InstanceType='t2.micro',
    KeyName='crm-key',
    MaxCount=1,
    MinCount=1,

    TagSpecifications=[
        {
            'ResourceType': 'instance',
            'Tags': [
                {
                    'Key': 'Name',
                    'Value': 'testing-boto3'
                },
            ]
        },
    ],
)
    return instance, 201

@app.post("/api/ec2/stop")
def stop_instance():
    instance_id = request.form.get("instance_id")
    ec2 = start_session().client("ec2")
    instance = ec2.stop_instances(InstanceIds=[instance_id])

    return instance, 201



def start_session():
    return boto3.session.Session(profile_name="aws-rsi-lower")

