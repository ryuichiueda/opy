#!/usr/bin/env python3
import sys, os, ast

VERSION = "0.6.1"
COPYRIGHT = "Ryuichi Ueda"
LICENSE = "MIT license"

f = []

def usage():
    print("py " + VERSION, file=sys.stderr)
    print("Copyright 2019 " + COPYRIGHT, file=sys.stderr)
    print("Released under " + LICENSE, file=sys.stderr)

class Sentence:
    def __init__(self, pattern, action, action_type):
        self.pattern = pattern
        self.action = action
        self.type = action_type

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
    for n in range(len(arg)-1):
        if arg[-n-1] != ":" and arg[-n-1] != ";":
            continue
        
        if arg[-n-1] == ":":
            try:
                ast.parse(arg[-n:])
                s, r = parse_pattern(arg[:-n-1])
                #return Sentence(arg[:-n-1], arg[-n:], "list"), ""
                return Sentence(s.pattern, arg[-n:], "list"), r
            except:
                pass
        else:
            try:
                ast.parse(arg[-n:])
                return Sentence("", arg[-n:], "list"), arg[:-n-1]
            except:
                pass

    try:
        ast.parse(arg)
        return Sentence("", arg, "list"), ""
    except:
        pass
    
    print("parse error", file=sys.stderr)
    sys.exit(1)

def parse_proc_type(arg):
    for n in range(len(arg)-1):
        if arg[-n-1] != ":" and arg[-n-1] != ";":
            continue

        if arg[-n:].lstrip(" ")[0] != "{":
            continue

        if arg[-n-1] == ":":
            try:
                action = arg[-n:].rstrip("} ").lstrip(" {")
                ast.parse(action)
                s, r = parse_pattern(arg[:-n-1])
                return Sentence(s.pattern, action, "proc"), r
            except:
                pass
        else:
            try:
                action = arg[-n:].rstrip("} ").lstrip(" {")
                ast.parse(action)
                return Sentence("", action, "proc"), arg[:-n-1]
            except:
                pass

    try:
        ast.parse(arg.lstrip("{ ").rstrip("} "))
        return Sentence("", arg, "proc"), ""
    except:
        pass

    print("parse error", file=sys.stderr)
    sys.exit(1)

def parse_pattern(arg):
    for n in range(len(arg)):
        if arg[-n-1] != ";":
            continue

        try:
            ast.parse(arg[-n:])
            return Sentence(arg[-n:], "", "list"), arg[:-n-1]
        except:
            pass

    return Sentence(arg, "", "list"), ""

def parse(sentences, arg):
    arg = arg.rstrip()

    if arg[-1] == "]":
        sentence, remain = parse_list_type(arg)
    elif arg[-1] == "}":
        sentence, remain = parse_proc_type(arg)
    else:
        sentence, remain = parse_pattern(arg)

    if remain == "":
        return [sentence] + sentences

    return parse([sentence] + sentences, remain)

def split_fields(line):
    line = line.rstrip('\n')
    return [line] + to_number( line.split(' ') )

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--help":
        usage()
        sys.exit(1)

    if len(sys.argv) > 2 and sys.argv[1] == "-m":
        exec(sys.argv[2])
        command_pos = 3
    else:
        command_pos = 1

    sentences = parse([], sys.argv[command_pos])

    begins = [ s for s in sentences if s.pattern in ["B", "BEGIN" ] ]
    normals = [ s for s in sentences if s.pattern not in ["B", "BEGIN", "E", "END" ] ]
    ends = [ s for s in sentences if s.pattern in ["E", "END" ] ]

    for s in begins:
        exec(s.action)

    if len(normals) == 0:
        for s in ends:
            exec(s.action)
        sys.exit(0)

    for line in sys.stdin:
        for s in normals:
            f = split_fields(line)
            for n, e in enumerate(f):
                exec("F" + str(n) + " = e ")
        
            if s.pattern == "" or eval(s.pattern):
                if s.type == "list":
                    lst = eval(s.action) if s.action else f[1:]
                    print( " ".join([ str(e) for e in lst]) )
                else:
                    exec(s.action)

    for s in ends:
        exec(s.action)
