import urllib.request
import json

API_URL = "https://api-inference.huggingface.co/models/TinyLlama/TinyLlama-1.1B-Chat-v1.0"
payload = {"inputs": "Give me one short funny pizza splash text."}
data = json.dumps(payload).encode("utf-8")
req = urllib.request.Request(API_URL, data=data, headers={"Content-Type": "application/json"})

try:
    with urllib.request.urlopen(req) as response:
        print(response.read().decode())
except Exception as e:
    print(e)
