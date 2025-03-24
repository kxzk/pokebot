# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
# ]
# ///
import csv
import json

import requests


def fetch_and_write_csv(url, csv_filename):
    try:
        # Send GET request
        response = requests.get(url)
        response.raise_for_status()  # Raise exception for HTTP errors

        # Debug: Check content type and preview text
        content_type = response.headers.get("Content-Type", "")
        if "application/json" not in content_type:
            print("Warning: Expected JSON but received:", content_type)
            print("Response preview:", response.text[:500])

        try:
            # Attempt to parse JSON response
            data_json = response.json()
        except json.decoder.JSONDecodeError:
            print("Error: Response is not valid JSON. Response text:")
            print(response.text)
            return

        # Extract headers and data
        headers = data_json.get("names")
        rows = data_json.get("data")

        if not headers or not rows:
            raise ValueError("JSON structure missing 'names' or 'data' keys.")

        # Write data to CSV file
        with open(csv_filename, mode="w", newline="", encoding="utf-8") as file:
            writer = csv.writer(file)
            writer.writerow(headers)
            for row in rows:
                # Convert nested data structures to JSON strings
                processed_row = [
                    json.dumps(item) if isinstance(item, (list, dict)) else item
                    for item in row
                ]
                writer.writerow(processed_row)

        print(f"CSV file written successfully to {csv_filename}")
    except Exception as e:
        print("Error fetching or writing data:", e)


if __name__ == "__main__":
    url = "https://api.dotgg.gg/cgfw/getcards?game=pokepocket&mode=indexed&cache=844"
    csv_filename = "cards.csv"
    fetch_and_write_csv(url, csv_filename)
