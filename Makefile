######################################################################
#
#                           Compiladors
#
######################################################################

CC = gcc
LEX = flex
YACC = bison
LIB = -lm -lc -lfl

SRC_LEX = lex_spec.l
SRC_YACC = bison_spec.y

LEX_OUT = lex.yy.c
YACC_OUT_C = bison_spec.tab.c
YACC_OUT_H = bison_spec.tab.h
YACC_OUT = $(YACC_OUT_C) $(YACC_OUT_H)

OBJ = *.o

SRC = main.c
BIN = calc_compiler.exe

SRC_EXTRA = dades.c funcions.c result_validator.c

LFLAGS = -n -o $*.c
YFLAGS = -d -v
CFLAGS = -ansi -Wall -g

EG_IN = test_file.txt
EG_OUT = output.txt


######################################################################

all: $(BIN)

$(BIN): $(OBJ)
	$(CC) -o $(BIN) $(CFLAGS) $(SRC) $(SRC_EXTRA) $(YACC_OUT_C) $(LEX_OUT) $(LIB)

$(OBJ): $(LEX_OUT) $(YACC_OUT)
	$(CC) $(CFLAGS) -c $(LEX_OUT)
	$(CC) $(CFLAGS) -c $(YACC_OUT_C)

$(LEX_OUT): $(SRC_LEX)
	$(LEX) $(LFLAGS) $(SRC_LEX)

$(YACC_OUT): $(SRC_YACC)
	$(YACC) $(YFLAGS) $(SRC_YACC)

clean:
	rm -f *~ $(BIN) $(OBJ) $(YACC_OUT) $(LEX_OUT) $(EG_OUT)

eg: $(EG_IN)
	./$(BIN) $(EG_IN) $(EG_OUT)
	cat $(EG_OUT)