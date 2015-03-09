function [ varargout ] = daily_report_attention( varargin )
%daily_report Generates a session report figure
bsave = 1;


rd = visRigDefs;
if nargin ==1
dataParsed = varargin{1};
dstruct.dataParsed = dataParsed;
else
    dstruct.licks = buildLicks_Attention;
    dstruct.dataParsed = dstruct.licks.sweeps;
    %     dstruct.dataParsed = loadBControlsession;
end
%% Plot formatting and init


if nargin==2
    bdocked = varargin{3};
else
    bdocked = 1;
end

if isfield(dstruct,'figure')
    if ishandle(dstruct.figure.hf)
        clf(dstruct.figure.hf);
    end
else
    if bdocked
        dstruct.figure.hf = figure('WindowStyle','docked');
    else
        dstruct.figure.hf = figure('position',[360    78   640   844]);
    end

end



set(dstruct.figure.hf,'KeyPressFcn',@updatefigure);
mn = initFigure(dstruct);

[~, dpath] = parentfolder(  fullfile(rd.DIR.DailyFig,dstruct.dataParsed.Protocol),1);
if bsave
    export_fig(dstruct.figure.hf, fullfile(dpath, [name '.pdf']),'-transparent');
    plot2svg(fullfile(dpath, [name '.svg']),dstruct.figure.hf)
end
varargout{1} = mn;
varargout{2} = dstruct.figure.hf;


    function  [varargout] = initFigure(dstruct)
        [junk, name, junk] = fileparts(dstruct.dataParsed.FileName);
        set(dstruct.figure.hf,'Name',[dstruct.dataParsed.Animal  ' ' dstruct.dataParsed.FileName],'numberTitle','off')
        
        nr = 3; nc = 2;
        dp = dstruct.licks.sweeps;
        
        
        % for running average
        filterlength = 7;        filttype = 'gaussian';      
        kernel = getFilterFun(filterlength,filttype);
                
        % compute running average
        y = dp.ChoiceMissed;
        y(isnan(y)) = 0;
        dp.movingAvg.ChoiceMissed =  nanconv(y,kernel,'edge','1d') ;
        y = dp.ChoiceCorrect;
        dp.movingAvg.ChoiceCorrect =  nanconv(y,kernel,'edge','1d') ;    
        y = dp.Premature;
        dp.movingAvg.Premature =  nanconv(y,kernel,'edge','1d') ;
        
        % trialrate
        xtime = (dp.TrialInit -dp.TrialInit(1))/1000;
        indNotMissed = isnan(dp.ChoiceMissed);
        y = [nan diff(xtime(indNotMissed))] ; % intertrial interval non missed trials
        y = 1./y*60;
        dp.movingAvg.trialRate_nonMissed =  nanconv(y,kernel,'edge','1d') ;
        
        fracMissed = nansum(dp.ChoiceMissed)/dp.ntrials;
        fracValid = nansum(dp.ChoiceCorrectValid)/dp.ntrials;
        fracPremature = nansum(dp.Premature/dp.ntrials); % premature means they licked before the change in visual stimulus
        trialRate_nonMissed = nanmean(dp.movingAvg.trialRate_nonMissed);
        numRewardTrials = nansum(dp.ChoiceCorrect);
        
        % time of first lick after stimChange
        indCorrectValid = dp.ChoiceCorrect==1 & dp.isValid;
        y = nan(1,dp.ntrials);
        y(indCorrectValid) = dp.firstLickAfterStimulusChange(indCorrectValid)- dp.timeStimulusChange(indCorrectValid) ;
        dp.movingAvg.timeToCorrectfirstLick = nanconv(y,kernel,'edge','1d') ;
        dp.movingAvg.timeToCorrectfirstLick = dp.movingAvg.timeToCorrectfirstLick/max(dp.movingAvg.timeToCorrectfirstLick);
        % time of first lick after stimOn
        y = dp.firstLickAfterStimulusOn - dp.timeStimulusOn ;
        
        dp.movingAvg.timeTofirstLickStimulusOn = nanconv(y,kernel,'edge','1d') ;
        dp.movingAvg.timeTofirstLickStimulusOn = dp.movingAvg.timeTofirstLickStimulusOn/max(dp.movingAvg.timeTofirstLickStimulusOn);

        %% plotting moving average across session
        h.hAx(1) = subplot(nr,nc,1);
        trial = [1:dp.ntrials];
        line(trial,dp.movingAvg.ChoiceCorrect,'color','g','linewidth',2);
        line(trial,dp.movingAvg.ChoiceMissed,'color','k','linewidth',2);
        line(trial,dp.movingAvg.Premature,'color',[0.7 0.7 0.7],'linewidth',2);
        line(trial,dp.movingAvg.timeToCorrectfirstLick,'color','b','linewidth',2);
        line(trial,dp.movingAvg.timeTofirstLickStimulusOn,'color','c','linewidth',2);
        
        
        h.leg(1) = legend({'ChoiceCorrect','ChoiceMissed','Premature','Time 1st Lick','Time 1st StimOn'});
        axis tight
        ylim([0 1]);
        stitle = sprintf('\t\t Rwd: %d, Vd: %1.2f, Miss: %1.2f, PreM: %1.2f, %1.0f trial/min',numRewardTrials,fracValid,fracMissed,fracPremature,trialRate_nonMissed);
        annotation('textbox',[0.01 .5 1 0.5],...
            'String',[dp.Animal ' ' dp.Date stitle],...
            'edgecolor','none','fontsize',15,'fontname','Arial','interpreter','none');
        
        h.hAx(2) =subplot(nr,nc,2);
        title('trial rate (unmissed)');
        line(xtime(indNotMissed)/60,dp.movingAvg.trialRate_nonMissed);
        ylabel('trial per/min');
        xlabel('min');
        axis tight;
        defaultAxes(h.hAx);
        defaultLegend(h.leg);
        
        %%  ** lick psths

        clear options cond;
