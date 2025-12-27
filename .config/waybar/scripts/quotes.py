#!/usr/bin/env python3
import requests, json, random, re
URL = "https://jamies.page/assets/static/navibar"
try:
    response = requests.get(URL, timeout=5)
    content = response.text
    try: quotes = json.loads(content)
    except json.JSONDecodeError:
        match = re.search(r'\[(.*?)\]', content, re.DOTALL)
        quotes = json.loads(f"[{match.group(1)}]") if match else []
    if quotes: print(random.choice(quotes))
except: print("")
