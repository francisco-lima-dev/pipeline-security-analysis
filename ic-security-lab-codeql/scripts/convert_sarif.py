import sys
import json

file_sarif = sys.argv[1]
file_json = sys.argv[2]

with open(file_sarif, "r") as file:
    content_sarif = file.read()

converted_json= json.loads(content_sarif)

with open(file_json, "w", encoding='utf-8') as file:
    json.dump(converted_json, file, ensure_ascii=False, indent=4)