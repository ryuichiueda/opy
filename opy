#!/usr/bin/env python3
import sys
import ast
import re
import codecs

__version__ = "1.7.0"
__author__ = "Ryuichi Ueda"
__license__ = "MIT license"
__url__ = "https://github.com/ryuichiueda/opy"


def usage():
    print("opy " + __version__ + "\n", file=sys.stderr)
    print("Copyright 2019 " + __author__, file=sys.stderr)
    print("Released under " + __license__, file=sys.stderr)
    print(__url__, file=sys.stderr)
    print("\nYou are using Python {}.{}.{} with this command."
          .format(*sys.version_info[0:3]),
          file=sys.stderr)


class Rule:
    '''
    Opy recognizes and executes a set of rules. The
    instance of this class contains information of a
    rule. 
    A rule is composed of either or both of a pattern
    and an action. In patterns and actions, sentences
    or expressions of Python are written. 
    An action is either a normal action or a list
    action. 
    '''
    def __init__(self, pattern, action, has_normal=False):
        self.pattern = pattern
        self.action = action
        self.has_normal_action = has_normal


class Parser:
    '''
    When a code is given, the instance of this class
    parses the code immediately. Then it sorts rules
    by patterns. 
    When the pattern of a rule is B/BEGIN or E/END, 
    the rule is categorized to "begins" or "ends"
    respectively. Otherwise it is appended to "lines."
    '''
    def __init__(self, code):
        rules = []
        while True:
            rule, code = self.__get_rule(code)
            if not rule:
                break

            # The parser gives each rule in the inverse order.
            rules.insert(0, rule) 

        self.begins = [r for r in rules if r.pattern in ["B", "BEGIN"] ]
        self.ends = [r for r in rules if r.pattern in ["E","END"] ]
        self.lines = [r for r in rules if r not in self.begins + self.ends ]


    def __get_rule(self, code) -> (Rule, str):
        '''
        This method judges the type of the rightmost
        rule by the rightmost character. It uses one 
        of three scanners based on the judgement.
        The scanner returns the rightmost rule and
        the residual code and this method returns them.
        '''

        code = code.strip()

        if code == "":
            return None, ""
        elif code[-1] == "]": # The rule has an list action.
            return self.__list(code)
        elif code[-1] == "}": # It has an normal action.
            return self.__action(code)
        else:                 # It has no action. 
            return self.__pattern(code)


    def __pattern(self, code) -> (Rule, str):
        '''
        This method searches ";" from right. 
        When ";" finds, the right part is tested
        whether it is a Python code or not. 
        '''
        n = len(code)
        while n != -1:
            n = code.rfind(";", 0, n)
            pattern = code[n+1:].strip()
            if self.__test(pattern):
                return Rule(pattern, ""), code[:n if n>0 else 0]
    
        print("pattern parse error", file=sys.stderr)
        sys.exit(1)


    def __list(self, code) -> (Rule, str):
        '''
        This method searches a list action from the right.
        If the rule to which the list action belongs has
        a pattern, the pattern is also searched and added
        to the rule. The rule and the left residual string
        are returned.
        '''
        n = len(code)
        while n != -1:
            n = max([ code.rfind(c, 0, n) for c in ";:" ] )
            proc = code[n+1:].lstrip()
            if not self.__test(proc):
                continue
            elif n == -1 or code[n] == ";":
                return Rule("", proc), code[:n if n>0 else 0]
            elif code[n] == ":":
                s, r = self.__pattern(code[:n])
                return Rule(s.pattern, code[n+1:]), r
    
        print("list action parse error", file=sys.stderr)
        sys.exit(1)


    def __action(self, code) -> (Rule, str):
        '''
        This method searches a normal action from the right.
        Its procedure is almost the same with that of __list.
        '''
        n = len(code)
        while n != -1:
            n = max([ code.rfind(c, 0, n) for c in ";:" ] )
            action = code[n+1:].strip()
            if action[0] != "{" or action[-1] != "}":
                continue

            proc = action[1:-1].strip()
            if not self.__test(proc):
                continue
            elif n == -1 or code[n] != ":":
                return Rule("", proc, True), code[:n if n>0 else 0]
            elif code[n] == ":":
                s, r = self.__pattern(code[:n])
                return Rule(s.pattern, proc, True), r

        print("normal action parse error", file=sys.stderr)
        sys.exit(1)


    def __test(self, code) -> bool:
        '''
        This method tests whether the code is
        appropriate as a sentence or an expression
        of Python.
        '''
        try:
            ast.parse(code)
            return True
        except:
            return False


def __split_fields(line, str_mode):
    '''
    This function splits a line into a list by using the characters
    in IFS (input field separator), and return the list. If the
    -s option is not given, this function tries to convert each element
    into an int or float value. At the return of the list, 
    the line before split is added to the list as the zeroth element.
    '''
    line = line.rstrip('\n')
    fs = re.split(IFS, line) if IFSREGEX else line.split(IFS)
    return [line] + (fs if str_mode else [num(e) for e in fs])


