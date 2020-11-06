------ VINCOLI ------

-- 1. In un'area espositiva possono svolgersi al massimo un evento per volta, in
-- base al periodo di quest'ultimi. Quindi un evento, per potersi svolgere,
-- deve ricadere in un periodo in cui non ci siano ulteriori eventi, in quanto ci
-- potrebbero essere conflitti per quanto riguarda la disponibilità degli slots;

-- Verifica: resitituire gli eventi che si verificano nella data di un altro evento
-- nella stessa area espositiva
select e.codice
from evento e 
where e.datainizio in (
select e1.datainizio
from evento e1
where e1.codice <> e.codice
and e1.areaespositiva.nome = e.areaespositiva.nome
)
and e.datafine in (
select e2.datafine
from evento e2
where e2.codice <> e.codice
and e2.areaespositiva.nome = e.areaespositiva.nome
)

-- oppure si può specificare la data

select e.nome
from evento e
where e.datainizio = to_date('2003/07/15', 'yy/mm/dd')
and e.datafine = to_date('2003/06/18', 'yy/mm/dd')

-- oppure si potrebbe ricercare la data di un evento in un intervallo
select e.nome
from evento e
where (e.datainizio between
to_date('2003/06/15', 'yy/mm/dd')
and
to_date('2003/06/18', 'yy/mm/dd'))
and (e.datafine between
to_date('2003/06/18', 'yy/mm/dd')
and
to_date('2003/06/30', 'yy/mm/dd'))


-- 2. Non ci possono essere due aree espositive in cui si verifica lo stesso evento
-- in quanto un evento è legato ad una sola area espositiva e ai suoi slots;

--Verifica: restituire le aree espositive diverse in cui si verifica lo stesso evento con lo stesso codice 
select a.nome, count(*)
from area a join evento e on (e.areaespositiva.nome = a.nome)
where a.nome in (
select e.areaespositiva.nome
from evento e1
where e1.codice = e.codice
)
group by a.nome
having count(*)>1

-- 3. Il numero dei giorni di affitto, per ogni prenotazione, è al massimo uguale
-- al numero dei giorni in cui si svolge un determinato evento. Questo vincolo
-- è motivato anche dal fatto che non ci sarebbe alcun senso prenotare uno o
-- più slot in una data in cui un evento è già finito o non è nemmeno iniziato;

--Verifica: restituire le prenotazioni che hanno un numero di giorni di affitto 
--maggiore della durata dell'evento stesso
select *
from prenotazione p
where p.ngiorniaffitto > 
(
select (e.datafine - e.datainizio)
from prenotazione p2 join evento e on (p2.evento.nome = e.nome)
where p2.cliente.ragsociale = p.cliente.ragsociale
and p2.evento.codice = p.evento.codice
)

-- 4. In una prenotazione, gli slots che sono stati prenotati, devono tutti ap-
-- partenere alla stessa area espositiva in cui si svolge l'evento a cui il cliente
-- vuole partecipare;

-- Verifica: Restituire le prenotazioni i cui slots non appartengono all'area
-- espositiva a cui fanno riferimento
select p.id, p.cliente.ragsociale, value(sl).id
from prenotazione p, table(p.slots) sl
where value(sl).id not in (
select value(sl2).id
from area a, table(a.slots) sl2
where a.nome = p.evento.areaespositiva.nome
)

-- 5. Non possono esistere due o più prenotazioni che affittino lo stesso slot, con-
-- temporaneamente, per un singolo evento. Se uno slot è già stato prenotato
-- questo è occupato;

--Verifica: Restitutire le prenotazioni che hanno gli stessi slot per lo stesso evento
select *
from prenotazione p, table(p.slots) sl
where value(sl).id in (
select value(sl2).id
from prenotazione p2, table(p2.slots)sl2
where p2.id <> p.id
and p2.evento.nome = p.evento.nome
and p2.evento.datainizio = p.evento.datainizio
and p2.evento.datafine = p.evento.datafine
)

-- 6. Un cliente può effettuare più di una prenotazione, per lo stesso evento, col
-- vincolo che gli slots differiscano in ogni prenotazione;

-- Verifica: restituire i clienti che hanno effettuato due o più prenotazioni per lo stesso evento
-- in cui compaiono gli stessi slots

select *
from prenotazione p, table(p.slots) sl
where value(sl).id in(
select value(sl2).id
from prenotazione p2, table(p2.slots) sl2
where p2.evento.nome = p.evento.nome
and p2.cliente.ragsociale = p.cliente.ragsociale
and p2.id <> p.id
)

