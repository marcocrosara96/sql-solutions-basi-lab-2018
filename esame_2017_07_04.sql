/*
Si consideri il seguente schema relazionale parziale (chiavi primarie sottolineate) contenente le informazioni relative
alla gestione prestiti in una rete di biblioteche:
UTENTE (codiceFiscale, nome , cognome , telefono , dataIscrizione , stato )
PRESTITO (idRisorsa, idBiblioteca, idUtente, dataInizio, durata )
RISORSA (id, biblioteca, titolo , tipo , stato )
dove PRESTITO.idBiblioteca e RISORSA.biblioteca fanno riferimento alla chiave primaria (id) dell’entità BIBLIOTECA
che si assume già definita come tabella. L’attributo UTENTE.stato può assumere il valore ’abilitato’ o ’ammonito’
o ’sospeso’; RISORSA.tipo indica il tipo di risorsa. Esempio: ’articolo’, ’libro’, etc. L’insieme di questi valori
può variare nel tempo ma si vuole mantenere un controllo stretto. RISORSA.stato può assumere il valore ’solo
consultazione’ o ’disponibile’ o ’on-line’.

Domanda 1
[5 punti]
(a) Scrivere il codice PostgreSQL per definire i domini/tabelle ausiliare necessarie.
(b) Indicare i 4 vincoli di integrità referenziale con la notazione Tabella.attributo/i → Tabella.attributo/i.
(c) Scrivere il codice PostgreSQL che generi le tabelle per rappresentare lo schema relazionale scegliendo i
domini più appropriati, inserendo tutti i possibili controlli di integrità e di correttezza dei valori/formato
dei dati. In particolare, si deve garantire che il formato del codice fiscale si 6 caratteri + 2 cifre + carattere
+ 2 cifre + carattere + 3 cifre + carattere, il formato del numero di telefono sia il carattere ’+’ seguito
da 10 cifre, e che una durata del prestito sia positiva.
*/

drop table if exists PRESTITO, RISORSA, UTENTE, BIBLIOTECA;
drop domain if exists statoUtente, statoRisorsa, tipoDM;

create domain statoUtente as varchar(15)
    check( value in( 'abilitato', 'ammonito', 'sospeso'));

create domain statoRisorsa as varchar(15)
    check( value in( 'solo consultazione', 'disponibile', 'online'));

create domain tipoDM as varchar(20)
    check( value in('articolo', 'libro'));

create table BIBLIOTECA(
    id integer primary key
);

create table UTENTE(
    codiceFiscale character(16) primary key, 
    nome varchar(30) not null, 
    cognome varchar(30) not null, 
    telefono character(11) not null, 
    dataIscrizione date not null, 
    stato statoUtente not null,
    check(codiceFiscale similar to '[A-Z]{6}[0-9]{2}[A-Z]{1}[0-9]{2}[A-Z]{1}[0-9]{3}[A-Z]{1}'),
    check(telefono similar to '[+]{1}[0-9]{10}')
);

create table RISORSA(
    id integer, 
    biblioteca integer not null references BIBLIOTECA(id), 
    titolo varchar(50) not null, 
    tipo tipoDM not null,
    stato statoRisorsa not null,
    primary key(id, biblioteca)
);

create table PRESTITO(
    idRisorsa integer, 
    idBiblioteca integer references BIBLIOTECA(id), 
    idUtente character(16) not null references UTENTE, 
    dataInizio date not null,
    durata interval not null,
    primary key(idRisorsa, idBiblioteca, idUtente, dataInizio),
    foreign key(idRisorsa, idBiblioteca) references RISORSA(id, biblioteca)
);

insert into BIBLIOTECA values(1);
insert into BIBLIOTECA values(2);
insert into BIBLIOTECA values(3);
insert into BIBLIOTECA values(4);

insert into UTENTE values('SDFFDF80A01L840W', 'mario' , 'pozio' , '+1234567890' , '02-08-2010' , 'abilitato');
insert into UTENTE values('TDFWED80A01L840W', 'luca' , 'korizia' , '+1234567890' , '02-09-2010' , 'abilitato');
insert into UTENTE values('JDFFDF80A01L840W', 'anima' , 'nemeo' , '+1234567890' , '02-09-2017' , 'abilitato');
insert into UTENTE values('IDFFDF80A01L840W', 'lucia' , 'pozio' , '+1234567890' , '02-08-2012' , 'abilitato');

insert into RISORSA values('1', '1', 'gennarino e i 4 ponti' , 'libro' , 'disponibile');
insert into RISORSA values('2', '1', 'geronimo' , 'libro' , 'disponibile');
insert into RISORSA values('3', '1', 'amore e psiche' , 'libro' , 'disponibile');
insert into RISORSA values('4', '1', 'caramelle' , 'libro' , 'disponibile');
insert into RISORSA values('5', '1', 'giochiamo a tombola' , 'libro' , 'disponibile');
insert into RISORSA values('1', '2', 'giochiamo a jolly' , 'libro' , 'disponibile');

insert into PRESTITO values('1', '1', 'SDFFDF80A01L840W', '01-08-2010', '24:00:00');
insert into PRESTITO values('1', '2', 'SDFFDF80A01L840W', '01-08-2010', '24:00:00');
insert into PRESTITO values('1', '1', 'TDFWED80A01L840W', '02-08-2010', '24:00:00');
insert into PRESTITO values('1', '1', 'TDFWED80A01L840W', '03-10-2010', '24:00:00');
insert into PRESTITO values('1', '1', 'TDFWED80A01L840W', '04-12-2010', '24:00:00');
insert into PRESTITO values('1', '1', 'IDFFDF80A01L840W', '02-08-2010', '24:00:00');
insert into PRESTITO values('1', '1', 'IDFFDF80A01L840W', '03-10-2010', '24:00:00');

/*
Domanda 4 [8 punti]
Scrivere il codice PostgreSQL, definendo anche eventuali viste, per rispondere alle seguenti due interrogazioni
nel modo più efficace:
(a) Trovare per ogni utente che abbia fatto prestiti presso almeno due biblioteche, il numero di prestiti ter-
minati alla data corrente presso ciascuna biblioteca e la loro durata totale sempre per ciascuna biblioteca.
Il risultato deve riportare il codice fiscale dell’utente, l’id della biblioteca e i conteggi richiesti.

(b) Trovare per ogni biblioteca (specificata solo dal suo id), l’utente/i con il maggior numero di prestiti e
l’utente/i con la durata complessiva maggiore, riportando nel risultato l’id della biblioteca, il codice fiscale
dell’utente e i conteggi richiesti (se gli utenti per ciascuna biblioteca coincidono, si deve stampare solo una
riga).
*/

-- a

create temp view utentiSopraDue(utente) as
select p.idUtente
from prestito p
group by p.idUtente
having count(distinct p.idbiblioteca) >= 2;

select p.idUtente, p.idBiblioteca, count(*), sum(p.durata)
from prestito p join utentiSopraDue usd on p.idUtente = usd.utente
where p.dataInizio + p.durata < CURRENT_DATE
group by p.idUtente, p.idBiblioteca;

-- b

select p.idBiblioteca, p.idUtente, count(*)
from prestito p
group by p.idBiblioteca, p.idUtente