BIN ?= laravel_checker
PREFIX ?= /usr/local

install:
	cp laravel_checker.sh $(PREFIX)/bin/$(BIN)
	chmod +x $(PREFIX)/bin/$(BIN)

uninstall:
	rm -f $(PREFIX)/bin/$(BIN)
