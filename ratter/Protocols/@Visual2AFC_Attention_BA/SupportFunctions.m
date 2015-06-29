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
            matchHistory(n_done_trials) = value(currFoilMatch);
            positionHistory(n_done_trials) = value(currStimPos);
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
            
            
            % keep track of correction loop
            temp = value(corrLoopV);
            
            if isempty(parsed_events.states.wrong_choice)==0
                if value(currStimSide)
                    if value(currStimPos)==1
                        temp(1) = temp(1)+1;
                    else
                        temp(2) = temp(2)+1;
                    end
                else % right side
                    if value(currStimPos)==1
                        temp(3) = temp(3)+1;
                    else
                        temp(4) = temp(4)+1;
                    end
                end
            elseif isempty(parsed_events.states.correct_choice)==0|| isempty(parsed_events.states.early_correct_choice)==0
                if value(currStimSide)
                    if value(currStimPos)==1
                        temp(1) = temp(1)-1;
                    else
                        temp(2) = temp(2)-1;
                    end
                else % right side
                    if value(currStimPos)==1
                        temp(3) = temp(3)-1;
                    else
                        temp(4) = temp(4)-1;
                    end
                end
            end
            temp(temp < 0 ) = 0;
            corrLoopV.value = temp;
        end
    case 'set_next_dots'
        
        if rand(1)<= probStimPos1
            currStimPos.value = 1;
            currTargetPos.value = value(stimPos);
            currFoilPos.value = value(stim2Pos);
        else
            currStimPos.value = 2;
            currTargetPos.value = value(stim2Pos);
            currFoilPos.value = value(stimPos);
        end
        
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
        
        %         intstimlum.value=value(tlum)*value(currdensity)+value(bckglum)*(1-value(currdensity));
        if rand(1) <= value(probFoilMatchTarget)
            currFoilMatch.value = 1;
        else
            
            currFoilMatch.value = 0;
        end
    case 'set_next_side'
        
        % BA cat
        trialDuration.value =  max(value(trialDuration),value(respDelay) + value(respWindow) + value(cueLength)+ value(postcueLength) + 0.5);
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
        
        % % blocks of high probablity Pos1 or Pos2
        

        blkLength = value(blockLength);
        blkProbPos1 = value( blockProbPos1);
        blkProbPos1Length =  length(blkProbPos1);
        if isnan(value(currBlockProbPos1Index))
            currBlockProbPos1Index.value = randi(length(blkProbPos1));
        end

        switch value(blockType)
            case 'noBlock'
                currBlockCount.value = 0;
            otherwise
                %                 Initialize Block
                if value(currBlockCount)==0
                    switch value(blockType)
                        case 'fixedBlock'
                            currBlockLength.value = blkLength(1);
                        case 'randomBlock'
                            if diff(blkLength)==0
                                currBlockLength.value= blkLength(1);
                            else
                                currBlockLength.value =randi(diff(blkLength))+ blkLength(1)-1;
                            end
                    end
                end
                
                currBlockCount.value = value(currBlockCount)+1;
                
                if value(currBlockCount)== currBlockLength
                    currBlockCount.value = 0;
                    currBlockProbPos1Index.value = mod(value(currBlockProbPos1Index),blkProbPos1Length)+1; % start a block with the next Pos1 PRob
                end
                
                % pick Position based on Block probability
                if rand(1)<= blkProbPos1(min(value(currBlockProbPos1Index),length(blkProbPos1)));
                    currStimPos.value = 1;
                    currTargetPos.value = value(stimPos);
                    currFoilPos.value = value(stim2Pos);
                else
                    currStimPos.value = 2;
                    currTargetPos.value = value(stim2Pos);
                    currFoilPos.value = value(stimPos);
                end
                
