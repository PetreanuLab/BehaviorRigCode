
function WhiteStim_TM_v01(stopMe)


%% Imports
import Devices.NI.DAQmx.*
r = visRigDefs;
%% Initiations and instatiations of persistent variables
counter=0;
persistent hCtr killMe 
persistent w rect 

close all;

%% Interrupt section
if nargin < 1
    killMe = false;
elseif stopMe
    killMe = stopMe;
end

if killMe && ~isempty(hCtr)
    hCtr.stop();
    return;
elseif ~isempty(hCtr)
    delete(hCtr);
end

%% Opens Psychtoolbox window
% Open a double buffered fullscreen window and select a gray background
% color:
screenNumber =  r.visualScreen.ID ; % Stimulus screen
windowPtrs=Screen('Windows');
if isempty(windowPtrs)
    [w, rect]  = Screen('OpenWindow', screenNumber, 0,[], 8, 2);
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    frameRate=Screen('FrameRate',screenNumber);
    
else
    disp('Existing window found');
    w = windowPtrs(end);
    frameRate=Screen('FrameRate',screenNumber);

end

%% NIDAQ Configuration
%Create AI Task
deviceName = 'Dev1';
hCtr = Task('myTask');
hCtr.createAIVoltageChan(deviceName,0,'myTriggerAI0');
hCtr.cfgDigEdgeStartTrig('PFI0');
%hCtr.cfgSampClkTiming(1000,'DAQmx_Val_ContSamps');
hCtr.cfgSampClkTiming(10000,'DAQmx_Val_FiniteSamps',2);
hCtr.registerDoneEvent(@FrameStartCallback); %Both DAQmx_Val_SampleClock and DAQmx_Val_SampleCompleteEvent yield same results
pause(1); %Give the registration a chance to 'settle' before starting Task. (otherwise, first event is skipped)
hCtr.start();

%% Trigger received
    function FrameStartCallback(~,~)
        disp('Trigger received');
        switch counter
            case 0
                PresentStimulus();
                counter = 1;
                stop(hCtr);
                start(hCtr);
            case 1
                StopStimulus();
                counter = 0;
                stop(hCtr);
                start(hCtr);
        end
    end

    function PresentStimulus()
        
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        
        Screen('FillRect',w, uint8(255),rect);
        Screen('Flip', w);
        Priority(0);
        disp('Stimulus On');
        
        
    end

    function StopStimulus()
        
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        
        Screen('FillRect',w, uint8(0),rect);
        Screen('Flip', w);
        Priority(0);
        disp('Stimulus Off');
        
    end
end
