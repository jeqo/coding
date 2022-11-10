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
    #assert 'b' not in g.g

def test_cave_link_small_big():
    g = Graph()
    g.link('a-B')
    assert len(g.g['a']) == 1
    assert len(g.g['B']) == 1

def test_simple_path():
    # given
    g = Graph()
    g.link('start-A')
    g.link('A-end')

    # when
    paths = g.do_paths()
    print(f'Result {paths}')
    # then
    assert len(paths) == 1
    assert paths[0] == ['start', 'A', 'end']

def test_simple_path_with_bif():
    # given
    g = Graph()
    g.link('start-A')
    g.link('start-B')
    g.link('B-end')
    g.link('A-end')

    # when
    paths = g.do_paths()
    print(f'Result {paths}')
    # then
    assert len(paths) == 2
    assert paths[0] == ['start', 'A', 'end']
    assert paths[1] == ['start', 'B', 'end']

def test_simple_path_with_loop():
    # given
    g = Graph()
    g.link('start-A')
    g.link('A-b')
    g.link('A-end')

    # when
    paths = g.do_paths()
    print(f'Result {paths}')
    # then
    assert len(paths) == 3
    assert paths[0] == ['start', 'A', 'b', 'A', 'b', 'A', 'end']
    assert paths[1] == ['start', 'A', 'b', 'A', 'end']
    assert paths[2] == ['start', 'A', 'end']
    
def test_part_one_set_0():
    g = Graph()
    f = open('../../dec12/test_0.txt', 'r')
    for line in f.readlines():
        g.link(line.strip())

    print(g.g)
    res = g.do_paths()
    print(f'Resultado: {res} total={len(res)}')

    assert ['start','A','b','A','b','A','c','A','end'] in res
    assert ['start','A','b','A','b','A','end'] in res
    assert ['start','A','b','A','b','end'] in res
    assert ['start','A','b','A','c','A','b','A','end'] in res
    assert ['start','A','b','A','c','A','b','end'] in res
    assert ['start','A','b','A','c','A','c','A','end'] in res
    assert ['start','A','b','A','c','A','end'] in res
    assert ['start','A','b','A','end'] in res
    assert ['start','A','b','d','b','A','c','A','end'] in res
    assert ['start','A','b','d','b','A','end'] in res
    assert ['start','A','b','d','b','end'] in res
    assert ['start','A','b','end'] in res
    assert ['start','A','c','A','b','A','b','A','end'] in res
    assert ['start','A','c','A','b','A','b','end'] in res
    assert ['start','A','c','A','b','A','c','A','end'] in res
    assert ['start','A','c','A','b','A','end'] in res
    assert ['start','A','c','A','b','d','b','A','end'] in res
    assert ['start','A','c','A','b','d','b','end'] in res
    assert ['start','A','c','A','b','end'] in res
    assert ['start','A','c','A','c','A','b','A','end'] in res
    assert ['start','A','c','A','c','A','b','end'] in res
    assert ['start','A','c','A','c','A','end'] in res
    assert ['start','A','c','A','end'] in res
    assert ['start','A','end'] in res
    assert ['start','b','A','b','A','c','A','end'] in res
    assert ['start','b','A','b','A','end'] in res
    assert ['start','b','A','b','end'] in res
    assert ['start','b','A','c','A','b','A','end'] in res
    assert ['start','b','A','c','A','b','end'] in res
    assert ['start','b','A','c','A','c','A','end'] in res
    assert ['start','b','A','c','A','end'] in res
    assert ['start','b','A','end'] in res
    assert ['start','b','d','b','A','c','A','end'] in res
    assert ['start','b','d','b','A','end'] in res
    assert ['start','b','d','b','end'] in res
    assert ['start','b','end'] in res

    assert len(res) == 36

def test_part_one_set_1():
    g = Graph()
    f = open('../../dec12/test_1.txt', 'r')
    for line in f.readlines():
        g.link(line.strip())

    print(g.g)
    res = g.do_paths()
    print(f'Resultado: {res} total={len(res)}')
#    
#    assert ['start','HN','dc','HN','end'] in res
#    assert ['start','HN','dc','HN','kj','HN','end'] in res
#    assert ['start','HN','dc','end'] in res
#    assert ['start','HN','dc','kj','HN','end'] in res
#    assert ['start','HN','end'] in res
#    assert ['start','HN','kj','HN','dc','HN','end'] in res
#    assert ['start','HN','kj','HN','dc','end'] in res
#    assert ['start','HN','kj','HN','end'] in res
#    assert ['start','HN','kj','dc','HN','end'] in res
#    assert ['start','HN','kj','dc','end'] in res
#    assert ['start','dc','HN','end'] in res
#    assert ['start','dc','HN','kj','HN','end'] in res
#    assert ['start','dc','end'] in res
#    assert ['start','dc','kj','HN','end'] in res
#    assert ['start','kj','HN','dc','HN','end'] in res
#    assert ['start','kj','HN','dc','end'] in res
#    assert ['start','kj','HN','end'] in res
#    assert ['start','kj','dc','HN','end'] in res
#    assert ['start','kj','dc','end'] in res
    assert len(res) == 103

def test_part_one_set_2():
    g = Graph()
    f = open('../../dec12/test_2.txt', 'r')
    for line in f.readlines():
        g.link(line.strip())

    print(g.g)
    res = g.do_paths()
    print(f'Resultado: {res} total={len(res)}')

    assert len(res) == 3509
