function fh=summary_plot(cellid, varargin)
% summary_plot(cellid, varargin)
% pairs={'align_on'       '';...
% 	'correct_only'   0;...
% 	'noviol_only'    1; ...
%     'mem_only'       0; ...
%     'by_sounds'      0;
% 	'main_sort'      'sides';...
% 	'plot_isi'       1;...
% 	'plot_raster'    1;...
% 	'plot_wave'      1;...
% 	'plot_hv'        1;...  % plot head velocity
% 	'bin_size'       0.01;...
% 	'krn'            [];...
% 	'pre'            +3;...
% 	'post'           +3;...
% 	'print_flag'     0;...
% 	'save_flag'      0;...
% 	}; parseargs(varargin, pairs);

pairs={'align_on'       '';...
	'correct_only'   0;...
	'noviol_only'    1; ...
    'mem_only'       0; ...
    'by_sounds'      0;
	'main_sort'      'sides';...
	'plot_isi'       1;...
	'plot_raster'    1;...
	'plot_wave'      1;...
	'plot_hv'        1;...  % plot head velocity
	'bin_size'       0.01;...
	'krn'            [];...
	'pre'            +3;...
	'post'           +3;...
	'print_flag'     0;...
	'save_flag'      0;...
	
	}; parseargs(varargin, pairs);

fh=figure;
set(fh,'Position',[100 100 850*.7 1000*.7])
if print_flag==1
	set(fh,'Renderer','painters');
else
	set(fh,'Renderer','opengl');
end

if numel(cellid)>1
	for cx=1:numel(cellid)
		try
			if nargin>1
				fh=summary_plot(cellid(cx));
				pause(1);
				close(fh);
				pause(0.1);
				fh=0;
			else
				fh(cx)=summary_plot(cellid(cx));
				%                 pause(0.1);
				%                 close(fh(cx));
			end
		catch
			showerror
			sprintf('Failed to plot cell %d\n',cellid(cx))
		end
	end
else
	
	[sessid,ts,waves]=bdata('select sessid, ts, wave from spktimes where cellid="{S}"',cellid);
if isempty(sessid)
    fprintf(2,'Cell %d was not found',cellid);
    close(fh);
    fh=[];
    return;
end
    ts=ts{1};
	[ratname]=bdata('select ratname from sessions where sessid="{S}"',sessid);
	
	ia=axes('Position',[0.05 0.97 1 1]);
	set(ia,'Visible','off');
	make_title(cellid,sessid);
	
	%% Create the ISI plot
	if plot_isi
		isi=diff(ts);
		bins=-4:0.1:1.5;
		axisi=axes('Position',[0.8 0.8 0.16 0.13]);
		hist(axisi,log10(isi),bins);
		xlabel('ISI (log_{10} secs)')
		ylabel('Frequency');
		xlim([min(bins) max(bins)]);
		set(axisi, 'XTick', [-3 -2 -1 0]);
		set(axisi, 'TickDir','out');
		set(axisi, 'TickLength',[0.025 0.2]);
		set(axisi, 'Box','off');
		
	end
	
	%% Create the waveplot
	
	if plot_wave
		axwave=axes('Position',[0.8 0.57 0.15 0.12]);
		waveplot(waves{1}, {'k', axwave,0.8});
		xlim([1 150]);
	end
	
	%% show cell info
	axinfo=axes('Position',[0.7 0.4 0.3 0.3]);
	th=text(0,0,getCellInfo(cellid));
	set(axinfo,'Visible','off');
	set(th,'Interpreter','none');
	
	%% set up the reference time and conditions
	
	peh=get_peh(sessid);		% get the parsed_events
	
	[ref,align_string]=get_ref_event(sessid,peh,align_on);
	
	%% head velocity plot
	if plot_hv,
		try
			[timestamps theta] = bdata('select ts, theta from tracking where sessid="{S}"',sessid);
			timestamps=timestamps{1}; timestamps = timestamps(1:end-1);
			hv_height = 0.14;
		catch
			fprintf(2, 'Head tracking info not available for session %d\n', sessid);
			plot_hv = 0;
			hv_height = 0;
		end;
	else
		hv_height = 0;
	end;
	raster_height = 0.8 - hv_height;
	raster_corner = [0.1 0.1+hv_height+0.08*hv_height];
	
	% By default we are sorting on sides and hit/miss
	% We assume that there is a sides field in the protocol data and a hits
	% field.
	
	[ref, condition, legend_str]=get_conditions(sessid, ref, peh, correct_only, noviol_only, by_sounds,mem_only);
	
	
	%% make the call to rasterC
	%
	gd_trials=ref>ts(1);
	ref=ref(gd_trials);  % This ignores trials before recording started. in a hacky way
	condition=condition(gd_trials);					 % jce
						 
	rh=exampleraster(ref,ts,'ref_label',align_string, ...
		'cnd', condition, ...
		'legend_str',legend_str, ...
		'renderer',get(fh,'Renderer'), ...
		'pre', pre, 'post', post, ...
		'total_height', raster_height, ...
		'corner', raster_corner);
	
	
	
	%% call rasterHV to plot the head velocity info
	if plot_hv,
		set(rh(end),'XTickLabel',{});
		theta_dot = headvelocity(timestamps, theta{1});
		rh(end+1)=rasterHV(ref, timestamps, theta_dot, 'cnd', condition, ...
			'ref_label',align_string, ...
			'pre', pre, 'post', post, ...
			'legend_on', 0, ...
			'renderer', get(fh, 'Renderer'), ...
			'ax_height', hv_height);
	end;
    
    linkaxes(rh,'x');

		%% Print
	fh=gcf;
	if print_flag
		set(gcf,'PaperPosition',[0.25 0.25 8 9])
		print -dpsc2 -painters
	end
	
	%% Save
	if save_flag
		set(gcf,'PaperPosition',[0.25 0.25 8 9]);
		saveas(gcf,[ratname{1} '_' num2str(cellid) '.pdf']);
	end
	
	
	end



