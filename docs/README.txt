╔══════════════════════════════════<#>═════════════════════════════════╗
║                                                                      ║
║                          Compiladors - PRAC1                         ║
║                         Calculator_Compilator                        ║
║                           Jaume Tello Viñas                          ║
║                             GEI 2024-2025                            ║
║                                                                      ║
╚══════════════════════════════════<#>═════════════════════════════════╝

╔══════════════════════════════════<#>═════════════════════════════════╗
║                                                                      ║
║                        Compilació i execució                         ║
║                                                                      ║
╚══════════════════════════════════<#>═════════════════════════════════╝
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
    1. bin/calc_compiler 'input_file.txt' 'output_file.txt':
        Aquest executable pren com a primer paràmetre un arxiu de text (.txt) 
        amb les instruccions a executar (una instrucció per línia).
        Com a segon paràmetre rep un arxiu de text (.txt) que servirà 
        per emmagatzemar les sortides de cada operació feta.


    2. bin/calc_compiler_interactive.exe:
        Aquest executable no pren cap paràmetre sinó que al executar-se 
        va demanant a l'usuari que introdueixi una expressió.
        En aquest cas, els resultats sortiran per pantalla en comptes de
        ser guardats en un arxiu de text (.txt).

Els errors detectats durant l'execució de qualsevol dels binaris seran
emmagatzemats a l'arxiu 'logs/error_log.txt'.


╔══════════════════════════════════<#>═════════════════════════════════╗
║                                                                      ║
║                         Decisions de disseny                         ║
║                                                                      ║
╚══════════════════════════════════<#>═════════════════════════════════╝
┌──────────────────────────────────────┐
│                 FLEX:                │
└──────────────────────────────────────┘
    1.  Només es reconeix un únic TOKEN per a les bases (oct, bin, dec, hex)
        en comptes de un TOKEN per a cada base. Això és degut a que l'arxiu
        bison ja s'encarrega de trobar de quina base es tracta

    2.  Les paraules reservades poden ser escrites tant en majúscules com en 
        minúscules mentre que les constants 'E' i 'PI' només poden ser escrites
        en majúscules.

    3.  Quan es detecta un TOKEN STRING se l'hi eliminen les cometes
        i se l'hi afegeix un delimitador '\0'.

    4.  Quan es detecta un TOKEN BOOL es passa com a un enter o 0 o 1 en comptes
        de passar-se com una string "true" o "false" per a facilitar la
        implementació interna

┌──────────────────────────────────────┐
│                 BISON:               │
└──────────────────────────────────────┘


╔══════════════════════════════════<#>═════════════════════════════════╗
║                                                                      ║
║                       Funcionalitats adicionals                      ║
║                                                                      ║
╚══════════════════════════════════<#>═════════════════════════════════╝



╔══════════════════════════════════<#>═════════════════════════════════╗
║                                                                      ║
║                              Limitacions                             ║
║                                                                      ║
╚══════════════════════════════════<#>═════════════════════════════════╝