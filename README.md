# py: Python wrapper that works like AWK or rb command

## usage 

```
$ echo 1 2 3 a b c | ./py '[ F[2]*3, F[3]+"aaa"]'
9 aaaa
```
