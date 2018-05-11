/*
Si consideri il seguente schema relazionale (chiavi primarie sottolineate) contenente le informazioni relative alle
autostrade italiane:
AUTOSTRADA (codice, nome , gestore , lunghezza ) ;
RAGGIUNGE (autostrada, comune, numeroCaselli ) ;
COMUNE (codiceISTAT, nome , numeroAbitanti , superficie ) ;
Si ricorda che: (1) il codice delle autostrade italiane considerate è composto dal carattere ’A’ seguito da un numero.
(2) il codice ISTAT di un comune è una stringa di 6 cifre. (3) l’attributo numeroCaselli indica il numero di caselli
dell’autostrada presenti nel territorio del comune (potrebbe essere anche zero).

    Domanda 1 [5 punti]
    Nella descrizione dello schema non è specificato quali sono i vincoli di integrità. Indicare quali quali sono i
    vincoli di integrità che si possono desumere usando la notazione ’→’.
    Scrivere il codice PostgreSQL che generi TUTTE le tabelle per rappresentare lo schema relazionale. Si inseri-
    scano tutti i possibili controlli di integrità e di correttezza dei dati. Si giustifichi, dove necessario, la scelta del
    dominio.
*/

drop table if exists raggiunge, autostrada, comune;

create table AUTOSTRADA(
    codice varchar(5) primary key check (codice similar to 'A[0-9]+'),
    nome varchar(40) unique not null,
    gestore varchar(40) not null,
    lunghezza numeric(6,3) not null check(lunghezza >= 0) -- con precisione al metro
);

create table COMUNE(
    codiceISTAT character(6) primary key check (codiceISTAT similar to '[0-9]{6}'), 
    nome varchar(40) unique not null, 
    numeroAbitanti integer not null check(numeroAbitanti >= 0), 
    superficie numeric not null check(superficie > 0)
);

create table RAGGIUNGE(
    autostrada varchar(5) not null references autostrada(codice), 
    comune character(6) not null references comune(codiceISTAT), 
    numeroCaselli smallint check(numeroCaselli >= 0) default 0 not null,
    primary key(autostrada, comune)
    -- foreign key ... refereneces ...(...) 
);

insert into COMUNE values('000001','milano',600000,600000);
insert into COMUNE values('000002','varese',50000,50000);
insert into COMUNE values('000003','zanè',1000,1000);
insert into COMUNE values('000004','thiene',40000,4000);
insert into COMUNE values('000005','roma',700000,700000);

insert into AUTOSTRADA values('A29','roma-infinito', 'paolini', 333);
insert into AUTOSTRADA values('A7','thine-milano', 'regione vene', 60);

insert into RAGGIUNGE values('A29','000001', 5);
insert into RAGGIUNGE values('A29','000002', 5);
insert into RAGGIUNGE values('A29','000005', 5);
insert into RAGGIUNGE values('A7','000004', 1);
insert into RAGGIUNGE values('A7','000003', 0);
insert into RAGGIUNGE values('A7','000001', 1);

/*
    Domanda 2 [6 punti]
    Trovare i comuni che non sono raggiunti da autostrade gestite dal gestore X, riportando il codice, il nome e gli
    abitanti del comune.
*/

select c.codiceISTAT, c.nome, c.numeroabitanti
from COMUNE c
EXCEPT
select distinct c.codiceISTAT, c.nome, c.numeroabitanti
from AUTOSTRADA a join RAGGIUNGE r on a.codice = r.autostrada
    join COMUNE c on r.comune = c.codiceISTAT
where a.gestore = 'paolini';

-- alternativa

select c.codiceISTAT, c.nome, c.numeroabitanti
from COMUNE c
where c.codiceISTAT not in(
    select r.comune
    from RAGGIUNGE r join AUTOSTRADA a on r.autostrada = a.codice
    where a.gestore = 'paolini' 
    and r.numeroCaselli > 0
);

/*
    Domanda 4 [8 punti]
    Scrivere il codice PostgreSQL, definendo anche eventuali viste, per rispondere alle seguenti due interrogazioni
    nel modo più efficace:

    (a) Trovare per ogni autostrada che raggiunga almeno 10 comuni, il numero totale di comuni che raggiunge e
    il numero totale di caselli, riportando il codice dell’autostrada, la sua lunghezza e i conteggi richiesti.

    (b) Selezionare le autostrade che hanno un potenziale di utenti diretti (=numero di abitanti che la possono
    usare dal loro comune) medio rispetto al numero dei caselli dell’autostrada stessa superiore alla media
    degli utenti per casello di tutte le autostrade. Si deve riportare il codice dell’autostrada, il suo numero
    totale di utenti, la media di utenti per casello.
*/

-- A

select a.codice, a.lunghezza, count(r.comune) as comuni_raggiunti, sum(r.numeroCaselli) as caselli_totali
from AUTOSTRADA a join RAGGIUNGE r on a.codice = r.autostrada
where r.numeroCaselli <> 0 -- serve?
group by a.codice, a.lunghezza
having count(r.comune) >= 3; -- es con 3 ma l'esercizio dice 10

--  B

--calcolo la media della pop per autostrada
drop view if exists vista_popmedia;
create temp view vista_popmedia(codice, totutenti, mediapercasello) as
select r.autostrada, sum(c.numeroabitanti), sum(c.numeroabitanti)/sum(r.numerocaselli)
from RAGGIUNGE r join COMUNE c on r.comune = c.codiceISTAT
where r.numerocaselli > 0
group by r.autostrada;

select v.codice, v.totutenti, v.mediapercasello
from vista_popmedia v
where v.mediapercasello >= all(
    select v2.mediapercasello
    from vista_popmedia v2
);

/*
Domanda 5
[7 punti]
(a) Considerando le query della domanda 4, illustrare quali sono gli indici da definire che possono migliorare
le prestazioni e, quindi, scrivere il codice PostgreSQL che definisce gli indici illustrati. Attenzione a non
creare indici già presenti (per ogni indice proposto già presente la valutazione è penalizzata)!

(b) Si consideri poi il seguente risultato del comando ANALYZE su una query inerenti alle tre tabelle
considerate:

QUERY PLAN
-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
        Hash JOIN ( cost =12.72..28.00 ROWS =5 width =118)
        Hash Cond : ( c . codiceistat = r . comune )
        -> Seq Scan ON comune c ( cost =0.00..13.80 ROWS =380 width =146)
        -> Hash ( cost =12.66..12.66 ROWS =5 width =28)
        -> Bitmap Heap Scan ON raggiunge r ( cost =4.19..12.66 ROWS =5 width =28)
        Recheck Cond : (( autostrada ) :: TEXT = ' A1 ' :: TEXT )
        -> Bitmap INDEX Scan ON raggiunge_pkey ( cost =0.00..4.19 ROWS =5)
        INDEX Cond : (( autostrada ) :: TEXT = ' A1 ' :: TEXT )

        Desumere il testo della query.
        Suggerimento: la query inizia con SELECT * FROM ...
*/

-- A

/*
    I join sono fatti tutti usando le chiavi primarie, per le quali il sistema già definisce gli indici in modo
    automatico.
    Quindi non si devono dichiarare ulteriori indici.

    ... unica esclusione sarebbe r.numerocaselli > 0 ...
*/

create index index_raggiunge_caselli on raggiunge(numerocaselli);
ANALYZE raggiunge;

-- B

select * 
from raggiunge r join comune c on c.codiceistat = r.comune
where r.autostrada = 'A1'

-- seleziona tutti i comuni raggiunti dall'autostrada A1