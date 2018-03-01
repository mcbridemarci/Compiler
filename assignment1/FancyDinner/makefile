BIN = dinner
CC = gcc
CFLAGS = -g

SRCS = $(BIN).y $(BIN).l
OBJS = lex.yy.o $(BIN).tab.o
LIBS = -lfl

$(BIN) : $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) $(LIBS) -o $(BIN)

$(BIN).tab.h $(BIN).tab.c : $(BIN).y
	bison -v -t -d $(BIN).y

lex.yy.c : $(BIN).l $(BIN).tab.h
	flex $(BIN).l

all:
	touch $(SRCS)
	make

clean:
	rm -f $(OBJS) $(BIN) lex.yy.c $(BIN).tab.h $(BIN).tab.c $(BIN).output

tar:
	tar -cvf $(BIN).tar $(SRCS) makefile menu.dinner

