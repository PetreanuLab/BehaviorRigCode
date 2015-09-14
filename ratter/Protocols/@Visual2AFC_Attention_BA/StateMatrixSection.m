function  [] =  StateMatrixSection(obj, action)

global toolboxtrig;
global leftvalve;
global syncled;
global rightvalve;
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
        
        SupportFunctions(obj,'set_next_dots');
        SupportFunctions(obj,'set_next_side');
        SupportFunctions(obj,'param_save');
        
        StateMatrixSection(obj, 'next_trial');
        
    case 'next_trial',
        %%
        %%%%%%%%%%%%%%%%%% Preparation step %%%%%%%%%%%%%%%%%%%%%%%%%
        %% Gets the correct and wrong choice
        
        if value(currStimSide)
            correctChoice = 'Lin';
            wrongChoice = 'Rin';
            reward = leftvalve;
            valveOpen = value(valveTime)*value(leftRewardMult);
        else
            correctChoice = 'Rin';
            wrongChoice = 'Lin';
            reward = rightvalve;
            valveOpen = value(valveTime)*value(rightRewardMult);
        end
        
        % % fixed ratio don't open the valve
        if value(fixedRationN)>1 & value(fixRatioRwdthisTrial)==0
            valveOpen = 0.001
        end
        
        if value(currTrialBonus)==1
            valveOpen= valveOpen *value(bonusWaterFac);
            disp('bonus trial')
        end
        %% Sets the inter-trial-interval
        if strcmp(value(ITI),'RANDOM')
            ITIValue = rand* (value(ITIMax)-value(ITIMin)) + value(ITIMin);
        else
            ITIValue = value(ITIMax);
        end
        
        %% Sets the response delay
        if value(delayMatchStim)
            responseDelay = value(currStimDuration);
            responseWindow = value(respDelay)+value(respWindow)-responseDelay;
        else
            responseDelay = value(respDelay);
            responseWindow = value(respWindow);
        end
        
        
        %%
        %%%%%%%%%%%%%%%%%% State Machine Configuration %%%%%%%%%%%%%%%%%%%%%%%%%
        %% Sets up the assembler
        sma = StateMachineAssembler('full_trial_structure');
        
        %% Sets up the scheduled waves
        % Psychtoolbox triggers
        sma = add_scheduled_wave(sma,'name','stimulus_trigger',...
            'preamble',0.001,'sustain',0.001,...
            'DOut',toolboxtrig);
        sma = add_scheduled_wave(sma,'name','correct_lick',...
            'preamble',0.001,'sustain',0.001,...
            'trigger_on_up', 'correct_timer','DOut',toolboxtrig);
        sma = add_scheduled_wave(sma,'name','wrong_lick',...
            'preamble',0.001,'sustain',0.001,...
            'trigger_on_up', 'wrong_timer','DOut',toolboxtrig);
        sma = add_scheduled_wave(sma,'name','correct_timer',...
            'preamble',0.1,...
            'trigger_on_up', 'lick_pulse');
        sma = add_scheduled_wave(sma,'name','wrong_timer',...
            'preamble',0.2,...
            'trigger_on_up', 'lick_pulse');
        sma = add_scheduled_wave(sma,'name','lick_pulse',...
            'preamble',0.001,'sustain',0.001,...
            'trigger_on_up', 'after_timer','DOut',toolboxtrig);
        sma = add_scheduled_wave(sma,'name','after_timer',...
            'preamble',value(afterLick),...
            'trigger_on_up', 'stimulus_trigger');
        sma = add_scheduled_wave(sma,'name','sync_trigger',...
            'preamble',0.001,'sustain',0.20,...
            'DOut',syncled);
          
        % Scan Image trigger
