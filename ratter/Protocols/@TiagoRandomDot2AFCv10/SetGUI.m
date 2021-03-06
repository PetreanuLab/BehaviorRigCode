function [] = SetGUI(obj, action)

GetSoloFunctionArgs;

switch action,
    case 'init',
        
        SoloParamHandle(obj,'sideHistory','value',1); 
        SoloParamHandle(obj,'coherHistory','value',1);
        SoloParamHandle(obj,'correctHistory','value',1);
        SoloParamHandle(obj,'wrongHistory','value',1);
        SoloParamHandle(obj,'choiceHistory','value',1);
        
        % Creates the main window
        SoloParamHandle(obj, 'mainfig', 'saveable', 0); mainfig.value = figure;
        name = 'Random Dot Task';
        set(value(mainfig), 'Name', name, 'Tag', name, ...
            'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        
        set(value(mainfig), 'Position', [423 196 430 680]);
        % Starting coordinates
        x=10; y=10;
        
        %
                
        % Coherences menu
        SliderParam(obj, 'coher_1_prob', 0, 0, 10, x, y, 'TooltipString', 'Weigth for first coherence.');next_row(y);                
        NumeditParam(obj, 'coher_1', 1, x, y, 'TooltipString', 'First coherence level');next_row(y);
        SliderParam(obj, 'coher_2_prob', 0, 0, 10, x, y, 'TooltipString', 'Weigth for second coherence.');next_row(y);                
        NumeditParam(obj, 'coher_2', 2.5, x, y, 'TooltipString', 'Second coherence level');next_row(y);
        SliderParam(obj, 'coher_3_prob', 0, 0, 10, x, y, 'TooltipString', 'Weigth for third coherence.');next_row(y);                
        NumeditParam(obj, 'coher_3', 6.3, x, y, 'TooltipString', 'Third coherence level');next_row(y);
        SliderParam(obj, 'coher_4_prob', 0, 0, 10, x, y, 'TooltipString', 'Weigth for fourth coherence.');next_row(y);                
        NumeditParam(obj, 'coher_4', 15.8, x, y, 'TooltipString', 'Fourth coherence level');next_row(y);
        SliderParam(obj, 'coher_5_prob', 0, 0, 10, x, y, 'TooltipString', 'Weigth for fifth coherence.');next_row(y);                
        NumeditParam(obj, 'coher_5', 39.8, x, y, 'TooltipString', 'Fifth coherence level');next_row(y);
        SliderParam(obj, 'coher_6_prob', 10, 0, 10, x, y, 'TooltipString', 'Weigth for sixth coherence.');next_row(y);                
        NumeditParam(obj, 'coher_6', 100, x, y, 'TooltipString', 'Sixth coherence level');next_row(y);
        SubheaderParam(obj, 'coherenceLevels', 'Coherence levels available', x, y);next_row(y,1.5);

        % Stimuli menu
        MenuParam(obj, 'dotDensity',{'0.05','0.08','0.1','0.15','0.2','0.25','0.3'}, 0.15, x, y, 'TooltipString', ...
            'Dot size in degrees',  'labelfraction', 0.5);next_row(y);
        MenuParam(obj, 'dotSpeed',{'5','15','25','30','40','60','75','90','120'}, 25, x, y, 'TooltipString', ...
            'Dot size in degrees',  'labelfraction', 0.5);next_row(y);
        MenuParam(obj, 'dotSize',{'0','0.01','0.02','0.03','0.1','0.5','1','1.5','2','3','4','5','6','7','8','9','10'}, 2, x, y, 'TooltipString', ...
            'Dot size in degrees',  'labelfraction', 0.5);next_row(y);
        MenuParam(obj, 'lifeTime',{'480','360','240','120','75','60','40','30','25','24','15','12','8','6','4','3','2'}, 24, x, y, 'TooltipString', ...
            'How stimuli are defined, either a random sequence or defined by external file',  'labelfraction', 0.5);next_row(y);

        MenuParam(obj, 'patchDeg',{'10','15','20','25','30','35','40','45','50','55','70','75','80','100'}, 40, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);        
        
        SliderParam(obj, 'dotsLevel', 100, 0,255, x, y, 'TooltipString', 'Level of brightness of dots.');next_row(y);
        SliderParam(obj, 'backgroundLevel', 0, 0,255, x, y, 'TooltipString', 'Level of brightness of background.');next_row(y);
        MenuParam(obj, 'monitor',{'19','22'}, 22, x, y, 'TooltipString', ...
            'Select which monitor is being used',  'labelfraction', 0.5);next_row(y);        
        SubheaderParam(obj, 'stimuliMenu', 'Random Dot', x, y); next_row(y,1.5);
                
        MenuParam(obj, 'maxAlternSides',{'2','3','4','5'}, 3, x, y, 'TooltipString', 'Maximum number of consecutive alternations allowed.');next_row(y);        
        MenuParam(obj, 'maxEqualSides',{'2','3','4','5'}, 3, x, y, 'TooltipString', 'Maximum number of consecutive equal sides allowed.');next_row(y);
        ToggleParam(obj, 'limitEqualSides', 1, x, y, 'position', [x y 100 20]); 
        ToggleParam(obj, 'limitAlternSides', 1, x, y, 'position', [(x+100) y 100 20]); next_row(y);
        
        SliderParam(obj, 'leftProb', 0.5, 0, 1, x, y); next_row(y);
        
        DispParam(obj, 'accuracy',0,x,y); next_row(y);
        DispParam(obj, 'bias',0,x,y); next_row(y);
        NumeditParam(obj, 'trialHistory', 20, x, y, 'TooltipString', ...
            'Number of last trials for bias and accuracy calculation');next_row(y);
        DispParam(obj, 'side', 1, x, y); next_row(y);
        DispParam(obj, 'coher', 100, x, y); next_row(y);
        SubheaderParam(obj, 'currentTrial', 'Current Trial', x, y); next_row(y,1.5);

        next_column(x); y=10;
        
        % Submit push button
        PushbuttonParam(obj, 'submit', x, y, 'position', [x y 100 45],'BackgroundColor', [0 0 1]);
        set_callback(submit, {'StateMatrixSection', 'init'}); %i, sprintf('\n')});
        
        PushbuttonParam(obj, 'restart', x, y, 'position', [(x+100) y 100 45],'BackgroundColor', [1 0 0]);next_row(y,2.5);
        set_callback(restart, {'SetGUI','restart'}); %i, sprintf('\n')});

        [x, y] = SavingSection(obj, 'init', x, y);
        
        my_state_colors = struct( ...
            'load_stimulus', [1 0 0], ...
            'stimulus_pres', [0 1 0], ...
            'response_window', [0 0 1], ...
            'correct_choice', [1 1 0], ...
            'wrong_choice', [1 0 1], ...
            'early_correct_choice', [0.8 0.8 0], ...
            'early_wrong_choice', [0.8 0 0.8], ...
            'time_out', [0 1 1], ...
            'inter_trial_interval', [1 1 1]);
        
                my_poke_colors = struct( ...
            'L',                  0.6*[1 0.66 0],    ...
            'C',                      [0 0 0],       ...
            'R',                  0.9*[1 0.66 0]);
        
        [x, y] = PokesPlotSection(obj, 'init', x, y, ...
            struct('states',  my_state_colors, 'pokes', my_poke_colors));
        %    set(value(PokesPlotSection.myfig), 'Position', [520 100 240 235]);
        PokesPlotSection(obj, 'hide');
        PokesPlotSection(obj, 'set_alignon', 'load_stimulus');
        ThisSPH=get_sphandle('owner', mfilename, 'name','t0'); ThisSPH{1}.value = 0;
        ThisSPH=get_sphandle('owner', mfilename, 'name','t1'); ThisSPH{1}.value = 8;


       % [x, y] = PokesPlotSection(obj, 'init', x, y, my_state_colors);
        
