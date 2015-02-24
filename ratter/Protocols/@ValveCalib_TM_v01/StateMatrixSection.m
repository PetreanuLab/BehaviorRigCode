function  [] =  StateMatrixSection(obj, action)

global leftvalve;
global rightvalve;

GetSoloFunctionArgs;

switch action
    case 'init',
                
        StateMatrixSection(obj, 'next_trial');
        
    case 'next_trial',
        
        if strcmp(value(valves),'BOTH')
            open_valves = 'left_water_delivery+right_water_delivery';
        elseif strcmp(value(valves),'LEFT')
            open_valves = 'left_water_delivery';
        else
            open_valves = 'right_water_delivery';           
        end
        
        % Sets up the assembler
        sma = StateMachineAssembler('full_trial_structure');
        
        % Sets up the scheduled waves
        sma = add_scheduled_wave(sma,'name','left_water_delivery',...
            'preamble',0.001,'sustain',value(valveTimeLeft),...
            'DOut',leftvalve);
        
        sma = add_scheduled_wave(sma,'name','right_water_delivery',...
            'preamble',0.001,'sustain',value(valveTimeRight),...
            'DOut',rightvalve);
        
        % Sets up the state-machine
        sma = add_state(sma, 'default_statechange', 'water_delivery', 'self_timer', 0.001);
        
        if n_done_trials < value(nTrials)
            
            %
            sma = add_state(sma, 'name', 'water_delivery','self_timer', 0.01,...
                'output_actions', {'SchedWaveTrig', open_valves},...
                'input_to_statechange', {'Tup', 'inter_trial_interval'});
            
        else
            sma = add_state(sma, 'name', 'water_delivery','self_timer', 0.01,...
                'input_to_statechange', {'Tup', 'inter_trial_interval'});
            
        end
        
        sma = add_state(sma, 'name', 'inter_trial_interval','self_timer',value(ITI),...
            'input_to_statechange', {'Tup','check_next_trial_ready'});
        
        
        %   dispatcher('send_assembler', sma, ...
        %   optional cell_array of strings specifying the prepare_next_trial states);
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
