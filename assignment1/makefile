GROUP = group
LAB = 1

#Output executable name
BIN = c-

#Use the C compiler
CC = gcc

#Base code file name for the class
BASE = parser

#Code files seperated by space
FILES := scanType
CFILES := $(FILES:=.c)
OFILES := $(FILES:=.o)
HFILES := $(FILES:=.h)

#Declare our source files to compile
SRCS := $(BASE).y $(BASE).l $(CFILES) $(HFILES)

#Declare object files to link
OBJS := lex.yy.o $(BASE).tab.o $(OFILES)



#Uncomment for gcc debugging
#CFLAGS = -g

#Declare compiler libraries to use
LIBS = -lfl

#Bison flags
BFLAGS = -v -t -d

#Uncomment for flex debugging
#FFLAGS = -d



#Declare nonfile target names
.PHONY: clean all tar

#Indicate starting point so we can type just "make" to run all
.DEFAULT_GOAL := all



#To create executable, ensure OBJECT & SOURCE files exist first, then run command
$(BIN): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) -o $(BIN)

#To create bison files, ensure parser files exist
$(BASE).tab.h $(BASE).tab.c: $(BASE).y
	bison $(BFLAGS) $(BASE).y

#To create flex file, ensure flex and bison header exist first
lex.yy.c: $(BASE).l $(BASE).tab.h
	flex $(FFLAGS) $(BASE).l



#Keyword to type after make to make everything
all: clean $(BIN)

#Keyword to type after make to clean non-source code files
clean:
	rm -f $(OBJS) $(BIN) lex.yy.c $(BASE).tab.* $(BASE).output output *~

#Keyword to type after make to create tarball of source code
tar:
	tar -cvf $(GROUP)_PA$(LAB)_.tar $(SRCS) makefile README

