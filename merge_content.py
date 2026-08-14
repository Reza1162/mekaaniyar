import json, os

with open("assets/content/chapters.json", encoding="utf-8") as f:
    main = json.load(f)

for fname in os.listdir("assets/content"):
    if fname.endswith("_full.json"):
        with open(f"assets/content/{fname}", encoding="utf-8") as f:
            new_data = json.load(f)
        for i, ch in enumerate(main["chapters"]):
            if ch["id"] == new_data["id"]:
                existing_ids = {s["id"] for s in ch["sections"]}
                for sec in new_data["sections"]:
                    if sec["id"] not in existing_ids:
                        main["chapters"][i]["sections"].append(sec)
                    else:
                        for j, s in enumerate(main["chapters"][i]["sections"]):
                            if s["id"] == sec["id"]:
                                main["chapters"][i]["sections"][j] = sec
                print(f"ادغام شد: {fname}")

with open("assets/content/chapters.json", "w", encoding="utf-8") as f:
    json.dump(main, f, ensure_ascii=False, indent=2)
print("chapters.json بروزرسانی شد")
