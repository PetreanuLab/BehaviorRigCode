function [obj] = TiagoRandomDot2AFCv10(varargin)
obj = class(struct, mfilename, pokesplot, saveload);
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
    if length(varargin) < 2 || ~ischar(varargin{2}),
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
    
    case 'init'
        
        SetGUI(obj, 'init');
        
        
    case 'prepare_next_trial'
        
        %Optimize this!!!
        if value(soundTrial)
            if or(isempty(parsed_events.states.wrong_choice)==0,isempty(parsed_events.states.early_wrong_choice)==0)
                sound((rand(40000*value(errorPunishment),1) - 0.5)*value(soundVolume)/2000,40000);
            elseif isempty(parsed_events.states.correct_choice)==0
                sound(sin((1:40000*0.25)/40000*2*pi*1000)*value(soundVolume)/2000,40000);
            end
        end
        
        fprintf(1, 'Preparing next trial -- making the next state matrix\n');
    
        SupportFunctions(obj,'random_variables');
        
        SupportFunctions(obj,'param_save');
        
        StateMatrixSection(obj, 'next_trial');
        
    case 'trial_completed'
        fprintf(1, ['\nFrom the beginning of this trial #%d to the\n' ...
            'start of the next, %g seconds elapsed.\n\n'], n_done_trials, ...
            parsed_events.states.state_0(2,1) - parsed_events.states.state_0(1,2));
        
        PokesPlotSection(obj, 'trial_completed');
        
    case 'update'
        PokesPlotSection(obj, 'update');
        
    case 'close'
        PokesPlotSection(obj, 'close');
        SetGUI(obj, 'close');
        
    otherwise,
        warning('Unknown action! "%s"\n', action);
        
end;
