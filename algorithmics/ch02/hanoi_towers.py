# Towers of Hanoi
#
# Inputs:
# - N number of rigns
# Constant:
# - 3 towers/positions

# Output:
# - List of moves to achieve final result (commands?)

# Invariants:
# - Rings moved one at the time
# - Never move a larger ring on top of a smaller one

# Solution proposed in this chapter using recursivity:
# Subroutine move N from X to Y using Z:
# 1. if N is 1, then output "move X to Y"
# 2. otherwise (ie. if N is higher than 1) do the following:
# 2.1. call move N - 1 from X to Z using Y;
# 2.2. output "move X to Y"
# 2.3. call move N - 1 from Z to Y using X;
# 3. return

# Potential enhancements:
# - Test list of commands to validate it works
# - Print simulation of commands

# ===

def hanoi(n: int):
    """
    Process hanoi algorithm for n rings.
    It receives the number of rings and returns a list of moves/commands
    """

    cmd = []

    hanoi_step(n, "A", "B", "C", cmd)

    return cmd

def hanoi_step(n: int, _from, _to, _other, cmd):
    if n == 1:
        cmd.append(_from + " -> " + _to)
    else:
        hanoi_step(n - 1, _from, _other, _to, cmd)
        cmd.append(_from + " -> " + _to)
        hanoi_step(n - 1, _other, _to, _from, cmd)

# run hanoi: implement a set of 3 stacks where each command is processed and steps can be observed.
# printing can be an additional step or included in this run simulation logic

import sys

if __name__ == "__main__":
    args_len = len(sys.argv)
    if args_len != 2:
        print("Pass a number of rings!")
        sys.exit(1)

    n = sys.argv[1]
    print("Number of rings: {0}".format(n))

    cmd = hanoi(int(n))

    print(cmd)
