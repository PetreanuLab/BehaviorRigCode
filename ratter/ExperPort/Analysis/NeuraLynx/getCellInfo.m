function [cstr]=getCellInfo(cellid)

[  sc_num,   cluster ,  single,   nSpikes ,  quality ,  overlap ,  iti_mn ,  iti_sd ,  trial_mn ,  trial_sd , filename]=bdata('select    sc_num,   cluster ,  single,   nSpikes ,  quality ,  overlap ,  iti_mn ,  iti_sd ,  trial_mn ,  trial_sd , filename from cells where cellid="{Si}"',cellid);
	
if isempty(sc_num)
	cstr='Sorry No cells here';
else
cstr=sprintf(['CellID: %i\nAD_Channel: %i\nCluster #: %i\nSingle? %i\n'...
	'# of Spikes: %i\nQuality: %i;\t  Overlap: %f\nBackround rate %.2f +/- %.2f Hz\n'...
	'Trial Rate %.2f +/- %.2f Hz\n Filename:\n%s'],...
	 cellid, sc_num,   cluster ,  single,   nSpikes ,  quality ,  overlap ,  iti_mn ,  iti_sd ,  trial_mn ,  trial_sd , filename{1});
end