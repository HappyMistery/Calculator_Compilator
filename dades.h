#ifndef EXEMPLE_DADES_H
#define EXEMPLE_DADES_H


#define STR_MAX_LENGTH 200

typedef enum {
  UNKNOWN_TYPE = 1,
  INT_TYPE,
  FLOAT_TYPE
} data_type;


typedef struct {
  data_type val_type;
  int val_int;
  float val_float;
} value_info;


char *type_to_str(data_type val_type);
char *value_info_to_str(value_info value);


#endif
