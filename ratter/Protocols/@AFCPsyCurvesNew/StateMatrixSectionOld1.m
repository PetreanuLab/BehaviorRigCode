%function [ output_args ] = StateMatrixSection_comented( input_args )
%STATEMATRIXSECTION_COMENTED Summary of this function goes here
%   Detailed explanation goes here

% Typical section code-- this file may be used as a template to be added 
% on to. The code below stores the current figure and initial position when
% the action is 'init'; and, upon 'reinit', deletes all SoloParamHandles 
% belonging to this section, then calls 'init' at the proper GUI position 
% again.


% [x, y] = YOUR_SECTION_NAME(obj, action, x, y)
%
% Section that takes care of YOUR HELP DESCRIPTION
%
% PARAMETERS:
% -----------
%
% obj      Default object argument.
%
% action   One of:
%            'init'      To initialise the section and set up the GUI
%                        for it
%
%            'reinit'    Delete all of this section's GUIs and data,
%                        and reinit, at the same position on the same
%                        figure as the original section GUI was placed.
%
% x, y     Relevant to action = 'init'; they indicate the initial
%          position to place the GUI at, in the current figure window
%
% RETURNS:
% --------
%
% [x, y]   When action == 'init', returns x and y, pixel positions on
%          the current figure, updated after placing of this section's GUI. 
%


function sma = StateMatrixSection(obj, action)

%declare here the globals that you want the stateMatrixSection
%to have access to, usually these are declared in the Settings_Custom.conf
%Declare var's in Protocol file as globals and initialize them,
%the%GetSoloFunctionArgs should get them!!

GetSoloFunctionArgs;

global left1water;
global right1water;
% global odorPresent

switch action

  case 'init',

      StateMatrixSection(obj, 'next_trial');

      
  case 'next_trial',
    %Declare != state matrixs here!! if something, this sma, if something else
    %then this other, if even somthing else, use this sma, while somthing, for
    %something, etc etc etc you get the pic.
        sma = StateMachineAssembler('full_trial_structure');
        
       %-------------------------------------------------------------------------%
        sma = add_olf_bank(sma, 'name', 'OlfBankA', 'ip',...
            value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_A_ID))]);
        sma = add_olf_bank(sma, 'name', 'OlfBankB', 'ip',...
            value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_B_ID))]);
        sma = add_olf_bank(sma, 'name', 'OlfBankF', 'ip',...
            value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_F_ID))]);
        sma = add_olf_bank(sma, 'name', 'OlfBankD', 'ip',...
            value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_D_ID))]);
       %-------------------------------------------------------------------------% 

    % If using scheduled waves, they have to be declared here, before the
    % states
    
%     disp(value(lValve))
%     disp(value(rValve))
    
    
    sma = add_scheduled_wave(sma, 'name', 'CNT_DELAY_SW', ...
        'preamble', (value(waitingTime)));
    
    sma = add_scheduled_wave(sma, 'name', 'CNT_JITTER_SW', ...
        'preamble', (value(cnt_jitter)));

    sma = add_scheduled_wave(sma, 'name', 'RWD_DELAY_INTER_TRIAL_SW', ...
        'preamble', (value(waitingTimeRew)), ...
        'sustain', value(ITI)-value(waitingTimeRew));
                
    sma = add_scheduled_wave(sma, 'name', 'GO_SIGNAL_SW', ...
        'preamble', value(goSignalDelay), ...
        'sustain', value(SoundDur), ...
        'refraction', 0, ...
        'sound_trig', value(IdSound));
        
    % IMPORTANT: the first state declared is state_0.
    % Default inputs: Lin: left line in; Lout: left line out; Rin, Rout;
    % Cin; Cout; Tup;
    
%-------------------------------------------------------------------------%    



