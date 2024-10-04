###################################################################### 
#                        Calculator Compilator                       #
#                                                                    # 
#                          Jaume Tello Viñas                         #
#                              Makefile                              #
#                             Pràctica 1                             #
######################################################################
#                          GENERAL DEFINES	 						 #
CC = gcc 															 #
LEX = flex 															 #
LIB = -lc -lfl  													 #
ELEX = lex_spec.l  												     #
OBJ = lex.yy.o  													 #
SRC = lex.yy.c  													 #
BIN = lex_spec  													 #
LFLAGS = -n -o $*.c  												 #
CFLAGS = -ansi -Wall -g  											 #
###################################################################### 

all: $(BIN)

$(BIN): $(OBJ)
	$(CC) -o $(BIN) $(OBJ) $(LIB)

$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $(SRC)

$(SRC): $(ELEX)
	$(LEX) $(ELEX)

clean:
	rm -f $(BIN) $(OBJ) $(SRC)