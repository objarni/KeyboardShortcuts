from xml.dom import minidom
from hypothesis import given, example, settings, reproduce_failure
import hypothesis.strategies as gen

KB_GEN = gen.text(min_size=1)
DESC_GEN = gen.text(min_size=1)
KB_DESC_GEN = gen.tuples(KB_GEN, DESC_GEN)
SHORTCUTLIST_GEN = gen.lists(KB_DESC_GEN, min_size=1)


@given(SHORTCUTLIST_GEN)
def test_output_contains_a_table(shortcut_list):
    b = ShortCutHtmlBuilder()
    for (kb, desc) in shortcut_list:
        b.add_shortcut(kb, desc)
    html = b.generate_html()
    assert '<table>' in html


@given(SHORTCUTLIST_GEN)
def test_output_contains_rows_for_every_shortcut(shortcut_list):
    b = ShortCutHtmlBuilder()
    for (kb, desc) in shortcut_list:
        b.add_shortcut(kb, desc)
    html = b.generate_html()
    assert html.count('<tr>') == len(shortcut_list)


@given(SHORTCUTLIST_GEN)
def test_output_contains_every_description(shortcut_list):
    b = ShortCutHtmlBuilder()
    for (kb, desc) in shortcut_list:
        b.add_shortcut(kb, desc)
    html = b.generate_html()
    for (kb, desc) in shortcut_list:
        assert desc in html


@given(SHORTCUTLIST_GEN)
def test_output_contains_every_kb_shortcut(shortcut_list):
    b = ShortCutHtmlBuilder()
    for (kb, desc) in shortcut_list:
        b.add_shortcut(kb, desc)
    html = b.generate_html()
    for (kb, desc) in shortcut_list:
        assert kb in html


@given(SHORTCUTLIST_GEN)
def test_output_has_twice_as_many_cells_as_shortcuts(shortcut_list):
    b = ShortCutHtmlBuilder()
    for (kb, desc) in shortcut_list:
        b.add_shortcut(kb, desc)
    html = b.generate_html()
    assert len(shortcut_list) * 2 == html.count("<td>")


@given(SHORTCUTLIST_GEN)
@settings(print_blob=True)
@example([('0', '0')])
def test_produces_valid_xml_document(shortcut_list):
    b = ShortCutHtmlBuilder()
    for (kb, desc) in shortcut_list:
        b.add_shortcut(kb, desc)
    html = b.generate_html()
    try:
        minidom.parseString(html)
    except:
        print(html)
        raise


@given(SHORTCUTLIST_GEN)
def test_every_end_tr_is_followed_by_newline(shortcut_list):
    b = ShortCutHtmlBuilder()
    for (kb, desc) in shortcut_list:
        b.add_shortcut(kb, desc)
    html = b.generate_html()
    assert html.count('</tr>') == html.count('</tr>\n')



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


