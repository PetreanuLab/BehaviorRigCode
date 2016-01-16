function StimulusPresentationRT_Attention(bugMe)

% Based on v17 just slightly edited to include rigdefs

%% Imports
import Devices.NI.DAQmx.*
r = visRigDefs;
%% Initiations and instatiations of persistent variables

bplaysoundfrombothspeakers =1;
if isfield(r.visualScreen,'playsoundfrombothspeakers')
    bplaysoundfrombothspeakers = r.visualScreen.playsoundfrombothspeakers; % otherwise play sound from cued side
end

counter=0;
audio_freq = 44000;
wrong = 0;
afterLick = 0;
nLoc = 1;
persistent hCtr data
persistent w rect frameRate
persistent loc %%(iloc).dotCentre dotCentrePolar dotDirection
persistent elapsedTime lickTime
persistent player
persistent s1 s2 cueSound

close all;

%% Interrupt section
if nargin < 1
    killMe = false;
elseif bugMe
    killMe = bugMe;
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
hCtr.cfgSampClkTiming(10000,'DAQmx_Val_FiniteSamps',2);
hCtr.registerDoneEvent(@FrameStartCallback); %Both DAQmx_Val_SampleClock and DAQmx_Val_SampleCompleteEvent yield same results
pause(1); %Give the registration a chance to 'settle' before starting Task. (otherwise, first event is skipped)
hCtr.start();


