# main.py
class Graph:
    def __init__(self):
        self.g = {}

    def link(self, path):
        """Takes a path and create links. If source cave is big, then link back."""
        p = path.split('-')
        _from = p[0]
        _to = p[1]
        self.add(_from, _to)
        if _from.isupper() or _to.isupper() :
            self.add(_to, _from)

    def add(self, _from, _to):
        if _to == 'start' or _from == 'end':
            return
        print(f"Add {_from} -> {_to}")
        if _from not in self.g:
            self.g[_from] = [_to]
        else:
            self.g[_from].append(_to)


def paths(g):
    paths = []
    for i in range(0, len(g.g['start'])):
        paths.append(inner_paths(g, 'start', i, []))
    return paths

def inner_paths(g, cave, i, prev):
    if cave.islower() and cave in prev:
        print(f'small cave {cave} already found @ {i}')
        p = prev[len(prev) - 1]
        opts = g.g[p]
        idx = opts.index(cave)
        print(f'index: {idx}')
        if idx + 1 < len(opts):
            del(prev[len(prev)-1])
            return inner_paths(g, p, idx+1, prev)
        else:
            return prev
    
    print(cave)
    prev.append(cave)
    
    if cave == 'end': # final cave
        print('end!')
        return prev
    if cave not in g.g: # lost
        print('last path step ' + cave)
        return prev
    
    opt = g.g[cave][i]
    
    return inner_paths(g, opt, 0, prev)


def main():
    g = Graph()

    f = open('../../dec12/test_0.txt', 'r')
    for line in f.readlines():
        g.link(line.strip())

    print(g.g)

    print(paths(g))

    return 0

if __name__ == '__main__':
    import sys
    sys.exit(main())
