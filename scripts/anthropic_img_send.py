# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
# ]
# ///
import base64
import os

import requests

ANTHROPIC_API_KEY = os.environ["ANTHROPIC_API_KEY"]
API_URL = "https://api.anthropic.com/v1/messages"

local_image_path = (
    "../images/app/solo__adv_battles.png"  # Update this path to your local file
)
IMAGE_MEDIA_TYPE = "image/png"

try:
    with open(local_image_path, "rb") as image_file:
        image_data = image_file.read()
    IMAGE_BASE64 = base64.b64encode(image_data).decode("utf-8")
except FileNotFoundError:
    raise Exception(f"Local file not found: {local_image_path}")

payload = {
    "model": "claude-3-7-sonnet-20250219",
    # "model": "claude-3-5-sonnet-20240620",
    "max_tokens": 1024,
    "messages": [
        {
            "role": "user",
            "content": [
                {
                    "type": "image",
                    "source": {
                        "type": "base64",
                        "media_type": IMAGE_MEDIA_TYPE,
                        "data": IMAGE_BASE64,
                    },
                },
                {
                    "type": "text",
                    "text": "What's in the image?",
                },
            ],
        }
    ],
}

headers = {
    "x-api-key": ANTHROPIC_API_KEY,
    "anthropic-version": "2023-06-01",
    "content-type": "application/json",
}

response = requests.post(API_URL, headers=headers, json=payload)

if response.status_code == 200:
    print("API Response:")
    print(response.json())
else:
    print("Request failed with status code:", response.status_code)
    print("Response content:", response.text)
