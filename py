#!/usr/bin/env python3
import sys, os, ast

__version__ = "0.7.2"
__author__ = "Ryuichi Ueda"
__license__ = "MIT license"
__url__ = "https://github.com/ryuichiueda/py"

def usage():
    print("py " + __version__, file=sys.stderr)
    print("Copyright 2019 " + __author__, file=sys.stderr)
    print("\nReleased under " + __license__, file=sys.stderr)
    print(__url__, file=sys.stderr)

class Rule:
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
                return Rule(s.pattern, arg[-n:], "list"), r
            except:
                pass
        else:
            try:
                ast.parse(arg[-n:])
                return Rule("", arg[-n:], "list"), arg[:-n-1]
            except:
                pass

    try:
        ast.parse(arg)
        return Rule("", arg, "list"), ""
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
                return Rule(s.pattern, action, "proc"), r
            except:
                pass
        else:
            try:
                action = arg[-n:].rstrip("} ").lstrip(" {")
                ast.parse(action)
                return Rule("", action, "proc"), arg[:-n-1]
            except:
                pass

    try:
        action = arg.lstrip("{ ").rstrip("} ")
        ast.parse(action)
        return Rule("", action, "proc"), ""
    except:
        pass

    print("parse error", file=sys.stderr)
    sys.exit(1)

def parse_pattern(arg):
    for n in range(len(arg)):
        if arg[-n-1] != ";":
            continue

        try:
            pat = arg[-n:].lstrip().rstrip()
            ast.parse(pat)
            return Rule(pat, "", "list"), arg[:-n-1]
        except:
            pass

    return Rule(arg, "", "list"), ""

def parse(rules, arg):
    arg = arg.rstrip()
    if arg == "":
        return rules

    if arg[-1] == "]":   rule, remain = parse_list_type(arg)
    elif arg[-1] == "}": rule, remain = parse_proc_type(arg)
    else:                rule, remain = parse_pattern(arg)

    if remain == "": return [rule] + rules
    else:            return parse([rule] + rules, remain)

def split_fields(line):
    line = line.rstrip('\n')
    return [line] + to_number( line.split(' ') )

def main_proc(header, begins, normals, ends):
    exec(header)
    for s in begins:
        if s.type == "list":
            print( " ".join([ str(e) for e in eval(s.action)]) )
        else:
            exec(s.action)

    if len(normals) == 0:
        for s in ends: exec(s.action)
        sys.exit(0)

    for n, line in enumerate(sys.stdin):
        f = split_fields(line)
        NF = len(f) - 1
        NR = n + 1

        for n, e in enumerate(f):
            exec("F" + str(n) + " = e ")
        
        for s in normals:
            if s.pattern == "" or eval(s.pattern):
                if s.type == "list":
                    lst = eval(s.action) if s.action else f[1:]
                    print( " ".join([ str(e) for e in lst]) )
                else:
                    exec(s.action)

    for s in ends:
        if s.type == "list":
            print( " ".join([ str(e) for e in eval(s.action)]) )
        else:
            exec(s.action)

def begin_end_separation(rules):
    begins = [ s for s in rules if s.pattern in ["B", "BEGIN" ] ]
    regulars = [ s for s in rules if s.pattern not in ["B", "BEGIN", "E", "END" ] ]
    ends = [ s for s in rules if s.pattern in ["E", "END" ] ]
    return begins, regulars, ends

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--help":
        usage()
        sys.exit(1)

    if len(sys.argv) > 2 and sys.argv[1] == "-m":
        header, code = sys.argv[2:4]
    else:
        header, code = "", sys.argv[1]

    rules = parse([], code)
    begins, regulars, ends = begin_end_separation(rules)
    main_proc(header, begins, regulars, ends)