% %                 NOTE:  if correction loops are on they will override this
% %                 choice, but nonRandomSide will NOT
%                 if rand < value(leftProb) % always use the leftProb to pick stimulus LEFT/RIGHT
%                     currStimSide.value = 1;
%                 else
%                     currStimSide.value = 0;
%                 end
                 
        end
        
        switch value(sideSelection)
            
            case 'random'
                    if value(nonRandomSide)==0
                        if rand < value(leftProb)
                            currStimSide.value = 1;
                        else
                            currStimSide.value = 0;
                        end
                    end
            case 'biasCorrection'
                    if value(nonRandomSide)==0
                        
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
                
            case 'correctionLoop'
                temp =  value(corrLoopV);
                if correctionLoopThres <0
                    corrLoopV.value = [0 0 0 0];
                end
                currCorrLoop.value = 1;
                if temp(1) >= correctionLoopThres
                    currStimSide.value = 1;
                    currStimPos.value = 1;
                    currTargetPos.value = value(stimPos);
                    currFoilPos.value = value(stim2Pos);

                elseif temp(2) >= correctionLoopThres
                    currStimSide.value = 1;
                    currStimPos.value = 2;
                    currTargetPos.value = value(stim2Pos);
                    currFoilPos.value = value(stimPos);

                elseif temp(3) >= correctionLoopThres
                    currStimSide.value = 0;
                    currStimPos.value = 1;
                    currTargetPos.value = value(stimPos);
                    currFoilPos.value = value(stim2Pos);

                elseif temp(4) >= correctionLoopThres
                    currStimSide.value = 0;
                    currStimPos.value = 2;
                    currTargetPos.value = value(stim2Pos);
                    currFoilPos.value = value(stimPos);

                else
                     
                    currCorrLoop.value = 0;
                    if value(nonRandomSide)==0
                        if rand < value(leftProb)
                            currStimSide.value = 1;
                        else
                            currStimSide.value = 0;
                        end
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
            lastMatch.value = matchHistory(n_done_trials);
        end
        
        if n_done_trials > value(meanSize)
            meanAccu.value = sum(correctHistory((end-value(meanSize)+1):end))/(value(meanSize)-sum(timeOutHistory((end-value(meanSize)+1):end)));
            
            ssH = value(stimSideHistory);  ssH = ssH(end-value(meanSize)+1:end);
            tH = value(timeOutHistory);  tH = tH(end-value(meanSize)+1:end);
            cH = value(correctHistory);  cH = cH(end-value(meanSize)+1:end);
            pH = value(positionHistory); pH = pH(end-value(meanSize)+1:end);
            nP1 = sum(pH==1)-sum(tH(pH==1));            nP2 = sum(pH==2)-sum(tH(pH==2));
            meanAcPos1.value = sum(cH(pH==1))/nP1;
            meanAcPos2.value = sum(cH(pH==2))/nP2;
            meanAccu.value = sum(correctHistory((end-value(meanSize)+1):end))/(value(meanSize)-sum(timeOutHistory((end-value(meanSize)+1):end)));
            meanTimeOut.value = mean(timeOutHistory((end-value(meanSize)+1):end));
            meanChoice.value = nanmean(choiceHistory((end-value(meanSize)+1):end));
            meanStimSide.value = mean(stimSideHistory((end-value(meanSize)+1):end));
            
            meanBias.value = (value(meanChoice)-value(meanStimSide)+1)/2;
            meanBPos1.value = (nanmean(cH(pH==1))-mean(ssH(pH==1))+1)/2; % BA I am not sure that this correctly deals with missed trials
            meanBPos2.value = (nanmean(cH(pH==2))-mean(ssH(pH==2))+1)/2;
            
            
        end
        
    case 'param_save'
        %% Screen Dimensions
        diag_cm = value(diagIn)*2.54;
        diag_px = sqrt(screenPx(1)^2+screenPx(2)^2);
        
        %% General stimulus properties
        tLum = getprob(targetLum,targetLumProb);
        fLum = getprob(foilLum,foilLumProb);
        intStimLum.value=value(tLum)*value(currDensity)+value(bckgLum)*(1-value(currDensity));
        
        
        stim_length = value(currStimDuration);
        radius_cm = tan(value(currStimSizeDeg)/2*pi/180)*value(distCm);
        
        Loc(1).stim_level =tLum;
        Loc(1).radius_px = round(diag_px/diag_cm*radius_cm);
        Loc(1).centre_px = value(currTargetPos);
        if value(currStimSide)
            Loc(1).stim_dir = value(leftDirection);
        else
            Loc(1).stim_dir = value(rightDirection);
        end
        
        
        %% Random dot properties
        Loc(1).dot_lifetime = value(currLifeTime);
        Loc(1).dot_coherence = value(currCoher)/100;
        Loc(1).dot_speed_cm = tan(value(currSpeed)*pi/180)*value(distCm);
        Loc(1).dot_speed_px = diag_px/diag_cm* Loc(1).dot_speed_cm;
        if value(currSize) == 0
            Loc(1).dot_size_px = 1;
        else
            Loc(1).dot_size_cm = tan(value(currSize)*pi/180)*value(distCm);
            Loc(1).dot_size_px = round(diag_px/diag_cm* Loc(1).dot_size_cm);
        end
        Loc(1).dot_number = floor(value(currDensity)* Loc(1).radius_px^2 /( Loc(1).dot_size_px/2)^2);
        
        % Loc 2 is always the foil
        if isequal(value(stimuliMode),'one')
            presentFoil = 0;
        else
            presentFoil = 1;
        end
        
        Loc(2) = Loc(1);
        Loc(2).stim_level = fLum;
        Loc(2).centre_px = value(currFoilPos);
        Loc(2).dot_coherence = getprob(foilCoh,foilCohProb);
        if isequal(value(stimuliMode),'two')      % in this mode the foil is just present but doesn't indicate a  direction
            Loc(2).dot_coherence = 0;
        end
        if value(currFoilMatch);
            Loc(2).stim_dir  =  Loc(1).stim_dir ;
            currFoilSide.value = value(currStimSide);            
        else
            
            Loc(2).dot_speed_cm = tan(value(foilDotSpeed)*pi/180)*value(distCm);
            Loc(2).dot_speed_px = diag_px/diag_cm* Loc(2).dot_speed_cm;
            if value(currStimSide)
                Loc(2).stim_dir  =  value(rightDirection);
                currFoilSide.value = 0 ;
            else
                Loc(2).stim_dir  = value(leftDirection);
                currFoilSide.value = 1 ;
            end
        end
        

        
        currFoilCoh.value = Loc(2).dot_coherence ;
        currFoilDirn.value = Loc(2).stim_dir ;
        
        background_level = value(bckgLum);
        inter_stim_level = value(intStimLum);
        rand_seed = value(currRandSeed);
        %% Others
        cue_length = value(cueLength);
        if value(currStimPos)==1
            cue_Freq = value(cue1Freq);
        else
            cue_Freq = value(cue2Freq);
        end
        cue_radiuspx =  Loc(1).radius_px;
        cuePos = Loc(1).centre_px;
        cue_sound_volume =value(cueVolume);
        cue_sound_length      = value(cueSoundLength);
        if value(currStimPos)==1
            cue_rightSpeaker = 1;
            cue_leftSpeaker = 0;
        else
            cue_leftSpeaker = 1;
            cue_rightSpeaker = 0;
        end
        preStimulusDelay = value(postcueLength);
        
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
        
        
        save(fullfile(r.DIR.ratter, 'next_trial_2afc_attention'),'presentFoil',...
            'stim_length',...
            'background_level','inter_stim_level',...
            'error_length','error_lifetime','error_sound_length','reward_sound_length',...
            'sound_volume','sound_sides_volume','trial_sounds','after_lick','stop_stimulus',...
            'visual_error','sound_sides','left','pre_stimulus','resp_delay','resp_window',...
            'left_frequency','right_frequency','rand_seed','preStimulusDelay',...
            'cue_length','cue_Freq','cuePos','cue_radiuspx','cue_sound_volume','cue_sound_length','cue_leftSpeaker','cue_rightSpeaker','Loc');
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
        
end;
end
function out = getprob(val,Prob)
CumProb = cumsum(value(Prob));
valRand = rand*CumProb(end);
out = val(find(valRand <= CumProb,1));
end
