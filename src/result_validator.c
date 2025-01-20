#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define EPSILON 1e-4
const double M_PI = 3.141592653589793;
const double M_E = 2.718281828459045;
const int BUFFER_LENGTH = 512;

int total_results;
int passed;
int index;

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


 
int validate_results(const char *input_file, const char *output_file) {
    FILE *file = fopen(output_file, "r");
    FILE *err_file = fopen("logs/error_log.txt", "r");
    char buffer[BUFFER_LENGTH];
    if (!file) {
        printf("Failed to open result file: %s\n", output_file);
        return EXIT_FAILURE;
    }
    if (!err_file) {
        printf("Failed to open error log file: error_log.txt\n");
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
        {"15 b8", "[Integer] 17"},
        {"123 b16", "[Integer] 7B"},
        {"7 b2", "[Integer] 111"},
        {"(7 + 3) * 2 - 5", result_to_string("int", (7 + 3) * 2 - 5)}, 
        {"(10 - 4) / 2 + 8 * 3", result_to_string("float", (10 - 4) / 2 + 8 * 3)}, 
        {"3 * (4 + 2 ** 3)", result_to_string("int", 3 * (4 + pow(2, 3)))}, 
        {"5 % 2 + 3 * 2 - LEN(\"hola\") / 2", result_to_string("float", 5 % 2 + 3 * 2 - strlen("hola") / 2)}, 
        {"7.5 + 2.5", result_to_string("float", 7.5 + 2.5)}, 
        {"10.2 - 4.1", result_to_string("float", 10.2 - 4.1)}, 
        {"3.0 * 4.0", result_to_string("float", 3.0 * 4.0)}, 
        {"2 / 4", result_to_string("float", (float)2 / 4)}, 
        {"9.0 / 3.0", result_to_string("float", 9.0 / 3.0)}, 
        {"8.5 % 3.0", result_to_string("float", fmod(8.5, 3.0))}, 
        {"2.5 ** 2.0", result_to_string("float", pow(2.5, 2.0))}, 
        {"3 ** 2.5", result_to_string("float", pow(3, 2.5))}, 
        {"(7 + 2.5) * 3 - 4 / 2 + 1.5", result_to_string("float", (7 + 2.5) * 3 - 4 / 2 + 1.5)}, 
        {"10 - (3.5 * 2) + LEN(\"perfecto\")**2 - 4 / 3.0", result_to_string("float", 10 - (3.5 * 2) + pow(strlen("perfecto"), 2) - 4 / 3.0)}, 
        {"(3 * 2.0 + 1.5**2) - 7 / 3", result_to_string("float", (3 * 2.0 + pow(1.5, 2)) - (float)7 / 3)}, 
        {"(fmod(5, 2.5) + 4.5) * 3 - 2 / 1.0", result_to_string("float", (fmod(5, 2.5) + 4.5) * 3 - 2 / 1.0)}, 
        {"sin(0)", result_to_string("float", sin(0))}, 
        {"COS(0)", result_to_string("float", cos(0))}, 
        {"tan(0)", result_to_string("float", tan(0))}, 
        {"SIN(PI / 4)", result_to_string("float", sin(M_PI / 4))},
        {"cos(PI / 4)", result_to_string("float", cos(M_PI / 4))}, 
        {"tan(PI / 4)", result_to_string("float", tan(M_PI / 4))}, 
        {"cos(PI / 3)", result_to_string("float", cos(M_PI / 3))}, 
        {"TAN(PI / 3)", result_to_string("float", tan(M_PI / 3))}, 
        {"LEN(\"Las estrellas brillan de noche\") + sin(30)", result_to_string("float", strlen("Las estrellas brillan de noche") + sin(30))}, 
        {"C2I \"45\" - cos(30)", result_to_string("float", 45 - cos(30))}, 
        {"60 * tan(30)", result_to_string("float", 60 * tan(30))}, 
        {"7.5 + sin(PI / 6)", result_to_string("float", 7.5 + sin(M_PI / 6))}, 
        {"10.5 - cos(PI / 4)", result_to_string("float", 10.5 - cos(M_PI / 4))}, 
        {"3.5 * tan(PI / 3)", result_to_string("float", 3.5 * tan(M_PI / 3))}, 
        {"(30 + sin(30)) * 2 - 4 / 2", result_to_string("float", (30 + sin(30)) * 2 - 4 / 2)}, 
        {"10 - (3 * cos(30)) + 5 - 3", result_to_string("float", 10 - (3 * cos(30)) + 5 - 3)}, 
        {"(7.5 + sin(PI / 4)) * 2 - 1.5", result_to_string("float", (7.5 + sin(M_PI / 4)) * 2 - 1.5)}, 
        {"10.2 - (3 * cos(PI / len(\"duck\"))) + 1.5", result_to_string("float", 10.2 - (3 * cos(M_PI / strlen("duck"))) + 1.5)}, 
        {"PI", result_to_string("float", M_PI)}, 
        {"E", result_to_string("float", M_E)},
        {"PI * E", result_to_string("float", M_PI * M_E)}, 
        {"PI**4", result_to_string("float", pow(M_PI, 4))}, 
        {"E**2", result_to_string("float", pow(M_E, 2))}, 
        {"sin(PI)", result_to_string("float", sin(M_PI))}, 
        {"cos(E)", result_to_string("float", cos(M_E))},
        {"LEN(\"paraguas\") / PI", result_to_string("float", strlen("paraguas") / M_PI)}, 
        {"sin(PI / 2) + 1", result_to_string("float", sin(M_PI / 2) + 1)}, 
        {"(7 + E) * 3 - sin(PI)", result_to_string("float", (7 + M_E) * 3 - sin(M_PI))}, 
        {"10 - (3.5 * PI) + E**2 - LEN(\"Piernas al fallo\") / 3.0", result_to_string("float", 10 - (3.5 * M_PI) + pow(M_E, 2) - strlen("Piernas al fallo") / 3.0)}
    };

    const struct {
        const char* input;
        const char* output;
    } boolean_test[] = {
        {"true", "[Boolean] true"},
        {"true and true", "[Boolean] true"},
        {"false OR false", "[Boolean] false"},
        {"not false", "[Boolean] true"},
        {"PI > 4", "[Boolean] false"},
        {"(1*0) == 0", "[Boolean] true"},
        {"(5 % 2 + 3 * 2 - 4 / 2) >= 5", "[Boolean] true"},
        {"(sin(PI / 2) + 1) < 2", "[Boolean] false"},
        {"1.5 <= 1.5002", "[Boolean] true"},
        {"true and NOT true or not true", "[Boolean] false"},
        {"(cos(0)) <> 1", "[Boolean] false"},
        {"(3 > 1.75) AND true or false", "[Boolean] true"},
        {"(not (PI <> PI) OR false) and (true and NOT(false and (4>=5)))", "[Boolean] true"},
        {"\"hola\" == \"hola\"", "[Boolean] true"},
        {"true <> (I2B 0)", "[Boolean] true"},
    };

    const struct {
        const char* input;
        const char* output;
    } string_test[] = {
        {"\"Hello, \" + \"World!\"", "[String] Hello, World!"},                      
        {"\"Good \" + \"Morning \" + \"Everyone\"", "[String] Good Morning Everyone"},
        {"\"The result is: \" + \"42\"", "[String] The result is: 42"},
        {"SUBSTR(\"Hello professor\" 6 10)", "[String] professor"},
        {"\"A boolean can be\" + \" either \" + true + \" or \" + false\"", "[String] A boolean can be either true or false"},
        {"\"Pi is approximately: \" + \"3.14\"", "[String] Pi is approximately: 3.14"},       
        {"\"C\" + \"++\" + \" Programming\"", "[String] C++ Programming"},
        {"\"Concatenation of \" + \"this\" + \" and \" + \"that\"", "[String] Concatenation of this and that"},
        {"\"Hello \" + \"there, \" + \"how \" + \"are \" + \"you?\"", "[String] Hello there, how are you?"},
        {"\"String \" + \"operations \" + \"are \" + \"fun!\"", "[String] String operations are fun!"},
        {"substr((\"xd\" + 123) 2 3)", "[String] 123"},
        {"\"To say that 1 == 1 is \" + true and (1==1)", "[String] To say that 1 == 1 is true"},
        {"\"The quick \" + \"brown \" + \"fox \" + \"jumps\"", "[String] The quick brown fox jumps"},
        {"\"Concatenating \" + \"strings \" + \"in C\"", "[String] Concatenating strings in C"},
        {"\"hola\" + SUBSTR(\"hola pepe\" 5 4)", "[String] holapepe"},
        {"LEN(\"NO COnfLIcts\") + \" finally\"", "[String] 12 finally"},
        {"SUBSTR(\"hola pepe\" LEN(\"hola \") len(\"pepe\"))", "[String] pepe"}
    };

    const struct {
        const char* input;
        const char* output;
    } var_test[] = {
        { "a := 3.7", "[Float] a = 3.7"},
        { "b := 10", "[Integer] b = 10"},
        { "c := a * 4 + b / 2 - 1", "[Float] c = 18.8"},
        { "d := \"My\"", "[String] d = My"},
        { "e := \"Girlfriend\"", "[String] e = Girlfriend"},
        { "f := c > 5 and b <= 10 OR not a < 2.5", "[Boolean] f = true"},
        { "arr[12] := 18", "[Integer] arr[12] = 18"},
        { "arr[2] := d+e", "[String] arr[2] = MyGirlfriend"},
        { "arr[0] := PI * 45", "[Float] arr[0] = 141.372"},
        { "arr[b] := b ** E", "[Float] arr[10] = 522.735"},
        { "arr[1] := f", "[Boolean] arr[1] = true"},
        { "arr[arr[12] - b] := not true", "[Boolean] arr[8] = false"},
        { "c + b - a", "[Float] 25.1"},
        { "a * b / c", "[Float] 1.96809"},
        { "d + " " + e + \" is cool\"", "[String] My Girlfriend is cool"},
        { "SUBSTR(d 2 2) + substr(e 1 1)", "[String] i"},
        { "c + (a * 2) / b - a", "[Float] 15.84"},
        { "f or not (b > 8 AND a < 4)", "[Boolean] true"},
        { "d + b + \"--\" + SUBSTR(e 1 2)", "[String] My10--ir"},
        { "substr((d + e) 1 3) + \"--\" + a", "[String] yGi--3.7"},
        { "a + b * (c - 2) / a", "[Float] 49.1054"},
        { "a > b or arr[1] and NOT (c < 10)", "[Boolean] true"},
        { "f and b > c or not (a == 3.7)", "[Boolean] false"},
        { "d + \" - \" + e + \": \" + c + a + arr[4*2]", "[String] My - Girlfriend: 18.83.7false"},
        { "SUBSTR((d + e) 1 4) + (c - b)", "[String] yGir8.8"},
    };

    const struct {
        const char* input;
        const char* output;
    } error_test[] = {
        {"-\"hello\"", " Unary Minus Operator (-) cannot be applied to type 'String'. Only type 'Integer' and 'Float'"},
        {"+true",  " Unary Plus Operator (+) cannot be applied to type 'Boolean'. Only type 'Integer' and 'Float'"},
        {"5 + false", " Addition (+) operator cannot be applied to type 'Boolean'"},
        {"\"hello\" - 3", " Subtraction (-) operator cannot be applied to type 'String'"},
        {"10/0", " Division by zero"},
        {"5%0", " Modulo by zero"},
        {"\"hello\" ** 2", " Power (**) operator cannot be applied to type 'String'"},
        {"\"abc\" > 123", " Higher (>) operator cannot be applied to type 'String'"},
        {"5 and \"hello\"", " And (and) operator can only be applied to type 'Boolean'"},
        {"sin(true)", " sin() cannot take a type 'Boolean' as a parameter"},
        {"tan(PI/2)", " Indefinition error"},
        {"false b8", " Base conversion (b10 to b8) cannot be applied to type 'Boolean'. Only type 'Integer'"},
        {"\"testing\" b16", " Base conversion (b10 to b16) cannot be applied to type 'String'. Only type 'Integer'"},
        {"abc[2] := 4.5 b2", " Base conversion (b10 to b2) cannot be applied to type 'Float'. Only type 'Integer'"},
        {"a", " Variable 'a' does not exist"},
        {"vector[true] := \"something\"", " Arrays can only be accessed using 'Integer', not 'Boolean'"},
        {"arr[5]", " Array element 'arr[5]' does not exist"},
        {"xyz[7] := true",  " Array 'xyz[]' cannot be resized to accept element 'xyz[7]'"},
        {"false == 3", " Equal (==) operator for type 'Boolean' can only operate against another value of type 'Boolean'"},
        {"PI <> \"PI\"", " Not equal (<>) operator for type 'String' can only operate against another value of type 'String'"},
        {"else", " Cannot use the word 'else' without a previous conditional declaration"},
        {"fi", " Cannot use the word 'fi' without a previous conditional declaration"},
        {"if 4 then", " Structure for an if conditional is \"if <boolean_expression> then <statement_list> fi\""},
        {"case", " Cannot use the word 'case' without a previous switch declaration"},
        {"default", " Cannot use the word 'default' without a previous switch declaration"},
        {"fswitch", " Cannot use the word 'fswitch' without a previous switch declaration"},
        {"case \"hola\":", " Case's condition must match switch's data type"},
        {"fswitch", " Switch cannot end without a 'default' block declared"},
        {"done", " Cannot use the word 'done' without a previous loop declaration"},
        {"until true", " Cannot use 'until <boolean_expression>' without a previous loop declaration"},
        {"repeat 0 do", " Loop has to be repeated at least 1 time, not lower"},
        {"repeat \"hola\" do", " Structure for a repeat loop is \"repeat <arithmetic_integer_expression> do <statement_list> done\""},
        {"while 5 do", " Structure for a while loop is \"while <boolean_expression> do <statement_list> done\""},
        {"for a in 3..3 do", " Loop has to be repeated at least 1 time, range values cannot be the same"},
        {"for b in true..76 do", " The range for a for loop needs to be comprised by two integer values"},
        {"until \"xd\"", " Structure for a do until loop is \"do <statement_list> until <boolean_expression>\""}
    };

    if(strcmp(input_file, "tests/arit_test.txt") == 0) {
        total_results = sizeof(arit_test) / sizeof(arit_test[0]);
        passed = 0;
        printf("\n\n\n========================================| %d aritmetic operations tests to pass... |========================================\n\n", total_results);
        for (index = 0; index < total_results; index++) {
            fgets(buffer, BUFFER_LENGTH, file);

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
    }
    else if(strcmp(input_file, "tests/bool_test.txt") == 0) {
        total_results = sizeof(boolean_test) / sizeof(boolean_test[0]);

        passed = 0;
        printf("\n\n\n========================================| %d boolean tests to pass... |========================================\n\n", total_results);
        for (index = 0; index < total_results; index++) {
            fgets(buffer, BUFFER_LENGTH, file);

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
    }
    else if(strcmp(input_file, "tests/string_test.txt") == 0) {
        total_results = sizeof(string_test) / sizeof(string_test[0]);

        passed = 0;
        printf("\n\n\n========================================| %d string concat tests to pass... |========================================\n\n", total_results);
        for (index = 0; index < total_results; index++) {
            fgets(buffer, BUFFER_LENGTH, file);

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
    }
    else if(strcmp(input_file, "tests/var_test.txt") == 0) {
        total_results = sizeof(var_test) / sizeof(var_test[0]);

        passed = 0;
        printf("\n\n\n========================================| %d variables tests to pass... |========================================\n\n", total_results);
        for (index = 0; index < total_results; index++) {
            fgets(buffer, BUFFER_LENGTH, file);

            /* Remove the newline character, if it exists */
            buffer[strcspn(buffer, "\n")] = '\0';

            /* Compare the result with the expected string */
            if (strcmp(buffer, var_test[index].output)) {
                printf("  %d\t[%d / %d]: %s -----> \"%s\"\n", index+1, passed, total_results, var_test[index].input, buffer);
                printf("Result mismatch at line %d: expected \"%s\", got \"%s\"\n\n", index + 1, var_test[index].output, buffer);
            } else {
                passed++;
                printf("  %d\t[%d / %d]: %s -----> \"%s\"\n", index+1, passed, total_results, var_test[index].input, buffer);
            }
        }
    }
    else if(strcmp(input_file, "tests/error_test.txt") == 0) {
        total_results = sizeof(error_test) / sizeof(error_test[0]);

        passed = 0;
        printf("\n\n\n========================================| %d error tests to pass... |========================================\n\n", total_results);
        for (index = 0; index < total_results; index++) {
            fgets(buffer, BUFFER_LENGTH, err_file);
            fgets(buffer, BUFFER_LENGTH, err_file);

            /* Remove the newline character, if it exists */
            buffer[strcspn(buffer, "\n")] = '\0';

            char temp[256];
            strcpy(temp, buffer);

            /* Find the first occurrence of ':' */
            char *colon_pos = strchr(temp, ':');
            
            if (colon_pos != NULL) {
                /* Split the string into two parts */
                *colon_pos = '\0';  /* Terminate the first part */
                strcpy(buffer, colon_pos + 1); /* Copy the part after ':' */
            }

            /* Compare the result with the expected error output */
            if (strcmp(buffer, error_test[index].output)) {
                printf("  %d\t[%d / %d]: %s -----> \"%s\"\n", index+1, passed, total_results, error_test[index].input, buffer);
                printf("Result mismatch at line %d: expected \"%s\", got \"%s\"\n\n", index + 1, error_test[index].output, buffer);
            } else {
                passed++;
                printf("  %d\t[%d / %d]: %s -----> \"%s\"\n", index+1, passed, total_results, error_test[index].input, buffer);
            }
        }
    }

    fclose(file);
    return EXIT_SUCCESS;
}
