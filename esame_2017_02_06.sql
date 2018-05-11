/*
Si consideri il seguente schema relazionale parziale (chiavi primarie sottolineate) contenente le informazioni relative
alla programmazione di allenamenti:
ESERCIZIO(nome, livello, gruppoMuscolare);
PROGRAMMA(nome, livello);
ESERCIZIO_IN_PROGRAMMA(nomeProgramma, giorno, nomeEsercizio, ordine, serie, ripetizioni, TUT, riposo);

dove entrambi gli attributi livello hanno dominio {principiante, intermedio, avanzato}, gruppoMuscolare ha
dominio GM={petto, schiena, spalle, braccia, gambe}, giorno è il nome del giorno della settimana, ordine è un
intero che indica l’ordine di esecuzione in un allenamento, serie indica quante volte una serie di ripetizioni deve
essere svolta, ripetizioni indica quante volte un esercizio deve essere ripetuto, TUT è il tempo sotto tensione in s,
che viene rappresentato come 4 valori interi distinti e riposo è il tempo in s di riposo tra una serie e la successiva.
Si sottolinea che un PROGRAMMA è composto da un insieme di esercizi distribuiti su uno o più giorni.

Domanda 1 [5 punti]
Scrivere in codice PostgreSQL la dichiarazione di tutti i domini necessari per implementare lo schema relazio-
nale.
Scrivere una tabella che rappresenti i possibili valori di TUT: ciascuna tupla deve rappresentare un id e una
possibile combinazione di 4 interi non negativi.
Scrivere il codice PostgreSQL che generi le tabelle per rappresentare lo schema relazionale con tutti i possibili
controlli di integrità e di correttezza dei dati.
*/

create domain livelloDOM as varchar(12)
    check(value in('principiante', 'intermedio', 'avanzato'));

create GM as varchar(7)
    check(value in('petto', 'schiena', 'spalle', 'braccia', 'gambe'));

create GiornoSett as varchar(7)
    check(value in('lunedì', 'martedì', 'mercoledì', 'giovedì', 'venerdì', 'sabato', 'domenica'));

create table ESERCIZIO(
    nome varchar(30) primary key,
    livello livelloDOM,
    gruppoMuscolare GM
);

create table PROGRAMMA(
    nome varchar(30) primary key, 
    livello livelloDOM
);

create table ESERCIZIO_IN_PROGRAMMA(
    nomeProgramma varchar(30) references PROGRAMMA(nome), 
    giorno GiornoSett, 
    nomeEsercizio varchar(30) references ESERCIZIO(nome), 
    ordine, 
    serie, 
    ripetizioni, 
    TUT, 
    riposo
    primary key(nomeProgramma, giorno, nomeEsercizio)
);