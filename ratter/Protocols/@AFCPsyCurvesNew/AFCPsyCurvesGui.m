% Maria Inês Vicente - August 2009

% To run it:
%  newstartup
%  dispatcher('init')
% and select this protocol.
%
% dispatcher('close_protocol'); dispatcher('set_protocol','2AFCPsyCurves');
%

function [x, y] = AFCPsyCurvesGui(obj, action, x, y)

GetSoloFunctionArgs;

   
switch action
    case 'init'
        SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
        name = 'AFCPsyCurves'; 
        set(value(myfig), 'Name', name, 'Tag', name, ...
              'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        set(value(myfig), 'Position', [380   50   622   690], 'Visible', 'on');
        x = 5; y = 5; 
%         gcf;

      
    % ----------------------  Rat Parameters -----------------------

    NumeditParam(obj, 'weight', NaN, x, y, 'label', 'Weight (g)');next_row(y);
    EditParam(obj, 'strain', 'LE', x, y, 'label', 'Strain');next_row(y);
    NumEditParam(obj, 'initialWeight', NaN, x, y, 'label', 'Initial weight (g)');next_row(y,1);
    EditParam(obj, 'arrivalDate', NaN, x, y, 'label', 'Date of arrival');next_row(y,1);
    SubHeaderParam(obj, 'RatParams', 'Rat Parameters', x, y); next_row(y,2);
    
    
    % -----------------------  Other Parameters -----------------------
    
    NumeditParam(obj, 'ITI', 4, x, y, 'label', 'Inter-trial interval');next_row(y);
    NumeditParam(obj, 'timeOutPenalty', 3, x, y, 'label', 'Time-out penalty');next_row(y);
    NumeditParam(obj, 'timeToGetReward', 4, x, y, 'label', 'Time to get reward'); next_row(y,1);
    NumeditParam(obj, 'too_late_jitter', 0.4, x, y, 'label', 'Too late jitter'); next_row(y,1);
    NumeditParam(obj, 'cnt_jitter', 0.4, x, y, 'label', 'Center jitter'); next_row(y,1);
    SubHeaderParam(obj, 'otherParams', 'Other Parameters', x, y); next_row(y,2);
      
     
    % ----------------  OdorDelaySection --------------------
    
     NumeditParam(obj, 'odorDeliveryMax', 1, x, y, 'label', 'Max odor delivery time (s)', ...
        'labelfraction', 0.7); next_row(y,2);
     
    [x, y] = OdorDelaySection(obj, 'init', x, y); next_row(y,2.2);
    
%     NumeditParam(obj, 'odorCueMax', NaN, x, y, 'label', 'Odor cue duration (max)',...
%               'labelfraction', 0.7); next_row(y,1);
%     DispParam(obj, 'odorCueAfterGoSignal', 0, x, y, 'label', 'Odor cue after go-signal', ...
%               'labelfraction', 0.7); next_row(y,1);
            

    % ----------------  TaskVersion ------------------------------

    MenuParam(obj, 'taskVersion', {'Original', 'Low_Urgency'}, 'Original', ...
        x, y, 'label', 'Task version', 'labelfraction', 0.5); %next_row(y,2); 
    
    
    
    next_column(x); 
    y = 5;
  
    
    % -----------------------  SoundsSection -----------------------
 
    [x, y] = SoundsSection(obj, 'init', x, y); next_row(y,1.4);
    
    
    % -----------------------  GoSignalSection -----------------------
 
    [x, y] = GoSignalDelaySection(obj, 'init', x, y); next_row(y,1);
    
    
    
    next_column(x); 
    y = 5;
    
    
    % ----------------  WaitingTimeRewardSection --------------------
     
    [x, y] = WaitingTimeRewardSection(obj, 'init', x, y); next_row(y,2);
      
    
    % ----------------  WaterProbSection --------------------
     
    [x, y] = WaterSection(obj, 'init', x, y);
            
    
      
   % ----------------  OlfactionSection --------------------

%     [x, y] = OlfactionSection(obj, 'init', x, y); next_row(y,2);
      
    
%     SoloFunctionAddVars('OdorDelaySection', 'rw_args', ...
%         {'ITI', 'timeToGetReward'});
    SoloFunctionAddVars('StateMatrixSection', 'rw_args', ...
        {'timeToGetReward', 'ITI', 'odorDeliveryMax', 'timeOutPenalty',...
        'taskVersion', 'too_late_jitter', 'cnt_jitter'});
    
    
case 'next_trial'
   
   
    OdorDelaySection(obj, 'next_trial');
    SoundsSection(obj, 'next_trial');
    GoSignalDelaySection(obj, 'next_trial');
    WaitingTimeRewardSection(obj, 'next_trial');
    WaterSection(obj, 'next_trial');
%     OlfactionSection(obj, 'next_trial');
    
      
      
  %---------------------------------------------------------------
  %          CASE TRIAL_COMPLETED
  %---------------------------------------------------------------
  case 'trial_completed'
    fprintf(1, ['\nFrom the beginning of this trial #%d to the\n' ...
      'start of the next, %g seconds elapsed.\n\n'], n_done_trials, ...
      parsed_events.states.state_0(2,1) - parsed_events.states.state_0(1,2));
  
  
    % --  PokesPlot needs completing the trial --
    %You need to inform the PokesPlot Plugin at what moment of the trial you
    %are so, here should go:

    
  %---------------------------------------------------------------
  %          CASE UPDATE
  %---------------------------------------------------------------
  case 'update'
%     OlfactionSection(obj, 'update')

  %And here should go this otherwise you will not see the plotting as it
  %happens trial by tial.
     if ~isempty(latest_parsed_events.states.starting_state),
        fprintf(1, 'Somep''n happened! Since the last update, we''ve moved from state "%s" to state "%s"\n', ...
         latest_parsed_events.states.starting_state, latest_parsed_events.states.ending_state);
     end;
        
     
  %---------------------------------------------------------------
  %          CASE CLOSE
  %---------------------------------------------------------------
  case 'close'

    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;
    
%     delete(value(myfig));
    delete_sphandle('owner', ['^@' class(obj) '$']);
      
  otherwise,
    warning('Unknown action! "%s"\n', action);
end;

return;