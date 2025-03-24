# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests",
# ]
# ///
import requests

if __name__ == "__main__":
    url = "https://api.dotgg.gg/cgfw/getcards?game=pokepocket&mode=indexed&cache=844"
    response = requests.get(url)

    with open("all_card_data.json", "w") as f:
        f.write(response.text)
