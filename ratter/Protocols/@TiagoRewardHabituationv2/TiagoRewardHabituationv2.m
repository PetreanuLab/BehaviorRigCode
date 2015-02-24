function [obj] = TiagoRewardHabituationv2(varargin)
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
        
        SoloParamHandle(obj,'lastChoices','value',0);
        
        % Creates the main window
        SoloParamHandle(obj, 'mainfig', 'saveable', 0); mainfig.value = figure;
        name = 'Reward Habituation';
        set(value(mainfig), 'Name', name, 'Tag', name, ...
            'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        
        set(value(mainfig), 'Position', [520 370 480 320]);%[775 100 220 400]
        % Starting coordinates
        x=20; y=20;
        % Submit push button
        PushbuttonParam(obj, 'submit', x, y, 'position', [x y 200 45],'BackgroundColor', [0 0 1]);next_row(y,3);
        set_callback(submit, {'StateMatrixSection', 'init'}); %i, sprintf('\n')});
        % Reward Menu - time valve is open and reward interval
        NumeditParam(obj, 'rewardInterval', 2, x, y, 'TooltipString', 'Time interval between rewards (seconds)');next_row(y);
        NumeditParam(obj, 'valveTime', 0.05, x, y, 'TooltipString', 'For how long valve is open (seconds)');next_row(y,1.2);
        SubheaderParam(obj, 'rewardMenu', 'Reward', x, y);next_row(y,1.5);
        % Session Duration Menu - session time or number of total rewards
        NumeditParam(obj, 'sessionTime', 300000, x, y, 'TooltipString', 'Duration of the training session (seconds). Leave 0 for number of rewards priority');next_row(y);
        NumeditParam(obj, 'nReward', 100000, x, y, 'TooltipString', 'Number of rewards to be given. Leave 0 for time priority');next_row(y,1.2);
        SubheaderParam(obj, 'sessionMenu', 'Session Duration', x, y); next_row(y,1.5);
        % Reward Location Menu
        NumeditParam(obj, 'maxEqualChoices', 3, x, y, 'TooltipString', 'Maximum number of equal choices allowed in a row.');next_row(y);
        MenuParam(obj, 'rewardLocation',{'BOTH','LEFT', 'RIGHT'}, 1, x, y, 'TooltipString', ...
            'Location of reward to be delivered',  'labelfraction', 0.5);next_row(y,1.2);
        SubheaderParam(obj, 'rewardLocationMenu', 'Reward location', x, y);
        
        
        % Declares global variables
        %%% Global Variables Example
        % DeclareGlobals(obj, {'rw_args','leftValve'}, {'ro_args', 'rightValve'},{'owner', class(obj)});
        %%%
        DeclareGlobals(obj, 'rw_args', {'rewardInterval', 'valveTime', 'sessionTime', 'nReward', 'maxEqualChoices','rewardLocation','lastChoices'});
        
        % Creates the saving options window
        %         SoloParamHandle(obj, 'savingfig', 'saveable', 0); savingfig.value = figure;
        %         name = 'Saving Section Figure';
        %         set(value(savingfig), 'Name', name, 'Tag', name, ...
        %             'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        %
        %         set(value(savingfig), 'Position', [520 100 240 235]);
        
        next_column(x); y=20;
        % Submit push button
        PushbuttonParam(obj, 'restart', x, y, 'position', [x y 200 45],'BackgroundColor', [1 0 0]);next_row(y,3);
        set_callback(restart, {'TiagoRewardHabituationv2','restart'}); %i, sprintf('\n')});
        
        [x, y] = SavingSection(obj, 'init', x, y);
        
        my_state_colors = struct( ...
            'start_timer', [1 0 0], ...
            'waiting_for_lick', [0 1 0], ...
            'left_reward', [0 0 1], ...
            'right_reward', [1 1 0], ...
            'time_interval', [1 0 1]);
        
        my_poke_colors = struct( ...
            'L',                  0.6*[1 0.66 0],    ...
            'C',                      [0 0 0],       ...
            'R',                  0.9*[1 0.66 0]);
        
        [x, y] = PokesPlotSection(obj, 'init', x, y, ...
            struct('states',  my_state_colors, 'pokes', my_poke_colors));
        %    set(value(PokesPlotSection.myfig), 'Position', [520 100 240 235]);
        PokesPlotSection(obj, 'hide');
        PokesPlotSection(obj, 'set_alignon', 'waiting_for_lick');
        ThisSPH=get_sphandle('owner', mfilename, 'name','t0'); ThisSPH{1}.value = 0;
        ThisSPH=get_sphandle('owner', mfilename, 'name','t1'); ThisSPH{1}.value = 10;
        %     PokesPlotSection(obj, 'time_axes', '-10 +10');
        %     set(value(axpokesplot), 'XLim', [value(t0) value(t1)]);
        %     set(value(PokesPlotSection(obj, 't0', 'value', -10)));
        %     SoloParamHandle(obj, 't0', 'value', -10);
        
        %   % Left edge of pokes plot:
        %     SoloParamHandle(obj, 't0', 'label', 't0', 'type', 'numedit', 'value', -4, ...
        %       'position', [165 1 60 20], 'TooltipString', 'time axis left edge');
        %     % Right edge of pokes plot:
        %     SoloParamHandle(obj, 't1', 'label', 't1', 'type', 'numedit', 'value', 15, ...
        %       'position', [230 1 60 20], 'TooltipString', 'time axis right edge');
        %     set_callback({t0;t1}, {mfilename, 'time_axis'});
        next_row(y);
        
        
    case 'prepare_next_trial'
        if (n_done_trials < value(nReward)) && dispatcher('get_time') < value(sessionTime)
            fprintf(1, 'Got to a prepare_next_trial state -- making the next state matrix\n');
            
            if value(maxEqualChoices) ~=0
                lastChoices.value = circshift(value(lastChoices),[0,-1]);
                lastChoices(end)= isempty(parsed_events.states.left_reward);
                value(lastChoices)
            end
            
            StateMatrixSection(obj, 'next_trial');
        else
            fprintf(1, 'Last trial\n');
            StateMatrixSection(obj, 'session_over');
        end
        
        
    case 'trial_completed'
        fprintf(1, ['\nFrom the beginning of this trial #%d to the\n' ...
            'start of the next, %g seconds elapsed.\n\n'], n_done_trials, ...
            parsed_events.states.state_0(2,1) - parsed_events.states.state_0(1,2));
        
        PokesPlotSection(obj, 'trial_completed');
        
        
    case 'update'
        %     if ~isempty(latest_parsed_events.states.starting_state),
        %       fprintf(1, 'Somep''n happened! Since the last update, we''ve moved from state "%s" to state "%s"\n', ...
        %         latest_parsed_events.states.starting_state, latest_parsed_events.states.ending_state);
        %     end;
        
        PokesPlotSection(obj, 'update');
        
    case 'restart'
        dispatcher('restart_protocol');
        
    case 'close'
        delete(value(mainfig));
        %delete(value(myfig));
        %PokesPlotSection(obj, 'close');
        
    otherwise,
        warning('Unknown action! "%s"\n', action);
        
end;