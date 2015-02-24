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

% global state_machine_server;
% global P; P = 1;
% global PIDScans;

switch action

  case 'init',
      
%       SoloParamHandle(obj, 'PIDScans');
%       SoloParamHandle(obj, 'data');
%       data.value = zeros(
      
%       SoloFunctionAddVars('PlotSection', 'rw_args', ...
%         {'data'});

      StateMatrixSection(obj, 'next_trial');

      
  case 'next_trial',
    %Declare != state matrixs here!! if something, this sma, if something else
    %then this other, if even somthing else, use this sma, while somthing, for
    %something, etc etc etc you get the pic.
        sma = StateMachineAssembler('full_trial_structure');
        
        
%     if n_done_trials == 0,
%         return,
%     end;

    % If using scheduled waves, they have to be declared here, before the
    % states
    % IMPORTANT: the first state declared is state_0.
    % Default inputs: Lin: left line in; Lout: left line out; Rin, Rout;
    % Cin; Cout; Tup;
    
%-------------------------------------------------------------------------%    
  
% P.S. the first state is by default:
% sma = add_state(sma, 'default_statechange', 'Waiting_4_Cin',
% 'self_timer', 0.001);

%-------------------------------------------------------------------------%\
%         sma = add_olf_bank(sma, 'name', 'OlfBankH', 'ip',...
%             value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_H_ID))]);
%         sma = add_olf_bank(sma, 'name', 'OlfBankG', 'ip',...
%             value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_G_ID))]);
        sma = add_olf_bank(sma, 'name', 'OlfBankF', 'ip',...
            value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_F_ID))]);
%         sma = add_olf_bank(sma, 'name', 'OlfBankE', 'ip',...
%             value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_E_ID))]);
%         sma = add_olf_bank(sma, 'name', 'OlfBankD', 'ip',...
%             value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_D_ID))]);
%         sma = add_olf_bank(sma, 'name', 'OlfBankC', 'ip',...
%             value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_C_ID))]);
        sma = add_olf_bank(sma, 'name', 'OlfBankB', 'ip',...
            value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_B_ID))]);
%         sma = add_olf_bank(sma, 'name', 'OlfBankA', 'ip',...
%             value(OLF_IP), 'bank', ['Bank' num2str(value(olf_bank_A_ID))]);
%-------------------------------------------------------------------------%



            % Start DAQ period
%             sma = add_state(sma,'name','predaq','self_timer',0.001,...
%                 'input_to_statechange',{'Tup','pre_odor'});
%             sm = RTLSM2(state_machine_server);
%             sm = StartDAQ(sm,P);
                   
            
            % Pre-odor
            sma = add_state(sma, 'name', 'pre_odor', 'self_timer', value(preOdor), ... 'output_actions', {value(OlfBank), value(baseValveNumber)},...
                'input_to_statechange', {'Tup', 'odor_delivery'});
            
            
            % Odor delivery
            sma = add_state(sma, 'name', 'odor_delivery', 'output_actions', {value(OlfBank), value(valveNumber)}, ...
                        'self_timer', value(odorDelivery),...
                        'input_to_statechange', {'Tup', 'post_odor'}); ..., 'Tup', 'go_signal'});
                    
            % Post-odor
            sma = add_state(sma, 'name', 'post_odor', ... 'output_actions', {value(OlfBank), value(baseValveNumber)}, ...
                'self_timer', value(postOdor), 'input_to_statechange', {'Tup', 'final_state'});
                    
            % Final state
            sma = add_state(sma, 'name', 'final_state', ... 'output_actions', {value(OlfBank), value(baseValveNumber)}, ...
                 'self_timer', value(timeOut), 'input_to_statechange', {'Tup', 'check_next_trial_ready'});        
            
%         data.value = GetDAQScans(sm);
% %         PIDScans.value = [value(PIDScans); value(data)];
%         sm = StopDAQ(sm);
%         disp(value(data));
        
        
             
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