import shutil, sys

path = "lib/features/chapters/chapter_page.dart"
shutil.copy(path, path + ".bak")
text = open(path, encoding="utf-8").read()

changed = False

# 1) add flutter_svg import right after flutter_markdown import
old_import = "import 'package:flutter_markdown/flutter_markdown.dart';"
new_import = "import 'package:flutter_markdown/flutter_markdown.dart';\nimport 'package:flutter_svg/flutter_svg.dart';"
if "flutter_svg/flutter_svg.dart" not in text:
    if old_import in text:
        text = text.replace(old_import, new_import, 1)
        changed = True
        print("added flutter_svg import")
    else:
        print("COULD NOT find flutter_markdown import line - check manually")
else:
    print("flutter_svg import already present, skipped")

# 2) add imageBuilder to the Markdown( widget
old_widget = """child: Markdown(
              data: widget.section.content,
              padding: const EdgeInsets.all(16),
              styleSheet: MarkdownStyleSheet("""

new_widget = """child: Markdown(
              data: widget.section.content,
              padding: const EdgeInsets.all(16),
              imageBuilder: (uri, title, alt) {
                final path = 'assets/content/${uri.toString()}';
                if (path.toLowerCase().endsWith('.svg')) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SvgPicture.asset(path, width: double.infinity, fit: BoxFit.contain),
                  );
                }
                return Image.asset(path, fit: BoxFit.contain);
              },
              styleSheet: MarkdownStyleSheet("""

if "imageBuilder:" not in text:
    if old_widget in text:
        text = text.replace(old_widget, new_widget, 1)
        changed = True
        print("added imageBuilder to Markdown widget")
    else:
        print("COULD NOT find the exact Markdown( block - check manually (formatting may differ)")
else:
    print("imageBuilder already present, skipped")

if changed:
    open(path, "w", encoding="utf-8").write(text)
    print("done - backup saved as chapter_page.dart.bak")
else:
    print("no changes made")
