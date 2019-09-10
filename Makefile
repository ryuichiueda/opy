all:
	@echo "Please \"make install\" to install"

install:
	cp ./opy /usr/local/bin/
	cp ./opy.1 /usr/local/share/man/man1/opy.1
	/usr/libexec/makewhatis || mandb

uninstall:
	rm /usr/local/bin/opy
	rm /usr/local/share/man/man1/opy.1
