from hypothesis import strategies as gen

ALPHABET = "abcdefhijklmnopqrstuvwxyzåäö+ "
KB_GEN = gen.text(min_size=1, alphabet=ALPHABET)
DESC_GEN = gen.text(min_size=1, alphabet=ALPHABET)
KB_DESC_GEN = gen.tuples(KB_GEN, DESC_GEN)
SHORTCUTLIST_GEN = gen.lists(KB_DESC_GEN, min_size=1)


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