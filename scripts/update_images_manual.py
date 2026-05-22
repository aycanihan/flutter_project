#!/usr/bin/env python3
"""
Firestore 'events' koleksiyonundaki imageUrl alanlarını
sabit Unsplash fotoğraflarıyla günceller.

Kurulum:
  pip install firebase-admin

Kullanım:
  python update_images_manual.py            # gerçek güncelleme
  python update_images_manual.py --dry-run  # yazmadan önizle
  python update_images_manual.py --force    # var olan URL'leri de üzerine yaz
"""

import argparse
import json
import warnings
import requests
import urllib3
import google.oauth2.service_account
import google.auth.transport.requests

# SSL doğrulaması bu makinede kurumsal CA nedeniyle başarısız oluyor.
# Yerel admin scripti için verify=False kullanılıyor.
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

SERVICE_ACCOUNT_KEY_PATH = "serviceAccountKey.json"

# ─── Sanatçı → Unsplash URL eşlemesi ─────────────────────────────────────────
# Her URL w=800&q=80 parametresiyle optimize edilmiştir.

ARTIST_IMAGES: dict[str, str] = {
    # ── Firestore etkinliklerine ait sanatçılar (kullanıcı tarafından atanan URL'ler) ──
    "guns n'roses":     "https://images.unsplash.com/photo-1540039155733-5bb30b99f842?w=800&h=400&fit=crop",
    "guns n roses":     "https://images.unsplash.com/photo-1540039155733-5bb30b99f842?w=800&h=400&fit=crop",
    "kanye west":       "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "gorillaz":         "https://images.unsplash.com/photo-1571266028243-d220c6a3ecca?w=800&h=400&fit=crop",
    "till lindemann":   "https://images.unsplash.com/photo-1598387993441-a364f854cfb4?w=800&h=400&fit=crop",
    "coldplay":         "https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?w=800&h=400&fit=crop",
    "radiohead":        "https://images.unsplash.com/photo-1501386761578-eaa54b3628c4?w=800&h=400&fit=crop",
    "arctic monkeys":   "https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?w=800&h=400&fit=crop",
    "billie eilish":    "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=400&fit=crop",
    "the weeknd":       "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&h=400&fit=crop",
    "kendrick lamar":   "https://images.unsplash.com/photo-1574169208507-84376144848b?w=800&h=400&fit=crop",
    "travis scott":     "https://images.unsplash.com/photo-1563841930606-67e2bce48b78?w=800&h=400&fit=crop",
    "tame impala":      "https://images.unsplash.com/photo-1506157786151-b8491531f063?w=800&h=400&fit=crop",
    "tyler the creator":"https://images.unsplash.com/photo-1598518619776-eae3f8a34eac?w=800&h=400&fit=crop",
    "paramore":         "https://images.unsplash.com/photo-1519892300165-cb5542fb47c7?w=800&h=400&fit=crop",
    "limp bizkit":      "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&h=400&fit=crop",
    "hans zimmer":      "https://images.unsplash.com/photo-1507838153414-b4b713384a76?w=800&h=400&fit=crop",
    "massive attack":   "https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=800&h=400&fit=crop",
    "portishead":       "https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=800&h=400&fit=crop",
    "kraftwerk":        "https://images.unsplash.com/photo-1511379938547-c1f69419868d?w=800&h=400&fit=crop",
    "tarkan":           "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&h=400&fit=crop",
    "mor ve ötesi":     "https://images.unsplash.com/photo-1574169208507-84376144848b?w=800&h=400&fit=crop",
    "mor ve otesi":     "https://images.unsplash.com/photo-1574169208507-84376144848b?w=800&h=400&fit=crop",
    "justin timberlake":"https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&h=400&fit=crop",
    "fka twigs":        "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "the neighbourhood":"https://images.unsplash.com/photo-1571266028243-d220c6a3ecca?w=800&h=400&fit=crop",
    "yebba":            "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=400&fit=crop",
    "miguel":           "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&h=400&fit=crop",
    "kaytranada":       "https://images.unsplash.com/photo-1429962714451-bb934ecdc4ec?w=800&h=400&fit=crop",
    "duran duran":      "https://images.unsplash.com/photo-1524368535928-5b5e00ddc76b?w=800&h=400&fit=crop",

    # ── Ek sanatçılar ────────────────────────────────────────────────────────────
    "duman":            "https://images.unsplash.com/photo-1429514513361-8fa32282fd5f?w=800&h=400&fit=crop",
    "kıraç":            "https://images.unsplash.com/photo-1501386760131-1bac9b2b0e1d?w=800&h=400&fit=crop",
    "kirac":            "https://images.unsplash.com/photo-1501386760131-1bac9b2b0e1d?w=800&h=400&fit=crop",
    "athena":           "https://images.unsplash.com/photo-1415886411536-4b2e9f7efc96?w=800&h=400&fit=crop",
    "pentagram":        "https://images.unsplash.com/photo-1598387993441-a364f854c3e1?w=800&h=400&fit=crop",
    "hayko cepkin":     "https://images.unsplash.com/photo-1598387993441-a364f854c3e1?w=800&h=400&fit=crop",
    "sezen aksu":       "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&h=400&fit=crop",
    "mabel matiz":      "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&h=400&fit=crop",
    "hadise":           "https://images.unsplash.com/photo-1415886411536-4b2e9f7efc96?w=800&h=400&fit=crop",
    "serdar ortaç":     "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&h=400&fit=crop",
    "serdar ortac":     "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&h=400&fit=crop",
    "kenan doğulu":     "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&h=400&fit=crop",
    "kenan dogulu":     "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&h=400&fit=crop",
    "rafet el roman":   "https://images.unsplash.com/photo-1506157786151-b8491531f063?w=800&h=400&fit=crop",
    "ceza":             "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "sagopa kajmer":    "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "ezhel":            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "şehinşah":         "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "sehinshah":        "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "norm ender":       "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "ben fero":         "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "cem vision":       "https://images.unsplash.com/photo-1571266028243-e4733b0f0bb0?w=800&h=400&fit=crop",
    "klangkarussell":   "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=400&fit=crop",
    "the cure":         "https://images.unsplash.com/photo-1540039155733-5bb30b4e843b?w=800&h=400&fit=crop",
    "nirvana":          "https://images.unsplash.com/photo-1429514513361-8fa32282fd5f?w=800&h=400&fit=crop",
    "pearl jam":        "https://images.unsplash.com/photo-1429514513361-8fa32282fd5f?w=800&h=400&fit=crop",
    "the strokes":      "https://images.unsplash.com/photo-1501386760131-1bac9b2b0e1d?w=800&h=400&fit=crop",
    "the killers":      "https://images.unsplash.com/photo-1540039155733-5bb30b4e843b?w=800&h=400&fit=crop",
    "green day":        "https://images.unsplash.com/photo-1429514513361-8fa32282fd5f?w=800&h=400&fit=crop",
    "muse":             "https://images.unsplash.com/photo-1540039155733-5bb30b4e843b?w=800&h=400&fit=crop",
    "u2":               "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&h=400&fit=crop",
    "metallica":        "https://images.unsplash.com/photo-1598387993441-a364f854c3e1?w=800&h=400&fit=crop",
    "iron maiden":      "https://images.unsplash.com/photo-1598387993441-a364f854c3e1?w=800&h=400&fit=crop",
    "slipknot":         "https://images.unsplash.com/photo-1598387993441-a364f854c3e1?w=800&h=400&fit=crop",
    "rammstein":        "https://images.unsplash.com/photo-1598387993441-a364f854c3e1?w=800&h=400&fit=crop",
    "system of a down": "https://images.unsplash.com/photo-1598387993441-a364f854c3e1?w=800&h=400&fit=crop",
    "tool":             "https://images.unsplash.com/photo-1598387993441-a364f854c3e1?w=800&h=400&fit=crop",
    "taylor swift":     "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&h=400&fit=crop",
    "beyoncé":          "https://images.unsplash.com/photo-1415886411536-4b2e9f7efc96?w=800&h=400&fit=crop",
    "beyonce":          "https://images.unsplash.com/photo-1415886411536-4b2e9f7efc96?w=800&h=400&fit=crop",
    "ed sheeran":       "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&h=400&fit=crop",
    "adele":            "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&h=400&fit=crop",
    "dua lipa":         "https://images.unsplash.com/photo-1415886411536-4b2e9f7efc96?w=800&h=400&fit=crop",
    "eminem":           "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "drake":            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "jay-z":            "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&h=400&fit=crop",
    "daft punk":        "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=400&fit=crop",
    "deadmau5":         "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=400&fit=crop",
    "tiësto":           "https://images.unsplash.com/photo-1571266028243-e4733b0f0bb0?w=800&h=400&fit=crop",
    "tiesto":           "https://images.unsplash.com/photo-1571266028243-e4733b0f0bb0?w=800&h=400&fit=crop",
    "martin garrix":    "https://images.unsplash.com/photo-1571266028243-e4733b0f0bb0?w=800&h=400&fit=crop",
    "david guetta":     "https://images.unsplash.com/photo-1571266028243-e4733b0f0bb0?w=800&h=400&fit=crop",
    "calvin harris":    "https://images.unsplash.com/photo-1571266028243-e4733b0f0bb0?w=800&h=400&fit=crop",
    "aphex twin":       "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&h=400&fit=crop",
    "pixies":           "https://images.unsplash.com/photo-1429514513361-8fa32282fd5f?w=800&h=400&fit=crop",
    "björk":            "https://images.unsplash.com/photo-1501386760131-1bac9b2b0e1d?w=800&h=400&fit=crop",
    "bjork":            "https://images.unsplash.com/photo-1501386760131-1bac9b2b0e1d?w=800&h=400&fit=crop",
    "frank ocean":      "https://images.unsplash.com/photo-1506157786151-b8491531f063?w=800&h=400&fit=crop",
    "sza":              "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&h=400&fit=crop",
    "h.e.r.":           "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&h=400&fit=crop",
    "yanni":            "https://images.unsplash.com/photo-1505236858219-8130083c5aa3?w=800&h=400&fit=crop",
    "yo-yo ma":         "https://images.unsplash.com/photo-1505236858219-8130083c5aa3?w=800&h=400&fit=crop",
    "ludovico einaudi": "https://images.unsplash.com/photo-1505236858219-8130083c5aa3?w=800&h=400&fit=crop",
    "max richter":      "https://images.unsplash.com/photo-1505236858219-8130083c5aa3?w=800&h=400&fit=crop",
}

