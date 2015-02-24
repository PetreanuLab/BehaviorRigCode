

function  [] =  StateMatrixSection(obj, action)

global toolboxtrig scanimagetrig1 scanimagetrig2;

GetSoloFunctionArgs(obj);

switch action
    %% Submit button was pressed
    case 'init',
        
        %% Runs all 3 support functions before setting the state machine
        SupportFunctions(obj,'set_session');
        SupportFunctions(obj,'set_next_stim');
        SupportFunctions(obj,'param_save');
        
        %% Sets state machine for first stimulus presentation
        StateMatrixSection(obj, 'next_trial');
        
        %% Sets state machine for next stimulus presentation
    case 'next_trial',
        
        if n_done_trials < value(totTrial)
            
            % Sets up the assembler
            sma = StateMachineAssembler('full_trial_structure');
            
            %% Sets up the scheduled waves
            % Psychtoolbox trigger
            sma = add_scheduled_wave(sma,'name','toolbox_trigger',...
                'preamble',0.001,'sustain',0.001,...
                'DOut',toolboxtrig);
            sma = add_scheduled_wave(sma,'name','toolbox_trigger_delay',...
                'preamble',0.2,'sustain',0.001,...
                'DOut',toolboxtrig);
            % Scan Image trigger
            sma = add_scheduled_wave(sma,'name','scanimage_trigger_1',...
                'preamble',0.001,'sustain',0.016,...
                'DOut',scanimagetrig1);
            
            sma = add_scheduled_wave(sma,'name','scanimage_trigger_2',...
                'preamble',0.001,'sustain',0.016,...
                'DOut',scanimagetrig2);
            
            
            %% Sets up the state-machine
            % State 0
            sma = add_state(sma, 'default_statechange', 'load_stimulus', 'self_timer', 0.001);
            if n_done_trials == 0
                % Load stimulus - sends psychtoolbox trigger
                sma = add_state(sma, 'name', 'load_stimulus','self_timer', value(ITI),...
                'output_actions', {'SchedWaveTrig','toolbox_trigger'},...                    
                    'input_to_statechange', {'Tup', 'baseline'});
                % Baseline presentation - sends psychtoolbox and scan image trigger
                
                sma = add_state(sma, 'name', 'baseline','self_timer', value(baseLength),...
                    'output_actions', {'SchedWaveTrig','scanimage_trigger_1'},...
                    'input_to_statechange', {'Tup', 'stim_pres'});
            else
                % Load stimulus - sends psychtoolbox trigger
                sma = add_state(sma, 'name', 'load_stimulus','self_timer', value(loadTime),...
                    'input_to_statechange', {'Tup', 'baseline'});
                % Baseline presentation - sends psychtoolbox and scan image trigger
                
                sma = add_state(sma, 'name', 'baseline','self_timer', value(baseLength),...
                    'output_actions', {'SchedWaveTrig','scanimage_trigger_1+scanimage_trigger_2'},...
                    'input_to_statechange', {'Tup', 'stim_pres'});
            end
            % Stimulus presentation
            sma = add_state(sma, 'name', 'stim_pres','self_timer', value(stimLength),...
                'output_actions', {'SchedWaveTrig','toolbox_trigger'},...
                'input_to_statechange', {'Tup', 'ITI_pres'});
            
            sma = add_state(sma, 'name', 'ITI_pres','self_timer',value(ITI),...
                'output_actions', {'SchedWaveTrig','toolbox_trigger_delay'},...
                'input_to_statechange', {'Tup','last_trigger'});
            
            if n_done_trials +1 == value(totTrial)
                % Inter trial interval
                sma = add_state(sma, 'name', 'last_trigger','self_timer',0.1,...
                    'output_actions', {'SchedWaveTrig','scanimage_trigger_2'},...
                    'input_to_statechange', {'Tup','check_next_trial_ready'});
            else
                sma = add_state(sma, 'name', 'last_trigger','self_timer',0.1,...
                    'input_to_statechange', {'Tup','check_next_trial_ready'});
            end
                        
            %   dispatcher('send_assembler', sma, ...
            %   optional cell_array of strings specifying the prepare_next_trial states);
            dispatcher('send_assembler', sma, {'stim_pres'});
            
            
        else
            
            % Sets up the assembler
            sma = StateMachineAssembler('full_trial_structure');
            
            
            % State 0
            sma = add_state(sma, 'default_statechange', 'last_state', 'self_timer', 1);
            
            sma = add_state(sma, 'name', 'last_state','self_timer',0.01,...
                'input_to_statechange', {'Tup','check_next_trial_ready'});
            
            %   dispatcher('send_assembler', sma, ...
            %   optional cell_array of strings specifying the prepare_next_trial states);
            dispatcher('send_assembler', sma, {'last_state'});
            
            
        end
        
    case 'reinit',
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        
        % Reinitialise at the original GUI position and figure:
        feval(mfilename, obj, 'init');
        
        
    otherwise,
        warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action); %#ok<WNTAG>
        
        
end
