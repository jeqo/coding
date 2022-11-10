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
        self.add(_to, _from)

    def add(self, _from, _to):
        if _to == 'start' or _from == 'end':
            return
        #print(f"Add {_from} -> {_to}")
        if _from not in self.g:
            self.g[_from] = [_to]
        else:
            self.g[_from].append(_to)


    # start # start
    # start-A # loop - branch 1
    # start-A-b-A # loop
    # start-A-b-A-c # loop
    # start-A-b-A-c-A-end # return
    # start-A-b-A-end # return
    # start-b # loop - branch 2
    def do_paths(self):
        _from = 'start'
        paths = []
        for _to in self.g[_from]:
            for path in self.do_inner_paths(_from, _to, [], True):
                paths.append(path)
        return paths

    def do_inner_paths(self, _from, _to, path, rep):
        if _from.islower() and _from in path:
            if rep:
                rep = False
            else:
                print(f'Step {_from} already present {path}')
                return []

        # print(f'Do inner paths: {_from}->{_to} with path: {path}')
        path.append(_from)

        if _to == 'end':
            path.append(_to)
            print(f'Found end! with path: {path}')
            return [path]

        if _to not in self.g: # lost
            print(f'no exit @ {_to}')
            return []
            
        paths = []
        for _next in self.g[_to]:
            # print(f'Check next {_to}->{_next} with path: {path}')
            if not rep and _next in path and path[path.index(_next) - 1] == _to:
                print(f'Step {_to}->{_next} already present {path}')
            else:
                res = self.do_inner_paths(_to, _next, path.copy(), rep)
                # print(f'Intermediate {res}')
                for r in res:
                    paths.append(r)
        return paths

def main():
    g = Graph()

    #f = open('../../dec12/test_0.txt', 'r')
    #f = open('../../dec12/test_1.txt', 'r')
    #f = open('../../dec12/test_2.txt', 'r')
    f = open('../../dec12/input.txt', 'r')
    for line in f.readlines():
        g.link(line.strip())

    print(g.g)
    res = g.do_paths()
    print(f'Resultado: {res} total={len(res)}')

    return 0

if __name__ == '__main__':
    import sys
    sys.exit(main())
