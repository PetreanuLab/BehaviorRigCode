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


function [x, y] = OlfactionSection(obj, action, x, y)
   
GetSoloFunctionArgs;


switch action

    case 'init',
        SoloParamHandle(obj, 'myfig', 'value', 0);
        myfig.value = figure;
        name = 'Olfaction'; 
        set(value(myfig), 'Name', name, 'Tag', name, ...
              'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        set(value(myfig), 'Position', [900   400   832   315]);
        x = 10; y = 5; %maxy=5;     % Initial position on main GUI window

        NumeditParam(obj, 'minWaitingTimeOlf', 0.2, x, y, 'label','Minimum waiting time',...
              'labelfraction', 0.53); next_row(y,1);
%         set_callback(minWaitingTime, {'OlfactionSection', 'set'});
        NumeditParam(obj, 'maxWaitingTimeOlf', 0.5, x, y, 'label','Maximum waiting time',...
              'labelfraction', 0.53); next_row(y,1);  
%         set_callback(maxWaitingTime, {'OlfactionSection', 'set'});

        DispParam(obj, 'waitingTimeOlf', 0, x, y, 'labelfraction', 0.53, 'label','Waiting time');
        next_row(y,1);

%         SoloParamHandle(obj, 'valveNumber', 'value', 0);
        DispParam(obj, 'odorPresent', 'No', x, y, 'label', ' Odor Present'); next_row(y,1.5);
%         
        SoloParamHandle(obj, 'valveNumber', 'value', 0);

        SubHeaderParam(obj, 'GeneralParams', 'General Parameters', x, y);
        next_row(y,2);
        
        waitingTimeOlf.value = value(minWaitingTimeOlf) + (value(maxWaitingTimeOlf) - ...
            value(minWaitingTimeOlf)) * rand;

    
        SoloFunctionAddVars('StateMatrixSection', 'ro_args', {'waitingTimeOlf'});
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'valveNumber', 'odorPresent'});
        SoloFunctionAddVars('YesOrNoSection', 'rw_args', {'valveNumber', 'odorPresent'});
    % -----------------------  OlfactometerSection -----------------------
 
        [x, y] = OlfactometerSection(obj, 'init', x, y); next_row(y,2);
        
        
    % -----------------------  OlfactometerSection -----------------------
  
        [x, y] = OdorSection(obj, 'init', x, y); next_row(y,2);
        
        
    % -----------------------  OdorProtocolSection -----------------------
  
        [x, y] = OdorProtocolSection(obj, 'init', x, y); %next_row(y);
        
        
        
%         [x, y] = ChoiceSection_Olf(obj, 'init', x, y); next_row(y,1.5);
        
%     case 'set',
%         minWaitingTime.value = value(minWaitingTime);
%         maxWaitingTime.value = value(maxWaitingTime);
    
    case 'next_trial',
        waitingTimeOlf.value = value(minWaitingTimeOlf) + (value(maxWaitingTimeOlf) - ...
            value(minWaitingTimeOlf)) * rand;
        OdorSection(obj, 'next_trial');
        OlfactometerSection(obj, 'next_trial');
        OdorProtocolSection(obj, 'next_trial');
        
%     case 'trial_completed',  
%         ChoiceSection_Olf(obj, 'trial_completed');
       
    case 'update' 
        OlfactometerSection(obj, 'update');
        
        
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