"""
2021 Dec 13 module

Problem description: ../../dec13/README.md

Input:
- Set of positions where dots are
  - The number of positions represents the number of lines on the paper
- Fold instructions

Model:
- Transparent paper
 - Size: based on number of positions
 - Dots positions: places where position is
 - Functions:
  - Print: print paper shape
  - Fold: compress paper by folding and mixing dots
   - Folding could create a new paper
"""


class FoldInstruction:
    def __init__(self, instruction: str):
        cmd = instruction[len("fold along "):]
        # print(cmd)
        s = cmd.split("=")
        self.direction = s[0]
        self.position = int(s[1])

    def __str__(self):
        return "Fold(direction=% s,position=% s)" % (self.direction, self.position)


class Position:
    def __init__(self, instruction):
        s = instruction.split(",")
        self.x = int(s[0])
        self.y = int(s[1])

    def __str__(self):
        return "Position(x=% s,x=% s)" % (self.x, self.y)


class TransparentPaper:
    def __init__(self, rows, cols, dots_by_row, dots_by_col, folds):

        # zero indexed
        self.rows = rows
        self.cols = cols

        self.dots_by_row = dots_by_row
        self.dots_by_col = dots_by_col
        self.folds = folds

    #def fold(self):
    @classmethod
    def parse(cls, instructions):
        """
        Instructions as in the input of the problem are received and parsed.
        """
        rows = 0
        cols = 0
        dots_by_row = {} # dots positions organized by row
        dots_by_col = {} # dots positions organized by row
        folds = []
        for i in instructions:
            instruction = i.strip()
            if len(instruction.split(",")) == 2:
                p = Position(instruction)
                if p.x > cols:
                    cols = p.x
                if p.y > rows:
                    rows = p.y
                if p.y in dots_by_row: dots_by_row[p.y].append(p.x)
                else: dots_by_row[p.y] = [ p.x ]
                if p.x in dots_by_col: dots_by_col[p.x].append(p.y)
                else: dots_by_row[p.x] = [ p.y ]
            else:
                if instruction.startswith("fold along "):
                    fold = FoldInstruction(instruction)
                    folds.append(fold)
        return cls(rows + 1, cols + 1, dots_by_row, dots_by_col, folds)

    def print(self):
        for i in range(0, self.rows):
            line = ""
            for j in range(0, self.cols):
                if i in self.dots_by_row and j in self.dots_by_row[i]:
                    line = line + "#"
                else:
                    line = line + "."

            print("Line:% s: % s" % (str(i).zfill(3), line))

    def __str__(self):
        return "TransparentPaper(rows=% s,cols=% s,dots_by_row=% s,folds=% s)" % (self.rows, self.cols, self.dots_by_row, self.folds)


def main() -> int:
    f = open('../../dec13/test.txt', 'r')
    # f = open('../../dec13/input.txt', 'r')
    t = TransparentPaper.parse(f.readlines())
    print(t)
    t.print()
    return 0


import sys

if __name__ == "__main__":
    sys.exit(main())
