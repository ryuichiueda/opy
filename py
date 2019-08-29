#!/usr/bin/env python3
import sys, os, ast

VERSION = "0.1.0"
COPYRIGHT = "Ryuichi Ueda"
LICENSE = "MIT license"

f = []

def usage():
    print("py " + VERSION, file=sys.stderr)
    print("Copyright 2019 " + COPYRIGHT, file=sys.stderr)
    print("Released under " + LICENSE, file=sys.stderr)

def F(n):
    return f[n]

def Fs(n, m=0):
    if m == 0:
       m = n

    return " ".join(str(x) for x in f[n:m+1])

def to_number(lst):
    ans = []
    for e in lst:
        try:
            a = int(e)
        except:
            try:    a = float(e)
            except: a = e

        ans.append(a)

    return ans

def parse(arg):
    pattern, action = "", ""

    for n in range(len(arg)):
        try:
            ast.parse(arg[-n-1:])
            return arg[:-n-1], arg[-n-1:]
        except:
            pass

    return pattern, action

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--help":
        usage()
        sys.exit(1)

    pattern, action = parse(sys.argv[1])
    
    for line in sys.stdin:
        line = line.rstrip('\n')
        f = [line] + to_number( line.split(' ') )

        if action == "":
            lst = f
        else:
            lst = eval(action)

        if pattern == "" or eval(pattern):
            print( " ".join([ str(e) for e in lst]) )
