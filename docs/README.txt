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
│               MAKEFILE:              │
└──────────────────────────────────────┘
    1.  La comanda 'make all' requereix que els directoris bin/ i build/
        existeixin. A més, crea dos binaris executables.

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
        implementació interna.

    5.  S'ignoren tant els comentaris com els espais en blanc (\t, \r, etc).

┌──────────────────────────────────────┐
│                 BISON:               │
└──────────────────────────────────────┘
    1.  Les constants PI i E estàn "hardcoded" al codi, en comptes d'estar
        emmagatzemades a la taula de símbols (línies 19, 20).

    2.  La variable 'err_mssg' (línia 28) és un array de 150 chars ja que es
        fa servir per guardar el missatge d'error a loggejar i el missatge més
        llarg que haurà d'escriure és d'uns 115 chars. Els chars sobrants són 
        una mesura de precaució.

    3.  La variable booleana 'err' (línia 29) només deixa printar/mostrar
        el resultat d'una expressió en cas de que no hi hagi hagut un error
        en l'execució d'aquesta (línies 79, 104, 127, 152).

    4.  Totes les expressions possibles (enteres, reals, boooleanes, string)
        són del mateix tipus <expr_val> ja que  la comprovació de tipus es fa 
        de manera interna.

    5.  Cada cop que es fa servir la funció 'type_to_str()', posteriorment
        s'allibera la memòria usada amb 'free()'.

    6.  Es pot concatenar qualsevol tipus de dada amb qualsevol altre tipus
        de dada mentre alguna d'aquestes dues dades sigui de tipus string.
    
    7.  En els casos en els que s'ha de fer una operació entre un enter i un 
        real, es casteja el valor de l'enter a real per tal de facilitar 
        la seva operació (línies 247, 261, 280, ...).

┌──────────────────────────────────────┐
│                SYMTAB:               │
└──────────────────────────────────────┘
    1.  El tipus de dades per emmagatzemar variables és 'id' del fitxer
        'dades.h'. D'aquesta manera podem guardar tots els seus atributs.


╔══════════════════════════════════<#>═════════════════════════════════╗
║                                                                      ║
║                       Funcionalitats adicionals                      ║
║                                                                      ║
╚══════════════════════════════════<#>═════════════════════════════════╝
    1.  S'ha afegit una funció interna que es crida amb la comanda següent:
                                "showVars()"
        que mostrarà en forma de taula ASCII totes les variables definides
        fins al moment de la crida. Aquesta taula conté 3 columnes per a 
        mostrar el nom, el tipus i el valor de cada variable.


╔══════════════════════════════════<#>═════════════════════════════════╗
║                                                                      ║
║                              Limitacions                             ║
║                                                                      ║
╚══════════════════════════════════<#>═════════════════════════════════╝
    1.  No hi han limitacions respecte al que es demana a l'enunciat 
        de la pràctica.