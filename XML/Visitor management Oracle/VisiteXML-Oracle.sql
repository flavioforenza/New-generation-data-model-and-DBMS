create or replace type set_visite as table of XMLTYPE;
/
create table Visitatori(
    nome varchar(30),
    cognome varchar(30),
    email varchar(50),
    visite set_visite,
    primary key(email)
)
nested table visite store as tab_visite;
/

insert into Visitatori values('Flavio', 'Forenza','io@hotmail.it',set_visite());
insert into Visitatori values('Valerio', 'Ricci','valric@gmail.com',set_visite());
insert into Visitatori values('Will', 'Smith','willsmith@hotmail.it',set_visite());

insert into table(select v.visite from Visitatori v where v.email='io@hotmail.it')
select xmltype.createxml('<?xml version="1.0" encoding="utf-8"?>
<Visita xsi:noNamespaceSchemaLocation="schema.xsd" Id="123" Evento="Apple" Giorno="2001-10-05" Entrata="12:28:30.68" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <Slots>
    <Slot id="sl123">
      <Nome>string</Nome>
      <Tipo>standard</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>30</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>MiPiace</Voto>
    </Slot>
    <Slot id="sl124">
      <Nome>string</Nome>
      <Tipo>deluxe</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>12</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>MiPiace</Voto>
    </Slot>
    <Slot id="sl125">
      <Nome>string</Nome>
      <Tipo>standard</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>22</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>Indifferente</Voto>
    </Slot>
  </Slots>
  <Percorso>
    <Slot ref="sl123">
      <OraEntrata>11:11:13.55</OraEntrata>
      <OraUscita>00:21:01.71</OraUscita>
      <TempoTrascorso>11:55:18.86</TempoTrascorso>
    </Slot>
    <Slot ref="sl124">
      <OraEntrata>16:00:47.63</OraEntrata>
      <OraUscita>05:01:07.25</OraUscita>
      <TempoTrascorso>11:55:18.86</TempoTrascorso>
    </Slot>
  </Percorso>
</Visita>

'
)
from dual;

insert into table(select v.visite from Visitatori v where v.email='valric@gmail.com')
select xmltype.createxml('<?xml version="1.0" encoding="utf-8"?>
<Visita xsi:noNamespaceSchemaLocation="schema.xsd" Id="123" Evento="Apple" Giorno="2001-10-05" Entrata="12:28:30.68" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <Slots>
    <Slot id="sl123">
      <Nome>string</Nome>
      <Tipo>standard</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>3</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>MiPiace</Voto>
    </Slot>
    <Slot id="sl124">
      <Nome>string</Nome>
      <Tipo>deluxe</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>18</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>MiPiace</Voto>
    </Slot>
    <Slot id="sl125">
      <Nome>string</Nome>
      <Tipo>standard</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>23</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>Indifferente</Voto>
    </Slot>
    <Slot id="sl126">
      <Nome>string</Nome>
      <Tipo>standard</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>230</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>Indifferente</Voto>
    </Slot>
  </Slots>
  <Percorso>
    <Slot ref="sl123">
      <OraEntrata>11:11:13.55</OraEntrata>
      <OraUscita>00:21:01.71</OraUscita>
      <TempoTrascorso>11:55:18.86</TempoTrascorso>
    </Slot>
    <Slot ref="sl124">
      <OraEntrata>16:00:47.63</OraEntrata>
      <OraUscita>05:01:07.25</OraUscita>
      <TempoTrascorso>11:55:18.86</TempoTrascorso>
    </Slot>
  </Percorso>
</Visita>

'
)
from dual;

insert into table(select v.visite from Visitatori v where v.email='willsmith@hotmail.it')
select xmltype.createxml('<?xml version="1.0" encoding="utf-8"?>
<Visita xsi:noNamespaceSchemaLocation="schema.xsd" Id="456" Evento="House" Giorno="2001-10-05" Entrata="12:28:30.68" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <Slots>
    <Slot id="sl11">
      <Nome>string</Nome>
      <Tipo>standard</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>39</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>MiPiace</Voto>
    </Slot>
    <Slot id="sl12">
      <Nome>string</Nome>
      <Tipo>deluxe</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>6</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>MiPiace</Voto>
    </Slot>
    <Slot id="sl13">
      <Nome>string</Nome>
      <Tipo>standard</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>9</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>Indifferente</Voto>
    </Slot>
    <Slot id="sl14">
      <Nome>string</Nome>
      <Tipo>standard</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>20</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>Indifferente</Voto>
    </Slot>
  </Slots>
  <Percorso>
    <Slot ref="sl11">
      <OraEntrata>11:11:13.55</OraEntrata>
      <OraUscita>00:21:01.71</OraUscita>
      <TempoTrascorso>11:55:18.86</TempoTrascorso>
    </Slot>
    <Slot ref="sl14">
      <OraEntrata>16:00:47.63</OraEntrata>
      <OraUscita>05:01:07.25</OraUscita>
      <TempoTrascorso>11:55:18.86</TempoTrascorso>
    </Slot>
  </Percorso>
</Visita>

'
)
from dual;


insert into table(select v.visite from Visitatori v where v.email='willsmith@hotmail.it')
select xmltype.createxml('<?xml version="1.0" encoding="utf-8"?>
<Visita xsi:noNamespaceSchemaLocation="schema.xsd" Id="400" Evento="House" Giorno="2001-10-05" Entrata="12:28:30.68" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
   <Slots>
    <Slot id="sl11">
      <Nome>string</Nome>
      <Tipo>standard</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>18</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>MiPiace</Voto>
    </Slot>
    <Slot id="sl12">
      <Nome>string</Nome>
      <Tipo>deluxe</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>6</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>MiPiace</Voto>
    </Slot>
    <Slot id="sl13">
      <Nome>string</Nome>
      <Tipo>standard</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>19</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>Indifferente</Voto>
    </Slot>
    <Slot id="sl14">
      <Nome>string</Nome>
      <Tipo>standard</Tipo>
      <TipoProdottiEsposti>string</TipoProdottiEsposti>
      <NumPassaggi>26</NumPassaggi>
      <NomeAzineda>string</NomeAzineda>
      <Voto>Indifferente</Voto>
    </Slot>
  </Slots>
  <Percorso>
    <Slot ref="sl11">
      <OraEntrata>11:11:13.55</OraEntrata>
      <OraUscita>00:21:01.71</OraUscita>
      <TempoTrascorso>11:55:18.86</TempoTrascorso>
    </Slot>
    <Slot ref="sl14">
      <OraEntrata>16:00:47.63</OraEntrata>
      <OraUscita>05:01:07.25</OraUscita>
      <TempoTrascorso>11:55:18.86</TempoTrascorso>
    </Slot>
  </Percorso>
</Visita>

'
)
from dual;