% P.S. the first state is by default:
% sma = add_state(sma, 'default_statechange', 'Waiting_4_Cin',
% 'self_timer', 0.001);


  
% disp(value(timeToGetReward))
% disp(value(olfCueDuration))
% disp(value(SoundDur))
          
                
                
                % Wait for center poke in
                sma = add_state(sma, 'name', 'waiting_for_cin', 'input_to_statechange', ...
                    {'Cin', 'center_poke_in'});
                
                switch value(taskVersion)
                    
                    case 'Original'
                        % Center poke in
                        sma = add_state(sma, 'name', 'center_poke_in', ...
                            'output_actions', {'SchedWaveTrig', 'CNT_DELAY_SW'},...
                            'input_to_statechange', {'CNT_DELAY_SW_In', 'cin_odor_min', ...
                            'Cout','early_cout'});
                        
                        % Early poke out -- but has the oportunity of
                        % poking in again
                        sma = add_state(sma, 'name', 'early_cout', ... 
                            'output_actions', {'SchedWaveTrig','CNT_JITTER_SW'},...
                            'input_to_statechange', {'CNT_JITTER_SW_In', 'premature_cout', ...
                            'Cin','center_poke_in_2',...
                            'CNT_DELAY_SW_In', 'cnt_jitter_go_signal_prevention'});

                        % 2nd center poke in
                        sma= add_state(sma,'name','center_poke_in_2',...
                            'output_actions', {'SchedWaveTrig','-CNT_JITTER_SW '},...
                            'input_to_statechange',{'CNT_DELAY_SW_In','cin_odor_min',...
                            'Cout','early_cout'});

                        % Center jitter at the end of the odor delay
                        sma = add_state(sma, 'name', 'cnt_jitter_go_signal_prevention', ...
                            'input_to_statechange', {'CNT_JITTER_SW_In', 'premature_cout', ...
                            'Cin','cin_odor_min'});

                        % Premature cout
                        sma = add_state(sma, 'name', 'premature_cout', 'self_timer', 0.001, ...
                            'output_actions',{'SoundOut', value(IdNoiseBurst)}, ...
                            'input_to_statechange', {'Tup', 'final_state'});
                        
                        % Center odor delivery _ minimum
                        sma = add_state(sma, 'name', 'cin_odor_min', ...
                            'output_actions', {'SchedWaveTrig','GO_SIGNAL_SW+RWD_DELAY_INTER_TRIAL_SW', value(OlfBank), value(valveNumber)}, ...
                            'input_to_statechange', {'GO_SIGNAL_SW_Out', 'go_signal', ...
                            'Cout','premature_cout_go_signal'});
                                                      
                        % Go-signal
                        sma = add_state(sma, 'name', 'go_signal', 'output_actions', {value(OlfBank), value(valveNumber)}, ...
                            'self_timer', 0.001, ...
                            'input_to_statechange', {'Tup', 'cin_odor_after_go_signal', 'Cout', 'cin_odor_after_go_signal'});
                        
                        % Center odor delivery _ after go-signal
                        sma = add_state(sma, 'name', 'cin_odor_after_go_signal', ...
                            'self_timer', (value(odorDeliveryMax) - value(SoundDur)), ...
                            'output_actions', {value(OlfBank), value(valveNumber)}, ...
                            'input_to_statechange', {'Cout', 'waiting_for_both_pokes', ...
                            'Tup', 'waiting_for_both_pokes'});
                                                                                                                        
                        % Premature cout go signal
                        sma = add_state(sma, 'name', 'premature_cout_go_signal', 'self_timer', 0.001, ...
                            'input_to_statechange', {'Tup', 'final_state'});
                        
                        
                        if strcmp (value(stim1Side), 'Left') == 1
                            
                            if (value(currentOdor(1,n_started_trials + 1)) == 1 || ...
                                    value(currentOdor(1,n_started_trials + 1)) == 3) == 1, % left - correct for stim1

                                % Waiting for right or left poke
                                sma = add_state(sma, 'name', 'waiting_for_both_pokes', ...
                                    'self_timer', value(timeToGetReward),'input_to_statechange', ...
                                    {'Lin', 'left_poke_in_correct', 'Rin', 'right_poke_in_error', ...
                                    'Tup', 'too_late'});

                                % Too late
                                sma = add_state(sma, 'name', 'too_late', ...
                                    'self_timer', 0.001, 'input_to_statechange', {'Tup', 'final_state'});

                                % Left poke in
                                sma = add_state(sma, 'name', 'left_poke_in_correct', ...
                                    'self_timer', (value(waitingTimeRew)), ...
                                    'input_to_statechange', {'Tup', 'lin_water', 'Lout', 'premature_correct_lout'});

                                % Premature correct left poke out
                                sma = add_state(sma, 'name', 'premature_correct_lout', ...
                                    'self_timer', 0.001, 'input_to_statechange', {'Tup', 'final_state'});

                                % Deliver water left
                                sma = add_state(sma, 'name', 'lin_water', 'output_actions', {'DOut', left1water}, ...
                                    'self_timer', value(lValve), 'input_to_statechange', ...
                                    {'Tup', 'final_state', 'Lout', 'final_state'});    

                                % Right poke in
                                sma = add_state(sma, 'name', 'right_poke_in_error', ...
                                    'self_timer', (value(waitingTimeRew)), 'input_to_statechange', {'Tup', 'rin_no_water', 'Rout', 'premature_error_rout'});

                                % Premature error right poke out
                                sma = add_state(sma, 'name', 'premature_error_rout', ...
                                    'self_timer', 0.001, 'input_to_statechange', {'Tup', 'rin_no_water'});

                                % No water right
                                sma = add_state(sma, 'name', 'rin_no_water', ...
                                    'output_actions', {'SoundOut', value(IdWaterTone)}, ...
                                    'self_timer', value(rValve), ...
                                    'input_to_statechange', {'Tup', 'error_ITI', 'Rout', 'error_ITI'});

                                % Error ITI
                                sma = add_state(sma, 'name', 'error_ITI', ...
                                    'self_timer', value(timeOutPenalty) - value(rValve), 'input_to_statechange', {'Tup', 'final_state'});

                                % Final state
                                sma = add_state(sma, 'name', 'final_state', ...
                                    'self_timer', value(ITI) - value(lValve), 'input_to_statechange', {'Tup', 'check_next_trial_ready'});


                                % Virtual left_poke_in_error'
                                sma = add_state(sma, 'name', 'left_poke_in_error');

                                % Virtual right_poke_in_correct
                                sma = add_state(sma, 'name', 'right_poke_in_correct');

                                % Virtual premature_error_lout'
                                sma = add_state(sma, 'name', 'premature_error_lout');

                                % Virtual premature_correct_rout
                                sma = add_state(sma, 'name', 'premature_correct_rout');

                                % Virtual rin_water
                                sma = add_state(sma, 'name', 'rin_water');

                                % Virtual lin_no_water
                                sma = add_state(sma, 'name', 'lin_no_water');


                            elseif (value(currentOdor(1,n_started_trials + 1)) == 2 || ...
                                value(currentOdor(1,n_started_trials + 1)) == 4) == 1, % right - correct for stim2

                                % Waiting for right or left poke
                                sma = add_state(sma, 'name', 'waiting_for_both_pokes', ...
                                    'self_timer', value(timeToGetReward),'input_to_statechange', {'Rin', 'right_poke_in_correct', 'Lin', 'left_poke_in_error', ...
                                    'Tup', 'too_late'});

                                % Too late
                                sma = add_state(sma, 'name', 'too_late', ...
                                    'self_timer', 0.001, 'input_to_statechange', {'Tup', 'final_state'});

                                % Right poke in
                                sma = add_state(sma, 'name', 'right_poke_in_correct', ...
                                    'self_timer', (value(waitingTimeRew)), 'input_to_statechange', {'Tup', 'rin_water', 'Rout', 'premature_correct_rout'});

                                % Premature correct right poke out
                                sma = add_state(sma, 'name', 'premature_correct_rout', ...
                                    'self_timer', 0.001, 'input_to_statechange', {'Tup', 'final_state'});

                                % Deliver water right
                                sma = add_state(sma, 'name', 'rin_water', 'output_actions', {'DOut', right1water}, ...
                                    'self_timer', value(rValve), 'input_to_statechange', {'Tup', 'final_state', 'Rout', 'final_state'});    

                                % Left poke in
                                sma = add_state(sma, 'name', 'left_poke_in_error', ...
                                    'self_timer', (value(waitingTimeRew)), 'input_to_statechange', {'Tup', 'lin_no_water', 'Lout', 'premature_error_lout'});

                                % Premature error right poke out
                                sma = add_state(sma, 'name', 'premature_error_lout', ...
                                    'self_timer', 0.001, 'input_to_statechange', {'Tup', 'lin_no_water'});

                                % No water right
                                sma = add_state(sma, 'name', 'lin_no_water', ...
                                    'output_actions', {'SoundOut', value(IdWaterTone)}, ...
                                    'self_timer', value(lValve), ...
                                    'input_to_statechange', {'Tup', 'error_ITI', 'Lout', 'error_ITI'});

                                % Error ITI
                                sma = add_state(sma, 'name', 'error_ITI', ...
                                    'self_timer', value(timeOutPenalty) - value(lValve), 'input_to_statechange', {'Tup', 'final_state'});

                                % Final state
                                sma = add_state(sma, 'name', 'final_state', ...
                                    'self_timer', value(ITI) - value(rValve), 'input_to_statechange', {'Tup', 'check_next_trial_ready'});


                                % Virtual right_poke_in_error'
                                sma = add_state(sma, 'name', 'right_poke_in_error');

                                % Virtual left_poke_in_correct
                                sma = add_state(sma, 'name', 'left_poke_in_correct');

                                % Virtual premature_correct_lout'
                                sma = add_state(sma, 'name', 'premature_correct_lout');

                                % Virtual premature_error_rout
                                sma = add_state(sma, 'name', 'premature_error_rout');

                                % Virtual rin_water_olf
                                sma = add_state(sma, 'name', 'lin_water');

                                % Virtual lin_no_water_olf
                                sma = add_state(sma, 'name', 'rin_no_water');

                            end
                            
                            
                        elseif strcmp (value(stim1Side), 'Right') == 1
                            
                            if (value(currentOdor(1,n_started_trials + 1)) == 2 || ...
                                    value(currentOdor(1,n_started_trials + 1)) == 4) == 1, % left - correct for stim2

                                % Waiting for right or left poke
                                sma = add_state(sma, 'name', 'waiting_for_both_pokes', ...
                                    'self_timer', value(timeToGetReward),'input_to_statechange', ...
                                    {'Lin', 'left_poke_in_correct', 'Rin', 'right_poke_in_error', ...
                                    'Tup', 'too_late'});

                                % Too late
                                sma = add_state(sma, 'name', 'too_late', ...
                                    'self_timer', 0.001, 'input_to_statechange', {'Tup', 'final_state'});

                                % Left poke in
                                sma = add_state(sma, 'name', 'left_poke_in_correct', ...
                                    'self_timer', (value(waitingTimeRew)), ...
                                    'input_to_statechange', {'Tup', 'lin_water', 'Lout', 'premature_correct_lout'});

                                % Premature correct left poke out
                                sma = add_state(sma, 'name', 'premature_correct_lout', ...
                                    'self_timer', 0.001, 'input_to_statechange', {'Tup', 'final_state'});

                                % Deliver water left
                                sma = add_state(sma, 'name', 'lin_water', 'output_actions', {'DOut', left1water}, ...
                                    'self_timer', value(lValve), 'input_to_statechange', ...
                                    {'Tup', 'final_state', 'Lout', 'final_state'});    

                                % Right poke in
                                sma = add_state(sma, 'name', 'right_poke_in_error', ...
                                    'self_timer', (value(waitingTimeRew)), 'input_to_statechange', {'Tup', 'rin_no_water', 'Rout', 'premature_error_rout'});

                                % Premature error right poke out
                                sma = add_state(sma, 'name', 'premature_error_rout', ...
                                    'self_timer', 0.001, 'input_to_statechange', {'Tup', 'rin_no_water'});

                                % No water right
                                sma = add_state(sma, 'name', 'rin_no_water', ...
                                    'output_actions', {'SoundOut', value(IdWaterTone)}, ...
                                    'self_timer', value(rValve), ...
                                    'input_to_statechange', {'Tup', 'error_ITI', 'Rout', 'error_ITI'});

                                % Error ITI
                                sma = add_state(sma, 'name', 'error_ITI', ...
                                    'self_timer', value(timeOutPenalty) - value(rValve), 'input_to_statechange', {'Tup', 'final_state'});

                                % Final state
                                sma = add_state(sma, 'name', 'final_state', ...
                                    'self_timer', value(ITI) - value(lValve), 'input_to_statechange', {'Tup', 'check_next_trial_ready'});


                                % Virtual left_poke_in_error'
                                sma = add_state(sma, 'name', 'left_poke_in_error');

                                % Virtual right_poke_in_correct
                                sma = add_state(sma, 'name', 'right_poke_in_correct');

                                % Virtual premature_error_lout'
                                sma = add_state(sma, 'name', 'premature_error_lout');

                                % Virtual premature_correct_rout
                                sma = add_state(sma, 'name', 'premature_correct_rout');

                                % Virtual rin_water
                                sma = add_state(sma, 'name', 'rin_water');

                                % Virtual lin_no_water
                                sma = add_state(sma, 'name', 'lin_no_water');


                            elseif (value(currentOdor(1,n_started_trials + 1)) == 1 || ...
                                value(currentOdor(1,n_started_trials + 1)) == 3) == 1, % right - correct for stim1

                                sma = add_state(sma, 'name', 'waiting_for_both_pokes',...
                                    'input_to_statechange',{'Rin', 'right_poke_in_correct', ...
                                    'Lin', 'left_poke_in_error', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_In', 'waiting_for_both_pokes_water'});

                                sma= add_state(sma,'name', 'waiting_for_both_pokes_water',...
                                    'input_to_statechange', {'Rin', 'right_poke_in_correct_water', ...
                                    'Lin', 'left_poke_in_error_water', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'too_late'});
                                
                                sma = add_state(sma, 'name', 'right_poke_in_correct_water', 'self_timer', 0.001, ...
                                    'input_to_statechange', {'Tup', 'rin_water'});
                                
                                sma = add_state(sma, 'name', 'left_poke_in_correct_water', 'self_timer', 0.001, ...
                                    'input_to_statechange', {'Tup', 'lin_no_water'});

                                sma = add_state(sma, 'name', 'too_late', 'self_timer', 0.001, ...
                                    'input_to_statechange', {'Tup', 'final_state'});

                                sma = add_state(sma, 'name', 'right_poke_in_correct',... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'rin_water', ...
                                    'Rout', 'waiting_for_both_pokes'});

                                sma = add_state(sma, 'name', 'left_poke_in_error', ... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'lin_no_water',...
                                    'Lout', 'waiting_for_both_pokes_error'});
                                
                                sma = add_state(sma, 'name', 'waiting_for_both_pokes_error', ... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'lin_no_water',...
                                    'Lin', 'left_poke_in_error', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                                
                                sma = add_state(sma, 'name', 'rin_water', 'self_timer', value(rValve), ...
                                    'output_actions', {'DOut', right1water},...
                                    'input_to_statechange', {'Tup', 'inter_trial',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                            
                                sma = add_state(sma, 'name', 'lin_no_water', ...
                                    'output_actions', {'SoundOut', value(IdWaterTone)}, ...
                                    'input_to_statechange', {'Tup', 'inter_trial',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                                
                                % Virtual right poke in correct
                                sma = add_state(sma, 'name', 'left_poke_in_correct');
                                
                                % Virtual left poke in error
                                sma = add_state(sma, 'name', 'right_poke_in_error');
                                
                                % Virtual premature_error_lout'
                                sma = add_state(sma, 'name', 'premature_error_rout');

                                % Virtual premature_correct_rout
                                sma = add_state(sma, 'name', 'premature_correct_lout');
                                
                                % Virtual no water left
                                sma = add_state(sma, 'name', 'rin_no_water');
                                
                                % Virtual water right
                                sma = add_state(sma, 'name', 'lin_water');

                            end
                        end
                        
                        
                        
                    case 'Low_Urgency'
                        
                        sma = add_state(sma, 'name', 'center_poke_in',...
                            'output_actions',{'SchedWaveTrig','CNT_DELAY_SW'},...
                            'input_to_statechange', {'CNT_DELAY_SW_In','cin_odor_min',...
                            'Cout','early_cout'});

                        sma = add_state(sma, 'name', 'early_cout', ... 
                            'output_actions', {'SchedWaveTrig','CNT_JITTER_SW'},...
                            'input_to_statechange', {'CNT_JITTER_SW_In', 'premature_cout', ...
                            'Cin','center_poke_in_2',...
                            'CNT_DELAY_SW_In', 'cnt_jitter_go_signal_prevention'});

                        sma= add_state(sma,'name','center_poke_in_2',...
                            'output_actions', {'SchedWaveTrig','-CNT_JITTER_SW '},...
                            'input_to_statechange',{'CNT_DELAY_SW_In','cin_odor_min',...
                            'Cout','early_cout'});

                        sma = add_state(sma, 'name', 'cnt_jitter_go_signal_prevention', ...
                            'input_to_statechange', {'CNT_JITTER_SW_In', 'premature_cout',...
                            'Cin','cin_odor_min'});

                        sma = add_state(sma, 'name', 'premature_cout', 'self_timer', 0.001, ...
                            'output_actions',{'SchedWaveTrig','RWD_DELAY_INTER_TRIAL_SW'},...
                            'input_to_statechange', {'Tup', 'inter_trial'});
                        
                        % Center odor delivery _ minimum
                        sma = add_state(sma, 'name', 'cin_odor_min', ...
                            'output_actions', {'SchedWaveTrig','GO_SIGNAL_SW+RWD_DELAY_INTER_TRIAL_SW', ...
                            value(OlfBank), value(valveNumber)}, ...
                            'input_to_statechange', {'GO_SIGNAL_SW_Out', 'go_signal', ...
                            'Cout','premature_cout_go_signal'});
                                                      
                        % Go-signal
                        sma = add_state(sma, 'name', 'go_signal', 'output_actions', {value(OlfBank), value(valveNumber)}, ...
                            'self_timer', 0.001, ...        
                            'input_to_statechange', {'Tup', 'cin_odor_after_go_signal', ...
                            'Cout', 'cin_odor_after_go_signal'});
                        
                        % Center odor delivery _ after go-signal
                        sma = add_state(sma, 'name', 'cin_odor_after_go_signal', ...
                            'self_timer', value(odorDeliveryMax) - value(SoundDur), ...
                            'output_actions', {value(OlfBank), value(valveNumber)}, ...
                            'input_to_statechange', {'Cout', 'waiting_for_both_pokes', ...
                            'Tup', 'waiting_for_both_pokes', ...
                            'RWD_DELAY_INTER_TRIAL_SW_In','waiting_for_both_pokes_water',...
                            'RWD_DELAY_INTER_TRIAL_SW_Out','too_late'});
                                                                                                                        
                        % Premature cout go signal
                        sma = add_state(sma, 'name', 'premature_cout_go_signal', 'self_timer', 0.001, ...
                            'input_to_statechange', {'Tup', 'final_state'});
                        
                        
                        if strcmp (value(stim1Side), 'Left') == 1
                            
                            if (value(currentOdor(1,n_started_trials + 1)) == 1 || ...
                                value(currentOdor(1,n_started_trials + 1)) == 3) == 1, % left - correct for stim1
                            
                                sma = add_state(sma, 'name', 'waiting_for_both_pokes',...
                                    'input_to_statechange',{'Lin', 'left_poke_in_correct', ...
                                    'Rin', 'right_poke_in_error', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_In', 'waiting_for_both_pokes_water'});

                                sma= add_state(sma,'name', 'waiting_for_both_pokes_water',...
                                    'input_to_statechange', {'Lin', 'left_poke_in_correct_water', ...
                                    'Rin', 'right_poke_in_error_water', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'too_late'});
                                
                                sma = add_state(sma, 'name', 'left_poke_in_correct_water', 'self_timer', 0.001, ...
                                    'input_to_statechange', {'Tup', 'lin_water'});
                                
                                sma = add_state(sma, 'name', 'right_poke_in_error_water', 'self_timer', 0.001, ...
                                    'input_to_statechange', {'Tup', 'rin_no_water'});

                                sma = add_state(sma, 'name', 'too_late', 'self_timer', 0.001, ...
                                    'input_to_statechange', {'Tup', 'final_state'});

                                sma = add_state(sma, 'name', 'left_poke_in_correct',... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'lin_water', ...
                                    'Lout', 'waiting_for_both_pokes'});

                                sma = add_state(sma, 'name', 'right_poke_in_error', ... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'rin_no_water',...
                                    'Rout', 'waiting_for_both_pokes_error'});
                                
                                sma = add_state(sma, 'name', 'waiting_for_both_pokes_error', ... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'rin_no_water',...
                                    'Rin', 'right_poke_in_error', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                                
                                sma = add_state(sma, 'name', 'lin_water', 'self_timer', value(lValve), ...
                                    'output_actions', {'DOut', left1water},...
                                    'input_to_statechange', {'Tup', 'inter_trial',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                            
                                sma = add_state(sma, 'name', 'rin_no_water', ...
                                    'output_actions', {'SoundOut', value(IdWaterTone)}, ...
                                    'input_to_statechange', {'Tup', 'inter_trial',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                                
                                % Virtual right poke in correct
                                sma = add_state(sma, 'name', 'right_poke_in_correct');
                                
                                % Virtual left poke in error
                                sma = add_state(sma, 'name', 'left_poke_in_error');
                                
                                % Virtual premature_error_lout'
                                sma = add_state(sma, 'name', 'premature_error_lout');

                                % Virtual premature_correct_rout
                                sma = add_state(sma, 'name', 'premature_correct_rout');
                                
                                % Virtual no water left
                                sma = add_state(sma, 'name', 'lin_no_water');
                                
                                % Virtual water right
                                sma = add_state(sma, 'name', 'rin_water');
                            
                           elseif (value(currentOdor(1,n_started_trials + 1)) == 2 || ...
                                value(currentOdor(1,n_started_trials + 1)) == 4) == 1, % right - correct for stim2
                            
                                sma = add_state(sma, 'name', 'waiting_for_both_pokes',...
                                    'input_to_statechange',{'Rin', 'right_poke_in_correct', ...
                                    'Lin', 'left_poke_in_error', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_In', 'waiting_for_both_pokes_water'});

                                sma= add_state(sma,'name', 'waiting_for_both_pokes_water',...
                                    'input_to_statechange', {'Rin', 'right_poke_in_correct_water', ...
                                    'Lin', 'left_poke_in_error_water', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'too_late'});
                                
                                sma = add_state(sma, 'name', 'right_poke_in_correct_water', 'self_timer', 0.001, ...
                                    'input_to_statechange', {'Tup', 'rin_water'});
                                
                                sma = add_state(sma, 'name', 'left_poke_in_error_water', 'self_timer', 0.001, ...
                                    'input_to_statechange', {'Tup', 'lin_no_water'});

                                sma = add_state(sma, 'name', 'too_late', 'self_timer', 0.001, ...
                                    'input_to_statechange', {'Tup', 'final_state'});

                                sma = add_state(sma, 'name', 'right_poke_in_correct',... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'rin_water', ...
                                    'Rout', 'waiting_for_both_pokes'});

                                sma = add_state(sma, 'name', 'left_poke_in_error', ... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'lin_no_water',...
                                    'Lout', 'waiting_for_both_pokes_error'});
                                
                                sma = add_state(sma, 'name', 'waiting_for_both_pokes_error', ... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'lin_no_water',...
                                    'Lin', 'left_poke_in_error', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                                
                                sma = add_state(sma, 'name', 'rin_water', 'self_timer', value(rValve), ...
                                    'output_actions', {'DOut', right1water},...
                                    'input_to_statechange', {'Tup', 'inter_trial',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                            
                                sma = add_state(sma, 'name', 'lin_no_water', ...
                                    'output_actions', {'SoundOut', value(IdWaterTone)}, ...
                                    'input_to_statechange', {'Tup', 'inter_trial',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                                
                                % Virtual right poke in correct
                                sma = add_state(sma, 'name', 'left_poke_in_correct');
                                
                                % Virtual left poke in error
                                sma = add_state(sma, 'name', 'right_poke_in_error');
                                
                                % Virtual premature_error_lout'
                                sma = add_state(sma, 'name', 'premature_error_rout');

                                % Virtual premature_correct_rout
                                sma = add_state(sma, 'name', 'premature_correct_lout');
                                
                                % Virtual no water left
                                sma = add_state(sma, 'name', 'rin_no_water');
                                
                                % Virtual water right
                                sma = add_state(sma, 'name', 'lin_water');
                                
                            end
                            
                            
                        elseif strcmp (value(stim1Side), 'Right') == 1
                            
                            if (value(currentOdor(1,n_started_trials + 1)) == 2 || ...
                                value(currentOdor(1,n_started_trials + 1)) == 4) == 1, % left - correct for stim2
                            
                                sma = add_state(sma, 'name', 'waiting_for_both_pokes',...
                                    'input_to_statechange',{'Lin', 'left_poke_in_correct', ...
                                    'Rin', 'right_poke_in_error', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_In', 'waiting_for_both_pokes_water',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'too_late'});

                                sma= add_state(sma,'name', 'waiting_for_both_pokes_water',...
                                    'input_to_statechange', {'Lin', 'left_poke_in_correct', ...
                                    'Rin', 'right_poke_in_error',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'too_late'});

                                sma = add_state(sma, 'name', 'too_late', 'self_timer', 0.001, ...
                                    'input_to_statechange', {'Tup', 'final_state'});

                                sma = add_state(sma, 'name', 'left_poke_in_correct',... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'lin_water', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'too_late', 'Lout', 'waiting_for_both_pokes'});

                                sma = add_state(sma, 'name', 'right_poke_in_error', ... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'rin_no_water',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                                
                                sma = add_state(sma, 'name', 'lin_water', 'self_timer', value(lValve), ...
                                    'output_actions', {'DOut', left1water},...
                                    'input_to_statechange', {'Tup', 'inter_trial',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                            
                                sma = add_state(sma, 'name', 'rin_no_water', ...
                                    'output_actions', {'SoundOut', value(IdWaterTone)}, ...
                                    'input_to_statechange', {'Tup', 'inter_trial',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                                
                                % Virtual right poke in correct
                                sma = add_state(sma, 'name', 'right_poke_in_correct');
                                
                                % Virtual left poke in error
                                sma = add_state(sma, 'name', 'left_poke_in_error');
                                
                                % Virtual premature_error_lout'
                                sma = add_state(sma, 'name', 'premature_error_lout');

                                % Virtual premature_correct_rout
                                sma = add_state(sma, 'name', 'premature_correct_rout');
                                
                                % Virtual no water left
                                sma = add_state(sma, 'name', 'lin_no_water');
                                
                                % Virtual water right
                                sma = add_state(sma, 'name', 'rin_water');
                            
                           elseif (value(currentOdor(1,n_started_trials + 1)) == 1 || ...
                                value(currentOdor(1,n_started_trials + 1)) == 3) == 1, % right - correct for stim1
                            
                                sma = add_state(sma, 'name', 'waiting_for_both_pokes',...
                                    'input_to_statechange',{'Rin', 'right_poke_in_correct', ...
                                    'Lin', 'left_poke_in_error', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_In', 'waiting_for_both_pokes_water',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'too_late'});

                                sma= add_state(sma,'name', 'waiting_for_both_pokes_water',...
                                    'input_to_statechange', {'Rin', 'right_poke_in_correct', ...
                                    'Lin', 'left_poke_in_error',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'too_late'});

                                sma = add_state(sma, 'name', 'too_late', 'self_timer', 0.001, ...
                                    'input_to_statechange', {'Tup', 'final_state'});

                                sma = add_state(sma, 'name', 'right_poke_in_correct',... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'rin_water', ...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'too_late', 'Rout', 'waiting_for_both_pokes'});

                                sma = add_state(sma, 'name', 'left_poke_in_error', ... 
                                    'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_In', 'lin_no_water',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                                
                                sma = add_state(sma, 'name', 'rin_water', 'self_timer', value(rValve), ...
                                    'output_actions', {'DOut', right1water},...
                                    'input_to_statechange', {'Tup', 'inter_trial',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                            
                                sma = add_state(sma, 'name', 'lin_no_water', ...
                                    'output_actions', {'SoundOut', value(IdWaterTone)}, ...
                                    'input_to_statechange', {'Tup', 'inter_trial',...
                                    'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                                
                                % Virtual left poke in correct
                                sma = add_state(sma, 'name', 'left_poke_in_correct');
                                
                                % Virtual right poke in error
                                sma = add_state(sma, 'name', 'right_poke_in_error');
                                
                                % Virtual premature_correct_lout'
                                sma = add_state(sma, 'name', 'premature_correct_lout');

                                % Virtual premature_error_rout
                                sma = add_state(sma, 'name', 'premature_error_rout');
                                
                                % Virtual no water right
                                sma = add_state(sma, 'name', 'rin_no_water');
                                
                                % Virtual water left
                                sma = add_state(sma, 'name', 'lin_water');
                                
                            end
                            
                        end
                        
                           
                            sma = add_state(sma, 'name', 'inter_trial', ...
                            'input_to_statechange', {'RWD_DELAY_INTER_TRIAL_SW_Out', 'final_state'});
                        
                            
                            % Final state
                            sma = add_state(sma, 'name', 'final_state', ...
                                'self_timer', 0.001, 'input_to_statechange', ...
                                {'Tup', 'check_next_trial_ready'});

                end
          
          
        

    % MANDATORY LINE:
    %   dispatcher('send_assembler', sma, ...
    %   optional cell_array of strings specifying the prepare_next_trial
    %   states);
    dispatcher('send_assembler', sma, 'final_state');
%     dispatcher('send_assembler', sma);
    
    
 
  case 'reinit',

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');
    
  otherwise,
    warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action);
    
    
  
        
end %%% SWITCH action