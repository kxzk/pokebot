# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "beautifulsoup4",
#     "requests",
# ]
# ///
import csv
import json
from datetime import date
from typing import Optional

import requests
from bs4 import BeautifulSoup, NavigableString, Tag


def parse_td_left(cell: Tag) -> dict:
    """
    Parses a <td class="left"> cell to extract:
      - Stage (e.g., "Stage 1")
      - Retreat Cost: both the alt text (with prefix removed) and image URL
      - Ability: name and descriptive text
      - Attacks: each attack's name, associated image alt texts, and following description text
    Returns a dictionary of the parsed fields.
    """
    result = {
        "stage": None,
        "retreat_cost": None,
        "retreat_cost_img": None,
        "ability_name": None,
        "ability_text": None,
        "attacks": [],
    }

    # --- Parse Stage ---
    stage_tag = cell.find("b", class_="a-bold", string="Stage")
    if stage_tag:
        # The stage value is expected to be in the next sibling (after the colon)
        next_text = stage_tag.next_sibling
        if next_text:
            result["stage"] = next_text.strip().lstrip(":").strip()

    # --- Parse Retreat Cost ---
    retreat_tag = cell.find("b", class_="a-bold", string="Retreat Cost")
    if retreat_tag:
        parent_div = retreat_tag.parent
        if parent_div:
            img = parent_div.find("img")
            if img:
                result["retreat_cost_img"] = img.get("src", "").strip()
                alt_text = (
                    img.get("alt", "").replace("Pokemon TCG Pocket -", "").strip()
                )
                result["retreat_cost"] = alt_text

    # --- Parse Ability ---
    ability_span = cell.find("span", class_="a-red")
    if ability_span:
        # Ability name: text immediately following the <span>
        ability_name = ability_span.next_sibling
        if ability_name and isinstance(ability_name, str):
            result["ability_name"] = ability_name.strip()
        # Ability description: gather text from subsequent siblings until a divider (e.g., <div class="align"> or <hr>) is encountered
        ability_desc_parts = []
        for sibling in ability_span.next_siblings:
            if isinstance(sibling, Tag):
                if sibling.name in ["div", "hr"]:
                    break
                if sibling.name == "br":
                    continue
                text = sibling.get_text(separator=" ", strip=True)
                if text:
                    ability_desc_parts.append(text)
            elif isinstance(sibling, NavigableString):
                text = sibling.strip()
                if text:
                    ability_desc_parts.append(text)
        result["ability_text"] = " ".join(ability_desc_parts)

    # --- Parse Attacks ---
    # Find all <div class="align"> blocks that are not used for retreat cost.
    attack_divs = []
    for div in cell.find_all("div", class_="align"):
        b_tag = div.find("b", class_="a-bold")
        if b_tag and b_tag.get_text(strip=True) not in ["Retreat Cost"]:
            attack_divs.append(div)
    for div in attack_divs:
        attack = {"name": None, "img_alts": [], "description": ""}
        # Attack name
        b_tag = div.find("b", class_="a-bold")
        if b_tag:
            attack["name"] = b_tag.get_text(strip=True)
        # Image alt texts within the attack block
        imgs = div.find_all("img")
        for img in imgs:
            alt = img.get("alt", "").strip()
            if alt:
                attack["img_alts"].append(alt)
        # After the attack div, capture following text (which may include energy cost and attack description)
        desc_parts = []
        for sibling in div.next_siblings:
            if isinstance(sibling, Tag):
                # Break if we hit another attack block or a divider
                if sibling.name == "div":
                    potential_bold = sibling.find("b", class_="a-bold")
                    if potential_bold:
                        break
                if sibling.name in ["hr"]:
                    break
                if sibling.name == "br":
                    continue
                text = sibling.get_text(separator=" ", strip=True)
                if text:
                    desc_parts.append(text)
            elif isinstance(sibling, NavigableString):
                text = sibling.strip()
                if text:
                    desc_parts.append(text)
        attack["description"] = " ".join(desc_parts)
        result["attacks"].append(attack)

    return result


def convert_cell(cell: Tag) -> Optional[str]:
    """
    Converts a table cell to a string.

    For cells with class 'left':
      - If no <b class="a-bold"> is present, returns the cell's text.
      - Otherwise, calls parse_td_left() to extract structured fields
        and returns the result as a JSON string.
    For other cells, returns the text content or, if absent, the alt text of the first image.
    """
    cell_classes = cell.get("class", [])
    if "left" in cell_classes:
        # If no a-bold elements, just return the plain text.
        if not cell.find("b", class_="a-bold"):
            return cell.get_text(strip=True)
        parsed = parse_td_left(cell)
        return json.dumps(parsed, ensure_ascii=False)

    # Fallback: extract normal text or use alt text from the first image.
    text = cell.get_text(strip=True)
    if text:
        return text
    img = cell.find("img")
    if img:
        alt_text = img.get("alt", "").replace("Pokemon TCG Pocket -", "").strip()
        return alt_text if alt_text else None
    return None


def scrape_and_write_csv(url: str, csv_filename: str) -> None:
    """
    Scrapes the given URL for table data and writes the extracted data to a CSV file.
    """
    headers = {
        "User-Agent": (
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
            "AppleWebKit/537.36 (KHTML, like Gecko) "
            "Chrome/90.0.4430.93 Safari/537.36"
        )
    }
    response = requests.get(url, headers=headers)
    if response.status_code != 200:
        print(f"Error: Unable to fetch page, status code {response.status_code}")
        return

    soup = BeautifulSoup(response.text, "html.parser")
    table_divs = soup.find_all("div", class_="scroll--table table-header--fixed")
    if not table_divs:
        print("Error: Table container not found")
        return
    table_div = table_divs[0]

    # Extract header row
    thead = table_div.find("thead")
    if not thead:
        print("Error: Table header not found")
        return
    header_tr = thead.find("tr")
    th_tags = header_tr.find_all("th")
    header_row = [
        th.get_text(strip=True).lower().replace(" ", "_").replace("|", "")
        for th in th_tags
    ]
    if len(header_row) >= 2:
        header_row[0] = "own_it"
        header_row[1] = "card_number"

    # Extract data rows
    tbody = table_div.find("tbody")
    if not tbody:
        print("Error: Table body not found")
        return
    rows = tbody.find_all("tr")
    data = []
    for row in rows:
        cells = row.find_all("td")
        data.append([convert_cell(cell) for cell in cells])

    # Write header and data to CSV file
    with open(csv_filename, "w", newline="", encoding="utf-8") as csvfile:
        writer = csv.writer(csvfile)
        writer.writerow(header_row)
        writer.writerows(data)

    print(f"[success] Data written to {csv_filename}")


if __name__ == "__main__":
    url = "https://game8.co/games/Pokemon-TCG-Pocket/archives/482685"
    csv_filename = f"pokemon_data_{date.today().isoformat()}.csv"
    scrape_and_write_csv(url, csv_filename)
