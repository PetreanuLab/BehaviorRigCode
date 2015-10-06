function [] = SupportFunctions(obj, action)

GetSoloFunctionArgs;
r = visRigDefs; % BA
%persistent player

switch action,

    case 'store_history'
        
        %% UPDATE STATE MATRIX SECTION
        if n_done_trials > 0
            stimSideHistory(n_done_trials) = value(currStimSide);
            coherHistory(n_done_trials) = value(currCoher);
            
            if isempty(parsed_events.states.wrong_choice)==0
                timeOutHistory(n_done_trials)=0;
                correctHistory(n_done_trials)=0;
                choiceHistory(n_done_trials)= not(value(currStimSide));
            elseif or(isempty(parsed_events.states.correct_choice)==0,isempty(parsed_events.states.early_correct_choice)==0)
                timeOutHistory(n_done_trials)=0;
                correctHistory(n_done_trials)=1;
                choiceHistory(n_done_trials)= value(currStimSide);
            else
                timeOutHistory(n_done_trials)=1;
                correctHistory(n_done_trials)=0;
                choiceHistory(n_done_trials)= NaN;
            end
        end
        
        
    case 'set_next_dots'

        stimSizeDegCumProb = cumsum(value(stimSizeDegProb));
        stimSizeDegRand = rand*stimSizeDegCumProb(end);
        currStimSizeDeg.value = stimSizeDeg(find(stimSizeDegRand <= stimSizeDegCumProb,1));
        
        if strcmp(value(randSeed),'random')
            currRandSeed.value=randi(1000);
        else
            currRandSeed.value=value(randSeed);
        end
        
        stimDurationCumProb = cumsum(value(stimDurationProb));
        stimDurationRand = rand*stimDurationCumProb(end);
        currStimDuration.value = stimDuration(find(stimDurationRand <= stimDurationCumProb,1));
        
        coherCumProb = cumsum(value(dotCoherProb));
        coherRand = rand*coherCumProb(end);
        currCoher.value = dotCoher(find(coherRand <= coherCumProb,1));
        
        densityCumProb = cumsum(value(dotDensityProb));
        densityRand = rand*densityCumProb(end);
        currDensity.value = dotDensity(find(densityRand <= densityCumProb,1));

        speedCumProb = cumsum(value(dotSpeedProb));
        speedRand = rand*speedCumProb(end);
        currSpeed.value = dotSpeed(find(speedRand <= speedCumProb,1));
        
        sizeCumProb = cumsum(value(dotSizeProb));
        sizeRand = rand*sizeCumProb(end);
        currSize.value = dotSize(find(sizeRand <= sizeCumProb,1));

        lifeTimeCumProb = cumsum(value(dotLifeTimeProb));
        lifeTimeRand = rand*lifeTimeCumProb(end);
        currLifeTime.value = dotLifeTime(find(lifeTimeRand <= lifeTimeCumProb,1));
        
        if value(soundSides)
        soundSidesVolumeCumProb = cumsum(value(soundSidesVolumeProb));
        soundSidesVolumeRand = rand*soundSidesVolumeCumProb(end);
        currSoundSidesVolume.value = soundSidesVolume(find(soundSidesVolumeRand <= soundSidesVolumeCumProb,1));
        else
            currSoundSidesVolume.value=0;
        end
        
        intStimLum.value=value(stimLum)*value(currDensity)+value(bckgLum)*(1-value(currDensity));
        
    case 'set_next_side'
        
        nonRandomSide.value = 0;
        
        if (value(limitEqualSides) && (n_done_trials >= value(maxEqualSides)))
            if sum(stimSideHistory((end-value(maxEqualSides)+1):end))== 0
                currStimSide.value = 1;
                nonRandomSide.value = 1;
            elseif sum(stimSideHistory((end-value(maxEqualSides)+1):end))== value(maxEqualSides)
                currStimSide.value = 0;
                nonRandomSide.value = 1;
            end
        end
        if (value(limitAlternSides)&&(n_done_trials > value(maxAlternSides)))
            if sum(abs(diff(stimSideHistory((end-value(maxAlternSides)):end)))) == value(maxAlternSides)
                nonRandomSide.value = 1;
            end
        end
        
        if value(nonRandomSide)==0
            
            switch value(sideSelection)
                
                case 'random'
                    
                    if rand < value(leftProb)
                        currStimSide.value = 1;
                    else
                        currStimSide.value = 0;
                    end
                    
                    
                case 'biasCorrection'
                    
                    if n_done_trials >= value(biasSize)
                        biasChoice = nanmean(choiceHistory((end-value(biasSize)+1):end));
                        biasStimSide = mean(stimSideHistory((end-value(biasSize)+1):end));
                        bias = (biasChoice-biasStimSide+1)/2;
                        if isnan(bias)
                            currStimSide.value = round(biasStimSide);
                        elseif bias < rand
                            currStimSide.value = 1;
                        else
                            currStimSide.value = 0;
                        end
                    else
                        currStimSide.value = round(rand);
                    end
            end
            
        end
        
    case 'update_disp_param'
        
        if n_done_trials > 0
            lastTimeOut.value = timeOutHistory(n_done_trials);
            lastCorrect.value = correctHistory(n_done_trials);
            lastChoice.value = choiceHistory(n_done_trials);
            lastStimSide.value = stimSideHistory(n_done_trials);
            lastCoher.value = coherHistory(n_done_trials);
            lastTrial.value = n_done_trials;
        end
        
        if n_done_trials > value(meanSize)
            meanAccu.value = sum(correctHistory((end-value(meanSize)+1):end))/(value(meanSize)-sum(timeOutHistory((end-value(meanSize)+1):end)));
            meanTimeOut.value = mean(timeOutHistory((end-value(meanSize)+1):end));
            meanChoice.value = nanmean(choiceHistory((end-value(meanSize)+1):end));
            meanStimSide.value = mean(stimSideHistory((end-value(meanSize)+1):end));
            
            meanBias.value = (value(meanChoice)-value(meanStimSide)+1)/2;
            
            
        end
        
    case 'param_save'
        %% Screen Dimensions
        diag_cm = value(diagIn)*2.54;
        diag_px = sqrt(screenPx(1)^2+screenPx(2)^2);

        %% General stimulus properties
        stim_length = value(currStimDuration);
        radius_cm = tan(value(currStimSizeDeg)/2*pi/180)*value(distCm);
        radius_px = round(diag_px/diag_cm*radius_cm);
        centre_px = value(stimPos);
        background_level = value(bckgLum);
        stim_level = value(stimLum);
        inter_stim_level = value(intStimLum);
        if value(currStimSide)
            stim_dir = value(leftDirection);
        else
            stim_dir = value(rightDirection);
        end
        rand_seed = value(currRandSeed);
        
        %% Random dot properties
        dot_lifetime = value(currLifeTime);
        dot_coherence = value(currCoher)/100;
        dot_speed_cm = tan(value(currSpeed)*pi/180)*value(distCm);
        dot_speed_px = diag_px/diag_cm*dot_speed_cm;
        if value(currSize) == 0
            dot_size_px = 1;
        else
            dot_size_cm = tan(value(currSize)*pi/180)*value(distCm);
            dot_size_px = round(diag_px/diag_cm*dot_size_cm);
        end
        dot_number = floor(value(currDensity)*radius_px^2 /(dot_size_px/2)^2);
        
        %% Others
        error_length = value(errorVisualLength);
        error_lifetime = value(flickeringError);
        error_sound_length = value(errorSoundLength);
        reward_sound_length = value(rewardSoundLength);
        sound_volume = value(soundVolume);
        sound_sides_volume = value(currSoundSidesVolume);
        trial_sounds = value(soundTrial);
        after_lick = value(afterLick);
        stop_stimulus = value(stopLick);
        visual_error = value(visualError);
        sound_sides = value(soundSides);
        left = value(currStimSide);
        pre_stimulus = value(preStimulus);
        resp_delay = value(respDelay);
        resp_window = value(respWindow);
        left_frequency = value(leftFrequency);
        right_frequency = value(rightFrequency);
        
        save(fullfile(r.DIR.ratterExperPort, 'next_trial'),'dot_speed_px','dot_number','radius_px',...
            'dot_coherence','stim_dir','stim_length','dot_lifetime','dot_size_px',...
            'stim_level','background_level','inter_stim_level','centre_px',...
            'error_length','error_lifetime','error_sound_length','reward_sound_length',...
            'sound_volume','sound_sides_volume','trial_sounds','after_lick','stop_stimulus',...
            'visual_error','sound_sides','left','pre_stimulus','resp_delay','resp_window',...
            'left_frequency','right_frequency','rand_seed');
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
        
end;