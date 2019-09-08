#!/usr/bin/env python3
import sys
import ast
import re

__version__ = "1.4.0"
__author__ = "Ryuichi Ueda"
__license__ = "MIT license"
__url__ = "https://github.com/ryuichiueda/py"


def usage():
    print("opy " + __version__, file=sys.stderr)
    print("Copyright 2019 " + __author__, file=sys.stderr)
    print("\nReleased under " + __license__, file=sys.stderr)
    print(__url__, file=sys.stderr)


class Rule:
    def __init__(self, pattern, action, do_exec=False):
        self.pattern = pattern
        self.action = action
        self.do_exec = do_exec


class Parser:
    def __init__(self, arg):
        rules = []
        while arg != "":
            rule, arg = self.__get_rule(arg)
            if rule != "":
                rules.insert(0, rule)

        self.begins = [r for r in rules if r.pattern in ["B", "BEGIN"] ]
        self.ends = [r for r in rules if r.pattern in ["E","END"] ]
        self.normals = [r for r in rules if r not in self.begins + self.ends ]


    def __get_rule(self, arg):
        arg = arg.strip()
        if arg == "":
            return "", ""
        elif arg[-1] == "]":
            return self.__list(arg)
        elif arg[-1] == "}":
            return self.__action(arg)
        else:
            return self.__pattern(arg)


    def __pattern(self, arg):
        for n in range(len(arg)):
            if arg[-n-1] != ";":
                continue
    
            pat = arg[-n:].strip()
            if self.__test(pat):
                return Rule(pat, ""), arg[:-n-1]
    
        return Rule(arg, ""), ""


    def __list(self, arg):
        for n in range(len(arg)-1):
            if arg[-n-1] not in ":;":
                continue
    
            proc = arg[-n:].lstrip()
            if not self.__test(proc):
                continue
    
            if arg[-n-1] != ":":
                return Rule("", proc), arg[:-n-1]
    
            try:
                s, r = self.__pattern(arg[:-n-1])
                return Rule(s.pattern, arg[-n:]), r
            except:
                continue
    
        if self.__test(arg):
            return Rule("", arg), ""
    
        print("parse error", file=sys.stderr)
        sys.exit(1)


    def __action(self, arg):
        for n in range(len(arg)-1):
            if arg[-n-1] not in ":;":
                continue
    
            if arg[-n:].lstrip(" ")[0] != "{":
                continue
    
            proc = arg[-n:].rstrip("} ").lstrip(" {")
            if not self.__test(proc):
                continue
    
            if arg[-n-1] != ":":
                return Rule("", proc, True), arg[:-n-1]
    
            try:
                s, r = self.__pattern(arg[:-n-1])
                return Rule(s.pattern, proc, True), r
            except:
                continue
    
        proc = arg.lstrip("{ ").rstrip("} ")
        if self.__test(proc):
            return Rule("", proc, True), ""
    
        print("parse error", file=sys.stderr)
        sys.exit(1)


    def __test(self, code):
        try:
            ast.parse(code)
            return True
        except:
            return False


#################################################
# data and functions for user
F = []
OFS = " "
IFS = " "
IFSREGEX = False

def r_(rgx, s=None):
    if s is None:
        s = F[0]

    return re.search(rgx, str(s))


def n_(s):
    try:
        return int(s)
    except ValueError:
        try:
            return float(s)
        except ValueError:
            return s


def Fs(b, e):
    return OFS.join( [str(f) for f in F[b:e+1] ])

#################################################


def to_numbers(lst):
    return [n_(e) for e in lst]


def split_fields(line, str_mode):
    line = line.rstrip('\n')
    fs = re.split(IFS, line) if IFSREGEX else line.split(IFS)

    if str_mode:
        return [line] + fs
    else:
        return [line] + to_numbers(fs)


def dynamic_module_import(msg):
    module = re.search(r'\'[^\']+\'', str(msg)).group().strip("'")
    try:
        exec("import " + module, globals())
    except NameError:
        print("Name error", file=sys.stderr)
        sys.exit(1)


def print_list(rule, f, glo, loc):
    try:
        lst = eval(rule.action, glo, loc) if rule.action else f[1:]
        print(OFS.join([str(e) for e in lst]))
    except NameError as e:
        dynamic_module_import(e)
        print_list(rule, f, glo, loc)


def main_proc(headers, begins, normals, ends, files, str_mode):
    global F
    NF = 0
    NR = 0
    FNR = 0

    for h in headers:
        exec("import " + h)

    for r in begins:
        if r.do_exec:
            exec(r.action)
        else:
            print_list(r, F, globals(), locals())

        sys.stdout.flush()

    if len(normals) == 0:
        for r in ends:
            if r.do_exec:
                exec(r.action)
            else:
                print_list(r, F, globals(), locals())
    
            sys.stdout.flush()

        sys.exit(0)

    for filename in files:
        if filename == "-":
            h_file = sys.stdin
        else:
            h_file = open(filename, "r")

        FILENAME = filename
        FNR = 0

        for line in h_file:
            F = split_fields(line, str_mode) 
            NF = len(F) - 1
            NR += 1
            FNR += 1

            for n, e in enumerate(F):
                exec("F" + str(n) + " = e ")

            for r in normals:
                if r.pattern != "" and not eval(r.pattern):
                    continue

                if r.do_exec:
                    exec(r.action)
                else:
                    print_list(r, F, globals(), locals())

                sys.stdout.flush()

        h_file.close()

    for r in ends:
        if r.do_exec:
            exec(r.action)
        else:
            print_list(r, F, globals(), locals())

        sys.stdout.flush()


def set_str_mode():
    if "-s" in sys.argv:
        sys.argv.remove("-s")
        return True
     
    return False


def get_header():
    if "-m" in sys.argv:
        pos = sys.argv.index("-m")
        modules = sys.argv[pos+1]
        sys.argv.remove("-m")
        sys.argv.remove(modules)
        return modules.split(",;")

    return ""


def get_ifs():
    ifs = " "
    regex = False

    if "-i" in sys.argv:
        pos = sys.argv.index("-i")
        ifs = sys.argv[pos+1]
        sys.argv.remove("-i")
        sys.argv.remove(ifs)
        regex = False
    elif "-I" in sys.argv:
        pos = sys.argv.index("-I")
        ifs = sys.argv[pos+1]
        sys.argv.remove("-I")
        sys.argv.remove(ifs)
        regex = True

    return ifs, regex


def get_ofs():
    ofs = " "
    if "-o" in sys.argv:
        pos = sys.argv.index("-o")
        ofs = sys.argv[pos+1]
        sys.argv.remove("-o")
        sys.argv.remove(ofs)

    return ofs


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "--help":
        usage()
        sys.exit(1)

    str_mode = set_str_mode()
    headers = get_header()
    IFS, IFSREGEX = get_ifs()
    OFS = get_ofs()
    files = sys.argv[2:] if len(sys.argv) > 2 else ["-"]
    p = Parser(sys.argv[1])
    main_proc(headers, p.begins, p.normals, p.ends, files, str_mode)
