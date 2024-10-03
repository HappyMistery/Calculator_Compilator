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
LIB =-lc-lfl  														 #
ELEX = lex_spec.l  												     #
OBJ = lex_spec.o  													 #
SRC = lex_spec.c  													 #
BIN = lex_spec  													 #
LFLAGS =-n-o $*.c  													 #
CFLAGS =-ansi-Wall-g  												 #
###################################################################### 

all : $(SRC) $(CC)-o $(BIN) $(CFLAGS) $< $(LIB) 

$(SRC) : $(ELEX) $(LEX) $(LFLAGS) $< 

clean : rm-f $(BIN) $(OBJ) $(SRC)