function th=make_title(cellid,sessid)
[rat, day, protocol]=bdata('select ratname, sessiondate,protocol from sessions where sessid="{S}"',sessid);
title_str=sprintf('%s, Cell %d, %s, %s', rat{1}, cellid, day{1}, protocol{1});
th=text(0,0,title_str);
set(th,'FontSize',18);

function [ref,align_string]=get_ref_event(sessid,peh,align_on)
if isempty(align_on)      % get the reference event
	align_string=align_str(sessid);
	ref=extract_alignment(sessid,align_string,peh);
elseif strcmp(align_on,'DO')
	%     s_time=extract_event(peh,'cpoke1(end,end)');
	%     e_time=extract_event(peh,'wait_for_spoke(end,end)');
	%     cout=extract_event(peh,'C',2);
	ref=zeros(numel(peh),1);
	for rx=1:numel(ref)
		couts=peh(rx).pokes.C(:,2);
		if ~isempty(peh(rx).states.wait_for_spoke) && ~isempty(couts) && ~isempty(peh(rx).states.cpoke1)
			e_time=peh(rx).states.wait_for_spoke(end,end);
			ref(rx)=max(couts(couts<e_time));
		else
			ref(rx)=nan;
		end
	end
	
	
	align_string='RT';
else
	align_string=align_on;
	ref=extract_alignment(sessid,align_on,peh);
end

%ref=ref(~isnan(ref));


function a_str=align_str(sessid)
if iscell(sessid)
	sessid=sessid{1};
end
protocol=bdata('select protocol from sessions where sessid="{S}"',sessid);
switch protocol{1}
	case 'SameDifferent'
		a_str='ps.center_2_side_gap(end,1)';
	case 'ProAnti2'
		a_str='ps.poke2sound(1,1)';
	case 'ExtendedStimulus'
		a_str='ps.wait_for_spoke(1,2)';
	otherwise
		warning('summary_plot:unknown_protocol','No default alignment for protocol %s.  Add to private align_on function in summary_plot',protocol);
end




%% Call rasterC to makes the raster and PSTH plot

function [ref,condition,legend_str]=get_conditions(sessid,ref,peh,correct_only,noviol_only,by_sounds,mem_only)

[protocol,pd]=bdata('select protocol,protocol_data from sessions where sessid="{S}"',sessid);
pd=pd{1};
[pd,peh]=fix_sizes_in_pd(pd,peh);
hits=pd.hits==1;
inc_trs=ones(size(pd.hits));
if by_sounds
    condition=pd.sounds;
    for ls=1:numel(unique(pd.sounds))
        legend_str{ls}=sprintf('Snd%d',ls);
    end
elseif strcmpi(protocol,'samedifferent')
	legend_str={'SndL:PokeR' 'SndL:PokeL','SndR:PokeL' 'SndR:PokeR'};
	rights=pd.sides=='r';
	inc_trs=~isnan(pd.hits);
	condition = ((hits==1)+10*(rights==1));
	
elseif strcmpi(protocol,'proanti2')
	legend_str={'Anti SoundR:PokeL' 'Pro SoundL:PokeL' 'Pro SoundR:PokeR','Anti SoundL:PokeR' };
	rights=pd.sides==1;
	pro=pd.context==1;
	inc_trs=~isnan(pd.hit) & pd.gotit==1;
	condition = (pro+(10*rights)); % anti-l 0, pro-l 1, anti-r 10, pro-r 11
	condition(condition==10)=20;  % this puts it in the order of the sides plot of the protocol

else
	if isempty(pd)
		%% if we don't have any trial info , just plot all trials.
		condition = 1;
		legend_str='all trials';
	else
		%% Try to seperate on hit/miss left/right for DO and pro/anti
		%% left/right for ProAnti2
		
		
		pd=pd{1};
		fn=fieldnames(pd);
		legend_str={'SndL:PokeR' 'SndL:PokeL','SndR:PokeL' 'SndR:PokeR'};
		if ismember('sides',fn)
			if ischar(pd.sides(1))
				rights=pd.sides=='r';
			else
				rights=pd.sides==1;
			end
		else
			warning('summary_plot:sides','No sides information in protocol data');
			rights=0;
			legend_str={'Miss' 'Hit'};
		end
		
		if ismember('hits',fn)
			hits=pd.hits==1;
		elseif ismember('gotit',fn)  %like in ProAnti2
			inc_trs=~isnan(pd.hit);
			hits=pd.gotit==1;
			
		else
			
			warning('summary_plot:hits','No hits information in protocol data');
			hits=0;
			
			if numel(legend_str)==4
				legend_str={'Left' 'Right'};
			else
				legend_str='';
			end
		end
		
	end
	
	
	hits=hits(inc_trs);
	rights=rights(inc_trs);
	condition = ((hits==1)+10*(rights==1));
	
end

if correct_only
		inc_trs=inc_trs & hits==1;
end

if mem_only
    inc_trs = inc_trs & pd.ssd<0.2;
end

if noviol_only
		if isfield(pd, 'cpoke_violations'),
			noviol = pd.cpoke_violations==1;
		else
			noviol = zeros(size(peh));
			for i = 1:length(noviol),
				noviol(i) = rows(peh(i).states.cpoke1)==1;
			end;
		end;
		inc_trs = inc_trs & (noviol==1);
	end;

inc_trs = inc_trs(1:length(ref));
ref=ref(inc_trs);
condition=condition(inc_trs);

