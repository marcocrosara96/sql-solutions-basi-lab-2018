-- nome database: did2014

/*Visualizzare il nome degli insegnamenti offerti dal corso di laurea in
Informatica nell’anno accademico 2009/2010.*/

/*
// ESEMPIO 1
    SELECT DISTINCT I.nomeins
    FROM CorsoStudi CS, InsErogato IE, Insegn I
    WHERE CS.id = IE.id_corsostudi
    AND IE.id_insegn = I.id
    AND IE.annoaccademico = '2009/2010'
    AND CS.nome = 'Laurea in Informatica';
*/

/*
//ESEMPIO 1 - versione 2
    SELECT DISTINCT I.nomeins
    FROM CorsoStudi CS JOIN InsErogato IE ON CS.id = IE.id_corsostudi
                        JOIN Insegn I ON IE.id_insegn = I.id
    WHERE IE.annoaccademico = '2009/2010'
    AND CS.nome = 'Laurea in Informatica';
*/

/*
    Esercizio 1
    Visualizzare il numero di corso studi presenti nella base di dati.
    Soluzione: ci sono 635 corsi di studio.
*/

SELECT COUNT(*)
FROM CorsoStudi;

/*
    Esercizio 2
    Visualizzare il nome, il codice, l’indirizzo e l’identificatore del preside di tutte le facoltà.
    Soluzione: ci sono 8 facoltà.
*/

SELECT nome, codice, indirizzo, id_preside_persona
FROM facolta;

/*
    Esercizio 3
    Trovare per ogni corso di studi che ha erogato insegnamenti nel 2010/2011 il suo nome e il nome delle facoltà
    che lo gestiscono (si noti che un corso può essere gestito da più facoltà). Non usare la relazione diretta tra
    InsErogato e Facoltà. Porre i risultati in ordine di nome corso studi.
    Soluzione: ci sono 211 righe. Le 5 righe dalla X posizione sono: ...
*/

SELECT DISTINCT CS.nome, F.nome
FROM InsErogato IE JOIN CorsoStudi CS ON  IE.id_corsostudi = CS.id
    JOIN CorsoInFacolta CIF ON CS.id = CIF.id_corsostudi
    JOIN Facolta F ON F.id = CIF.id_facolta
WHERE IE.annoaccademico = '2010/2011'
ORDER BY CS.nome;

/*
    Esercizio 4
    Visualizzare il nome, il codice e l’abbreviazione di tutti i corsi di studio gestiti dalla facoltà di Medicina e
    Chirurgia.
    Soluzione: ci sono 236 righe.
*/

select cs.nome, cs.codice, cs.abbreviazione
from facolta f join corsoinfacolta cif on f.id = cif.id_facolta join CorsoStudi cs on cs.id = cif.id_corsostudi
where f.nome ='Medicina e Chirurgia';

/*
    Esercizio 5
    Visualizzare il codice, il nome e l’abbreviazione di tutti corsi di studio che nel nome contengono la sottostringa
    ’lingue’ (eseguire il confronto usando ILIKE invece di LIKE : in questo modo i caratteri maiuscolo e minuscolo
    non sono diversi).
    Soluzione: ci sono 16 righe.
*/

select codice, nome, abbreviazione
from CorsoStudi
where nome ILIKE('%lingue%');

/*
    Esercizio 6
    Visualizzare le sedi dei corsi di studi in un elenco senza duplicati.
    Soluzione: ci sono 48 righe.
*/

select distinct sede
from CorsoStudi;

/*
    Esercizio 7
    Visualizzare i moduli degli insegnamenti erogati nel 2010/2011 nei corsi di studi della facoltà di Economia.
    Si visualizzi il nome dell’insegnamento, il discriminante (attributo descrizione della tabella Discriminante), il
    nome del modulo e l’attributo modulo.
    Soluzione: ci sono 299 righe.
*/

select distinct CS.nome, D.descrizione, IE.nomemodulo, IE.modulo
from InsErogato IE join CorsoStudi CS on  IE.id_corsostudi = CS.id
    join CorsoInFacolta CIF on CS.id = CIF.id_corsostudi
    join Facolta F on F.id = CIF.id_facolta
    join Discriminante D on IE.id_discriminante = D.id
where IE.annoaccademico = '2010/2011'
    and F.nome = 'Economia';

/*
    Esercizio 8
    Visualizzare il nome e il discriminante (attributo descrizione della tabella Discriminante) degli insegnamenti
    erogati nel 2009/2010 che non sono moduli o unità logistiche e che hanno 3, 5 o 12 crediti. Si ordini il risultato
    per discriminante.
    Soluzione: ci sono 724 righe distinte. Le ultime 5 righe sono: ...
*/