%% Trigger received
    function FrameStartCallback(~,~)
        try
        %disp('Trigger received')
        switch counter
            case 0
                counter = 1;
                PrepareStimulus();
                stop(hCtr);
                start(hCtr);
                
            case 1
                counter = 2;
                stop(hCtr);
                start(hCtr);
                PresentCue()
                PresentStimulus();
                counter=0;
                
            case 2
                counter = 3;
                LickDetected();
                stop(hCtr);
                start(hCtr);
                
            case 3
                counter = 4;
                TimerOut();
                stop(hCtr);
                start(hCtr);
            case 4
                AfterLick();
                stop(hCtr);
                start(hCtr);
        end
        catch me
            getReport(me)
        end
        
    end

    function PrepareStimulus()
        data = load(fullfile(r.DIR.temp,'next_trial_2afc_attention'));
        afterLick = 0;
        
        s1 = RandStream('mlfg6331_64','seed',data.rand_seed);
        s2 = RandStream('mlfg6331_64','seed',0);
        
        if data.cue_sound_length
            bsoundCue = 1;
            y =  [sin((1 : audio_freq*data.cue_sound_length)/audio_freq*2*pi*data.cue_Freq)]*data.cue_sound_volume;
            wavedata = zeros(2,data.cue_sound_length*audio_freq);
            if data.cue_rightSpeaker, wavedata(1,:) =y; end
            if data.cue_leftSpeaker, wavedata(2,:) =y; end
            cueSound = audioplayer(wavedata,audio_freq);
        end
        % Dots speed
        dotSpeedPerFrame = data.Loc(1).dot_speed_px/frameRate;
        if data.presentFoil
            nLoc = 2;
        else data.presentFoil
            nLoc = 1;
        end
        for iloc = 1:nLoc
            % Initiates the dots' centres
            loc(iloc).dotCentrePolar = [rand(s1,1,data.Loc(iloc).dot_number)*2*pi-pi;...
                sqrt(rand(s1,1,data.Loc(iloc).dot_number))*data.Loc(iloc).radius_px];
            
            nDotLimit = round(data.Loc(iloc).dot_number*(1-data.Loc(iloc).dot_coherence)/8);
            sDotLimit = round(data.Loc(iloc).dot_number*(1-data.Loc(iloc).dot_coherence)/4);
            eDotLimit = round(data.Loc(iloc).dot_number*(1-data.Loc(iloc).dot_coherence)*3/8);
            wDotLimit = round(data.Loc(iloc).dot_number*(1-data.Loc(iloc).dot_coherence)/2);
            neDotLimit = round(data.Loc(iloc).dot_number*(1-data.Loc(iloc).dot_coherence)*5/8);
            seDotLimit = round(data.Loc(iloc).dot_number*(1-data.Loc(iloc).dot_coherence)*3/4);
            swDotLimit = round(data.Loc(iloc).dot_number*(1-data.Loc(iloc).dot_coherence)*7/8);
            nwDotLimit = round(data.Loc(iloc).dot_number*(1-data.Loc(iloc).dot_coherence));
            
            loc(iloc).dotDirection = zeros(2,data.Loc(iloc).dot_number);
            
            % Change the way direction and orientation is assessed
            % Just two orientations and rotate the whole frame by a specific
            % angle
            loc(iloc).dotDirection(:,1:nDotLimit) = repmat([0; -1]*dotSpeedPerFrame,1,nDotLimit);
            loc(iloc).dotDirection(:,nDotLimit+1:sDotLimit) = repmat([0; 1]*dotSpeedPerFrame,1,sDotLimit-nDotLimit);
            loc(iloc).dotDirection(:,sDotLimit+1:eDotLimit) = repmat([1; 0]*dotSpeedPerFrame,1,eDotLimit -sDotLimit);
            loc(iloc).dotDirection(:,eDotLimit+1:wDotLimit) = repmat([-1; 0]*dotSpeedPerFrame,1,wDotLimit-eDotLimit);
            loc(iloc).dotDirection(:,wDotLimit+1:neDotLimit) = repmat([sqrt(2)/2; -sqrt(2)/2]*dotSpeedPerFrame,1,neDotLimit-wDotLimit);
            loc(iloc).dotDirection(:,neDotLimit+1:seDotLimit) = repmat([sqrt(2)/2; sqrt(2)/2]*dotSpeedPerFrame,1,seDotLimit-neDotLimit);
            loc(iloc).dotDirection(:,seDotLimit+1:swDotLimit) = repmat([-sqrt(2)/2; sqrt(2)/2]*dotSpeedPerFrame,1,swDotLimit-seDotLimit);
            loc(iloc).dotDirection(:,swDotLimit+1:nwDotLimit) = repmat([-sqrt(2)/2; -sqrt(2)/2]*dotSpeedPerFrame,1,nwDotLimit-swDotLimit);
            
            if data.Loc(iloc).dot_coherence>0
                coherentDirection = [sin(data.Loc(iloc).stim_dir*pi/180); -cos(data.Loc(iloc).stim_dir*pi/180)];
                
                loc(iloc).dotDirection(:,nwDotLimit+1:end) =  repmat(coherentDirection*dotSpeedPerFrame,1,data.Loc(iloc).dot_number-nwDotLimit);
            end
        end
        disp('stimulus prepared');
        
        
    end

    function PresentCue()
        cueTime = GetSecs();
        if data.cue_sound_length >0
            play(cueSound)
        end
        if (data.cue_length > 0.001)
            Screen('FillRect',w, uint8(data.background_level),rect);
            
            % RING cue
            rad = data.Loc(1).radius_px*1.1;
            x0 = data.cuePos(1)-rad;
            y0 = data.cuePos(2)-rad;
            Screen('FillOval',w,255,[x0,y0,x0+2*rad,y0+2*rad]);
            rad = data.Loc(1).radius_px;
            x0 = data.cuePos(1)-rad;
            y0 = data.cuePos(2)-rad;
            Screen('FillOval',w,uint8(data.background_level),[x0,y0,x0+2*rad,y0+2*rad]);
           
            % Center dot cue
            rad = data.cue_radiuspx;
            x0 = data.cuePos(1)-rad;
            y0 = data.cuePos(2)-rad;
            Screen('FillOval',w,255,[x0,y0,x0+2*rad,y0+2*rad]);
            vblcue(1) = Screen('Flip', w);
            
            % % End Cue
            Screen('FillRect',w, uint8(data.background_level),rect);
            vblcue(2) = Screen('Flip', w, cueTime+data.cue_length);
        end
        WaitSecs(data.preStimulusDelay);
    end
    function PresentStimulus()
        
        nFramesStim = round(data.stim_length*frameRate);
        nFrames = round((data.resp_delay+data.resp_window+data.after_lick+0.3)*frameRate);
        
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        
        % Maybe include permutation of dotDirection so that the
        % order of position reset is randomized over the different
        % directions
        for iloc = 1:nLoc
            loc(iloc).dotRem = rem(1:data.Loc(iloc).dot_number,data.Loc(iloc).dot_lifetime);
        end
        
        Screen('FillRect',w, uint8(data.background_level),rect);
  %%% TEST ME      
        if data.sound_sides
            wavedata = zeros(2,(data.pre_stimulus+data.stim_length)*audio_freq);
            if data.left
                
                y =  [zeros(1, data.pre_stimulus*audio_freq),sin((1:audio_freq*(data.stim_length))/audio_freq*2*pi*(data.left_frequency)*1000)]*(data.sound_sides_volume)/2000;
            else
                y =  [zeros(1, data.pre_stimulus*audio_freq),sin((1:audio_freq*(data.stim_length))/audio_freq*2*pi*(data.right_frequency)*1000)]*(data.sound_sides_volume)/2000;
            end
            if ~bplaysoundfrombothspeakers
                if data.cue_rightSpeaker, wavedata(1,:) =y; end
                if data.cue_leftSpeaker, wavedata(2,:) =y; end
                
            else
                wavedata(1,:) =y;
                wavedata(2,:) =y;
            end
            player = audioplayer(wavedata,audio_freq);

            %             y =  [sin((1 : audio_freq*data.cue_sound_length)/audio_freq*2*pi*data.cue_Freq)]*data.cue_sound_volume;
