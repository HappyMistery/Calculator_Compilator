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
        "make clean"
    2. Per a compilar i generar tots els fitxers necessaris: 
        "make all"
Es recomana l'ús de la comanda següent:
    "make clean && make all"

┌──────────────────────────────────────┐
│               EXECUCIÓ:              │
└──────────────────────────────────────┘
Un cop compilat el codi font, obtenim 2 executables:
    1. bin/calc_compiler 'input_file.txt' 'output_file.txt':
        Aquest executable pren com a primer paràmetre un arxiu de text (.txt) 
        amb les instruccions a executar (una instrucció per línia).
        Com a segon paràmetre rep un arxiu de text (.txt) que servirà 
        per emmagatzemar les sortides de cada operació feta.
        Ex d'ús: "./bin/calc_compiler tests/structs_test.txt output.txt"


    2. bin/calc_compiler_interactive.exe:
        Aquest executable no pren cap paràmetre sinó que al executar-se 
        va demanant a l'usuari que introdueixi una expressió.
        En aquest cas, els resultats sortiran per pantalla en comptes de
        ser guardats en un arxiu de text (.txt).
        Ex d'ús: "./bin/calc_compiler_interactive"

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
    
    2.  Els fitxers per a la sortida d'errors i per a la sortida del codi de
        3 adreces (c3a) es creen al moment de la compilació.

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

    4.  Quan es detecta un TOKEN BOOL es passa com a un enter amb valor 0 o 1 
        en comptes de passar-se com una string "true" o "false" per a facilitar 
        la implementació interna.

    5.  S'ignoren tant els comentaris com els espais en blanc (\t, \r, etc).

┌──────────────────────────────────────┐
│                 BISON:               │
└──────────────────────────────────────┘
    1.  Les constants PI i E estàn "hardcoded" al codi, en comptes d'estar
        emmagatzemades a la taula de símbols (línies 21, 22).

    2.  La variable 'err_mssg' (línia 35) és un array de 256 chars ja que es
        fa servir per guardar el missatge d'error a loggejar i el missatge més
        llarg que haurà d'escriure és d'uns 115 chars sense comptar noms de 
        variables. L'espai sobrant és una mesura de precaució.

    3.  La variable booleana 'err' (línia 37) només deixa printar/mostrar
        el resultat d'una expressió en cas de que no hi hagi hagut un error
        en l'execució d'aquesta (línies 468, 505, 579, 610, 6804, 710).

    4.  Totes les expressions possibles (enteres, reals, boooleanes, string)
        són del mateix tipus <expr_val> (línia 104) ja que  la comprovació de 
        tipus es fa de manera interna.

    5.  Cada cop que es fa servir la funció 'type_to_str()', posteriorment
        s'allibera la memòria usada amb 'free()'.

    6.  Es pot concatenar qualsevol tipus de dada amb qualsevol altre tipus
        de dada mentre alguna d'aquestes dues dades sigui de tipus string.
    
    7.  En els casos en els que s'ha de fer una operació entre un enter i un 
        real, es casteja el valor de l'enter a real de manera implícita per 
        tal de facilitar la seva operació (línies 795, 879, 954, 1050, 1225, ...).
    
    8.  Els operadors Equal (==) i Not equal (<>) poden fer-se servir per a tots
        els tipus de dades, amb la condició de que els booleans només poden
        ser comparats amb booleans, i les strings només poden ser comparades
        amb strings. Per altre banda, reals i enters poden comparar-se entre ells.

    9.  Per a crear una taula unidimensional (array) s'ha d'assignar un valor 
        a l'última entrada de la taula, és a dir, si es vol crear un vector de 
        x elements es definirà tal que 'arr_name[x-1] := 0'. D'aquesta manera es
        creen x entrades a la symtable sense cap valor ni tipus, preparades per a 
        ser omplertes (línies 520-530).

    10.  Les taules unidimensionals no tenen tipus. Poden existir taules que 
        continguin elements enters, reals, booleans i strings al mateix temps.

    11. Un cop creada una taula unidimensional, no es pot modificar la seva mida,
        és a dir, si es crea una taula amb la següent comanda:
                                "noms[5] := "Ricardo""
        , l'element noms[6] no existeix i si en un futur s'hi intenta assignar 
        algún valor, es notificarà a l'usuari amb un missatge d'error (línies 534 i 639).

    12. Les taules unidimensionals poden ser indexades amb operacions reals sempre
        que el resultat d'aquestes operacions sigui un valor enter o sigui extremadament
        proper a un valor enter.
        L'instrucció "abc[10/2] := true" és totalment vàlida i es tractarà igual que 
        l'instrucció "abc[5] := true".

    13. L'operació potència per a reals té en compte la part decimal de l'exponent (en
        cas d'haver-n'hi. Línies 972-977).
    
    14. Els casts explícits entre tipus de dades interpreten que han de castejar 
        l'expressió immediatament següent i no més, o en el seu defecte, tot el que 
        es trobi dins del parèntesi immediatament següent (igual que sin(), cos() i tan()).

    15. Poden haver-hi fins a 32 estructures (bucles i condicionals) aniuades (tot i que 
        es recomana no tenir-los ...).

    16. Una estructura (bucle o condicional) pot tenir fins a 512 instruccions 
        en el seu interior.

    17. Un switch pot tenir fins a 31 casos (case) juntament amb un cas default obligatori. 
        És a dir, pot tenir des de 0 casos fins a 31 casos, però sempre ha d'haver-hi 
        el cas default.

    18. El bucle for pot ser ascendent o descendent, depenent de l'ordre del rang esepcificat.
        En cas de que el primer element del rang sigui menor al segon, el bucle iterarà de
        manera ascendent, afegint +1 al id a cada iteració. En cas contrari es restarà -1 al id.
    