def __dynamic_module_import(msg):
    '''
    This function tries to import a package with the name extracted
    from a given NameError message. 
    '''
    module = re.search(r'\'[^\']+\'', str(msg)).group().strip("'")
    try:
        exec("import " + module, globals())
    except NameError:
        print("Name error", file=sys.stderr)
        sys.exit(1)


def __print_list(rule, f, glo, loc):
    '''
    This function outputs the list with the delimiter given in OFS.
    At a name error, it calls __dynamic_module_import so as to import
    a module with the name. If successful, it retries the output again.
    '''
    try:
        lst = eval(rule.action, glo, loc) if rule.action else f[1:]
        print(OFS.join([str(e) for e in lst]))
    except NameError as e:
        __dynamic_module_import(e)
        __print_list(rule, f, glo, loc)


'''
The following __set... functions search options. 
When an option is found. They set or return appropriate
data for reflecting the option. They also removes
the option and its associated arguments. 
'''

def __set_str_mode():
    if "-s" in sys.argv:
        sys.argv.remove("-s")
        return True
     
    return False


def __get_header():
    if "-m" in sys.argv:
        pos = sys.argv.index("-m")
        modules = sys.argv[pos+1]
        sys.argv.remove("-m")
        sys.argv.remove(modules)
        return modules

    return ""


def __get_ifs():
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


def __get_ofs():
    ofs = " "
    if "-o" in sys.argv:
        pos = sys.argv.index("-o")
        ofs = sys.argv[pos+1]
        sys.argv.remove("-o")
        sys.argv.remove(ofs)

    return ofs


'''
Following variables and functions before
the main part are for users. 
'''

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


def join(fs, b, e):
    return OFS.join( [str(f) for f in fs[b:e+1] ])


def dropjoin(fs, pos):
    pos = [pos] if isinstance(pos, int) else pos
    outindex = list( set(range(1, NF+1)).difference(pos) )
    outlist = fs if isinstance(fs, list) else __split_fields(fs, True)
    return OFS.join([ str(outlist[e]) for e in outindex ])


'''
The following are the main part. To assure the consistency
of scopes of variables, I didn't divide processes into
functions. However, please tell me it if you have an idea.  
'''

if __name__ == "__main__":
    if len(sys.argv) < 2 or sys.argv[1] == "--help":
        usage()
        sys.exit(1)

    '''
    The following lines extract information from options.
    Some names of variables have prefix "__" so as not to
    collide with the names that users define. 
    The names with upper case latters are predefined variables
    for users. 
    '''
    __str_mode = __set_str_mode()
    __modules = __get_header()
    IFS, IFSREGEX = __get_ifs()
    OFS = __get_ofs()
    FILES = sys.argv[2:] if len(sys.argv) > 2 else ["-"]

    '''
    The following line parses the code. If the code is composed
    of only begin/end patterns, the standard input is removed 
    from the file list. Otherwise, the procedure stops when data
    is not given from it.
    '''
    __p = Parser(sys.argv[1])
    if __p.lines == []:
        FILES.remove("-")

    # Here the main process starts. 
    NF = 0
    NR = 0
    FNR = 0

    # The modules after -m option are imported here. 
    if __modules != "":
        exec("import " + __modules)

    # This loop executes begin rules one by one.
    for __r in __p.begins:
        '''
        This if-sentence appears repeatedly. However, it cannot be grouped
        into a function due to scope problems.
        '''
        if __r.has_normal_action:
            exec(__r.action)
        else:
            __print_list(__r, F, globals(), locals())

        sys.stdout.flush()

    for FILENAME in FILES:
        __h_file = sys.stdin if FILENAME == "-" else open(FILENAME, "r")
        FNR = 0 # raw number in each file

        for __line in __h_file:
            F = __split_fields(__line, __str_mode) 

            NF = len(F) - 1
            NR += 1
            FNR += 1

            '''
            Each element in F is copied to Fn (F0, F1, ...) variable.
            Binded elements to Fn variables are not references but
            duplications. Though it may rise to the confusion, now it
            is not dealt with. 
            '''
            for __n, __e in enumerate(F):
                globals()["F" + str(__n)] = __e

            for __r in __p.lines:
                if __r.pattern != "" and not eval(__r.pattern):
                    continue

                if __r.has_normal_action:
                    exec(__r.action)
                else:
                    __print_list(__r, F, globals(), locals())

                sys.stdout.flush()

        __h_file.close()

    # This loop executes end rules one by one.
    for __r in __p.ends:
        if __r.has_normal_action:
            exec(__r.action)
        else:
            __print_list(__r, F, globals(), locals())

        sys.stdout.flush()