%         sma = add_scheduled_wave(sma,'name','scanimage_trigger_1',...
%             'preamble',0.001,'sustain',0.020,...
%             'DOut',scanimagetrig1);
%         sma = add_scheduled_wave(sma,'name','scanimage_trigger_2',...
%             'preamble',0.001,'sustain',0.020,...
%             'DOut',scanimagetrig2);
        
        
        % Stop trial
        sma = add_scheduled_wave(sma,'name','trial_timer',...
            'preamble',value(trialDuration),'sustain',0.001);
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
                'preamble', value(preStimulus)+value(current_time_rel_vis_stim1)-0.009,...
                'sustain',totalStimTime-value(current_time_rel_vis_stim1)-0.014,...
                'DOut',shuttertrig);      %channel DIO1 of cable 2
            
            if value(noStim)==0
                %SW to shine the laser on the mouse: turns on  RF to AOM
                sma = add_scheduled_wave(sma,'name','AOM_pulse1', ...
                    'preamble', value(preStimulus)+value(current_time_rel_vis_stim1),...
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
                    'preamble', value(preStimulus)+value(current_time_rel_vis_stim1)-0.001, ...
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
                'input_to_statechange', {'Tup','pre_stimulus','Sout','waiting_for_run'});
            % If the animal doesn't need to run to get the stimulus
        else
            % Set trial state
            % Tells arduino a new trial has started and sends the threshold speed
            sma = add_state(sma, 'name', 'set_trial','self_timer',0.001,...
                'output_actions', {'SchedWaveTrig','arduino_trigger+arduino_speed'},...
                'input_to_statechange', {'Tup','pre_stimulus'});
        end
        % Only if photo-stimulation is active on the session
        if value(photoStim)
            if value(noStim) % No photo-stimulation on this trial
                % Pre stimulus state
                % Waits before presenting, and opens shutter
                sma = add_state(sma, 'name', 'pre_stimulus','self_timer', value(preStimulus),...
                    'output_actions', {'SchedWaveTrig','shutter_pulse'},...
                    'input_to_statechange', {'Tup', 'cue'});
            else % Trial with photo-stimulation
                % Pre stimulus state
                % Waits before presenting, opens shutter and prepares photo-stimulation
                sma = add_state(sma, 'name', 'pre_stimulus','self_timer', value(preStimulus),...
                    'output_actions', {'SchedWaveTrig','AOM_pulse1+shutter_pulse+preamble_wave'},...
                    'input_to_statechange', {'Tup', 'cue'});
            end
        else
            % Pre stimulus state
            % Waits before presenting
            if value(noLick)
                sma = add_state(sma, 'name', 'pre_stimulus','self_timer', value(preStimulus),...
                    'input_to_statechange', {'Tup', 'cue','Rin','reset_pre_stimulus','Lin','reset_pre_stimulus'});
            else
                if n_done_trials == 0
                    sma = add_state(sma, 'name', 'pre_stimulus','self_timer', value(preStimulus),...
                        'input_to_statechange', {'Tup', 'cue'});
%                         'output_actions', {'SchedWaveTrig','scanimage_trigger_1'},...
%                         'input_to_statechange', {'Tup', 'cue'});
                else
                    sma = add_state(sma, 'name', 'pre_stimulus','self_timer', value(preStimulus),...
                         'input_to_statechange', {'Tup', 'cue'});