select distinct I.nomeins, D.descrizione
from InsErogato IE join Insegn I on IE.id_insegn = I.id 
    join Discriminante D on D.id = IE.id_discriminante
where IE.annoaccademico = '2009/2010' 
    and IE.modulo = '0' 
    and IE.crediti IN (3, 5, 12)
order by D.descrizione;

/*
    Esercizio 9
    Visualizzare l’identificatore, il nome e il discriminante degli insegnamenti erogati nel 2008/2009 che non sono
    moduli o unità logistiche e con peso maggiore di 9 crediti. Ordinare per nome.
    Soluzione: ci sono 1218 righe. Le 5 righe dalla MXXIII riga sono ...
*/

select I.id, I.nomeins, D.descrizione
from Insegn I join InsErogato IE on IE.id_insegn = I.id
    join Discriminante D on IE.id_discriminante = D.id
where IE.annoaccademico = '2008/2009'
    and IE.modulo = '0'
    and IE.crediti > 9
order by I.nomeins;

/*
    Esercizio 10
    Visualizzare in ordine alfabetico di nome degli insegnamenti (esclusi i moduli e le unità logistiche) erogati
    nel 2010/2011 nel corso di studi in Informatica, riportando il nome, il discriminante, i crediti e gli anni di
    erogazione.
    Soluzione: ci sono 26 righe.
*/

select distinct I.nomeins, D.descrizione, IE.crediti, IE.annierogazione
from Insegn I join InsErogato IE on IE.id_insegn = I.id
    join CorsoStudi CS on IE.id_corsostudi = CS.id
    join Discriminante D on IE.id_discriminante = D.id
where IE.modulo = '0'
    and IE.annoaccademico = '2010/2011'
    and CS.nome = 'Laurea in Informatica'
order by I.nomeins;
---limit 5 offset 25;

/*
    Esercizio 11
    Trovare il massimo numero di crediti associato a un insegnamento fra quelli erogati nel 2010/2011.
    Soluzione: 180.
*/ 

--con variazione
select distinct I.nomeins, IE.crediti
from Insegn I join InsErogato IE on I.id = IE.id_insegn
where Ie.annoaccademico = '2010/2011'
    and IE.crediti = (select max(IE.crediti) as maxcrediti
    from InsErogato IE
    where Ie.annoaccademico = '2010/2011');

/*
    Esercizio 12
    Trovare, per ogni anno accademico, il massimo e il minimo numero di crediti erogati tra gli insegnamenti
    dell’anno.
    Soluzione: ci sono 16 righe.
*/

select IE.annoaccademico, MAX(IE.crediti) AS maxcrediti, MIN(IE.crediti) AS mincrediti --manca qualcosa
from InsErogato IE
group by IE.annoaccademico;

/*
    Esercizio 13
    Trovare, per ogni anno accademico e per ogni corso di studi la somma dei crediti erogati (esclusi i moduli e le
    unità logistiche: vedi nota sopra) e il massimo e minimo numero di crediti degli insegnamenti erogati sempre
    escludendo i moduli e le unità logistiche.
    Soluzione: ci sono 1587 righe. Le riga relativa alla "Scuola di Specializzazione in Urologia (Vecchio ordina-
    mento)" nell’anno 2011/2012 ha valori 52.00, 10.00 e 162.00.
*/

select CS.nome, IE.annoaccademico, sum(IE.crediti)
from InsErogato IE join CorsoStudi CS on IE.id_corsostudi = CS.id
where IE.modulo = '0'
group by CS.nome, IE.annoaccademico;

/*
    Esercizio 14
    Trovare per ogni corso di studi della facoltà di Scienze Matematiche Fisiche e Naturali il numero di insegnamenti
    (esclusi i moduli e le unità logistiche) erogati nel 2009/2010.
    Soluzione: ci sono 21 righe.
*/

select Cs.nome, count(Ie.id) as numInsegn
from InsErogato IE join CorsoStudi CS on  IE.id_corsostudi = CS.id
    join CorsoInFacolta CIF on CS.id = CIF.id_corsostudi
    join Facolta F on F.id = CIF.id_facolta
where IE.modulo = '0'
    and F.nome = 'Scienze Matematiche Fisiche e Naturali'
    and IE.annoaccademico = '2009/2010'
group by CS.nome;

/*
    Esercizio 15
    Trovare i corsi di studi che nel 2010/2011 hanno erogato insegnamenti con un numero di crediti pari a 4 o 6 o
    8 o 10 o 12 o un numero di crediti di laboratorio tra 10 e 15 escluso, riportando il nome del corso di studi e la
    sua durata. Si ricorda che i crediti di laboratorio sono rappresentati dall’attributo creditilab della tabella
    InsErogato.
    Soluzione: ci sono 197 righe. Le prime 5 ordinate rispetto al nome sono: ...
*/