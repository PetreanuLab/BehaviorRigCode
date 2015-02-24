function [] = SupportFunctions(obj, action)

GetSoloFunctionArgs;

%persistent player

switch action,
    
    case 'update_disp_param'
        
        if n_done_trials > 0
            lastISI.value = value(currISI);
            lastTestSide.value = value(currTestSide);
            lastAdaptationDuration.value = value(currAdaptationDuration);
            lastAdaptationSide.value = value(currAdaptationSide);
            lastTrial.value = n_done_trials;
        end

    
    case 'set_next_timings'
        
        adaptationDurationCumProb = cumsum(value(adaptationDurationProb));
        adaptationDurationRand = rand*adaptationDurationCumProb(end);
        currAdaptationDuration.value = adaptationDuration(find(adaptationDurationRand <= adaptationDurationCumProb,1));
        
        ISICumProb = cumsum(value(ISIProb));
        ISIRand = rand*ISICumProb(end);
        currISI.value = ISI(find(ISIRand <= ISICumProb,1));
        
    case 'set_next_stim'
        
        stimSizeCumProb = cumsum(value(stimSizeProb));
        stimSizeRand = rand*stimSizeCumProb(end);
        currStimSize.value = stimSize(find(stimSizeRand <= stimSizeCumProb,1));
        
        if strcmp(value(randSeedAdaptation),'random')
            currRandSeedAdaptation.value=randi(1000);
        else
            currRandSeedAdaptation.value=value(randSeedAdaptation);
        end
        
        if strcmp(value(randSeedTest),'random')
            currRandSeedTest.value=randi(1000);
        else
            currRandSeedTest.value=value(randSeedTest);
        end

        
        if rand < value(adaptationLeftProb)
            currAdaptationSide.value = 1;
        else
            currAdaptationSide.value = 0;
        end
        
        if rand < value(testLeftProb)
            currTestSide.value = 1;
        else
            currTestSide.value = 0;
        end
        
    case 'set_next_adaptation'
        
        adaptationCoherCumProb = cumsum(value(adaptationCoherProb));
        adaptationCoherRand = rand*adaptationCoherCumProb(end);
        currAdaptationCoher.value = adaptationCoher(find(adaptationCoherRand <= adaptationCoherCumProb,1));
        
        adaptationDensityCumProb = cumsum(value(adaptationDensityProb));
        adaptationDensityRand = rand*adaptationDensityCumProb(end);
        currAdaptationDensity.value = adaptationDensity(find(adaptationDensityRand <= adaptationDensityCumProb,1));
        
        adaptationSpeedCumProb = cumsum(value(adaptationSpeedProb));
        adaptationSpeedRand = rand*adaptationSpeedCumProb(end);
        currAdaptationSpeed.value = adaptationSpeed(find(adaptationSpeedRand <= adaptationSpeedCumProb,1));
        
        adaptationSizeCumProb = cumsum(value(adaptationSizeProb));
        adaptationSizeRand = rand*adaptationSizeCumProb(end);
        currAdaptationSize.value = adaptationSize(find(adaptationSizeRand <= adaptationSizeCumProb,1));
        
        adaptationLifeTimeCumProb = cumsum(value(adaptationLifeTimeProb));
        adaptationLifeTimeRand = rand*adaptationLifeTimeCumProb(end);
        currAdaptationLifeTime.value = adaptationLifeTime(find(adaptationLifeTimeRand <= adaptationLifeTimeCumProb,1));
        
    case 'set_next_test'
        
        testCoherCumProb = cumsum(value(testCoherProb));
        testCoherRand = rand*testCoherCumProb(end);
        currTestCoher.value = testCoher(find(testCoherRand <= testCoherCumProb,1));
        
        testDensityCumProb = cumsum(value(testDensityProb));
        testDensityRand = rand*testDensityCumProb(end);
        currTestDensity.value = testDensity(find(testDensityRand <= testDensityCumProb,1));
        
        testSpeedCumProb = cumsum(value(testSpeedProb));
        testSpeedRand = rand*testSpeedCumProb(end);
        currTestSpeed.value = testSpeed(find(testSpeedRand <= testSpeedCumProb,1));
        
        testSizeCumProb = cumsum(value(testSizeProb));
        testSizeRand = rand*testSizeCumProb(end);
        currTestSize.value = testSize(find(testSizeRand <= testSizeCumProb,1));
        
        testLifeTimeCumProb = cumsum(value(testLifeTimeProb));
        testLifeTimeRand = rand*testLifeTimeCumProb(end);
        currTestLifeTime.value = testLifeTime(find(testLifeTimeRand <= testLifeTimeCumProb,1));
        
    case 'param_save'
        %% Screen Dimensions
        diag_cm = value(diagIn)*2.54;
        diag_px = sqrt(screenPx(1)^2+screenPx(2)^2);
        
        %% General stimulus properties
        radius_cm = tan(value(currStimSize)/2*pi/180)*value(distCm);
        radius_px = round(diag_px/diag_cm*radius_cm);
        centre_px = value(stimPos);
        background_level = value(bckgLum);
        stim_level = value(stimLum);
        
        %% Adaptation stimulus properties
        stim_length_adaptation = value(currAdaptationDuration);
        if value(currAdaptationSide)
            stim_dir_adaptation = value(leftDirection);
        else
            stim_dir_adaptation = value(rightDirection);
        end
        dot_lifetime_adaptation = value(currAdaptationLifeTime);
        dot_coherence_adaptation = value(currAdaptationCoher)/100;
        dot_speed_cm_adaptation = tan(value(currAdaptationSpeed)*pi/180)*value(distCm);
        dot_speed_px_adaptation = diag_px/diag_cm*dot_speed_cm_adaptation;
        if value(currAdaptationSize) == 0
            dot_size_px_adaptation = 1;
        else
            dot_size_cm_adaptation = tan(value(currAdaptationSize)*pi/180)*value(distCm);
            dot_size_px_adaptation = round(diag_px/diag_cm*dot_size_cm_adaptation);
        end
        dot_number_adaptation = floor(value(currAdaptationDensity)*radius_px^2 /(dot_size_px_adaptation/2)^2);
        rand_seed_adaptation =value(currRandSeedAdaptation);
      
        %% Test stimulus properties
        stim_length_test = value(testDuration);
        if value(currTestSide)
            stim_dir_test = value(leftDirection);
        else
            stim_dir_test = value(rightDirection);
        end
        dot_lifetime_test = value(currTestLifeTime);
        dot_coherence_test = value(currTestCoher)/100;
        dot_speed_cm_test = tan(value(currTestSpeed)*pi/180)*value(distCm);
        dot_speed_px_test = diag_px/diag_cm*dot_speed_cm_test;
        if value(currTestSize) == 0
            dot_size_px_test = 1;
        else
            dot_size_cm_test = tan(value(currTestSize)*pi/180)*value(distCm);
            dot_size_px_test = round(diag_px/diag_cm*dot_size_cm_test);
        end
        dot_number_test = floor(value(currTestDensity)*radius_px^2 /(dot_size_px_test/2)^2);
        rand_seed_test =value(currRandSeedTest);

        
        %% Others
        save('c:/ratter/next_trial','radius_px','stim_level','background_level','centre_px',...
            'dot_coherence_adaptation','stim_dir_adaptation','stim_length_adaptation','dot_lifetime_adaptation',...
            'dot_size_px_adaptation','dot_speed_px_adaptation','dot_number_adaptation','rand_seed_adaptation',...
            'dot_coherence_test','stim_dir_test','stim_length_test','dot_lifetime_test',...
            'dot_size_px_test','dot_speed_px_test','dot_number_test','rand_seed_test');
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
        
end;