-- 7. Ogni slot prenotato resta tale fino alla fine dell'evento, non permettendo a
-- nessun altro cliente, di ri-prenotarlo durante un evento.
-- Ciò è valido anche nel caso in cui il primo cliente non nè usufruisca più.

-- Verifica: trovare gli slots che restano inutilizzati pur essendo prenotati
-- Ciò vuol dire che bisogna trovare gli slots di una prenotazione che dura meno 
-- dell'intero periodo dell'evento

select value(sl)
from prenotazione p, table(p.slots)sl
where p.ngiorniaffitto < (
select (e.datafine - e.datainizio)
from evento e
where p.evento.nome = e.nome
)

-- 8. Il prezzo totale dev'essere calcolato sulla singola prenotazione (o più di
-- una) effettuata dallo stesso cliente in questione, per lo stesso evento;

--!! Il vincolo è facilmente verificabile utilizzoando la funzione "PrezTot", il quale
-- calcola tutte le prenotazioni (se più di una), o le singole prenotazioni, di un cliente.
--Es: (Necessita di inserire 2 prenotazioni fatte dallo stesso cliente per lo stesso evento
-- se si vuole verificare che il prezzo totoale comprenda più di una prenotazione).
SET SERVEROUTPUT ON;
select p.PrezTot('Flavio', '12345') as totale
from prenotazione p
where rownum = 1


-- 9. Se per vari motivi uno slot, già prenotato, non venisse reso disponibile al
-- cliente, il prezzo dello stesso sarà decurtato dal prezzo totale;

--Verifica: rimuovere dal prezzo totale il prezzo dello slots non reso più disponibile
-- N.B. La seguente funzione accetta in input la ragione sociale del cliente, il codice
-- evento a cui esso ha partecipato, e il codice dello slot contenente il prezzo da rimuovere
create or replace function modifyTot (rsCliente string, codEvento string, codSlot number) return number 
is 
    totale number(7,2) := 0;
    percentuale number;
    subtotale number(7,2):=0;
begin 
    select p.PrezTot(rscliente, codEvento) into totale
    from prenotazione p
    where rownum = 1;
    for slot in (
    select deref(value(sl)) as ss, p.ngiorniaffitto as giorni
    from prenotazione p, table(p.slots) sl
    where p.cliente.ragsociale = rsCliente
    and p.evento.codice = codEvento
    )
    LOOP
        if slot.ss.id = codSlot
        then
            if slot.ss is of(t_deluxe)
            then
                select TREAT(value(s) as t_deluxe).percentuale into percentuale
                from slots s
                where s.id = slot.ss.id;
                DBMS_OUTPUT.put_line ('Rimuovo dal prezzo dello Slot ID: '||slot.ss.id||' --> Tipo Deluxe €' ||slot.ss.pzgiornaliero||'+'||percentuale||'%');
                subtotale := subtotale + slot.ss.pzgiornaliero;
                subtotale := subtotale + (slot.ss.pzgiornaliero/100)*percentuale;
                totale := totale - (subtotale*slot.giorni);
            else
                DBMS_OUTPUT.put_line ('Rimuovo il prezzo dello Slot ID: '||slot.ss.id||' --> Tipo Standard €'||slot.ss.pzgiornaliero);
                totale := totale - slot.ss.pzgiornaliero;
            end if;
        end if;
    end loop;
    DBMS_OUTPUT.put_line ('Prezzo totale: €'||totale);
    return totale;
end modifyTot;

select modifyTot('Superman', '6789', '9')
from dual;

-- 10. La percentuale di uno slot deluxe deve essere sempre positiva e maggiore
-- di zero, in quanto essa è utile per la maggiorazione del prezzo di affitto
-- del singolo slot;

--Verifica: ricecare lo slot deluxe che ha una pecentuale negativa o uguale a zero.
select s.id, TREAT(value(s) as t_deluxe).percentuale as percentuale
from slots s
where value(s) is of type(t_deluxe)
and TREAT(value(s) as t_deluxe).percentuale<=0;


-- 11. L'inserimento di tutti i dati dev'essere corretto, specialmente quando si
-- inseriscono informazioni quali la data di inizio e la data di fine di un evento
-- dove quest'ultima dev'essere cronologicamente successiva (in termini di
-- giorno, mese ed anno), o al massimo uguale, rispetto alla data di inizio.

