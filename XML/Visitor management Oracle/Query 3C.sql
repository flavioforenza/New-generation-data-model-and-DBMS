--Query esercizio 3c
create or replace view Final as(
    select xmltab."Evento" as evento, xmltab."Slot" as slot, 
    sum(xmltab."Passaggi") as pass, 
    sum(xmltab."Rating") as rat
    from visitatori v, table(v.visite) vs, evento even, XMLTABLE(
    '   
        let $ev := /Visita[@Evento=$NomeEvento]
        let $slots := distinct-values($ev/Slots/Slot/@id)
        let $master :=(
            <SingoloEvento>
                {
                    for $slot in $slots
                        return
                        <SingoloSlot>
                            <Evento>{$ev/@Evento}</Evento>
                            <Id>{$slot}</Id>
                            <NumPassaggi>{$ev//Slot[@id=$slot]/NumPassaggi}</NumPassaggi>
                            <Rating>{count($ev/Slots/Slot[@id =$slot]/Voto="MiPiace")}</Rating>
                        </SingoloSlot>
                }
            </SingoloEvento>
        )
        
        let $multiSlot := $master//SingoloSlot
        
        return
        $multiSlot
    '
        passing value(vs), even.nome as "NomeEvento"
        columns
        "Evento" varchar(50) path '//SingoloSlot/Evento/@Evento',
        "Slot" varchar(50) path '//SingoloSlot/Id',
        "Passaggi" number path '//SingoloSlot/NumPassaggi',
        "Rating" number path '//SingoloSlot/Rating'    
    )xmltab
    group by xmltab."Evento", xmltab."Slot"
);

--slots preferito per ogni evento
select evento, slot, pass, rat 
from final v1 
where pass in ( 
  select max(pass) 
  from final v2 
  where  v1.evento = v2.evento
) 

--Evento con il max pass
select evento, slot, max(pass), rat
from final
group by evento, slot, rat
having max(pass)>=ALL(
select max(pass)
from final
);