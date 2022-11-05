from main import Cave

def test_cave_link_big_big():
    a = Cave('A')
    b = Cave('B')
    a.link(b)
    assert len(a.links) == 1
    assert len(b.links) == 1

def test_cave_link_big_small():
    a = Cave('A')
    b = Cave('b')
    a.link(b)
    assert len(a.links) == 1
    assert len(b.links) == 1

def test_cave_link_small_small():
    a = Cave('a')
    b = Cave('b')
    a.link(b)
    assert len(a.links) == 1
    assert len(b.links) == 0

def test_cave_link_small_big():
    a = Cave('a')
    b = Cave('B')
    a.link(b)
    assert len(a.links) == 1
    assert len(b.links) == 0
