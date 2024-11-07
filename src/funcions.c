#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dades.h"
#include "symtab.h"

extern int yyparse();
extern FILE *yyin;
extern FILE *yyout;
extern int yylineno;


int init_analisi_lexica(char *filename)
{
  int error;
  yyin = fopen(filename,"r");
  if(yyin == NULL) {
    error = EXIT_FAILURE;
  } else {
    error = EXIT_SUCCESS;
  }
  return error;
}


int end_analisi_lexica()
{
  int error;
  error = fclose(yyin);
  if (error == 0) {
    error = EXIT_SUCCESS;
  } else {
    error = EXIT_FAILURE;
  }
  return error;
}


int init_analisi_sintactica(char* filename)
{
  int error = EXIT_SUCCESS;
  yyout = fopen(filename,"w");
  if (yyout == NULL) {
    error = EXIT_FAILURE;
  }
  return error;
}


int end_analisi_sintactica(void)
{
  int error;

  error = fclose(yyout);

  if(error == 0) {
    error = EXIT_SUCCESS;
  } else {
    error = EXIT_FAILURE;
  }
  return error;
}


int analisi_semantica(void)
{
  int error;

  if (yyparse() == 0) {
    error =  EXIT_SUCCESS;
  } else {
    error =  EXIT_FAILURE;
  }
  return error;
}


void yyerror(char *explanation)
{
  fprintf(stderr, "Error: %s , in line %d\n", explanation, yylineno);
}

void cast_vals_to_flt(value_info *op1, value_info *op2) {
    if(op2 == NULL) {
        if (op1->val_type == INT_TYPE) 
            op1->fval = (float)op1->ival;
    }
    else {
        if (op1->val_type == INT_TYPE) 
            op1->fval = (float)op1->ival;
        if (op2->val_type == INT_TYPE) 
            op2->fval = (float)op2->ival;
    }
}

char* decToBin(int n) {
    char* binaryStr = (char*)malloc(33 * sizeof(char));
    if (!binaryStr) {
        printf("Memory allocation failed!\n");
        exit(1);
    }
    int i = 0;
    if (n == 0) {
        strcpy(binaryStr, "0");
        return binaryStr;
    }
    /* Temporary array to store the binary digits in reverse */
    char temp[32];
    while (n > 0) {
        /* Store remainder when n is divided by 2 */
        temp[i] = (n % 2) + '0'; /* Convert int (0 or 1) to char */
        n = n / 2;
        i++;
    }
    int j;
    /* Reverse the temp array to get the correct binary string */
    for (j = 0; j < i; j++) {
        binaryStr[j] = temp[i - j - 1];
    }
    binaryStr[i] = '\0';
    return binaryStr;
}

char* decToOct(int n) {
    char* octalStr = (char*)malloc(12 * sizeof(char));
    if (!octalStr) {
        printf("Memory allocation failed!\n");
        exit(1);
    }

    sprintf(octalStr, "%o", n);
    return octalStr;
}

char* decToHex(int n) {
    char* hexStr = (char*)malloc(9 * sizeof(char));
    if (!hexStr) {
        printf("Memory allocation failed!\n");
        exit(1);
    }

    sprintf(hexStr, "%X", n);
    return hexStr;
}

char* switch_bases(value_info *val, base base) {
    if(val->val_type == INT_TYPE) {
        char* result;
        switch (base) {
            case BIN_BASE:
                result = decToBin(val->ival);
                break;
            case OCT_BASE:
                result = decToOct(val->ival);
                break;
            case HEX_BASE:
                result = decToHex(val->ival);
                break;
            default:
                result = (char*)malloc(1 * sizeof(char));
                strcpy(result, "");
                printf("Invalid base!\n");
        }
        return result;
    }
    return "";
}

