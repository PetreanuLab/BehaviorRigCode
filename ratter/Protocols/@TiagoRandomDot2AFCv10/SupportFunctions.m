function [] = SupportFunctions(obj, action)

GetSoloFunctionArgs;

switch action,
    
    case 'random_variables'
        
        if n_done_trials > 0
            if or(isempty(parsed_events.states.wrong_choice)==0,isempty(parsed_events.states.early_wrong_choice)==0)
                wrongHistory(n_done_trials)=1;
                correctHistory(n_done_trials)=0;
                choiceHistory(n_done_trials)= not(value(side));
            elseif or(isempty(parsed_events.states.correct_choice)==0,isempty(parsed_events.states.early_correct_choice)==0)
                wrongHistory(n_done_trials)=0;
                correctHistory(n_done_trials)=1;
                choiceHistory(n_done_trials)= value(side);
            else
                wrongHistory(n_done_trials)=0;
                correctHistory(n_done_trials)=0;
                choiceHistory(n_done_trials)= NaN;
            end
                         
        end
        
        if n_done_trials > value(trialHistory)
            accuracy.value = sum(correctHistory((end-value(trialHistory)):end))/(sum(correctHistory((end-value(trialHistory)):end))+sum(wrongHistory((end-value(trialHistory)):end)));
            bias.value = nanmean(choiceHistory((end-value(trialHistory)):end));
        end
        
        % Need to remove the lastAltern outside of this condition!
        if n_done_trials >= value(maxEqualSides)
            lastSides = sideHistory((n_done_trials+1-value(maxEqualSides)):end);
            disp(value(lastSides));
        else
            lastSides = ones(value(maxEqualSides),1)/2;
        end
        if n_done_trials >= (value(maxAlternSides)+1)
            lastAltern = abs(diff(sideHistory((n_done_trials-value(maxAlternSides)):end)));
            disp(value(lastAltern));
        else
            lastAltern = zeros(value(maxAlternSides),1);
        end
        
        
        if (value(limitEqualSides) && sum(lastSides)==0) % All last sides were right
            side.value = 1; % Next side is left
            disp('non random left')
        elseif (value(limitEqualSides)  &&  sum(value(lastSides))== value(maxEqualSides)) % All last sides were left
            side.value = 0; % Next side is right
                        disp('non random left')

        elseif (value(limitAlternSides) && sum(value(lastAltern))== value(maxAlternSides)) % Last trials were alternating all the time
            side.value = sideHistory(n_done_trials); % Next side is the same as the current one
            disp('non random same')
        else
            if rand()< value(leftProb)
                side.value = 1;
                disp('random left')
            else
                side.value = 0;
                disp('random right')
            end
        end
        
%         if value(coher) < 0.5
%             coherProb = cumsum([value(SIXTY) value(EIGHTY) value(HUNDRED)]);
%             coherRand = rand*coherProb(end);
%             if coherRand <= coherProb(1)
%                 coher.value = 0.6;
%             elseif coherRand <= coherProb(2)
%                 coher.value = 0.8;
%             else
%                 coher.value = 1.0;
%             end
%         else

            coherProb = cumsum([value(coher_1_prob) value(coher_2_prob) value(coher_3_prob) value(coher_4_prob) value(coher_5_prob) value(coher_6_prob)]);
            coherRand = rand*coherProb(end);

            if coherRand <= coherProb(1)
                coher.value = value(coher_1);
            elseif coherRand <= coherProb(2)
                coher.value = value(coher_2);
            elseif coherRand <= coherProb(3)
                coher.value = value(coher_3);
            elseif coherRand <= coherProb(4)
                coher.value = value(coher_4);
            elseif coherRand <= coherProb(5)
                coher.value = value(coher_5);
            else
                coher.value = value(coher_6);
            end
%         end
        
        sideHistory(n_done_trials+1)=value(side);
        coherHistory(n_done_trials+1)=value(coher);
        
        
    case 'param_save'
        
        left = value(side)==1;
        coherence = value(coher)/100;
        stimulus_duration = value(stimuliDuration);
        life_time = value(lifeTime);
        dot_size = value(dotSize);
        dot_speed = value(dotSpeed);
        dot_density = value(dotDensity);
        dot_level = value(dotsLevel);
        background_level = value(backgroundLevel);
        sounds = value(soundSides);
        volume = value(soundVolume);
        left_frequency = value(leftFrequency);
        right_frequency = value(rightFrequency);
        monitor_type = value(monitor);
        patch_deg =  value(patchDeg);
        
        save('c:/ratter/next_trial','coherence','left','stimulus_duration','life_time',...
            'dot_size','dot_speed','dot_density','dot_level','background_level','sounds',...
            'left_frequency','right_frequency','volume','monitor_type','patch_deg');
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
        
end;