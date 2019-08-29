# py: Python wrapper that works like AWK or rb command

## usage 

### pattern

```
$ seq 10 | py 'F1%2==0'
2
4
6
8
10
```

### action

```
$ echo 1 2 3 a b c | py '[ F2, F3*3, F5+"aaa"]'
2 9 baaa
```

### pattern and action

```
$ seq 10 | py 'F1%2==0[F1, ":even"]'
2 :even
4 :even
6 :even
8 :even
10 :even
```

### import of modules

````
$ seq 1 3 | py -m 'import math' '[ F1*math.pi, math.sin(F1) ]' 
3.141592653589793 0.8414709848078965
6.283185307179586 0.9092974268256817
9.42477796076938 0.1411200080598672
````
