import json
import boto3
import os
from botocore.exceptions import ClientError

region = "us-east-1"
instances = [os.environ["INSTANCE_IDS"]]
ec2 = boto3.client("ec2", region_name=region)

def lambda_handler(event, context):
    try:
        body = json.loads(event["body"])
        action = body.get("action")

        if action == "start":
            ec2.start_instances(InstanceIds=instances)
            message = f"Starting instance(s): {instances}"
        elif action == "stop":
            ec2.stop_instances(InstanceIds=instances)
            message = f"Stopping instance(s): {instances}"
        else:
            message = "Invalid action. Use 'start' or 'stop'."

        return {
            "statusCode": 200,
            "body": json.dumps({"message": message})
        }

    except ClientError as e:
        if "IncorrectInstanceState" in str(e):
            return {
                "statusCode": 200,
                "body": json.dumps({"message": "Instance already in desired state."})
            }
        else:
            return {
                "statusCode": 500,
                "body": json.dumps({"error": str(e)})
            }
    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }
