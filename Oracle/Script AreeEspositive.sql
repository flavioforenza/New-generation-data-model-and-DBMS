-- creo il tipo locazione
create or replace type t_locazione as object(
Indirizzo varchar(30),
Citta varchar(30),
Paese varchar(30)
)
/

-- creo il tipo facilities
create or replace type t_facilities as object(
    tipologia varchar(30)
)
/

create type set_facilities as table of t_facilities;
/

-- creo il tipo slot
create or replace type t_slots as object(
    id integer,
    dimensione numeric(8,2),
    pzGiornaliero numeric(8,2),
    coordinataX numeric(4,2),
    coordinataY numeric(4,2)
)not final;
/

--creo slots standard e deluxe
create or replace type t_deluxe under t_slots(
    percentuale numeric(5,2)
    );
/

create or replace type t_standard under t_slots(
    listaFacilities set_facilities
    );
/

create or replace type set_slots as table of ref t_slots;
/

--creo l'Area Espositiva
create or replace type t_area as object(
    nome varchar(30),
    Locazione t_locazione,
    NumVisitatori number(5,2),
    slots set_slots
)
/

create type set_id as table of number;
/

create or replace type check_slots as object(
    Data date,
    liberi set_id,
    occupati set_id
);
/

create or replace type set_check_slots as table of check_slots;
/

--creo l'evento
create or replace type t_evento as object(
    nome varchar(30),
    codice varchar(30),
    DataInizio date,
    DataFine date,
    AreaEspositiva ref t_area,
    member function CheckSlots (CodEvento string, data date) return set_check_slots
)
/

create or replace type set_area as table of ref t_area;
/

--creo il cliente
create or replace type t_cliente as object(
    ragSociale varchar(30),
    telefono varchar(10),
    AreaPreferita ref t_area,
    AreeVisitate set_area
)
/

-- creo le prenotazioni
create or replace type t_prenotazione as object(
    id varchar(10),
    Cliente ref t_cliente,
    NGiorniAffitto number(5,2),
    Evento ref t_evento,
    Slots set_slots,
    member function PrezTot (rsCliente string, codEvento string) return number
)
/

-- CREAZIONE DELLE TABELLE

--creo la tabella
create table Slots of t_slots(
    primary key(id)
    );
/

-- creo la tabella area
create table Area of t_area(
    primary key(nome)
)
nested table slots store as tab_slots
/

--creo la tabella evento
create table Evento of t_evento(
    primary key(codice)
)
/

--creo la tabella cliente
create table Cliente of t_cliente(
    primary key(ragSociale)
)
nested table AreeVisitate store as tab_areevisitate;
/

--creo la tabella prenotazione
create table Prenotazione of t_prenotazione(
primary key(id)
)
nested table Slots store as tab_slotsP
/

---------------------------------- EFFETTUO GLI INSERIMENTI ----------------------------------

--Inserisco alcuni slots
insert into slots values(t_deluxe(04, 50, 80, 14, 14, 10));
insert into slots values(t_deluxe(05, 50, 80, 15, 15, 10));
insert into slots values(t_deluxe(07, 50, 80, 15, 15, 10));
insert into slots values(t_deluxe(09, 50, 80, 14, 14, 10));
insert into slots values(t_deluxe(10, 50, 80, 15, 15, 10));
insert into slots values(t_deluxe(13, 50, 80, 15, 15, 10));
insert into slots values(t_deluxe(14, 50, 80, 14, 14, 10));
insert into slots values(t_deluxe(15, 50, 80, 15, 15, 10));
insert into slots values(t_deluxe(16, 50, 80, 15, 15, 10));
insert into slots values(t_deluxe(17, 50, 80, 15, 15, 10));
insert into slots values(t_deluxe(18, 40, 80, 15, 15, 10));
insert into slots values(t_deluxe(19, 40, 80, 15, 15, 10));

insert into slots values(t_standard(01, 20, 30, 11, 11,set_facilities()));
insert into slots values(t_standard(02, 20, 30, 12, 12, set_facilities()));
insert into slots values(t_standard(03, 20, 30, 13, 13, set_facilities()));
insert into slots values(t_standard(06, 20, 30, 13, 13, set_facilities()));
insert into slots values(t_standard(11, 20, 30, 13, 13, set_facilities()));
insert into slots values(t_standard(12, 20, 30, 13, 13, set_facilities()));

--inserisco le aree
insert into area values('Elettronica', null, 50, set_slots());
insert into area values('Disco', null, 60, set_slots());

