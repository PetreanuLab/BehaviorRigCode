function  [] =  StateMatrixSection(obj, action)

global toolboxtrig;
global leftvalve;
global aomtrig;
global shuttertrig;
global arduinotrig;
global arduinoreset;
global arduinospeed;
% global scanimagetrig1;
% global scanimagetrig2;

GetSoloFunctionArgs;

switch action
    case 'init',
        
        % BA TO DO BELOW
        SupportFunctions(obj,'set_next_dots');
        SupportFunctions(obj,'set_next_stimulusChange');
        SupportFunctions(obj,'param_save');
        
        StateMatrixSection(obj, 'next_trial');
        
    case 'next_trial',
        %%%%%%%%%%%%%%%%%% Preparation step %%%%%%%%%%%%%%%%%%%%%%%%%
        valveOpen = value(valveTime);
        reward = leftvalve;
        lick= 'Lin';
        
        %% Sets the inter-trial-interval
        if strcmp(value(ITI),'RANDOM')
            ITIValue = rand* (value(ITIMax)-value(ITIMin)) + value(ITIMin);
        else
            ITIValue = value(ITIMax);
        end
        
        pre_response_window_duration = 0.001; % time after the stimlus change when response is still considered invalid (accident)
        validTrial = value(currValidTrial);
        stim_length = value(currStimDuration);
        responseWindow = value(currResponseWindow)-pre_response_window_duration;
        
        earlyLickGracePeriod = value(earlyLickGP);      
        changeStimDelay = value(currChangeStimDelay);
        punishEarlyLicksWindow  =changeStimDelay - earlyLickGracePeriod;
        if punishEarlyLicksWindow <0
            error('changeStimDelay must be longer than earlyLickGracePeriod')
        end
        
        trial_length = stim_length + value(preCue); + value(cueDuration) + value(stimDelay);
        
        %%
        %%%%%%%%%%%%%%%%%% State Machine Configuration %%%%%%%%%%%%%%%%%%%%%%%%%
        % % Sets up the assembler
        sma = StateMachineAssembler('full_trial_structure');
        
        %% Sets up the scheduled waves
        % Psychtoolbox triggers
        sma = add_scheduled_wave(sma,'name','stimulus_trigger',... % 1 present stimulus
            'preamble',0.001,'sustain',0.001,...
            'DOut',toolboxtrig);
        sma = add_scheduled_wave(sma,'name','correct_lick',... % 2 lick detected
            'preamble',0.001,'sustain',0.001,        ...
            'trigger_on_up', 'correct_timer','untrigger_on_down','cue_stimulus_timer +cue_stimulus_EARLY_LICKS_timer','DOut',toolboxtrig); 
        sma = add_scheduled_wave(sma,'name','wrong_lick',... % 2 lick detected
            'preamble',0.001,'sustain',0.001,...
            'trigger_on_up', 'wrong_timer','untrigger_on_down','cue_stimulus_timer +cue_stimulus_EARLY_LICKS_timer','DOut',toolboxtrig); 
        sma = add_scheduled_wave(sma,'name','correct_timer',...
            'preamble',0.050,...% this duration is decoded by the stimulus computer 
            'trigger_on_up', 'pulse');
        sma = add_scheduled_wave(sma,'name','wrong_timer',... % wasd 0.125
            'preamble',0.115,...    % this duration is decoded by the stimulus computer to present Visual Error or not
            'trigger_on_up', 'pulse');
         sma = add_scheduled_wave(sma,'name','change_stim_wave',... % change stimulus
            'preamble',0.001,'sustain',0.001,        ...
            'trigger_on_up', 'change_stim_timer','DOut',toolboxtrig);    
        sma = add_scheduled_wave(sma,'name','change_stim_timer',... % helper to change stimulus (send the 2nd pulse)
            'preamble',0.050,... % this duration is decoded by the stimulus computer 
            'trigger_on_up', 'pulse');
        sma = add_scheduled_wave(sma,'name','stop_stim_wave',...  % stop the visual stim program as change the stim
            'preamble',0.001,'sustain',0.001,'untrigger_on_down','cue_stimulus_timer +cue_stimulus_EARLY_LICKS_timer',...
            'trigger_on_up', 'stop_stim_timer','DOut',toolboxtrig);
        sma = add_scheduled_wave(sma,'name','stop_stim_timer',... % helper to stop the visual stim (send the 2nd pulse)
            'preamble',0.2,... % this duration is decoded by the stimulus computer 
            'trigger_on_up', 'pulse');
        
        sma = add_scheduled_wave(sma,'name','pulse',...  
            'preamble',0.001,'sustain',0.001,....
            'DOut',toolboxtrig);
        
        
        % Stop trial
        
        sma = add_scheduled_wave(sma,'name','cue_stimulus_timer',... % the  length of the visual stimulus without the preCue
            'preamble',trial_length-value(preCue),'sustain',0.001,...
            'trigger_on_up','stop_stim_wave' );
        sma = add_scheduled_wave(sma,'name','cue_stimulus_No_trigger',... % this timer is used to time the length of the stimulus but doesn't trigger visual PC
            'preamble',trial_length-value(preCue),'sustain',0.001);
        sma = add_scheduled_wave(sma,'name','trial_timer',...
            'preamble',trial_length,'sustain',0.001);
        sma = add_scheduled_wave(sma,'name','cue_stimulus_EARLY_LICKS_timer',... % this timer is started after earlylicks delays the trial
            'preamble',trial_length-value(preCue) -(earlyLickGracePeriod + value(cueDuration)+value(stimDelay)),'sustain',0.001,...
            'trigger_on_up','stop_stim_wave' );
        sma = add_scheduled_wave(sma,'name','trial_EARLY_LICKS_timer',... % this timer is started after earlylicks delays the trial
            'preamble',trial_length-(earlyLickGracePeriod + value(cueDuration)+value(stimDelay)),'sustain',0.001);
        % BA %%%%%%%%%%%%% DO THESE schedule wave need to be turned off?
        
        % Reward delivery
        sma = add_scheduled_wave(sma,'name','reward_delivery',...
            'preamble',0.001,'sustain',valveOpen,...
            'DOut',reward);
        % Arduino triggers
        sma = add_scheduled_wave(sma,'name','arduino_trigger',...
            'preamble',0.001,'sustain',0.001,...
            'DOut',arduinotrig);
        sma = add_scheduled_wave(sma,'name','arduino_speed',...
            'preamble',0.005,'sustain',value(speedTreshold)*2/1000,...
            'DOut',arduinospeed);
        sma = add_scheduled_wave(sma,'name','arduino_reset',...
            'preamble',0.001,'sustain',0.001,...
            'DOut',arduinoreset);
        
        %%
        if value(photoStim)
            %% Schedule waves for photostimulation       -    changed by Rodrigo Dias 03July13
            % Variable to allow shutter to be open for the correct time
            % interval
            totalStimTime=0;
            totalStimTime=value(current_time_rel_vis_stim1)+value(currentPulseDuration1)+...
                value(current_time_rel_vis_stim2)+value(currentPulseDuration2)+...
                value(current_time_rel_vis_stim3)+value(currentPulseDuration3)+...
                value(current_time_rel_vis_stim4)+value(currentPulseDuration4);
            
            %SW to open and close the shutter.
            sma = add_scheduled_wave(sma,'name','shutter_pulse',...
                'preamble', value(preCue)+value(current_time_rel_vis_stim1)-0.009,...
                'sustain',totalStimTime-value(current_time_rel_vis_stim1)-0.014,...
                'DOut',shuttertrig);      %channel DIO1 of cable 2
            
            if value(noStim)==0
                %SW to shine the laser on the mouse: turns on  RF to AOM
                sma = add_scheduled_wave(sma,'name','AOM_pulse1', ...
                    'preamble', value(preCue)+value(current_time_rel_vis_stim1),...
                    'sustain',value(currentPulseDuration1),'DOut',aomtrig,...
                    'trigger_on_up','preamble_AOM2');
                
                %Digital SW to serve as preamble to the AOM waves.
                sma = add_scheduled_wave(sma, 'name', 'preamble_AOM2',...
                    'preamble', value(currentPulseDuration1)+value(current_time_rel_vis_stim2)-0.001, ...
                    'trigger_on_up', 'AOM_pulse2');
                sma = add_scheduled_wave(sma,'name','AOM_pulse2', 'preamble', 0.001,...
                    'sustain',value(currentPulseDuration2),'DOut',aomtrig,'trigger_on_up','preamble_AOM3');
                
                sma = add_scheduled_wave(sma, 'name', 'preamble_AOM3',...
                    'preamble', value(currentPulseDuration2)+value(current_time_rel_vis_stim3)-0.001, ...
                    'trigger_on_up', 'AOM_pulse3');
                sma = add_scheduled_wave(sma,'name','AOM_pulse3', 'preamble', 0.001,...
                    'sustain',value(currentPulseDuration3),'DOut',aomtrig,'trigger_on_up','preamble_AOM4');
                
                sma = add_scheduled_wave(sma, 'name', 'preamble_AOM4',...
                    'preamble', value(currentPulseDuration3)+value(current_time_rel_vis_stim4)-0.001, ...
                    'trigger_on_up', 'AOM_pulse4');
                sma = add_scheduled_wave(sma,'name','AOM_pulse4', 'preamble', 0.001,...
                    'sustain',value(currentPulseDuration4),'DOut',aomtrig);
                
                
                %Digital SW to serve as preamble to the analog waves.
                sma = add_scheduled_wave(sma, 'name', 'preamble_wave',...
                    'preamble', value(preCue)+value(current_time_rel_vis_stim1)-0.001, ...
                    'trigger_on_up', 'sw_chn1+sw_chn2');
                
                axisSwitch1=[1 2]; %vectors responsible for switching axis - change
                axisSwitch2=[2 1];              %channel to which each AO signal is sent
                
                %Analog Scheduled Waves - rotate the mirrors!
                sma = add_scheduled_wave(sma, 'name', 'sw_chn1', 'is_ao', 1, 'AOut', axisSwitch1(value(switch_xy)+1),...
                    'two_by_n_matrix', value(AOMatrix1));
                sma = add_scheduled_wave(sma, 'name', 'sw_chn2', 'is_ao', 1, 'AOut', axisSwitch2(value(switch_xy)+1),...
                    'two_by_n_matrix', value(AOMatrix2));
            end
        end
        
        %% Sets up the states-machine
        % Default state
        % If first trial, resets Arduino and loads stimulus
        if(n_done_trials==0)
            sma = add_state(sma, 'default_statechange', 'set_session', 'self_timer', 0.001);
            sma = add_state(sma, 'name', 'set_session','self_timer',0.100,...
                'output_actions', {'SchedWaveTrig','arduino_reset+stimulus_trigger'},...
                'input_to_statechange', {'Tup','set_trial'});
            % Otherwise does nothing
        else
            sma = add_state(sma, 'default_statechange', 'set_trial', 'self_timer', 0.001);
        end
        
        % If animal has to run to get stimulus
        if value(treadmillStim)
            % Set trial state
            % Tells arduino a new trial has started and sends the threshold speed
            sma = add_state(sma, 'name', 'set_trial','self_timer',0.001,...
                'output_actions', {'SchedWaveTrig','arduino_trigger+arduino_speed'},...
                'input_to_statechange', {'Tup','waiting_for_run'});
            % Waiting for run state
            % Waits until animal starts running
            sma = add_state(sma, 'name', 'waiting_for_run',...
                'input_to_statechange', {'Sin','running'});
            % Running state
            % Counts the time while the animal is running. If the animal
            % runs long enough, presents stimulus, otherwise returns to
            % waiting for run state
            sma = add_state(sma, 'name', 'running','self_timer',value(runLength),...
                'input_to_statechange', {'Tup','pre_cue','Sout','waiting_for_run'});
            % If the animal doesn't need to run to get the stimulus
        else
            % Set trial state
            % Tells arduino a new trial has started and sends the threshold speed
            sma = add_state(sma, 'name', 'set_trial','self_timer',0.001,...
                'output_actions', {'SchedWaveTrig','arduino_trigger+arduino_speed'},...
                'input_to_statechange', {'Tup','pre_cue'});
        end
        
        % Pre CUE state (TIME before CUE comes ON)
        if value(photoStim)  % Only if photo-stimulation is active on the session
            if value(noStim) % No photo-stimulation on this trial
                
                % Waits before presenting, and opens shutter
                sma = add_state(sma, 'name', 'pre_cue','self_timer', value(preCue),...
                    'output_actions', {'SchedWaveTrig','shutter_pulse+trial_timer'},...
                    'input_to_statechange', {'Tup', 'cue'});
            else % Trial with photo-stimulation
                % Pre stimulus state
                % Waits before presenting, opens shutter and prepares photo-stimulation
                sma = add_state(sma, 'name', 'pre_cue','self_timer', value(preCue),...
                    'output_actions', {'SchedWaveTrig','AOM_pulse1+shutter_pulse+preamble_wave+trial_timer'},...
                    'input_to_statechange', {'Tup', 'cue'});
            end
        else
            % Pre Cue State
            % Waits before presenting
                sma = add_state(sma, 'name', 'pre_cue','self_timer', value(preCue),...
                    'output_actions', {'SchedWaveTrig','trial_timer'},...
                    'input_to_statechange', {'Tup', 'cue'});
        end
        
        % % CUE presentation state  % make a different state for cueInvalid so it is easy to see on the pokes plot
        if validTrial
            sma = add_state(sma, 'name', 'cue','self_timer', value(cueDuration),...
                'output_actions', {'SchedWaveTrig','stimulus_trigger+cue_stimulus_timer+cue_stimulus_No_trigger'},...
                'input_to_statechange', {'Tup', 'stimulus_delay'});
            % DUMMY STATE
            sma = add_state(sma, 'name', 'cueInvalid','self_timer', 0.001,'input_to_statechange', {'Tup', 'stimulus_delay'});
            
        else
            sma = add_state(sma, 'name', 'cue','self_timer', 0.001,...
                'output_actions', {'SchedWaveTrig','stimulus_trigger+cue_stimulus_timer+cue_stimulus_No_trigger'},...
                'input_to_statechange', {'Tup', 'cueInvalid'});
            sma = add_state(sma, 'name', 'cueInvalid','self_timer', value(cueDuration),...
                'input_to_statechange', {'Tup', 'stimulus_delay'});
        end
        
        sma = add_state(sma, 'name', 'stimulus_delay','self_timer', value(stimDelay),...
            'input_to_statechange', {'Tup', 'stim_onset'});
        
        % In case we want to force animals to wait before licking
        if value(punishEarlyLick)
            switch value(punishEarlyLickType) % TO DO
                case 'end_the_trial'
                    
                    % STIMULUS presentation STARTS
                    % Presents stimulus, starts trial timer and checks if animals lick during delay
                    sma = add_state(sma, 'name', 'stim_onset','self_timer', earlyLickGracePeriod ,...
                        'input_to_statechange', {'Tup', 'punish_early_licks'});
                    sma = add_state(sma, 'name', 'punish_early_licks','self_timer', punishEarlyLicksWindow ,...
                        'input_to_statechange', {'Tup', 'change_stimulus',lick,'early_choice'});
                    % In case animals can lick during the delay period
                case 'delay_stim_change'
                    sma = add_state(sma, 'name', 'stim_onset','self_timer', earlyLickGracePeriod ,...
                        'input_to_statechange', {'Tup', 'punish_early_licks'});
                    sma = add_state(sma, 'name', 'punish_early_licks','self_timer', punishEarlyLicksWindow ,...
                        'input_to_statechange', {'Tup', 'change_stimulus',lick,'early_licks_stimulus_delayed1'});
                    
                    % STOP the stimulus & trial_timer it isn't relavant anymore
                    % because trial has been delayed by licking
                    sma = add_state(sma, 'name', 'early_licks_stimulus_delayed1','self_timer', 0.001 ,...
                        'output_actions', {'SchedWaveTrig','-trial_timer -cue_stimulus_timer -cue_stimulus_EARLY_LICKS_timer -trial_EARLY_LICKS_timer'},...
                        'input_to_statechange', {'Tup', 'early_licks_stimulus_delayed2'});
                    % START a new trial_timer_early_licks
                    sma = add_state(sma, 'name', 'early_licks_stimulus_delayed2','self_timer', 0.3 ,...
                        'output_actions', {'SchedWaveTrig','wrong_lick'},...
                        'input_to_statechange', {'Tup', 'early_licks_stimulus_delayed3'});
                    
                    sma = add_state(sma, 'name', 'early_licks_stimulus_delayed3','self_timer', 0.001 ,...
                        'output_actions', {'SchedWaveTrig','cue_stimulus_EARLY_LICKS_timer +trial_EARLY_LICKS_timer'},...
                        'input_to_statechange', {'Tup', 'punish_early_licks'});
                    % In case animals can lick during the delay period
            end
        else
            % STIMULUS presentation STARTS
            % Presents stimulus, starts trial timer and waits delay period
            sma = add_state(sma, 'name', 'stim_onset','self_timer', changeStimDelay,...
                'input_to_statechange', {'Tup', 'change_stimulus'}); %% OPTIONALLY PUNISH HERE
        end
        sma = add_state(sma, 'name', 'change_stimulus','self_timer', 0.05,...%% NOTE licks in this state are ignored (the stimulus has changed but it is too early for a response) it also stops sync problems with visual code. licks (and their pulses) at the same time as the pulse to change stimulus can screw things up
            'output_actions', {'SchedWaveTrig','change_stim_wave'},...
            'input_to_statechange', {'Tup', 'response_window'}); 
        
        
        
        % Response window state ( AFTER CHANGE of Stimlus)
        if validTrial % If current trial is is attended
            % Give free water after change... Training state
            if value(freeWaterAtChange)
                sma = add_state(sma, 'name', 'response_window','self_timer', 0.2,... % NOTE this is in addition to the outDelay give some time otherwise change pulse and correct pulse to visual computer can overlape
                    'input_to_statechange', {'Tup','correct_valid'});
            else
                sma = add_state(sma, 'name', 'response_window','self_timer', responseWindow,...
                    'input_to_statechange', {lick,'correct_valid','Tup', 'missed_response'});
                % Checks animal licks and rewards, punishes or goes to time out
                % In case we are not punishing animals for mistakes
            end
        else
            if  value(rewardWitholding)                 % In case we reward the animals for WITHOLDING
                sma = add_state(sma, 'name', 'response_window','self_timer', responseWindow,...
                    'input_to_statechange', {lick,'wrong_choice','Tup', 'correct_invalid'});
            else
                sma = add_state(sma, 'name', 'response_window','self_timer', responseWindow,...
                    'input_to_statechange', {lick,'wrong_choice','Tup', 'pre_iti'});
            end
            
        end
        
        % Time out state
        if value(setRespWindow)
            sma = add_state(sma, 'name', 'missed_response','self_timer', 10,...
                'input_to_statechange', {'cue_stimulus_timer_In', 'pre_iti', 'cue_stimulus_EARLY_LICKS_timer_In', 'pre_iti', 'Tup', 'pre_iti'});
        else
            % Checks animal licks and rewards or goes to time out
            sma = add_state(sma, 'name', 'missed_response','self_timer', 0.001,...
                'input_to_statechange', {'Tup', 'pre_iti'});
        end
        
        % Correct choice state
        % Opens valve, informs toolbox and waits trial duration before going to ITI
        sma = add_state(sma, 'name', 'correct_valid','self_timer', value(outDelay),... % to keep stimulus increase the length of this state
            'output_actions', {'SchedWaveTrig' '-cue_stimulus_timer -cue_stimulus_EARLY_LICKS_timer'},...
            'input_to_statechange', {'Tup', 'reward_state'});
        
        sma = add_state(sma, 'name', 'reward_state','self_timer', 0.001,...
            'output_actions', {'SchedWaveTrig','reward_delivery+correct_lick'},...
            'input_to_statechange', {'Tup', 'pre_iti'});
        
        
        % Correct choice state
        % Opens valve, informs toolbox and waits trial duration before going to ITI
        sma = add_state(sma, 'name', 'correct_invalid','self_timer', value(outDelay),...
            'output_actions', {'SchedWaveTrig' '-cue_stimulus_timer -cue_stimulus_EARLY_LICKS_timer'},...
            'input_to_statechange', {'Tup', 'reward_state_invalid'});
        
        sma = add_state(sma, 'name', 'reward_state_invalid','self_timer', 0.001,...
            'output_actions', {'SchedWaveTrig','reward_delivery'},...
            'input_to_statechange', {'Tup', 'pre_iti'});
        
