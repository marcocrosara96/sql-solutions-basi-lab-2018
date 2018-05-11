DROP TABLE IF EXISTS automobile, noleggio, cliente;
drop domain if exists nPosti;

-- domanda 1

create domain nPosti as smallint
    check(value in(2, 4, 5, 6, 8, 9)); 

create table automobile(
    targa varchar(7) primary key,
    marca varchar(20) not null,
    modello varchar(20) not null,
    posti nPosti,
    cilindrata integer,
    check(cilindrata >= 0 AND cilindrata < 10000)
);

create table cliente(
    nPatente varchar(10) primary key,
    cognome varchar(20) not null,
    nome varchar(20) not null,
    paeseProvenienza varchar(20),
    nInfrazioni smallint,
    check(nInfrazioni >= 0 ),
    unique(nome, cognome)
);

create table noleggio(
    targa varchar(7) not null,
    cliente varchar(10) not null,
    inizio timestamp not null,
    fine timestamp,
    primary key(targa, cliente, inizio),
    foreign key(cliente) references cliente(nPatente),
    foreign key(targa) references automobile(targa)
);

INSERT INTO automobile values('VR23423','audi','a5',2,1000);
INSERT INTO automobile values('VR11111','audi','a8',2,1000);
INSERT INTO automobile values('VR23424','fiat','500',5,1000);
INSERT INTO automobile values('VR23421','volvo','x9',9,1000);
INSERT INTO automobile values('VR55555','swaggy','pot',5,66);

INSERT INTO cliente values('pat234234','ruffini','carlo', 'milano', 1);
INSERT INTO cliente values('pat324523','giacomini','luca', 'trapani', 0);

INSERT INTO noleggio values('VR23423','pat234234','2017-07-23', '2017-07-23');
INSERT INTO noleggio values('VR23424','pat324523','2017-07-23', null);
INSERT INTO noleggio values('VR23421','pat234234','2017-07-23', null);
INSERT INTO noleggio values('VR55555','pat234234','2017-07-23', '2017-07-24');

/*
cliente c join noleggio n on c.nPatente = n.cliente
    join automobile a on n.targa = a.targa
*/

-- domanda 2
select c.cognome, c.nome, c.paeseProvenienza
from cliente c
where not EXISTS(
    select 1
    from noleggio n join automobile a on n.targa = a.targa
    where n.cliente = c.nPatente
        and a.marca = 'audi'
);

-- domanda 3 (a)
/*select a.marca, count(distinct a.targa) as tot_auto_marca, count(a.targa) tot_noleggi_marca--, sum(datediff(hour, n.inizio, n.fine))
from noleggio n right outer join automobile a on n.targa = a.targa
group by a.marca;*/

create temp view autoPerMarca(marca, numero) as
select a.marca, count(*)
from automobile a
group by a.marca;

create temp view sommaoreecosevarie(marca, tot_auto_marca, tot_noleggi_marca, somma_ore_marca) as
select a.marca, apm.numero as tot_auto_marca, count(a.targa) tot_noleggi_marca, sum(extract(epoch FROM (fine-inizio)/(60*60))) as somma_ore_marca
from noleggio n join automobile a on n.targa = a.targa
    join autoPerMarca apm on a.marca = apm.marca 
group by a.marca, apm.numero;

-- domanda 3 (b)

select socv.marca, socv.somma_ore_marca
from sommaoreecosevarie socv
where socv.somma_ore_marca >= all(
    select sovc2.somma_ore_marca
    from sommaoreecosevarie sovc2
    where sovc2.somma_ore_marca is not null
);

-- domanda 4

explain select c.cognome, c.nome, c.paeseProvenienza
        from cliente c
        where not EXISTS(
            select 1
            from noleggio n join automobile a on n.targa = a.targa
            where n.cliente = c.nPatente
                and a.marca = 'audi'
        );

create index automobile_index on automobile(marca);
analyze automobile;

-- 44.80 to 38.00

-- domanda 5 
