function [] = SupportFunctions(obj, action)

GetSoloFunctionArgs;

switch action,
    
    case 'store_history'
        
        %% Updates choice history
        if n_done_trials > 0
            if isempty(parsed_events.states.left_reward)==0
                choiceHistory(n_done_trials)= 1;
            else
                choiceHistory(n_done_trials)= 0;
            end
        end
        
    case 'play_sounds'
        
        %% Sends sound paired with reward
        if n_done_trials > 0
            if value(rewardSound)
                audio_freq = 40000;
                sound(sin((1:audio_freq*0.2)/audio_freq*2*pi*1000)*value(soundVolume)/2000,audio_freq);
            end
        end
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
        
end;