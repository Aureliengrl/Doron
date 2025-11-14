#!/usr/bin/env python3
"""
Récupère la liste de TOUS les annonceurs disponibles sur Awin
"""
import requests
import json
from dotenv import load_dotenv
import os

load_dotenv()

AWIN_API_TOKEN = os.getenv("AWIN_API_TOKEN")
AWIN_PUBLISHER_ID = os.getenv("AWIN_PUBLISHER_ID")

def get_all_advertisers():
    """Récupère tous les annonceurs Awin auxquels on a accès"""

    url = "https://api.awin.com/publishers/{}/programmes".format(AWIN_PUBLISHER_ID)

    headers = {
        "Authorization": f"Bearer {AWIN_API_TOKEN}",
        "Content-Type": "application/json"
    }

    print("🔍 Récupération de tous les annonceurs Awin...\n")

    try:
        response = requests.get(url, headers=headers, timeout=30)

        if response.status_code == 200:
            data = response.json()

            advertisers = []
            for program in data:
                advertiser = {
                    "id": program.get("advertiserId"),
                    "name": program.get("advertiserName"),
                    "status": program.get("programmeStatus"),
                    "vertical": program.get("vertical")
                }
                advertisers.append(advertiser)

            # Trier par nom
            advertisers.sort(key=lambda x: x["name"])

            print(f"✅ {len(advertisers)} annonceurs trouvés:\n")

            # Grouper par statut
            joined = [a for a in advertisers if a["status"] == "joined"]
            pending = [a for a in advertisers if a["status"] == "pending"]

            print(f"🟢 ACTIFS ({len(joined)}):")
            for adv in joined:
                print(f"  • {adv['name']} (ID: {adv['id']}) - {adv['vertical']}")

            if pending:
                print(f"\n🟡 EN ATTENTE ({len(pending)}):")
                for adv in pending:
                    print(f"  • {adv['name']} (ID: {adv['id']})")

            # Sauvegarder dans un fichier
            with open("awin_advertisers.json", "w", encoding="utf-8") as f:
                json.dump(advertisers, f, indent=2, ensure_ascii=False)

            print(f"\n💾 Liste sauvegardée dans awin_advertisers.json")

            return advertisers

        else:
            print(f"❌ Erreur API Awin: {response.status_code}")
            print(f"Response: {response.text}")
            return []

    except Exception as e:
        print(f"❌ Erreur: {e}")
        return []

if __name__ == "__main__":
    get_all_advertisers()
