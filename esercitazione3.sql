/*
    Esercizio 1
    Trovare nome, cognome dei docenti che nell’anno accademico 2010/2011 hanno tenuto lezioni in almeno due
    corsi di studio (vale a dire hanno tenuto almeno due insegnamenti o moduli A e B dove A è del corso C1 e B
    è del corso C2 dove C1 != C2 ).

    268 | Paolo | Roffia
    269 | Andrea | Lionzo
    270 | Corrado | Corsi
    278 | Alessandro | Lai
    280 | Giuseppe | Ceriani
*/

select p.id, p.nome, p.cognome
from persona p
where p.id in(
    select p.id
    from InsErogato ie join Docenza d on ie.id = d.id_inserogato 
        join Persona p on d.id_persona = p.id
        join CorsoStudi cs on ie.id_corsostudi = cs.id
    where ie.annoaccademico = '2010/2011'
    group by p.id
    having count(distinct cs.id) >= 2
)
order by p.id;

/* SOLUZIONE
select P.id, P.nome, P.cognome
from persona P
where P.id in (
    select D.id_persona
    from Docenza D join InsErogato IE on D.id_inserogato = IE.id
    where IE.annoaccademico = "2010/2011"
    group by D.id_persona
    having count(distinct IE.id_corsoStudi) >= 2
)
order by P.id
limit 5 offset 49;
*/

-----------------------------------------------------------------------------------------------------------------

/*
    Esercizio 2
    Trovare nome, cognome e telefono dei docenti che hanno tenuto nel 2009/2010 un’occorrenza di insegna-
    mento che non sia un’unità logistica del corso di studi con id=4 ma che non hanno mai tenuto un modulo
    dell’insegnamento di ’Programmazione’ del medesimo corso di studi.

    La soluzione ha 5 righe:
    Alberto | Belussi | 045 802 7980
    Vincenzo | Manca | 045 802 7981
    Angelo | Pica | 
    Graziano | Pravadelli | +39 045 802 7081
    Roberto | Segala | 045 802 7997
*/

select p.nome, p.cognome, p.telefono
from persona p
where p.id in (
    select p.id
    from InsErogato ie join Docenza d on ie.id = d.id_inserogato 
        join Persona p on d.id_persona = p.id
    where ie.annoaccademico = '2009/2010'
        and ie.id_corsostudi = '4'
        and ie.modulo = '0'
    group by p.id
    having count(ie.id) >= 1 
) and p.id not in (
    select p.id
    from InsErogato ie join Docenza d on ie.id = d.id_inserogato 
        join Persona p on d.id_persona = p.id
        join Insegn i on ie.id_insegn = i.id
    where i.nomeins = 'Programmazione'
        and ie.id_corsostudi = '4'
        and ie.modulo <> '0'
    group by p.id
    having count(ie.id) >= 1
)
order by p.id;

-----------------------------------------------------------------------------------------------------------------

/*
    Esercizio 3
    Trovare identificatore, nome e cognome dei docenti che, nell’anno accademico 2010/2011, hanno tenuto un
    insegnamento (l’attributo da confrontare è nomeins) che non hanno tenuto nell’anno accademico precedente.
    Ordinare la soluzione per nome e cognome.

    La soluzione ha 1031 righe. Le 5 a partire dalla XX riga sono:
    140 | Ferrarini | Roberto
    142 | Combi | Carlo
    168 | Rossignoli | Cecilia
    173 | Manca | Vincenzo
    184 | Bonacina | Maria Paola
*/

-- metodo 1 (errore 1041 righe)

select distinct p.id, p.cognome, p.nome
from persona p
where EXISTS (
    select ie.id_insegn
    from docenza d join InsErogato ie on d.id_inserogato = ie.id
    where p.id = d.id_persona
        and ie.annoaccademico = '2010/2011'
    EXCEPT 
    select ie.id_insegn
    from docenza d join InsErogato ie on d.id_inserogato = ie.id
    where p.id = d.id_persona
        and ie.annoaccademico = '2009/2010'
)
order by p.id;

-- metodo 2 (errore 1041 righe)