# Kategori bazlı yedek görseller — sanatçı eşleşmesi bulunamadığında kullanılır
CATEGORY_FALLBACKS: dict[str, str] = {
    "Rock":         "https://images.unsplash.com/photo-1429514513361-8fa32282fd5f?w=800&q=80",
    "Metal":        "https://images.unsplash.com/photo-1598387993441-a364f854c3e1?w=800&q=80",
    "Pop":          "https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?w=800&q=80",
    "Hip-Hop":      "https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=800&q=80",
    "EDM":          "https://images.unsplash.com/photo-1571266028243-e4733b0f0bb0?w=800&q=80",
    "Electronic":   "https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?w=800&q=80",
    "Alternative":  "https://images.unsplash.com/photo-1540039155733-5bb30b4e843b?w=800&q=80",
    "Indie":        "https://images.unsplash.com/photo-1501386760131-1bac9b2b0e1d?w=800&q=80",
    "R&B":          "https://images.unsplash.com/photo-1506157786151-b8491531f063?w=800&q=80",
    "Klasik":       "https://images.unsplash.com/photo-1505236858219-8130083c5aa3?w=800&q=80",
    "Psychedelic":  "https://images.unsplash.com/photo-1501386760131-1bac9b2b0e1d?w=800&q=80",
    "Trip-Hop":     "https://images.unsplash.com/photo-1506157786151-b8491531f063?w=800&q=80",
}

