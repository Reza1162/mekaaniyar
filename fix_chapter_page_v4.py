import shutil

path = "lib/features/chapters/chapter_page.dart"
shutil.copy(path, path + ".bak4")
text = open(path, encoding="utf-8").read()
changed = False

old_block = """          if (widget.section.id == 'turbo_full')
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TurboSystemDiagram(),
            ),
          Expanded(
            child: Markdown("""

new_block = """          if (widget.section.id == 'turbo_full')
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TurboSystemDiagram(),
            ),
          if (widget.section.id == 'paint_process')
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: PaintLayersDiagram(),
            ),
          if (widget.section.id == 'body_repair_basics')
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: DamageRepairFlowDiagram(),
            ),
          Expanded(
            child: Markdown("""

if "PaintLayersDiagram()" not in text:
    if old_block in text:
        text = text.replace(old_block, new_block, 1)
        changed = True
        print("added PaintLayersDiagram and DamageRepairFlowDiagram")
    else:
        print("COULD NOT find the turbo_full anchor block - paste your current chapter_page.dart so I can adjust")
else:
    print("already present, skipped")

if changed:
    open(path, "w", encoding="utf-8").write(text)
    print("done - backup saved as chapter_page.dart.bak4")
else:
    print("no changes made")
