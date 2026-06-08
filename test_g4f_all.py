import g4f
from g4f.client import Client

working = []
for name in dir(g4f.Provider):
    if name.startswith("_"): continue
    p = getattr(g4f.Provider, name)
    if isinstance(p, type) and issubclass(p, g4f.Provider.BaseProvider):
        if hasattr(p, 'needs_auth') and p.needs_auth: continue
        try:
            client = Client(provider=p)
            response = client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[{"role": "user", "content": "Hello"}],
            )
            print(f"Success with {name}")
            working.append(name)
            break
        except Exception:
            pass

print(f"Found working: {working}")