%                 sAnimal = ddstruct.licks.Animal;
%         sDate = dstruct.licks.Date;
%         options.savefile = sprintf('%s_AL%s_%sE%d_U%d%s%s',options.sDesc,alignEvent, sDate,Electrode,UnitID );
% 
 % ///////////////// correct PSTH 
        options.hAx(1) = subplot(nr,nc,3);
        options.hAx(2) = subplot(nr,nc,4);       
        Electrode = 0;        UnitID = 0;
        
        WOI  = [-4 2]*1000;
        alignEvent = 'timeStimulusChange';
        options.bsave = 0;
        options.bootstrap = 0;
        options.binsize = 20;
        options.nsmooth =round(50/ options.binsize);
        
        options.sDesc = 'Correct';
        options.dpFieldsToPlot = {'firstLickAfterStimulusChange'};
        options.sortSweepsByARelativeToB= {'firstLickAfterStimulusChange','timeStimulusChange',};
        options.plottype = {'psth','rasterplot'};
        icond = 1;
        cond(icond).sleg = 'Correct';
        cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
        cond(icond).sweepsf   = {'ChoiceCorrect',[1]};
        cond(icond).trialRelsweepsf   = {};
        cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
        
        
        [hPSTH  ntrialsInCond]= psthCondSpikes(dstruct.licks,cond, WOI, options);
