import base64
import json
import os
import urllib.request

def main(event, context):
    pubsub_message = base64.b64decode(event['data']).decode('utf-8')
    log_entry = json.loads(pubsub_message)

    method_name = log_entry.get("protoPayload", {}).get("methodName", "")
    principal = log_entry.get("protoPayload", {}).get("authenticationInfo", {}).get("principalEmail", "unknown")
    timestamp = log_entry.get("timestamp", "unknown")

    if "SetIamPolicy" in method_name or "CreateServiceAccountKey" in method_name:
        message = f"""
⚠️ *CloudShield Sentinel Alert*
*Event:* `{method_name}`
*User:* `{principal}`
*Time:* `{timestamp}`
        """

        slack_webhook_url = "https://hooks.slack.com/services/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"
        payload = json.dumps({"text": message.strip()}).encode("utf-8")
        headers = {"Content-Type": "application/json"}
        req = urllib.request.Request(slack_webhook_url, payload, headers)

        try:
            with urllib.request.urlopen(req) as resp:
                print("Slack response:", resp.read().decode())
        except Exception as e:
            print("Slack webhook failed:", e)
