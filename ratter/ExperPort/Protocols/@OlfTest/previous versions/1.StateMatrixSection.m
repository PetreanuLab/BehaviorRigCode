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

switch action

  case 'init',
      
      StateMatrixSection(obj, 'next_trial');

      
  case 'next_trial',
    %Declare != state matrixs here!! if something, this sma, if something else
    %then this other, if even somthing else, use this sma, while somthing, for
    %something, etc etc etc you get the pic.
        sma = StateMachineAssembler('full_trial_structure');

    % If using scheduled waves, they have to be declared here, before the
    % states
    % IMPORTANT: the first state declared is state_0.
    % Default inputs: Lin: left line in; Lout: left line out; Rin, Rout;
    % Cin; Cout; Tup;
    
%-------------------------------------------------------------------------%

        sma = add_olf_bank(sma, 'name', 'OlfBankA', 'ip',...
            value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_A_ID))]);
        sma = add_olf_bank(sma, 'name', 'OlfBankB', 'ip',...
            value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_B_ID))]);
        sma = add_olf_bank(sma, 'name', 'OlfBankC', 'ip',...
            value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_C_ID))]);
        sma = add_olf_bank(sma, 'name', 'OlfBankD', 'ip',...
            value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_D_ID))]);
        
%-------------------------------------------------------------------------%

  SoloParamHandle(obj, 'OlfBank');


        switch value(OdorName)      
                case {'Limonene (R)-(+)'}
                    OlfBank.value = 'OlfBankA';
                case {'Ethylacetoacetate'}
                    OlfBank.value = 'OlfBankB';
                case {'1-Propanol'}
                    OlfBank.value = 'OlfBankC';
        end
  
% Syntax of sma, sma calls the State Machine Assembler that will in our
% case add_state [it can do other things too...]. This will help you create
% states that will form your matrix on a trial basis. so; sma =
% add_state(sma, 'name', 'yourStateName', 'input_to_statechange', {'event',
% 'where_to_go_in_case_of_event', 'other_event',
% 'where_to_go_in_this_case', etc...});
% events can be Cin, Cout, Lin, Lout, Rin, Rout, Tup (see default inputs
% above), outputs or actions (see above as well) can be called by using:
% 'output_actions', {'DOut_or_AOut', number_of_DIOLINE} or as in this case
% if you define DIOLINES in the settings_custom.conf you can use whatever
% name you attribute them. You can also set a timer for each state, this is
% usefull if you want to force an event in a time frame or restart, in this
% case ('self_timer', lValve_time) the 'self_timer' call is followed by a
% var which is getting it's value from the GUI; normal syntax is
% 'self_timer', whatever_number_or_fraction_of_seconds. If the self timer
% finishes the event is called Tup which can and will poin to another
% state.
% P.S. the first state is by default:
% sma = add_state(sma, 'default_statechange', 'Waiting_4_Cin',
% 'self_timer', 0.001);


        
        valves = 5;
        valveNumber = ceil(valves * rand);
  
        switch value(ProtocolPhase)
            case {'water at the lateral pokes'}
%         if strcmpi(value(ProtocolPhase), 'water at the lateral pokes') == 1,

%             waitingTimeSet.value = NaN;
%             TrialsPerBlockSet.value = NaN;
            
            % Waiting for right or left poke
            sma = add_state(sma, 'name', 'waiting_for_both_pokes',...
                'input_to_statechange', {'Lin', 'left_poke_in_water', 'Rin', 'right_poke_in_water'});

%             % Deliver water left
%             sma = add_state(sma, 'name', 'left_poke_in_water', 'output_actions', {'DOut', left1water},...
%                 'self_timer', value(lValve), 'input_to_statechange', {'Tup', 'final_state', 'Lout', 'final_state'});    
% 
%             % Deliver water right
%             sma = add_state(sma, 'name', 'right_poke_in_water', 'output_actions', {'DOut', right1water},...
%                 'self_timer', value(rValve), 'input_to_statechange', {'Tup', 'final_state','Rout', 'final_state'});

%             % State 4: final state
%             sma = add_state(sma, 'name', 'final_state', ...
%                 'self_timer', value(timeOut), 'input_to_statechange', {'Tup', 'check_next_trial_ready'});

            case {'wait at center poke'}
%         elseif strcmp(value(ProtocolPhase), 'wait at center poke') == 1,          
                       
%             waitingTimeSet.value = 0.2;
%             TrialsPerBlockSet.value = 50;

            % Wait for center poke in
            sma = add_state(sma, 'name', 'waiting_for_cin', 'input_to_statechange', {'Cin', 'center_poke_in'});
            
            % Center poke in
            sma = add_state(sma, 'name', 'center_poke_in', 'self_timer', (value(waitingTime)), ...
                'input_to_statechange', {'Tup', 'waiting_for_both_pokes', 'Cout', 'premature_cout'});
            
            % Premature center poke out
            sma = add_state(sma, 'name', 'premature_cout', 'self_timer', 0.5, ...
                'input_to_statechange', {'Tup', 'final_state'});
            
            % Waiting for right or left poke
            sma = add_state(sma, 'name', 'waiting_for_both_pokes', 'self_timer', value(timeToGetReward),...
                'input_to_statechange', {'Lin', 'left_poke_in_water', 'Rin', 'right_poke_in_water', 'Tup', 'too_late'});

            % Too late
            sma = add_state(sma, 'name', 'too_late', 'self_timer', 0.5, ...
                'input_to_statechange', {'Tup', 'final_state'});
            