%         set(hPSTH.hAx,'Color',[1 1 1]*.2)
        setYLabel(hPSTH.hAx(1),'licks/sec')        
        setAxEq(hPSTH.hAx,'x','matchFirstAxis')
        axes(hPSTH.hAx(1));
       text(0.6, 0.8,options.sDesc);
        
 % ///////////// error PSTH 
        options.hAx(1) = subplot(nr,nc,5);
        options.hAx(2) = subplot(nr,nc,6);
        
        Electrode = 0;        UnitID = 0;       
        
        WOI  = [-4 2]*1000;
        alignEvent = 'timeStimulusOn';
        options.bsave = 0;
        options.bootstrap = 0;
        options.binsize = 20;
        options.nsmooth =round(50/ options.binsize);
        
        options.sDesc = 'Error';
        options.dpFieldsToPlot = {'firstLickAfterStimulusOn'};
        options.sortSweepsByARelativeToB= {'firstLickAfterStimulusOn','timeStimulusOn',};
        options.plottype = {'psth','rasterplot'};
        icond = 1;
        cond(icond).sleg = 'Error';
        cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
        cond(icond).sweepsf   = {'ChoiceCorrect',[0]};
        cond(icond).trialRelsweepsf   = {};
        cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
        
        
        [hPSTH2  ntrialsInCond]= psthCondSpikes(dstruct.licks,cond, WOI, options);
%         set(hPSTH.hAx,'Color',[1 1 1]*.2)
        setYLabel(hPSTH2.hAx(1),'licks/sec')        
        setAxEq(hPSTH2.hAx,'x','matchFirstAxis')
        axes(hPSTH2.hAx(1));
        text(0.6, 0.8,options.sDesc);


        %%
        varargout{1} = [];
        varargout{2} = dstruct.figure.hf;
        plotAnn( dstruct.licks.sweeps.FileName,dstruct.figure.hf);
        
    end

    function updatefigure(src,event)
        % Callback to parse keypress event data to print a figure
        bupdate = 0;
        switch(event.Character)
            case 'r'
                bupdate = 1;
                dataParsed = fullfile(dstruct.licks.sweeps.PathName, dstruct.licks.sweeps.FileName);
%             case 'S'
%                 dp = dstruct.dataParsed;
%                 performSummary = getPerformance(dp);
%                 
%                 [animalLog bfound] = addToLocalLog(performSummary,[],dp.FileName);
%                 
%                 hSummary = plotLogSummary(dp.Animal);
%                 bupdate = 0;
               case 'p' % plot psth of licks
              
            case 'l' %load a new file
                [directory files] = getBcontrol_AnimalExpt(dstruct.licks.sweeps.Animal);
                if isunix
                    slash = '/';
                else
                    slash = '\';
                end
                [FileName,PathName] = uigetfile(fullfile(directory,slash,'data*.mat'),'Select Behavior file to analyze');
                dataParsed = [PathName FileName];
                
                bupdate = 1;
            case 28 % left (LOAD OLDER FILE)
                [directory files] = getBcontrol_AnimalExpt(dstruct.licks.sweeps.Animal);
                % note files are sorted by date starting from most current
                % find the current expt
                [~, loc] =  ismember(files(:,2),dstruct.licks.sweeps.FileName);
                loc = find(loc);
                % the next LESS current behavioral file
                loc  = loc +1;
                if (loc) > size(files,1); % wrap to the NEWEST if this is the OLDEST current file
                    loc = 1;
                end
                
                dataParsed = fullfile(directory,files{loc,1});
                bupdate = 1;
            case 29 % right (LOAD PREVIOUS DAYS BEHAVIOR FILE)
                [directory files] = getBcontrol_AnimalExpt(dstruct.licks.sweeps.Animal);
                % note files are sorted by date starting from most current
                % find the current expt
                [~, loc] =  ismember(files(:,2),dstruct.licks.sweeps.FileName);
                loc = find(loc);
                % the next more current behavioral file
                loc  = loc -1;
                if (loc) <=0 % wrap to the oldest if this is the most current file
                    loc = size(files,1);
                end
                
                dataParsed = fullfile(directory,files{loc,1});
                bupdate = 1;
        end
        
        if bupdate
            dstruct.licks = buildLicks_Attention(dataParsed);
            dstruct.dataParsed = dstruct.licks.sweeps;
            clf(dstruct.figure.hf);
            try
                initFigure(dstruct);
                
                if bsave
                    saveas(dstruct.figure.hf, fullfile(rd.DIR.DailyFig, [name '.pdf']));
                end
            catch ME
                getReport(ME)
            end
        end
        
    end
end