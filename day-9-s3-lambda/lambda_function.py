import json

def lambda_handler(event, context):
    print("Triggered by S3 event:", json.dumps(event))
    return {"message": "Lambda triggered successfully"}