select distinct p.id, p.cognome, p.nome
from persona p
where EXISTS (
    select ie.id_insegn
    from docenza d join InsErogato ie on d.id_inserogato = ie.id
    where p.id = d.id_persona
        and ie.annoaccademico = '2010/2011'
        and ie.id_insegn not in(
            select ie2.id_insegn
            from docenza d2 join InsErogato ie2 on d2.id_inserogato = ie2.id
            where p.id = d2.id_persona
                and ie2.annoaccademico = '2009/2010'
        )
)
order by p.id;

-----------------------------------------------------------------------------------------------------------------

/*
    Esercizio 4
    Trovare per ogni periodo di lezione del 2010/2011 la cui descrizione inizia con ’I semestre’ o ’Primo semestre’
    il numero di occorrenze di insegnamento allocate in quel periodo. Si visualizzi quindi: l’abbreviazione, il
    discriminante, inizio, fine e il conteggio richiesto ordinati rispetto all’inizio e fine.

    La soluzione ha 3 righe:
    Primo semestre | eco | 2010 -10 -04 | 2010 -12 -22 | 104
    Primo semestre | Primo semestre | 2010 -10 -04 | 2011 -01 -22 | 124
    I semestre | I semestre | 2010 -10 -04 | 2011 -01 -31 | 159
*/


-----------------------------------------------------------------------------------------------------------------


/*
    Esercizio 6
    Trovare i corsi di studio che non sono gestiti dalla facoltà di “Medicina e Chirurgia” e che hanno insegnamenti
    erogati con moduli nel 2010/2011. Si visualizzi il nome del corso e il numero di insegnamenti erogati con
    moduli nel 2010/2011.
    Soluzione: ci sono 33 righe. Le prime 5 ordinate rispetto al nome sono:

    Laurea IN Beni culturali | 5
    Laurea IN Bioinformatica | 4
    Laurea IN Biotecnologie | 12
    Laurea IN Filosofia | 8
    Laurea IN Informatica | 2
*/

select cs.nome
from CorsoStudi cs join CorsoInFacolta cif on cs.id = cif.id_corsostudi
    join Facolta f on cif.id_facolta = f.id
where f.nome <> 'Medicina e Chirurgia'
and cs.nome in (
    select cs.nome
    from CorsoStudi cs join InsErogato ie on cs.id = ie.id_corsostudi
    where ie.hamoduli <> '0'
        and ie.annoaccademico = '2010/2011'
    group by cs.nome
    having count(ie.id) >= 1
)
order by cs.nome;

-----------------------------------------------------------------------------------------------------------------

/*
    Esercizio 8
    Trovare, per ogni facoltà, il docente che ha tenuto il numero massimo di ore di lezione nel 2009/2010, riportando
    il cognome e il nome del docente e la facoltà. Per la relazione tra InsErogato e Facolta usare la relazione
    diretta.

    La soluzione ha 10 righe.
    Babbi | Anna Maria | Lingue e letterature straniere | 144.000
    Bartolozzi | Pietro | Medicina e Chirurgia | 411.000
    Battistelli | Adalgisa | Scienze motorie | 144.000
    Brunetti | Federico | Economia | 202.000
    De Lotto | Cinzia | Lingue e letterature straniere | 144.000
    Pedrazza Gorlero | Maurizio | Giurisprudenza | 158.000
    Peruzzi | Enrico | Lettere e filosofia | 150.000
    Pescatori | Sergio | Lingue e letterature straniere | 144.000
    Sala | Gabriel Maria | Scienze della formazione | 245.000
    Spera | Mauro | Scienze matematiche fisiche e naturali | 169.000
*/

--drop view oretot_view;
create temp view oretot_view (id, cognome, nome, facolta, oretot) as
    select p.id, p.cognome, p.nome, f.nome, sum(d.orelez)
    from inserogato ie join docenza d on ie.id = d.id_inserogato
        join persona p on d.id_persona = p.id
        join facolta f on ie.id_facolta = f.id
        /*join corsostudi cs on ie.id_corsostudi = cs.id 
        join corsoinfacolta cif on cs.id = cif.id_corsostudi
        join facolta f on cif.id_facolta = f.id*/
    where d.orelez is not null
        and ie.annoaccademico = '2009/2010'
    group by f.id, p.id;

