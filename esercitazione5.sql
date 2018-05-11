/* 
    Esercizio 1
    Si assume che la tabella Museo possa essere aggiornata da applicazioni diverse, non sincronizzate fra loro.
    Scrivere una transazione che aggiunga un museo e dimostrare cosa succede se due applicazioni aggiungono lo
    stesso museo nello stesso istante usando lo schema della transazione proposta.
*/
--non serve creare transazioni perchè sono singole operazioni, sono due insert, in caso le due 
--operazioni avvengano nello stesso istante a una delle due operazioni "la più lenta" sarà ritornato il
--messaggio d'errori

/*
    Esercizio 2
    Si assuma che una transazione deve visualizzare i prezzi dei musei di Verona che hanno parte decimale diversa
    da 0 e, poi, aggiornare tali prezzi del 10% arrotondando alla seconda cifra decimale. L’altra transazione
    (concorrente) deve aggiornare il prezzo dei musei di Verona aumentandoli del 10% e arrotondando alla seconda
    cifra decimale.
*/
--TRANSAZIONE 1
begin transaction isolation level repeatable read;
    --fondamentale REPEATABLE READ altrimenti vi è un problema se la QUERY 2 viene eseguita tra il select e l'update
    --di TRANSAZIONE 1
    select *
    from museo
    where (prezzo - prezzo::integer) > 0
        and città ilike 'Verona';

    update museo
    set prezzo = round(prezzo*1.10,2)
    where (prezzo-prezzo::integer) > 0
        and città ilike 'Verona';
end;
--inserendo questo livello può essere che l'update sia abortito per problmei di concorrenza durante l'esecuzione
--e dunque ottengo il comportamento corretto 

--QUERY 2
--begin;
    update museo
    set prezzo = round(prezzo*1.10,2)
    where città ilike 'Verona';
--end;

/*
    Esercizio 3
    In una transazione si deve inserire una nuova mostra al museo di Castelvecchio con prezzo d’ingresso a 40 euro
    e prezzo ridotto a 20. Nell’altra transazione (concorrente) si deve calcolare il prezzo medio delle mostre di
    Verona prima considerando solo i prezzi ordinari e, in un’interrogazione separata, considerando solo i prezzi
    ridotti.
*/

--TRANSAZIONE 1
--delete from mostra where titolo = 'Mostra arte moderna';
insert into mostra(titolo, inizio, fine, museo, città, prezzointero, prezzoridotto) 
    values('Mostra arte moderna','05/02/17','10/02/17','CastelVecchio','Verona','40','20');

--TRANSAZIONE 2
begin transaction isolation level repeatable read;
    select avg(prezzointero) as "Media Intero"
    from mostra
    where città ilike 'Verona';

    select avg(prezzoridotto) as "Media Ridotto"
    from mostra
    where città ilike 'Verona';
end;

/*
    Esercizio 4
    In una transazione si deve aumentare il prezzo di tutte le mostre di Verona del 10% mentre, nell’altra, si devono
    ridurre i prezzi ridotti di tutte le mostre del 5%. In entrambi i casi, l’importo finale si deve arrotondare alla
    seconda cifra decimale.
*/
--TRANSAZIONE 1
update mostra
set prezzointero = round(prezzointero * 1.10, 2),
    prezzoridotto = round(prezzoridotto * 1.10, 2)
where città ilike 'Verona'; -- UPDATE è ATOMICO, non serve nulla, se avessi diviso i due set ci vuole il SERIALIZABLE

--TRANSAZIONE 1
update mostra
set prezzoridotto = round(prezzoridotto * 0.95, 2);


/*
    5 -> repetable read o serializable?
*/