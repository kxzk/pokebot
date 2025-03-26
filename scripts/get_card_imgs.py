# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
# ]
# ///
import csv
import glob
import os

import requests


def gather_card_ids(csv_pattern):
    all_ids = set()
    csv_files = glob.glob(csv_pattern)
    if not csv_files:
        print(f"No CSV files found matching pattern: {csv_pattern}")
        return all_ids

    for csv_file in csv_files:
        try:
            with open(csv_file, mode="r", newline="", encoding="utf-8") as file:
                reader = csv.DictReader(file)
                if "id" not in reader.fieldnames:
                    raise KeyError(f"CSV '{csv_file}' does not contain an 'id' column.")
                for row in reader:
                    card_id = row["id"]
                    if card_id:
                        all_ids.add(card_id)
        except Exception as e:
            print(f"Error reading {csv_file}: {e}")
    return all_ids


def download_missing_images(card_ids, output_dir):
    os.makedirs(output_dir, exist_ok=True)
    for card_id in card_ids:
        image_path = os.path.join(output_dir, f"{card_id}.webp")
        if os.path.exists(image_path):
            continue  # skip if already exists

        image_url = f"https://static.dotgg.gg/pokepocket/card/{card_id}.webp"
        try:
            response = requests.get(image_url, stream=True)
            response.raise_for_status()
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
    card_ids = gather_card_ids("../data/cards_*.csv")

    download_missing_images(card_ids, "../images/cards")
