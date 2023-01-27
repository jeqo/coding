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
        self.position = s[1]

    def __str__(self):
        return "Fold(direction=% s,position=% s)" % (self.direction, self.position)


class Position:
    def __init__(self, instruction):
        s = instruction.split(",")
        self.x = s[0]
        self.y = s[1]

    def __str__(self):
        return "Position(x=% s,x=% s)" % (self.x, self.y)


class TransparentPaper:
    def __init__(self, instructions):
        """
        Instructions as in the input of the problem are received and parsed.
        """
        lines = 0
        pos = []
        folds = []
        for i in instructions:
            instruction = i.strip()
            if len(instruction.split(",")) == 2:
                lines = lines + 1
                pos.append(Position(instruction))
            else:
                if instruction.startswith("fold along "):
                    fold = FoldInstruction(instruction)
                    folds.append(fold)

        self.lines = lines
        self.pos = pos
        self.folds = folds

    def __str__(self):
        return "TransparentPaper(lines=% s,pos=% s,folds=% s)" % (self.lines, self.pos, self.folds)


def main() -> int:
    f = open('../../dec13/test.txt', 'r')
    # f = open('../../dec13/input.txt', 'r')
    t = TransparentPaper(f.readlines())
    print(t)
    return 0


import sys

if __name__ == "__main__":
    sys.exit(main())
