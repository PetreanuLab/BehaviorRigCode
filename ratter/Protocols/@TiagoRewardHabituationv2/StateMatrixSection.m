function  [] =  StateMatrixSection(obj, action)

global left1valve;
global right1valve;

GetSoloFunctionArgs;

switch action
    case 'init',
        
        if value(maxEqualChoices) ~=0
            lastChoices.value = ones(1,value(maxEqualChoices))/2;
        end

        StateMatrixSection(obj, 'next_trial');
        
    case 'next_trial',
        % Sets up the assembler
        sma = StateMachineAssembler('full_trial_structure');
        
        
        % sma = add_scheduled_wave(sma,'name','session_duration','preamble',value(sessionTime));
        
        % Sets up the state-machine
        sma = add_state(sma, 'default_statechange', 'waiting_for_lick', 'self_timer', 0.001);
        %         sma = add_state(sma, 'name', 'start_timer','self_timer', 0.001,...
        %             'output_actions', {'SchedWaveTrig', 'session_duration'},...
        %             'input_to_statechange', {'Tup','waiting_for_lick'});
        
        if ((strcmp(value(rewardLocation),'BOTH') && value(maxEqualChoices)~=0 && sum(value(lastChoices))==0) || strcmp(value(rewardLocation),'RIGHT'))
            % fprintf(1, 'Maximum number of left choices detected\n');
            sma = add_state(sma, 'name', 'waiting_for_lick',...
                'input_to_statechange', {'Rin','right_reward'});
        elseif ((strcmp(value(rewardLocation),'BOTH') && value(maxEqualChoices)~=0 && sum(value(lastChoices))== value(maxEqualChoices)) || strcmp(value(rewardLocation),'LEFT'))
            % fprintf(1, 'Maximum number of right choices detected\n');
            sma = add_state(sma, 'name', 'waiting_for_lick',...
                'input_to_statechange', {'Lin', 'left_reward'});
        else
            % fprintf(1, 'Good boy!\n');
            sma = add_state(sma, 'name', 'waiting_for_lick',...
                'input_to_statechange', {'Lin', 'left_reward','Rin','right_reward'});
        end
        
        sma = add_state(sma, 'name', 'left_reward','self_timer',value(valveTime),...
            'output_actions', {'DOut', left1valve},...
            'input_to_statechange', {'Tup', 'time_interval'});
        sma = add_state(sma, 'name', 'right_reward','self_timer',value(valveTime),...
            'output_actions', {'DOut', right1valve},...
            'input_to_statechange', {'Tup', 'time_interval'});
        sma = add_state(sma, 'name', 'time_interval','self_timer',value(rewardInterval),...
            'input_to_statechange', {'Tup','check_next_trial_ready'});
        
        % MANDATORY LINE:
        dispatcher('send_assembler', sma, {'time_interval'});
        
    case 'session_over'
        % Sets up the assembler
        sma = StateMachineAssembler('full_trial_structure');
        
        % Sets up the state-machine
        sma = add_state(sma, 'default_statechange', 'over', 'self_timer', 0.001);
        sma = add_state(sma, 'name', 'over');
        
        % MANDATORY LINE:
        dispatcher('send_assembler', sma, {'over'});
        
    case 'reinit',
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        
        % Reinitialise at the original GUI position and figure:
        feval(mfilename, obj, 'init');
        
        
    otherwise,
        warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action); %#ok<WNTAG>
        
end;














