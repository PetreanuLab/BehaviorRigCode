function [obj] = RodMinimalv3(varargin)

% It is in the following line that you can add plugin objects:
obj = class(struct, mfilename, lasercontrol, saveload);

%---------------------------------------------------------------
%   BEGIN SECTION COMMON TO ALL PROTOCOLS, DO NOT MODIFY
%---------------------------------------------------------------

% If creating an empty object, return without further ado:
if nargin==0 || (nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty')), 
   return; 
end;

if isa(varargin{1}, mfilename), % If first arg is an object of this class itself, we are 
                                % Most likely responding to a callback from  
                                % a SoloParamHandle defined in this mfile.
  if length(varargin) < 2 || ~isstr(varargin{2}), 
    error(['If called with a "%s" object as first arg, a second arg, a ' ...
      'string specifying the action, is required\n']);
  else action = varargin{2}; varargin = varargin(3:end);
  end;
else % Ok, regular call with first param being the action string.
       action = varargin{1}; varargin = varargin(2:end);
end;
if ~isstr(action), error('The action parameter must be a string'); end;

GetSoloFunctionArgs(obj);

%---------------------------------------------------------------
%   END OF SECTION COMMON TO ALL PROTOCOLS, MODIFY AFTER THIS LINE
%---------------------------------------------------------------



switch action,

  %---------------------------------------------------------------
  %          CASE INIT
  %---------------------------------------------------------------
  
  case 'init'

    % Make a figure
    SoloParamHandle(obj, 'myfig', 'saveable', 0); myfig.value = figure;
    
    % Make the title of the figure be the protocol name, and if someone tries
    % to close this figure, call dispatcher's close_protocol function, so it'll know
    % to take it off the list of open protocols.
    name = mfilename;
    set(value(myfig), 'Name', name, 'Tag', name, ...
      'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');


    % At this point we have one SoloParamHandle, myfig
    % Let's put the figure where we want it and give it a reasonable size:
    set(value(myfig), 'Position', [500   104   200   5]);

    % ----------

    x = 5; y = 5;             % Initial position on main GUI window

%-------------------------------------------------------------------------%   
%                           GUI creation 
    

    [x, y] = SavingSection(obj, 'init', x, y);
     [x, y] = LaserControlSection(obj,'init',x,y);
%     [x, y] = PokesPlotSection(obj, 'init', x, y);
%     %    set(value(PokesPlotSection.myfig), 'Position', [520 100 240 235]);
%         PokesPlotSection(obj, 'hide');
%         PokesPlotSection(obj, 'set_alignon', 'load_stimulus');
    
   
    
    
    % Make the main figure window as wide as it needs to be and as tall as
    % it needs to be; that way, no matter what each plugin requires in
    % terms of space, we always have enough space for it.
    pos = get(value(myfig), 'Position');
    set(value(myfig), 'Position', [pos(1:2) 205 230]);
    
%-------------------------------------------------------------------------% 
    
    StateMatrixSection(obj, 'init');
    
  %---------------------------------------------------------------
  %          CASE PREPARE_NEXT_TRIAL
  %---------------------------------------------------------------
  case 'prepare_next_trial'
    fprintf(1, 'Got to a prepare_next_trial state -- making the next state matrix\n');
    
    StateMatrixSection(obj, 'next_trial');
    
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    fprintf(1, ['\nFrom the beginning of this trial #%d to the\n' ...
      'start of the next, %g seconds elapsed.\n\n'], n_done_trials, ...
      parsed_events.states.state_0(2,1) - parsed_events.states.state_0(1,2));
  
   % PokesPlotSection(obj, 'trial_completed');
    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
    if ~isempty(latest_parsed_events.states.starting_state),
      fprintf(1, 'Somep''n happened! Since the last update, we''ve moved from state "%s" to state "%s"\n', ...
        latest_parsed_events.states.starting_state, latest_parsed_events.states.ending_state);
    end;
    
   % PokesPlotSection(obj, 'update');
      

  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'
    delete(value(myfig));
    LaserControlSection(obj, 'close');

    %PokesPlotSection(obj, 'close');
    
  otherwise,
    warning('Unknown action! "%s"\n', action);
end;

return;