%  %                       'output_actions', {'SchedWaveTrig','scanimage_trigger_1+scanimage_trigger_2'},...
%                         'input_to_statechange', {'Tup', 'cue'});
                end
                
            end
            
            sma = add_state(sma, 'name', 'reset_pre_stimulus','self_timer',0.001,...
                'input_to_statechange', {'Tup', 'pre_stimulus'});
        end
        
        sma = add_state(sma, 'name', 'cue','self_timer', max(0.001,value(cueLength)),...
            'output_actions', {'SchedWaveTrig','stimulus_trigger+trial_timer+sync_trigger'},...
            'input_to_statechange', {'Tup', 'post_cue'});
        
        sma = add_state(sma, 'name', 'post_cue','self_timer', max(0.001,value(postcueLength)),...
            'input_to_statechange', {'Tup', 'resp_delay'});
        
        % In case we want to force animals to wait before licking
        if value(punishEarlyLick)
            % Stimulus presentation state
            % Presents stimulus, starts trial timer and checks if animals lick during delay
            sma = add_state(sma, 'name', 'resp_delay','self_timer', responseDelay,...
                'input_to_statechange', {'Tup', 'response_window',wrongChoice,'wrong_choice',correctChoice,'early_correct_choice'});
            % In case animals can lick during the delay period
        else
            % Stimulus presentation state
            % Presents stimulus, starts trial timer and waits delay period
            sma = add_state(sma, 'name', 'resp_delay','self_timer', responseDelay,...
                'input_to_statechange', {'Tup', 'response_window'});
        end
        
        % In case we punish the animals for making a mistake
        if value(punishError)
            % Response window state
            % Checks animal licks and rewards, punishes or goes to time out
            sma = add_state(sma, 'name', 'response_window','self_timer', responseWindow,...
                'input_to_statechange', {correctChoice,'correct_choice',wrongChoice,'wrong_choice','Tup', 'time_out'});
            % In case we are not punishing animals for mistakes
        else
            % Response window state
            % Checks animal licks and rewards or goes to time out
            sma = add_state(sma, 'name', 'response_window','self_timer', responseWindow,...
                'input_to_statechange', {correctChoice,'correct_choice','Tup', 'time_out'});
        end
        
        % Time out state
        % Checks animal licks and rewards or goes to time out
        sma = add_state(sma, 'name', 'time_out','self_timer', 10,...
            'input_to_statechange', {'trial_timer_In', 'inter_trial_interval','Tup', 'inter_trial_interval'});
        
        % Correct choice state
        % Opens valve, informs toolbox and waits trial duration before going to ITI
        sma = add_state(sma, 'name', 'correct_choice','self_timer', 10,...
            'output_actions', {'SchedWaveTrig','reward_delivery+correct_lick'},...
            'input_to_statechange', {'trial_timer_In', 'inter_trial_interval','Tup', 'inter_trial_interval'});
        % Early correct choice state
        % Informs toolbox and waits trial duration before going to ITI
        sma = add_state(sma, 'name', 'early_correct_choice','self_timer', 10,...
            'output_actions', {'SchedWaveTrig','correct_lick'},...
            'input_to_statechange', {'trial_timer_In', 'inter_trial_interval','Tup', 'inter_trial_interval'});
        % Wrong choice state
        % Informs toolbox and waits error time-out
        sma = add_state(sma, 'name', 'wrong_choice','self_timer', value(errorTimeOut),...
            'output_actions', {'SchedWaveTrig','wrong_lick'},...
            'input_to_statechange', {'Tup', 'inter_trial_interval_wrong'});
        
        % Inter trial interval state
        % Loads next trial stimulus and waits ITI before ending the trial
        sma = add_state(sma, 'name', 'inter_trial_interval','self_timer',ITIValue,...
            'output_actions', {'SchedWaveTrig','stimulus_trigger'},...
            'input_to_statechange', {'Tup','check_next_trial_ready'});
        
        % In case we want lick during ITI after wrong choice to reset it
        if value(resetITI)
            % Inter trial interval wrong state
            % Waits ITI and resets it if any lick is detected
            sma = add_state(sma, 'name', 'inter_trial_interval_wrong','self_timer',0.001,...
                'output_actions', {'SchedWaveTrig','stimulus_trigger'},...
                'input_to_statechange', {'Tup','inter_trial_interval_wait'});
            
            sma = add_state(sma, 'name', 'inter_trial_interval_wait','self_timer',ITIValue,...
                'input_to_statechange', {'Tup','check_next_trial_ready','Rin','reset_ITI','Lin','reset_ITI'});
            % Reset ITI state
            % Resets ITI
            sma = add_state(sma, 'name', 'reset_ITI','self_timer',0.001,...
                'input_to_statechange', {'Tup', 'inter_trial_interval_wait'});
            % In case animals can lick during ITI after wrong choice
        else
            % Inter trial interval wrong state
            % Loads next trial stimulus and waits ITI before ending the trial
            sma = add_state(sma, 'name', 'inter_trial_interval_wrong','self_timer',ITIValue,...
                'output_actions', {'SchedWaveTrig','stimulus_trigger'},...
                'input_to_statechange', {'Tup','check_next_trial_ready'});
        end
        
        %% Sends state machine to the assembler
        dispatcher('send_assembler', sma, {'correct_choice','time_out','wrong_choice','early_correct_choice'});
        
        
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
