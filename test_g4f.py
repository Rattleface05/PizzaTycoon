import g4f
try:
    response = g4f.ChatCompletion.create(
        model="gpt-4o",
        messages=[{"role": "user", "content": "Hello"}],
    )
    print("Success:")
    print(response)
except Exception as e:
    print("Failed:")
    print(e)
