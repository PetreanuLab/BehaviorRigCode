function [sessid, sessstr]=getSessions(rat,op)

if ~op
	% get all experimenters
	sql='select sessid, sessiondate, n_done_trials,total_correct  from sessions where ratname="{S}" order by sessiondate desc';
	[sessid, sessdate,nt, pc]=bdata(sql,rat);
else
	sql='select sessid, sessiondate, n_done_trials,total_correct  from sessions where ratname="{S}" and sessid in (select distinct(sessid) from cells) order by sessiondate desc';

	[sessid, sessdate, nt, pc]=bdata(sql,rat);
end	
if ~isempty(sessid)
for sx=1:numel(sessid)
	sessstr{sx}=sprintf('%s,   \t%d,    \t%.3g%%',sessdate{sx}, nt(sx), 100*pc(sx)); %#ok<AGROW>
end

else
	sessstr='';

end