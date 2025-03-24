# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "beautifulsoup4",
#     "requests",
# ]
# ///
import requests
from bs4 import BeautifulSoup


def get_html(url):
    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    }

    try:
        response = requests.get(url, headers=headers)
        response.raise_for_status()
        return response.text
    except Exception as e:
        print(f"Error fetching {url}: {e}")
        return None


def parse_html(html):
    return BeautifulSoup(html, "html.parser")


if __name__ == "__main__":
    url = "https://ptcgpocket.gg/cards/"

    html = get_html(url)

    if html:
        soup = parse_html(html)
        print(soup.prettify())
