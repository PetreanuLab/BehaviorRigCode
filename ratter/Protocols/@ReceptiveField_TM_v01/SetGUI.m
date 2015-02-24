function [] = SetGUI(obj, action)

GetSoloFunctionArgs(obj);

persistent my_state_colors  my_event_colors

switch action,
    
    case 'init',
        
        %% Initiates
        %% Create protocol main figure
        % Make default figure. We remember to make it non-saveable; on next run
        % the handle to this figure might be different, and we don't want to
        % overwrite it when someone does load_data and some old value of the
        % fig handle was stored as SoloParamHandle "main_fig"
        SoloParamHandle(obj, 'main_fig', 'saveable', 0); main_fig.value = figure;
        
        % Make the title of the figure be the protocol name, and if someone tries
        % to close this figure, call dispatcher's close_protocol function, so it'll know
        % to take it off the list of open protocols.
        name = 'Stimulus Presentation';
        set(value(main_fig), 'Name', name, 'Tag', name, ...
            'closerequestfcn', 'dispatcher(''close_protocol'')', ...
            'MenuBar', 'none', 'NumberTitle', 'off');
        
        set(value(main_fig), 'Position', [423 396 430 480]);
        % Starting coordinates
        x=10; y=10;
        
        %
        
        %% Setup Menu
        NumeditParam(obj, 'screenSizePx', [1920 1080], x, y, 'TooltipString', ...
            '...');next_row(y);
        NumeditParam(obj, 'diagIn', 24, x, y, 'TooltipString', ...
            '...');next_row(y);
        NumeditParam(obj, 'viewingDistCm', 30, x, y, 'TooltipString', ...
            '...');next_row(y);
        SubheaderParam(obj, 'setupMenu', 'Monitor Configuration', x, y); next_row(y,1.5);
        
        %% Grid Menu
        NumeditParam(obj, 'cellSizeDeg', 10, x, y, 'TooltipString', ...
            '...');next_row(y);
        NumeditParam(obj, 'gridCells', [10 6], x, y, 'TooltipString', ...
            '...');next_row(y);
        NumeditParam(obj, 'viewCenterCm', [0 0], x, y, 'TooltipString', ...
            '...');next_row(y);
        NumeditParam(obj, 'gridCenterDeg', [0 0], x, y, 'TooltipString', ...
            '...');next_row(y);        
        NumeditParam(obj, 'gridRepetition', 4, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        SubheaderParam(obj, 'gridMenu', 'Grid Configuration', x, y); next_row(y,1.5);
        
        
        %% Timing Menu
        NumeditParam(obj, 'ITI', 2, x, y, 'TooltipString',...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'stimLength',1, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'baseLength',1, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'loadTime', 0.2, x, y, 'TooltipString',...
            '',  'labelfraction', 0.5);next_row(y);
        SubheaderParam(obj, 'timeMenu', 'Time Configuration', x, y); next_row(y,1.5);
        
        %% Stim Menu
        SliderParam(obj, 'backLight', 0, 0,255, x, y, 'TooltipString', 'Level of brightness of background.');next_row(y);
        SliderParam(obj, 'stimLight', 255, 0,255, x, y, 'TooltipString', 'Level of brightness of stimulus.');next_row(y);
        NumeditParam(obj, 'stimDir', [0 45 90 135 180 225 270 315], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        NumeditParam(obj, 'barWidth',2, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        NumeditParam(obj, 'barSpeed',25, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        SubheaderParam(obj, 'setupMenu', 'Stimulus Properties', x, y); next_row(y,1.5);
        
        next_column(x); y=10;
        
        %% Saving section
        [x, y] = SavingSectionNonInteractive(obj, 'init', x, y);
        
        next_row(y,0.4);
        
        %% Analyses Section
        % Configures PokesPlotSection
        SetGUI(obj, 'configure_pokesplot');
        
        % Initiates PokesPlotSection
        [x, y] = PokesPlotSection(obj, 'init', x, y, ...
            struct('states',  my_state_colors, 'pokes', my_event_colors));
        PokesPlotSection(obj, 'hide');
        
        SubheaderParam(obj, 'analysesHeader', 'Analyses', x, y); next_row(y,1.5);
        

        %% Submit push and restart buttons
        % Run
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
        
                        %% Display
        DispParam(obj, 'gridRangeDeg', NaN, x, y); next_row(y);
        DispParam(obj, 'gridSizeDeg', NaN, x, y); next_row(y);
        DispParam(obj, 'currDir', NaN, x, y); next_row(y);
        DispParam(obj, 'currGridPos', [NaN NaN], x, y); next_row(y);
        DispParam(obj, 'currGrid', 0, x, y); next_row(y);
        DispParam(obj, 'totTrial', 0, x, y); next_row(y);        
        DispParam(obj, 'currTrial', 0, x, y); next_row(y);
        SubheaderParam(obj, 'currentTrial', 'Current Trial', x, y); next_row(y,1.5);

        
        %% Declares global variables
        %%% Global Variables Example
        DeclareGlobals(obj, 'rw_args', {...
            'screenSizePx','diagIn','viewingDistCm',...
            'gridCells','gridCenterDeg','viewCenterCm','gridRepetition',...
            'ITI','stimLength','baseLength','loadTime',...
            'backLight','stimLight','stimDir','barWidth','barSpeed',...
            'cellSizeDeg','gridSizeDeg','gridRangeDeg','currDir','currGridPos','currGrid','currTrial','totTrial'});
        
        %% RESET POSITION F DISPATCHER AND POKESPLOT
        a = findobj('type','figure');
        [~, c] = sort(a);
        %%% Dispatcher
        set(a(c(1)), 'position', [5 395 410 460]);
        %%% PokesPlot
        % set(a(c(3)), 'position', [0.1      0.0275     0.8       0.815]);
        
    case 'start'
        dispatcher('Run');
        
    case 'stop'
        dispatcher('Stop');
        
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
            'load_stimulus', [1 0 0], ...
            'baseline', [0 1 0], ...
            'stim_pres', [0 0 1], ...
            'ITI_pres', [0 1 1]);
        
        % In pokesplot, the poke colors have a default value, so we don't need
        % to specify them, but here they are so you know how to change them.
        %colors vary from 0 to 1 in RGB so [1 0 0] is red, [0 1 0] is green, [0 0 1] is blue and [1 1 1] is
        % white [0 0 0] is black, of course.
        my_event_colors = struct( ...
            'S',                  0.25*[1 0.66 0],    ...
            'P',                  0.5*[1 0.66 0],    ...
            'L',                  0.75*[1 0.66 0],    ...
            'R',                  1*[1 0.66 0]);
        
    case 'close',
        if exist('main_fig', 'var') && isa(main_fig, 'SoloParamHandle') && ishandle(value(main_fig)),
            delete(value(main_fig));
        end;
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
end;

