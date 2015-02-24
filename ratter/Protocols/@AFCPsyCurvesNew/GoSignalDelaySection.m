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


function [x, y] = GoSignalDelaySection(obj, action, x, y)
   
GetSoloFunctionArgs;


switch action

    case 'init',
%         SoloParamHandle(obj, 'myfig', 'value', 0);
%         myfig.value = figure;
%         name = 'Go-signal delay'; 
%         set(value(myfig), 'Name', name, 'Tag', name, ...
%               'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
%         set(value(myfig), 'Position', [900   50   209   342]);
%         x = 5; y = 5; maxy = 5;     % Initial position on main GUI window
        gcf;
        
        PushbuttonParam(obj, 'SetGoSignalDelay', x, y,'label','Set go-signal delay',...
            'position', [x y 200 25], 'BackgroundColor', [0.1 0.5 0.5]); next_row(y,1.3);
        set_callback(SetGoSignalDelay, {'GoSignalDelaySection', 'setGoSignalDelay'}); %next_row(y,1);
        
        DispParam(obj, 'goSignalDelay', 0, x, y, 'labelfraction', 0.7, 'label','Waiting time for reward (s)');
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
          
        MenuParam(obj, 'goSignalDelayType', {'Fixed', 'UnifDist', 'ExpDist'}, ...
            'Fixed', x, y, 'labelfraction', 0.6, 'label','Waiting time for reward'); next_row(y,1.5);
        
        
        NumeditParam(obj, 'deltaFailure', NaN, x, y, 'label', 'Delta failure',...
              'labelfraction', 0.5); next_row(y,1);
        NumeditParam(obj, 'deltaSuccess', NaN, x, y, 'label', 'Delta success',...
              'labelfraction', 0.5); next_row(y,1);  
        NumeditParam(obj, 'endPoint', NaN, x, y, 'label', 'End point',...
              'labelfraction', 0.5); next_row(y,1);
        NumeditParam(obj, 'startPoint', NaN, x, y, 'label', 'Start point',...
              'labelfraction', 0.5); next_row(y,1.2);  
        MenuParam(obj, 'goSignalDelayAdaptive', {'On', 'Off'}, ...
            'On', x, y, 'labelfraction', 0.6, 'label', 'Adaptive'); next_row(y,1);
        
        
        SubHeaderParam(obj, 'goSignalDelayParams', 'Go-signal delay', x, y); %next_row(y,2);
        
        SoloParamHandle(obj, 'goSignalDelayVector')
        goSignalDelayVector.value = nan(1, 1000);
        SoloParamHandle(obj, 'UnifDistVector');
        UnifDistVector.value = zeros(1, 1000);
        SoloParamHandle(obj, 'ExpDistVector');
        ExpDistVector.value = zeros(1, 1000);
        
%         SoloFunctionAddVars('ChoiceSection', 'ro_args', {'goSignalDelayVector'});
%         SoloFunctionAddVars('PlotSection', 'ro_args', {'goSignalDelayVector'});
        SoloFunctionAddVars('StateMatrixSection', 'ro_args', {'goSignalDelay'});

    case 'setGoSignalDelay'
        
        switch value(goSignalDelayAdaptive)
            case 'On'
                goSignalDelay.value = value(startPoint);
                goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
                
            case 'Off'
                switch value(goSignalDelayType)
                    case 'Fixed'
                        goSignalDelay.value = value(fixedValue);
                        goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
                        UnifDistMax.value = NaN;
                        UnifDistMin.value = NaN;
                        ExpDistMean.value = NaN;
                        ExpDistMin.value = NaN;
                        ExpDistMax.value = NaN;
                    case 'UnifDist'
                        fixedValue.value = NaN;
                        UnifDistVector.value = (value(UnifDistMin) + (value(UnifDistMax) - ...
                    value(UnifDistMin)) * rand(1,1000));
                        goSignalDelay.value = value(UnifDistVector(1, n_started_trials + 1));
                        goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
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
                        goSignalDelay.value = value(ExpDistVector(1, n_started_trials + 1));
                        goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
                end
        end
                
%     disp(value(goSignalDelayVector));
        
    case 'next_trial',
        
        if n_done_trials == 0,
            return,
        end;
               
        switch value(goSignalDelayAdaptive)
            
            case 'On'
                if (~isempty(parsed_events.states.go_signal) == 1)
                    goSignalDelay.value = value(goSignalDelay) + value(deltaSuccess);
                    goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
                    if value(goSignalDelay) > value(endPoint)
                        goSignalDelay.value = value(endPoint);
                        goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
                    end
                elseif (~isempty(parsed_events.states.go_signal) == 1)
                    goSignalDelay.value = value(goSignalDelay) - value(deltaFailure);
                    goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
                    if value(goSignalDelay) < value(startPoint)
                        goSignalDelay.value = value(startPoint);
                        goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
                    end
                else
                    goSignalDelay.value = value(goSignalDelay);
                    goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
                end
                
            case 'Off'
                switch value(goSignalDelayType)
                    case 'Fixed'
                        goSignalDelay.value = value(fixedValue);
                        goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
                    case 'UnifDist'
                        goSignalDelay.value = value(UnifDistVector(1, n_started_trials + 1));
                        goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
                    case 'ExpDist'
                        goSignalDelay.value = value(ExpDistVector(1, n_started_trials + 1));
                        goSignalDelayVector(1, n_started_trials + 1) = value(goSignalDelay);
                end
        end
        
%         disp(value(goSignalDelay));


        
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