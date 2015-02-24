% [sma] = add_input(sma, 'name', 'MyInputActionName', 'input_line', 4)
%
% Adds a new possible input event to the state machine.  
% The default input events are:
%
% 'Cin'  with input line +1 (edge-up on AI input channel 1)
% 'Cout' with input line -1 (edge-down on AI input channel 1)
% 'Lin'  with input line +2 (edge-up on AI input channel 2)
% 'Lout' with input line -2 (edge-down on AI input channel 2)
% 'Rin'  with input line +3 (edge-up on AI input channel 3)
% 'Rout' with input line -3 (edge-down on AI input channel 3)
% 
% RETURNS: 
% --------
%
% sma      The updated State Machine Assembler object, after the input has
%          been added.
%
% PARAMETERS:
% -----------
%
% sma      The instantiation of the StateMachineAssembler object to which
%          the input will be added.
%
% OPTIONAL PARAMETERS:
% ---------------------
%
% name      A string that will be the name of the new input line. Use this
%           name when calling add_state and defining input_actions for the 
%           state. 
%           If this name already exists in this sma, an error will be thrown.
%
% input_line  A number that is either positive, negative, or 0.  This 
%             number indicates which analog input channel on the DAQ card 
%             to monitor for events. 
%             A zero indicates no channel is monitored and this is a 'dummy' 
%             event.  
%             A positive value means the channel id is monitored for 'edge
%             up' threshold crossings.
%             A negative value means the channel id is monitored for 'edge
%             down' threshold crossings.
%
%
% EXAMPLES:
% ----------
%
% >> sma = add_input(sma, 'name', 'line4Up',  'input_line', +4);
%
%       Registers a new input called 'line4up' that will fire whenever AI
%       channel 4 on the DAQ card has a positive (edge-up) threshold
%       crossing.
%
%          Later, to use such an input, you might add a state in which it 
%          can lead to a transition:
%          >> sma = add_state('input_to_statechange', {'line4Up', ...
%                     'state_to_jump_to_when_line4Up_happens'});
%
% The default configuration of a new StateMachineAssembler object is as if
% the following calls were made to the assembler:
%
% >> sma = add_input(sma, 'name', 'Cin',  'input_line', +1);
% >> sma = add_input(sma, 'name', 'Cout', 'input_line', -1);
% >> sma = add_input(sma, 'name', 'Rin',  'input_line', +2);
% >> sma = add_input(sma, 'name', 'Rout', 'input_line', -2);
% >> sma = add_input(sma, 'name', 'Lin',  'input_line', +3);
% >> sma = add_input(sma, 'name', 'Lout', 'input_line', -3);

% Written by Calin Culianu <cculianu@yahoo.com> January 2008

function [sma] = add_input(sma, varargin)
   
   pairs = { ...
     'name'               []    ;  ...
     'input_line'          []   ;  ...
   }; parseargs(varargin, pairs);

   if isempty(name) | ~ischar(name),
       error('Need to specify a "name" argument string to add_input.');
   end;
   if isempty(input_line) | ~isscalar(input_line),
       error('Need to specify an "input_line" scalar integer to add_input.');
   end;
   
   
   % --- BEGIN error-checking ---
   u = find(strcmp(name, sma.input_line_map(:,1)));
   if ~isempty(u),
      error(['Input line named "' name '" already exists!']);
   end;
   
   % Make sure that we aren't using more han 6 unique channels as the FSM
   % gets slow and unstable with too many inputs   
   uniq_nonzero_chans = find(unique(abs(cell2mat(sma.input_line_map(:,2)))));
   if length(uniq_nonzero_chans)+1 > 6,
       warning(sprintf('FIXME: YOU HAVE MORE THAN 6 AI INPUT CHANNELS SPECIFIED FOR THIS STATE MACHINE!\nTHIS IS LIABLE TO MAKE THE STATE MACHINE SLOW AND UNRELIABLE!\nPLEASE CHANGE YOUR PROTOCOL!!\n-Calin')); 
   end;
   if abs(input_line) > 16,
       warning('SPECIFIED AN DAQ CHANNEL >16 TO ADD_INPUT -- CHANCES ARE THIS IS AN ERROR!');
   end;
   % --- END error-checking ---
    
   % We'll add columns for the input line
   % and we'll put them right before the Tup:
   thecol = length(sma.input_line_map)+1;
   Tup = find(strcmp('Tup', sma.input_map(:,1)));
   if (Tup ~= thecol) | (max(cell2mat(sma.input_map(:,2))) ~= thecol),
       error('INCONSISTENT STATE -- TUP COLUMN SHOULD BE THERE AND SHOULD BE THE LAST COLUMN!');
   end;
   % make space for the two new cols and move everything after and
   % including Tup forwards by two columns:
   sma.states = [sma.states cell(rows(sma.states),1)];
   sma.states(:,thecol+1:end) = sma.states(:,thecol:end-1);
   sma.states(:,thecol)  = sma.default_actions;
   % repeat for iti_states:
   sma.iti_states = [sma.iti_states cell(rows(sma.iti_states),1)];
   sma.iti_states(:,thecol+1:end) = sma.iti_states(:,thecol:end-1);
   sma.iti_states(:,thecol)  = sma.default_iti_actions;
   
   % Now add our new entry the input map:
   sma.input_map = [sma.input_map(1:thecol-1,:) ; ...
                    {name,  thecol} ; ...
                    sma.input_map(thecol:end,:)];
   % Now add our new input line map entry..
   sma.input_line_map = [sma.input_line_map(1:thecol-1,:) ; ...
                         {name,  input_line } ; ...
                         sma.input_line_map(thecol:end,:)];
                     
   % And adjust the Tup entry in the input map:
   Tup = Tup + 1;
   sma.input_map{Tup,2} = sma.input_map{Tup,2} + 1;

   % As well as adjusting the self_timer map:
   for i=1:rows(sma.self_timer_map),
      sma.self_timer_map{i,2} = sma.self_timer_map{i,2}+1;
   end;
   
   % And the output map:
   for i=1:rows(sma.output_map),
      sma.output_map{i,2} = sma.output_map{i,2} + 1;
   end;
   
   
   