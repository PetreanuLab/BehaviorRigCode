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


function  [] =  StateMatrixSection(obj, action)

global left1led;
global center1led;
global right1led;
global center1valve;


GetSoloFunctionArgs;


switch action
  case 'init',
    StateMatrixSection(obj, 'next_trial');
    
  case 'next_trial',
  
   LaserControlSection(obj,'prepare_next_trial');   
      
   sma = StateMachineAssembler('full_trial_structure');
    
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %SW to shine the laser on the mouse: opens AOM (something like that)
   sma = add_scheduled_wave(sma,'name','inhibition_pulse',...
            'preamble', value(response_delay),'sustain',value(pulseDuration),...
            'DOut',center1valve);

    %Digital SW to serve as preamble to the analog waves. 
   sma = add_scheduled_wave(sma, 'name', 'preamble_wave',...
            'preamble', value(response_delay)-0.001, 'trigger_on_up', 'sw_chn1+sw_chn2');     
   
   axisSwitch1=[1 2]; %vectors responsible for switching axis - change 
   axisSwitch2=[2 1];              %channel to which each AO sign is sent
           
        %Analog Scheduled Waves - rotate the mirrors!
   sma = add_scheduled_wave(sma, 'name', 'sw_chn1', 'is_ao', 1, 'AOut', axisSwitch1(value(switch_xy)+1),...
            'two_by_n_matrix', value(AOMatrix1));
   sma = add_scheduled_wave(sma, 'name', 'sw_chn2', 'is_ao', 1, 'AOut', axisSwitch2(value(switch_xy)+1),...
            'two_by_n_matrix', value(AOMatrix2));
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
        
        
%   Machine State
   sma = add_state(sma, 'name', 'begin','self_timer',value(response_delay), ...
            'input_to_statechange', {'Tup', 'final_state'});
    
   if value(noStim)==0
       sma = add_state(sma ,'name', 'final_state','self_timer',5,...
              'input_to_statechange', {'Tup', 'check_next_trial_ready'},...
              'output_actions',{'SchedWaveTrig','preamble_wave+inhibition_pulse'});
   else
       sma = add_state(sma, 'name', 'final_state', 'self_timer', 1,...  
            'input_to_statechange', {'Tup', 'last'}); 
       sma = add_state(sma, 'name', 'last','self_timer',value(response_delay), ...   %waiting to start next trial
            'input_to_statechange', {'Tup', 'check_next_trial_ready'},...   
            'output_actions',{'DOut',left1led+center1led+right1led});
   end;
   
  
 
   dispatcher('send_assembler', sma, {'begin'});
    
    
  case 'reinit',

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');
    
  otherwise,
    warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action);
end;

   
      