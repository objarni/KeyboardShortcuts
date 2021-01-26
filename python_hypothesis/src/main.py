from pathlib import Path

from src.html_gen import ShortCutHtmlBuilder

if __name__ == '__main__':
    builder = ShortCutHtmlBuilder()
    builder.set_context('i3')
    builder.add_shortcut("Meta+Sh+V", "Edit config")
    html = builder.generate_html()
    print(html)
