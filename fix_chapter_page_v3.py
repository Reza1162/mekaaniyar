import shutil

path = "lib/features/chapters/chapter_page.dart"
shutil.copy(path, path + ".bak3")
text = open(path, encoding="utf-8").read()
changed = False

# 1) add import for the new native diagram widgets
old_import = "import '../pro/pro_page.dart';"
new_import = "import '../pro/pro_page.dart';\nimport '../../widgets/tech_diagrams.dart';"
if "widgets/tech_diagrams.dart" not in text:
    if old_import in text:
        text = text.replace(old_import, new_import, 1)
        changed = True
        print("added tech_diagrams import")
    else:
        print("COULD NOT find import anchor - add manually: import '../../widgets/tech_diagrams.dart';")
else:
    print("tech_diagrams import already present, skipped")

# 2) insert conditional native diagrams right before the Markdown widget
old_block = """          Expanded(
            child: Markdown("""

new_block = """          if (widget.section.id == 'engine_basics')
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: FourStrokeDiagram(),
            ),
          if (widget.section.id == 'cooling')
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: CoolingSystemDiagram(),
            ),
          if (widget.section.id == 'turbo_full')
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TurboSystemDiagram(),
            ),
          Expanded(
            child: Markdown("""

if "FourStrokeDiagram()" not in text:
    if old_block in text:
        text = text.replace(old_block, new_block, 1)
        changed = True
        print("added native diagram widgets before Markdown body")
    else:
        print("COULD NOT find the Expanded(child: Markdown( block - paste current file content so I can adjust")
else:
    print("diagram widgets already present, skipped")

if changed:
    open(path, "w", encoding="utf-8").write(text)
    print("done - backup saved as chapter_page.dart.bak3")
else:
    print("no changes made")
