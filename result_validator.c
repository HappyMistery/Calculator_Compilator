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
    const struct {
        const char* input;
        float  output;
    } arit_test[] = {
        {"7 + 3", 7 + 3}, 
        {"10 - 4", 10 - 4}, 
        {"3 * 4", 3 * 4}, 
        {"5 % 2", 5 % 2}, 
        {"2 ** 3", pow(2, 3)}, 
        {"(7 + 3) * 2 - 5", (7 + 3) * 2 - 5}, 
        {"(10 - 4) / 2 + 8 * 3", (10 - 4) / 2 + 8 * 3}, 
        {"3 * (4 + 2 ** 3)", 3 * (4 + pow(2, 3))}, 
        {"5 % 2 + 3 * 2 - 4 / 2", 5 % 2 + 3 * 2 - 4 / 2}, 
        {"7.5 + 2.5", 7.5 + 2.5}, 
        {"10.2 - 4.1", 10.2 - 4.1}, 
        {"3.0 * 4.0", 3.0 * 4.0}, 
        {"2 / 4", (float)2 / 4}, 
        {"9.0 / 3.0", 9.0 / 3.0}, 
        {"8.5 % 3.0", fmod(8.5, 3.0)}, 
        {"2.5 ** 2.0", pow(2.5, 2.0)}, 
        {"(7.5 + 2.5) / 2.0 - 1.5 * 3", (7.5 + 2.5) / 2.0 - 1.5 * 3}, 
        {"(10.2 - 4.1) * 2.0 + 1.0 / 2.0", (10.2 - 4.1) * 2.0 + 1.0 / 2.0}, 
        {"3.0 * (4.0 + 2.5 ** 2.0)", 3.0 * (4.0 + pow(2.5, 2.0))}, 
        {"(8.5 % 3.2) + 4.2 * 1.5 - 3.0 / 1.5", fmod(8.5, 3.2) + 4.2 * 1.5 - 3.0 / 1.5}, 
        {"sin(0)", sin(0)}, 
        {"cos(0)", cos(0)}, 
        {"tan(0)", tan(0)}, 
        {"sin(PI / 4)", sin(M_PI / 4)},
        {"cos(PI / 4)", cos(M_PI / 4)}, 
        {"tan(PI / 4)", tan(M_PI / 4)}, 
        {"sin(PI / 2)", sin(M_PI / 2)}, 
        {"cos(PI / 2)", cos(M_PI / 2)}, 
        {"sin(PI / 3)", sin(M_PI / 3)}, 
        {"cos(PI / 3)", cos(M_PI / 3)}, 
        {"tan(PI / 3)", tan(M_PI / 3)}, 
        {"7 + 2.5", 7 + 2.5}, 
        {"10 - 3.5", 10 - 3.5}, 
        {"3 * 2.0", 3 * 2.0}, 
        {"8 / 3", (float)8 / 3}, 
        {"5 % 2.5", fmod(5, 2.5)}, 
        {"3 ** 2.5", pow(3, 2.5)}, 
        {"30 + sin(30)", 30 + sin(30)}, 
        {"45 - cos(30)", 45 - cos(30)}, 
        {"60 * tan(30)", 60 * tan(30)}, 
        {"7.5 + sin(PI / 6)", 7.5 + sin(M_PI / 6)}, 
        {"10.5 - cos(PI / 4)", 10.5 - cos(M_PI / 4)}, 
        {"3.5 * tan(PI / 3)", 3.5 * tan(M_PI / 3)}, 
        {"(7 + 2.5) * 3 - 4 / 2 + 1.5", (7 + 2.5) * 3 - 4 / 2 + 1.5}, 
        {"10 - (3.5 * 2) + 8**2 - 4 / 3.0", 10 - (3.5 * 2) + pow(8, 2) - 4 / 3.0}, 
        {"(3 * 2.0 + 1.5**2) - 7 / 3", (3 * 2.0 + pow(1.5, 2)) - (float)7 / 3}, 
        {"(fmod(5, 2.5) + 4.5) * 3 - 2 / 1.0", (fmod(5, 2.5) + 4.5) * 3 - 2 / 1.0}, 
        {"(30 + sin(30)) * 2 - 4 / 2", (30 + sin(30)) * 2 - 4 / 2}, 
        {"10 - (3 * cos(30)) + 5 - 3", 10 - (3 * cos(30)) + 5 - 3}, 
        {"(7.5 + sin(PI / 4)) * 2 - 1.5", (7.5 + sin(M_PI / 4)) * 2 - 1.5}, 
        {"10.2 - (3 * cos(PI / 4)) + 1.5", 10.2 - (3 * cos(M_PI / 4)) + 1.5}, 
        {"PI", M_PI}, 
        {"E", M_E}, 
        {"PI + E", M_PI + M_E}, 
        {"PI * E", M_PI * M_E}, 
        {"PI**2", pow(M_PI, 2)}, 
        {"E**2", pow(M_E, 2)}, 
        {"sin(PI)", sin(M_PI)}, 
        {"cos(E)", cos(M_E)}, 
        {"7 + PI", 7 + M_PI}, 
        {"10.5 - E", 10.5 - M_E}, 
        {"8 / PI", 8 / M_PI}, 
        {"sin(PI / 2) + 1", sin(M_PI / 2) + 1}, 
        {"(7 + E) * 3 - sin(PI)", (7 + M_E) * 3 - sin(M_PI)}, 
        {"10 - (3.5 * PI) + E**2 - 4 / 3.0", 10 - (3.5 * M_PI) + pow(M_E, 2) - 4 / 3.0}
    };


    const char *expected_string_concat_results[] = {
        "Hello, World!",
        "Good Morning Everyone",           
        "The result is: 42",             
        "Pi is approximately: 3.14",     
        "C++ Programming",               
        "Concatenation of this and that",
        "Hello there, how are you?",
        "String operations are fun!",
        "The quick brown fox jumps",
        "Concatenating strings in C"
    };

    const char *string_concat_operations[] = {
        "\"Hello, \" + \"World!\"",                      
        "\"Good \" + \"Morning \" + \"Everyone\"",
        "\"The result is: \" + \"42\"",
        "\"Pi is approximately: \" + \"3.14\"",          
        "\"C\" + \"++\" + \" Programming\"",
        "\"Concatenation of \" + \"this\" + \" and \" + \"that\"",
        "\"Hello \" + \"there, \" + \"how \" + \"are \" + \"you?\"",
        "\"String \" + \"operations \" + \"are \" + \"fun!\"",
        "\"The quick \" + \"brown \" + \"fox \" + \"jumps\"",
        "\"Concatenating \" + \"strings \" + \"in C\""
    };

    int total_results = sizeof(arit_test) / sizeof(arit_test[0]);

    int index;
    int passed = 0;
    printf("\n\n\n========================================| %d aritmetic operations tests to pass... |========================================\n\n", total_results);
    printf("\n%d aritmetic tests to pass...\n", total_results);
    for (index = 0; index < total_results; index++) {
        fgets(buffer, 511, file);

        /* Convert the line to a double */
        double result = atof(buffer);

        /* Compare the result with the expected value (with a little tolerance) */
        if (fabs(result - arit_test[index].output) > EPSILON) {
            printf("%d [%d / %d]: %s -----> %g\n", index+1, passed, total_results, arit_test[index].input, result);
            printf("Result mismatch at line %d: expected %g, got %g\n\n", index + 1, arit_test[index].output, result);
        } else {
            passed++;
            printf("%d [%d / %d]: %s -----> %g\n", index+1, passed, total_results, arit_test[index].input, result);
        }
    }

    total_results = sizeof(expected_string_concat_results) / sizeof(expected_string_concat_results[0]);

    passed = 0;
    printf("\n\n\n========================================| %d string concat tests to pass... |========================================\n\n", total_results);
    for (index = 0; index < total_results; index++) {
        fgets(buffer, 511, file);

        /* Remove the newline character, if it exists */
        buffer[strcspn(buffer, "\n")] = '\0';

        /* Compare the result with the expected string */
        if (strcmp(buffer, expected_string_concat_results[index])) {
            printf("%d [%d / %d]: %s -----> \"%s\"\n", index+1, passed, total_results, string_concat_operations[index], buffer);
            printf("\nResult mismatch at line %d: expected \"%s\", got \"%s\"\n", index + 1, expected_string_concat_results[index], buffer);
        } else {
            passed++;
            printf("%d [%d / %d]: %s -----> \"%s\"\n", index+1, passed, total_results, string_concat_operations[index], buffer);
        }
    }

    fclose(file);
    return EXIT_SUCCESS;
}
