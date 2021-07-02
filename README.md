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

### the simplest way

You can install `opy` with 

```
$ chmod +x opy
$ sudo cp opy /usr/local/bin/     # Please check PATH.
```

since `opy` is an independent script file.

### make

The `opy` file and its manual are copied to `/usr/local/bin/` and `/usr/local/share/man/man1/` respectively with the following command.

```
$ sudo make install
```


### homebrew

The version remains old because I don't have a Mac PC anymore...

```
$ brew tap ryuichiueda/oneliner-python
$ brew install oneliner-python
```

## options

See [EXAMPLES.md](./EXAMPLES.md)

* `-b`: buffer the standard output
* `-c`: read each line as CSV data
* `-C`: output data with a CSV format
* `-s`: treat numbers from input data as strings
* `-i <separator>`: separators change input field separators
* `-I <separator>`: separators change input field separators with a regular expression
* `-m <module>`: modules import modules
* `-o <separator>`: separators change output field separators
* `-v <variable>=<string>`: define a variable from a string on the shell
* `-t <json/yaml/xml/csv>`: tree mode (read a json/yaml/xml/csv file entirely and set the data to an object "T".)
* `--help`: show help


