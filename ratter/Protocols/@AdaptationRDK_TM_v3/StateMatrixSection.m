function  [] =  StateMatrixSection(obj, action)

global toolboxtrig;
global arduinotrig;
global arduinoreset;
global arduinospeed;
global scanimagetrig1;
global scanimagetrig2;
global leftvalve;
global rightvalve;

GetSoloFunctionArgs;

switch action
    case 'init',
        
        SupportFunctions(obj,'set_next_timings');
        SupportFunctions(obj,'set_next_stim');
        SupportFunctions(obj,'set_next_adaptation');
        SupportFunctions(obj,'set_next_test');
        SupportFunctions(obj,'param_save');
        
        StateMatrixSection(obj, 'next_trial');
        
    case 'next_trial',
        %%
        %%%%%%%%%%%%%%%%%% State Machine Configuration %%%%%%%%%%%%%%%%%%%%%%%%%
        %% Sets up the assembler
        sma = StateMachineAssembler('full_trial_structure');
        
        %% Sets up the scheduled waves
        % Psychtoolbox triggers
        sma = add_scheduled_wave(sma,'name','stimulus_trigger',...
            'preamble',0.001,'sustain',0.001,...
            'DOut',toolboxtrig);
        
        % Scan Image trigger
        sma = add_scheduled_wave(sma,'name','scanimage_trigger_1',...
            'preamble',0.001,'sustain',0.016,...
            'DOut',scanimagetrig1);
        sma = add_scheduled_wave(sma,'name','scanimage_trigger_2',...
            'preamble',0.001,'sustain',0.016,...
            'DOut',scanimagetrig2);
        
        
        % Arduino triggers
        sma = add_scheduled_wave(sma,'name','arduino_trigger',...
            'preamble',0.001,'sustain',0.001,...
            'DOut',arduinotrig);
        sma = add_scheduled_wave(sma,'name','arduino_speed',...
            'preamble',0.005,'sustain',30*2/1000,...
            'DOut',arduinospeed);
        sma = add_scheduled_wave(sma,'name','arduino_reset',...
            'preamble',0.001,'sustain',0.001,...
            'DOut',arduinoreset);
                
        % Valve scheduled wave
        sma = add_scheduled_wave(sma,'name','left_trigger',...
            'preamble',value(valvePeriod)*rand(1),'sustain',value(valveDuration),...
            'DOut',leftvalve);
        % Valve scheduled wave
        sma = add_scheduled_wave(sma,'name','right_trigger',...
            'preamble',value(valvePeriod)*rand(1),'sustain',value(valveDuration),...
            'DOut',rightvalve);
        
        if rand <0.5
            valve_trigger='left_trigger';
        else
            valve_trigger='right_trigger';
        end
        
        %% Sets up the states-machine
        % Default state
        % If first trial, resets Arduino
        if(n_done_trials==0)
            sma = add_state(sma, 'default_statechange', 'set_session', 'self_timer', 0.001);
            sma = add_state(sma, 'name', 'set_session','self_timer',0.100,...
                'output_actions', {'SchedWaveTrig','arduino_reset'},...
                'input_to_statechange', {'Tup','set_trial'});
            % Otherwise does nothing
        else
            sma = add_state(sma, 'default_statechange', 'set_trial', 'self_timer', 0.001);
%             sma = add_state(sma, 'name', 'set_session','self_timer',0.100,...
%                 'output_actions', {'SchedWaveTrig','scanimage_trigger_2'},...
%                 'input_to_statechange', {'Tup','set_trial'});
        end
        
        % Set trial state
        % Tells arduino a new trial has started and loads stimulus
        sma = add_state(sma, 'name', 'set_trial','self_timer',0.001,...
            'output_actions', {'SchedWaveTrig','arduino_trigger+arduino_speed+stimulus_trigger'},...
            'input_to_statechange', {'Tup','pre_stimulus'});
        
        % Pre stimulus state
        % Waits before presenting and sends trigger to 2-photon
        if n_done_trials == 0
            sma = add_state(sma, 'name', 'pre_stimulus','self_timer', value(preAdaptation),...
                'output_actions', {'SchedWaveTrig','scanimage_trigger_1'},...
                'input_to_statechange', {'Tup', 'adaptation_stimulus'});
        else
            sma = add_state(sma, 'name', 'pre_stimulus','self_timer', value(preAdaptation),...
                'output_actions', {'SchedWaveTrig','scanimage_trigger_1+scanimage_trigger_2'},...
                'input_to_statechange', {'Tup', 'adaptation_stimulus'});
        end
        
        % Adaptation stimulus state
        % Presents adaptation stimulus
        sma = add_state(sma, 'name', 'adaptation_stimulus','self_timer', value(currAdaptationDuration),...
            'output_actions', {'SchedWaveTrig',['stimulus_trigger+',valve_trigger]},...
            'input_to_statechange', {'Tup', 'inter_stimulus_interval'});
        
        % ISI state
        % Waits ISI
        sma = add_state(sma, 'name', 'inter_stimulus_interval','self_timer', value(currISI),...
            'input_to_statechange', {'Tup', 'test_stimulus'});
        
        % Test stimulus state
        % Presents test stimulus
        sma = add_state(sma, 'name', 'test_stimulus','self_timer', value(testDuration),...
            'output_actions', {'SchedWaveTrig','stimulus_trigger'},...
            'input_to_statechange', {'Tup', 'inter_trial_interval'});
        
        % Inter trial interval state
        % Loads next trial stimulus and waits ITI before ending the trial
        sma = add_state(sma, 'name', 'inter_trial_interval','self_timer',value(ITI),...
            'input_to_statechange', {'Tup','check_next_trial_ready'});
        
        
        %% Sends state machine to the assembler
        dispatcher('send_assembler', sma, {'inter_trial_interval'});
        
        
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