--drop view oremax_view;
create temp view oremax_view (facolta, oremax) as
    select facolta, max(ov.oretot)
    from oretot_view ov
    group by ov.facolta;

select tot.cognome, tot.nome, tot.facolta, tot.oretot
from oretot_view tot
where row(tot.facolta, tot.oretot) in (
    select max.facolta, max.oremax
    from oremax_view max
)
order by tot.cognome;

-----------------------------------------------------------------------------------------------------------------

/*
    Esercizio 9
    Trovare gli insegnamenti (esclusi i moduli e le unità logistiche) del corso di studi con id=240 erogati nel
    2009/2010 e nel 2010/2011 che non hanno avuto docenti di nome ’Roberto’, ’Alberto’, ’Massimo’ o ’Luca’
    in entrambi gli anni accademici, riportando il nome, il discriminante dell’insegnamento, ordinati per nome
    insegnamento.

    La soluzione ha 22 righe. Le cinque a partire dalla XV riga sono:
    Medicina interna ( V anno ) | -
    Patologia e clinica delle endocrinopatie ( IV anno ) | -
    Patologia e clinica delle endocrinopatie ( V anno ) | -
    Patologia e clinica delle malattie del ricambio ( IV anno ) | -
    Patologia e clinica delle malattie del ricambio ( V anno ) | -
*/

select distinct i.nomeins, dis.descrizione
from insegn i join inserogato ie on i.id = ie.id_insegn
    join corsostudi cs on ie.id_corsostudi = cs.id
    join docenza d on ie.id = d.id_inserogato
    join persona p on d.id_persona = p.id
    join discriminante dis on ie.id_discriminante = dis.id
where cs.id = 240
    and ie.modulo = '0'
    and ie.annoaccademico = '2009/2010'
    and p.nome <> 'Roberto'
    and p.nome <> 'Alberto'
    and p.nome <> 'Massimo'
    and p.nome <> 'Luca'
    and EXISTS (
        select 1
        from inserogato ie2 join docenza d2 on ie2.id = d2.id_inserogato
            join persona p2 on d2.id_persona = p2.id
        where i.id = ie2.id_insegn
            and ie2.id_corsostudi = 240
            and ie2.modulo = '0'
            and ie2.annoaccademico = '2010/2011'
            and p2.nome <> 'Roberto'
            and p2.nome <> 'Alberto'
            and p2.nome <> 'Massimo'
            and p2.nome <> 'Luca'
    )
order by i.nomeins;

-----------------------------------------------------------------------------------------------------------------

/*
    Esercizio 10
    Trovare le unità logistiche del corso di studi con id=420 erogati nel 2010/2011 e che hanno lezione o il
    lunedì (Lezione.giorno=2) o il martedì (Lezione.giorno=3), ma non in entrambi i giorni, riportando il nome
    dell’insegnamento e il nome dell’unità ordinate per nome insegnamento.
    La soluzione ha 8 righe:

    Algoritmi | Teoria
    Architettura degli elaboratori | Laboratorio
    Architettura degli elaboratori | Teoria
    Basi di dati | Laboratorio
    Programmazione I | Laboratorio
    Programmazione I | Teoria
    Sistemi operativi | Laboratorio
    Sistemi operativi | Teoria
*/

select distinct i.nomeins, ie.nomeunita
from  insegn i join inserogato ie on i.id = ie.id_insegn
    join corsostudi cs on ie.id_corsostudi = cs.id
    join lezione l on l.id_inserogato = ie.id
where cs.id = 420
    and ie.annoaccademico = '2010/2011'
    and ie.modulo < '0'
    and (l.giorno = 2 
        or l.giorno = 3)
