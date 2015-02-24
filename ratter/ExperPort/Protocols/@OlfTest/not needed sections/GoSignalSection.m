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


function [x, y] = GoSignalSection(obj, action, x, y)
   
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

        PushbuttonParam(obj, 'SetGoSignalDelay', x, y, 'position', [x y 200 25], ...
          'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1);
        set_callback(SetGoSignalDelay, {'GoSignalSection', 'setGoSignalDelay'});% next_row(y,1);
        DispParam(obj, 'goSignalDelay', 0, x, y, 'labelfraction', 0.7, 'label','Go-signal delay (s)');
        next_row(y,1.5);
        NumeditParam(obj, 'ExpDistMean', NaN, x, y, 'label','ExpDist mean',...
              'labelfraction', 0.5); next_row(y,1);
        NumeditParam(obj, 'UnifDistMin', NaN, x, y, 'label','Unif Dist minimum',...
              'labelfraction', 0.5); next_row(y,1);  
        NumeditParam(obj, 'UnifDistMax', NaN, x, y, 'label','Unif Dist maximum',...
              'labelfraction', 0.5); next_row(y,1);
        NumeditParam(obj, 'fixedValue', NaN, x, y, 'label','Fixed value',...
              'labelfraction', 0.5); next_row(y,1);  
        MenuParam(obj, 'goSignalDelayType', {'Fixed', 'UnifDist', 'ExpDist'}, ...
            'Fixed', x, y, 'label','Go-signal delay'); next_row(y,1.5);
        
        SubHeaderParam(obj, 'goSignal', 'Go-Signal Delay', x, y);
        
        SoloParamHandle(obj, 'UnifDistVector');
        UnifDistVector.value = zeros(1,1000);
        SoloParamHandle(obj, 'ExpDistVector');
        ExpDistVector.value = zeros(1,1000);
        
    
        SoloFunctionAddVars('StateMatrixSection', 'ro_args', {'goSignalDelay'});

    case 'setGoSignalDelay'
        
        switch value(goSignalDelayType)
            case 'Fixed'
                goSignalDelay.value = value(fixedValue);
                UnifDistMax.value = NaN;
                UnifDistMin.value = NaN;
                ExpDistMean.value = NaN;
            case 'UnifDist'
                fixedValue.value = NaN;
                UnifDistVector.value = (round(value(UnifDistMin) + (value(UnifDistMax) - ...
            value(UnifDistMin)) * rand(1,1000)*10))/10;
                goSignalDelay.value = value(UnifDistVector(1, n_started_trials + 1));
                ExpDistMean.value = NaN;
            case 'ExpDist'
                fixedValue.value = NaN;
                UnifDistMax.value = NaN;
                UnifDistMin.value = NaN;
                ExpDistVector = exprnd(value(ExpDistMean),1,1000);
                goSignalDelay.value = value(ExpDistVector(1, n_started_trials + 1));
        end
                
                
    case 'next_trial',
        switch value(goSignalDelayType)
            case 'Fixed'
                goSignalDelay.value = value(fixedValue);
%                 UnifDistMax.value = NaN;
%                 UnifDistMin.value = NaN;
%                 ExpDistMean.value = NaN;
            case 'UnifDist'
%                 fixedValue.value = NaN;
%                 UnifDistVector.value = value(UnifDistMin) + (value(UnifDistMax) - ...
%             value(UnifDistMin)) * rand(1,1000);
                goSignalDelay.value = value(UnifDistVector(1, n_started_trials + 1));
%                 ExpDistMean.value = NaN;
            case 'ExpDist'
%                 fixedValue.value = NaN;
%                 UnifDistMax.value = NaN;
%                 UnifDistMin.value = NaN;
%                 ExpDistVector = exprnd(value(ExpDistMean),1,1000);
                goSignalDelay.value = value(ExpDistVector(1, n_started_trials + 1));
        end

        
        
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

    
  % ------------------------------------------------------------------
  %              REINIT
  % ------------------------------------------------------------------    
%   case 'reinit'
%     x = my_xyfig(1); y = my_xyfig(2); origfig = my_xyfig(3);
%     currfig = gcf;
%     
%     feval(mfilename, obj, 'close');
%     
%     figure(origfig);
%     feval(mfilename, obj, 'init', x, y);
%     figure(currfig);

    
 
%   case 'reinit',
%     currfig = gcf;
% 
%     % Get the original GUI position and figure:
%     x = my_gui_info(1); y = my_gui_info(2); origfig = my_gui_info(3);
% 
%     
%     feval(mfilename, obj, 'close');
%     figure(origfig);
% %     delete_sphandle('owner', ['^@' class(obj) '$'], ...
% %       'fullname', ['^' mfilename]);
% 
%     % Reinitialise at the original GUI position and figure:
%     [x, y] = feval(mfilename, obj, 'init', x, y);
% 
%     % Restore the current figure:
%     figure(currfig);
end;