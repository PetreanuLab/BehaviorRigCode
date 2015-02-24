function GratingsStim(action)

%% Imports and persistent variables
import Devices.NI.DAQmx.*

%% Initiations and instatiations of persistent variables
global folderPath
global hCtr
global w rect frameRate maxLevel minLevel stimLevel bckgLevel ifi waitframes stimBrightness bckgBrightness screenOrientation glsl
global elevation azimuth elevationBorders azimuthBorders elevationRange azimuthRange elevationMid azimuthMid cbMask cbSizeDeg
global animal experiment
global diagCm distanceCm centerCm
global baseline stimLength ITI
global stimDir radiusDeg tempFreq spatCpd posDeg
global p radiusPx posPx spatFreq shiftperframe visiblesize gratingtex
global nFramesBase nFramesDir nFramesIti

%% Experiment parameters
animal = 'BA_SC004';
experiment = 'GRATING270';
%% Monitor properties
screenOrientation = 1;  % 0 for vertical; 1 for horizontal
stimBrightness =  0.5; %0.1  % value between 0 and 1 (full brightness)
bckgBrightness = 0;
cbSizeDeg = 20;

%% Alignement
distanceCm = 11;    % distance of eye to screen
centerCm = [0 0];   % offset of projection of eye in the screen

%% Stimulus properties
baseline = 2;
stimLength = 2;           % stimulus period
ITI = 2;
posDeg = [10 5;
          40 5;
          10 -35;
          40 -35]; % LEFT/RIGHT -/+ UP/DOWN -/+
stimRep = 30;            % number of stimulus
stimDir = [270];
radiusDeg = 10;
tempFreq = 2;
spatCpd = 0.08;

%% Constants - DON'T CHANGE
diagIn = 24;    % screen diagonal in inches
inch = 2.54;
diagCm = diagIn*inch;


