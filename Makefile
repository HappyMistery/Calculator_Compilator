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
BISON = bison														 #
LIB = -lc -lfl  													 #
ELEX = lex_spec.l  												     #
PARSER = bison_spec.y												 #
OBJ = lex.yy.o bison_spec.tab.o  									 #
SRC_LEX = lex.yy.c  												 #
SRC_PARSER = bison_spec.tab.c										 #
BIN = calc_compiler  												 #
LFLAGS = -n -o $*.c  												 #
CFLAGS = -ansi -Wall -g  											 #
###################################################################### 

all: $(BIN)

$(BIN): $(OBJ)
	$(CC) -o $(BIN) $(OBJ) $(LIB)

$(OBJ): $(SRC_LEX) $(SRC_PARSER)
	$(CC) $(CFLAGS) -c $(SRC_LEX)
	$(CC) $(CFLAGS) -c $(SRC_PARSER)

$(SRC_LEX): $(ELEX)
	$(LEX) $(ELEX)

$(SRC_PARSER): $(PARSER)
	$(BISON) -d $(PARSER)

clean:
	rm -f $(BIN) $(OBJ) $(SRC_LEX) bison_spec.tab.* lex.yy.*