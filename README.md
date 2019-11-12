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

### homebrew

```
$ brew tap ryuichiueda/oneliner-python
$ brew install oneliner-python
```

## options

See [EXAMPLES.md](./EXAMPLES.md)

* `-b`: buffer the standard output
* `-c`: read data as CSVs
* `-C`: output data with a CSV format
* `-s`: treat numbers from input data as strings
* `-i`: separators change input field separators
* `-I`: separators change input field separators with a regular expression
* `-m`: modules import modules
* `-o`: separators change output field separators
* `-v`: `<variable>=<string>` define a variable from a string on the shell
* `--help`: show help


