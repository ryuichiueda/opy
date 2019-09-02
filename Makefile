all:
	@echo "Please \"make install\" to install"

install:
	sudo cp ./opy /usr/local/bin/

uninstall:
	sudo rm /usr/local/bin/opy
