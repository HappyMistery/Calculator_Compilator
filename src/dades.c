#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "dades.h"

char* strdup(const char* s);

char *type_to_str(data_type val_type)
{
  if (val_type == UNKNOWN_TYPE) {
    return strdup("Unknown type");
  } else if (val_type == INT_TYPE) {
    return strdup("Integer");
  } else if (val_type == FLOAT_TYPE) {
    return strdup("Float");
  } else if (val_type == BOOL_TYPE) {
    return strdup("Boolean");
  } else if (val_type == STRING_TYPE) {
    return strdup("String");
  } else {
    return strdup("Error: incorrect value for 'val_type'");
  }
}