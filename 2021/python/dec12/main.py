# main.py

class Cave:
    def __init__(self, name):
        self.name = name
        self.links = []

    def __str__(self):
        return "Cave{name: % s links: % s}" % (self.name, self.links)
    
    def __repr__(self):
        return "Cave{name: % s links: % s}" % (self.name, self.links)

    def link(self, other_cave):
        self.links.append(other_cave)
        if self.name.isupper():
            other_cave.links.append(self)
        return

class Graph:
    def __init__(self):
        return

def main():
    a = Cave('a')
    b = Cave('B')
    a.link(b)
    print(a)
    return 0

if __name__ == '__main__':
    import sys
    sys.exit(main())