%         ToggleParam(obj, 'PlotsGUI', 1, x, y); next_row(y);
%         set_callback(PlotsGUI, {'SetGUI','restart'}); %i, sprintf('\n')});

        next_row(y,0.4);

        MenuParam(obj, 'valveTimeRight',{'0.02','0.03','0.04','0.05','0.06','0.07','0.08','0.09','0.1','0.5','1'}, 0.05, x, y, 'TooltipString', 'For how long valve is open (seconds)');next_row(y);
        MenuParam(obj, 'valveTimeLeft',{'0.02','0.03','0.04','0.05','0.06','0.07','0.08','0.09','0.1','0.5','1'}, 0.05, x, y, 'TooltipString', 'For how long valve is open (seconds)');next_row(y);
        MenuParam(obj, 'ITIMax', {'0.001','1','1.5','2','2.5','3','4','5','6','7','8','9','10'},3, x, y, 'TooltipString', 'Inter-Trial Interval (seconds)');next_row(y);
        MenuParam(obj, 'ITI', {'0.001','1','1.5','2','2.5','3','4','5','10', 'RANDOM'},'RANDOM', x, y, 'TooltipString', 'Inter-Trial Interval (seconds)');next_row(y);
        MenuParam(obj, 'errorPunishment', {'0.001','1','2','3','4','5','6','7','8','9','10'}, 5, x, y, 'TooltipString', 'Duration of the error punishment state.');next_row(y);
        MenuParam(obj, 'timeOut', {'0.001','1','2','3','4','5','10'}, 1, x, y, 'TooltipString', 'Duration of the time-out state.');next_row(y);
        MenuParam(obj, 'rewardState', {'0.001','1','1.5','2','3','4','5','10'}, 1, x, y, 'TooltipString', 'Duration of the reward state.');next_row(y);
        MenuParam(obj, 'responseWindow',{'1','2','3','4','5'}, 3, x, y, 'TooltipString', 'Duration of response window.');next_row(y);
        MenuParam(obj, 'responseDelay',{'0.001','0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1','1.5','2','3','4','5'}, 1, x, y, 'TooltipString', 'Delay after stimulus onset for considering a response.');next_row(y);
        MenuParam(obj, 'stimuliDuration', {'0.1','0.2','0.3','0.4','0.5','0.6','0.7','0.8','0.9','1','1.5','2','3','4','5'}, 1, x, y, 'TooltipString', 'Length in seconds of stimuli presentation.');next_row(y);
        SubheaderParam(obj, 'timing', 'Trial timings', x, y); next_row(y,1.5);
        
        MenuParam(obj, 'rightFrequency', {'2','4','6','8','10','12'},4, x, y, 'TooltipString', 'Sound frequency paired with right direction in kHz.');next_row(y);

        MenuParam(obj, 'leftFrequency', {'2','4','6','8','10','12'},2, x, y, 'TooltipString', 'Sound frequency paired with left direction in kHz.');next_row(y);

        SliderParam(obj, 'soundVolume', 10, 0, 50, x, y, 'TooltipString', 'Sound cues volume.');next_row(y);
        
        ToggleParam(obj, 'soundSides', 0, x, y,'position',[x y 100 20]);
        
        ToggleParam(obj, 'soundTrial', 1, x, y,'position',[x + 100 y 100 20]); next_row(y);
        
        SubheaderParam(obj, 'soundsHeader', 'Sound Options', x, y); next_row(y,1.5); 
        
        ToggleParam(obj, 'delayITI', 1, x, y); next_row(y); 
        ToggleParam(obj, 'punishDelayLick', 0, x, y); next_row(y);
        ToggleParam(obj, 'punishError', 0, x, y); 


        
        % Declares global variables
        %%% Global Variables Example
        % DeclareGlobals(obj, {'rw_args','leftValve'}, {'ro_args', 'rightValve'},{'owner', class(obj)});
        %%%
        DeclareGlobals(obj, 'rw_args', {...
            'side', 'coher','accuracy','bias','trialHistory',...
            'sideHistory','coherHistory','correctHistory','wrongHistory','choiceHistory',...
            'ITI','ITIMax','valveTimeRight','valveTimeLeft','timeOut','errorPunishment','rewardState',...
            'coher_1','coher_2','coher_3','coher_4','coher_5','coher_6',...
            'coher_1_prob','coher_2_prob','coher_3_prob','coher_4_prob','coher_5_prob','coher_6_prob',...
            'lifeTime','dotsLevel','dotSize','dotSpeed','dotDensity','monitor','patchDeg',...
            'backgroundLevel','stimuliDuration',...
            'limitEqualSides','maxEqualSides','limitAlternSides','maxAlternSides',...
            'responseDelay','responseWindow','punishError','delayITI','punishDelayLick','leftProb',...
            'soundTrial', 'soundSides', 'leftFrequency', 'rightFrequency','soundVolume'});
        
        
        % RESET POSITION F DISPATCHER AND POKESPLOT
        a = findobj('type','figure');
        [~, c] = sort(a);
        %%% Dispatcher
        set(a(c(1)), 'position', [5 395 410 460]);
        %%% PokesPlot
        % set(a(c(3)), 'position', [0.1      0.0275     0.8       0.815]);
        
    case 'restart'
        dispatcher('restart_protocol');
        


    case 'close',
        delete(value(mainfig));
        
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;

