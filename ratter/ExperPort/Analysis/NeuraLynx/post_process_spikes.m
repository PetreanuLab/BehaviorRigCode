function err=post_process_spikes(sessid,force)

if nargin<2
	force=0;
end

already_done=bdata('select count(overlap) from cells where sessid="{S}"',sessid);
if already_done
	if ~force
		err=0;
		return;
	end
end

[cellid,ts]=bdata('select cellid,ts from spktimes where sessid="{S}"',sessid);

for cx=1:numel(cellid)
	
	isi=diff(ts{cx})*1e3;  % get isi in ms
	num_low_isi=sum(isi<1);
	frac_bad=num_low_isi/numel(isi);
	
	% if we could get some info from the protocol about what to align on
	% then we could calculate background and trial activity, etc.  but
	% without some info... very hard.  We could ask all protocols to
	% have a function that returns this info..... hrm.
	overlap=0;
	for icx=1:numel(cellid)
		if icx==cx
			%skip this
		else
			c_overlap=numel(intersect(ts{cx},ts{icx}));
			overlap=max(overlap,c_overlap);
		end
	end
	overlap=overlap/numel(ts{cx});
	
	mym(bdata,'update cells set overlap="{S}", frac_bad_isi="{S}" where cellid="{S}"', overlap, frac_bad, cellid(cx));
	
	
	
end

	