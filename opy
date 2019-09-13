#!/usr/bin/env python3
import sys
import ast
import re

__version__ = "1.5.2"
__author__ = "Ryuichi Ueda"
__license__ = "MIT license"
__url__ = "https://github.com/ryuichiueda/opy"


def usage():
    print("opy " + __version__ + "\n", file=sys.stderr)
    print("Copyright 2019 " + __author__, file=sys.stderr)
    print("Released under " + __license__, file=sys.stderr)
    print(__url__, file=sys.stderr)
    print("\nYou are using Python {}.{}.{} with this command.".format(*sys.version_info[0:3]),
          file=sys.stderr)


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
    
            action = arg[-n:].strip(" ")
            if action[0] != "{" or action[-1] != "}":
                continue

            proc = action[1:-1].strip(" ")
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


def to_numbers(lst):
    return [num(e) for e in lst]


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
        return modules

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


def num(s):
    try:
        return int(s)
    except ValueError:
        try:
            return float(s)
        except ValueError:
            return s


def Fs(b, e):
    return OFS.join( [str(f) for f in F[b:e+1] ])


def drop(s, pos):
    tmp = split_fields(s, True)

    if isinstance(pos, int):
        tmp.pop(pos)
    else:
        for e in reversed(pos):
            tmp.pop(e)

    return OFS.join([ str(e) for e in tmp[1:] ])


if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "--help":
        usage()
        sys.exit(1)

    __str_mode = set_str_mode()
    __modules = get_header()
    IFS, IFSREGEX = get_ifs()
    OFS = get_ofs()
    FILES = sys.argv[2:] if len(sys.argv) > 2 else ["-"]
    __p = Parser(sys.argv[1])

    ### main procedure (must be executed in the global scope) ###
    NF = 0
    NR = 0
    FNR = 0

    if __modules != "":
        exec("import " + __modules)

    for __r in __p.begins:
        if __r.do_exec:
            exec(__r.action)
        else:
            print_list(__r, F, globals(), locals())

        sys.stdout.flush()

    if len(__p.normals) == 0:
        for __r in __p.ends:
            if __r.do_exec:
                exec(__r.action)
            else:
                print_list(__r, F, globals(), locals())
    
            sys.stdout.flush()

        sys.exit(0)

    for FILENAME in FILES:
        __h_file = sys.stdin if FILENAME == "-" else open(FILENAME, "r")

        FNR = 0

        for line in __h_file:
            F = split_fields(line, __str_mode) 
            NF = len(F) - 1
            NR += 1
            FNR += 1

            for __n, __e in enumerate(F):
                globals()["F" + str(__n)] = __e

            for __r in __p.normals:
                if __r.pattern != "" and not eval(__r.pattern):
                    continue

                if __r.do_exec:
                    exec(__r.action)
                else:
                    print_list(__r, F, globals(), locals())

                sys.stdout.flush()

        __h_file.close()

    for __r in __p.ends:
        if __r.do_exec:
            exec(__r.action)
        else:
            print_list(__r, F, globals(), locals())

        sys.stdout.flush()
