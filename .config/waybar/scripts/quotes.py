#!/usr/bin/env python3
import requests
import json
import random
import re
import sys

URL = "https://jamies.page/assets/static/navibar"

try:
    response = requests.get(URL, timeout=5)
    response.raise_for_status()
    content = response.text

    try:
        quotes = json.loads(content)
    except json.JSONDecodeError:
        match = re.search(r'\[(.*?)\]', content, re.DOTALL)
        if match:
            quotes = json.loads(f"[{match.group(1)}]")
        else:
            sys.exit(1)

    if quotes:
        print(random.choice(quotes))

except Exception:
    print("")
