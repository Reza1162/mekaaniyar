import re, shutil, sys

path = "pubspec.yaml"
shutil.copy(path, path + ".bak")
text = open(path, encoding="utf-8").read()
lines = text.split("\n")

# 1) add flutter_svg under dependencies: if not present
if "flutter_svg" not in text:
    out = []
    added = False
    in_deps = False
    for line in lines:
        out.append(line)
        if re.match(r"^dependencies:\s*$", line):
            in_deps = True
            continue
        if in_deps and not added:
            # first line after dependencies: that starts with two spaces (a key) -> insert before it
            if re.match(r"^  \S", line) and "flutter:" in line:
                # insert flutter_svg right after this line (keeps sdk: flutter block intact)
                pass
        if in_deps and not added and line.strip() == "" :
            out.insert(len(out)-1, "  flutter_svg: ^2.0.10")
            added = True
            in_deps = False
    if not added:
        # fallback: insert right after "dependencies:" line
        out = []
        for line in lines:
            out.append(line)
            if re.match(r"^dependencies:\s*$", line) and not added:
                out.append("  flutter_svg: ^2.0.10")
                added = True
    lines = out
    text = "\n".join(lines)
    print("added flutter_svg dependency" if added else "COULD NOT auto-add flutter_svg - check manually")
else:
    print("flutter_svg already present, skipped")

# 2) add assets entry under flutter: / assets: if not present
if "assets/content/diagrams/" not in text:
    lines = text.split("\n")
    out = []
    i = 0
    has_assets_block = "assets:" in text
    inserted = False
    while i < len(lines):
        line = lines[i]
        out.append(line)
        if re.match(r"^  assets:\s*$", line) and not inserted:
            out.append("    - assets/content/diagrams/")
            inserted = True
        i += 1
    if not inserted:
        # no assets: block yet -> add one under "flutter:" section
        out2 = []
        i = 0
        while i < len(lines):
            line = lines[i]
            out2.append(line)
            if re.match(r"^flutter:\s*$", line) and not inserted:
                out2.append("  assets:")
                out2.append("    - assets/content/diagrams/")
                inserted = True
            i += 1
        out = out2
    text = "\n".join(out)
    print("added assets/content/diagrams/ entry" if inserted else "COULD NOT auto-add assets entry - check manually")
else:
    print("assets entry already present, skipped")

open(path, "w", encoding="utf-8").write(text)
print("done - backup saved as pubspec.yaml.bak")
