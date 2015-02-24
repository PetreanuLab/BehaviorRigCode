% [sma] = modify_input(sma, 'name', 'MyInputActionName', 'input_line', 4)
%
% Modifies the physical AI line that an input is associated with.
% 
% RETURNS: 
% --------
%
% sma      The updated State Machine Assembler object, after the input has
%          been modified.
%
% PARAMETERS:
% -----------
%
% sma      The instantiation of the StateMachineAssembler object to which
%          the input modification will be made.
%
% OPTIONAL PARAMETERS:
% ---------------------
%
% name      A string that is the name of an existing input line.   
%           This is the same name that was passed to add_input.m when 
%           the input was originally reated.
%
%           If this name does not exist in this sma, an error will be thrown.
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
% >> sma = add_input(sma, 'name', 'lineUp',  'input_line', +4);
%
%       Registers a new input called 'lineUp' that will fire whenever AI
%       channel 4 on the DAQ card has a positive (edge-up) threshold
%       crossing.
%
%
%       Later, modify_input can be called to change the line from AI 4 to
%       AI 5.
%
% >> sma = modify_input(sma, 'name', 'lineUp', 'input_line', +5);
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
%
% As such, modify_input can be called with any of 'Cin',
% 'Cout', 'Lin', 'Lout', 'Rin' and 'Rout' to any StateMachineAssembler
% object.

% Written by Calin Culianu <cculianu@yahoo.com> January 2008

function [sma] = modify_input(sma, varargin)

  pairs = { ...
     'name'               []    ;  ...
     'input_line'          []   ;  ...
   }; parseargs(varargin, pairs);

   if isempty(name) | ~ischar(name),
       error('Need to specify a "name" argument string to modify_input.');
   end;
   if isempty(input_line) | ~isscalar(input_line),
       error('Need to specify an "input_line" scalar integer to modify_input.');
   end;
   
   
   % --- BEGIN error-checking ---
%    u = find(strcmp(name, sma.input_line_map(:,1)));
   u = find(strcmp(name, sma.input_map(:,1)));
   if isempty(u),
      error(['Input line named "' name '" does not exist!']);
   end;
   
   % Make sure that we aren't using more han 6 unique channels as the FSM
   % gets slow and unstable with too many inputs   
%    uniq_nonzero_chans = find(unique(abs(cell2mat(sma.input_line_map(:,2)))));
   uniq_nonzero_chans = find(unique(abs(cell2mat(sma.input_map(:,2)))));
   if length(uniq_nonzero_chans)+1 > 6,
       warning(sprintf('FIXME: YOU HAVE MORE THAN 6 AI INPUT CHANNELS SPECIFIED FOR THIS STATE MACHINE!\nTHIS IS LIABLE TO MAKE THE STATE MACHINE SLOW AND UNRELIABLE!\nPLEASE CHANGE YOUR PROTOCOL!!\n-Calin')); 
   end;
   if abs(input_line) > 16,
       warning('SPECIFIED AN DAQ CHANNEL >16 TO MODIFY_INPUT -- CHANCES ARE THIS IS AN ERROR!');
   end;
   % --- END error-checking ---
    
   % now, just specify a new channel id to use
%    sma.input_line_map{u, 2} = input_line;
    sma.input_map{u, 2} = input_line;
      
   % And.. that's it!
   