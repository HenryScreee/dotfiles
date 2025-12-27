#!/usr/bin/env python3
import requests, json, random, re, os

URL = "https://jamies.page/assets/static/navibar"
CACHE_FILE = os.path.expanduser("~/.cache/waybar_quote_cache")

def get_quote():
    try:
        response = requests.get(URL, timeout=3)
        content = response.text
        try: 
            quotes = json.loads(content)
        except json.JSONDecodeError:
            match = re.search(r'\[(.*?)\]', content, re.DOTALL)
            quotes = json.loads(f"[{match.group(1)}]") if match else []
        
        if quotes:
            quote = random.choice(quotes)
            # Save to cache
            with open(CACHE_FILE, "w") as f:
                f.write(quote)
            return quote
    except:
        pass
    
    # Fallback to cache if network fails
    if os.path.exists(CACHE_FILE):
        with open(CACHE_FILE, "r") as f:
            return f.read().strip()
            
    return "Focus." # Ultimate fallback

print(get_quote())
