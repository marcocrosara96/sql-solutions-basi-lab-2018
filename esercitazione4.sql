/*
    Esercizio 1
    Visualizzare le sedi dei corsi di studi in un elenco senza duplicati.
    Soluzione: da ~95 accessi si passa a... . Gli indici creati sono: ....
*/

 -- Da ~97 accessi si passa a  . Gli indici creati sono: corsostudi(sede)
 -- Creando un indice su sede, il numero di accessi a disco non diminuisce. Quindi nessun indice può migliorare la query.

EXPLAIN select distinct sede
        from corsostudi cs;

create index index_corsostudi on corsostudi(sede);
analyze corsostudi;

-------------------------------------------------------------------------------------------------------------------

/*
    Esercizio 2
    Trovare, per ogni insegnamento erogato dell’a.a. 2013/2014, il suo nome e id della facoltà che lo gestisce
    usando la relazione assorbita con facoltà.
    Soluzione: da ~6328 accessi si passa a ~4557 con la creazione di un solo indice. Quale?
*/

-- Si passa da circa 6328 accessi si passa a 4557 accessi con la creazione di un unico indice su inserogato.annoaccademico
 
EXPLAIN select i.nomeins, ie.id_facolta
        from inserogato ie join insegn i on ie.id_insegn = i.id
        where ie.annoaccademico = '2013/2014';

create index index_annoaccademico on inserogato(annoaccademico);
analyze inserogato;

-------------------------------------------------------------------------------------------------------------------

/*
    Visualizzare il codice, il nome e l’abbreviazione di tutti corsi di studio che nel nome contengono la sottostringa
    ’lingue’ (eseguire un test case-insensitive: usare ILIKE invece di LIKE ).
    Soluzione: da ~96 accessi si passa a...
*/

-- Si passa da circa  accessi si passa a  accessi con la creazione di


 