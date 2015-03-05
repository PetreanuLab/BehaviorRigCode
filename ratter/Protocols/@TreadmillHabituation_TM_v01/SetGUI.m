function [] = SetGUI(obj, action)

GetSoloFunctionArgs;

persistent my_state_colors  my_event_colors 

        %      IMPORTANT: whatever data you want to save should be defined as a
        %      SoloParam object [whatever(obj, ....);], if you do NOT want to save
        %      things you can define it as whateverIdontwanttosave('base', ...);


switch action,
    
    %% CASE init
    case 'init',
        
        
        SoloParamHandle(obj,'choiceHistory','value',[]);
    
        %% Create protocol main figure
        % Make default figure. We remember to make it non-saveable; on next run
        % the handle to this figure might be different, and we don't want to
        % overwrite it when someone does load_data and some old value of the
        % fig handle was stored as SoloParamHandle "main_fig"
        SoloParamHandle(obj, 'main_fig', 'saveable', 0); main_fig.value = figure;
        
        % Make the title of the figure be the protocol name, and if someone tries
        % to close this figure, call dispatcher's close_protocol function, so it'll know
        % to take it off the list of open protocols.
        name = 'Treadmill Speed Test';
        set(value(main_fig), 'Name', name, 'Tag', name, ...
            'closerequestfcn', 'dispatcher(''close_protocol'')',...
                'MenuBar', 'none',    'NumberTitle', 'off');
        
        % Sets figure size and position
        set(value(main_fig), 'Position', [424 460 430 415]);
        
        % Initial position on main GUI window
        x=10; y=10;        

        %% Stimulus section
        SliderParam(obj, 'soundVolume', 5, 0, 10, x, y, 'TooltipString', 'Sound volume');next_row(y);
        ToggleParam(obj, 'rewardSound', 1, x, y, 'OnString', 'Sound On', ...
            'OffString', 'Sound Off'); next_row(y);
        SliderParam(obj, 'stimDuration', 0.8,0,5, x, y, 'TooltipString', 'Length in seconds of stimuli presentation.');next_row(y);
        ToggleParam(obj, 'visualStim', 1, x, y, 'OnString', 'Stimulus On', ...
            'OffString', 'Stimulus Off'); next_row(y);
        SubheaderParam(obj, 'rewardHeader', 'Stimulus Parameters', x, y); next_row(y,1.5);
        
        %% Reward section
        NumeditParam(obj, 'maxEqualChoices', 3, x, y, 'TooltipString', 'Maximum number of equal choices allowed in a row.');next_row(y);
        ToggleParam(obj, 'limitEqualChoices', 0, x, y, 'OnString', 'Limit On', ...
            'OffString', 'Limit Off'); next_row(y);
        MenuParam(obj, 'rewardLocation',{'BOTH','LEFT', 'RIGHT'}, 1, x, y, 'TooltipString', ...
            'Location of reward to be delivered',  'labelfraction', 0.5);next_row(y,1.2);
        NumeditParam(obj, 'leftRewardMult', 1, x, y, 'TooltipString', '');next_row(y);       
        NumeditParam(obj, 'rightRewardMult', 1, x, y, 'TooltipString', '');next_row(y);               
        NumeditParam(obj, 'valveTime', 0.03, x, y, 'TooltipString', 'For how long valve is open (seconds)');next_row(y,1);
        SubheaderParam(obj, 'rewardHeader', 'Reward Parameters', x, y); next_row(y,1.5); 

        %% Treadmill section       
        NumeditParam(obj, 'speedTreshold', 1.0, x, y);next_row(y);
        NumeditParam(obj, 'runLength', 2.0, x, y);next_row(y);
        SubheaderParam(obj, 'treadMillHeader', 'Treadmill Parameters', x, y); next_row(y,1.5); 

        %% Habituation Protocol section       
        MenuParam(obj, 'habituationProtocol',{'JUST_LICK','JUST_RUN', 'RUN_TO_LICK'}, 1, x, y, 'TooltipString', ...
            'Which habituation protocol is selected',  'labelfraction', 0.5);next_row(y,1.2);
        SubheaderParam(obj, 'habituationHeader', 'Habituation Protocol', x, y); next_row(y,1.5); 

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

        %% Timing Section
        NumeditParam(obj, 'ITI', 1, x, y, 'TooltipString', 'Time interval between rewards (seconds)');next_row(y);
        NumeditParam(obj, 'expireTime', 1, x, y, 'TooltipString', 'Time animal has to lick after successful run');next_row(y);
        SubheaderParam(obj, 'timingsHeader', 'Timings', x, y); next_row(y,1.5);


        %% Declares global variables
        %%% Global Variables Example
        % DeclareGlobals(obj, {'rw_args','leftValve'}, {'ro_args', 'rightValve'},{'owner', class(obj)});
        %%%
        DeclareGlobals(obj, 'rw_args', {'choiceHistory','maxEqualChoices','limitEqualChoices',...
            'rewardLocation','leftRewardMult','rightRewardMult','valveTime',...
            'speedTreshold', 'runLength','habituationProtocol',...
            'rewardSound','soundVolume','visualStim','stimDuration',...
            'ITI','expireTime'});

        
        % RESET POSITION F DISPATCHER
        a = findobj('type','figure');
        [~, c] = sort(a);
        %%% Dispatcher
        set(a(c(1)), 'position', [5 375 410 480]);
        
        
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
    
        
        
    %% Configure pokesplot    
    case 'configure_pokesplot'
        %% Parameters for Pokesplot 
        % For plotting with the pokesplot plugin, we need to tell it what
        % colors to plot with:
        %  IMPORTANT: States in the StateMatrixSection (sma_states) should NOT have
        %  capitalized letters, if they do, the PokesPlot Plugin will not plot
        %  them. ex. waiting_4_cout works but Waiting_4_Cout will not...
        
        my_state_colors = struct( ...
            'reset_arduino', [1 1 1], ...            
            'set_arduino', [1 0 0], ...
            'waiting_for_run', [0 1 0], ...
            'running', [0 0 1], ...
            'waiting_for_lick', [1 1 0], ...
            'left_reward', [1 0 1], ...
            'right_reward', [0 1 1], ...            
            'inter_trial_interval', [0 0 0]);
        
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
        if exist('main_fig', 'var') && isa(main_fig, 'SoloParamHandle') && ishandle(value(main_fig)),
            delete(value(main_fig));
        end;
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;

