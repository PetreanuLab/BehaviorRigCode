function [] = SetGUI(obj, action)

GetSoloFunctionArgs;

persistent my_state_colors  my_event_colors 

        %      IMPORTANT: whatever data you want to save should be defined as a
        %      SoloParam object [whatever(obj, ....);], if you do NOT want to save
        %      things you can define it as whateverIdontwanttosave('base', ...);


switch action,
    
    %% CASE init
    case 'init',
        
        %% Initiates 
        SoloParamHandle(obj,'timeOutHistory','value',[]); 
        SoloParamHandle(obj,'coherHistory','value',[]);
        SoloParamHandle(obj,'correctHistory','value',[]);
        SoloParamHandle(obj,'stimSideHistory','value',[]);
        SoloParamHandle(obj,'choiceHistory','value',[]);
        SoloParamHandle(obj,'nonRandomSide','value',0);
        SoloParamHandle(obj,'positionHistory','value',[]); 
        SoloParamHandle(obj,'currTargetPos','value',[]);
        SoloParamHandle(obj,'currFoilPos','value',[]);
        SoloParamHandle(obj,'matchHistory','value',[]);
        SoloParamHandle(obj,'fixRatioRwdCnter','value',0);
        SoloParamHandle(obj,'fixRatioRwdthisTrial','value',1);
         
        %% Set all additional GUIs
        TimingsGUI(obj, 'init');
        MonitorGUI(obj, 'init');
        StimulusGUI(obj,'init');
        TrialGUI(obj,'init');
        BiasGUI(obj,'init');
        SoundGUI(obj,'init');
        TreadmillGUI(obj,'init');
 
        %% Create protocol main figure
        % Make default figure. We remember to make it non-saveable; on next run
        % the handle to this figure might be different, and we don't want to
        % overwrite it when someone does load_data and some old value of the
        % fig handle was stored as SoloParamHandle "main_fig"
        SoloParamHandle(obj, 'main_fig', 'saveable', 0); main_fig.value = figure;
        
        % Make the title of the figure be the protocol name, and if someone tries
        % to close this figure, call dispatcher's close_protocol function, so it'll know
        % to take it off the list of open protocols.
        name = 'Visual 2AFC';
        set(value(main_fig), 'Name', name, 'Tag', name, ...
            'closerequestfcn', 'dispatcher(''close_protocol'')',...
                'MenuBar', 'none',    'NumberTitle', 'off');
        
        % Sets figure size and position
        set(value(main_fig), 'Position', [ 424   180   430   748]);
        
        % Initial position on main GUI window
        x=10; y=10;        
        
        
        %% Additional IOs section
        % Timings
        ToggleParam(obj, 'timingsToggle', 0, x, y, 'OnString', 'Hide timings', ...
            'OffString', 'Show timings'); next_row(y);
        set_callback(timingsToggle, {'SetGUI', 'show_hide_timings'});
        % Monitor
        ToggleParam(obj, 'monitorToggle', 0, x, y, 'OnString', 'Hide monitor', ...
            'OffString', 'Show monitor'); next_row(y);
        set_callback(monitorToggle, {'SetGUI', 'show_hide_monitor'});
        % Stimulus
        ToggleParam(obj, 'stimulusToggle', 0, x, y, 'OnString', 'Hide stimulus', ...
            'OffString', 'Show stimulus'); next_row(y);
        set_callback(stimulusToggle, {'SetGUI', 'show_hide_stimulus'});
        % Trial
        ToggleParam(obj, 'trialToggle', 0, x, y, 'OnString', 'Hide trial', ...
            'OffString', 'Show trial'); next_row(y);
        set_callback(trialToggle, {'SetGUI', 'show_hide_trial'});
        % Bias
        ToggleParam(obj, 'biasToggle', 0, x, y, 'OnString', 'Hide bias', ...
            'OffString', 'Show bias'); next_row(y);
        set_callback(biasToggle, {'SetGUI', 'show_hide_bias'});
        % Sound
        ToggleParam(obj, 'soundToggle', 0, x, y, 'OnString', 'Hide sound', ...
            'OffString', 'Show sound'); next_row(y);
        set_callback(soundToggle, {'SetGUI', 'show_hide_sound'}); 
        % Treadmill
        ToggleParam(obj, 'treadmillToggle', 0, x, y, 'OnString', 'Hide treadmill', ...
            'OffString', 'Show treadmill'); next_row(y);
        set_callback(treadmillToggle, {'SetGUI', 'show_hide_treadmill'});                
        SubheaderParam(obj, 'iosHeader', 'Additional IOs', x, y); next_row(y,1.5);         
        
        %% History mean section
        DispParam(obj, 'meanBias',0,x,y); next_row(y);
        DispParam(obj, 'meanBPos2',0,x,y); next_row(y);
        DispParam(obj, 'meanBPos1',0,x,y); next_row(y);
        DispParam(obj, 'meanStimSide',0,x,y); next_row(y);           
        DispParam(obj, 'meanChoice',0,x,y); next_row(y);
        DispParam(obj, 'meanTimeOut',0,x,y); next_row(y);
        DispParam(obj, 'meanAccu',0,x,y); next_row(y);
        DispParam(obj, 'meanAcPos2',0,x,y); next_row(y);
        DispParam(obj, 'meanAcPos1',0,x,y); next_row(y);
        DispParam(obj, 'corrLoopV',[0 0 0 0],x,y); next_row(y);
        NumeditParam(obj, 'meanSize', 20, x, y, 'TooltipString', ...
            'Number of last trials for bias and accuracy calculation');next_row(y);
        SubheaderParam(obj, 'meanHeader', 'Mean values', x, y); next_row(y,1.5); 
        
        %% Current trial section
        DispParam(obj, 'currStimPos', NaN, x, y); next_row(y);        
        DispParam(obj, 'currRandSeed', NaN, x, y); next_row(y);        
        DispParam(obj, 'currSoundSidesVolume', NaN, x, y); next_row(y);
        DispParam(obj, 'currLifeTime', NaN, x, y); next_row(y);
        DispParam(obj, 'currSize', NaN, x, y); next_row(y);
        DispParam(obj, 'currSpeed', NaN, x, y); next_row(y);
        DispParam(obj, 'currDensity', NaN, x, y); next_row(y);        
        DispParam(obj, 'currCoher', NaN, x, y); next_row(y);
        DispParam(obj, 'currStimSizeDeg', NaN, x, y); next_row(y);        
        DispParam(obj, 'currStimDuration', NaN, x, y); next_row(y);
        DispParam(obj, 'currStimSide', NaN, x, y); next_row(y);
        DispParam(obj, 'currCorrLoop', NaN, x, y); next_row(y);
       DispParam(obj, 'currBlockCount', 0, x, y); next_row(y);
       DispParam(obj, 'currBlockLength', NaN, x, y); next_row(y);
         DispParam(obj, 'currBlockProbPos1Index', NaN, x, y); next_row(y);

        SubheaderParam(obj, 'currentHeader', 'Current Trial', x, y); next_row(y,1.5); 
        
        %% Changes column
        next_column(x); y=10;
        
        %% Save section
        % From Plugins/@saveload:
        %Initiates 'Savig Section' in the window(figure) just created, x e y =
        %position of section in the window.
        [x, y] = SavingSection(obj, 'init', x, y);
        SavingSection(obj,'set_autosave_frequency',10);

        %% Run section
        % Start
        PushbuttonParam(obj, 'start', x, y, 'position', [(x) y 100 25],'BackgroundColor', [0 1 0]);
        set_callback(start, {'SetGUI', 'start'}); %i, sprintf('\n')});
        % Stop
        PushbuttonParam(obj, 'stop', x, y, 'position', [(x+100) y 100 25],'BackgroundColor', [1 1 0]);next_row(y,1.5);
        set_callback(stop, {'SetGUI', 'stop'}); %i, sprintf('\n')});
        % Submit
        PushbuttonParam(obj, 'submit', x, y, 'position', [x y 100 25],'BackgroundColor', [0 0 1]);
        set_callback(submit, {'StateMatrixSection', 'init'}); %i, sprintf('\n')});
        % Restart
        PushbuttonParam(obj, 'restart', x, y, 'position', [(x+100) y 100 25],'BackgroundColor', [1 0 0]);next_row(y,1.5);
        set_callback(restart, {'SetGUI','restart'}); %i, sprintf('\n')});
        SubheaderParam(obj, 'runHeader', 'Protocol control', x, y); next_row(y,1.5); 

        %% Analyses Section
        % Configures PokesPlotSection
        SetGUI(obj, 'configure_pokesplot');

        % Initiates PokesPlotSection
        [x, y] = PokesPlotSection(obj, 'init', x, y, ...
            struct('states',  my_state_colors, 'pokes', my_event_colors));
                PokesPlotSection(obj, 'hide');
        
        SubheaderParam(obj, 'analysesHeader', 'Analyses', x, y); next_row(y,1.5);
        
                %% Last trial section
        DispParam(obj, 'lastTimeOut', NaN, x, y); next_row(y);
        DispParam(obj, 'lastMatch', NaN, x, y); next_row(y);
        DispParam(obj, 'lastCorrect', NaN, x, y); next_row(y);        
        DispParam(obj, 'lastChoice', NaN, x, y); next_row(y);
        DispParam(obj, 'lastStimSide', NaN, x, y); next_row(y);
        DispParam(obj, 'lastCoher', NaN, x, y); next_row(y);
        DispParam(obj, 'lastTrial', NaN, x, y); next_row(y);
        SubheaderParam(obj, 'lastHeader', 'Last Trial', x, y); next_row(y,1.5);
        
         
        DispParam(obj, 'currFoilCoh', NaN, x, y); next_row(y);
        DispParam(obj, 'currFoilDirn', NaN, x, y); next_row(y);
        DispParam(obj, 'currFoilSide', NaN, x, y); next_row(y);
        DispParam(obj, 'currFoilLum', NaN, x, y); next_row(y);      
        DispParam(obj, 'currFoilMatch', NaN, x, y); next_row(y);
        SubheaderParam(obj, 'lastHeader', 'Foil', x, y); next_row(y,1.5);

        %% Photo Stimulation Section
        ToggleParam(obj, 'photoStim', 0, x, y, 'OnString', 'Photo Stimulation On', ...
            'OffString', 'Photo Stimulation Off'); next_row(y);
        [x, y] = LaserControlSection(obj, 'init', x, y);
                
        %% Declares global variables
        %%% Global Variables Example
        % DeclareGlobals(obj, {'rw_args','leftValve'}, {'ro_args', 'rightValve'},{'owner', class(obj)});
        %%%
        DeclareGlobals(obj, 'rw_args', {'currStimSide', 'currCoher',...
            'currCorrLoop','currStimPos','currDensity','currSpeed','currSize','currLifeTime',...
            'currSoundSidesVolume','currStimDuration','currStimSizeDeg','currRandSeed',...
            'lastTimeOut','lastChoice','lastCorrect','lastStimSide','lastCoher','lastTrial',...
            'meanTimeOut','meanBias','meanBPos1','meanBPos2','meanAccu','meanAcPos1','meanAcPos2','meanSize','meanChoice','meanStimSide'...
            'timingsToggle','monitorToggle','stimulusToggle','trialToggle',...
            'biasToggle','soundToggle','treadmillToggle',...
            'timeOutHistory','coherHistory',...
            'positionHistory','correctHistory','stimSideHistory','choiceHistory','currTargetPos','currFoilPos','nonRandomSide',...
            'corrLoopV','photoStim', 'currBlockCount', 'currBlockLength', 'currBlockProbPos1Index',...
            'currFoilSide','currFoilCoh','currFoilMatch','currFoilDirn','currFoilLum','matchHistory','lastMatch',...
            'fixRatioRwdCnter','fixRatioRwdthisTrial'});

        % RESET POSITION F DISPATCHER
        a = findobj('type','figure');
        [~, c] = sort(a);
        %%% Dispatcher
        set(a(c(1)), 'position', [5 250 410 515]);
        
    %% Run section toggle button cases
    % Start
    case 'start'
        dispatcher('Run');
    % Stop    
    case 'stop'
        dispatcher('Stop');
    % Restart    
    case 'restart'
        dispatcher('restart_protocol');
    
    %% Additional IOs toggle whow/hide cases
    % Timings    
    case 'show_hide_timings',
        if value(timingsToggle) == 1, TimingsGUI(obj, 'show');
        else TimingsGUI(obj, 'hide');
        end

    % Monitor            
    case 'show_hide_monitor',
        if value(monitorToggle) == 1, MonitorGUI(obj, 'show');
        else MonitorGUI(obj, 'hide');
        end
    % Stimulus    
    case 'show_hide_stimulus',
        if value(stimulusToggle) == 1,  StimulusGUI(obj, 'show');
        else StimulusGUI(obj, 'hide');
        end
    % Trial    
    case 'show_hide_trial',
        if value(trialToggle) == 1, TrialGUI(obj, 'show');
        else TrialGUI(obj, 'hide');
        end
    % Bias    
    case 'show_hide_bias',
        if value(biasToggle) == 1, BiasGUI(obj, 'show');
        else BiasGUI(obj, 'hide');
        end
    % Sound    
    case 'show_hide_sound',
        if value(soundToggle) == 1, SoundGUI(obj, 'show');
        else SoundGUI(obj, 'hide');
        end
    % Sound    
    case 'show_hide_treadmill',
        if value(treadmillToggle) == 1, TreadmillGUI(obj, 'show');
        else TreadmillGUI(obj, 'hide');
        end        
        
    %% Configure pokesplot    
    case 'configure_pokesplot'
        %% Parameters for Pokesplot 
        % For plotting with the pokesplot plugin, we need to tell it what
        % colors to plot with:
        %  IMPORTANT: States in the StateMatrixSection (sma_states) should NOT have
        %  capitalized letters, if they do, the PokesPlot Plugin will not plot
        %  them. ex. waiting_4_cout works but Waiting_4_Cout will not...
        
        my_state_colors = struct( ...
            'waiting_for_run', [1 1 1], ...
            'running', [0 0 0], ...
            'pre_stimulus', [1 0 0], ...
            'resp_delay', [0 1 0], ...
            'response_window', [0 0 1], ...
            'time_out', [0 1 1], ...
            'correct_choice', [1 1 0], ...
            'wrong_choice', [1 0 1], ...
            'early_correct_choice', [0.8 0.8 0], ...
            'inter_trial_interval_wrong', [0.5 0.5 0.5], ...
            'inter_trial_interval_wait', [0.5 0.5 0.5], ...
            'inter_trial_interval', [0.5 0.5 0.5]);
        
        % In pokesplot, the poke colors have a default value, so we don't need
        % to specify them, but here they are so you know how to change them.
        %colors vary from 0 to 1 in RGB so [1 0 0] is red, [0 1 0] is green, [0 0 1] is blue and [1 1 1] is
        % white [0 0 0] is black, of course.
        my_event_colors = struct( ...
            'S',                  0.25*[1 0.66 0],    ...
            'P',                  0.5*[1 0.66 0],    ...    
            'L',                  0.75*[1 0.66 0],    ...
            'R',                  1*[1 0.66 0]);
        
        
    %% Closes protocol    
    case 'close',
        TimingsGUI(obj, 'close');
        MonitorGUI(obj, 'close');
        StimulusGUI(obj, 'close');
        TrialGUI(obj, 'close');
        BiasGUI(obj, 'close');
        SoundGUI(obj, 'close');
        TreadmillGUI(obj, 'close');
        
        if exist('main_fig', 'var') && isa(main_fig, 'SoloParamHandle') && ishandle(value(main_fig)),
            delete(value(main_fig));
        end;
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;