DEFAULT_IMAGE = "https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=800&q=80"

# Başlıktan çıkarılacak son ekler
TITLE_SUFFIXES = [
    "konseri", "concert", "live", "tour", "festival",
    "gala", "show", "performans", "turnesi", "etkinliği",
    "istanbul", "ankara", "izmir", "bursa", "antalya",
    "open air", "live in",
]
# ─────────────────────────────────────────────────────────────────────────────


def normalize(text: str) -> str:
    return (
        text.lower()
        .replace("ş", "s").replace("ğ", "g").replace("ç", "c")
        .replace("ö", "o").replace("ü", "u").replace("ı", "i")
        .replace("İ", "i").strip()
    )


def extract_artist(title: str) -> str:
    """'Duman Konseri İstanbul' → 'Duman'"""
    t = title.strip()
    for suffix in TITLE_SUFFIXES:
        if normalize(t).endswith(normalize(suffix)):
            t = t[: -len(suffix)].strip(" -–—")
    return t


def resolve_image(title: str, category: str) -> tuple[str, str]:
    """
    Etkinlik başlığı ve kategorisine göre Unsplash URL döner.
    Dönen tuple: (url, kaynak)  — kaynak = 'artist' | 'category' | 'default'
    """
    artist = extract_artist(title)
    key = normalize(artist)

    # 1) Tam eşleşme
    if key in ARTIST_IMAGES:
        return ARTIST_IMAGES[key], "artist"

    # 2) Kısmi eşleşme (başlık içinde sanatçı adı geçiyorsa)
    for name, url in ARTIST_IMAGES.items():
        if name in key or key in name:
            return url, "artist~partial"

    # 3) Kategori yedek
    if category in CATEGORY_FALLBACKS:
        return CATEGORY_FALLBACKS[category], "category"

    # 4) Genel yedek
    return DEFAULT_IMAGE, "default"


