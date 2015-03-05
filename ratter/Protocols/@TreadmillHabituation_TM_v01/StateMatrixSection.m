function  [] =  StateMatrixSection(obj, action)

global arduinotrig;
global arduinospeed;
global arduinoreset;
global leftvalve;
global rightvalve;
global toolboxtrig;


GetSoloFunctionArgs;

switch action
    case 'init',
        
        StateMatrixSection(obj, 'next_trial');
        
    case 'next_trial',
        
        if strcmp(value(rewardLocation),'LEFT')
            lick_event = {'Lin','left_reward'};
            forced_reward = 'left_reward';
        elseif strcmp(value(rewardLocation),'RIGHT')
            lick_event = {'Rin','right_reward'};
            forced_reward = 'right_reward';
        elseif (value(limitEqualChoices) && (n_done_trials >= value(maxEqualChoices)))
            if sum(choiceHistory((end-value(maxEqualChoices)+1):end))== 0
                lick_event = {'Lin','left_reward'};
                forced_reward = 'left_reward';
            elseif sum(choiceHistory((end-value(maxEqualChoices)+1):end))== value(maxEqualChoices)
                lick_event = {'Rin','right_reward'};
                forced_reward = 'right_reward';
            else
                lick_event = {'Lin','left_reward','Rin','right_reward'};
                if rand<0.5
                    forced_reward = 'left_reward';
                else
                    forced_reward = 'right_reward';
                end
            end
        else
            lick_event = {'Lin','left_reward','Rin','right_reward'};
            if rand<0.5
                forced_reward = 'left_reward';
            else
                forced_reward = 'right_reward';
            end
        end
        
        %%
        %%%%%%%%%%%%%%%%%% State Machine Configuration %%%%%%%%%%%%%%%%%%%%%%%%%
        %% Sets up the assembler
        sma = StateMachineAssembler('full_trial_structure');
        
        %% Sets up the scheduled waves
        % Arduino triggers
        sma = add_scheduled_wave(sma,'name','arduino_trigger',...
            'preamble',0.001,'sustain',0.001,...
            'DOut',arduinotrig);
        sma = add_scheduled_wave(sma,'name','arduino_speed',...
            'preamble',0.005,'sustain',value(speedTreshold)*2/1000,...
            'DOut',arduinospeed);
        sma = add_scheduled_wave(sma,'name','arduino_reset',...
            'preamble',0.001,'sustain',0.001,...
            'DOut',arduinoreset);
        % Valve triggers
        sma = add_scheduled_wave(sma,'name','left_reward_delivery',...
            'preamble',0.001,'sustain',value(valveTime)*value(leftRewardMult),...
            'DOut',leftvalve);
        sma = add_scheduled_wave(sma,'name','right_reward_delivery',...
            'preamble',0.001,'sustain',value(valveTime)*value(rightRewardMult),...
            'DOut',rightvalve);
        % Psychtoolbox triggers
        sma = add_scheduled_wave(sma,'name','stimulus_trigger',...
            'preamble',0.001,'sustain',0.001,...
            'DOut',toolboxtrig,...
            'trigger_on_up','stimulus_timer');
         sma = add_scheduled_wave(sma,'name','stimulus_timer',...
            'preamble',value(stimDuration),...
            'trigger_on_up','stimulus_stop');
         sma = add_scheduled_wave(sma,'name','stimulus_stop',...
            'preamble',0.001,'sustain',0.001,...
            'DOut',toolboxtrig);

        %% Sets up the states-machine
        % Default state
        % Does nothing
        if(n_done_trials==0)
            sma = add_state(sma, 'default_statechange', 'reset_arduino', 'self_timer', 0.001);
            sma = add_state(sma, 'name', 'reset_arduino','self_timer',0.100,...
                'output_actions', {'SchedWaveTrig','arduino_reset'},...
                'input_to_statechange', {'Tup','set_arduino'});
        else
            sma = add_state(sma, 'default_statechange', 'set_arduino', 'self_timer', 0.001);
        end
        
        if strcmp(value(habituationProtocol),'JUST_LICK')
            sma = add_state(sma, 'name', 'set_arduino','self_timer',0.001,...
                'output_actions', {'SchedWaveTrig','arduino_trigger+arduino_speed'},...
                'input_to_statechange', {'Tup','waiting_for_lick'});
            
            sma = add_state(sma, 'name', 'waiting_for_lick',...
                'input_to_statechange', lick_event);

        else
            sma = add_state(sma, 'name', 'set_arduino','self_timer',0.001,...
                'output_actions', {'SchedWaveTrig','arduino_trigger+arduino_speed'},...
                'input_to_statechange', {'Tup','waiting_for_run'});
            
            sma = add_state(sma, 'name', 'waiting_for_run',...
                'input_to_statechange', {'Sin','running'});
            
            sma = add_state(sma, 'name', 'running','self_timer',value(runLength),...
                'input_to_statechange', {'Tup','done_with_running','Sout','waiting_for_run'});
            
            if strcmp(value(habituationProtocol),'JUST_RUN')
                if value(visualStim)
                    sma = add_state(sma, 'name', 'done_with_running','self_timer',0.001,...
                        'output_actions', {'SchedWaveTrig','stimulus_trigger'},...
                        'input_to_statechange', {'Tup',forced_reward});
                else
                    sma = add_state(sma, 'name', 'done_with_running','self_timer',0.001,...
                        'input_to_statechange', {'Tup',forced_reward});
                end
            elseif strcmp(value(habituationProtocol),'RUN_TO_LICK')
                if value(visualStim)
                    sma = add_state(sma, 'name', 'done_with_running','self_timer',0.001,...
                        'output_actions', {'SchedWaveTrig','stimulus_trigger'},...
                        'input_to_statechange', {'Tup','waiting_for_lick'});
                else
                    sma = add_state(sma, 'name', 'done_with_running','self_timer',0.001,...
                        'input_to_statechange', {'Tup','waiting_for_lick'});
                end
                
             sma = add_state(sma, 'name', 'waiting_for_lick','self_timer',value(expireTime),...
            'input_to_statechange', {'Tup','waiting_for_run',lick_event{:}});
    
            end
            
        end
        
        
        sma = add_state(sma, 'name', 'left_reward','self_timer',0.001,...
            'output_actions', {'SchedWaveTrig','left_reward_delivery'},...
            'input_to_statechange', {'Tup', 'inter_trial_interval'});
        
        sma = add_state(sma, 'name', 'right_reward','self_timer',0.001,...
            'output_actions', {'SchedWaveTrig','right_reward_delivery'},...
            'input_to_statechange', {'Tup', 'inter_trial_interval'});
        
        sma = add_state(sma, 'name', 'inter_trial_interval','self_timer',value(ITI),...
            'input_to_statechange', {'Tup','check_next_trial_ready'});
        
        
        %% Sends state machine to the assembler
        dispatcher('send_assembler', sma, {'left_reward','right_reward'});
        
        
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
