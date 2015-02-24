function [x]=getRats(expr,op)

if ~op
	% get all experimenters
	
	[recent_rats]=bdata('select distinct(ratname) from sessions where experimenter="{S}" and sessiondate>date_sub(now(),interval 6 day) order by ratname',expr);
	ratname=bdata('select ratname from ratinfo.rats where experimenter="{S}"',expr);
	keeps=zeros(size(ratname))==1;
	for rx=1:numel(ratname)
		if isempty(ratname{rx}) || ~isempty(regexp(ratname{rx}(1),'[0-9]'))
			keeps(rx)=false;
		else
			sessid=bdata('select sessid from sessions where ratname="{S}" limit 1',ratname{rx});
			if isempty(sessid)
				keeps(rx)=false;
			else
				keeps(rx)=true;
			end
		end
	end
	
	
	
	all_rats=ratname(keeps);
	
	
	old_rats=setdiff(all_rats, recent_rats);
	x=[recent_rats; old_rats];
	
else
	[s,x]=bdata('select max(sessiondate) as a, ratname from sessions where experimenter="{S}" and sessid in (select distinct(sessid) from spktimes) group by ratname order by a desc, ratname',expr);
end