class ShortCutHtmlBuilder:
    def __init__(self):
        self.shortcuts = []

    def add_shortcut(self, kb, desc):
        self.shortcuts.append((kb, desc))

    def generate_html(self):
        rows = ''
        for kb, desc in self.shortcuts:
            rows += f'<tr><td>{kb}</td><td>{desc}</td></tr>\n'
        return f'<table>{rows}</table>'