% [x, y] = PlotSection(obj, action, [arg1], [arg2])

function [x, y] = PlotSection(obj, action, varargin)

try
    % Nothing that happens in pokesplot should cause a session to abort.
    % So the whole thing is getting wrapped in a try catch.
    
GetSoloFunctionArgs(obj);

global data;
sampling_rate = 3000; dt = 1/sampling_rate;


switch action,

%% init    
  % ------------------------------------------------------------------
  %              INIT
  % ------------------------------------------------------------------    

  case 'init'
    if length(varargin) < 2,
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;
    x = varargin{1}; y = varargin{2};
    
    SoloParamHandle(obj, 'I_am_PlotSection');
    SoloParamHandle(obj, 'my_xyfig', 'value', [x y gcf]);
    ToggleParam(obj, 'PlotShow', 1, x, y, 'OnString', 'Plot showing', ...
      'OffString', 'Plot hidden', 'TooltipString', 'Show/Hide Plot window'); next_row(y);
    set_callback(PlotShow, {mfilename, 'show_hide'});
    
    screen_size = get(0, 'ScreenSize');
    SoloParamHandle(obj, 'myfig', 'value', figure('Position', [500 750, 400 400], ...
      'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
      'Name', mfilename), 'saveable', 0);
    origfig_xy = [x y];


    % ---

    
    x = 3; y = 3;

       
    
    % An axis for the current plot:
    SoloParamHandle(obj, 'axplot', 'saveable', 0, 'value', axes('Position', [0.15 0.2 0.75 0.7]));
    xlabel('secs'); ylabel('volts'); hold on;
    %set(value(axplot), 'Color', 0.3*[1 1 1]);
    
    
    % ---
    x = origfig_xy(1); y = origfig_xy(2);
    figure(value(my_xyfig(3)));
    
%% update    
  % ------------------------------------------------------------------
  %              UPDATE
  % ------------------------------------------------------------------    

  case 'update',
    % We initialize a new trial once it's started, so as to have access to its start time:
%     if length(trial_info) < n_started_trials, %#ok<NODEF> (defined by GetSoloFunctionArgs)
%       initialize_trial(n_started_trials,n_completed_trials,parsed_events,value(alignon),trial_info); %#ok<NODEF> (defined by GetSoloFunctionArgs)
%     end;
% 
%     time = dispatcher('get_time');
%     update_already_started_trial(dispatcher('get_time'), ...
%       n_started_trials, parsed_events, latest_parsed_events, ...
%       value(alignon), value(axplot), trial_info);
%     
%     set(value(axplot), 'XLim', [value(t0) value(t1)]);
%     set_ylimits(n_started_trials, value(axplot), value(trial_limits), ...
%       value(start_trial), value(end_trial), value(ntrials));
% 
%   
%     drawnow;

%% trial_completed    
  % ------------------------------------------------------------------
  %              TRIAL_COMPLETED
  % ------------------------------------------------------------------    

  case 'trial_completed',
    
    [r c] = size(data);
    time = dt:dt:r*dt;
    
    % An axis for the plot:
    SoloParamHandle(obj, 'axplot', 'saveable', 0, 'value', axes('Position', [0.1 0.10 0.8 0.54]));
    xlabel('secs'); ylabel('V'); hold on;
    %set(value(axplot), 'Color', 0.3*[1 1 1]);
      
    plot(time,data(:,2),'k','linewidth',4)
    ylim([0 5]);
    
    
    
%% close

  % ------------------------------------------------------------------
  %              CLOSE
  % ------------------------------------------------------------------    
  case 'close'    
    pokesplot_preferences_pane(obj, 'close');
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;    
    delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', [mfilename '_']);


end; %     end of switch action
catch
    showerror
end
%     end of function PokesPlotSection