switch action
    
    case 'init'
        GratingsStim('open_nidaq');
        GratingsStim('open_screen');
        GratingsStim('set_calibration');
        GratingsStim('prepare_stim');

    case 'set_dir'
        folderPath = uigetdir;
        
    case 'open_nidaq'    
        %% NIDAQ configuration
        deviceName = 'Dev1';
        hCtr = Task('myTask');
        hCtr.createAIVoltageChan(deviceName,0,'myTriggerAI0');
        hCtr.cfgDigEdgeStartTrig('PFI0');
        hCtr.cfgSampClkTiming(10000,'DAQmx_Val_FiniteSamps',2);
        hCtr.registerDoneEvent(@FrameStartCallback); %Both DAQmx_Val_SampleClock and DAQmx_Val_SampleCompleteEvent yield same results
        pause(1); %Give the registration a chance to 'settle' before starting Task. (otherwise, first event is skipped)
        
        %% Starts accepting pulses
        hCtr.start();
        
        disp('NIDAQ set');
        
    case 'close_nidaq'
        hCtr.delete();        
        disp('NIDAQ closed');
        
    case 'open_screen'
        %% Opens window for presenting stimulus
        screenNumber=2;
        % Open a double buffered fullscreen window
        [w, rect]  = Screen('OpenWindow', screenNumber, 0,[], 8, 2);
        Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        % Gets monitor frame rate
        frameRate=Screen('FrameRate',screenNumber);
        glsl = MakeTextureDrawShader(w, 'SeparateAlphaChannel');
        % Gets black, white and stimulus levels
        maxLevel=WhiteIndex(screenNumber);
        minLevel=BlackIndex(screenNumber);
        
        %% Variables for optimal frame timing
        % Query duration of one monitor refresh interval:
        ifi=Screen('GetFlipInterval', w);
        % waitframes = 1 means: Redraw every monitor refresh.
        waitframes = 1;
                
        disp('Screen open');
        
        
    case 'close_screen'
        
        Screen('CloseAll');
        disp('Screen closed');
        
        
    case 'set_calibration'
        
        %% Sets angular coordinate system
        % Width and height of monitor in cm
        y0 = 16*diagIn/sqrt(16^2+9^2)*inch;
        z0 = 9*diagIn/sqrt(16^2+9^2)*inch;
        y=linspace(-y0/2,y0/2,rect(3));
        z=linspace(-z0/2,z0/2,rect(4));
        % Monitor coordinates in cm
        [Y,Z] = meshgrid(y,z);
        % Vertical monitor
        if screenOrientation
            % Monitor angular coordinates in reference to the defined center
            elevation = (pi/2-acos((Z-centerCm(2))./sqrt(distanceCm^2+(Y-centerCm(1)).^2+(Z-centerCm(2)).^2)))/pi*180;
            azimuth = atan((Y-centerCm(1))./distanceCm)/pi*180;
        else
            % Monitor angular coordinates in reference to the defined center
            elevation = (pi/2-acos((Y-centerCm(2))./sqrt(distanceCm^2+(Z-centerCm(1)).^2+(Y-centerCm(2)).^2)))/pi*180;
            azimuth = -atan((Z-centerCm(1))./distanceCm)/pi*180;
        end
        
        %% Auxiliary angular variables
        % Maximum and minimum values
        elevationBorders=[min(min(elevation)) max(max(elevation))]
        azimuthBorders=[min(min(azimuth)) max(max(azimuth))]
        % Range
        elevationRange = elevationBorders(2)-elevationBorders(1);
        azimuthRange = azimuthBorders(2)-azimuthBorders(1);
        % Mid point
        elevationMid = (elevationBorders(2)+elevationBorders(1))/2;
        azimuthMid = (azimuthBorders(2)+azimuthBorders(1))/2;
        
        %% Computes checkerboard mask
        cbMask = cos(azimuth*2*pi/cbSizeDeg).*cos(elevation*2*pi/cbSizeDeg)>0;
        
        stimLevel = stimBrightness*maxLevel;
        bckgLevel = bckgBrightness*maxLevel;
        
        disp('Calibration set');
    
            case 'show_calibration'
        
        % Converts checkerboard mask into texture
        cbTex=Screen('MakeTexture', w, stimLevel.*cbMask);
        
        % Draw image:
        Screen('DrawTexture', w, cbTex);
        Screen('Flip', w);
        
    case 'blank_monitor'
        
        Screen('FillRect',w, minLevel,rect);
        Screen('Flip', w);
        
    case 'save'
        
        % For posterior data analysis
        save([folderPath filesep animal '_'  experiment],...
            'animal','experiment',...
            'screenOrientation', 'stimRep','diagIn',...
            'baseline','stimLength','ITI','posDeg','stimRep',...
            'stimDir','radiusDeg','tempFreq',...
            'spatCpd');

        
        disp('Data saved')
        
    case 'prepare_stim'
        
        % Aux calculations
        diagPx = sqrt(rect(3)^2+rect(4)^2);
        radiusCm = tan(radiusDeg*pi/180)*distanceCm;
        radiusPx = round(diagPx/diagCm*radiusCm);
        spatFreq = 1/((tan(1/spatCpd*pi/180)*distanceCm)*diagPx/diagCm);
        
        for i=1:size(posDeg,1)
            %aux=zeros(size(rect));
            index_1=abs(azimuth-posDeg(i,1))<0.1;
            index_2=abs(elevation-posDeg(i,2))<0.1;
            index = index_1&index_2;
            %aux(index)=1;    
            [r, c]=find(index);
        
            posPx(i,1) = round(mean(c));
            posPx(i,2) = round(mean(r));
        end
        
        % Calculate parameters of the grating:
        p=ceil(1/spatFreq); % pixels/cycle, rounded up.
        fr = spatFreq*2*pi;
        
        % Create one single static grating image:
        x = meshgrid(-radiusPx:radiusPx + p, -radiusPx:radiusPx);
        
        inc = stimLevel - bckgLevel;
        
        grating = uint8(bckgLevel) + uint8(inc*cos(fr*x));
        
        % Create circular aperture for the alpha-channel:
        [x,y]=meshgrid(-radiusPx:radiusPx, -radiusPx:radiusPx);
        circle = uint8(stimLevel * (x.^2 + y.^2 <= (radiusPx)^2));
        
        % Set 2nd channel (the alpha channel) of 'grating' to the aperture
        % defined in 'circle':
        grating(:,:,2) = 0;
        grating(1:2*radiusPx+1, 1:2*radiusPx+1, 2) = circle;
        
        % Store alpha-masked grating in texture and attach the special 'glsl'
        % texture shader to it:
        gratingtex = Screen('MakeTexture', w, grating , [], [], [], [], glsl);
                
        waitduration = waitframes * ifi;
        
        % Recompute p, this time without the ceil() operation from above.
        % Otherwise we will get wrong drift speed due to rounding!
        p = 1/spatFreq; % pixels/cycle
        
        % Translate requested speed of the gratings (in cycles per second) into
        % a shift value in "pixels per frame", assuming given waitduration:
        shiftperframe = tempFreq * p * waitduration;
        
        %% Number of frames
        nFramesBase = round(baseline*frameRate);
        nFramesDir = round(stimLength/length(stimDir)*frameRate);
        nFramesIti = round(ITI*frameRate);
        visiblesize=2*radiusPx+1;
        
        % Use realtime priority for better timing precision:
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        
        Screen('FillRect',w, minLevel,rect);
        Screen('Flip', w);
        
        disp('Stimulus ready');
        
    otherwise
        disp('I dont know what you mean');
        
