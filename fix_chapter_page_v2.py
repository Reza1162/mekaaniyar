import shutil

path = "lib/features/chapters/chapter_page.dart"
shutil.copy(path, path + ".bak2")
text = open(path, encoding="utf-8").read()

old = """                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SvgPicture.asset(path, width: double.infinity, fit: BoxFit.contain),
                  );"""

new = """                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: SvgPicture.asset(path, fit: BoxFit.contain),
                    ),
                  );"""

if old in text:
    text = text.replace(old, new, 1)
    open(path, "w", encoding="utf-8").write(text)
    print("fixed: SVG box height is now bounded (220) instead of unbounded")
elif "height: 220" in text:
    print("already fixed, skipped")
else:
    print("COULD NOT find the expected block - paste your current chapter_page.dart content and I'll adjust manually")
