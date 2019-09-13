# opy: onelinerers' Python

 a Python wrapper that works like AWK or rb command

[![Build Status](https://travis-ci.org/ryuichiueda/opy.svg?branch=master)](https://travis-ci.org/ryuichiueda/opy)

## example of use

```
$ seq 3 | opy '[math.sin(F1)]'
0.8414709848078965
0.9092974268256817
0.1411200080598672
```

* See [EXAMPLES.md](./EXAMPLES.md)

## install

### make

The `opy` file and its manual are copied to `/usr/local/bin/` and `/usr/local/share/man/man1/` respectively with the following command.

```
$ sudo make install
```

### snap 

```
$ sudo snap install opy
```

For installing the man page, please make a symbolic link as follows.

```
$ sudo ln -s /snap/opy/current/opy.1 /usr/share/man/man1/
```

* [snapcraft store](https://snapcraft.io/opy)

### homebrew

```
$ brew tap ryuichiueda/oneliner-python
$ brew install oneliner-python
```

## options

* `--help`: show help
* `-m <modules>`: load modules
* `-s`: string mode
    * prohibit automatic number conversions.
* `-i, -o`: input/output field separator

```
$ echo '1,2,3,4,5' | opy -i , '[F2]'
2
$ echo '1,2,3,4,5' | opy -i , -o x '[Fs(2,4)]'
2x3x4
```

* `-I`: regex input field separator

```
$ echo a33b313c | tr ' ' , | opy -I '\d+' '[Fs(1,3)]'
a b c
```
