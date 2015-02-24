function FourierStim_v2(action)

%% Imports and persistent variables
import Devices.NI.DAQmx.*

%% Initiations and instatiations of persistent variables
global folderPath
global hCtr
global w rect frameRate maxLevel minLevel stimLevel ifi waitframes screenBrightness
global elevation azimuth elevationBorders azimuthBorders elevationRange azimuthRange elevationMid azimuthMid cbMask
global barPos tex numCycles
global animal experiment

%% Experiment parameters
animal = 'JN0029';
experiment = '160215_vr_a'
%% Monitor properties
screenOrientation = 1;  % 0 for vertical; 1 for horizontal
screenBrightness =  0.2; %0.1  % value between 0 and 1 (full brightness)

%% Alignement
distanceCm = 9.5;    % distance of eye to screen
centerCm = [0 0];   % offset of projection of eye in the screen

%% Stimulus properties
orientation = [1 1];       % col 1: 0 for horizontal, 1 for vertical
                           % col 2: 1 for right/down, -1 for left/up
stimPeriod = 12;           % stimulus period
numCycles = 80;            % number of stimulus
barWidthDeg =20;           % width of drifting bar
edgesDeg = 0.1;            % screen extension for each side in percentage of
% range in degrees 
cbFlag = 1;                % 0 no checkerboard; 1 checkerboard
cbSizeDeg = 30;            % size of checkerboard pattern in degrees
cbPeriod = 0.166;

%% Constants - DON'T CHANGE
inch = 2.54;
diagIn = 24;    % screen diagonal in inches


switch action
    
    case 'init'
        
        FourierStim_v2('open_nidaq');
        FourierStim_v2('open_screen');
        FourierStim_v2('set_calibration');
        FourierStim_v2('prepare_stim');
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
        % Gets monitor frame rate
        frameRate=Screen('FrameRate',screenNumber);
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
        
        stimLevel = screenBrightness*maxLevel;
        
                        disp('Calibration set');

        
    case 'prepare_stim'
        
        stimLevel = screenBrightness*maxLevel;
        
        %% Number of frames
        stimFrames=stimPeriod*frameRate;                 % Per stimulus
        cbPeriodFrames = round(frameRate*cbPeriod);     % Per checkboard cycle
        
        %% Gets the position of the drifting bar for each frame
        % Vertical stimulus
        if orientation(1)
            barPos = linspace(azimuthMid-orientation(2)*azimuthRange*(0.5+edgesDeg),azimuthMid+orientation(2)*azimuthRange*(0.5+edgesDeg),stimFrames);
            % Horizontal Stimulus
        else
            barPos = linspace(elevationMid-orientation(2)*elevationRange*(0.5+edgesDeg),elevationMid+orientation(2)*elevationRange*(0.5+edgesDeg),stimFrames);
        end
        
        %% Compute each frame of the movie
        % and convert those frames, stored in MATLAB matrices, into Psychtoolbox
        % OpenGL textures using 'MakeTexture';
        % Number of frames in each stimulus repetition
        for i=1:stimFrames
            %% Computes mask for drifting bar
            % Vertical stimulus
            if orientation(1)
                barMask=(azimuth>(barPos(i)-barWidthDeg/2)).*(azimuth<(barPos(i)+barWidthDeg/2));
                % Horizontal stimulus
            else
                barMask=(elevation>(barPos(i)-barWidthDeg/2)).*(elevation<(barPos(i)+barWidthDeg/2));
                
            end
            %% Computes final mask and converts into textures
            % With checkerboard
            if cbFlag
                % Checks if checkerboard period is over
                if rem(i,cbPeriodFrames)==0
                    % Flickers checkerboard
                    cbMask=~cbMask;
                end
                % Converts mask into texture
                tex(i)=Screen('MakeTexture', w, uint8(stimLevel*barMask.*cbMask));
                % Without checkerboard
            else
                % Converts mask into texture
                tex(i)=Screen('MakeTexture', w, uint8(stimLevel*barMask));
            end
            
        end
        
        % Use realtime priority for better timing precision:
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        
        Screen('FillRect',w, minLevel,rect);
        Screen('Flip', w);
        
        disp('Stimulus ready');
        
        
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
            'screenOrientation', 'screenBrightness','diagIn',...
            'orientation','stimPeriod','numCycles','barWidthDeg','edgesDeg',...
            'cbFlag','cbSizeDeg','cbPeriod',...
            'barPos');
        
        disp('Data saved')
        
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
            %% Presents all stimulus frames
            for n=1:numCycles
                for j=1:length(tex)
                    % Draw image:
                    Screen('DrawTexture', w, tex(j))
                    vbl = Screen('Flip', w, vbl + (waitframes - 0.5) * ifi);
                    
                end

            end
            
            Screen('FillRect',w, minLevel,rect);
            Screen('Flip', w);
            
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
            'screenOrientation', 'screenBrightness','diagIn',...
            'orientation','stimPeriod','numCycles','barWidthDeg','edgesDeg',...
            'cbFlag','cbSizeDeg','cbPeriod',...
            'barPos');
        
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
