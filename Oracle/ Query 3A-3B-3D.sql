------------------------------------------------------------------------------------------------------------------------------------

--ESERCIZIO 3
-- A. Creare un documento XML che riporta gli slot disponibili per un dato evento.
-- Uno slot è disponibile se non compare nelle prenotazioni di un evento

-- X TUTTI GLI EVENTI
select xmlelement("SlotsLiberi",
xmlagg(
        xmlelement("Evento", 
        xmlattributes(p1.codice as "Codice", p1.nome as "Nome"),
        xmlagg(
            xmlelement("Slot",
                xmlattributes(value(sl).id as "ID"),
                xmlforest(
                        value(sl).dimensione as "Dimensione",
                        value(sl).pzGiornaliero as "PrzGiornaliero",
                        value(sl).CoordinataX as "CoordinataX",
                        value(sl).CoordinataY as "CoordinataY"
                    )
                )
            )
        )
    )
)result
from evento p1, table(p1.areaespositiva.slots) sl
where value(sl) not in(
select value(sl1)
from prenotazione p, table(p.slots) sl1
where p.evento.codice = p1.codice)
group by p1.codice, p1.nome;

-- X IL SINGOLO EVENTO (Es: evento con codice: 12345)
select xmlelement("SlotsLiberi",
xmlagg(
        xmlelement("Evento", 
        xmlattributes(p1.codice as "Codice", p1.nome as "Nome"),
        xmlagg(
            xmlelement("Slot",
                xmlattributes(value(sl).id as "ID"),
                xmlforest(
                        value(sl).dimensione as "Dimensione",
                        value(sl).pzGiornaliero as "PrzGiornaliero",
                        value(sl).CoordinataX as "CoordinataX",
                        value(sl).CoordinataY as "CoordinataY"
                    )
                )
            )
        )
    )
)result
from evento p1, table(p1.areaespositiva.slots) sl
where p1.codice = '12345' and value(sl) not in(
select value(sl1)
from prenotazione p, table(p.slots) sl1
where p.evento.codice = '12345')
group by p1.codice, p1.nome;

-- B. Determinare l’evento dell’anno. L’evento dell’anno è l’evento che ha portato il maggior incasso possibile
select p.evento.codice, sum(distinct(Tdeluxe.prezzo+Tstandard.prezzo)) as tot
from prenotazione p join (
    select p1.evento.codice as codD, sum(((value(slot).pzgiornaliero) +  
    (value(slot).pzgiornaliero/100)*(TREAT(deref(value(slot)) as t_deluxe).percentuale))
    *p1.ngiorniaffitto) as prezzo
    from prenotazione p1, table(p1.slots) slot
    where deref(value(slot)) is of type (t_deluxe)
    group by p1.evento.codice
)Tdeluxe on (p.evento.codice = Tdeluxe.codD) join
(
    select p3.evento.codice as codS, sum((value(slot).pzgiornaliero)*p3.ngiorniaffitto) as prezzo 
    from prenotazione p3, table(p3.slots) slot
    where deref(value(slot)) is of type (t_standard)
    group by p3.evento.codice
)Tstandard on (Tdeluxe.codD = Tstandard.codS)
group by p.evento.codice
having  sum(distinct(Tdeluxe.prezzo+Tstandard.prezzo))>= ALL(
select max(Tdeluxe.prezzo+Tstandard.prezzo)
from prenotazione p join (
    select p1.evento.codice as codD, sum(((value(slot).pzgiornaliero) +  
    (value(slot).pzgiornaliero/100)*(TREAT(deref(value(slot)) as t_deluxe).percentuale))
    *p1.ngiorniaffitto) as prezzo
    from prenotazione p1, table(p1.slots) slot
    where deref(value(slot)) is of type (t_deluxe)
    group by p1.evento.codice
)Tdeluxe on (p.evento.codice = Tdeluxe.codD) join
(
    select p3.evento.codice as codS, sum((value(slot).pzgiornaliero)*p3.ngiorniaffitto) as prezzo 
    from prenotazione p3, table(p3.slots) slot
    where deref(value(slot)) is of type (t_standard)
    group by p3.evento.codice
)Tstandard on (Tdeluxe.codD = Tstandard.codS)
group by p.evento.codice
)


-- D. Inserire la prenotazione di un cliente X per un evento Y per i tre slot deluxe liberi che hanno la metratura più alta per 
-- un periodo di Z giorni. Dopo questa prenotazione l’area espositiva preferita diventa quella che contiene tali slots. 
-- L’operazione deve garantire che la base di dati sia consistente dopo l’operazione.

insert into cliente values('X', '3234567890', null, set_area());

insert into evento values('Y', 'cY', to_date('2003/07/15', 'yy/mm/dd'), to_date('2003/07/18', 'yy/mm/dd'), null);

--creo l'area e gli assegno 5 slots deluxe con metratua differente (3 uguali + 2 diversi)

insert into area values('Test', null, 50, set_slots());

insert into table(select slots from area where nome = 'Test')
select ref(s) from slots s where s.id IN (13,14,15,16,17,18,19); 

--verifica dell'esistenza di un'area con almeno 3 slots deluxe liberi
update evento
set areaespositiva = (select ref(a) from area a where a.nome = 
(--va a selezionare l'area che ha gli slots con maggiore metratura
    select area.Narea
    from(
    --restituisce la prima area che ha almeno 3 slots dalla dimensione massima 
        select a1.nome as Narea, max(value(sl).dimensione) as dim, count(*)
        from area a1, table(a1.slots) sl 
        where value(sl).id not in (
        select value(slots).id
        from prenotazione p, table(p.slots) slots
        )
        and deref(value(sl)) is of type(t_deluxe)
        group by a1.nome, value(sl).dimensione 
        having count(*)>=3
    )area
    where rownum = 1
    group by area.Narea)
)
where nome = 'Y';

--creazione di una nuova prenotazione con cliente X ed evento con codice cY
insert into prenotazione
select 9, ref(c), 2, ref(e), set_slots()
from cliente c, evento e
where c.ragSociale = 'X' and e.codice = 'cY';

--assegnamento del 3 slots deluxe alla prenotazione cY
insert into table(select p.slots from prenotazione p where p.evento.codice = 'cY')
select ref(s) from slots s, (
        select value(sl).id as slotArea, value(sl).dimensione
        from evento e, table(e.areaespositiva.slots) sl
        where value(sl) not in (
        select value(slots)
        from prenotazione p, table(p.slots) slots
        )
        and deref(value(sl)) is of type(t_deluxe)
        and e.areaespositiva.nome = 'Test'
        --solo i primi 3 slots 
        and rownum<=3
        group by value(sl)
        having max(value(sl).dimensione)>= ALL(
            select value(sl).dimensione
            from evento e, table(e.areaespositiva.slots) sl
            where value(sl) not in (
            select value(slots)
            from prenotazione p, table(p.slots) slots
            )
            and deref(value(sl)) is of type(t_deluxe)
            and e.areaespositiva.nome = 'Test'    
            )
         )ev
where s.id = ev.slotArea;

--assegnamento dell'area Test all'area preferita del cliente X
update cliente
set areapreferita=(select ref(a) from area a where a.nome = 'Test')
where ragsociale = 'X';

--verifica
select c.areapreferita
from cliente c
where c.ragsociale='X';


