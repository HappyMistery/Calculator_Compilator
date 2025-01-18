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
        emmagatzemades a la taula de símbols (línies 21, 22).

    2.  La variable 'err_mssg' (línia 34) és un array de 256 chars ja que es
        fa servir per guardar el missatge d'error a loggejar i el missatge més
        llarg que haurà d'escriure és d'uns 115 chars sense comptar noms de variables. Els chars sobrants són 
        una mesura de precaució.

    3.  La variable booleana 'err' (línia 36) només deixa printar/mostrar
        el resultat d'una expressió en cas de que no hi hagi hagut un error
        en l'execució d'aquesta (línies 133, 162, 229, 254, 309, 344).

    4.  Totes les expressions possibles (enteres, reals, boooleanes, string)
        són del mateix tipus <expr_val> ja que  la comprovació de tipus es fa 
        de manera interna.

    5.  Cada cop que es fa servir la funció 'type_to_str()', posteriorment
        s'allibera la memòria usada amb 'free()'.

    6.  Es pot concatenar qualsevol tipus de dada amb qualsevol altre tipus
        de dada mentre alguna d'aquestes dues dades sigui de tipus string.
    
    7.  En els casos en els que s'ha de fer una operació entre un enter i un 
        real, es casteja el valor de l'enter a real de manera implícita per 
        tal de facilitar la seva operació (línies 422, 503, 649, 763, ...).
    
    8.  Els operadors Equal (==) i Not equal (<>) poden fer-se servir per a tots
        els tipus de dades, amb la condició de que els booleans només poden
        ser comparats amb booleans, i les strings només poden ser comparades
        amb strings.

    9.  Per a crear una taula unidimensional (array) s'ha d'assignar un valor 
        a l'última entrada de la taula, és a dir, si es vol crear un vector de 
        x elements es definirà tal que 'arr_name[x-1] := 0'. D'aquesta manera es
        creen x entrades a la symtable sense cap valor ni tipus, llestes per a 
        ser omplertes.

    10.  Les taules unidimensionals no tenen tipus. Poden existir taules que 
        continguin elements enters, reals, booleans i strings al mateix temps.

    11. Un cop creada una taula unidimensional, no es pot modificar la seva mida,
        és a dir, si es crea una taula amb la següent comanda:
                                "noms[5] := "Ricardo""
        , l'element noms[6] no existeix i si en un futur s'hi intenta assignar 
        algún valor, es notificarà a l'usuari amb un missatge d'error.

    12. Les taules unidimensionals poden ser indexades amb operacions reals sempre
        que el resultat d'aquestes operacions sigui un valor enter.
        L'instrucció "abc[10/2] := true" és totalment vàlida.

    13. L'operació potència real té en compte la part decimal de l'exponent (en
        cas d'haver-n'hi. Línies 593-598).
    
    14. Els casts explícits entre tipus de dades interpreten que han de castejar 
        l'expressió immediatament següent i no més, o en el seu defecte, tot el que 
        es trobi dins del parèntesi immediatament següent (igual que sin(), cos() i tan()).

    15. Poden haver-hi fins a 32 estructures (bucles i condicionals) aniuades (tot i que 
        es recomana no tenir-los ...).

    16. Una estructura (bucles o condicionals) pot tenir fins a 512 instruccions en el seu interior.

    17. Un switch pot tenir fins a 31 casos (case) juntament amb un default obligatori. 
        És a dir, pot tenir des de 0 casos fins a 31 casos, però sempre ha d'haver-hi 
        el cas default.

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
        però no en viceversa.


╔══════════════════════════════════<#>═════════════════════════════════╗
║                                                                      ║
║                              Limitacions                             ║
║                                                                      ║
╚══════════════════════════════════<#>═════════════════════════════════╝
    1.  Podria considerar-se una limitació el fet de que hi ha 1 conflicte 
        shift/reduce degut a l'operació de la potència (línia 570 a bison_spec.y).
        Actualment, i per a que la potència funcioni tal i com es demana, la 
        gramàtica ha d'especificar "expr3 POW expr2" però això dona el conflicte. 
        En canvi, si s'especifica "expr2 POW expr3", el conflicte desapareix.

    2.  No es poden fer canvis de tipus explícits d'enter a string o de real a string.