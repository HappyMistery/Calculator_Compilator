#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define EPSILON 1e-4
const double M_PI = 3.141592653589793;
const double M_E = 2.718281828459045;

char* result_to_string(char* type, double res) {
    char tmp_str[50];
    char* final_str = (char*)malloc(50 * sizeof(char));
    sprintf(tmp_str, "%g", res);
    if(strcmp(type, "int") == 0) {
        strcpy(final_str, "[Integer] ");
    }
    else {
        strcpy(final_str, "[Float] ");
    }
    strcat(final_str, tmp_str);
    return final_str;
}


 
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
        const char* output;
    } arit_test[] = {
        {"7 + 3", result_to_string("int", 7 + 3)}, 
        {"10 - 4", result_to_string("int", 10 - 4)}, 
        {"3 * 4", result_to_string("int", 3 * 4)}, 
        {"5 % 2", result_to_string("int", 5 % 2)}, 
        {"2 ** 3", result_to_string("int", pow(2, 3))}, 
        {"(7 + 3) * 2 - 5", result_to_string("int", (7 + 3) * 2 - 5)}, 
        {"(10 - 4) / 2 + 8 * 3", result_to_string("float", (10 - 4) / 2 + 8 * 3)}, 
        {"3 * (4 + 2 ** 3)", result_to_string("int", 3 * (4 + pow(2, 3)))}, 
        {"5 % 2 + 3 * 2 - 4 / 2", result_to_string("float", 5 % 2 + 3 * 2 - 4 / 2)}, 
        {"7.5 + 2.5", result_to_string("float", 7.5 + 2.5)}, 
        {"10.2 - 4.1", result_to_string("float", 10.2 - 4.1)}, 
        {"3.0 * 4.0", result_to_string("float", 3.0 * 4.0)}, 
        {"2 / 4", result_to_string("float", (float)2 / 4)}, 
        {"9.0 / 3.0", result_to_string("float", 9.0 / 3.0)}, 
        {"8.5 % 3.0", result_to_string("float", fmod(8.5, 3.0))}, 
        {"2.5 ** 2.0", result_to_string("float", pow(2.5, 2.0))}, 
        {"3 ** 2.5", result_to_string("float", pow(3, 2.5))}, 
        {"(7 + 2.5) * 3 - 4 / 2 + 1.5", result_to_string("float", (7 + 2.5) * 3 - 4 / 2 + 1.5)}, 
        {"10 - (3.5 * 2) + 8**2 - 4 / 3.0", result_to_string("float", 10 - (3.5 * 2) + pow(8, 2) - 4 / 3.0)}, 
        {"(3 * 2.0 + 1.5**2) - 7 / 3", result_to_string("float", (3 * 2.0 + pow(1.5, 2)) - (float)7 / 3)}, 
        {"(fmod(5, 2.5) + 4.5) * 3 - 2 / 1.0", result_to_string("float", (fmod(5, 2.5) + 4.5) * 3 - 2 / 1.0)}, 
        {"sin(0)", result_to_string("float", sin(0))}, 
        {"cos(0)", result_to_string("float", cos(0))}, 
        {"tan(0)", result_to_string("float", tan(0))}, 
        {"sin(PI / 4)", result_to_string("float", sin(M_PI / 4))},
        {"cos(PI / 4)", result_to_string("float", cos(M_PI / 4))}, 
        {"tan(PI / 4)", result_to_string("float", tan(M_PI / 4))}, 
        {"cos(PI / 3)", result_to_string("float", cos(M_PI / 3))}, 
        {"tan(PI / 3)", result_to_string("float", tan(M_PI / 3))}, 
        {"30 + sin(30)", result_to_string("float", 30 + sin(30))}, 
        {"45 - cos(30)", result_to_string("float", 45 - cos(30))}, 
        {"60 * tan(30)", result_to_string("float", 60 * tan(30))}, 
        {"7.5 + sin(PI / 6)", result_to_string("float", 7.5 + sin(M_PI / 6))}, 
        {"10.5 - cos(PI / 4)", result_to_string("float", 10.5 - cos(M_PI / 4))}, 
        {"3.5 * tan(PI / 3)", result_to_string("float", 3.5 * tan(M_PI / 3))}, 
        {"(30 + sin(30)) * 2 - 4 / 2", result_to_string("float", (30 + sin(30)) * 2 - 4 / 2)}, 
        {"10 - (3 * cos(30)) + 5 - 3", result_to_string("float", 10 - (3 * cos(30)) + 5 - 3)}, 
        {"(7.5 + sin(PI / 4)) * 2 - 1.5", result_to_string("float", (7.5 + sin(M_PI / 4)) * 2 - 1.5)}, 
        {"10.2 - (3 * cos(PI / 4)) + 1.5", result_to_string("float", 10.2 - (3 * cos(M_PI / 4)) + 1.5)}, 
        {"PI", result_to_string("float", M_PI)}, 
        {"E", result_to_string("float", M_E)},
        {"PI * E", result_to_string("float", M_PI * M_E)}, 
        {"PI**4", result_to_string("float", pow(M_PI, 4))}, 
        {"E**2", result_to_string("float", pow(M_E, 2))}, 
        {"sin(PI)", result_to_string("float", sin(M_PI))}, 
        {"cos(E)", result_to_string("float", cos(M_E))},
        {"8 / PI", result_to_string("float", 8 / M_PI)}, 
        {"sin(PI / 2) + 1", result_to_string("float", sin(M_PI / 2) + 1)}, 
        {"(7 + E) * 3 - sin(PI)", result_to_string("float", (7 + M_E) * 3 - sin(M_PI))}, 
        {"10 - (3.5 * PI) + E**2 - 4 / 3.0", result_to_string("float", 10 - (3.5 * M_PI) + pow(M_E, 2) - 4 / 3.0)}
    };


    const struct {
        const char* input;
        const char* output;
    } string_test[] = {
        {"\"Hello, \" + \"World!\"", "[String] Hello, World!"},                      
        {"\"Good \" + \"Morning \" + \"Everyone\"", "[String] Good Morning Everyone"},
        {"\"The result is: \" + \"42\"", "[String] The result is: 42"},
        {"\"Pi is approximately: \" + \"3.14\"", "[String] Pi is approximately: 3.14"},          
        {"\"C\" + \"++\" + \" Programming\"", "[String] C++ Programming"},
        {"\"Concatenation of \" + \"this\" + \" and \" + \"that\"", "[String] Concatenation of this and that"},
        {"\"Hello \" + \"there, \" + \"how \" + \"are \" + \"you?\"", "[String] Hello there, how are you?"},
        {"\"String \" + \"operations \" + \"are \" + \"fun!\"", "[String] String operations are fun!"},
        {"\"The quick \" + \"brown \" + \"fox \" + \"jumps\"", "[String] The quick brown fox jumps"},
        {"\"Concatenating \" + \"strings \" + \"in C\"", "[String] Concatenating strings in C"},
    };

    const struct {
    const char* input;
    const char* output;
} boolean_test[] = {
    {"true", "[Boolean] true"},
    {"true and true", "[Boolean] true"},
    {"false or false", "[Boolean] false"},
    {"not false", "[Boolean] true"},
    {"PI > 4", "[Boolean] false"},
    {"1*0 == 0", "[Boolean] true"},
    {"5 % 2 + 3 * 2 - 4 / 2 >= 5", "[Boolean] true"},
    {"sin(PI / 2) + 1 < 2", "[Boolean] false"},
    {"1.5 <= 1.5002", "[Boolean] true"},
    {"true and not true or not true", "[Boolean] false"},
    {"cos(0) <> 1", "[Boolean] false"},
    {"(3 > 1.75) and true or false", "[Boolean] true"},
    {"(not (PI <> PI) or false) and (true and not(false and (4>=5)))", "[Boolean] true"},
};

    int total_results = sizeof(arit_test) / sizeof(arit_test[0]);

    int index;
    int passed = 0;
    printf("\n\n\n========================================| %d aritmetic operations tests to pass... |========================================\n\n", total_results);
    printf("\n%d aritmetic tests to pass...\n", total_results);
    for (index = 0; index < total_results; index++) {
        fgets(buffer, 511, file);

        /* Remove the newline character, if it exists */
        buffer[strcspn(buffer, "\n")] = '\0';

        /* Compare the result with the expected value (with a little tolerance) */
        if (strcmp(buffer, arit_test[index].output) > EPSILON) {
            printf("  %d\t[%d / %d]: %s -----> %s\n", index+1, passed, total_results, arit_test[index].input, buffer);
            printf("Result mismatch at line %d: expected %s, got %s\n\n", index + 1, arit_test[index].output, buffer);
        } else {
            passed++;
            printf("  %d\t[%d / %d]: %s -----> %s\n", index+1, passed, total_results, arit_test[index].input, buffer);
        }
    }

    total_results = sizeof(string_test) / sizeof(string_test[0]);

    passed = 0;
    printf("\n\n\n========================================| %d string concat tests to pass... |========================================\n\n", total_results);
    for (index = 0; index < total_results; index++) {
        fgets(buffer, 511, file);

        /* Remove the newline character, if it exists */
        buffer[strcspn(buffer, "\n")] = '\0';

        /* Compare the result with the expected string */
        if (strcmp(buffer, string_test[index].output)) {
            printf("  %d\t[%d / %d]: %s -----> \"%s\"\n", index+1, passed, total_results, string_test[index].input, buffer);
            printf("Result mismatch at line %d: expected \"%s\", got \"%s\"\n\n", index + 1, string_test[index].output, buffer);
        } else {
            passed++;
            printf("  %d\t[%d / %d]: %s -----> \"%s\"\n", index+1, passed, total_results, string_test[index].input, buffer);
        }
    }

    total_results = sizeof(boolean_test) / sizeof(boolean_test[0]);

    passed = 0;
    printf("\n\n\n========================================| %d boolean tests to pass... |========================================\n\n", total_results);
    for (index = 0; index < total_results; index++) {
        fgets(buffer, 511, file);

        /* Remove the newline character, if it exists */
        buffer[strcspn(buffer, "\n")] = '\0';

        /* Compare the result with the expected boolean result */
        if (strcmp(buffer, boolean_test[index].output)) {
            printf("  %d\t[%d / %d]: %s -----> \"%s\"\n", index+1, passed, total_results, boolean_test[index].input, buffer);
            printf("Result mismatch at line %d: expected \"%s\", got \"%s\"\n\n", index + 1, boolean_test[index].output, buffer);
        } else {
            passed++;
            printf("  %d\t[%d / %d]: %s -----> \"%s\"\n", index+1, passed, total_results, boolean_test[index].input, buffer);
        }
    }

    fclose(file);
    return EXIT_SUCCESS;
}
