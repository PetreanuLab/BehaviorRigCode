function [] = SetGUI(obj, action)

GetSoloFunctionArgs;

persistent my_state_colors  my_event_colors


switch action,
    
    case 'init',
        
        %% Initiates 
        SoloParamHandle(obj,'stimDirHistory','value',[]);
        
        SoloParamHandle(obj,'stimTypeHistory','value',{});        

        SoloParamHandle(obj,'gratTempFreqHistory','value',[]);
        SoloParamHandle(obj,'gratSpatFreqHistory','value',[]);
        SoloParamHandle(obj,'gratTypeHistory','value',{});
 
        SoloParamHandle(obj,'dotCoherHistory','value',[]);
        SoloParamHandle(obj,'dotLifeTimeHistory','value',[]);
        SoloParamHandle(obj,'dotSizeHistory','value',[]);
        SoloParamHandle(obj,'dotSpeedHistory','value',[]);
        SoloParamHandle(obj,'dotDensityHistory','value',[]);
        
        
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
        
        set(value(main_fig), 'Position', [423 396 430 660]);
        % Starting coordinates
        x=10; y=10;
        
        %
        
        %% Setup Menu
        NumeditParam(obj, 'screenWidthPx', 1920, x, y, 'TooltipString', ...
            '...');next_row(y);
        NumeditParam(obj, 'screenHeightPx', 1080, x, y, 'TooltipString', ...
            '...');next_row(y);
        NumeditParam(obj, 'diagIn', 24, x, y, 'TooltipString', ...
            '...');next_row(y);
        NumeditParam(obj, 'viewingDistCm', 20, x, y, 'TooltipString', ...
            '...');next_row(y);
        SubheaderParam(obj, 'setupMenu', 'Setup Configuration', x, y); next_row(y,1.5);
        
        
        %% Stimulus Menu
        SliderParam(obj, 'backLight', 0, 0,255, x, y, 'TooltipString', 'Level of brightness of background.');next_row(y);
        SliderParam(obj, 'stimLight', 255, 0,255, x, y, 'TooltipString', 'Level of brightness of stimulus.');next_row(y);
        NumeditParam(obj, 'centreY', 540, x, y, 'TooltipString', ...
            '...');next_row(y);
        NumeditParam(obj, 'centreX', 960, x, y, 'TooltipString', ...
            '...');next_row(y);
        NumeditParam(obj, 'patchDegProb', [0 0 0 0 0 0 1], x, y, 'TooltipString', 'Array with coherences probabilities');next_row(y);
        NumeditParam(obj, 'patchDeg', [5 10 20 30 50 80 120], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        MenuParam(obj, 'ITI', {'0.001','0.5','1','2','3','5','8','10'},2, x, y, 'TooltipString',...
            '',  'labelfraction', 0.5);next_row(y);
        MenuParam(obj, 'stimLength',{'0.5','1','2','3','4','5','8','10'}, 2, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        MenuParam(obj, 'baseLength',{'0.001','0.5','1','2','3','5','8','10'}, 2, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);        
        NumeditParam(obj, 'stimRepetition', 100, x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        
        NumeditParam(obj, 'stimDirProb', [1 0 1 0 1 0 1 0], x, y, 'TooltipString', 'Array with coherences probabilities');next_row(y);
        NumeditParam(obj, 'stimDir', [0 45 90 135 180 225 270 315], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        
        MenuParam(obj, 'stimType',{'Random Dot','Grating'}, 'Random Dot', x, y, 'TooltipString', ...
            '',  'labelfraction', 0.5);next_row(y);
        SubheaderParam(obj, 'setupMenu', 'Stimulus Properties', x, y); next_row(y,1.5);
        
       
        DispParam(obj, 'currDotDensity', NaN, x, y); next_row(y);
        DispParam(obj, 'currDotSpeed', NaN, x, y); next_row(y);        
        DispParam(obj, 'currDotSize', NaN, x, y); next_row(y);
        DispParam(obj, 'currDotLifeTime', NaN, x, y); next_row(y);
        DispParam(obj, 'currDotCoher', NaN, x, y); next_row(y);
        DispParam(obj, 'currGratSpatFreq', NaN, x, y); next_row(y);
        DispParam(obj, 'currGratTempFreq', NaN, x, y); next_row(y);
        DispParam(obj, 'currGratType', NaN, x, y); next_row(y);
        DispParam(obj, 'currPatchDeg', 0, x, y); next_row(y);        
        DispParam(obj, 'currStimType', NaN, x, y); next_row(y);        
        DispParam(obj, 'currStimDir', NaN, x, y); next_row(y);
        DispParam(obj, 'currStimNum', 0, x, y); next_row(y);
        SubheaderParam(obj, 'currentTrial', 'Current Trial', x, y); next_row(y,1.5);
        
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

        
        %% Random Dot menu - HERE
        NumeditParam(obj, 'dotDensity', [0.05 0.1 0.15 0.2 0.3], x, y, 'TooltipString', 'Array with coherences probabilities');next_row(y);               
        NumeditParam(obj, 'dotDensityProb', [0 0 1 0 0], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        NumeditParam(obj, 'dotSpeed', [1 10 25 60 100], x, y, 'TooltipString', 'Array with coherences probabilities');next_row(y);                
        NumeditParam(obj, 'dotSpeedProb', [0 0 1 0 0], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        NumeditParam(obj, 'dotSize', [3 2 1.5 1 0.5 0.1], x, y, 'TooltipString', 'Array with coherences probabilities');next_row(y);        
        NumeditParam(obj, 'dotSizeProb', [0 1 0 0 0 0], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        NumeditParam(obj, 'dotLifeTime', [120 60 30 24 12 6], x, y, 'TooltipString', 'Array with coherences probabilities');next_row(y);
        NumeditParam(obj, 'dotLifeTimeProb', [1 0 0 0 0 0], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        NumeditParam(obj, 'dotCoher', [100 39.8 15.8 6.3 2.5 0], x, y, 'TooltipString', 'Array with coherences probabilities');next_row(y);
        NumeditParam(obj, 'dotCoherProb', [1 0 0 0 0 0], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
       
        SubheaderParam(obj, 'randomDotMenu', 'Random Dot Parameters', x, y); next_row(y,1.5);
        
        %% Grating menu
        NumeditParam(obj, 'gratSpatFreq', [0.02 0.04 0.08 0.12 0.16 0.32], x, y, 'TooltipString', 'Array with coherences probabilities');next_row(y);
        NumeditParam(obj, 'gratSpatFreqProb', [0 0 1 0 0 0], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        NumeditParam(obj, 'gratTempFreq', [0.5 1 2 4 8 16], x, y, 'TooltipString', 'Array with coherences probabilities');next_row(y);
        NumeditParam(obj, 'gratTempFreqProb', [0 0 0 0 1 0], x, y, 'TooltipString', 'Array with available coherences');next_row(y);
        MenuParam(obj, 'gratType',{'sin','square'}, 'sin', x, y, 'TooltipString', ...
            'Sinusoidal or square-wave grating ',  'labelfraction', 0.5); next_row(y);
        SubheaderParam(obj, 'gratingMenu', 'Grating Parameters', x, y); next_row(y,1.5);
       
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
        
        %% Declares global variables
        %%% Global Variables Example
        % DeclareGlobals(obj, {'rw_args','leftValve'}, {'ro_args', 'rightValve'},{'owner', class(obj)});
        %%%
        DeclareGlobals(obj, 'rw_args', {...
            'stimDirHistory','stimTypeHistory',...
            'gratTempFreqHistory','gratSpatFreqHistory','gratTypeHistory',...
            'dotCoherHistory','dotLifeTimeHistory','dotSizeHistory','dotSpeedHistory','dotDensityHistory',...
            'screenWidthPx','screenHeightPx','diagIn','viewingDistCm',...
            'backLight', 'stimLight','centreY','centreX','patchDeg',...
            'ITI','stimLength','baseLength','stimRepetition','stimType',...
            'stimDirProb','stimDir',...
            'currStimNum','currStimDir','currStimType','currPatchDeg'...
            'currGratTempFreq','currGratSpatFreq','currGratType',...
            'currDotDensity','currDotSpeed','currDotSize','currDotLifeTime','currDotCoher',...            
            'dotDensity','dotSpeed','dotSize','dotLifeTime','dotCoher',...
            'dotDensityProb','dotSpeedProb','dotSizeProb','dotLifeTimeProb','dotCoherProb',...
            'gratSpatFreq','gratTempFreq','gratSpatFreqProb','gratTempFreqProb','gratType','patchDegProb'});
        
        %% RESET POSITION F DISPATCHER AND POKESPLOT
        a = findobj('type','figure');
        [~, c] = sort(a);
        %%% Dispatcher
        set(a(c(1)), 'position', [5 395 410 460]);
        %%% PokesPlot
         %set(a(c(3)), 'position', [0.1      0.0275     0.8       0.815]);
        
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
            'prepare_stimulus', [1 0 0], ...
            'baseline_presentation', [0 1 0], ...
            'stimulus_presentation', [0 0 1], ...
            'inter_trial_interval', [0 1 1]);
        
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

