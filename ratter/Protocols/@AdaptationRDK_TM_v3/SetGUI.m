function [] = SetGUI(obj, action)

GetSoloFunctionArgs;

persistent my_state_colors  my_event_colors 

        %      IMPORTANT: whatever data you want to save should be defined as a
        %      SoloParam object [whatever(obj, ....);], if you do NOT want to save
        %      things you can define it as whateverIdontwanttosave('base', ...);


switch action,
    
    %% CASE init
    case 'init',
                
        %% Set all additional GUIs
        TimingsGUI(obj, 'init');
        MonitorGUI(obj, 'init');
        StimulusGUI(obj,'init');
        
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
        set(value(main_fig), 'Position', [424 360 430 535]);
        
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
        SubheaderParam(obj, 'iosHeader', 'Additional IOs', x, y); next_row(y,1.5);         

                        
        %% Current trial section
        
        DispParam(obj, 'currRandSeedTest', NaN, x, y); next_row(y);        
        DispParam(obj, 'currTestDensity', NaN, x, y); next_row(y);                        
        DispParam(obj, 'currTestLifeTime', NaN, x, y); next_row(y);
        DispParam(obj, 'currTestSize', NaN, x, y); next_row(y);
        DispParam(obj, 'currTestSpeed', NaN, x, y); next_row(y);
        DispParam(obj, 'currTestCoher', NaN, x, y); next_row(y);
        SubheaderParam(obj, 'currentHeader3', 'Current Trial - Test Stim', x, y); next_row(y,1.5); 
        
        DispParam(obj, 'currRandSeedAdaptation', NaN, x, y); next_row(y);                
        DispParam(obj, 'currAdaptationDensity', NaN, x, y); next_row(y);                        
        DispParam(obj, 'currAdaptationLifeTime', NaN, x, y); next_row(y);
        DispParam(obj, 'currAdaptationSize', NaN, x, y); next_row(y);
        DispParam(obj, 'currAdaptationSpeed', NaN, x, y); next_row(y);
        DispParam(obj, 'currAdaptationCoher', NaN, x, y); next_row(y);
        SubheaderParam(obj, 'currentHeader2', 'Current Trial - Adaptation Stim', x, y); next_row(y,1.5); 
 
        DispParam(obj, 'currISI', NaN, x, y); next_row(y);                       
        DispParam(obj, 'currTestSide', NaN, x, y); next_row(y);               
        DispParam(obj, 'currAdaptationDuration', NaN, x, y); next_row(y);
        DispParam(obj, 'currAdaptationSide', NaN, x, y); next_row(y);
        SubheaderParam(obj, 'currentHeader1', 'Current Trial', x, y); next_row(y,1.5); 

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
        
        %% Other parameters section
        DispParam(obj, 'currStimSize', NaN, x, y); next_row(y);                       
        SubheaderParam(obj, 'otherHeader', 'Other Parameters', x, y); next_row(y,1.5); 
   
        %% Last trial section
        DispParam(obj, 'lastISI', NaN, x, y); next_row(y);                       
        DispParam(obj, 'lastTestSide', NaN, x, y); next_row(y);               
        DispParam(obj, 'lastAdaptationDuration', NaN, x, y); next_row(y);
        DispParam(obj, 'lastAdaptationSide', NaN, x, y); next_row(y);
        DispParam(obj, 'lastTrial', NaN, x, y); next_row(y);
        SubheaderParam(obj, 'lastHeader1', 'Last Trial', x, y); next_row(y,1.5); 
                
        %% Declares global variables
        %%% Global Variables Example
        % DeclareGlobals(obj, {'rw_args','leftValve'}, {'ro_args', 'rightValve'},{'owner', class(obj)});
        %%%
        DeclareGlobals(obj, 'rw_args', {'currAdaptationSide', 'currAdaptationDuration','currTestSide','currISI',...
            'currAdaptationCoher','currAdaptationSpeed','currAdaptationSize','currAdaptationLifeTime','currAdaptationDensity',...
            'currTestCoher','currTestSpeed','currTestSize','currTestLifeTime','currTestDensity',...
            'currRandSeedAdaptation','currRandSeedTest','lastISI','lastTestSide','lastAdaptationDuration','lastAdaptationSide',...
            'currStimSize','timingsToggle','monitorToggle','stimulusToggle','lastTrial'});
        
        % RESET POSITION F DISPATCHER
        a = findobj('type','figure');
        [~, c] = sort(a);
        %%% Dispatcher
        set(a(c(1)), 'position', [5 340 410 515]);
        
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
        
    %% Configure pokesplot    
    case 'configure_pokesplot'
        %% Parameters for Pokesplot 
        % For plotting with the pokesplot plugin, we need to tell it what
        % colors to plot with:
        %  IMPORTANT: States in the StateMatrixSection (sma_states) should NOT have
        %  capitalized letters, if they do, the PokesPlot Plugin will not plot
        %  them. ex. waiting_4_cout works but Waiting_4_Cout will not...
        
        my_state_colors = struct( ...
            'pre_stimulus', [1 0 0], ...
            'adaptation_stimulus', [0 1 0], ...
            'inter_stimulus_interval', [0 0 1], ...
            'test_stimulus', [0 1 1], ...
            'inter_trial_interval', [1 1 0]);
        
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
        if exist('main_fig', 'var') && isa(main_fig, 'SoloParamHandle') && ishandle(value(main_fig)),
            delete(value(main_fig));
        end;
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;

