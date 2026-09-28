import os
import base64
import urllib.request
import json

api_key = os.environ.get(
    "GEMINI_API_KEY",
    base64.b64decode("QVEuQWI4Uk42SnFJc2pPemQzd3ZUT0NHbVlRSGRRenhNSHRVZUhXeVNyb0paTzBOZldIb0E=").decode("utf-8")
)

# Test models in order
candidate_models = [
    "gemini-2.5-flash",
    "gemini-2.5-pro",
    "gemini-3.8-flash",
    "gemini-3.7-flash",
    "gemini-3.5-flash",
    "gemini-flash-latest",
    "gemini-pro-latest",
]

for m in candidate_models:
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{m}:generateContent?key={api_key}"
    payload = json.dumps({
        "contents": [{"parts": [{"text": "You are ATLANTA, an advanced personal AI assistant. Greet Boss in one brief sentence."}]}]
    }).encode("utf-8")
    
    req = urllib.request.Request(url, data=payload, headers={"Content-Type": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
            text = data["candidates"][0]["content"]["parts"][0]["text"]
            print(f"SUCCESS with {m}:")
            print(text.strip())
            break
    except Exception as e:
        err = e.read().decode() if hasattr(e, "read") else str(e)
        print(f"Failed {m}: {err[:120]}")
