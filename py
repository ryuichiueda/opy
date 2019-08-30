#!/usr/bin/env python3
import sys, os, ast

VERSION = "0.3.1"
COPYRIGHT = "Ryuichi Ueda"
LICENSE = "MIT license"

f = []

def usage():
    print("py " + VERSION, file=sys.stderr)
    print("Copyright 2019 " + COPYRIGHT, file=sys.stderr)
    print("Released under " + LICENSE, file=sys.stderr)

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

def parse_list_type(arg):
    for n in range(len(arg)):
        if arg[-n-1] != "[":
            continue

        try:
            ast.parse(arg[-n-1:])
            return arg[:-n-1], arg[-n-1:], "list"
        except:
            pass
    
    print("parse error", file=sys.stderr)
    sys.exit(1)

def parse_proc_type(arg):
    for n in range(len(arg[:-1])):
        if arg[-n] != "{":
            continue
        try:
            ast.parse(arg[-n+1:-1])
            return arg[:-n], arg[-n+1:-1], "proc"
        except:
            pass
    
    print("parse error", file=sys.stderr)
    sys.exit(1)

def parse(arg):
    if arg[-1] == "]":
        return parse_list_type(arg)
    elif arg[-1] == "}":
        return parse_proc_type(arg)
    else:
        return arg, "", "list"

def split_fields(line):
    line = line.rstrip('\n')
    return [line] + to_number( line.split(' ') )

def exec_line(pattern, action, action_type, line):
    f = split_fields(line)
    for n, e in enumerate(f):
        exec("F" + str(n) + " = e ")

    if pattern == "" or eval(pattern):
        if action_type == "list":
            lst = eval(action) if action else f[1:]
            print( " ".join([ str(e) for e in lst]) )
        else:
            exec(action)

def exec_lines(pattern, action, action_type):
    for line in sys.stdin:
        exec_line(pattern, action, action_type, line)

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--help":
        usage()
        sys.exit(1)

    if len(sys.argv) > 2 and sys.argv[1] == "-m":
        exec(sys.argv[2])
        command_pos = 3
    else:
        command_pos = 1

    pattern, action, action_type = parse(sys.argv[command_pos])
    exec_lines(pattern, action, action_type)
