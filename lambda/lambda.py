import boto3
import os

# Create EC2 client
ec2 = boto3.client('ec2')

def lambda_handler(event, context):
    """
    Lambda function to start or stop EC2 instances.
    The action is determined by the 'action' environment variable or event payload.
    """

    # You can set these as environment variables in the Lambda configuration
    instance_ids = os.environ.get('INSTANCE_IDS', '').split(',')
    action = event.get('action', os.environ.get('ACTION', '')).lower()

    if not instance_ids or instance_ids == ['']:
        return {"status": "error", "message": "No instance IDs provided."}

    if action == 'start':
        response = ec2.start_instances(InstanceIds=instance_ids)
        print(f"Starting instances: {instance_ids}")
        return {"status": "success", "action": "start", "response": response}

    elif action == 'stop':
        response = ec2.stop_instances(InstanceIds=instance_ids)
        print(f"Stopping instances: {instance_ids}")
        return {"status": "success", "action": "stop", "response": response}

    else:
        return {"status": "error", "message": "Invalid action. Use 'start' or 'stop'."}