def _get_token_and_project() -> tuple[str, str]:
    """Service account JSON'dan OAuth2 token ve project_id döner."""
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
    creds = google.oauth2.service_account.Credentials.from_service_account_file(
        SERVICE_ACCOUNT_KEY_PATH, scopes=scopes
    )
    # verify=False: kurumsal CA bu makinede Python'a tanıtılmamış
    session = requests.Session()
    session.verify = False
    auth_req = google.auth.transport.requests.Request(session=session)
    creds.refresh(auth_req)
    with open(SERVICE_ACCOUNT_KEY_PATH) as f:
        project_id = json.load(f)["project_id"]
    return creds.token, project_id


def _list_docs(base_url: str, headers: dict) -> list[dict]:
    """Firestore REST API ile tüm events dökümanlarını sayfalayarak çeker."""
    docs, page_token = [], None
    while True:
        params = {"pageSize": 300}
        if page_token:
            params["pageToken"] = page_token
        resp = requests.get(f"{base_url}/events", headers=headers, params=params, verify=False)
        resp.raise_for_status()
        body = resp.json()
        docs.extend(body.get("documents", []))
        page_token = body.get("nextPageToken")
        if not page_token:
            break
    return docs


def _str_field(value: str) -> dict:
    return {"stringValue": value}


def run(dry_run: bool = False, force: bool = False) -> None:
    token, project_id = _get_token_and_project()
    headers  = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
    base_url = (
        f"https://firestore.googleapis.com/v1"
        f"/projects/{project_id}/databases/(default)/documents"
    )

    print("Firestore'dan etkinlikler alınıyor...\n")
    docs = _list_docs(base_url, headers)
    print(f"Toplam {len(docs)} etkinlik bulundu.\n")

    counts = {"updated": 0, "skipped": 0}

    for doc in docs:
        fields   = doc.get("fields", {})
        title    = fields.get("title",    {}).get("stringValue", "(başlıksız)")
        category = fields.get("category", {}).get("stringValue", "")
        cur_url  = fields.get("imageUrl", {}).get("stringValue", "")
        doc_name = doc["name"]                      # full resource path
        doc_id   = doc_name.rsplit("/", 1)[-1]

        print(f"[{doc_id[:8]}]  {title}  ({category})")

        if cur_url and not force:
            print("  → imageUrl zaten var, atlanıyor  (--force ile üzerine yaz)\n")
            counts["skipped"] += 1
            continue

        url, source = resolve_image(title, category)
        short = url[:80] + "..." if len(url) > 80 else url

        if dry_run:
            print(f"  [DRY RUN] [{source}]  {short}\n")
        else:
            patch_url = f"https://firestore.googleapis.com/v1/{doc_name}"
            body = {"fields": {"imageUrl": _str_field(url)}}
            r = requests.patch(
                patch_url,
                headers=headers,
                params={"updateMask.fieldPaths": "imageUrl"},
                json=body,
                verify=False,
            )
            r.raise_for_status()
            print(f"  ✓ [{source}]  {short}\n")

        counts["updated"] += 1

    print("=" * 60)
    print(
        f"Tamamlandı!  Güncellenen: {counts['updated']}  "
        f"Atlanan: {counts['skipped']}"
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Firestore event imageUrl'lerini sabit Unsplash görselleriyle güncelle"
    )
    parser.add_argument(
        "--dry-run", action="store_true",
        help="Firestore'a yazmadan önizle",
    )
    parser.add_argument(
        "--force", action="store_true",
        help="Var olan imageUrl alanını da üzerine yaz",
    )
    args = parser.parse_args()

    if args.dry_run:
        print("⚠  DRY RUN — Firestore'a HİÇBİR ŞEY yazılmayacak\n")

    run(dry_run=args.dry_run, force=args.force)
