% [sma] = add_olf_bank(sma, {'name', 'MyOlf', 'ip', '10.10.100.100', 'bank', 'Bank1'})
%
% Add an olfactometer bank to the list of olfactometers registered with the sma State
% Machine assembler object. Returns the updated sma object.
%
% Each call to this function will append an additional output column to the state
% matrix that is sent to the state machine.  The column values correspond
% to the valve to open for that bank. 
%
% For an introduction to what the olfactometer is and how it's controlled from BControl,
% email Calin Culianu: <calin@ajvar.org> or <cculianu@yahoo.com>. 
%
% 
% RETURNS: 
% --------
%
% sma      The updated State Machine Assembler object, after the olfactometer column has been added.
%
% PARAMETERS:
% -----------
%
% sma      The instantiation of the StateMachineAssembler object to which
%          the scheduled wave will be added.
%
% name     REQUIRED - the name of the olfactometer.  Use this when calling
%          add_state
%
% ip       The IP address of the olfactometer in question.  This should be in standard decimal number-and-dots 
%          notation eg 10.10.100.123, etc.
%
% bank     The bank name.  The bank name is really specified by the olfactometer.ini file INSIDE the olfactometer.
%          The names are typically something like 'Bank1' or 'Bank2', or
%          'Bank3', etc.
%
%
% EXAMPLES:
% ----------
%
% >> sma = add_olf_bank(sma, 'ip', '10.10.100.123',  'bank', 'Bank1');
%
%       Registers an olfactometer with IP 10.10.100.123 to be sent the SET
%       BANK ODOR command on Bank1.  The actual bank odor value sent
%       depends on the state matrix column.
%
function [sma, sched_wave_name] = add_olf_bank(sma, varargin)
   
   pairs = { ...
     'name'             '' ; ...
     'ip'               ''    ;  ...
     'bank'            ''    ;  ...
   }; parseargs(varargin, pairs);

   if ~isempty(find(strcmp(name, sma.output_map(:,1)))),
       error(['And olf bank named ' name ' already exists.']);
   end;
%    % --- BEGIN error-checking ---
%    Tup = find(strcmp('Tup', sma.input_map(:,1)));
%    if isempty(Tup),
%       error('Huh??? input map has no Tup entry?');
%    end;
%       
%    [prev_names{1:length(sma.sched_waves)}] = deal(sma.sched_waves.name);
%    if ~isempty(find(strcmp(sched_wave_name, prev_names))),
%       error(['A scheduled wave with name ' sched_wave_name ' already ' ...
%              'exists.']);
%    end;   
%    % --- END error-checking ---
%    
   if isempty(name),
       error('Required parameter missing: ''name ''.  Olfactometer needs a name!');
   end;
   if isempty(ip),
       error('Required parameter missing: ''ip''. Olfactometer needs an IP address!');
   end;
   if isempty(bank),
       error('Required parameter missing: ''bank''. Olfactometer needs a bank name!');
   end;
   
   % We'll add the column at the end
   [len_output_map, dummy] = size(sma.output_map);
   col = max([sma.output_map{:, 2}]) + 1; % determine the last col
   out_name = name; % internally we refer to it simply as the olf name
   sma.output_map(len_output_map+1, :) = { out_name, col };
   % Now add our olf bookkeeping
   [n_olfs, dummy] = size(sma.olfs);
   n_olfs = n_olfs + 1;
   sma.olfs(n_olfs, :) = { name ip bank };
      % --- create a column 
      if ~isempty(sma.states),         
         sma.states = [sma.states num2cell(zeros(rows(sma.states),1))];
      else
         sma.states = cell(0, cols(sma.states)+1);
      end;
      % repeat for iti_states:
      if ~isempty(sma.iti_states),         
         sma.iti_states = [sma.iti_states num2cell(zeros(rows(sma.iti_states),1))];
      else
         sma.iti_states = cell(0, cols(sma.iti_states)+1);
      end;
  