# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
# ]
# ///
import csv
import os

import requests


def download_images(csv_file, output_dir):
    os.makedirs(output_dir, exist_ok=True)

    with open(csv_file, mode="r", newline="", encoding="utf-8") as file:
        reader = csv.DictReader(file)
        if "id" not in reader.fieldnames:
            raise KeyError("CSV does not contain an 'id' column.")
        ids = [row["id"] for row in reader]

    for card_id in ids:
        image_url = f"https://static.dotgg.gg/pokepocket/card/{card_id}.webp"
        try:
            response = requests.get(image_url, stream=True)
            response.raise_for_status()
            image_path = os.path.join(output_dir, f"{card_id}.webp")
            with open(image_path, "wb") as img_file:
                for chunk in response.iter_content(chunk_size=8192):
                    if chunk:
                        img_file.write(chunk)
            print(f"Downloaded: {card_id}.webp")
        except requests.HTTPError as http_err:
            print(f"HTTP error for {card_id}: {http_err}")
        except Exception as err:
            print(f"Error downloading {card_id}: {err}")


if __name__ == "__main__":
    download_images("cards.csv", "cards")
