function [] = SupportFunctions(obj, action)

GetSoloFunctionArgs;

switch action,
    
    
    %% Saves parameters for stimulus presentation
    case 'param_save'
        
        %% Monitor properties
        screenOrientation = value(screenOri);
        screenBrightness = value(stimLight);
        
        %% Alignment
        distanceCm = value(viewingDistCm);
        centerCm = value(centerPos);
        
        %% Stimulus properties
        orientation = [value(stimOri) value(stimDir)];
        stimPeriod = value(barPeriod);
        numCycles = value(stimRepetitions);
        barWidthDeg =value(barSizeDeg);
        edgesDeg = value(edges);
        cbFlag = value(cbON);
        cbSizeDeg = value(cbSpatialPeriod);
        cbPeriod = value(cbTemporalPeriod);
        
        save('c:/ratter/next_stimulus',...
            'screenOrientation', 'screenBrightness','distanceCm','centerCm',...
            'orientation','stimPeriod','numCycles','barWidthDeg','edgesDeg',...
            'cbFlag','cbSizeDeg','cbPeriod');
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
        
end;