function StimulusPresentation_Spatial_EarlyLick_delays_change(bugMe)
% %
% % For interface with VisualSpatialDetection.m (Bcontrol Protocol)
% % BA 022015 modified from Tiago Marques's Random Dots code
%
% %  WARNING BA timing of this script may not be reliable
% % Specifically we do not know how much jitter there is in the stimulus
% presentation relative to the event times that Bcontrol ASSUMES.
% So the animal could be responding to the visual stimulus, but the state
% that we have in bcontrol (say for a change in the visual stimulus) may
% not be happening exactly when the visual stimulus occurs.
% This should be tested eventually. Especially for physiology
%% Imports
import Devices.NI.DAQmx.*
r = visRigDefs;
%% Initiations and instatiations of persistent variables
counter=0;
counterName = 'init';
audio_freq = 44000;
bpunish = 0;
bearlypunish = 0;
boutCome = 0;
changeNOW = 0;
bstopStimulus = 0;
% ev.time = [];ev.thiscounter = [];ev.counterName= [];
global hCtr;
persistent  data
persistent w rect frameRate
persistent stimulus iLocChange bCue
persistent elapsedTime lastTrigger cueTime
persistent rewardSound noiseSound cueSound earlynoiseSound
persistent s1 s2

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
screenNumber = 2; % r.visualScreen; % Stimulus screen
if isempty(w)
    [w, rect]  = Screen('OpenWindow', screenNumber, 0,[], 8, 2);
    Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
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
        %         disp('Trigger received')
        %         ev.time(end+1) = now;
        %         ev.thiscounter(end+1) = counter;
        %         ev.counterName(end+1) = counterName;
        %
        try
            switch counter
                case 0
                    bpunish = 0;
                    counter = 1;
                    counterName = 'Prepare Stimulus';
                    PrepareStimulusAndCue();
                    stop(hCtr);
                    start(hCtr);
                    
                case 1
                    counter = 2;
                    counterName = 'Present Cue and Stim';
                    cueTime = GetSecs();
                    stop(hCtr);
                    start(hCtr);
                    PresentStimulusAndCue();
                    counter=0; % if you finished get ready to restart
                    
                case 2  % pre stimulus change
                    lastTrigger = tic;
                    counterName = 'Trigger'
                    stop(hCtr);
                    start(hCtr);
                    counter = 3;
                    
                case 3
                    counterName = '3Trigger2'
                    TriggerDetected1();  % counter updated inside this function
                    stop(hCtr);
                    start(hCtr);
                case 4
                    counterName = '4Trigger'
                    lastTrigger = tic;
                    stop(hCtr);
                    start(hCtr);
                    counter = 5;
                    
                case 5
                    counterName = '5Trigger2'
                    TriggerDetected();
                    stop(hCtr);

                    % start is delayed until after stimulus is stopped and error/correct sound is played 
                                 % or 0.1 sec is passed, to insure that
                                 % near sync triggers from bcontrol are
                                 % ignored (e.g. a lick right before the
                                 % stimulus_stop timer stops the stimulus ,
                                 % both with try and stop the stimulus but
                                 % one will be interperteed as a prep
                                 % stimulus and fuck shit up
                    counter=0; % if you finished get ready to restart
                    
                    
                    
            end
        catch me
            getReport(me)
        end
        
        
    end

    function PrepareStimulusAndCue()
        s = load(fullfile(r.DIR.ratter,'next_trial'));
        data = s.param; clear s
        
        s1 = RandStream('mlfg6331_64','seed',data.rand_seed);
        s2 = RandStream('mlfg6331_64','seed',0);
                            data.visual_error 
        % % Prepare Cue Audio
        if data.cue_length~= 0
            bCue = 1;
            y =  [sin((1 : audio_freq*data.cue_length)/audio_freq*2*pi*data.cue_frequency)]*data.sound_volume;
            wavedata = zeros(2,data.cue_length*audio_freq);
            if data.cue_rightSpeaker, wavedata(2,:) =y; end
            if data.cue_leftSpeaker, wavedata(1,:) =y; end
            cueSound = audioplayer(wavedata,audio_freq);
        else
            bCue = 0;
        end
        % % Perpare other sounds
        
        rewardSound = audioplayer(sin((1:audio_freq*(data.reward_sound_length))/audio_freq*2*pi*1000)*(data.sound_volume),audio_freq);
        
        noiseSound = audioplayer((rand(s2,audio_freq*(data.error_sound_length),1) - 0.5)*(data.error_sound_volume),audio_freq);
        early_noise_length = 0.1;
        earlynoiseSound = audioplayer((rand(s2,audio_freq*(early_noise_length),1) - 0.5)*(data.error_sound_volume/10),audio_freq);
        
        % % Stimulus
        % % Prepare Dots
        for iLoc = 1:3 % NOTE iLoc 1 is always the valid location, iLoc 3 is the changed stimulus
            % Dots speed
            dotSpeedPerFrame = data.stimulus(iLoc).dot_speed_px/frameRate;
            stimulus(iLoc).lumlevel = data.stimulus(iLoc).lumlevel;
            
            % Initiates the dots' centres
            stimulus(iLoc).dotCentrePolar = [rand(s1,1,data.stimulus(iLoc).dot_number)*2*pi-pi;...
                sqrt(rand(s1,1,data.stimulus(iLoc).dot_number))*data.stimulus(iLoc).radius_px];
            
            nDotLimit = round(data.stimulus(iLoc).dot_number*(1-data.stimulus(iLoc).dot_coherence)/8);
            sDotLimit = round(data.stimulus(iLoc).dot_number*(1-data.stimulus(iLoc).dot_coherence)/4);
            eDotLimit = round(data.stimulus(iLoc).dot_number*(1-data.stimulus(iLoc).dot_coherence)*3/8);
            wDotLimit = round(data.stimulus(iLoc).dot_number*(1-data.stimulus(iLoc).dot_coherence)/2);
            neDotLimit = round(data.stimulus(iLoc).dot_number*(1-data.stimulus(iLoc).dot_coherence)*5/8);
            seDotLimit = round(data.stimulus(iLoc).dot_number*(1-data.stimulus(iLoc).dot_coherence)*3/4);
            swDotLimit = round(data.stimulus(iLoc).dot_number*(1-data.stimulus(iLoc).dot_coherence)*7/8);
            nwDotLimit = round(data.stimulus(iLoc).dot_number*(1-data.stimulus(iLoc).dot_coherence));
            
            stimulus(iLoc).dotDirection = zeros(2,data.stimulus(iLoc).dot_number);
            
            % Change the way direction and orientation is assessed
            % Just two orientations and rotate the whole frame by a specific
            % angle
            stimulus(iLoc).dotDirection(:,1:nDotLimit) = repmat([0; -1]*dotSpeedPerFrame,1,nDotLimit);
            stimulus(iLoc).dotDirection(:,nDotLimit+1:sDotLimit) = repmat([0; 1]*dotSpeedPerFrame,1,sDotLimit-nDotLimit);
            stimulus(iLoc).dotDirection(:,sDotLimit+1:eDotLimit) = repmat([1; 0]*dotSpeedPerFrame,1,eDotLimit -sDotLimit);
            stimulus(iLoc).dotDirection(:,eDotLimit+1:wDotLimit) = repmat([-1; 0]*dotSpeedPerFrame,1,wDotLimit-eDotLimit);
            stimulus(iLoc).dotDirection(:,wDotLimit+1:neDotLimit) = repmat([sqrt(2)/2; -sqrt(2)/2]*dotSpeedPerFrame,1,neDotLimit-wDotLimit);
            stimulus(iLoc).dotDirection(:,neDotLimit+1:seDotLimit) = repmat([sqrt(2)/2; sqrt(2)/2]*dotSpeedPerFrame,1,seDotLimit-neDotLimit);
            stimulus(iLoc).dotDirection(:,seDotLimit+1:swDotLimit) = repmat([-sqrt(2)/2; sqrt(2)/2]*dotSpeedPerFrame,1,swDotLimit-seDotLimit);
            stimulus(iLoc).dotDirection(:,swDotLimit+1:nwDotLimit) = repmat([-sqrt(2)/2; -sqrt(2)/2]*dotSpeedPerFrame,1,nwDotLimit-swDotLimit);
            
            if data.stimulus(iLoc).dot_coherence>0
                coherentDirection = [sin(data.stimulus(iLoc).stim_dir*pi/180); -cos(data.stimulus(iLoc).stim_dir*pi/180)];
                
                stimulus(iLoc).dotDirection(:,nwDotLimit+1:end) =  repmat(coherentDirection*dotSpeedPerFrame,1,data.stimulus(iLoc).dot_number-nwDotLimit);
            end
            % Maybe include permutation of dotDirection so that the
            % order of position reset is randomized over the different
            % directions
            stimulus(iLoc).dotRem = rem(1:data.stimulus(iLoc).dot_number,data.stimulus(iLoc).dot_lifetime);
            
        end
        
        % Which Stimulus Location is changing
        data.validTrial
        if data.validTrial
            iLocChange = 1;
        else
            iLocChange = 2;
        end
        
        
        % % Prepare whitenoise for Invalide trial  % TO DO data.sound_invalid_volume
        disp('stimulus prepared');
        
        
    end


    function PresentStimulusAndCue()
        
         bstartStim = 0; bstopStimulus = 0; berrorplayed=0;
        priorityLevel=MaxPriority(w);
        Priority(priorityLevel);
        
        % % Present Cue
        if bCue
            Screen('FillRect',w, uint8(data.background_level),rect);
            rad = data.stimulus(1).radius_px;
            x0 = data.cue_centre_px(1)-rad;
            y0 = data.cue_centre_px(2)-rad;
            Screen('FillOval',w,255,[x0,y0,x0+2*rad,y0+2*rad]);
            play(cueSound);
            vblcue(1) = Screen('Flip', w);
            
            % % End Cue
            Screen('FillRect',w, uint8(data.background_level),rect);
            vblcue(2) = Screen('Flip', w, cueTime+data.cue_length);
           bstartStim = 0;
            
            actualCue_length = diff(vblcue);
            fprintf('Cue presented\t\t%1.0fms\tActual Cue Length %1.3f vs %1.3f\n', (actualCue_length-data.cue_length)*1000,actualCue_length, data.cue_length)
            vbl = vblcue(2);
        else
            Screen('FillRect',w, uint8(data.background_level),rect);
            vbl = Screen('Flip', w);
        end
        % Stimulus Time has NOT finished yet
        
        endStimulusTime = cueTime +...
            data.cue_length +...
            data.stim_delay +...
            data.stim_length;
        stimulusOnsetTime = (cueTime +...
            data.cue_length +...
            data.stim_delay );
        extraTime=0.3; % this exists because a response at the very end of the stimulus window, can result in boutCome after the stimulus period
        % but outcomes Visual stimuli and sound should still occur
        while ~bstopStimulus
            try
                
                % Trigger has happen While Prese_length)ntStimulus is happening
                % There will be correct or error events
                if boutCome
                    disp('outcome');
                    boutCome = 0; % reset outcome
                    
                    if bearlypunish
                        bearlypunish = 0;                        
                        if data.punishEarlyLickNoise
                            disp('play early noise');
                            play(earlynoiseSound);
                        end
                    else
                        if ~bpunish % reward sound
                            disp('correct lick');
                            if data.trial_sounds
                                play(rewardSound);
                            end
                            bstopStimulus = 1; % always stop stimulus after an outcome
                            Screen('FillRect',w, uint8(data.inter_stim_level),rect);
                            Screen('Flip', w);
                            %                         Priority(0);
                            %                         disp('stimulus stopped');
                            %                         return;
                        elseif ~berrorplayed % error sound  % NOTE BA stimulus ends on errors trials this mighte be rewarding??
                            disp('error lick');
                            if data.trial_sounds
                                play(noiseSound);
                            end
                            bstopStimulus = 1; % always stop stimulus after an outcome
                            berrorplayed = 1;
                            Screen('FillRect',w, uint8(data.inter_stim_level),rect);
                            Screen('Flip', w);
                            if  bpunish && data.visual_error    % flicker screen
                                bstopStimulus = 1; % always stop stimulus after an outcome
                                Screen('FillRect',w, uint8(data.inter_stim_level),rect);
                                Screen('Flip', w);
                                disp('stimulus stopped');
                                
                                nFramesError = round(data.error_length*frameRate);
                                for j=1:nFramesError
                                    if mod(j,data.error_lifetime)/data.error_lifetime<=0.5
                                        Screen('FillRect',w, uint8(data.background_level),rect);
                                    else
                                        Screen('FillRect',w, uint8(data.stimulus(1).lumlevel)*0.2,rect);
                                    end
                                    Screen('Flip', w);
                                end
                                Screen('FillRect',w, uint8(data.inter_stim_level),rect);
                                Screen('Flip', w);
                                %                             Priority(0);
                                disp('error stimulus')
                                %                             return;
                            else
                                %                             return
                                %                             Priority(0);
                                bstopStimulus =1;
                                disp('stimulus stopped');
                            end
                            
                        end
                    end
                    
                   
                    
                end
                
                if ~bstopStimulus   % % Stimulus Onset Time
                    
                    if ~bstartStim;               startStimTime = GetSecs();      bstartStim = 1;      end
                    % Converts dots positions to cartisian coordinates
                    for iLoc = 1:2
                        stimulus(iLoc).dotCentre = [cos(stimulus(iLoc).dotCentrePolar(1,:)).*stimulus(iLoc).dotCentrePolar(2,:); sin(stimulus(iLoc).dotCentrePolar(1,:)).*stimulus(iLoc).dotCentrePolar(2,:)];
                        Screen('DrawDots', w, stimulus(iLoc).dotCentre, data.stimulus(iLoc).dot_size_px, uint8(stimulus(iLoc).lumlevel), data.stimulus(iLoc).centre_px,1);
                    end
                    Screen('DrawingFinished', w); % Tell PTB that no further drawing commands will follow before Screen('Flip')
                    vbl(end+1) = Screen('Flip', w,  vbl(end)+0.5*1/frameRate);
                    
                    % % ChangeStimulus time
                    if changeNOW 
                        changeNOW = 0;
                        stimulus(iLocChange).dotDirection =  stimulus(3).dotDirection;
                        stimulus(iLocChange).lumlevel = stimulus(3).lumlevel;

                    end % OPTIONALLY ADD INVALID SOUND HERE
                    
                    for iLoc = 1:2
                        
                        % Moves dots
                        stimulus(iLoc).dotCentre = stimulus(iLoc).dotCentre + stimulus(iLoc).dotDirection;
                        
                        % Converts updated dots positions to polar coordinates
                        stimulus(iLoc).dotCentrePolar = [atan2(stimulus(iLoc).dotCentre(2,:),stimulus(iLoc).dotCentre(1,:)); sqrt(stimulus(iLoc).dotCentre(1,:).^2 + stimulus(iLoc).dotCentre(2,:).^2)];
                        
                        % Redraws the position of dead dots
                        i = round(startStimTime-GetSecs()/frameRate);
                        frameRem = rem(i,data.stimulus(iLoc).dot_lifetime);
                        stimulus(iLoc).dotCentrePolar(:, stimulus(iLoc).dotRem==frameRem) = ...
                            [rand(s1,1,sum( stimulus(iLoc).dotRem==frameRem))*2*pi-pi;...
                            sqrt(rand(s1,1,sum( stimulus(iLoc).dotRem==frameRem)))*data.stimulus(iLoc).radius_px];
                        
                        % Detects whether a border was reached
                        stimulus(iLoc).dotCentrePolar(1, stimulus(iLoc).dotCentrePolar(2,:) > data.stimulus(iLoc).radius_px*1.2) = stimulus(iLoc).dotCentrePolar(1, stimulus(iLoc).dotCentrePolar(2,:) > data.stimulus(iLoc).radius_px*1.2)+pi;
                    end
                    
                end
            catch me
                getReport(me)
            end
        end
        fprintf('STIMULUS presented')
       
        Screen('FillRect',w, uint8(data.inter_stim_level),rect);
        Screen('Flip', w);
        
        Priority(0);
        
        % see counter 5 for explaination of this dead period
        if hCtr.isTaskDone
            WaitSecs(0.2);
            start(hCtr);
        end
    end

    function TriggerDetected1()
        elapsedTime = toc(lastTrigger);
        
        if elapsedTime < 0.1
            changeNOW = 1;
            counter = 4;
            disp(['change detected '   num2str(elapsedTime,'%1.2f')])
        elseif elapsedTime > 0.075 && elapsedTime < 0.15
            bearlypunish = 1;
            bpunish = 0;
            boutCome = 1;
            counter = 2;
            disp(['early punish '   num2str(elapsedTime,'%1.2f')])
            
        elseif elapsedTime > 0.175  % end stimulus if after change
            bpunish = 0;
            bstopStimulus = 1;
            counter = 0;
            disp(['END detected '   num2str(elapsedTime,'%1.2f')])
        end
    end
    function TriggerDetected()
        elapsedTime = toc(lastTrigger);
         bearlypunish = 0;
        if elapsedTime < 0.1
            bpunish = 0;
            boutCome = 1;
            disp(['correct detected '   num2str(elapsedTime,'%1.2f')])
        elseif elapsedTime > 0.1 && elapsedTime < 0.175 % detected TTL in more than 100ms that means punishment
            bpunish = 1;
            boutCome = 1;
            disp(['punish detected '   num2str(elapsedTime,'%1.2f')])
        elseif elapsedTime > 0.195 && elapsedTime < 0.3  % end stimulus if after change
            bpunish = 0;
            bstopStimulus = 1;
            disp(['END detected '   num2str(elapsedTime,'%1.2f')])
        else
            disp(['something else '  num2str(elapsedTime,'%1.2f')]);
             bpunish = 0;
            bstopStimulus = 1;
        end
    end


end