EXCEPT(
    select i.nomeins, ie.nomeunita
    from  insegn i join inserogato ie on i.id = ie.id_insegn
        join corsostudi cs on ie.id_corsostudi = cs.id
        join lezione l on l.id_inserogato = ie.id
    where cs.id = 420
        and ie.annoaccademico = '2010/2011'
        and ie.modulo < '0'
        and l.giorno = 2
    INTERSECT
    select i.nomeins, ie.nomeunita
    from  insegn i join inserogato ie on i.id = ie.id_insegn
        join corsostudi cs on ie.id_corsostudi = cs.id
        join lezione l on l.id_inserogato = ie.id
    where cs.id = 420
        and ie.annoaccademico = '2010/2011'
        and ie.modulo < '0'
        and l.giorno = 3
);

/* -- Risolutore dubbi : ecco perchè i due risulati, delle due query sono diversi ...
select ie.id, i.nomeins, ie.nomeunita, l.giorno, ie.discriminantemodulo
    from  insegn i join inserogato ie on i.id = ie.id_insegn
        join corsostudi cs on ie.id_corsostudi = cs.id
        join lezione l on l.id_inserogato = ie.id
    where i.nomeins = 'Sistemi operativi'
        and cs.id = 420
        and ie.annoaccademico = '2010/2011'
        and ie.modulo = '-2';
*/

-- alternativa
select distinct i.nomeins, ie.nomeunita/*, ie.modulo*/
from  insegn i join inserogato ie on i.id = ie.id_insegn
    join corsostudi cs on ie.id_corsostudi = cs.id
    join lezione l on l.id_inserogato = ie.id
where cs.id = 420
    and ie.annoaccademico = '2010/2011'
    and ie.modulo < '0'/*ie.nomeunita <> ''*/
    and ((l.giorno = 2
        and not EXISTS(
            select 1
            from lezione l2
            where l2.id_inserogato = ie.id
                and l2.giorno = 3
            )
        )
        or (l.giorno = 3
            and not EXISTS(
            select 1
            from lezione l2
            where l2.id_inserogato = ie.id
                and l2.giorno = 2
            )
        )
    )
order by i.nomeins, ie.nomeunita;

-----------------------------------------------------------------------------------------------------------------

/*
    Esercizio 11
    Trovare il nome dei corsi di studio che non hanno mai erogato insegnamenti che contengono nel nome la stringa
    ’matematica’ (usare ILIKE invece di LIKE per rendere il test non sensibile alle maiuscole/minuscole).
    La soluzione ha 572 righe.
*/

select distinct cs.nome
from corsostudi cs join inserogato ie on cs.id = ie.id_corsostudi
where not EXISTS(
    select 1
    from insegn i
    where ie.id_insegn = i.id 
        and i.nomeins ilike '%matematica%'
);

--alternativa
select distinct cs.nome
from corsostudi cs join inserogato ie on cs.id = ie.id_corsostudi
        join insegn i on ie.id_insegn = i.id
where not(i.nomeins ilike '%matematica%');

-----------------------------------------------------------------------------------------------------------------

/*
    Esercizio 12
    Trovare gli insegnamenti (esclusi moduli e unità logistiche) dei corsi di studi della facoltà di ’Scienze Ma-
    tematiche Fisiche e Naturali’ che sono stati tenuti dallo stesso docente per due anni accademici consecutivi
    riportando il nome dell’insegnamento, il nome e il cognome del docente.
    Per la relazione tra InsErogato e Facolta non usare la relazione diretta.
    Circa la condizione sull’anno accademico, dopo aver estratto una sua opportuna parte, si può trasformare que-
    sta in un intero e, quindi, usarlo per gli opportuni controlli. Oppure si può usarla direttamente confrontandola
    con un’opportuna parte dell’altro anno accademico.

    La soluzione ha 535 righe. Le ultime 5 sono:
    Viticoltura I | Andrea | Pitacco
    Viticoltura II | Gianni | Borin
    Viticoltura III | Claudio | Giulivo
    Web semantico | Matteo | Cristani
    Zonazione vinicola | Francesco | Morari
*/

-- NON COMPLETAMENTE ESATTO

