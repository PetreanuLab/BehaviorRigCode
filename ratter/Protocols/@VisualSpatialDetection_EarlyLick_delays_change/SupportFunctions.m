function [] = SupportFunctions(obj, action)

GetSoloFunctionArgs;
r = visRigDefs; % BA
%persistent player

switch action,
    
    case 'store_history'
        %
        %         %% UPDATE STATE MATRIX SECTION
        if n_done_trials > 0
            
            validHistory(n_done_trials) = value(currValidTrial);
            validLocHistory(n_done_trials) = value(currValidLoc);
            
            correctHistory(n_done_trials) = NaN;
            correctHistoryLoc1(n_done_trials) = NaN;
            correctHistoryLoc2(n_done_trials) = NaN;
            earlyHistory(n_done_trials) = 0;
            missedHistory(n_done_trials) = 0;
            %             parsed_events.states
            if ~isempty(parsed_events.states.wrong_choice)
                correctHistory(n_done_trials) = 0;
                if value(currValidLoc)==2
                    correctHistoryLoc2(n_done_trials) = 0;
                else
                    correctHistoryLoc1(n_done_trials) = 0;
                end
                
            elseif  ~isempty(parsed_events.states.correct_valid)|| ...
                    ~isempty(parsed_events.states.correct_invalid)
                correctHistory(n_done_trials) = 1;
                if value(currValidLoc)==2
                    correctHistoryLoc2(n_done_trials) = 1;
                else
                    correctHistoryLoc1(n_done_trials) = 1;
                end
            end
            
            if isfield(parsed_events.states, 'punish_early_licks')
                if ~isempty(parsed_events.states.early_choice)
                    earlyHistory(n_done_trials) = 1;
                elseif isfield(parsed_events.states, 'punish_early_licks')
                    if isfield(parsed_events.states, 'early_licks_stimulus_delayed3')
                        if ~isempty(parsed_events.states.early_licks_stimulus_delayed3)
                            earlyHistory(n_done_trials) = 1;
                        end
                    end
                end
            else
                earlyHistory(n_done_trials) = NaN;
            end
            
            if ~isempty(parsed_events.states.missed_response)
                missedHistory(n_done_trials) = 1;
            end
        end
        
        % % update Adapting variables
        if isequal('Adapt random with max',value(randomChangeDelay))
            
            if ~isempty(earlyHistory) && ~isnan(earlyHistory(end))
                blastcorrect = ~earlyHistory(end);                    %                 was last trial early?
                if ~isnan(blastcorrect)
                    a = value(goalMinChgDelay);
                    mn = a(1);
                    mx = a(2);
                    correctstep = a(3);
                    errorstep = a(4);
                    % update with adapted value
                    if blastcorrect
                        newvalue = value(minChgDelay)+correctstep;
                    elseif ~blastcorrect
                        newvalue= value(minChgDelay)+errorstep;
                    end
                    if newvalue>mx, minChgDelay.value=mx; % check that newvalue doesn't exceed limits
                    elseif newvalue<mn,minChgDelay.value=mn;               end
                    
                    if newvalue~=value(minChgDelay); % if value changed change it and update, stimulus length and max as well
                        minChgDelay.value = newvalue;
                        if blastcorrect
                            maxChgDelay.value = value(maxChgDelay)+correctstep;
                            maxStimLgth.value = value(maxStimLgth)+correctstep;
                        elseif ~blastcorrect
                            maxChgDelay.value= value(maxChgDelay)+errorstep;
                            maxStimLgth.value = value(maxStimLgth)+errorstep;
                        end
                    end
                end
            end
        end
    case 'set_next_stimulusChange'
        
        % % Trial is Valid
        switch  value(validTrialSelection)
            case 'user'
                currValidTrial.value =  value(userThisTrialValid);
            case 'random'
                currValidTrial.value =  double(rand < value(validTrialProb));
        end
        
        switch value(stimchangeSelector)
            case 'changeLocation' % select the location that will change;
                if value(currValidTrial)
                    if rand < value(changeLocation1) %  probablity of change at Location 1
                        currValidLoc.value = 1;
                    else
                        currValidLoc.value = 2;
                    end
                    
                else
                    if rand < value(changeLocation1)
                        currValidLoc.value = 2;
                    else
                        currValidLoc.value = 1;
                    end
                end
            case 'validLocation'
                % % Location that is Valid
                switch  value(validLocationSelection)
                    case 'user'
                        currValidLoc.value =  value(validLocation)+1; % turn boolean into 1 or 2
                    case 'random'
                        currValidLoc.value =  randi(2);
                end
                
        end
        
        
        % % Sets the stimulus length
        bdone=0  ;     i=0;
        while ~bdone
            switch value(stimDist)
                case 'exponential'
                    stim_length=exprnd(value(meanStimLgth));
                case 'uniform'
                    stim_length = value(minChgDelay) + rand*(value(maxStimLgth)-value(minChgDelay));
                case 'fixed'
                    stim_length = value(maxStimLgth);
            end
            bdone = 1;
            if or(stim_length>value(maxStimLgth),(stim_length<(value(minChgDelay)+value(respWindow))))
                bdone=0;
            end
            
            i=i+1;
            if i>50,             warning('Cannot find stimulus length for parameters') ;
                stim_length = value(minChgDelay)+value(respWindow)+0.1;
                maxStimLgth.value  = stim_length;
            end
        end
        
        currStimDuration.value = stim_length;
        validTrial = value(currValidTrial);
        
        % % Set change delay
        switch value(randomChangeDelay)
            case 'random'
                changeStimDelay = value(minChgDelay) + rand*(stim_length-value(minChgDelay)-value(respWindow));  % time fromt the begining of the stimulus to the change
            case 'random with max'
                changeStimDelay = value(minChgDelay) + rand*(stim_length-value(minChgDelay)-value(respWindow)) * (value(maxChgDelay)- value(minChgDelay));  % time fromt the begining of the stimulus to the change
            case 'fixed'
                changeStimDelay = value(minChgDelay);
            case 'Adapt random with max'    % updating is done in story history section
                changeStimDelay = value(minChgDelay) + rand*(stim_length-value(minChgDelay)-value(respWindow)) * (value(maxChgDelay)- value(minChgDelay));  % time fromt the begining of the stimulus to the change
                
        end
        
        % % Sets the responseWindow
        if or(and(not(value(setRespWindow)),validTrial),not(validTrial)) % responseWindow until the end of the Stimulus
            responseWindow = stim_length - changeStimDelay;
        else % use specified response window
            responseWindow = value(respWindow);
        end
        currResponseWindow.value = responseWindow;
        currChangeStimDelay.value = changeStimDelay;
        
        % %  stimulus Change   paramters
        currCohChg.value = getprob(cohChg,cohChgProb)  ;
        currDirnDeltaChg.value = getprob(dirnDeltaChg,dirnDeltaChgProb);
        currLumChg.value = getprob(lumChg,lumChgProb)  ;
        currSpeedChg.value = getprob(speedChg,speedChgProb);
        
        currChangeVolume.value = getprob(changeSoundVolume,changeSoundVolumeProb);
        
        
        % check timing makes sense
        if value(errorTimeOut) < value(errorSoundLength) ||...
                value(errorTimeOut) < value(errorVisualLength)
            errorSoundLength.value = value(errorTimeOut);
            errorVisualLength.value = value(errorTimeOut);
            warning('errorTimeOut is too short. Shorter than errorSoundLength or errorVisualLength, This has been corrected')
            
            
        end
        
        if (value(earlyTimeOut)+value(ITIMax)+1) < value(errorSoundLength) ||...
                (value(earlyTimeOut)+value(ITIMax)+1) < value(errorVisualLength)
            earlyTimeOut.value = max( value(errorVisualLength), value(errorSoundLength) ) ...
                - (value(ITIMax)+1)+0.3; % 1 is from preITI and 0.3 is for safety
            warning('earlyTimeOut is too short. Shorter than errorSoundLength or errorVisualLength, This has been corrected')
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
        
        currLumFoil.value = getprob(foilLum,foilLumProb);
        currLumTarg.value = getprob(targetLum,targetLumProb);
        
        
        
        
        
    case 'update_disp_param'
        
        if n_done_trials > 0
            lastCorrect.value = correctHistory(n_done_trials);
            lastLoc.value = validLocHistory(n_done_trials);
            lastValid.value = validHistory(n_done_trials);
            lastMissed.value = missedHistory(n_done_trials);
            lastTrial.value = n_done_trials;
        end
        if value(meanSize) == -1
            meanSize.value = n_done_trials;
        end
        if n_done_trials > value(meanSize)
            
            indmean = [(n_done_trials-value(meanSize)+1):n_done_trials];
            indValid = validHistory(indmean)==1;
            indMiss = missedHistory(indmean)==1;
            indInValid = validHistory(indmean)==0;
            
            performance.value = nanmean( correctHistory(indmean));
            validPerf.value  =  nanmean(correctHistory(indmean(indValid)));
            invalidPerf.value=  nanmean(correctHistory(indmean(indInValid)));
            missFrac.value=  nansum(missedHistory(indmean))/meanSize;
            earlyFrac.value=  nansum(earlyHistory(indmean))/meanSize;
            
            performanceLoc1.value =  nanmean( correctHistoryLoc1(indmean));
            performanceLoc2.value = nanmean( correctHistoryLoc2(indmean));
            
            validPerfLoc1.value = nanmean( correctHistoryLoc1(indmean(indValid)));
            validPerfLoc2.value = nanmean( correctHistoryLoc2(indmean(indValid)));
            
            invalidPerfLoc1.value = nanmean( correctHistoryLoc1(indmean(indInValid)));
            invalidPerfLoc2.value = nanmean( correctHistoryLoc2(indmean(indInValid)));
            
            fracTrialLoc1.value =         sum(validLocHistory(indmean)==1) /meanSize;
            
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
        param.punishEarlyLickNoise = value(punishEarlyLkNoise);
        param.punishEarlyLickType = value(punishEarlyLickType);
        % % timing properties
        param.pre_cue           = value(preCue);
        param.cue_length        = value(cueDuration);
        param.stim_delay        = value(stimDelay); % after the cue
        param.stim_length       = value(currStimDuration);
        param.changeStimDelay   = value(currChangeStimDelay);
        param.resp_window       = value(currResponseWindow);
        
        % % CUE properties
        if value(currValidLoc)==1
            param.cue_frequency = value(cue1Frequency)*1000;
            param.cue_rightSpeaker = 1;
            param.cue_leftSpeaker = 0;
            param.cue_centre_px = value(stim1Pos);
        else
            param.cue_frequency = value(cue2Frequency)*1000;
            param.cue_rightSpeaker = 0;
            param.cue_leftSpeaker = 1;
            param.cue_centre_px = value(stim2Pos);
        end
        
        
        % % Random dot properties of all spatial stimuluss
        % % NOTE: stimulus(1) is the Target
        param.stimulus(1).lumlevel =  value(currLumTarg);
        param.stimulus(1).radius_px = round(param.diag_px/param.diag_cm*param.radius_cm);
        
        
        param.stimulus(1).stim_dir = value(targetDirection);
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
        param.stimulus(2) = param.stimulus(1);
        if value(currValidLoc)==1
            param.stimulus(1).centre_px = value(stim1Pos);
            param.stimulus(2).centre_px = value(stim2Pos);
        else
            param.stimulus(1).centre_px = value(stim2Pos);
            param.stimulus(2).centre_px = value(stim1Pos);
        end
        
        
        param.stimulus(2).stim_dir    = param.stimulus(2).stim_dir + value(foilDeltaDirc_Deg);
        param.stimulus(2).lumlevel = value(currLumFoil);
        switch value(selectLumType)
            case 'UnChange/Change'
                % use foil/Target Lum to specify Lum of unchanging and changing stimuli respectively
                if   ~value(currValidTrial);
                    param.stimulus(2).lumlevel  = value(currLumTarg);
                    param.stimulus(1).lumlevel = value(currLumFoil);
                end
            case 'Loc1/Loc2'
                if  value(currValidLoc)==1
                    param.stimulus(1).lumlevel = value(currLumFoil);
                    param.stimulus(2).lumlevel  = value(currLumTarg);
                else
                    param.stimulus(1).lumlevel = value(currLumTarg);
                    param.stimulus(2).lumlevel  = value(currLumFoil);
                end
                
                
            otherwise % everything is already good Foil and Foil and Target is target
                
        end
        
        % % stimulus Change  parameters ... stimulus(3)
        param.stimChange_coh =   value(currCohChg);
        param.stimChange_dirn =   value(currDirnDeltaChg);
        param.stimChange_speed =   value(currSpeedChg);
        param.stimChange_lum =   value(currLumChg);
        
        
        if  value(currValidTrial);
            param.stimulus(3) = param.stimulus(1);
        else
            param.stimulus(3) = param.stimulus(2);
        end
        param.stimulus(3).dot_coherence = param.stimChange_coh;
        param.stimulus(3).stim_dir = param.stimChange_dirn;
        param.stimulus(3).lumlevel =  param.stimChange_lum ;
        param.stimulus(3).dot_speed_cm = tan(value(param.stimChange_speed)*pi/180)*value(distCm);
        param.stimulus(3).dot_speed_px = param.diag_px/param.diag_cm*param.stimulus(3).dot_speed_cm;
        % % other stimulus are distractors/Foils
        
        %% Others
        param. validTrial       =  value(currValidTrial);
        
        param.error_length      = value(errorVisualLength);
        param.error_lifetime    = value(flickeringError);
        param.error_sound_length = value(errorSoundLength);
        param.error_sound_volume = value(errorSoundVolume);
        param.reward_sound_length = value(rewardSoundLength);
        param.sound_volume      = value(soundVolume);
        param.change_sound_volume = value(currChangeVolume);
        
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

