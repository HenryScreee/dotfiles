#!/usr/bin/env python3
import json, random, os, sys

# Try imports, fail gracefully if requests is missing (should be fixed now though)
try:
    import requests
except ImportError:
    sys.exit(1)

URL = "https://jamies.page/assets/static/navibar"
CACHE_FILE = "/tmp/jamie_quotes_cache.json"
FALLBACK_QUOTE = "Focus."

def fetch_and_cache():
    """Fetches the full list of quotes and saves to /tmp"""
    try:
        response = requests.get(URL, timeout=5)
        response.raise_for_status()
        content = response.text
        
        # Jamie's API sometimes returns raw JS arrays like ['a','b'] instead of strict JSON
        # If json.loads fails, we wrap it in valid syntax or Regex it.
        try:
            quotes = json.loads(content)
        except json.JSONDecodeError:
            import re
            match = re.search(r'\[(.*?)\]', content, re.DOTALL)
            if match:
                quotes = json.loads(f"[{match.group(1)}]")
            else:
                return []

        if quotes:
            with open(CACHE_FILE, "w") as f:
                json.dump(quotes, f)
            return quotes
    except Exception:
        return []
    return []

def get_quote():
    # 1. Try to read from local Cache (0 Network)
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                quotes = json.load(f)
                if quotes: return random.choice(quotes)
        except:
            pass # Cache corrupt? Fall through to fetch.

    # 2. If no cache, Fetch from Web (One time only)
    quotes = fetch_and_cache()
    if quotes:
        return random.choice(quotes)

    # 3. Ultimate Fallback (Offline & No Cache)
    return FALLBACK_QUOTE

if __name__ == "__main__":
    print(get_quote())