-- Verifica: Restituire tutti gli eventi la cui data inizio è maggiore di data fine
select *
from evento e
where e.datainizio > e.datafine


-- 12. E' importante specificare un numero positivo per le seguenti informazioni:
-- Numero dei visitatori in un'area espositiva, Dimensione di uno slot, Nu-
-- mero dei giorni in affitto in ogni prenotazione;

--Verifica: Restituire l'area che ha un numero negativo di visitatori:
select a.nome
from area a
where a.numvisitatori < 0;

--Verifica: restituire lo slot che ha una dimensione negativa:
select s.id
from slots s
where s.dimensione <0;

--Verifica: restitutire la prenotazione che ha un numero di giorni negativo:
select p.id
from prenotazione p
where p.ngiorniaffitto<0;


-- 13. Per poter identificare la posizione di uno slot, entrambe le sue coordinate
-- devono essere inserite. I valori che possono assumere possono essere sia
-- positivi che negativi;

--Verifica: restituire gli slots a cui manca una delle due coordinate:
select *
from slots s
where s.coordinatax is null 
or s.coordinatay is null


-- 14.Due slots, appartenenti alla stessa area, non possono avere delle coordinate uguali, 
-- in quanto devono essere istanti o affiancati;

--Verifica: restituire gli slots appartenenti alla stessa area, che hanno le stesse coordinate
select value(sl).id, value(sl).coordinatax, value(sl).coordinatay
from area a, table(a.slots) sl
where value(sl).coordinatax in (
    select value(sl2).id
    from area a2, table(a2.slots) sl2
    where a2.nome = a.nome
    and value(sl2).id <> value(sl).id
)
and value(sl).coordinatay in(
    select value(sl3).id
    from area a3, table(a3.slots) sl3
    where a3.nome = a.nome
    and value(sl3).id <> value(sl).id
)


--15. Gli eventi si differenziano solo per il proprio codice, pertanto ci potreb-
-- bero essere eventi con lo stesso nome che potrebbero essere svolti in aree
-- espositive diverse, con date uguali, o diverse. Questa informazione è utile
-- per l'utilizzo della funzione CheckSlots (spiegata nei prossimi paragrafi),
-- situata nella classe Evento nello schema UML, la quale va a ricercare la
-- disponibilità degli slots appartenenti ad un evento, andando a inserire in
-- input parametri quali il codice dell'evento e la data in cui esso si è tenuto.

--Verifica: restituire un evento se e solo se esiste un altro evento avente codice e nome uguale:
select e.nome, e.codice, count(*)
from evento e
group by e.nome, e.codice
having count(*)>1;


-- 16: Un evento, che abbia lo stesso nome uguale ad un altro, può ripetersi in
-- un'area espositiva con il vincolo che abbia un identificativo diverso;

--Verifica: Restituire gli eventi con nome uguale, data diversa e identificativo uguale, 
-- che si svolgono nella stessa area espositiva:

select e.nome, count(*)
from evento e
where e.datainizio <> (
    select e2.datainizio
    from evento e2
    where e2.nome = e.nome
    and e2.codice = e.codice
    and e2.areaespositiva.nome = e.areaespositiva.nome
)
or e.datafine <> (
    select e3.datainizio
    from evento e3
    where e3.nome = e.nome
    and e3.codice = e.codice 
    and e3.areaespositiva.nome = e.areaespositiva.nome
)
group by e.nome
having count(*)>1


-- 17. L'area preferita di un cliente esiste se e solo se fra le prenotazioni compare uno slot che appartiene a tale area;

--Verifica: restituire l'area preferita di un cliente i cui slots non compaiono nelle prenotazioni
select c.ragsociale, c.areapreferita.nome
from cliente c, table(c.areapreferita.slots) sl
where value(sl).id not in(
select value(sl).id
from prenotazione p, table(p.slots) sl2
)
group by c.ragsociale, c.areapreferita.nome

-- 18. Le aree richieste in passato dal cliente esistono se e solo se esistono fra le prenotazioni degli slots 
-- appartenenti a tali aree espositive.

--Verifica: Restituire le aree richieste in passato, di un cliente, i cui slots non compaiono nelle prenotazioni
select c.ragsociale, value(av).nome
from cliente c, table(c.areevisitate) av, table(value(av).slots) sl
where value(sl).id not in(
    select value(slp).id
    from prenotazione p, table(p.slots) slp
    where p.cliente.ragsociale = c.ragsociale
);

 








