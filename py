#!/usr/bin/env python3
import sys, os, ast, re

__version__ = "0.8.3"
__author__ = "Ryuichi Ueda"
__license__ = "MIT license"
__url__ = "https://github.com/ryuichiueda/py"

def usage():
    print("py " + __version__, file=sys.stderr)
    print("Copyright 2019 " + __author__, file=sys.stderr)
    print("\nReleased under " + __license__, file=sys.stderr)
    print(__url__, file=sys.stderr)

class Rule:
    def __init__(self, pattern, action, do_exec=False):
        self.pattern = pattern
        self.action = action
        self.do_exec = do_exec

def to_number(s):
    try:
        return int(s)
    except:
        try:    return float(s)
        except: return s


def to_numbers(lst):
    return [ to_number(e) for e in lst ]

def parse_list_type(arg):
    for n in range(len(arg)-1):
        if arg[-n-1] not in ":;":
            continue
        
        action = arg[-n:].lstrip()
        if not test_parse(action):
            continue

        if arg[-n-1] != ":":
            return Rule("", action), arg[:-n-1]

        try:
            s, r = parse_pattern(arg[:-n-1])
            return Rule(s.pattern, arg[-n:]), r
        except:
            continue

    if test_parse(arg):
        return Rule("", arg), ""
    
    print("parse error", file=sys.stderr)
    sys.exit(1)

def test_parse(code):
    try:
        ast.parse(code)
        return True
    except:
        return False

def parse_proc_type(arg):
    for n in range(len(arg)-1):
        if arg[-n-1] not in ":;":
            continue

        if arg[-n:].lstrip(" ")[0] != "{":
            continue

        action = arg[-n:].rstrip("} ").lstrip(" {")
        if not test_parse(action):
            continue

        if arg[-n-1] != ":":
            return Rule("", action, True), arg[:-n-1]

        try:
            s, r = parse_pattern(arg[:-n-1])
            return Rule(s.pattern, action, True), r
        except:
            continue

    action = arg.lstrip("{ ").rstrip("} ")
    if test_parse(action): 
        return Rule("", action, True), ""

    print("parse error", file=sys.stderr)
    sys.exit(1)

def parse_pattern(arg):
    for n in range(len(arg)):
        if arg[-n-1] != ";":
            continue

        pat = arg[-n:].lstrip().rstrip()
        if test_parse(pat): return Rule(pat, ""), arg[:-n-1]
        else:               pass

    return Rule(arg, ""), ""

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
    return [line] + to_numbers( line.split(' ') )

def print_list(rule, f, glo, loc):
    try:
        lst = eval(rule.action, glo, loc) if rule.action else f[1:]
        print( " ".join([ str(e) for e in lst]) )
    except NameError as e: #dynamic module load
        module = re.search(r'\'[^\']+\'', str(e)).group().strip("'")
        try:
            exec("import " + module, globals())
        except:
            print("Name error", file=sys.stderr)
            sys.exit(1)
           
        print_list(rule, f, glo, loc)


def main_proc(header, begins, normals, ends):
    f = []
    NF = 0
    NR = 0

    exec(header)

    for r in begins:
        if r.do_exec: exec(r.action)
        else:         print_list(r, f, globals(), locals())

    if len(normals) == 0:
        for r in ends: exec(r.action)
        sys.exit(0)

    for line in sys.stdin:
        f = split_fields(line)
        NF = len(f) - 1
        NR += 1

        for n, e in enumerate(f):
            exec("F" + str(n) + " = e ")
        
        for r in normals:
            if r.pattern != "" and not eval(r.pattern):
                continue

            if r.do_exec: exec(r.action)
            else:         print_list(r, f, globals(), locals())

    for r in ends:
        if r.do_exec: exec(r.action)
        else:         print_list(r, f, globals(), locals())

def begin_end_separation(rules):
    begins = [ r for r in rules if r.pattern in ["B", "BEGIN" ] ]
    normals = [ r for r in rules if r.pattern not in ["B", "BEGIN", "E", "END" ] ]
    ends = [ r for r in rules if r.pattern in ["E", "END" ] ]
    return begins, normals, ends

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--help":
        usage()
        sys.exit(1)

    if len(sys.argv) > 2 and sys.argv[1] == "-m":
        header, code = sys.argv[2:4]
    else:
        header, code = "", sys.argv[1]

    rules = parse([], code)
    begins, normals, ends = begin_end_separation(rules)
    main_proc(header, begins, normals, ends)
