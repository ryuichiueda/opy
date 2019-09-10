all:
	@echo "Please \"make install\" to install"

install:
	sudo cp ./opy /usr/local/bin/
	sudo cp ./opy.1 /usr/local/share/man/man1/opy.1
	sudo /usr/libexec/makewhatis || sudo mandb

uninstall:
	sudo rm /usr/local/bin/opy
	sudo rm /usr/local/share/man/man1/opy.1
