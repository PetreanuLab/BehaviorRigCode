function [x]=getExperimenters(op)

if ~op
	% get all experimenters
	
	x=bdata('select distinct(experimenter) from sessions order by experimenter');
else
	x=bdata('select distinct(experimenter) from sessions where sessid in (select distinct(sessid) from spktimes) order by experimenter');
end	