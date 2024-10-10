#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define EPSILON 1e-4
const double M_PI = 3.141592653589793;
const double M_E = 2.718281828459045;
 
int validate_results(const char *output_file) {
    FILE *file = fopen(output_file, "r");
    char buffer[511];
    if (!file) {
        printf("Failed to open result file: %s\n", output_file);
        return EXIT_FAILURE;
    }

    /* Expected results for the operations */
    double expected_arit_results[] = {
        /* Basic integer operations */
        7 + 3, 10 - 4, 3 * 4, 5 % 2, pow(2, 3),
        /* Complex integer operations */
        (7 + 3) * 2 - 5, (10 - 4) / 2 + 8 * 3, 3 * (4 + pow(2, 3)), 5 % 2 + 3 * 2 - 4 / 2,
        /* Basic float operations */
        7.5 + 2.5, 10.2 - 4.1, 3.0 * 4.0, 2.0 / 4.0, 9.0 / 3.0, fmod(8.5, 3.0), pow(2.5, 2.0),
        /* Complex float operations */
        (7.5 + 2.5) / 2.0 - 1.5 * 3, (10.2 - 4.1) * 2.0 + 1.0 / 2.0, 3.0 * (4.0 + pow(2.5, 2.0)), fmod(8.5, 3.2) + 4.2 * 1.5 - 3.0 / 1.5,
        /* Basic trigonometry operations */
        sin(0), cos(0), tan(0), sin(M_PI / 4), cos(M_PI / 4), tan(M_PI / 4),
        /* Complex trigonometry operations */
        sin(M_PI / 2), cos(M_PI / 2), tan(M_PI / 2), sin(M_PI / 3), cos(M_PI / 3), tan(M_PI / 3),
        /* Basic mixed operations */
        (float)7 + 2.5, 10 - 3.5, 3 * 2.0, (float)8 / (float)3, fmod(5, 2.5), pow(3, 2.5),
        30 + sin(30), 45 - cos(30), 60 * tan(30),
        7.5 + sin(M_PI / 6), 10.5 - cos(M_PI / 4), 3.5 * tan(M_PI / 3),
        /* Complex mixed operations */
        (7 + 2.5) * 3 - 4 / 2 + 1.5, 10 - (3.5 * 2) + pow(8, 2) - 4 / 3.0, (3 * 2.0 + pow(1.5, 2)) - 7 / 3, (fmod(5, 2.5) + 4.5) * 3 - 2 / 1.0,
        (30 + sin(30)) * 2 - 4 / 2, 10 - (3 * cos(30)) + 5 - 3,
        (7.5 + sin(M_PI / 4)) * 2 - 1.5, 10.2 - (3 * cos(M_PI / 4)) + 1.5,
        /* Basic constant operations */
        M_PI, M_E, M_PI + M_E, M_PI * M_E,
        /* Complex constant operations */
        pow(M_PI, 2), pow(M_E, 2), sin(M_PI), cos(M_E),
        /* Basic mixed constant operations */
        7 + M_PI, 10.5 - M_E, (float)8 / (float)M_PI, sin(M_PI / 2) + 1,
        /* Complex mixed constant operations */
        (7 + M_E) * 3 - sin(M_PI), 10 - (3.5 * M_PI) + pow(M_E, 2) - 4 / 3.0
    };

    const char *arit_operations[] = {
        "7 + 3", "10 - 4", "3 * 4", "5 % 2", "2 ** 3",
        "(7 + 3) * 2 - 5", "(10 - 4) / 2 + 8 * 3", "3 * (4 + 2 ** 3)", "5 % 2 + 3 * 2 - 4 / 2", 
        "7.5 + 2.5", "10.2 - 4.1", "3.0 * 4.0", "2 / 4", "9.0 / 3.0", "8.5 % 3.0", "2.5 ** 2.0",
        "(7.5 + 2.5) / 2.0 - 1.5 * 3", "(10.2 - 4.1) * 2.0 + 1.0 / 2.0", "3.0 * (4.0 + 2.5 ** 2.0)", 
        "(8.5 % 3.2) + 4.2 * 1.5 - 3.0 / 1.5", "sin(0)", "cos(0)", "tan(0)", "sin(PI / 4)", 
        "cos(PI / 4)", "tan(PI / 4)", "sin(PI / 2)", "cos(PI / 2)", "tan(PI / 2)", "sin(PI / 3)", 
        "cos(PI / 3)", "tan(PI / 3)", "7 + 2.5", "10 - 3.5", "3 * 2.0", "8 / 3", "5 % 2.5", 
        "3 ** 2.5", "30 + sin(30)", "45 - cos(30)", "60 * tan(30)", "7.5 + sin(PI / 6)", 
        "10.5 - cos(PI / 4)", "3.5 * tan(PI / 3)", "(7 + 2.5) * 3 - 4 / 2 + 1.5", 
        "10 - (3.5 * 2) + pow(8, 2) - 4 / 3.0", "(3 * 2.0 + pow(1.5, 2)) - 7 / 3", 
        "(fmod(5, 2.5) + 4.5) * 3 - 2 / 1.0", "(30 + sin(30)) * 2 - 4 / 2", 
        "10 - (3 * cos(30)) + 5 - 3", "(7.5 + sin(PI / 4)) * 2 - 1.5", 
        "10.2 - (3 * cos(PI / 4)) + 1.5", "PI", "E", "PI + E", "PI * E", 
        "pow(PI, 2)", "pow(E, 2)", "sin(PI)", "cos(E)", "7 + PI", "10.5 - E", 
        "8 / PI", "sin(PI / 2) + 1", "(7 + E) * 3 - sin(PI)", 
        "10 - (3.5 * PI) + pow(E, 2) - 4 / 3.0"  
    };

    int total_results = sizeof(expected_arit_results) / sizeof(expected_arit_results[0]);

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

        /* Compare the result with the expected value (with a little tolerance) */
        if (fabs(result - expected_arit_results[index]) > EPSILON) {
            printf("%d [%d / %d]: %s --> %g\n", index+1, passed, total_results, arit_operations[index], result);
            printf("Result mismatch at line %d: expected %g, got %g\n", index + 1, expected_arit_results[index], result);
        } else {
            passed++;
            printf("%d [%d / %d]: %s --> %g\n", index+1, passed, total_results, arit_operations[index], result);
        }
    }

    if (index < total_results) {
        printf("Fewer results in the file than expected\n");
        fclose(file);
        return EXIT_FAILURE;
    }

    fclose(file);
    return EXIT_SUCCESS;
}
