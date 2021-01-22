from xml.dom import minidom
from hypothesis import given, example, settings

from src.html_gen import SHORTCUTLIST_GEN, ShortCutHtmlBuilder


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



