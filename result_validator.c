#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* Function to compare results with expected values */ 
int validate_results(const char *output_file) {
    FILE *file = fopen(output_file, "r");
    char buffer[511];
    if (!file) {
        printf("Failed to open result file: %s\n", output_file);
        return EXIT_FAILURE;
    }

    /* Expected results for the operations */
    double expected_results[] = {
        /* Basic integer operations */
        7+3, 10-4, 3*4, 5%2, pow(2,3),
        /* Complex integer operations */
        (7+3)*2-5, (10-4)/2+8*3, 3*(4+pow(2,3)), 5%2 + 3*2 - 4/2,
        /* Basic float operations */
        7.5+2.5, 10.2-4.1, 3.0*4.0, 2.0/4.0, 9.0/3.0, fmod(8.5, 3.0), pow(2.5,2.0),
        /* Complex float operations */
        (7.5+2.5)/2.0 - 1.5*3, (10.2-4.1) * 2.0 + 1.0/2.0, 3.0*(4.0 + pow(2.5,2.0)), fmod(8.5,3.0) + 4.2 * 1.5 - 3.0/1.5,
        /* Basic mixed operations */
        7+2.5, 10-3.5, 3*2.0, 8/3, fmod(5,2.5), pow(3,2.5),
        /* Complex mixed operations */
        (7+2.5)*3 - 4/2 + 1.5, 10 - (3.5*2) + pow(8,2) - 4/3.0, (3*2.0 + pow(1.5,2)) - 7/3, (fmod(5,2.5) + 4.5) * 3 - 2/1.0      
    };

    const char *operations[] = {
        /* Basic integer operations */
        "7+3", "10-4", "3*4", "5%2", "2**3",
        /* Complex integer operations */
        "(7 + 3) * 2 - 5", "(10 - 4) / 2 + 8 * 3", "3 * (4 + 2**3)", "5 % 2 + 3 * 2 - 4 / 2",
        /* Basic float operations */
        "7.5+2.5", "10.2-4.1", "3.0*4.0", "2/4", "9.0/3.0", "8.5 % 3.0", "2.5**2.0",
        /* Complex float operations */
        "(7.5+2.5)/2.0 - 1.5*3", "(10.2-4.1) * 2.0 + 1.0/2.0", "3.0*(4.0 + 2.5**2.0)", "(8.5%3.0) + 4.2 * 1.5 - 3.0/1.5",
        /* Basic mixed operations */
        "7+2.5", "10-3.5", "3*2.0", "8/3", "5%2.5", "3**2.5",
        /* Complex mixed operations */
        "(7+2.5)*3 - 4/2 + 1.5", "10 - (3.5*2) + 8**2 - 4/3.0", "(3*2.0 + 1.5**2) - 7/3", "(5%2.5 + 4.5) * 3 - 2/1.0"  
    };

    int total_results = sizeof(expected_results) / sizeof(expected_results[0]);

    int index;
    int passed = 0;
    printf("%d tests to pass...\n", total_results);
    for (index = 0; index < total_results; index++) {
        fgets(buffer, 511, file);

        if (index >= total_results) {
            printf("More results in the file than expected\n");
            fclose(file);
            return EXIT_FAILURE;
        }

        /* Convert the line to a double */
        double result = atof(buffer);

        /* Compare the result with the expected value */
        if (result != expected_results[index]) {
            printf("%d [%d / %d]: %s --> %g\n", index+1, passed, total_results, operations[index], result);
            printf("Result mismatch at line %d: expected %g, got %g\n", index + 1, expected_results[index], result);
        } else {
            passed++;
            printf("%d [%d / %d]: %s --> %g\n", index+1, passed, total_results, operations[index], result);
        }
    }

    /* Check if there are fewer results than expected */
    if (index < total_results) {
        printf("Fewer results in the file than expected\n");
        fclose(file);
        return EXIT_FAILURE;
    }

    fclose(file);
    return EXIT_SUCCESS;
}
