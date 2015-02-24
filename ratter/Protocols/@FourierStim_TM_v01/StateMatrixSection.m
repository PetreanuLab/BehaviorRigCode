function  [] =  StateMatrixSection(obj, action)

global toolboxtrig scanimagetrig1 scanimagetrig2;

GetSoloFunctionArgs;

switch action
    %% Submit button was pressed
    case 'init',
                
        %% Sets state machine for first stimulus presentation
        StateMatrixSection(obj, 'next_trial');
        
        %% Sets state machine for next stimulus presentation
    case 'next_trial',
        
        if n_done_trials < value(stimRepetitions)
            
            % Sets up the assembler
            sma = StateMachineAssembler('full_trial_structure');
            
            %% Sets up the scheduled waves
            % Psychtoolbox trigger
            sma = add_scheduled_wave(sma,'name','toolbox_trigger',...
                'preamble',0.001,'sustain',0.001,...
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
            sma = add_state(sma, 'default_statechange', 'stimulus_presentation', 'self_timer', 0.001);
            % Baseline presentation - sends psychtoolbox and scan image trigger
            if n_done_trials == 0
                sma = add_state(sma, 'name', 'stimulus_presentation','self_timer', value(barPeriod),...
                    'output_actions', {'SchedWaveTrig','toolbox_trigger+scanimage_trigger_1'},...
                    'input_to_statechange', {'Tup', 'last_trigger'});
            else
                sma = add_state(sma, 'name', 'stimulus_presentation','self_timer', value(barPeriod),...
                    'output_actions', {'SchedWaveTrig','scanimage_trigger_1+scanimage_trigger_2'},...
                    'input_to_statechange', {'Tup', 'last_trigger'});
            end
            
            if n_done_trials +1 == value(stimRepetitions)
                % Inter trial interval
                sma = add_state(sma, 'name', 'last_trigger','self_timer',0.001,...
                    'output_actions', {'SchedWaveTrig','scanimage_trigger_2'},...
                    'input_to_statechange', {'Tup','check_next_trial_ready'});
            else
                sma = add_state(sma, 'name', 'last_trigger','self_timer',0.001,...
                    'input_to_statechange', {'Tup','check_next_trial_ready'});
            end
            
            %   dispatcher('send_assembler', sma, ...
            %   optional cell_array of strings specifying the prepare_next_trial states);
            dispatcher('send_assembler', sma, {'stimulus_presentation'});
        
        
        else
            
                        % Sets up the assembler
            sma = StateMachineAssembler('full_trial_structure');

            
            % State 0
            sma = add_state(sma, 'default_statechange', 'last_state', 'self_timer', 1);
            
            sma = add_state(sma, 'name', 'last_state','self_timer',0.001,...
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
