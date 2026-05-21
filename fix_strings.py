import re

file_path = "NinniAI/Models/SoundDataMap.swift"
with open(file_path, "r") as f:
    content = f.read()

# Replace displayName: "..." with displayName: String(localized: "...")
content = re.sub(r'displayName:\s*"([^"]+)"', r'displayName: String(localized: "\1")', content)

# Replace description: "..." with description: String(localized: "...")
content = re.sub(r'description:\s*"([^"]+)"', r'description: String(localized: "\1")', content)

with open(file_path, "w") as f:
    f.write(content)

print("Done replacing strings in SoundDataMap.swift")
