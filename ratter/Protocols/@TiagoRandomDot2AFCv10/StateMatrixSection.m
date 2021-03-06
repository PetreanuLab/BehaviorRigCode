function  [] =  StateMatrixSection(obj, action)

global center1valve;
global left1valve;
global right1valve;

GetSoloFunctionArgs;

switch action
    case 'init',
        
        SupportFunctions(obj,'random_variables');
        
        SupportFunctions(obj,'param_save');
        
        StateMatrixSection(obj, 'next_trial');
        
    case 'next_trial',
        
        if value(side)
            correctChoice = 'Lin';
            wrongChoice = 'Rin';
            reward = left1valve;
            valveTime = value(valveTimeLeft);
        else
            correctChoice = 'Rin';
            wrongChoice = 'Lin';
            reward = right1valve;
            valveTime = value(valveTimeRight);
        end
        
        if strcmp(value(ITI),'RANDOM')
            ITIValue = rand()* (value(ITIMax)-0.5) + 0.5;
        else
            ITIValue = value(ITI);
        end
        
        % Sets up the assembler
        sma = StateMachineAssembler('full_trial_structure');
        
        % Sets up the scheduled waves
        sma = add_scheduled_wave(sma,'name','reward_delivery',...
            'preamble',0.001,'sustain',valveTime,...
            'DOut',reward);
        
        % Sets up the state-machine
        sma = add_state(sma, 'default_statechange', 'load_stimulus', 'self_timer', 0.001);
        
        %
        sma = add_state(sma, 'name', 'load_stimulus','self_timer', 0.001,...
            'output_actions', {'DOut', center1valve},...
            'input_to_statechange', {'Tup', 'wait_load'});
        
        sma = add_state(sma, 'name', 'wait_load','self_timer', 0.25,...
            'input_to_statechange', {'Tup', 'stimulus_trigger'});
        %
        sma = add_state(sma, 'name', 'stimulus_trigger','self_timer', 0.001,...
            'output_actions', {'DOut', center1valve},...
            'input_to_statechange', {'Tup', 'stimulus_pres'});
        
        if value(punishDelayLick)
            sma = add_state(sma, 'name', 'stimulus_pres','self_timer', value(responseDelay),...
                'input_to_statechange', {'Tup', 'response_window',wrongChoice,'early_wrong_choice',correctChoice,'early_correct_choice'});
        else
            sma = add_state(sma, 'name', 'stimulus_pres','self_timer', value(responseDelay),...
                'input_to_statechange', {'Tup', 'response_window'});
        end
        
        if value(punishError)
            sma = add_state(sma, 'name', 'response_window','self_timer', value(responseWindow),...
                'input_to_statechange', {correctChoice,'correct_choice',wrongChoice,'wrong_choice','Tup', 'time_out'});
        else
            sma = add_state(sma, 'name', 'response_window','self_timer', value(responseWindow),...
                'input_to_statechange', {correctChoice,'correct_choice','Tup', 'time_out'});
        end
        
        sma = add_state(sma, 'name', 'correct_choice','self_timer', value(rewardState),...
            'output_actions', {'SchedWaveTrig','reward_delivery'},...
            'input_to_statechange', {'Tup', 'inter_trial_interval'});
        
        sma = add_state(sma, 'name', 'time_out','self_timer', value(timeOut),...
            'input_to_statechange', {'Tup', 'inter_trial_interval'});
        
        sma = add_state(sma, 'name', 'wrong_choice','self_timer', value(errorPunishment),...
            'input_to_statechange', {'Tup', 'inter_trial_interval'});
        
        sma = add_state(sma, 'name', 'early_correct_choice','self_timer', value(rewardState),...
            'input_to_statechange', {'Tup', 'inter_trial_interval'});
        sma = add_state(sma, 'name', 'early_wrong_choice','self_timer', value(errorPunishment),...
            'input_to_statechange', {'Tup', 'inter_trial_interval'});
        
        sma = add_state(sma, 'name', 'reset_ITI','self_timer',0.001,...
            'input_to_statechange', {'Tup', 'inter_trial_interval'});
        
        
        if value(delayITI)
            sma = add_state(sma, 'name', 'inter_trial_interval','self_timer',ITIValue,...
                'input_to_statechange', {'Tup','check_next_trial_ready','Rin','reset_ITI','Lin','reset_ITI'});
        else
            sma = add_state(sma, 'name', 'inter_trial_interval','self_timer',ITIValue,...
                'input_to_statechange', {'Tup','check_next_trial_ready'});
        end
        
        %   dispatcher('send_assembler', sma, ...
        %   optional cell_array of strings specifying the prepare_next_trial states);
        dispatcher('send_assembler', sma, {'correct_choice','early_correct_choice','time_out','wrong_choice','early_wrong_choice','inter_trial_interval'});
        
        
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