drop view insegnamentiView;
create temp view insegnamentiView(id_inserogato) as
select distinct ieP.id
from inserogato ieP join docenza dP on ieP.id = dP.id_inserogato
where EXISTS(
    select 1
    from inserogato ieF join docenza dF on ieF.id = dF.id_inserogato
    where ief.id_insegn = iep.id_insegn
        and ief < ieP
        and ((  cast( SUBSTRING(ieP.annoaccademico, 6, 4) as Integer)
            -   cast( SUBSTRING(ieF.annoaccademico, 6, 4) as Integer) ) = 1)
        and dP.id_persona = dF.id_persona
);

select distinct i.nomeins, p.nome, p.cognome
from inserogato ie join docenza d on ie.id = d.id_inserogato
        join persona p on d.id_persona = p.id
        join corsostudi cs on ie.id_corsostudi = cs.id 
        join corsoinfacolta cif on cs.id = cif.id_corsostudi
        join facolta f on cif.id_facolta = f.id
        join insegn i on ie.id_insegn = i.id,
        insegnamentiView iview
where ie.modulo = '0'
    and f.nome ilike '%Scienze Matematiche Fisiche e Naturali%'
    and ie.id in (iview.id_inserogato)
order by i.nomeins;

-----------------------------------------------------------------------------------------------------------------

/*
    Esercizio 13
    Trovare per ogni segreteria che serve almeno un corso di studi il numero di corsi di studi serviti, riportando il
    nome della struttura, il suo numero di fax e il conteggio richiesto.
    La soluzione ha 42 righe.
*/

select ss.nomestruttura, count(ss.id)
from strutturaservizio ss join corsostudi cs on ss.id = cs.id_segreteria
group by ss.nomestruttura, ss.fax;
/*having count(ss.nomestruttura) >= 1;*/

-----------------------------------------------------------------------------------------------------------------

/*
    Esercizio 14
    Considerando solo l’anno accademico 2010/2011, trovare i docenti che hanno insegnato per un numero totale
    di crediti di lezione maggiore della media dei crediti totali insegnati (lezione) da tutti i docenti nell’anno
    accademico. I crediti insegnati sono specificati nella tabella Docenza. Per calcolare la somma o la media, si
    devono considerare solo le ’docenze’ che hanno creditilez significativi e diversi da 0 (per rendere la selezione
    un po’ più significativa).
    Come controllo intermedio, la media è ~13.509. La soluzione ha 517 righe.
*/

select p.id, p.cognome, p.nome, otp.sommaore
from ore_tot_prof otp join persona p on otp.idprof = p.id
where otp.sommaore > (
        select avg(otp.sommaore)
        from ore_tot_prof otp
    );

create temp view ore_tot_prof(idprof, sommaore) as
select p.id, sum(d.creditilez)
from inserogato ie join docenza d on ie.id = d.id_inserogato 
    join persona p on d.id_persona = p.id
where ie.annoaccademico = '2010/2011'
    and d.creditilez is not null
    and d.creditilez <> 0
group by p.id;

-----------------------------------------------------------------------------------------------------------------

/*
    Esercizio 15
    Trovare per ogni docente il numero di insegnamenti o moduli o unità logistiche a lui assegnate come docente
    nell’anno accademico 2005/2006, riportare anche coloro che non hanno assegnato alcun insegnamento. Nel
    risultato si mostri identificatore, nome e cognome del docente insieme al conteggio richiesto (0 per il caso
    nessun insegnamento/modulo/unità insegnati).
    La soluzione ha 3315 righe.
*/

drop view if EXISTS insegnamentiDocente CASCADE;
create temp view insegnamentiDocente(iddocente, nome, cognome, inss) as
select p.id, p.nome, p.cognome, count(ie.id)
from inserogato ie join docenza d on ie.id = d.id_inserogato 
    join persona p on d.id_persona = p.id
where ie.annoaccademico = '2005/2006'
group by p.id, p.nome, p.cognome;

select p.id, p.nome, p.cognome, 0 as Nins
from persona p join docenza d on p.id = d.id_persona
EXCEPT 
select ieddoc.iddocente, ieddoc.nome, ieddoc.cognome, 0  as Nins
from insegnamentiDocente ieddoc
UNION
select ieddoc.iddocente, ieddoc.nome, ieddoc.cognome, ieddoc.inss
from insegnamentiDocente ieddoc;