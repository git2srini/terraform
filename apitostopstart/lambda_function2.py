import boto3
import json
import os

ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    """
    Lambda function to start or stop EC2 instances.
    Triggered via API Gateway POST request.
    Expected JSON body: { "action": "start" } or { "action": "stop" }
    """

    instance_ids = os.environ.get('INSTANCE_IDS', '').split(',')
    print(f"Received event: {event}")
    
    try:
        body = json.loads(event.get('body', '{}'))
        action = body.get('action', '').lower()

        if action == 'start':
            ec2.start_instances(InstanceIds=instance_ids)
            message = f"Started instances: {instance_ids}"
        elif action == 'stop':
            ec2.stop_instances(InstanceIds=instance_ids)
            message = f"Stopped instances: {instance_ids}"
        else:
            return {"statusCode": 400, "body": json.dumps({"error": "Invalid action. Use 'start' or 'stop'."})}

        return {"statusCode": 200, "body": json.dumps({"message": message})}

    except Exception as e:
        print(f"Error: {e}")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}
