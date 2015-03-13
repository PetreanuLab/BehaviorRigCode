function [] = SupportFunctions(obj, action)

GetSoloFunctionArgs;
r = visRigDefs; % BA
%persistent player

switch action,
    
    case 'store_history'
        %
        %         %% UPDATE STATE MATRIX SECTION
        if n_done_trials > 0
            
            goHistory(n_done_trials) = value(currGoTrial);
            loc1History(n_done_trials) = value(currLoc1);
            
            correctHistory(n_done_trials) = NaN;
            correctHistoryLoc1(n_done_trials) = NaN;
            correctHistoryLoc2(n_done_trials) = NaN;
            earlyHistory(n_done_trials) = 0;
            missedHistory(n_done_trials) = 0;
            %             parsed_events.states
            if ~isempty(parsed_events.states.wrong_choice)
                correctHistory(n_done_trials) = 0;
                if value(currLoc1)~=1
                    correctHistoryLoc2(n_done_trials) = 0;
                else
                    correctHistoryLoc1(n_done_trials) = 0;
                end
                
            elseif  ~isempty(parsed_events.states.correct_go)|| ...
                    ~isempty(parsed_events.states.correct_nogo)
                correctHistory(n_done_trials) = 1;
                if value(currLoc1)~=1
                    correctHistoryLoc2(n_done_trials) = 1;
                else
                    correctHistoryLoc1(n_done_trials) = 1;
                end
            end
            
            
            if ~isempty(parsed_events.states.missed_response)
                missedHistory(n_done_trials) = 1;
                
            end
            
            
            % %         update adaptive parameter
            cH = value(correctHistory);
            mH = value(missedHistory);
            newvalue = value(minStimLgthGo);
            
            if value(currGoTrial)
                a = value(adaptStimLgthGo);
                mn = a(1); mx = a(2); corrstep = a(3);  errstep = a(4);
                if cH(end)==1
                    newvalue= value(minStimLgthGo) + corrstep;
                elseif mH(end)==1
                    newvalue = value(minStimLgthGo) + errstep;
                end
                if newvalue < mn
                    newvalue = mn;
                elseif newvalue > mx;
                    newvalue = mx;
                end
                delta = newvalue -value(minStimLgthGo) ;
                
                if newvalue ~=value(minStimLgthGo)
                    minStimLgthGo.value = value(minStimLgthGo) + delta;
                    maxStimLgthGo.value = value(maxStimLgthGo) + delta;
                end
                
            else
                
                a = value(adaptStimLgthNogo);
                mn = a(1); mx = a(2); corrstep = a(3);  errstep = a(4);
                if cH(end)==1
                    newvalue= value(minStimLgthNogo) + corrstep;
                elseif cH(end)==0
                    newvalue = value(minStimLgthNogo) + errstep;
                end
                if newvalue < mn
                    newvalue = mn;
                elseif newvalue > mx;
                    newvalue = mx;
                end
                delta = newvalue -value(minStimLgthNogo) ;
                
                if newvalue ~=value(minStimLgthNogo)
                    minStimLgthNogo.value = value(minStimLgthNogo) + delta;
                    maxStimLgthNogo.value = value(maxStimLgthNogo) + delta;
                end
            end
        end
    case 'set_next_stimulusChange'
        
        % % Location
        currLoc1.value = double(rand<value(loc1Prob));
        
        % % Trial is go
        switch  value(goTrialSelection)
            case 'user'
                currGoTrial.value =  value(userThisTrialGo);
            case 'random'
                currGoTrial.value =  double(rand < value(goTrialProb));
        end
        
        % % Sets the stimulus length
        if value(currGoTrial)
            stim_length = value(minStimLgthGo) + rand*(value(maxStimLgthGo)-value(minStimLgthGo));
        else
            stim_length = value(minStimLgthNogo) + rand*(value(maxStimLgthNogo)-value(minStimLgthNogo));
        end
        currStimDuration.value = stim_length;
        
        % % Sets the stimulus onset
        currStimOnset.value = value(minStimDelay) + rand*(value(maxStimDelay)-value(minStimDelay));
        % check timing makes sense
        if value(errorTimeOut) < value(errorSoundLength) ||...
                value(errorTimeOut) < value(errorVisualLength)
            errorSoundLength.value = value(errorTimeOut);
            errorVisualLength.value = value(errorTimeOut);
            warning('errorTimeOut is too short. Shorter than errorSoundLength or errorVisualLength, This has been corrected')
        end
        
        
    case 'set_next_dots'
        
        if strcmp(value(randSeed),'random')
            currRandSeed.value=randi(1000);
        else
            currRandSeed.value=value(randSeed);
        end
        
        % % For TARGET and FOIL
        stimSizeDegCumProb = cumsum(value(stimSizeDegProb));
        stimSizeDegRand = rand*stimSizeDegCumProb(end);
        currStimSizeDeg.value = stimSizeDeg(find(stimSizeDegRand <= stimSizeDegCumProb,1));
        
        if value(currGoTrial)
            currLum.value = getprob(goLum,goLumProb);
            currCoher.value = getprob(goCoh,goCohProb);
            currSpeed.value = getprob(goSpeed,goSpeedProb);
            currDirection.value = value(goDirection);
        else
            currLum.value = getprob(nogoLum,nogoLumProb);
            currCoher.value =getprob(nogoCoh,nogoCohProb);
            currSpeed.value = getprob(nogoSpeed,nogoSpeedProb);
            currDirection.value = value(nogoDirection);
        end
        
        densityCumProb = cumsum(value(dotDensityProb));
        densityRand = rand*densityCumProb(end);
        currDensity.value = dotDensity(find(densityRand <= densityCumProb,1));
        
        sizeCumProb = cumsum(value(dotSizeProb));
        sizeRand = rand*sizeCumProb(end);
        currSize.value = dotSize(find(sizeRand <= sizeCumProb,1));
        
        lifeTimeCumProb = cumsum(value(dotLifeTimeProb));
        lifeTimeRand = rand*lifeTimeCumProb(end);
        currLifeTime.value = dotLifeTime(find(lifeTimeRand <= lifeTimeCumProb,1));
        
    case 'update_disp_param'
        
        if n_done_trials > 0
            lastCorrect.value = correctHistory(n_done_trials);
            lastLoc.value = loc1History(n_done_trials);
            lastGo.value = goHistory(n_done_trials);
            lastMissed.value = missedHistory(n_done_trials);
            lastTrial.value = n_done_trials;
        end
        if value(meanSize) == -1
            meanSize.value = n_done_trials;
        end
        if n_done_trials > value(meanSize)
            
            indmean = [(n_done_trials-value(meanSize)+1):n_done_trials];
            indGo = goHistory(indmean)==1;
            indMiss = missedHistory(indmean)==1;
            indNogo = goHistory(indmean)==0;
            
            performance.value = nanmean( correctHistory(indmean));
            nogoPerf.value=  nanmean(correctHistory(indmean(indNogo)));
            missFrac.value=  nansum(missedHistory(indmean))/meanSize;
            goPerf.value  =  nanmean(correctHistory(indmean(indGo)))-value(missFrac);
            earlyFrac.value=  nansum(earlyHistory(indmean))/meanSize;
            
            performanceLoc1.value =  nanmean( correctHistoryLoc1(indmean));
            performanceLoc2.value = nanmean( correctHistoryLoc2(indmean));
            
            goPerfLoc1.value = NaN ; % this is wrong need to subtract misses nanmean( correctHistoryLoc1(indmean(indGo)));
            goPerfLoc2.value = NaN ; % this is wrong need to subtract misses nanmean( correctHistoryLoc2(indmean(indGo)));
            
            nogoPerfLoc1.value = nanmean( correctHistoryLoc1(indmean(indNogo)));
            nogoPerfLoc2.value = nanmean( correctHistoryLoc2(indmean(indNogo)));
            
            fracTrialLoc1.value =         sum(loc1History(indmean)==1) /meanSize;
            
        end
        
    case 'param_save'
        %% Screen Dimensions
        param.diag_cm = value(diagIn)*2.54;
        param.diag_px = sqrt(screenPx(1)^2+screenPx(2)^2);
        
        %% General stimulus properties
        param.radius_cm = tan(value(currStimSizeDeg)/2*pi/180)*value(distCm);
        
        param.background_level  = value(bckgLum);
        param.inter_stim_level  = value(intStimLum);
        param.rand_seed = value(currRandSeed);
        
        % % timing properties
        param.pre_cue           = 0
        param.cue_length        = 0
        param.stim_delay        = value(currStimOnset); % after the cue
        param.stim_length       = value(currStimDuration);
        
        % % CUE and stimulus location properties
        if value(currLoc1)
            param.cue_frequency = value(cue1Frequency)*1000;
            param.cue_rightSpeaker = 1;
            param.cue_leftSpeaker = 0;
            param.cue_centre_px = value(stim1Pos);
            param.stimulus(1).centre_px = value(stim1Pos);
        else
            param.cue_frequency = value(cue2Frequency)*1000;
            param.cue_rightSpeaker = 0;
            param.cue_leftSpeaker = 1;
            param.cue_centre_px = value(stim2Pos);
            param.stimulus(1).centre_px = value(stim2Pos);
        end
        
        % % Random dot properties of all spatial stimuluss
        % % NOTE: stimulus(1) is the Target
        param.stimulus(1).lumlevel =  value(currLum);
        param.stimulus(1).radius_px = round(param.diag_px/param.diag_cm*param.radius_cm);
        
        param.stimulus(1).stim_dir = value(currDirection);
        param.stimulus(1).dot_lifetime = value(currLifeTime);
        param.stimulus(1).dot_coherence = value(currCoher)/100;
        param.stimulus(1).dot_speed_cm = tan(value(currSpeed)*pi/180)*value(distCm);
        param.stimulus(1).dot_speed_px = param.diag_px/param.diag_cm*param.stimulus(1).dot_speed_cm;
        if value(currSize) == 0
            param.stimulus(1).dot_size_px = 1;
        else
            param.stimulus(1).dot_size_cm = tan(value(currSize)*pi/180)*value(distCm);
            param.stimulus(1).dot_size_px = round(param.diag_px/param.diag_cm*param.stimulus(1).dot_size_cm);
        end
        param.stimulus(1).dot_number = floor(value(currDensity)*param.stimulus(1).radius_px^2 /(param.stimulus(1).dot_size_px/2)^2);
        
        
        
        % % other
        
        %% Others
        param.goTrial       =  value(currGoTrial);
        
        param.error_length      = value(errorVisualLength);
        param.error_lifetime    = value(flickeringError);
        param.error_sound_length = value(errorSoundLength);
        param.error_sound_volume = value(errorSoundVolume);
        param.reward_sound_length = value(rewardSoundLength);
        param.sound_volume      = value(soundVolume);
        
        param.trial_sounds      = value(soundTrial);
        param.after_lick        = value(outDelay);
        param.stop_stimulus     = value(stopLick);
        param.visual_error      = value(visualError);
        
        save(fullfile(r.DIR.ratter, 'next_trial'),'param');
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
        
end;
end
% % helper function

function out = getprob(val,Prob)
CumProb = cumsum(value(Prob));
valRand = rand*CumProb(end);
out = val(find(valRand <= CumProb,1));
end

