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
        
        SupportFunctions(obj,'set_next_stimulusChange');
        SupportFunctions(obj,'set_next_dots');        
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
        
        goTrial = value(currGoTrial); % valid means go
        stim_length = value(currStimDuration);

        trial_length = stim_length + value(currStimOnset)+value(outDelay)+0.01;
        
        %%
        %%%%%%%%%%%%%%%%%% State Machine Configuration %%%%%%%%%%%%%%%%%%%%%%%%%
        % % Sets up the assembler
        sma = StateMachineAssembler('full_trial_structure');
        
        %% Sets up the scheduled waves
        % Psychtoolbox triggers
        sma = add_scheduled_wave(sma,'name','stimulus_trigger',... % 1 present stimulus, prepare stimulus
            'preamble',0.001,'sustain',0.001,'DOut',toolboxtrig);
        sma = add_scheduled_wave(sma,'name','stop_stimulus_trigger',... % 1 present stimulus, prepare stimulus
            'preamble',0.001,'sustain',0.001,...
            'trigger_on_up', 'stop_stimulus_timer','DOut',toolboxtrig);
        sma = add_scheduled_wave(sma,'name','stop_stimulus_timer',... %
            'preamble',0.2,'sustain',0.001,...
            'trigger_on_up', 'pulse');
        sma = add_scheduled_wave(sma,'name','correct_lick',... % 2 lick detected
            'preamble',0.001,'sustain',0.001,        ...
            'trigger_on_up', 'correct_timer','DOut',toolboxtrig); 
        sma = add_scheduled_wave(sma,'name','wrong_lick',... % 2 lick detected
            'preamble',0.001,'sustain',0.001,...
            'trigger_on_up', 'wrong_timer','DOut',toolboxtrig); 
        sma = add_scheduled_wave(sma,'name','correct_timer',...
            'preamble',0.05,...
            'trigger_on_up', 'pulse');
        sma = add_scheduled_wave(sma,'name','wrong_timer',...
            'preamble',0.125,...    % this duration is decoded by the stimulus computer to present Visual Error or not
            'trigger_on_up', 'pulse');
        sma = add_scheduled_wave(sma,'name','pulse',...  % 
            'preamble',0.001,'sustain',0.001,....
            'DOut',toolboxtrig); 
        
        % Stop trial
        sma = add_scheduled_wave(sma,'name','trial_timer',...
            'preamble',trial_length,'sustain',0.001);
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
                'input_to_statechange', {'Tup','pre','Sout','waiting_for_run'});
            % If the animal doesn't need to run to get the stimulus
        else
            % Set trial state
            % Tells arduino a new trial has started and sends the threshold speed
            sma = add_state(sma, 'name', 'set_trial','self_timer',0.001,...
                'output_actions', {'SchedWaveTrig','arduino_trigger+arduino_speed'},...
                'input_to_statechange', {'Tup','pre'});
        end
        
        % Pre stim state (TIME before stimulus comes ON)
        if value(photoStim)  % Only if photo-stimulation is active on the session
            if value(noStim) % No photo-stimulation on this trial
                
                % Waits before presenting, and opens shutter
                sma = add_state(sma, 'name', 'pre','self_timer', 0.001,...
                    'output_actions', {'SchedWaveTrig','trial_timer'},...
                    'input_to_statechange', {'Tup', 'pre_stim'});
            else % Trial with photo-stimulation
                % Pre stimulus state
                % Waits before presenting, opens shutter and prepares photo-stimulation
                sma = add_state(sma, 'name', 'pre','self_timer', 0.001,...
                    'output_actions', {'SchedWaveTrig','AOM_pulse1+preamble_wave+trial_timer'},...
                    'input_to_statechange', {'Tup', 'pre_stim'});
            end
        else
            % Pre Cue State
            % Waits before presenting
                sma = add_state(sma, 'name', 'pre','self_timer', 0.001,...
                    'output_actions', {'SchedWaveTrig','trial_timer'},...
                    'input_to_statechange', {'Tup', 'pre_stim'});
        end
        
        sma = add_state(sma, 'name', 'pre_stim','self_timer', value(currStimOnset),...
            'input_to_statechange', {'Tup', 'stim_onset'});
        % % insert punish early licks here
        % % STIMULUS presentation state
        if goTrial
            
            if value(freeWaterAtChange)
                sma = add_state(sma, 'name', 'stim_onset','self_timer', 1,...%  show stimulus for a sec
                    'output_actions', {'SchedWaveTrig','stimulus_trigger'},... % 
                    'input_to_statechange', {'Tup', 'freewater'});
                sma = add_state(sma, 'name', 'freewater','self_timer', 0.25,...% give water
                    'output_actions', {'SchedWaveTrig','reward_delivery'},...
                    'input_to_statechange', {'Tup', 'freewater_await_lick'});
                sma = add_state(sma, 'name', 'freewater_await_lick','self_timer', 1,...% wait for lick
                    'input_to_statechange', {lick,'freewater_stop_stimulus_lick','Tup', 'freewater_stop_stimulus'});
                sma = add_state(sma, 'name', 'freewater_stop_stimulus_lick','self_timer', 0.001,...% give reward tone and stop stimulus
                    'output_actions', {'SchedWaveTrig','correct_lick'},...
                    'input_to_statechange', {'Tup', 'pre_iti'});
               sma = add_state(sma, 'name', 'freewater_stop_stimulus','self_timer', 0.001,...% give reward tone and stop stimulus
                    'output_actions', {'SchedWaveTrig','stop_stimulus_trigger'},...
                    'input_to_statechange', {'Tup', 'pre_iti'});
                
            else
                sma = add_state(sma, 'name', 'stim_onset','self_timer', 0.25,...% this pause is so an fast lick doesn't screw up sync
                    'output_actions', {'SchedWaveTrig','stimulus_trigger'},... % present stimulus
                    'input_to_statechange', {'Tup', 'go_response_window'});
            end
        else
            sma = add_state(sma, 'name', 'stim_onset','self_timer', 0.25,... % this pause is so an fast lick doesn't screw up sync
                'output_actions', {'SchedWaveTrig','stimulus_trigger'},... % present stimulus
                'input_to_statechange', {'Tup', 'nogo_response_window'});
        end
        
        
        % Response window state  AFTER Stimlus)  
        sma = add_state(sma, 'name', 'go_response_window','self_timer', stim_length,...
            'input_to_statechange', {lick,'correct_go','Tup', 'missed_response'});
        % Checks animal licks and rewards, punishes or goes to time out
        % In case we are not punishing animals for mistakes
        
        sma = add_state(sma, 'name', 'nogo_response_window','self_timer', stim_length,...
            'input_to_statechange', {lick,'wrong_choice','Tup', 'correct_nogo'});
        
        sma = add_state(sma, 'name', 'missed_response','self_timer', 0.001,...
            'output_actions', {'SchedWaveTrig','stop_stimulus_trigger'},...
            'input_to_statechange', {'Tup', 'pre_iti'});
        
        % Correct choice state
        % Opens valve, informs toolbox and waits trial duration before going to ITI
        sma = add_state(sma, 'name', 'correct_go','self_timer', value(outDelay),... % to keep stimulus increase the length of this state
            'input_to_statechange', {'Tup', 'reward_state'});
        
        sma = add_state(sma, 'name', 'reward_state','self_timer', 0.001,...
            'output_actions', {'SchedWaveTrig','reward_delivery+correct_lick'},...
            'input_to_statechange', {'Tup', 'pre_iti'});
        
        if  value(rewardWitholding)                 % In case we reward the animals for WITHOLDING
            sma = add_state(sma, 'name', 'correct_nogo','self_timer', value(outDelay),...
                'output_actions', {'SchedWaveTrig','stop_stimulus_trigger'},...
                'input_to_statechange', {'Tup', 'reward_state_nogo'});
        else
            sma = add_state(sma, 'name', 'correct_nogo','self_timer', value(outDelay),...
                'output_actions', {'SchedWaveTrig','stop_stimulus_trigger'},...
                'input_to_statechange', {'Tup', 'pre_iti'});           
        end
        
        sma = add_state(sma, 'name', 'reward_state_nogo','self_timer', 0.001,...
            'output_actions', {'SchedWaveTrig','reward_delivery'},...
            'input_to_statechange', {'Tup', 'pre_iti'});
        
        
        % Wrong choice state
        if  value(punishError)  % In case we punish the animals for making a mistake
            % Informs toolbox and waits error time-out
            sma = add_state(sma, 'name', 'wrong_choice','self_timer', value(errorTimeOut),...
                'output_actions', {'SchedWaveTrig','wrong_lick'},...
                'input_to_statechange', {'trial_timer_In', 'wrong_choice_2','Tup', 'wrongChoice_timeout'}); % there is a hack here the Tup state change.. (is is possilbe that trial timer IN has already happened in this stage?
 
            sma = add_state(sma, 'name', 'wrong_choice_2','self_timer', 0.5,... % this state is so a late lick wont collide with stopstimulus 
                'input_to_statechange', {'Tup', 'wrongChoice_timeout'}); % there is a hack here the Tup state change.. (is is possilbe that trial timer IN has already happened in this stage?
            
            sma = add_state(sma, 'name', 'wrongChoice_timeout','self_timer', value(errorTimeOut)-0.5,...
                 'output_actions', {'SchedWaveTrig','stop_stimulus_trigger'},...            
                'input_to_statechange', {'Tup', 'pre_iti'});
        else
            sma = add_state(sma, 'name', 'wrong_choice','self_timer', 10,...
                'input_to_statechange', {'trial_timer_In', 'wrongChoice_timeout','Tup', 'wrongChoice_timeout'});
            
            sma = add_state(sma, 'name', 'wrongChoice_timeout','self_timer', 0.001,...
                'output_actions', {'SchedWaveTrig','stop_stimulus_trigger'},...
                'input_to_statechange', {'Tup', 'pre_iti'});
        end
        
        % This State gives time for the stimulus information to be computed before the
        % StimulusPresntation program is called by thenext trigger
        preITItime =1;
        sma = add_state(sma, 'name', 'pre_iti','self_timer',preITItime,...
            'input_to_statechange', {'Tup','inter_trial_interval'});
        
        % Inter trial interval state
        % Loads next trial stimulus and waits ITI before ending the trial
        sma = add_state(sma, 'name', 'inter_trial_interval','self_timer',ITIValue-preITItime,...
            'output_actions', {'SchedWaveTrig','stimulus_trigger'},... % prepare next trial in visual pc
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
