#!/usr/bin/env python3
"""
Test de l'API Awin
"""
import requests
import json
from dotenv import load_dotenv
import os

load_dotenv()

AWIN_API_TOKEN = os.getenv("AWIN_API_TOKEN")
AWIN_PUBLISHER_ID = os.getenv("AWIN_PUBLISHER_ID")

print(f"Token: {AWIN_API_TOKEN[:20]}...")
print(f"Publisher ID: {AWIN_PUBLISHER_ID}\n")

# Test 1: Product Feed API
print("=" * 70)
print("TEST 1: Product Feed API - Liste des annonceurs avec produits")
print("=" * 70)

url = f"https://productdata.awin.com/{AWIN_PUBLISHER_ID}/datafeed/list/apikey/{AWIN_API_TOKEN}"

try:
    response = requests.get(url, timeout=30)
    print(f"Status: {response.status_code}")

    if response.status_code == 200:
        data = response.json()
        print(f"✅ Réponse reçue:")
        print(json.dumps(data[:3], indent=2) if isinstance(data, list) else json.dumps(data, indent=2))
    else:
        print(f"❌ Erreur: {response.text}")

except Exception as e:
    print(f"❌ Exception: {e}")

print("\n")

# Test 2: Publisher API - Programmes
print("=" * 70)
print("TEST 2: Publisher API - Programmes")
print("=" * 70)

url2 = f"https://api.awin.com/publishers/{AWIN_PUBLISHER_ID}/programmes"
headers = {
    "Authorization": f"Bearer {AWIN_API_TOKEN}"
}

try:
    response2 = requests.get(url2, headers=headers, timeout=30)
    print(f"Status: {response2.status_code}")

    if response2.status_code == 200:
        data2 = response2.json()
        print(f"✅ Réponse reçue:")
        print(json.dumps(data2[:2], indent=2) if isinstance(data2, list) else json.dumps(data2, indent=2))
    else:
        print(f"❌ Erreur: {response2.text}")

except Exception as e:
    print(f"❌ Exception: {e}")

print("\n")

# Test 3: Accounts API
print("=" * 70)
print("TEST 3: Accounts API - Info du compte")
print("=" * 70)

url3 = f"https://api.awin.com/publishers/{AWIN_PUBLISHER_ID}/accounts"
headers3 = {
    "Authorization": f"Bearer {AWIN_API_TOKEN}"
}

try:
    response3 = requests.get(url3, headers=headers3, timeout=30)
    print(f"Status: {response3.status_code}")

    if response3.status_code == 200:
        data3 = response3.json()
        print(f"✅ Réponse reçue:")
        print(json.dumps(data3, indent=2))
    else:
        print(f"❌ Erreur: {response3.text}")

except Exception as e:
    print(f"❌ Exception: {e}")
