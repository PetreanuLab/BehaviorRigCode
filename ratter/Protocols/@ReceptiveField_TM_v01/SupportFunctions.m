
function [] = SupportFunctions(obj, action)

GetSoloFunctionArgs(obj);

persistent totCells

switch action,

    case 'set_session'
        totCells = gridCells(1)*gridCells(2);
        totTrial.value = value(gridRepetition)*totCells*length(stimDir);
        
%         diag_cm = value(diagIn)*2.54;
%         diag_px = sqrt(screenSizePx(1)^2+screenSizePx(2)^2);
%     
        gridSizeDeg.value = [value(cellSizeDeg)*gridCells(1) value(cellSizeDeg)*gridCells(2)];
        gridRangeDeg.value = [-value(cellSizeDeg)*gridCells(1)/2+gridCenterDeg(1) value(cellSizeDeg)*gridCells(1)/2+gridCenterDeg(1) -value(cellSizeDeg)*gridCells(2)/2+gridCenterDeg(2) value(cellSizeDeg)*gridCells(2)/2+gridCenterDeg(2)];
        
%         gridSizeCm = gridSizePx*diag_cm/diag_px;
%         gridSizeDeg.value = 2*atan(gridSizeCm./2/value(viewingDistCm))*180/pi;
        
%         cellSizeCm = gridSizePx./gridCells*diag_cm/diag_px;
%         
%         cellSizeDeg.value = atan(cellSizeCm./value(viewingDistCm))*180/pi;
%         
%         cellSizePx = gridSizePx./gridCells;
        
    case 'set_next_stim'
        
        if n_done_trials < value(totTrial)
            currTrial.value = n_done_trials + 1;
            
            dirIndex = mod(value(currTrial)-1,length(stimDir))+1;
            
            %posIndex = mod(value(currTrial)-1,length(stimDir)*totCells)+1;
            
            currDir.value = stimDir(dirIndex);
            
            posIndex=mod(ceil((value(currTrial))/length(stimDir))-1,totCells)+1;
            currGrid.value = floor((value(currTrial)-1)/(length(stimDir)*totCells))+1;
                        
            currGridPos.value=[mod(posIndex-1,gridCells(1))+1 ceil(posIndex/gridCells(1))];
        end
        
        %% Saves parameters for stimulus presentation
    case 'param_save'
        
        %% Screen Dimensions
        distance_cm = value(viewingDistCm);
%         screen_width_px = screenSizePx(1);
%         screen_height_px = screenSizePx(2);
        
        %% General stimulus properties
        stim_length = value(stimLength);
        base_length = value(baseLength);
        stim_ITI = value(ITI);
        centre_cm = value(viewCenterCm);
        grid_centre_deg = value(gridCenterDeg);
        back_light = value(backLight);
        stim_light = value(stimLight);
        
        %cell_px = cellSizePx;
        %cell_corner = [(currGridPos(1)-1)*cellSizePx(1) (currGridPos(2)-1)*cellSizePx(2)];
        cell_deg = value(cellSizeDeg);
        cell_size(1)=gridCells(1);
        cell_size(2)=gridCells(2);        
        stim_dir = value(currDir);
        stim_pos(1) = currGridPos(1);
        stim_pos(2) = currGridPos(2);
        stim_speed=value(barSpeed);
        stim_width=value(barWidth);
        %stim_speed = tan(value(barSpeed)*pi/180)*value(viewingDistCm)*diag_px/diag_cm;
        %stim_width = tan(value(barWidth)*pi/180)*value(viewingDistCm)*diag_px/diag_cm;
                
        save('c:/ratter/next_stimulus',...
            'distance_cm','cell_size',...
            'cell_deg','stim_dir', 'stim_pos','stim_speed','stim_width',...
            'stim_length','base_length','stim_ITI','centre_cm','grid_centre_deg','back_light','stim_light');
        
    otherwise,
        error(['Don''t know how to deal with action ' action]);
        
end;