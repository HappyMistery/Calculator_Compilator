######################################################################
#
#                           Compiladors
#
######################################################################

CC = gcc
LEX = flex
YACC = bison
LIB = -lm -lc -lfl

# Paths
SRC_DIR = src
INCLUDE_DIR = include
GRAMMAR_DIR = grammar
BUILD_DIR = build
BIN_DIR = bin
DOCS_DIR = docs

# Lex and Bison files
SRC_LEX = $(GRAMMAR_DIR)/lex_spec.l
SRC_YACC = $(GRAMMAR_DIR)/bison_spec.y

LEX_OUT = $(BUILD_DIR)/lex.yy.c
LEX_H = $(BUILD_DIR)/lex.yy.h
YACC_OUT_C = $(BUILD_DIR)/bison_spec.tab.c
YACC_OUT_H = $(BUILD_DIR)/bison_spec.tab.h
YACC_OUT = $(YACC_OUT_C) $(YACC_OUT_H)
YACC_OUTPUT = $(BUILD_DIR)/bison_spec.output

OBJ = $(BUILD_DIR)/*.o

SRC = $(SRC_DIR)/main.c
SRC_INTERACTIVE = $(SRC_DIR)/main_interactive.c
BIN = $(BIN_DIR)/calc_compiler
BIN_INTERACTIVE = $(BIN_DIR)/calc_compiler_interactive

SRC_EXTRA = $(SRC_DIR)/dades.c $(SRC_DIR)/funcions.c $(SRC_DIR)/result_validator.c $(SRC_DIR)/symtab.c

LFLAGS = -n -o $*.c
YFLAGS = -d -v
CFLAGS = -ansi -Wall -g -Iinclude -Ibuild

EG_IN = test_file.txt
EG_OUT = output.txt

######################################################################

all: $(BIN) $(BIN_INTERACTIVE)

$(BIN): $(OBJ)
	$(CC) -o $(BIN) $(CFLAGS) $(SRC) $(SRC_EXTRA) $(YACC_OUT_C) $(LEX_OUT) $(LIB)

$(BIN_INTERACTIVE): $(OBJ)
	$(CC) -o $(BIN_INTERACTIVE) $(CFLAGS) $(SRC_INTERACTIVE) $(SRC_EXTRA) $(YACC_OUT_C) $(LEX_OUT) $(LIB)

$(OBJ): $(LEX_OUT) $(YACC_OUT)
	$(CC) $(CFLAGS) -c $(LEX_OUT) -o $(BUILD_DIR)/lex.yy.o
	$(CC) $(CFLAGS) -c $(YACC_OUT_C) -o $(BUILD_DIR)/bison_spec.tab.o
	$(CC) $(CFLAGS) -c $(SRC_DIR)/symtab.c -o $(BUILD_DIR)/symtab.o

$(LEX_OUT): $(SRC_LEX)
	$(LEX) $(LFLAGS) $(SRC_LEX)
	mv lex.yy.h $(BUILD_DIR)/lex.yy.h

$(LEX_H): $(SRC_LEX)
	$(LEX) -o $(LEX_OUT) $(SRC_LEX) -h

$(YACC_OUT): $(SRC_YACC)
	$(YACC) $(YFLAGS) $(SRC_YACC)
	mv bison_spec.tab.c $(YACC_OUT_C)
	mv bison_spec.tab.h $(YACC_OUT_H)
	mv bison_spec.output $(YACC_OUTPUT)

clean:
	rm -f *~ $(BIN) $(BIN_INTERACTIVE) $(OBJ) $(YACC_OUT) $(YACC_OUTPUT) $(LEX_OUT) $(EG_OUT) $(LEX_H) $(BUILD_DIR)/*.o

eg: $(EG_IN)
	./$(BIN) $(EG_IN) $(EG_OUT)
	cat $(EG_OUT)