% 
        % Wrong choice state
        if  value(punishError)  % In case we punish the animals for making a mistake
            % Informs toolbox and waits error time-out
            sma = add_state(sma, 'name', 'wrong_choice','self_timer', 10,...
                'output_actions', {'SchedWaveTrig','wrong_lick'},...
                'input_to_statechange', {'trial_timer_In', 'wrongChoice_timeout',...
                'trial_EARLY_LICKS_timer_In', 'wrongChoice_timeout','Tup', 'wrongChoice_timeout'}); % there is a hack here the Tup state change.. (is is possilbe that trial timer IN has already happened in this stage?
            
            sma = add_state(sma, 'name', 'wrongChoice_timeout','self_timer', value(errorTimeOut),...
                'input_to_statechange', {'Tup', 'pre_iti'});
        else
            sma = add_state(sma, 'name', 'wrong_choice','self_timer', 10,...
                'input_to_statechange', {'trial_timer_In', 'pre_iti',...
                'trial_EARLY_LICKS_timer_In', 'pre_iti','Tup', 'pre_iti'});
            
            sma = add_state(sma, 'name', 'wrongChoice_timeout','self_timer', value(errorTimeOut),...  % STATE IS NEVER ENTERED
                'input_to_statechange', {'Tup', 'pre_iti'});
        end
        
        % Early  choice state
        sma = add_state(sma, 'name', 'early_choice','self_timer', 0.001,...
             'output_actions', {'SchedWaveTrig' 'stop_stim_wave' },...
             'input_to_statechange', {'cue_stimulus_No_trigger_In', 'pre_iti'});
        % This State gives time for the stimulus information to be computed before the
        % StimulusPresntation program is called by thenext trigger
        preITItime =1;
        sma = add_state(sma, 'name', 'pre_iti','self_timer',preITItime,...
            'output_actions', {'SchedWaveTrig' '-cue_stimulus_timer -cue_stimulus_EARLY_LICKS_timer'},... % BA shouldn't be necessary?
            'input_to_statechange', {'Tup','inter_trial_interval'});
        
        % Inter trial interval state
        % Loads next trial stimulus and waits ITI before ending the trial
        sma = add_state(sma, 'name', 'inter_trial_interval','self_timer',ITIValue-preITItime,...
            'output_actions', {'SchedWaveTrig','stimulus_trigger'},...
            'input_to_statechange', {'Tup','check_next_trial_ready'});
        
        
        %% Sends state machine to the assembler
        dispatcher('send_assembler', sma, {'pre_iti'});
        
        
    case 'reinit',
        
        % Delete all SoloParamHandles who belong to this object and whose
        % fullname starts with the name of this mfile:
        delete_sphandle('owner', ['^@' class(obj) '$'], ...
            'fullname', ['^' mfilename]);
        
        % Reinitialise at the original GUI position and figure:
        feval(mfilename, obj, 'init');
        
        
    otherwise,
        warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action); %#ok<WNTAG>
        
        
end
