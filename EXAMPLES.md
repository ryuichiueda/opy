# examples

## usage 

### pattern/action/list action

* pattern

```
$ seq 10 | opy 'F1%2==0'
2
4
6
8
10
```

* action

```
$ seq 10 | opy '{print(F1,end="")}' 
12345678910
```

* list action

```
$ echo 1 2 3 a b c | opy '[ F2, F3*3, F5+"aaa"]'
2 9 baaa
```

* pattern and action

```
$ seq 10 | opy 'F1%2==0:{F1= str(F1)+" " ; print(F1,end="")}' 
2 4 6 8 10 
```

* pattern and list action

```
$ seq 10 | opy 'F1%2==0:[F1, ": even"]'
2 : even
4 : even
6 : even
8 : even
10 : even
```

* muitliple rules:

```
$ seq 4 | opy 'F1%2==0:[F1, ":even"];F1%2==1:[F1, ": odd"]'
1 : odd
2 : even
3 : odd
4 : even
```

* BEGIN and END patterns

```
$ seq 10 | opy 'B:{a=0};{a+=F1};E:[a]'
55
```

or 

```
$ seq 10 | opy 'BEGIN:{a=0};{a+=F1};END:[a]'
55
```

* list at begin

```
$ opy 'B:[1+1]'
2
```

### dynamic load of modules 

```
$ seq 1 3 | opy '[ F1*math.pi, math.sin(F1) ]' 
3.141592653589793 0.8414709848078965
6.283185307179586 0.9092974268256817
9.42477796076938 0.1411200080598672
```

* note: It works only in list actions. Each element must not be changed in the list.

### list comprehension

```
$ seq 1 100 | xargs -n 10 | opy '[ 1.0/x for x in F[1:3] ]'
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

### original function

* regular expression match (wrapper of re.search)

```
$ seq 10 | opy 'r_("[24680]")'
2
4
6
8
10
```
or

```
$ seq 10 | opy 'r_("[24680]", F1)'
2
4
6
8
10
```

* field selection

```
$ echo {1..10} | opy '[join(F,[2,3,4,6,7,8])]'
2 3 4 6 7 8
```

* field drop

```
$ echo {1..10} | opy '[dropjoin(F0,[2,3,5])]'
1 4 6 7 8 9 10
```

### input from file

```
$ opy 'NR==1' $(which opy)
#!/usr/bin/env python3
```

### default dictionary/list

```
echo 'a 3
b 4
a 5 
b 2.3' | opy '{D[F1]+=F2};E:{for k in D: print(k, D[k])}'
a 8
b 6.3
```

```
$ seq 10 | opy 'NR%2:{L.append(F1)};E:[L]'
[1, 3, 5, 7, 9]
```

## use of scipy

* integrate

```
opy 'B:{from scipy import integrate};B:{def f(x): return 2*x};B:[integrate.quad(f,0,5)]'
(25.0, 2.7755575615628914e-13)
```

## options


* `-c`: read data as CSVs

```
$ echo 'a,"b,","c"""' | opy -c '[F1,F2,F3]'
a b, c"
```

* `-C`: output data with a CSV format

```
$ echo '1 2 3' | opy -C True
"1","2","3"
$ echo '1 "2,3" 3 "' | opy -C True
"1","""2,3""","3",""""
```

* `-s`: treat numbers from input data as strings



* `-i`: separators change input field separators

```
$ echo 100 JPY | opy '[F1+F2]'
(error!!)
$ echo 100 JPY | opy -s '[F1+F2]'
100JPY
```

* `-I`: separators change input field separators with a regular expression


```
$ echo a,b@c | opy -I '[,@]' '[F1,F2,F3]'
a b c
```

* `-m`: modules import modules

```
$ opy -m numpy 'E:{print(numpy.pi)}'
3.141592653589793
$ opy -m math,numpy 'B:[math.e,numpy.e]'
2.718281828459045 2.718281828459045
```


* `-o`: separators change output field separators


```
$ echo a,b@c | opy -I '[,@]' -o '=' '[F1,F2,F3]'
a=b=c
```

* `-v`: `<variable>=<string>` define a variable from a string on the shell



```
$ a=abc
$ opy -v "b=$a" 'B:[b*2]'
abcabc
```

