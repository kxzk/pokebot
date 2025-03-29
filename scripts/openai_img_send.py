# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
# ]
# ///
import base64
import os

import requests

API_KEY = os.environ["OPENAI_API_KEY"]
API_URL = "https://api.openai.com/v1/responses"

local_image_path = "../images/app/solo__adv_battles.png"

with open(local_image_path, "rb") as image_file:
    encoded_image = base64.b64encode(image_file.read()).decode("utf-8")

payload = {
    "model": "gpt-o1",
    "input": [
        {
            "role": "user",
            "content": [
                {
                    "type": "input_text",
                    "text": "What's in the image?",
                },
                {
                    "type": "input_image",
                    "image_url": f"data:image/jpeg;base64,{encoded_image}",
                },
            ],
        }
    ],
}

headers = {"Content-Type": "application/json", "Authorization": f"Bearer {API_KEY}"}

response = requests.post(API_URL, headers=headers, json=payload)

try:
    response.raise_for_status()
    print("API Response:", response.json())
except requests.exceptions.HTTPError as err:
    print("Request failed:", err)
    print("Response content:", response.text)