--popolo gli slots delle aree precedenti
insert into table(select slots from area where nome = 'Elettronica')
select ref(s) from slots s where s.id IN (01,02,03,04,05); 

insert into table(select slots from area where nome = 'Disco')
select ref(s) from slots s where s.id IN (09,10,11,12); 

--creo degli eventi
insert into evento values('House', 'CCH123', to_date('2003/06/15', 'yy/mm/dd'), to_date('2003/06/18', 'yy/mm/dd'), null);
insert into evento values('Apple', '12345', to_date('2003/06/28', 'yy/mm/dd'), to_date('2003/06/30', 'yy/mm/dd'), null);
insert into evento values('Ibiza', '6789', to_date('2003/06/01', 'yy/mm/dd'), to_date('2003/06/05', 'yy/mm/dd'), null);

--associo le aree espositive agli eventi
update evento
set areaespositiva = (select ref(a) from area a where a.nome = 'Elettronica')
where nome = 'House';

update evento
set areaespositiva = (select ref(a) from area a where a.nome = 'Elettronica')
where nome = 'Apple';

update evento
set areaespositiva = (select ref(a) from area a where a.nome = 'Disco')
where nome = 'Ibiza';

--creo un cliente
insert into cliente values('qwe11', '3234567890', null, set_area());
insert into cliente values('Flavio', '3234167890', null, set_area());
insert into cliente values('Superman', '3234567890', null, set_area());

--creo una prenotazione effettuata dal cliente 'qwe11' per l'evento 'House'
insert into prenotazione
select 1, ref(c), 3, ref(e), set_slots()
from cliente c, evento e
where c.ragSociale = 'qwe11' and e.codice = 'CCH123';

insert into prenotazione
select 2, ref(c), 3, ref(e), set_slots()
from cliente c, evento e
where c.ragSociale = 'Flavio' and e.codice = 'CCH123';

insert into prenotazione
select 3, ref(c), 2, ref(e), set_slots()
from cliente c, evento e
where c.ragSociale = 'Flavio' and e.codice = '12345';

insert into prenotazione
select 4, ref(c), 4, ref(e), set_slots()
from cliente c, evento e
where c.ragSociale = 'Superman' and e.codice = '6789';

insert into prenotazione
select 5, ref(c), 2, ref(e), set_slots()
from cliente c, evento e
where c.ragSociale = 'qwe11' and e.codice = '12345';

--inserisco gli slots alle prenotazioni
insert into table(select p.slots from prenotazione p where p.cliente.ragSociale = 'qwe11' and p.evento.codice = 'CCH123')
select ref(s) from slots s where s.id IN(01,02,05);

insert into table(select p.slots from prenotazione p where p.cliente.ragSociale = 'Flavio' and p.evento.codice = 'CCH123')
select ref(s) from slots s where s.id = 04;

insert into table(select p.slots from prenotazione p where p.cliente.ragSociale = 'Flavio' and p.evento.codice = '12345')
select ref(s) from slots s where s.id = 01;

insert into table(select p.slots from prenotazione p where p.cliente.ragSociale = 'Superman' and p.evento.codice = '6789')
select ref(s) from slots s where s.id IN(09,11);

insert into table(select p.slots from prenotazione p where p.cliente.ragSociale = 'qwe11' and p.evento.codice = '12345')
select ref(s) from slots s where s.id = 04;


-----------------------------------------------------------------------------------------------------------------------------------

-- Funzione per il calcolo del prezzo totale (In prenotazione)
create or replace type body t_prenotazione
as
    member function PrezTot (rsCliente string, codEvento string) return number
is
    totale number(7,2) :=0;
    percentuale number;
    numGiorni number :=0;
begin
    DBMS_OUTPUT.put_line ('--- Prenotazioni del cliente '||rsCliente || ' ---');
    for slot in (
    select deref(value(sl)) as ss, p.ngiorniaffitto as giorni
    from prenotazione p, table(p.slots) sl
    where p.cliente.ragsociale = rsCliente
    and p.evento.codice = codEvento
    )
    LOOP
        if slot.ss is of(t_deluxe)
        then
            select TREAT(value(s) as t_deluxe).percentuale into percentuale
            from slots s
            where s.id = slot.ss.id;
            DBMS_OUTPUT.put_line ('Slot ID: '||slot.ss.id||' --> Tipo Deluxe €' ||slot.ss.pzgiornaliero||'+'||percentuale||'%');
            totale := totale + slot.ss.pzgiornaliero;
            totale := totale + (slot.ss.pzgiornaliero/100)*percentuale;
        else
            DBMS_OUTPUT.put_line ('Slot ID: '||slot.ss.id||' --> Tipo Standard €'||slot.ss.pzgiornaliero);
            totale := totale + slot.ss.pzgiornaliero;
        end if; 
        numGiorni := slot.giorni;
    end loop;
    totale := totale * numGiorni;
    DBMS_OUTPUT.put_line ('Numero giorni affitto: ' || numGiorni);
    DBMS_OUTPUT.put_line ('Prezzo totale: €'||totale);
    return totale;
    end PrezTot;
