import boto3
import json

def ask_bedrock(prompt):

    bedrock = boto3.client("bedrock-runtime", region_name="us-east-1")

    body = json.dumps({
        "prompt": prompt,
        "max_tokens_to_sample": 500
    })

    response = bedrock.invoke_model(
        modelId="anthropic.claude-3-sonnet",
        body=body
    )

    result = json.loads(response["body"].read())

    return result["completion"]
