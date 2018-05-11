DROP TABLE Orario, Opera, Mostra, Museo;
DROP DOMAIN giorniSettimana;

--Creo un nuovo dominio per i giorni della settimana
CREATE DOMAIN giorniSettimana AS CHAR (3)
    CHECK ( VALUE IN ('LUN', 'MAR', 'MER', 'GIO', 'VEN', 'SAB', 'DOM'));

CREATE TABLE Museo (
    nome VARCHAR(30) DEFAULT 'MuseoVeronese',
    città VARCHAR(20) DEFAULT 'Verona',
    indirizzo VARCHAR(50),
    numeroTelefono VARCHAR(15),
    giornoChiusura giorniSettimana NOT NULL,
    prezzo NUMERIC(5,2) NOT NULL DEFAULT 10, --NUMERIC è quivalente a DECIMAL
    PRIMARY KEY(nome, città)
);

CREATE TABLE Mostra (
    titolo VARCHAR(30),
    inizio DATE NOT NULL,
    fine DATE NOT NULL,
    museo VARCHAR(30),
    città VARCHAR(20),
    prezzo NUMERIC(5,2),
    PRIMARY KEY(titolo, inizio),
    FOREIGN KEY(museo, città) REFERENCES Museo(nome, città),
    CHECK(fine > inizio)
);

CREATE TABLE Opera (
    nome VARCHAR(30),
    cognomeAutore VARCHAR(20),
    nomeAutore VARCHAR(20),
    museo VARCHAR(30),
    città VARCHAR(20),
    epoca VARCHAR(20),
    anno INTEGER,
    PRIMARY KEY(nome, cognomeAutore, nomeAutore),
    FOREIGN KEY(museo, città) REFERENCES Museo(nome, città),
    CHECK(anno < 9999)
);

CREATE TABLE Orario (
    progressivo INTEGER PRIMARY KEY,
    museo VARCHAR(30) NOT NULL,
    città VARCHAR(20) NOT NULL,
    giorno giorniSettimana NOT NULL, --proporre un dominio !
    orarioApertura TIME WITH TIME ZONE DEFAULT '09:00 CET',
    orarioChiusura TIME WITH TIME ZONE DEFAULT '19:00 CET',
    FOREIGN KEY(museo, città) REFERENCES Museo(nome, città),
    CHECK(orarioChiusura > orarioApertura)
);

-- ES 2 e 3
INSERT INTO Museo (nome, città, indirizzo, numeroTelefono, giornoChiusura, prezzo) 
    VALUES ('Arena', 'Verona', 'piazza Bra', '045 8003204', 'MAR', 20),
        ('CastelVecchio', 'Verona', 'Corso Castelvecchio', '045 594734', 'LUN', 15);

INSERT INTO Opera (nome, cognomeAutore, nomeAutore, museo, città, epoca, anno) 
    VALUES ('Notte stellata sul rodano', 'van Gogh', 'Vincent Willem', 'CastelVecchio', 'Verona', 'Vario', '1886'), 
        ('Presepe Italiano', 'Rossi', 'Mario', 'Arena', 'Verona', 'moderno', 1997),
        ('Presepe Svizzero', 'Bianchi', 'Luigi', 'Arena', 'Verona', 'moderno', 1997);

INSERT INTO Mostra (titolo, inizio, fine, museo, città, prezzo) 
    VALUES ('Presepi del mondo', '02-05-2017', '06-08-2017', 'Arena', 'Verona', 14),
        ('Vincent Life', '01-02-2016', '01-02-2017', 'CastelVecchio', 'Verona', 12);

-- ES 4 => Provare ad inserire nella relazione Museo tuple che violino i vincoli specificati.
INSERT INTO Museo (nome, città, indirizzo, numeroTelefono, giornoChiusura, prezzo) 
    VALUES ('Arena', 'Verona', 'piazza Bra', '045 8003204', 'MAR', 20),
            -- Non è possibile aggiungerla poicè esiste già 
        ('Gigio', 'Padano', 'Corso Porto', '045 494555', 'Monday', 5);
            -- Non è possibile agigungerla poichè il valore del giorno della settimana è errata

-- ES 5 => Nella relazione Museo, aggiungere l’attributo sitoInternet e inserire gli opportuni valori.
ALTER TABLE Museo ADD COLUMN sitoInternet VARCHAR(50);

UPDATE Museo
SET sitoInternet = 'www.arenaverona.it'
WHERE nome = 'Arena' AND città = 'Verona';

UPDATE Museo
SET sitoInternet = 'www.castelvecchio.it'
WHERE nome = 'CastelVecchio' AND città = 'Verona';

-- ES 6 => Nella relazione Mostra modificare l’attributo prezzo in prezzoIntero ed aggiungere l’attributo prezzoRi-
-- dotto con valore di default 5. Aggiungere il vincolo (di tabella o di attributo?) che garantisca che Mo-
-- stra.prezzoRidotto sia minore di Mostra.prezzo.
ALTER TABLE Mostra RENAME COLUMN prezzo TO prezzoIntero;
ALTER TABLE Mostra ADD COLUMN prezzoRidotto NUMERIC(5,2) DEFAULT 5;
ALTER TABLE Mostra ADD CHECK( prezzoRidotto < prezzoIntero );

-- ES 7 => Nella relazione Museo aggiornare il prezzo aggiungendo 1 Euro nelle tuple esistenti.
UPDATE Museo
SET prezzo = prezzo + 1;

-- ES 8 => Nella relazione Mostra aggiornare il prezzoRidotto aumentandolo di 1 Euro per quelle mostre che hanno
-- prezzoIntero inferiore a 15 Euro.
UPDATE Mostra
SET prezzoRidotto = prezzoRidotto + 1
WHERE prezzoIntero < 15;