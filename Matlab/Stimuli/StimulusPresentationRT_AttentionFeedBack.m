function StimulusPresentationRT_AttentionFeedBack_test(bugMe)

% Based on v17 just slightly edited to include rigdefs

%% Imports
import Devices.NI.DAQmx.*
r = visRigDefs;
warning('off','all')

%% Initiations and instatiations of persistent variables

bplaysoundfrombothspeakers =1;
if isfield(r.visualScreen,'playsoundfrombothspeakers')
    bplaysoundfrombothspeakers = r.visualScreen.playsoundfrombothspeakers; % otherwise play sound from cued side
end

% CUE feeback parameters
startCoordCue = [1200 540]; % this is replaced by values read from file
bJustReachCueTarget = 0; % OVERWRITTEN by data.
bdrawCueTarget = 1; % set to one  if the target location for the cue (in Feedbacmode (otherwise not used)
minTimeInCueZone = 1; % OVERWRITTEN by data. time in secs that the cue must be within a radius of the final target


% data.bcueRadInc = 1; % Cue radius increase during Stimlus presentation
% data.bfadeInFoil = 1; % fade in the foil

% define Cue size in fraction of final stimulus radius
mxCueRad= 1;
mnCueRad = 0.2; % use this for non changing cue

readIntv = 0.2;
counter=0;
audio_freq = 44000;
wrong = 0;
afterLick = 0;
nLoc = 1;
persistent hCtr data
persistent w rect frameRate  p  width height
persistent loc %%(iloc).dotCentre dotCentrePolar dotDirection
persistent elapsedTime lickTime
persistent player glsl  stimulusplayer
persistent s1 s2 cueSound
persistent serialArduino
persistent mouseRunGain runSizeGain
persistent mouseRunGainStimulus
cueRad =0;
masktex = 0;
lastrad = 0;

if isempty(mouseRunGain)
    mouseRunGain = 4;
end
if isempty(runSizeGain)
    runSizeGain = 5;
end
if isempty(mouseRunGainStimulus)
    mouseRunGainStimulus = 1;
end
close all;


upKey = KbName('up');
downKey = KbName('down');
escKey = KbName('Esc');
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
%  InitializeMatlabOpenGL([], 0, 1);
windowPtrs=Screen('Windows');
if isempty(windowPtrs)
    [w, rect]  = Screen('OpenWindow', screenNumber, 0,[], 8, 2);
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    frameRate=Screen('FrameRate',screenNumber);
    % Create a special texture drawing shader for masked texture drawing:
    glsl = MakeTextureDrawShader(w, 'SeparateAlphaChannel');
    
else
    disp('Existing window found');
    w = windowPtrs(end);
    frameRate=Screen('FrameRate',screenNumber);
    % Create a special texture drawing shader for masked texture drawing:
    glsl = MakeTextureDrawShader(w, 'SeparateAlphaChannel');
    
end


serialArduino = instrfind({'Port'}, {r.visualScreen.ArduinoCOM});
if isempty(serialArduino);
    serialArduino =  serial(r.visualScreen.ArduinoCOM, 'BaudRate', 2400);
    set(serialArduino,'Timeout',0.1);
end
if ~isequal(get(serialArduino,'Status'),'open')
    fopen(serialArduino);
end

%% NIDAQ Configuration
%Create AI Task
deviceName = 'Dev1';
hCtr = Task('myTask');
hCtr.createAIVoltageChan(deviceName,0,'myTriggerAI0');
hCtr.cfgDigEdgeStartTrig('PFI0');
hCtr.cfgSampClkTiming(10000,'DAQmx_Val_FiniteSamps',2);

%    [numSamps,inputData] = callbackStruct8.hAI(1).readAnalogData(callbackStruct8.numSamples, callbackStruct8.numSamples, 'scaled',1);


hCtr.registerDoneEvent(@FrameStartCallback); %Both DAQmx_Val_SampleClock and DAQmx_Val_SampleCompleteEvent yield same results
pause(1); %Give the registration a chance to 'settle' before starting Task. (otherwise, first event is skipped)
hCtr.start();
PrepareStimulus();
display('Initialized')

%% Trigger received
    function FrameStartCallback(~,~)
        try
            %disp('Trigger received')
            if data.cue_running_feedback ==0
                switch counter
                    case 0
                        counter = 1;
                        PrepareStimulus();
                        stop(hCtr);
                        start(hCtr);
                        
                    case 1
                        counter = 3;
                        stop(hCtr);
                        start(hCtr);
                        PresentCue();
                        PresentStimulus();
                        counter=0;
                    case 3
                        counter = 4;
                        LickDetected();
                        stop(hCtr);
                        start(hCtr);
                        
                    case 4
                        counter = 5;
                        TimerOut();
                        stop(hCtr);
                        start(hCtr);
                    case 5
                        AfterLick();
                        stop(hCtr);
                        start(hCtr);
                end
            else
                display('feedback trial')
                switch counter
                    case 0
                        counter = 1;
                        PrepareStimulus();
                        stop(hCtr);
                        start(hCtr);
                        
                    case 1
                        stop(hCtr); % keep it off because it seems to mess up serial communication
                        counter = 2;
                        PresentFeedbackCue();
                        
                    case 2  % during Stimulus Presentation
                        counter = 3;
                        toc
                        disp('Trigger Stimulus')
                        stop(hCtr);
                        start(hCtr);
                        PresentStimulus();
                        counter=0;
                    case 3
                        counter = 4;
                        LickDetected();
                        stop(hCtr);
                        start(hCtr);
                        
                    case 4
                        counter = 5;
                        TimerOut();
                        stop(hCtr);
                        start(hCtr);
                    case 5
                        AfterLick();
                        stop(hCtr);
                        start(hCtr);
                end
            end
        catch me
            getReport(me)
            fclose(serialArduino);
        end
        
    end
    function PrepareStimulus()
        data = load(fullfile(r.DIR.temp,'next_trial_2afc_attention'));
        %         data.stim_type = 'Random Dot';  % % BA replace
        %         data.mvmt_type = 'drift';
        s2 = RandStream('mt19937ar','seed',0); % for audio
        PrepareStimulusSound();
        [width, height]=Screen('WindowSize', w);
        if data.presentFoil
            nLoc = 2;
        else data.presentFoil
            nLoc = 1;
        end
        switch data.stim_type
            case 'RD'; % 'Random Dot'
                PrepareRandomDot();
                %                 RunStimulus = @RunRandomDot;
            otherwise
                PrepareGrating();
                %                 RunStimulus = @RunGrating;
        end
    end

    function PrepareRandomDot()
        afterLick = 0;
        
        s1 = RandStream('mt19937ar','seed',data.rand_seed);
        
        % Dots speed
        dotSpeedPerFrame = data.Loc(1).dot_speed_px/frameRate;
        
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
        stimulusplayer = audioplayer(wavedata,audio_freq);
        
    end

    function PrepareGrating()
        
        % BA currently both Foil and Target have all the same properties
        % except stim_dir
        
        % Calculate parameters of the grating:
        p=ceil(1/data.grat_spat_freq); % pixels/cycle, rounded up.
        fr = data.grat_spat_freq*2*pi;
        
        for iloc = 1:nLoc
            % Create one single static grating image:
            x = meshgrid(-data.Loc(iloc).radius_px:data.Loc(iloc).radius_px + p, -data.Loc(iloc).radius_px:data.Loc(iloc).radius_px);
            
            inc = data.Loc(iloc).stim_level - data.background_level;
            
            data.grat_type = 'square';
            switch data.grat_type
                case 'sin'
                    grating = uint8(data.background_level) + uint8(inc*cos(fr*x));
                case 'square'
                    grating = uint8(data.background_level) + uint8(inc*cos(fr*x));
            end
            
            % Create circular aperture for the alpha-channel:
            [x,y]=meshgrid(-data.Loc(iloc).radius_px:data.Loc(iloc).radius_px, -data.Loc(iloc).radius_px:data.Loc(iloc).radius_px);
            circle = uint8(data.Loc(iloc).stim_level * (x.^2 + y.^2 <= (data.Loc(iloc).radius_px)^2));
            
            % Set 2nd channel (the alpha channel) of 'grating' to the aperture
            % defined in 'circle':
            grating(:,:,2) = 0;
            grating(1:2*data.Loc(iloc).radius_px+1, 1:2*data.Loc(iloc).radius_px+1, 2) = circle;
            
            % Store alpha-masked grating in texture and attach the special 'glsl'
            % texture shader to it:
            loc(iloc).gratingtex = Screen('MakeTexture', w, grating , [], [], [], [], glsl);
            
            % Query duration of monitor refresh interval:
            ifi=Screen('GetFlipInterval', w);
            
            waitframes = 1;
            waitduration = waitframes * ifi;
            
            % Recompute p, this time without the ceil() operation from above.
            % Otherwise we will get wrong drift speed due to rounding!
            loc(iloc).p = 1/data.grat_spat_freq; % pixels/cycle
            
            % Translate requested speed of the gratings (in cycles per second) into
            % a shift value in "pixels per frame", assuming given waitduration:
            loc(iloc).shiftperframe = data.grat_temp_freq * loc(iloc).p * waitduration;
            
            %for flicker stimuli, calculate # of frames to wait before next
            %flip
            loc(iloc).framesperflip = round(1/(ifi * data.grat_temp_freq));
        end
        disp('stimulus prepared');
        if strcmp(data.mvmt_type,'flicker')
            disp(['Actual flicker frequency = ' num2str(1/ifi/loc(iloc).framesperflip)])
        end
    end
    function PrepareStimulusSound()
        if data.cue_sound_length
            bsoundCue = 1;
            switch data.cue_with_noise
                case  1 % use noise Cue so interpret cue_Freq > 10kHz as blue noise (high pass white noise at 10000)
                    %                                                     cue_Freq < 10kHz as brown noise (low pass white noise at 10000)
                    y = rand(audio_freq*data.cue_sound_length,1);
                    if data.cue_Freq > 10000
                        y = filtdata(y,audio_freq,10000,'high');
                    else
                        y = filtdata(y,audio_freq,10000,'low');
                    end
                    wavedata = zeros(2,data.cue_sound_length*audio_freq);
                    y = y/80*data.cue_sound_volume;
                    wavedata(1,:) =y;
                    wavedata(2,:) =y;
                    cueSound = audioplayer(wavedata,audio_freq);
                otherwise
                    
                    if 1  % use chirp
                        t =1/audio_freq:1/audio_freq:data.cue_sound_length;
                        if data.cue_Freq > 10000
                            % down sweep (similar but not identical to
                            % halassa paer
                            y=chirp(t,12000,data.cue_sound_length,6000,'q',[],'convex');
                        else
                            y=chirp(t,4000,data.cue_sound_length,8000,'q',[],'convex');
                        end
                        
                        if ~bplaysoundfrombothspeakers
                            y = y/80;
                            if data.cue_rightSpeaker, wavedata(1,:) =y; end
                            if data.cue_leftSpeaker, wavedata(2,:) =y; end
                            
                        else
                            y = y/80;
                            wavedata(1,:) =y;
                            wavedata(2,:) =y;
                        end
                        cueSound = audioplayer(wavedata,audio_freq);
                    else % use just tone
                        y =  [sin((1 : audio_freq*data.cue_sound_length)/audio_freq*2*pi*data.cue_Freq)]*data.cue_sound_volume;
                        wavedata = zeros(2,data.cue_sound_length*audio_freq);
                        if data.cue_rightSpeaker, wavedata(1,:) =y; end
                        if data.cue_leftSpeaker, wavedata(2,:) =y; end
                        cueSound = audioplayer(wavedata,audio_freq);
                    end
            end
            
        end
    end
    function PresentFeedbackCue()
        flushinput(serialArduino);
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        bJustReachCueTarget = data.cue_feedback_limit;
        minTimeInCueZone = data.targ_CueTime;
        
        cueTime = GetSecs();
        vblcue = cueTime-1/frameRate;
        if isfield(data,'cue_start_pos'),           startCoordCue = data.cue_start_pos;       end
        if data.cue_sound_length >0
            play(cueSound)
            tCueStart = GetSecs();
        end
        lastmouseSpeed = 0;
        display('Cue Feedback Loop');
        
        Screen('FillRect',w, uint8(data.background_level),rect);
        nFramesCue = 4*frameRate; %round((data.resp_delay+data.resp_window+data.after_lick+0.3)*frameRate);
        
        coordCurrent = startCoordCue;
        cueInPlace = 0; lastrad = 0; lastcoordCurr = 0;
        animationStage = 0;  timeInCueZone = -1;
        while(~cueInPlace)
            if 0
                mouseSpeed = 1;
            else
                %             % To query the device.
                WaitSecs((1/frameRate)/2);
                fprintf(serialArduino, 'r');
                ms = fscanf(serialArduino);
                mouseSpeed = abs(str2num(ms))*-1;
            end
            % only move when mouse moves forward
            if mouseSpeed > 0
                mouseSpeed = 0;
            end
            
            switch  animationStage
                case 0  % move cue
                    
                    % gets smaller
                    %                 rad = data.Loc(1).radius_px* (mnCueRad +  (abs(coordCurrent(1)- data.cuePos(1))/abs(startCoordCue(1)- data.cuePos(1)))^6*mxCueRad*(1-mnCueRad)); % calculate current size of circle
                    % gets bigger
                    %                 rad = data.Loc(1).radius_px* (mnCueRad +  (1 -(abs(coordCurrent(1)- data.cuePos(1))/abs(startCoordCue(1)- data.cuePos(1)))^0.25)*mxCueRad*(1-mnCueRad)); % calculate current size of circle
                    %                 rad = max(rad,mnCueRad*data.Loc(1).radius_px);
                    %                 rad = min(rad,mxCueRad*data.Loc(1).radius_px);
                    
                    % no change
                    rad = data.Loc(1).radius_px*mnCueRad;
                    %                     radCueTarget =  rad*1.1; % this is the radius of the cue at the final target of the cue
                    radCueTarget = rad* data.targ_cueRad_Fac; % this is the radius of the cue at the final target of the cue
                    targetCue_Radius = radCueTarget; % these don't ahve to be equal targetCue_Radius is the radius that the cue is considered to be in the Zone
                    radiusPastCuePos = targetCue_Radius+1; % distance past the Cue target where the Cue wraps to the startCoord again.
                    %                     mouseSpeed = abs(mouseSpeed*-1;
                    % CUE MOVES PAST THE TARGET
                    if (abs(coordCurrent(1) - data.cuePos(1)) < targetCue_Radius)  & timeInCueZone  < 0% is the target going up or down
                        timeInCueZone = GetSecs();
                        % stop sound
                        stop(cueSound)
                        
                        if bJustReachCueTarget
                            if data.bcueRadInc
                                disp('** Cue done')
                                tic
                                cueRad = data.Loc(1).radius_px*mnCueRad;
                                endCueHelper();
                                cueInPlace = 1;
                                break;
                                
                            else
                                animationStage = animationStage +1;
                            end
                            
                        end
                    elseif (abs(coordCurrent(1) - data.cuePos(1)) < targetCue_Radius) &  (GetSecs()-timeInCueZone)>minTimeInCueZone
                        
                        disp('** Cue done')
                        tic
                        endCueHelper();
                        cueInPlace = 1;
                    elseif (abs(coordCurrent(1) - data.cuePos(1)) > targetCue_Radius)
                        % if cue with noise, noise will be on until the
                        % cue is in the target spot
                        if (GetSecs()-tCueStart)>=  data.cue_sound_length & data.cue_sound_length >0 & data.cue_with_noise ...
                                & data.cue_sound_constant
                            play(cueSound)
                            tCueStart = GetSecs();
                        end
                        timeInCueZone = -1;
                        if startCoordCue(1) < data.cuePos(1) % is the target going up or down
                            dirn = -1;
                            if coordCurrent(1) >  (data.cuePos(1)-radiusPastCuePos*dirn) % reset cue position if t goes past the cue target
                                coordCurrent(1) =  startCoordCue(1);
                                if ~data.cue_with_noise
                                    play(cueSound)
                                end
                            end
                        else
                            dirn = 1;
                            if coordCurrent(1)<  (data.cuePos(1)-radiusPastCuePos*dirn) % reset cue position if t goes past the cue target
                                coordCurrent(1) =  startCoordCue(1);
                                if ~data.cue_with_noise
                                    play(cueSound)
                                end
                            end
                        end
                        
                        
                    end
                    
                    if data.random_run_gain>0
                        randomGainFct= data.random_run_gain;
                    else
                        randomGainFct = 1;
                    end
                    if isempty(mouseSpeed), mouseSpeed = lastmouseSpeed;  warning('mousespeed empty'); end % This is a hack .. it shouldn't happen that it is empty not sure why it doesn other than can't communicate with arduino some times.
                    coordCurrent(1) = mouseRunGain*mouseSpeed*dirn*randomGainFct + coordCurrent(1);
                    lastmouseSpeed = mouseSpeed;
                    if bJustReachCueTarget% % if reaching Target Start
                        
                        if startCoordCue(1) < data.cuePos(1)
                            coordCurrent(1) = min(coordCurrent(1), data.cuePos(1));
                            coordCurrent(1) = max(coordCurrent(1),rect(1)); % keep from going off the screen
                        else
                            coordCurrent(1) = max(coordCurrent(1), data.cuePos(1));
                            coordCurrent(1) = min(coordCurrent(1), rect(3)); % keep from going off the screen
                        end
                    end
                case 1 % incrase size of cue
                    
                    radTarget = data.Loc(1).radius_px;
                    
                    rad = radiusGrowHelper(rad,mouseSpeed);
                    % NOTE remove mouseSpeed to make cue grow automatically
                    % (no need for running)
                    
                    if rad>= radTarget
                        animationStage = animationStage +1;
                    end
                    
                    
                otherwise % done
                    disp('** Cue done')
                    tic
                    endCueHelper();
                    cueInPlace = 1;
                    
                    break;
                    
                    
            end
            
            
            Screen('FillRect',w, uint8(data.background_level),rect);
            %             Screen('FillRect',w, 128,rect);
            
            cuetype = 'ring';
            ringthickness = 20;
            if bdrawCueTarget
                
                x0 = data.cuePos(1)-radCueTarget;
                y0 = data.cuePos(2)-radCueTarget;
                Screen('FillOval',w,255,[x0,y0,x0+2*radCueTarget,y0+2*radCueTarget]);
                x0 = data.cuePos(1)- (radCueTarget - ringthickness/2);
                y0 = data.cuePos(2)- (radCueTarget - ringthickness/2);
                Screen('FillOval',w, uint8(data.background_level),[x0,y0,x0+2*(radCueTarget-ringthickness/2),y0+2*(radCueTarget-ringthickness/2)]);
            end
            switch (cuetype)
                case 'dot'% dot only
                    x0 = coordCurrent(1)-rad;
                    y0 = coordCurrent(2)-rad;
                    Screen('FillOval',w,255,[x0,y0,x0+2*rad,y0+2*rad]);
                case 'ring'  % ring
                    
                    x0 = coordCurrent(1)-rad;
                    y0 = coordCurrent(2)-rad;
                    
                    
                    switch (data.stim_type)
                        case 'RD' % 'Random Dot'
                            iloc = 1;
                            loc(iloc).dotCentre = [cos(loc(iloc).dotCentrePolar(1,:)).*loc(iloc).dotCentrePolar(2,:); sin(loc(iloc).dotCentrePolar(1,:)).*loc(iloc).dotCentrePolar(2,:)];
                    end
                    
                    Screen('FillOval',w,100,[x0,y0,x0+2*rad,y0+2*rad]);
                    if lastrad ~= rad || lastcoordCurr ~= coordCurrent(1)
                        lastrad = rad;
                        lastcoordCurr = coordCurrent(1);
                        rin = [rad*0.99,rad*0.99];
                        c = [0 0];
                        if bdrawCueTarget
                            rin(end+1,:) =[radCueTarget radCueTarget];  % this is the radius of the cue at the final target of the cue
                            c = [0 data.cuePos(1)-coordCurrent(1)];
                        end
                        masktex =  helperMakeMask(rin,w,1,uint8(data.background_level),c);
                    end
                    x0 = coordCurrent(1)- (rad - ringthickness);
                    y0 = coordCurrent(2)- (rad - ringthickness);
                    Screen('FillOval',w, uint8(data.background_level),[x0,y0,x0+2*(rad-ringthickness),y0+2*(rad-ringthickness)]);
                    %                    Screen('DrawDots', w, loc(iloc).dotCentre, data.Loc(iloc).dot_size_px, uint8(data.Loc(iloc).stim_level), coordCurrent,1);
                    Screen('DrawTexture', w, masktex, [],CenterRectOnPoint(rect,coordCurrent(1),coordCurrent(2)));
                    
            end
            
            vblcue = Screen('Flip', w,vblcue(end)+(1/frameRate)/2);
            
            [keyIsDown,timeSecs,keyCode] = KbCheck; % user controlled options during cue presentation
            if keyCode(upKey)
                switch (animationStage) % manually adjust gain
                    case 0
                        mouseRunGain = mouseRunGain+1
                    case 1
                        runSizeGain = runSizeGain+1;
                end
                
                WaitSecs(0.050);
            elseif keyCode(downKey)
                switch (animationStage) % manually adjust gain
                    case 0
                        mouseRunGain = max(mouseRunGain-1,0.5)
                    case 1
                        runSizeGain = max(runSizeGain-1,0.5);
                end
                
                WaitSecs(0.050);
            elseif keyCode(escKey)
                WaitSecs(0.050);
                s = fscanf(serialArduino);
                display(['%%%%% Escape code ' s ' %% ']);
                cueInPlace = 1;
                break;
            end
        end
        %         % % End Cue
        
        %
        %         Screen('FillRect',w, uint8(data.background_level),rect);
        %         vblcue(2) = Screen('Flip', w, cueTime+data.cue_length);
        
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
        tic
        WaitSecs(data.preStimulusDelay);
    end
    function endCueHelper()
        stop(cueSound);
        start(hCtr);
        %                     WaitSecs(0.1); % wait for NIDAQ to start
        fprintf(serialArduino, 's');
        s = fscanf(serialArduino);
        if ~ismember(s,'A') % BA testing trying to catch errors
            counter = 2;
        end
        display(['%%%%% ' s ' %% ']);
    end
    function PresentStimulus()
        lastReadtime = GetSecs();
        nFramesStim = round(data.stim_length*frameRate);
        nFrames = round((data.resp_delay+data.resp_window+data.after_lick+0.3)*frameRate);
        
        
        % Maybe include permutation of dotDirection so that the
        % order of position reset is randomized over the different
        % directions
        for iloc = 1:nLoc
            loc(iloc).dotRem = rem(1:data.Loc(iloc).dot_number,data.Loc(iloc).dot_lifetime);
        end
        
        Screen('FillRect',w, uint8(data.background_level),rect);
        
        if data.sound_sides
            
            
            %             y =  [sin((1 : audio_freq*data.cue_sound_length)/audio_freq*2*pi*data.cue_Freq)]*data.cue_sound_volume;
            %             wavedata = zeros(2,data.cue_sound_length*audio_freq);
            %
            play(stimulusplayer);
        end
        
        disp('stimulus started');
        thisStimLevel =[0 0]; % for optionally fading in Foil
        toc
        cueRad  = data.Loc(1).radius_px*mnCueRad; % ba hack this should be necessary
        
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
                    disp('stimulus stopped');
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
            
            lastmouseSpeed =0.1; mouseSpeed =0.1;
            switch (data.stim_type)
                case 'RD'
                    for iloc = 1:nLoc
                        this(iloc).dotDirection= loc(iloc).dotDirection;
                    end
                    
                    
            end
            %             minSpeed  = 0.1*loc(iloc).dotDirection;
            %             maxSpeed  = 10*loc(iloc).dotDirection;
            if i<nFramesStim
                if  0 && (GetSecs - lastReadtime) >readIntv  % for dot speed in close loop but doesn't work data.dotSpeedFeedback
                    fprintf(serialArduino, 'r');
                    ms = fscanf(serialArduino);
                    lastReadtime = GetSecs;
                    if 0
                        mouseSpeed = 1;
                    else
                        mouseSpeed = abs(str2num(ms));
                    end
                    
                    if isempty(mouseSpeed), mouseSpeed = lastmouseSpeed; else
                        lastmouseSpeed = mouseSpeed;
                    end
                    [keyIsDown,timeSecs,keyCode] = KbCheck; % user controlled options during cue presentation
                    if keyCode(upKey)
                        mouseRunGainStimulus = mouseRunGainStimulus+0.2;
                        WaitSecs(0.050);
                    elseif keyCode(downKey)
                        mouseRunGainStimulus = max(mouseRunGainStimulus-0.2,0.2);
                        WaitSecs(0.050);
                    end
                end
                for iloc = 1:nLoc
                    if  data.bfadeInFoil  && iloc ==2
                        thisStimLevel(iloc) = min(thisStimLevel(iloc)+1,data.Loc(iloc).stim_level) ;
                    else
                        thisStimLevel(iloc) = data.Loc(iloc).stim_level;
                    end
                    
                    switch (data.stim_type)
                        case 'RD' % 'Random Dot'
                            % Converts dots positions to cartisian coordinates
                            loc(iloc).dotCentre = [cos(loc(iloc).dotCentrePolar(1,:)).*loc(iloc).dotCentrePolar(2,:); sin(loc(iloc).dotCentrePolar(1,:)).*loc(iloc).dotCentrePolar(2,:)];
                            
                            
                            Screen('DrawDots', w, loc(iloc).dotCentre, data.Loc(iloc).dot_size_px, uint8(thisStimLevel(iloc)), data.Loc(iloc).centre_px,1);
                            
                            loc(iloc).dotCentre = loc(iloc).dotCentre + this(iloc).dotDirection;
                            
                            % Converts updated dots positions to polar coordinates
                            loc(iloc).dotCentrePolar = [atan2(loc(iloc).dotCentre(2,:),loc(iloc).dotCentre(1,:)); sqrt(loc(iloc).dotCentre(1,:).^2 + loc(iloc).dotCentre(2,:).^2)];
                            
                            % Redraws the position of dead dots
                            frameRem = rem(i,data.Loc(iloc).dot_lifetime);
                            loc(iloc).dotCentrePolar(:,loc(iloc).dotRem==frameRem) = ...
                                [rand(s1,1,sum(loc(iloc).dotRem==frameRem))*2*pi-pi;...
                                sqrt(rand(s1,1,sum(loc(iloc).dotRem==frameRem)))*data.Loc(iloc).radius_px];
                            
                            % Detects whether a border was reached
                            loc(iloc).dotCentrePolar(1, loc(iloc).dotCentrePolar(2,:) > data.Loc(iloc).radius_px) = loc(iloc).dotCentrePolar(1, loc(iloc).dotCentrePolar(2,:) > data.Loc(iloc).radius_px)+pi;
                        otherwise
                            
                            visiblesize=2*data.Loc(iloc).radius_px+1;
                            % Definition of the drawn source rectangle on the screen:
                            srcRect=[0, 0, visiblesize, visiblesize];
                            dstRect=[data.Loc(iloc).centre_px(1)-data.Loc(iloc).radius_px, data.Loc(iloc).centre_px(2)-data.Loc(iloc).radius_px,...
                                data.Loc(iloc).centre_px(1)-data.Loc(iloc).radius_px+visiblesize, data.Loc(iloc).centre_px(2)-data.Loc(iloc).radius_px+visiblesize];
                            
                            switch data.mvmt_type
                                case 'drift'
                                    yoffset = mod(i*loc(iloc).shiftperframe,loc(iloc).p);
                                    
                                    % Draw first grating texture, rotated by "angle":
                                    Screen('DrawTexture', w, loc(iloc).gratingtex, srcRect, dstRect, data.Loc(iloc).stim_dir+90, [], [], [], [], [], [0, yoffset, 0, 0]);
                                    
                                case 'flicker'
                                    yoffset = loc(iloc).p*((-1)^ceil(i/loc(iloc).framesperflip))/4;
                                    %                         if i==1 || mod(i-1,framesperflip)==0
                                    % Draw first grating texture, rotated by "angle":
                                    Screen('DrawTexture', w, loc(iloc).gratingtex, srcRect, dstRect, data.Loc(iloc).stim_dir+90, [], [], [], [], [], [0, yoffset, 0, 0]);
                            end
                            
                    end
                    % increase stimulus size during presentation for the
                    % cueRadius to the final radius
                    if data.bcueRadInc
                        if iloc ==1
                            radTarget = data.Loc(1).radius_px;
                            if cueRad < radTarget
                                cueRad = radiusGrowHelper(cueRad);
                            else
                                radTarget = cueRad;
                            end
                            
                            if lastrad ~= cueRad
                                lastrad = cueRad;
                                masktex =  helperMakeMask([cueRad*0.99,cueRad*0.99],w,1,uint8(data.background_level));
                            end
                            
                            if radTarget~= cueRad
                                Screen('DrawTexture', w, masktex, [],CenterRectOnPoint(rect, data.cuePos(1), data.cuePos(2)));
                            end
                            
                        end
                    end
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
        Screen('FillRect',w, uint8(data.inter_stim_level),rect);
        Screen('Flip', w);
        Priority(0);
        moglClutBlit()
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


    function rad = radiusGrowHelper(rad,mouseSpeed)
        if nargin >1
            rad = rad + runSizeGain * abs(mouseSpeed); % calculate current size of circle
            rad = max(rad,mnCueRad*data.Loc(1).radius_px);
            rad = min(rad,mxCueRad*data.Loc(1).radius_px);
        else % grow at constant rate no matter if running or not
            rad = rad + runSizeGain * 20; % calculate current size of circle
            rad = max(rad,mnCueRad*data.Loc(1).radius_px);
            rad = min(rad,mxCueRad*data.Loc(1).radius_px);
        end
    end
    function masktex =  helperMakeMask(r,window,masktype,backgroundlevel,c)
        %         c is the the distance between the first and second radius
        % BA
        
        width = width*1;% height a width multipled by 2.1 to make mask can be moved anywhere in the
        height = height*1;
        % screen and still mask
        % white = WhiteIndex(window);
        % black = BlackIndex(window);
        % grey = round(0.5*(black+white));
        
        % We create a Luminance+Alpha matrix for use as transparency mask:
        [x,y]=meshgrid([1:width]-width/2,[1:height]-height/2);
        % Layer 1 (Luminance) is filled with luminance value 'gray' of the
        % background.
        maskimg=ones(height,width,2) * double(backgroundlevel);
        % Layer 2 (Transparency aka Alpha) is filled with gaussian transparency
        % mask.
        for ir = 1:min(2,size(r,1))
            rx = r(ir,1);
            ry = r(ir,1);
            if ir ==1
                cindx =  round((height/2-rx):(height/2+rx-1));
                cindy = round((width/2-ry):(width/2+ry-1));
            else
                cindx = round( ((height/2+c(1) )-rx):((height/2+c(1))+rx-1));
                cindy =round( ((width/2+c(2) )-ry):((width/2+ c(2))+ry-1));
            end
            
            switch masktype % note param.nMask should equal to the number of cases
                case 0 % gaussianm
                    maskimg(:,:,2)=255 - exp(-((x/rx).^2)-((y/ry).^2))*255;
                case 1 % eliptical aperature
                    if ir==1                    maskimg(:,:,2) = 255; end
                    maskimg(cindx,cindy,2)= (~makeElipse(rx,ry))'*255;
                case 2 % inverted eliptical aperature
                    if ir==1                    maskimg(:,:,2) = 0; end
                    maskimg(cindx,cindy,2)= (makeElipse(rx,ry))'*255;
                case 3 % no mask
                    maskimg(:,:,2) = 0;
                    %     case 4 % Working on cross grating
                    %         Duration = str2double(get(handles.Duration,'String'));
                    %         FrameHz = round(str2double(get(handles.FrameHz,'String')));
                    %
                    %         cnow = UCparams.c;
                    %
                    %         [frm]= generateGratings_blit(handles.orient(cnow),handles.freq(cnow),handles.TempFreq(cnow),handles.phase(cnow),handles.contrast(cnow),1/FrameHz,  handles.degPerPix,width,height,FrameHz,black,white);
                    %         maskimg(:,:,2) = frm;
                    %         maskimg((height/2-rx):(height/2+rx-1),(width/2-ry):(width/2+ry-1),2)= (~makeElipse(rx,ry))*255;
                    %
            end
        end
        % Build a single transparency mask texture:
        masktex=Screen('MakeTexture', window, maskimg);
        % masktex=Screen('MakeTexture', window, squeeze(frm));
        
        % Screen('DrawTexture', window,masktex)
        % Screen('Flip',window);
    end

end