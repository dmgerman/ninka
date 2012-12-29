VERSION = 4
NAME = comments
BETA = no

DIR = $(NAME)-v$(VERSION)

DEFINES = -DVERSION=\"$(VERSION)\" -DNAME=\"$(NAME)\" #-DBETA
DISTROFILES = Makefile README CHANGES main.cpp main.h io.cpp io.h dformat.cpp dformat.h func.cpp func.h $(NAME).1
OPTIONS = -O2 -Wall -Wno-deprecated

#DEBUG = -g -DDEBUG -DIODEBUG


all:
	g++ $(DEBUG) $(OPTIONS) $(DEFINES) -c io.cpp
	g++ $(DEBUG) $(OPTIONS) $(DEFINES) -c dformat.cpp
	g++ $(DEBUG) $(OPTIONS) $(DEFINES) -c func.cpp
	g++ $(DEBUG) $(OPTIONS) $(DEFINES) -c main.cpp
	g++ -o $(NAME) main.o io.o dformat.o func.o

install:
	@echo -n "Installing binary:   "
	@cp $(NAME) /usr/local/bin
	@chmod 755 /usr/local/bin/$(NAME)
	@echo "Done."
	@echo -n "Installing man page: "
	@cp $(NAME).1 /usr/local/man/man1
	@echo -e "Done.\n"
	@echo -n `$(NAME)`
	@echo -e "\nPlease read the README if you have not already done so."

distro:
	rm -rf $(DIR)*.tar.gz $(NAME) $(DIR)
	@if [ "$(BETA)" = "yes" ]; then \
		mkdir $(DIR)b; \
		cp $(DISTROFILES) $(DIR)b; \
		tar -cvzf $(DIR)b.tar.gz $(DIR)b; \
		rm -rf $(DIR)b; \
	else \
		mkdir $(DIR); \
		cp $(DISTROFILES) $(DIR); \
		tar -cvzf $(DIR).tar.gz $(DIR); \
		rm -rf $(DIR); \
	fi

clean:
	rm -f *.o comments

