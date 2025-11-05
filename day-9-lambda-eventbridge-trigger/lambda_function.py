def lambda_handler(event, context):
    print("Lambda executed by EventBridge")
    return {"statusCode": 200, "body": "Lambda executed successfully!"}
