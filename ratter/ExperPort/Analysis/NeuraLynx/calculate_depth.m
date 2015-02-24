rats=bdata('select distinct ratname from ratinfo.turn_down_log');

for rx=1:numel(rats)
    
    rat=rats{rx};
    
    [id, turn_date, turn_time, turn]=bdata('select id, turn_date, turn_time, turn from ratinfo.turn_down_log where ratname="{S}" order by turn_date, turn_time',rat);
    depth=cumsum(turn);
    
    for tx=1:numel(id)
        mym(bdata,'update ratinfo.turn_down_log set depth="{S}" where id="{S}"',depth(tx)*0.3175, id(tx))
    end
end