%             wavedata = zeros(2,data.cue_sound_length*audio_freq);
% 
            play(player);
        end
        
        disp('stimulus started');
        
        for i=1:nFrames
            if afterLick
                afterLick = 0;
                if not(wrong)
                    disp('correct lick')
                    if data.trial_sounds
                        player = audioplayer(sin((1:audio_freq*(data.reward_sound_length))/audio_freq*2*pi*1000)*(data.sound_volume)/1000,audio_freq);
                        play(player);
                    end
                else
                    disp('error lick')
                    if data.trial_sounds
                        player = audioplayer((rand(s2,audio_freq*(data.error_sound_length),1) - 0.5)*(data.sound_volume)/1000,audio_freq);
                        play(player);
                    end
                end
                
                if data.stop_stimulus && ...
                        (not(wrong) || (wrong && not(data.visual_error)))
                    Screen('FillRect',w, uint8(data.inter_stim_level),rect);
                    Screen('Flip', w);
                    Priority(0);
                    disp('stimulus stoped');
                    return;
                elseif  wrong && data.visual_error
                    nFramesError = round(data.error_length*frameRate);
                    for j=1:nFramesError
                        if mod(j,data.error_lifetime)/data.error_lifetime<=0.5
                            Screen('FillRect',w, uint8(data.background_level),rect);
                        else
                            Screen('FillRect',w, uint8(data.Loc(1).stim_level)*0.2,rect);
                        end
                        Screen('Flip', w);
                    end
                    Screen('FillRect',w, uint8(data.inter_stim_level),rect);
                    Screen('Flip', w);
                    Priority(0);
                    disp('error stimulus')
                    return;
                end
            end
            
            if i<nFramesStim
                for iloc = 1:nLoc
                    % Converts dots positions to cartisian coordinates
                    loc(iloc).dotCentre = [cos(loc(iloc).dotCentrePolar(1,:)).*loc(iloc).dotCentrePolar(2,:); sin(loc(iloc).dotCentrePolar(1,:)).*loc(iloc).dotCentrePolar(2,:)];
                    
                    Screen('DrawDots', w, loc(iloc).dotCentre, data.Loc(iloc).dot_size_px, uint8(data.Loc(iloc).stim_level), data.Loc(iloc).centre_px,1);
                    
                    % Moves dots
                    loc(iloc).dotCentre = loc(iloc).dotCentre + loc(iloc).dotDirection;
                    
                    % Converts updated dots positions to polar coordinates
                    loc(iloc).dotCentrePolar = [atan2(loc(iloc).dotCentre(2,:),loc(iloc).dotCentre(1,:)); sqrt(loc(iloc).dotCentre(1,:).^2 + loc(iloc).dotCentre(2,:).^2)];
                    
                    % Redraws the position of dead dots
                    frameRem = rem(i,data.Loc(iloc).dot_lifetime);
                    loc(iloc).dotCentrePolar(:,loc(iloc).dotRem==frameRem) = ...
                        [rand(s1,1,sum(loc(iloc).dotRem==frameRem))*2*pi-pi;...
                        sqrt(rand(s1,1,sum(loc(iloc).dotRem==frameRem)))*data.Loc(iloc).radius_px];
                    
                    % Detects whether a border was reached
                    loc(iloc).dotCentrePolar(1, loc(iloc).dotCentrePolar(2,:) > data.Loc(iloc).radius_px) = loc(iloc).dotCentrePolar(1, loc(iloc).dotCentrePolar(2,:) > data.Loc(iloc).radius_px)+pi;
                end
                Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                Screen('Flip', w);

            elseif i == nFramesStim
                disp('stimulus presented');
                Screen('FillRect',w, uint8(data.inter_stim_level),rect);
                Screen('Flip', w);
            else
                Screen('Flip', w);
            end
            
        end
        Priority(0);
    end

    function LickDetected()
        disp('lick');
        lickTime = tic;
    end

    function TimerOut()
        elapsedTime = toc(lickTime);
        
        if elapsedTime < 0.15
            wrong = 0;
        else
            wrong = 1;
        end
        
        if data.after_lick==0
            afterLick = 1;
        end
    end

    function AfterLick()
        afterLick = 1;
    end

end