end;
/
--Query per ritrovare il prezzo totale di un cliente (es: 'qwe11') specificando l'identificativo di un evento (es: 'CCH123')
SET SERVEROUTPUT ON;
select p.PrezTot('qwe11', 'CCH123') as totale
from prenotazione p
where rownum = 1

------------------------------------------------------------------------------------------------------------------------------------
-- RICERCA DEGLI SLOTS LIBERI E OCCUPATI
/
--PACKAGE (serve per la funzione sotto in quanto viene richiamata)
create or replace package p_check_slot as
    function get_slots_liberi(CodEvento string, data date) RETURN set_id;
    function get_slots_occupati(CodEvento string, data date) RETURN set_id;
end p_check_slot;
/

--creazione del corpo del package
create or replace package body p_check_slot as
    FUNCTION get_slots_liberi(CodEvento string, data date) 
    RETURN set_id
    IS slots_liberi set_id;
    BEGIN
        select value(sl).id bulk collect into slots_liberi
        from evento p1, table(p1.areaespositiva.slots) sl
        where (p1.codice = CodEvento and value(sl).id not in(
        select value(sl1).id
        from prenotazione p, table(p.slots) sl1))
        and (data between p1.datainizio and p1.datafine);
        RETURN slots_liberi;
    end get_slots_liberi;
    FUNCTION get_slots_occupati(CodEvento string, data date) 
    RETURN set_id
    IS slots_occupati set_id;
    BEGIN
        select value(sl).id bulk collect into slots_occupati
        from evento p1, table(p1.areaespositiva.slots) sl
        where (p1.codice = CodEvento and value(sl).id in(
        select value(sl1).id
        from prenotazione p, table(p.slots) sl1))
        and (data between p1.datainizio and p1.datafine);
        RETURN slots_occupati;
    end get_slots_occupati; 
end p_check_slot;

/
--FUNZIONE utile per richiamare il package sopra in ogni evento
create or replace type body t_evento 
as
    member function CheckSlots(CodEvento string, data date) RETURN set_check_slots
is    
    numberID set_check_slots;
begin
    DBMS_OUTPUT.put_line ('Informazioni sugli slot relativi all evento: '|| CodEvento || ' in data: ' ||data);
    for el in(
    select p_check_slot.get_slots_liberi(CodEvento,data) as lib, 
    p_check_slot.get_slots_occupati(CodEvento,data) as occ
    from dual)
    Loop
    if el.occ is not null
    then
    DBMS_OUTPUT.put_line ('Slots occupati:' );   
        for i in 1..el.occ.count()
        Loop
            DBMS_OUTPUT.put_line ('ID: '||el.occ(i));
        end loop;
    else
    DBMS_OUTPUT.put_line ('Tutti gli slots sono liberi.');
    end if;
    
    if el.lib is not null
    then
    DBMS_OUTPUT.put_line ('Slots liberi:' );   
        for i in 1..el.lib.count()
        Loop
            DBMS_OUTPUT.put_line ('ID: ' || el.lib(i));
        end loop;
    else
    DBMS_OUTPUT.put_line ('Tutti gli slots sono occupati.');
    end if;
    end Loop;
    
    select check_slots(data, pp.lib, pp.occ) bulk collect into numberID
    from(
    select P_check_slot.get_slots_liberi(CodEvento,data) as lib, p_check_slot.get_slots_occupati(CodEvento,data) as occ
    from dual
    )pp;
    return numberID;
    end CheckSlots;
end;
/

--query per ritrovare gli slots
SET SERVEROUTPUT ON;
select value(llv).data as Data, value(SlotLiberi), value(SlotOccupati)
from evento e, table(e.CheckSlots('CCH123', to_date('2003/06/15', 'yy/mm/dd'))) llv,
    table(value(llv).liberi) SlotLiberi, table(value(llv).occupati) SlotOccupati
where e.codice = 'CCH123';