┌──────────────────────────────────────┐
│                SYMTAB:               │
└──────────────────────────────────────┘
    1.  El tipus de dades per emmagatzemar variables és 'id' del fitxer
        'dades.h'. D'aquesta manera es poden guardar tots els seus atributs.

┌──────────────────────────────────────┐
│                  C3A:                │
└──────────────────────────────────────┘
    1.  Els temporals tenen un rang de noms des de $t001 fins a $t999.

    2.  L'operació potència (POW) es mostra com un bucle de multiplicacions.

    3.  Funcions com SUBSTR i LEN retornen un 3AC amb el resultat de l'operació.

    4.  Les Strings també produeixen 3AC. A més, l'operació de concatenació
        d'strings es representa amb el 3AC "CONCAT" tot i no existir. 


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
        En el cas de les taules unidimensionals, mostrarà tots els elements 
        d'una mateixa taula de manera continuada, sense altres variables 
        entre mig.

    2.  S'han afegit casts explícits entre tipus de dades aritmètics i boooleanes
        així com entre strings i tipus de dades tant aritmètics com booleanes, 
        però no viceversa.

    3.  Existeix una validació automàtica per als arxius d'entrada següents:
            - arit_test.txt
            - bool_test.txt
            - string_test.txt
            - var_test.txt
            - error_test.txt
        Per tal d'executar-los tots i veure els test que el programa passa, es
        pot executar la següent comanda:
            "./bin/calc_compiler tests/arit_test.txt output.txt && 
            ./bin/calc_compiler tests/bool_test.txt output.txt && 
            ./bin/calc_compiler tests/string_test.txt output.txt && 
            ./bin/calc_compiler tests/var_test.txt output.txt && 
            ./bin/calc_compiler tests/error_test.txt output.txt"
        Tot i existir molts més fitxers d'entrada per a tests, aquests estan 
        orientats a la validació del 3AC, per tant no tenen validació automàtica.


╔══════════════════════════════════<#>═════════════════════════════════╗
║                                                                      ║
║                              Limitacions                             ║
║                                                                      ║
╚══════════════════════════════════<#>═════════════════════════════════╝
    1.  Podria considerar-se una limitació el fet de que hi ha 1 conflicte 
        shift/reduce degut a l'operació de la potència (línia 570 a bison_spec.y).
        Actualment, i per a que la potència funcioni tal i com es demana, la 
        gramàtica ha d'especificar "expr3 POW expr2" però això comporta un conflicte. 
        En canvi, si s'especifica "expr2 POW expr3", el conflicte desapareix.

    2.  No es poden fer canvis de tipus explícits d'enter a string o de real a string.