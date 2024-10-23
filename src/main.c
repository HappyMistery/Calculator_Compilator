#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include "funcions.h"
#include "result_validator.h"

extern int yydebug;

int main(int argc, char *argv[])
{
    int error;

    yydebug = 1;
    if (argc == 3) {
        error = init_analisi_lexica(argv[1]);

        if (error == EXIT_SUCCESS) {
        error = init_analisi_sintactica(argv[2]);

        if (error == EXIT_SUCCESS) {
            error = analisi_semantica();

            if (error != EXIT_SUCCESS) {
                printf("ERROR");
            }

            error = end_analisi_sintactica();
            if (error == EXIT_FAILURE) {
            printf("The output file can not be closed\n");
            }

            error = end_analisi_lexica();
            if (error == EXIT_FAILURE) {
            printf("The input file can not be closed\n");
            }
        } else {
            printf("The output file %s can not be created\n",argv[2]);
        }
        } else {
        printf("The input file %s can not be opened\n",argv[1]);
        }
    } else {
        printf("\nUsage: %s INPUT_FILE OUTPUT_FILE\n",argv[0]);
    }
    error = validate_results(argv[1], argv[2]);
    return EXIT_SUCCESS;
}
