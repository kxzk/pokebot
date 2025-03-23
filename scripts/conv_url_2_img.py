#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
# ]
# ///
import requests


def fetch_and_save_image(url, filename):
    try:
        response = requests.get(url)
        response.raise_for_status()  # Raises an HTTPError for bad responses
        with open(filename, "wb") as f:
            f.write(response.content)
        print(f"Image successfully saved as '{filename}'")
    except requests.exceptions.RequestException as e:
        print(f"An error occurred: {e}")


if __name__ == "__main__":
    url = "https://static.dotgg.gg/pokepocket/card/A1-001.webp"
    filename = "A1-001.webp"
    fetch_and_save_image(url, filename)
