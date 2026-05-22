#!/usr/bin/env python3
"""
Firestore 'events' koleksiyonundaki her etkinliğin imageUrl alanını
Wikipedia Commons'tan CC lisanslı sanatçı fotoğraflarıyla günceller.

Kurulum:
  pip install firebase-admin requests

Kullanım:
  1. Firebase Console > Project Settings > Service Accounts >
     "Generate new private key" ile serviceAccountKey.json indirin
  2. serviceAccountKey.json dosyasını bu script'in yanına koyun
  3. python update_event_images.py              # gerçek güncelleme
  4. python update_event_images.py --dry-run    # Firestore'a yazmadan test
  5. python update_event_images.py --force      # var olan URL'leri de güncelle
"""

import sys
import time
import json
import argparse
import requests

import firebase_admin
from firebase_admin import credentials, firestore

# ─── Ayarlar ─────────────────────────────────────────────────────────────────
SERVICE_ACCOUNT_KEY_PATH = "serviceAccountKey.json"
COMMONS_API = "https://commons.wikimedia.org/w/api.php"

# Kabul edilen CC / kamu malı lisans anahtar sözcükleri
ALLOWED_LICENSE_KEYWORDS = [
    "cc0", "cc-by", "cc-by-sa", "public domain", "creativecommons.org"
]

# Etkinlik başlığından temizlenecek Türkçe / İngilizce son ekler
TITLE_SUFFIXES = [
    "konseri", "concert", "live", "tour", "festival",
    "gala", "show", "performans", "turnesi", "etkinliği",
    "istanbul", "ankara", "izmir", "bursa", "antalya",
]
# ─────────────────────────────────────────────────────────────────────────────


def extract_artist_name(event_title: str) -> str:
    """'Duman Konseri' → 'Duman', 'Radiohead Live' → 'Radiohead'."""
    title = event_title.strip()
    for suffix in TITLE_SUFFIXES:
        if title.lower().endswith(suffix):
            title = title[: -len(suffix)].strip(" -–—")
    return title


def _is_cc_license(extmetadata: dict) -> bool:
    short = extmetadata.get("LicenseShortName", {}).get("value", "").lower()
    url   = extmetadata.get("LicenseUrl",       {}).get("value", "").lower()
    combined = short + " " + url
    return any(kw in combined for kw in ALLOWED_LICENSE_KEYWORDS)


def _get_cc_url_for_title(page_title: str) -> str | None:
    """Wikimedia Commons dosya başlığı için CC URL döner; lisanssızsa None."""
    params = {
        "action": "query",
        "titles": page_title,
        "prop": "imageinfo",
        "iiprop": "url|extmetadata",
        "iiextmetadatafilter": "LicenseShortName|LicenseUrl",
        "format": "json",
    }
    try:
        r = requests.get(COMMONS_API, params=params, timeout=10)
        r.raise_for_status()
        pages = r.json().get("query", {}).get("pages", {})
    except Exception as e:
        print(f"    [API hatası] {e}")
        return None

    for pid, page in pages.items():
        if pid == "-1":
            continue
        infos = page.get("imageinfo", [])
        if not infos:
            continue
        info = infos[0]
        if _is_cc_license(info.get("extmetadata", {})):
            return info.get("url")
    return None


def _search_commons(query: str) -> str | None:
    """Commons dosya araması; CC lisanslı ilk JPEG/PNG URL'ini döner."""
    params = {
        "action": "query",
        "list": "search",
        "srsearch": query,
        "srnamespace": 6,       # File: namespace
        "srlimit": 15,
        "srprop": "title",
        "format": "json",
    }
    try:
        r = requests.get(COMMONS_API, params=params, timeout=10)
        r.raise_for_status()
        results = r.json().get("query", {}).get("search", [])
    except Exception as e:
        print(f"    [Arama hatası] {e}")
        return None

    for item in results:
        title = item.get("title", "")
        if not any(title.lower().endswith(ext) for ext in (".jpg", ".jpeg", ".png")):
            continue
        url = _get_cc_url_for_title(title)
        if url:
            return url
    return None


def find_artist_image(artist_name: str, category: str = "") -> str | None:
    """
    Sanatçı için CC lisanslı görsel URL'si bulur.
    Birden fazla arama sorgusunu sırayla dener.
    """
    queries = [
        f"{artist_name} musician",
        f"{artist_name} singer",
        f"{artist_name} band",
        f"{artist_name} {category}" if category else None,
        artist_name,
    ]

    for q in queries:
        if not q:
            continue
        url = _search_commons(q)
        if url:
            return url
        time.sleep(0.3)   # API hız sınırı

    return None


def run(dry_run: bool = False, force: bool = False) -> None:
    """Ana işlev: Firestore'dan eventleri çek, görselleri güncelle."""

    # Firebase başlat
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    firebase_admin.initialize_app(cred)
    db = firestore.client()

    print("Firestore'dan etkinlikler alınıyor...\n")
    docs = list(db.collection("events").stream())
    print(f"Toplam {len(docs)} etkinlik bulundu.\n")

    counts = {"updated": 0, "skipped": 0, "failed": 0}

    for doc in docs:
        data    = doc.to_dict()
        title   = data.get("title", "(başlıksız)")
        cat     = data.get("category", "")
        cur_url = data.get("imageUrl", "")

        print(f"[{doc.id}]  {title}  ({cat})")

        if cur_url and not force:
            print("  → imageUrl zaten mevcut, atlanıyor  (--force ile üzerine yaz)\n")
            counts["skipped"] += 1
            continue

        artist = extract_artist_name(title)
        print(f"  Aranan: '{artist}'")
        url = find_artist_image(artist, cat)

        if url:
            short = url if len(url) <= 90 else url[:87] + "..."
            if dry_run:
                print(f"  [DRY RUN] Güncellenecek URL: {short}\n")
            else:
                doc.reference.update({"imageUrl": url})
                print(f"  ✓ Güncellendi: {short}\n")
            counts["updated"] += 1
        else:
            print("  ✗ CC lisanslı görsel bulunamadı\n")
            counts["failed"] += 1

        time.sleep(0.5)   # Firestore + API hız sınırı

    print("=" * 55)
    print(f"Tamamlandı!   Güncellenen: {counts['updated']}  "
          f"Atlanan: {counts['skipped']}  Başarısız: {counts['failed']}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Firestore event imageUrl'lerini Wikipedia Commons görselleriyle güncelle"
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Firestore'a yazmadan sadece bulduğu URL'leri göster"
    )
    parser.add_argument(
        "--force", action="store_true",
        help="Var olan imageUrl alanını bile üzerine yaz"
    )
    args = parser.parse_args()

    if args.dry_run:
        print("⚠  DRY RUN modu — Firestore'a HİÇBİR ŞEY yazılmayacak\n")

    run(dry_run=args.dry_run, force=args.force)
