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
%   export_fig(dstruct.figure.hf, fullfile(dpath, [name '.pdf']),'-transparent');
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
        dp.movingAvg.ChoiceMissed =  nanconv(y,kernel,'edge','1d') ;
        y = dp.ChoiceCorrect;
        dp.movingAvg.ChoiceCorrect =  nanconv(y,kernel,'edge','1d') ;
        y = dp.ChoiceCorrectValid;
        dp.movingAvg.ChoiceCorrectValid =  nanconv(y,kernel,'edge','1d') ;
        y = dp.ChoiceCorrectInvalid;
        dp.movingAvg.ChoiceCorrectInvalid =  nanconv(y,kernel,'edge','1d') ;
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
        fracInvalid = nansum(dp.ChoiceCorrectInvalid)/dp.ntrials;
        fracPremature = nansum(dp.Premature/dp.ntrials); % premature means they licked before the change in visual stimulus
        trialRate_nonMissed = nanmean(dp.movingAvg.trialRate_nonMissed);
        numRewardTrials = nansum(dp.ChoiceCorrect);
        
        % time of first lick after stimChange
        indCorrectValid = dp.ChoiceCorrect==1 & dp.isValid==1;
        y = nan(1,dp.ntrials);
        y(indCorrectValid) = dp.firstLickAfterStimulusChange(indCorrectValid)- dp.timeStimulusChange(indCorrectValid) ;
        dp.movingAvg.timeToCorrectfirstLick = nanconv(y,kernel,'edge','1d') ;
        dp.movingAvg.timeToCorrectfirstLick = dp.movingAvg.timeToCorrectfirstLick/max(dp.movingAvg.timeToCorrectfirstLick);
        % time of first lick after stimOn
        y = dp.firstLickAfterStimulusOn - dp.timeStimulusOn ;
        
        dp.movingAvg.timeTofirstLickStimulusOn = nanconv(y,kernel,'edge','1d') ;
        dp.movingAvg.timeTofirstLickStimulusOn = dp.movingAvg.timeTofirstLickStimulusOn/max(dp.movingAvg.timeTofirstLickStimulusOn);
        
        %% plotting moving average across session
        h.hAx(1) = subplot(nr,nc,1:2);
        trial = [1:dp.ntrials];
        %line(trial,dp.movingAvg.ChoiceCorrect,'color','g','linewidth',2);
        line(trial,dp.movingAvg.ChoiceCorrectValid,'color',[0.7 0 0],'linewidth',2);
        line(trial,dp.movingAvg.ChoiceCorrectInvalid,'color','r','linewidth',2);
        line(trial,dp.movingAvg.ChoiceMissed,'color','k','linewidth',2);
        line(trial,dp.movingAvg.Premature,'color',[0.7 0.7 0.7],'linewidth',2);
        %         line(trial,dp.movingAvg.timeToCorrectfirstLick,'color','b','linewidth',2);
        %         line(trial,dp.movingAvg.timeTofirstLickStimulusOn,'color','c','linewidth',2);
        line(trial, dp.freeWaterAtChange,'color','g','linewidth',2,'linestyle',':');
        line(trial, dp.isRandom,'color','r','linewidth',2,'linestyle',':');
        line(trial, dp.probValid,'color',0.7 .*[1 1 1],'linewidth',2,'linestyle',':');
        line(trial, dp.noChangeInvalid,'color',0.7 .*[0 0 1],'linewidth',2,'linestyle',':');
        
        
        %            h.leg(1) = legend({'corr','miss','PreM','Lk 1st Chg','Lk 1 StimOn','freeRwd','punishEarly'});
        %      h.leg(1) = legend({'cValid','cInV','miss','PreM','Lk 1st Chg','Lk 1 StimOn','freeRwd'});
        h.leg(1) = legend({'cValid','cInV','miss','PreM','freeRwd','isRand','probValid','noChangeInV'});
        axis tight
        ylim([0 1]);
        stitle = sprintf('\t\t Rwd: %d, Vd: %1.2f, InV:  %1.2f, Miss: %1.2f, PreM: %1.2f, %1.0f trial/min',numRewardTrials,fracValid,fracInvalid,fracMissed,fracPremature,trialRate_nonMissed);
        annotation('textbox',[0.01 .5 1 0.5],...
            'String',[dp.Animal ' ' dp.Date stitle],...
            'edgecolor','none','fontsize',15,'fontname','Arial','interpreter','none');
        
        %         h.hAx(2) =subplot(nr,nc,2);
        %         title('trial rate (unmissed)');
        %         line(xtime(indNotMissed)/60,dp.movingAvg.trialRate_nonMissed);
        %         ylabel('trial per/min');
        %         xlabel('min');
        %         axis tight;
        defaultAxes(h.hAx);
        defaultLegend(h.leg,'NorthEastOutside');
        
        %%  ** lick psths
        
        clear options cond;
        %                 sAnimal = ddstruct.licks.Animal;
        %         sDate = dstruct.licks.Date;
        %         options.savefile = sprintf('%s_AL%s_%sE%d_U%d%s%s',options.sDesc,alignEvent, sDate,Electrode,UnitID );
        %
        % ///////////////// correct PSTH
        options.hAx(1) = subplot(nr,nc,3);
        options.hAx(2) = subplot(nr,nc,5);
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
%         icond = 1;
%         cond(icond).sleg = 'Valid';
%         cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
%         cond(icond).sweepsf   = {'ChoiceCorrect',1,'isValid',1};
%         cond(icond).trialRelsweepsf   = {};
%         cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
%         cond(icond).plotparam.bAppend= 0;
%         cond(icond).plotparam.scolor= 'k';
%         icond = 2;
%         cond(icond).sleg = 'Invalid';
%         cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
%         cond(icond).sweepsf   = {'ChoiceCorrect',1,'isValid',0};
%         cond(icond).trialRelsweepsf   = {};
%         cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
%         cond(icond).plotparam.bAppend= 1;
%         cond(icond).plotparam.scolor= [1 1 1]*0.7;
       icond = 1;
        cond(icond).sleg = 'Valid';
        cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
        cond(icond).sweepsf   = {'ChoiceCorrect',1,'ChoiceLeft',1};
        cond(icond).trialRelsweepsf   = {};
        cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
        cond(icond).plotparam.bAppend= 0;
        cond(icond).plotparam.scolor= 'k';
        icond = 2;
        cond(icond).sleg = 'Invalid';
        cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
        cond(icond).sweepsf   = {'ChoiceCorrect',1,'ChoiceLeft',0};
        cond(icond).trialRelsweepsf   = {};
        cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
        cond(icond).plotparam.bAppend= 1;
        cond(icond).plotparam.scolor= [1 1 1]*0.7;
        
        
        [dstruct.hPSTH  ntrialsInCond]= psthCondSpikes(dstruct.licks,cond, WOI, options);
        %         set(hPSTH.hAx,'Color',[1 1 1]*.2)
        setYLabel(dstruct.hPSTH.hAx(1),'licks/sec')
          axes(dstruct.hPSTH.hAx(1));
        axis tight      
        setAxEq(dstruct.hPSTH.hAx,'x','matchFirstAxis')
        text(0.6, 0.8,options.sDesc);
         % ///////////// error PSTH
        clear options cond;
        options.hAx(1) = subplot(nr,nc,4);
        options.hAx(2) = subplot(nr,nc,6);
        
        Electrode = 0;        UnitID = 0;
        
        WOI  = [-4 2]*1000;
        alignEvent = 'timeStimulusChange';
        options.bsave = 0;
        options.bootstrap = 0;
        options.binsize = 20;
        options.nsmooth =round(50/ options.binsize);
        
        options.sDesc = 'Error';
        options.dpFieldsToPlot = {'firstLickAfterStimulusChange'};
        options.sortSweepsByARelativeToB= {'firstLickAfterStimulusChange','timeStimulusChange',};
        options.plottype = {'psth','rasterplot'};
        icond = 1;
        cond(icond).sleg = 'Error';
        cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
        cond(icond).sweepsf   = {'ChoiceCorrect',[0],'isValid',0};
        cond(icond).trialRelsweepsf   = {};
        cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
        cond(icond).plotparam.bAppend= 0
        cond(icond).plotparam.scolor= [1 1 1]*0.6;       
        
        [dstruct.hPSTH2  ntrialsInCond]= psthCondSpikes(dstruct.licks,cond, WOI, options);
        %         set(hPSTH.hAx,'Color',[1 1 1]*.2)
        setYLabel(dstruct.hPSTH2.hAx(1),'licks/sec')
        axes(dstruct.hPSTH2.hAx(1));
        axes(dstruct.hPSTH2.hAx(1));
        axis tight
        setAxEq(dstruct.hPSTH2.hAx,'x','matchFirstAxis')
        text(0.6, 0.8,options.sDesc);
        
        
        % % Plot PSTh of first lick
        figure
        Electrode = 0;        UnitID = 0;
        icond = 1;
        alignEvent = 'timeStimulusChange';
        cond(icond).sleg = 'Valid';
        cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
        cond(icond).sweepsf   = {'ChoiceCorrectValid',1,'freeWaterAtChange',0};
        cond(icond).trialRelsweepsf   = {};
        cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
        cond(icond).plotparam.bAppend= 0;
        
        bins = linspace(200,3500,30);
        
        this_lick = filtspikes(dstruct.licks,1,cond(icond).spikesf,cond(icond).sweepsf );
        [a1 x1] = hist(this_lick.sweeps.firstLickAfterStimulusChange-this_lick.sweeps.timeStimulusChange,bins);
        
        
        
        icond = 2;
        alignEvent = 'timeStimulusChange';
        cond(icond).sleg = 'Valid';
        cond(icond).spikesf = {'Electrode',Electrode,'Unit',UnitID};
        cond(icond).sweepsf   = {'ChoiceCorrectInvalid',0};
        cond(icond).trialRelsweepsf   = {};
        cond(icond).alignEvent= alignEvent; % NOTE Times must be relative to the beginning of the session
        cond(icond).plotparam.bAppend= 0;
        
        this_lick = filtspikes(dstruct.licks,1,cond(icond).spikesf,cond(icond).sweepsf );
        [a2 x2] = hist(this_lick.sweeps.firstLickAfterStimulusChange-this_lick.sweeps.timeStimulusChange,bins);
        
        
        stairs(x1,a1,'color','k'); hold all
        stairs(x2,a2,'color',[1 1 1]*0.6)
        xlabel('first Lick After Change (ms)')
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
            if isfield(dstruct,'hPSTH2')
                mydata = [];
                guidata(dstruct.hPSTH2(2),mydata);
                guidata(dstruct.hPSTH(2),mydata);
            end
            clf(dstruct.figure.hf);
            try
                initFigure(dstruct);
                
                if bsave
                    export_fig(dstruct.figure.hf, fullfile(dpath, [name '.pdf']),'-transparent');
                    plot2svg(fullfile(dpath, [name '.svg']),dstruct.figure.hf)
                end
            catch ME
                getReport(ME)
            end
        end
        
    end
end