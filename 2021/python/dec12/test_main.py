from main import Graph


def test_cave_link_start():
    g = Graph()
    g.link('start-A')
    print(g.g)
    assert len(g.g['start']) == 1
    assert 'A' not in g.g

def test_cave_link_end():
    g = Graph()
    g.link('A-end')
    assert len(g.g['A']) == 1
    assert 'end' not in g.g

def test_cave_link_big_big():
    g = Graph()
    g.link('A-B')
    assert len(g.g['A']) == 1
    assert len(g.g['B']) == 1

def test_cave_link_big_small():
    g = Graph()
    g.link('A-b')
    assert len(g.g['A']) == 1
    assert len(g.g['b']) == 1

def test_cave_link_small_small():
    g = Graph()
    g.link('a-b')
    assert len(g.g['a']) == 1
    assert 'b' not in g.g

def test_cave_link_small_big():
    g = Graph()
    g.link('a-B')
    assert len(g.g['a']) == 1
    assert len(g.g['B']) == 1
