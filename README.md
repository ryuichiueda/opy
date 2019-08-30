# py: Python wrapper that works like AWK or rb command

[![Build Status](https://travis-ci.org/ryuichiueda/py.svg?branch=master)](https://travis-ci.org/ryuichiueda/py)

## usage 

### basic grammer

* pattern

```
$ seq 10 | py 'F1%2==0'
2
4
6
8
10
```

* list mode

```
$ echo 1 2 3 a b c | py '[ F2, F3*3, F5+"aaa"]'
2 9 baaa
```

* pattern and list mode

```
$ seq 10 | py 'F1%2==0:[F1, ":even"]'
2 :even
4 :even
6 :even
8 :even
10 :even
```

* action

```
$ seq 10 | ./py '{print(F1,end="")}' 
12345678910
```

* pattern and action

```
$ seq 10 | ./py 'F1%2==0:{F1= str(F1)+" " ; print(F1,end="")}' 
2 4 6 8 10 
```

* muitliple sentences:

```
$ seq 4 | ./py 'F1%2==0:[F1, ":even"];F1%2==1:[F1, ":odd"]'
1 :odd
2 :even
3 :odd
4 :even
```


* list comprehension

```
$ seq 1 100 | xargs -n 10 | ./py '[ 1.0/x for x in f[1:3] ]'
1.0 0.5
0.09090909090909091 0.08333333333333333
0.047619047619047616 0.045454545454545456
0.03225806451612903 0.03125
0.024390243902439025 0.023809523809523808
0.0196078431372549 0.019230769230769232
0.01639344262295082 0.016129032258064516
0.014084507042253521 0.013888888888888888
0.012345679012345678 0.012195121951219513
0.01098901098901099 0.010869565217391304
```

### import of modules

````
$ seq 1 3 | py -m 'import math' '[ F1*math.pi, math.sin(F1) ]' 
3.141592653589793 0.8414709848078965
6.283185307179586 0.9092974268256817
9.42477796076938 0.1411200080598672
````


