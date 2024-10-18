#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "dades.h"

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
