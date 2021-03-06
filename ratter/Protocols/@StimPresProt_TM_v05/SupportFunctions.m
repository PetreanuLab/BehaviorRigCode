function [] = SupportFunctions(obj, action)

GetSoloFunctionArgs;

switch action,
    
    case 'store_history'
        
        %% UPDATE STATE MATRIX SECTION
            if currStimNum > 0
            stimDirHistory(value(currStimNum)) = value(currStimDir);
        
            stimDirHistory(value(currStimNum)) = value(currStimDir);
            
            stimTypeHistory{value(currStimNum)} = value(currStimType);
            
            gratTempFreqHistory(value(currStimNum)) = value(currGratTempFreq);
            gratSpatFreqHistory(value(currStimNum)) = value(currGratSpatFreq);
            gratTypeHistory{value(currStimNum)} = value(currGratType);
            
            dotCoherHistory(value(currStimNum)) = value(currDotCoher);
            dotLifeTimeHistory(value(currStimNum)) = value(currDotLifeTime);
            dotSizeHistory(value(currStimNum)) = value(currDotSize);
            dotSpeedHistory(value(currStimNum)) = value(currDotSpeed);
            dotDensityHistory(value(currStimNum)) = value(currDotDensity);
            end
        
    case 'set_next_stim'
        
        if n_done_trials < value(stimRepetition)
            currStimNum.value = n_done_trials + 1;
            
            currStimType.value = value(stimType);
            
            stimDirCumProb = cumsum(value(stimDirProb));
            stimDirRand = rand*stimDirCumProb(end);
            currStimDir.value = stimDir(find(stimDirRand <= stimDirCumProb,1));
            
            patchDegCumProb = cumsum(value(patchDegProb));
            patchDegRand = rand*patchDegCumProb(end);
            currPatchDeg.value = patchDeg(find(patchDegRand <= patchDegCumProb,1));
               
            if strcmp(value(currStimType), 'Grating')
                currGratType.value = value(gratType);
                
                gratTempFreqCumProb = cumsum(value(gratTempFreqProb));
                gratTempFreqRand = rand*gratTempFreqCumProb(end);
                currGratTempFreq.value = gratTempFreq(find(gratTempFreqRand <= gratTempFreqCumProb,1));
                
                gratSpatFreqCumProb = cumsum(value(gratSpatFreqProb));
                gratSpatFreqRand = rand*gratSpatFreqCumProb(end);
                currGratSpatFreq.value = gratSpatFreq(find(gratSpatFreqRand <= gratSpatFreqCumProb,1));
                
                currDotCoher.value = NaN;
                currDotLifeTime.value = NaN;
                currDotSize.value = NaN;
                currDotSpeed.value = NaN;
                currDotDensity.value = NaN;
                
            else
                
                currGratType.value = NaN;
                currGratTempFreq.value = NaN;
                currGratSpatFreq.value = NaN;
                
                dotCoherCumProb = cumsum(value(dotCoherProb));
                dotCoherRand = rand*dotCoherCumProb(end);
                currDotCoher.value = dotCoher(find(dotCoherRand <= dotCoherCumProb,1));
                
                dotLifeTimeCumProb = cumsum(value(dotLifeTimeProb));
                dotLifeTimeRand = rand*dotLifeTimeCumProb(end);
                currDotLifeTime.value = dotLifeTime(find(dotLifeTimeRand <= dotLifeTimeCumProb,1));
                
                dotSizeCumProb = cumsum(value(dotSizeProb));
                dotSizeRand = rand*dotSizeCumProb(end);
                currDotSize.value = dotSize(find(dotSizeRand <= dotSizeCumProb,1));
                
                dotSpeedCumProb = cumsum(value(dotSpeedProb));
                dotSpeedRand = rand*dotSpeedCumProb(end);
                currDotSpeed.value = dotSpeed(find(dotSpeedRand <= dotSpeedCumProb,1));
                
                dotDensityCumProb = cumsum(value(dotDensityProb));
                dotDensityRand = rand*dotDensityCumProb(end);
                currDotDensity.value = dotDensity(find(dotDensityRand <= dotDensityCumProb,1));
            end
        end
        
        %% Saves parameters for stimulus presentation
    case 'param_save'
        
        %% Screen Dimensions
        screen_width_px = value(screenWidthPx);
        screen_height_px = value(screenHeightPx);
        diag_cm = value(diagIn)*2.54;
        diag_px = sqrt(screen_width_px^2+screen_height_px^2);
        
        %% General stimulus properties
        stim_type = value(currStimType);
        stim_length = value(stimLength);
        base_length = value(baseLength);
        stim_ITI = value(ITI);
        radius_cm = tan(value(currPatchDeg)/2*pi/180)*value(viewingDistCm);
        radius_px = round(diag_px/diag_cm*radius_cm);
        centre_px = [value(centreX), value(centreY)];
        back_light = value(backLight);
        stim_light = value(stimLight);
        
        stim_dir = value(currStimDir);
        
        %% Random dot properties
        dot_lifetime = value(currDotLifeTime);
        dot_coherence = value(currDotCoher)/100;
        dot_speed_cm = tan(value(currDotSpeed)*pi/180)*value(viewingDistCm);
        dot_speed_px = diag_px/diag_cm*dot_speed_cm;
        if value(currDotSize) == 0
            dot_size_px = 1;
        else
            dot_size_cm = tan(value(currDotSize)*pi/180)*value(viewingDistCm);
            dot_size_px = round(diag_px/diag_cm*dot_size_cm);
        end
        dot_density = value(currDotDensity);
        dot_number = floor(dot_density*radius_px^2 /(dot_size_px/2)^2);
        
        
        %% Grating properties
        grat_type = value(currGratType);
        grat_temp_freq = value(currGratTempFreq);
        grat_spat_freq = 1/((tan(1/value(currGratSpatFreq)*pi/180)*value(viewingDistCm))*diag_px/diag_cm);
        
        save('c:/ratter/next_stimulus',...
            'stim_dir', 'stim_type','stim_length','base_length','radius_px','centre_px','back_light','stim_light',...
            'dot_lifetime','dot_speed_px','dot_size_px','dot_number','dot_coherence','dot_density',...
            'grat_type','grat_temp_freq','grat_spat_freq');
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
        
end;