##>=================================<#>================================<##
||                                                                      ||
||                          Compiladors - PRAC1                         ||
||                         Calculator_Compilator                        ||
||                           Jaume Tello Viñas                          ||
||                             GEI 2024-2025                            ||
||                                                                      ||
##>=================================<#>================================<##

##>=================================<#>================================<##
||                                                                      ||
||                        Compilació i execució                         ||
||                                                                      ||
##>=================================<#>================================<##

┌──────────────────────────────────────┐
│              ABANS DE RES:           │
└──────────────────────────────────────┘
Aquest analitzador està dissenyat amb tecnologies pròpies de Linux, 
per tant, si es vol fer servir en Windows, s'ha de fer servir el 
Subsistema de Windows per Linux (wsl).

A més, s'han d'instalar les eines següents (fent servir 'sudo apt install ...'):
    - gcc
    - flex
    - bison
    - make

┌──────────────────────────────────────┐
│              COMPILACIÓ:             │
└──────────────────────────────────────┘
Per a la compilació d'aquest analitzador, es fa ús de les comandes definides 
al fitxer Makefile. És a dir:
    1. Per a netejar tots els fitxers innecessaris: 
        make clean
    2. Per a compilar i generar tots els fitxers necessaris: 
        make all
Es recomana l'ús de la comanda següent:
    make clean && make all

┌──────────────────────────────────────┐
│               EXECUCIÓ:              │
└──────────────────────────────────────┘
Un cop compilat el codi font, obtenim 2 executables:
    1. ./calc_compiler.exe 'input_file.txt' 'output_file.txt':
        Aquest executable pren com a primer paràmetre un arxiu de text (.txt) 
        amb les instruccions a executar (una instrucció per línia).
        Com a segon paràmetre rep un arxiu de text (.txt) que servirà 
        per emmagatzemar les sortides de cada operació feta.


    2. ./calc_compiler_interactive.exe:
        Aquest executable no pren cap paràmetre sinó que al executar-se 
        va demanant a l'usuari que introdueixi una expressió.
        En aquest cas, els resultats sortiran per pantalla en comptes de
        ser guardats en un arxiu de text (.txt).

Els errors detectats durant l'execució de qualsevol dels executables seran
emmagatzemats a l'arxiu 'error_log.txt'.



##>=================================<#>================================<##
||                                                                      ||
||                         Decisions de disseny                         ||
||                                                                      ||
##>=================================<#>================================<##



##>=================================<#>================================<##
||                                                                      ||
||                              Limitacions                             ||
||                                                                      ||
##>=================================<#>================================<##