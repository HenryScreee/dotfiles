#!/usr/bin/env python3
import json, random, os, sys

# Try imports
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
        
        # --- THE FIX: FORCE UTF-8 ENCODING ---
        response.encoding = 'utf-8' 
        # -------------------------------------
        
        response.raise_for_status()
        content = response.text
        
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
    # 1. Try to read from local Cache
    if os.path.exists(CACHE_FILE):
        try:
            with open(CACHE_FILE, "r") as f:
                quotes = json.load(f)
                if quotes: return random.choice(quotes)
        except:
            pass 

    # 2. Fetch from Web (Force Refresh for this test)
    quotes = fetch_and_cache()
    if quotes:
        return random.choice(quotes)

    return FALLBACK_QUOTE

if __name__ == "__main__":
    # Force a cache clear so we can see the fix immediately
    if os.path.exists(CACHE_FILE):
        os.remove(CACHE_FILE)
    print(get_quote())