end

%% Trigger function
    function FrameStartCallback(~,~)
        % Trigger received
        disp('Trigger Received')
        % Stops accepting new triggers
        stop(hCtr);
        
        % Perform initial Flip to sync us to the VBL and for getting an initial
        % VBL-Timestamp for our "WaitBlanking" emulation:
        vbl=Screen('Flip', w);

        try
            for m = 1:size(posPx,1)
                % Definition of the drawn source rectangle on the screen:
                srcRect=[0, 0, visiblesize, visiblesize];
                dstRect=[posPx(m,1)-radiusPx, posPx(m,2)-radiusPx,...
                    posPx(m,1)-radiusPx+visiblesize, posPx(m,2)-radiusPx+visiblesize];
                for n = 1:stimRep
                    for o=1:nFramesBase
                        Screen('FillRect',w, uint8(minLevel),rect);
                        Screen('Flip', w);
                        drawnow();
                    end
                    for q = 1:length(stimDir)
                        for u = 1:nFramesDir
                            % Shift the grating by "shiftperframe" pixels per frame. We pass
                            % the pixel offset 'yoffset' as a parameter to
                            % Screen('DrawTexture'). The attached 'glsl' texture draw shader
                            % will apply this 'yoffset' pixel shift to the RGB or Luminance
                            % color channels of the texture during drawing, thereby shifting
                            % the gratings. Before drawing the shifted grating, it will mask it
                            % with the "unshifted" alpha mask values inside the Alpha channel:
                            yoffset = mod(u*shiftperframe,p);
                            %Screen('FillRect',w, uint8(maxLevel),srcRect, dstRect);
                            % Draw first grating texture, rotated by "angle":
                            Screen('DrawTexture', w, gratingtex, srcRect, dstRect, stimDir(q), [], [], [], [], [], [0, yoffset, 0, 0]);
                            % Screen('DrawTexture', w, gratingtex, [], [], gratAngle, [], [], [], [], [], [0, yoffset, 0, 0]);
                            %Screen('DrawTexture', w, gratingtex)
                            vbl = Screen('Flip', w, vbl +  (waitframes - 0.5) * ifi);
                            
                            drawnow();
                        end
                    end
                    
                    for o=1:nFramesIti
                        
                        Screen('FillRect',w, uint8(minLevel),rect);
                        Screen('Flip', w);
                        
                    end
                    
                end
            end
            % Close all textures
            Screen('Close');
            
            Priority(0);
            
            % Starts accepting new triggers
            start(hCtr);
            
            disp('Stimulus presented')
            
            folderPath = uigetdir;
            
            
        % For posterior data analysis
        save([folderPath filesep animal '_'  experiment],...
            'animal','experiment',...
            'screenOrientation', 'stimRep','diagIn',...
            'baseline','stimLength','ITI','posDeg','stimRep',...
            'stimDir','radiusDeg','tempFreq',...
            'spatCpd');
            
            disp('Data saved')
            
            
        catch
            Screen('FillRect',w, minLevel,rect);
            Screen('Flip', w);
            % Close all textures
            Screen('Close');
            
            Priority(0);
            
            % Starts accepting new triggers
            start(hCtr);
            
            disp('Stimulus aborted')
            
            psychrethrow(psychlasterror);
        end
        
    end

end