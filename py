#!/usr/bin/env python3
import sys

def join_anytype(lst):
    return " ".join([ str(e) for e in lst])
     
def to_number(lst):
    ans = []
    for n, e in enumerate(lst):
        try:
            a = int(e)
        except:
            try:
                a = float(e)
            except:
                a = e

        ans.append(a)

    return ans

for line in sys.stdin:
    F = to_number( line.rstrip('\n').split(' ') )
    eval("print(join_anytype(" + sys.argv[1] + "))")
