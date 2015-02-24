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
%


function [x, y] = WaitingTimeRewardSection(obj, action, x, y)
   
GetSoloFunctionArgs;


switch action

    case 'init',
%         SoloParamHandle(obj, 'myfig', 'value', 0);
%         myfig.value = figure;
%         name = 'Olfaction'; 
%         set(value(myfig), 'Name', name, 'Tag', name, ...
%               'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
%         set(value(myfig), 'Position', [900   400   832   315]);
%         x = 5; y = 5; maxy = 5;     % Initial position on main GUI window
        gcf;
        
        PushbuttonParam(obj, 'SetWaitingTimeRew', x, y,'label','Set waiting time for reward',...
            'position', [x y 200 25], 'BackgroundColor', [0.1 0.5 0.5]); next_row(y,1.3);
        set_callback(SetWaitingTimeRew, {'WaitingTimeRewardSection', 'setWaitingTimeRew'; ...
            'PlotSection', 'startWaitingTimeRewPlot'}); %next_row(y,1);
        
        DispParam(obj, 'waitingTimeRew', 0, x, y, 'labelfraction', 0.7, 'label','Waiting time for reward (s)');
        next_row(y,1.5);
        
        NumeditParam(obj, 'ExpDistMin', NaN, x, y, 'label','Exp Dist minimum',...
              'labelfraction', 0.5); next_row(y,1);
        NumeditParam(obj, 'ExpDistMax', NaN, x, y, 'label','Exp Dist maximum',...
              'labelfraction', 0.5); next_row(y,1);
        NumeditParam(obj, 'ExpDistMean', NaN, x, y, 'label','Exp Dist mean',...
              'labelfraction', 0.5); next_row(y,1);
        NumeditParam(obj, 'UnifDistMin', NaN, x, y, 'label','Unif Dist minimum',...
              'labelfraction', 0.5); next_row(y,1);  
        NumeditParam(obj, 'UnifDistMax', NaN, x, y, 'label','Unif Dist maximum',...
              'labelfraction', 0.5); next_row(y,1);
        NumeditParam(obj, 'fixedValue', NaN, x, y, 'label','Fixed value',...
              'labelfraction', 0.5); next_row(y,1.2);
          
        MenuParam(obj, 'waitingTimeRewType', {'Fixed', 'UnifDist', 'ExpDist'}, ...
            'Fixed', x, y, 'labelfraction', 0.6, 'label','Waiting time for reward'); next_row(y,1.5);
        
        
        NumeditParam(obj, 'deltaFailure', NaN, x, y, 'label', 'Delta failure',...
              'labelfraction', 0.5); next_row(y,1);
        NumeditParam(obj, 'deltaSuccess', NaN, x, y, 'label', 'Delta success',...
              'labelfraction', 0.5); next_row(y,1);  
        NumeditParam(obj, 'endPoint', NaN, x, y, 'label', 'End point',...
              'labelfraction', 0.5); next_row(y,1);
        NumeditParam(obj, 'startPoint', NaN, x, y, 'label', 'Start point',...
              'labelfraction', 0.5); next_row(y,1.2);  
        MenuParam(obj, 'waitingTimeRewAdaptive', {'On', 'Off'}, ...
            'On', x, y, 'labelfraction', 0.6, 'label', 'Adaptive'); next_row(y,1);
        
        
        SubHeaderParam(obj, 'waitingTimeRewParams', 'Waiting Time for Reward', x, y); %next_row(y,2);
        
        SoloParamHandle(obj, 'waitingTimeRewVector')
        waitingTimeRewVector.value = nan(1, 1000);
        SoloParamHandle(obj, 'UnifDistVector');
        UnifDistVector.value = zeros(1, 1000);
        SoloParamHandle(obj, 'ExpDistVector');
        ExpDistVector.value = zeros(1, 1000);
        
        SoloFunctionAddVars('ChoiceSection', 'ro_args', {'waitingTimeRewVector'});
        SoloFunctionAddVars('PlotSection', 'ro_args', {'waitingTimeRewVector'});
        SoloFunctionAddVars('StateMatrixSection', 'ro_args', {'waitingTimeRew'});

    case 'setWaitingTimeRew'
        
        switch value(waitingTimeRewAdaptive)
            case 'On'
                waitingTimeRew.value = value(startPoint);
                waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                
            case 'Off'
                switch value(waitingTimeRewType)
                    case 'Fixed'
                        waitingTimeRew.value = value(fixedValue);
                        waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                        UnifDistMax.value = NaN;
                        UnifDistMin.value = NaN;
                        ExpDistMean.value = NaN;
                        ExpDistMin.value = NaN;
                        ExpDistMax.value = NaN;
                    case 'UnifDist'
                        fixedValue.value = NaN;
                        UnifDistVector.value = (value(UnifDistMin) + (value(UnifDistMax) - ...
                    value(UnifDistMin)) * rand(1,1000));
                        waitingTimeRew.value = value(UnifDistVector(1, n_started_trials + 1));
                        waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                        ExpDistMean.value = NaN;
                        ExpDistMin.value = NaN;
                        ExpDistMax.value = NaN;
                    case 'ExpDist'
                        fixedValue.value = NaN;
                        UnifDistMax.value = NaN;
                        UnifDistMin.value = NaN;
                        ExpDistVector.value = exprnd(value(ExpDistMean),1,2000);
                        ExpDistVector.value = value(ExpDistMin) + value(ExpDistVector(find(value(ExpDistVector) < (value(ExpDistMax) - value(ExpDistMin)))));
        %                 iMax = find(value(ExpDistVector) > value(ExpDistMax));
        %                 ExpDistVector(iMax) = value(ExpDistMax);
        %                 iMin = find(value(ExpDistVector) < value(ExpDistMin));
        %                 ExpDistVector(iMin) = value(ExpDistMin);
                        waitingTimeRew.value = value(ExpDistVector(1, n_started_trials + 1));
                        waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                end
        end
                
%     disp(value(waitingTimeRewVector));
        
    case 'next_trial',
        
        if n_done_trials == 0,
            return,
        end;
               
        switch value(waitingTimeRewAdaptive)
            
            case 'On'
                if (~isempty(parsed_events.states.lin_water) == 1) || ...
                        (~isempty(parsed_events.states.rin_water) == 1)
                    waitingTimeRew.value = value(waitingTimeRew) + value(deltaSuccess);
                    waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                    if value(waitingTimeRew) > value(endPoint)
                        waitingTimeRew.value = value(endPoint);
                        waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                    end
                elseif (~isempty(parsed_events.states.lin_no_water) == 1) || ...
                        (~isempty(parsed_events.states.rin_no_water) == 1)
                    waitingTimeRew.value = value(waitingTimeRew) - value(deltaFailure);
                    waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                    if value(waitingTimeRew) < value(startPoint)
                        waitingTimeRew.value = value(startPoint);
                        waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                    end
                else
                    waitingTimeRew.value = value(waitingTimeRew);
                    waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                end
                
            case 'Off'
                switch value(waitingTimeRewType)
                    case 'Fixed'
                        waitingTimeRew.value = value(fixedValue);
                        waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                    case 'UnifDist'
                        waitingTimeRew.value = value(UnifDistVector(1, n_started_trials + 1));
                        waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                    case 'ExpDist'
                        waitingTimeRew.value = value(ExpDistVector(1, n_started_trials + 1));
                        waitingTimeRewVector(1, n_started_trials + 1) = value(waitingTimeRew);
                end
        end
        
%         disp(value(waitingTimeRew));


        
%   ------------------------------------------------------------------
%                CLOSE
%   ------------------------------------------------------------------    
  case 'close'    
    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;    
    delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', ['^' mfilename '_']);

    
 
end;