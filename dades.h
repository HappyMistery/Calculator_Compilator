#ifndef EXEMPLE_DADES_H
#define EXEMPLE_DADES_H


#define STR_MAX_LENGTH 200

typedef enum {
  UNKNOWN_TYPE = 1,
  INT_TYPE,
  FLOAT_TYPE,
  BOOL_TYPE,
  STRING_TYPE
} data_type;

typedef enum {
  NO_BASE = 1,
  BIN_BASE,
  OCT_BASE,
  DEC_BASE,
  HEX_BASE
} base;


typedef struct {
  data_type val_type;
  int ival;
  float fval;
  char* sval;
  int bval;
} value_info;

typedef struct {
    char *name;
    int length;
    int line;
    value_info id_val;
    base base;
} id;


char *type_to_str(data_type val_type);


#endif