%             % Deliver water left
%             sma = add_state(sma, 'name', 'left_poke_in_water', 'output_actions', {'DOut', left1water},...
%                 'self_timer', value(lValve), 'input_to_statechange', {'Tup', 'final_state', 'Lout', 'final_state'});    
% 
%             % Deliver water right
%             sma = add_state(sma, 'name', 'right_poke_in_water', 'output_actions', {'DOut', right1water},...
%                 'self_timer', value(rValve), 'input_to_statechange', {'Tup', 'final_state','Rout', 'final_state'});

%             % State 5: final state
%             sma = add_state(sma, 'name', 'final_state', ...
%                 'self_timer', value(timeOut), 'input_to_statechange', {'Tup', 'check_next_trial_ready'});
            
            case {'olfaction'}
%         elseif strcmp(value(ProtocolPhase), 'olfaction') == 1,

%             waitingTimeSet.value = 'UnifDist';
%             TrialsPerBlockSet.value = NaN;

            % Wait for center poke in
            sma = add_state(sma, 'name', 'waiting_for_cin', 'input_to_statechange', {'Cin', 'center_poke_in'});
            
            % Center poke in
            sma = add_state(sma, 'name', 'center_poke_in', 'self_timer', (value(waitingTime)), ...
                'input_to_statechange', {'Tup', 'cin_odor', 'Cout', 'premature_cout'});
            
            % Premature center poke out
            sma = add_state(sma, 'name', 'premature_cout', 'self_timer', 0.5, ...
                'input_to_statechange', {'Tup', 'final_state'});

            % Center poke in - deliver odor
            sma = add_state(sma, 'name', 'cin_odor', 'output_actions', {value(OlfBank), valveNumber},...
                        'self_timer', value(OlfCueDuration),...
                        'input_to_statechange', {'Cout', 'waiting_for_both_pokes', 'Tup', 'waiting_for_both_pokes'});

            if valveNumber == 5 % blank
                % Waiting for right or left poke
                sma = add_state(sma, 'name', 'waiting_for_both_pokes', 'self_timer', value(timeToGetReward),...
                    'input_to_statechange', {'Lin', 'lin_water', 'Rin', 'rin_no_water', 'Tup', 'too_late'});
                
                % Too late
                sma = add_state(sma, 'name', 'too_late', 'self_timer', 0.5, ...
                    'input_to_statechange', {'Tup', 'final_state'});
                
                % Left poke in - water
                sma = add_state(sma, 'name', 'lin_water', 'output_actions', {'DOut', left1water},...
                    'self_timer', value(lValve), 'input_to_statechange', {'Tup', 'final_state', 'Lout', 'final_state'});
                
                % Right poke in - no water
                sma = add_state(sma, 'name', 'rin_no_water',...
                    'self_timer', 2, 'input_to_statechange', {'Tup', 'final_state', 'Rout', 'final_state'});
            else
                % Waiting for right or left poke
                sma = add_state(sma, 'name', 'waiting_for_both_pokes', 'self_timer', value(timeToGetReward),...
                    'input_to_statechange', {'Rin', 'rin_water', 'Lin', 'lin_no_water', 'Tup', 'too_late'});
                
                % Too late
                sma = add_state(sma, 'name', 'too_late', 'self_timer', 0.5, ...
                    'input_to_statechange', {'Tup', 'final_state'});
                
                % Right poke in - water
                sma = add_state(sma, 'name', 'rin_water', 'output_actions', {'DOut', right1water}, ...
                    'self_timer', value(rValve), 'input_to_statechange', {'Tup', 'final_state', 'Rout', 'final_state'});
                
                % Left poke in - no water
                sma = add_state(sma, 'name', 'lin_no_water',...
                    'self_timer', 2, 'input_to_statechange', {'Tup', 'final_state', 'Lout', 'final_state'});
            end
        end
        
        
        % Deliver water left
            sma = add_state(sma, 'name', 'left_poke_in_water', 'output_actions', {'DOut', left1water}, ...
                'self_timer', value(lValve), 'input_to_statechange', {'Tup', 'final_state', 'Lout', 'final_state'});    

        % Deliver water right
            sma = add_state(sma, 'name', 'right_poke_in_water', 'output_actions', {'DOut', right1water}, ...
                'self_timer', value(rValve), 'input_to_statechange', {'Tup', 'final_state', 'Rout', 'final_state'});
            
        % Final state
            sma = add_state(sma, 'name', 'final_state', ...
                    'self_timer', value(timeOut), 'input_to_statechange', {'Tup', 'check_next_trial_ready'});        
         
%     SoloFunctionAddVars('WaitingTimeSection', 'rw_args', {'waitingTimeSet', 'TrialsPerBlockSet'});                  
                
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