void buildTable(char *vars[], int var_index) {
    int max_name_length = strlen("Name");
    int max_type_length = strlen("Type");
    int max_value_length = strlen("Value");
    int i, j;
    id var;

    for (i = 0; i < var_index; i++) {
        sym_lookup(vars[i], &var);
        int name_length = strlen(var.name);
        int type_length = strlen(type_to_str(var.id_val.val_type));

        char value_buffer[512];
        switch (var.id_val.val_type) {
            case INT_TYPE:
                sprintf(value_buffer, "%d", var.id_val.ival);
                break;
            case FLOAT_TYPE:
                sprintf(value_buffer, "%.2f", var.id_val.fval);
                break;
            case STRING_TYPE:
                sprintf(value_buffer, "%s", var.id_val.sval);
                break;
            case BOOL_TYPE:
                sprintf(value_buffer, "%s", var.id_val.bval ? "true" : "false");
                break;
            default:
                sprintf(value_buffer, "N/A");
                break;
        }
        int value_length = strlen(value_buffer);

        if (name_length > max_name_length) {
            max_name_length = name_length;
        }
        if (type_length > max_type_length) {
            max_type_length = type_length;
        }
        if (value_length > max_value_length) {
            max_value_length = value_length;
        }
    }

    printf("┌");
    for (i = 0; i < max_name_length; i++) {
        printf("─");
    }
    printf("┬─");
    for (i = 0; i < max_type_length; i++) {
        printf("─");
    }
    printf("─┬");
    for (i = 0; i < max_value_length; i++) {
        printf("─");
    }
    printf("┐\n");

    printf("│Name");
    for (i = 0; i < max_name_length - strlen("Name"); i++) {
        printf(" ");
    }
    printf("│Type  ");
    for (i = 0; i < max_type_length - strlen("Type"); i++) {
        printf(" ");
    }
    printf("│Value");
    for (i = 0; i < max_value_length - strlen("Value"); i++) {
        printf(" ");
    }
    printf("│\n");

    printf("├");
    for (i = 0; i < max_name_length; i++) {
        printf("─");
    }
    printf("┼─");
    for (i = 0; i < max_type_length; i++) {
        printf("─");
    }
    printf("─┼");
    for (i = 0; i < max_value_length; i++) {
        printf("─");
    }
    printf("┤\n");

    for (i = 0; i < var_index; i++) {
        sym_lookup(vars[i], &var);

        char value_buffer[512];
        switch (var.id_val.val_type) {
            case INT_TYPE:
                sprintf(value_buffer, "%d", var.id_val.ival);
                break;
            case FLOAT_TYPE:
                sprintf(value_buffer, "%g", var.id_val.fval);
                break;
            case STRING_TYPE:
                sprintf(value_buffer, "%s", var.id_val.sval);
                break;
            case BOOL_TYPE:
                sprintf(value_buffer, "%s", var.id_val.bval ? "true" : "false");
                break;
            default:
                sprintf(value_buffer, "N/A");
                break;
        }

        printf("│");
        printf("%s", var.name);
        int padding = max_name_length - strlen(var.name);
        for (j = 0; j < padding; j++) {
            printf(" ");
        }

        printf("│ ");
        printf("%s", type_to_str(var.id_val.val_type));
        padding = max_type_length - strlen(type_to_str(var.id_val.val_type));
        for (j = 0; j < padding; j++) {
            printf(" ");
        }

        printf(" │");
        printf("%s", value_buffer);
        padding = max_value_length - strlen(value_buffer);
        for (j = 0; j < padding; j++) {
            printf(" ");
        }

        printf("│\n");

        if (i < var_index - 1) {
            printf("├");
            for (j = 0; j < max_name_length; j++) {
                printf("─");
            }
            printf("┼─");
            for (j = 0; j < max_type_length; j++) {
                printf("─");
            }
            printf("─┼");
            for (j = 0; j < max_value_length; j++) {
                printf("─");
            }
            printf("┤\n");
        }
    }

    printf("└");
    for (i = 0; i < max_name_length; i++) {
        printf("─");
    }
    printf("┴─");
    for (i = 0; i < max_type_length; i++) {
        printf("─");
    }
    printf("─┴");
    for (i = 0; i < max_value_length; i++) {
        printf("─");
    }
    printf("┘\n");
}
