def sort(l):
    """
    The bubblesort algorithm consists on comparing elements
    starting from the bottom, and bubble up the the larger ones
    """
    for i in range(0, len(l)):
        for j in range(i + 1, len(l)):
            print("Item before: " + l[i] + " and " + l[j])
            if l[i] > l[j]: # bubble up and down
                tmp = l[i]
                l[i] = l[j]
                l[j] = tmp
                print("Item after: " + l[i] + " and " + l[j])
    return l


import sys
if __name__ == "__main__":
    n = len(sys.argv)
    print("Total number of args {0} \n".format(n))

    if n == 2:
        s = sys.argv[1]
        print("Input: {0}\n".format(s))
        print("Results:")
        for i in sort(s.split(",")):
            print("Item: " + i)
    else:
        print("Pass an arg")
