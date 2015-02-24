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

function [x, y] = YesOrNoSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

    case 'init',
    
%     gcf
%     DispParam(obj, 'odorPresent', 'No', x, y, 'label', ' Odor Present'); next_row(y,1.5);
    
    SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
    name = 'Yes or No'; 
    set(value(myfig), 'Name', name, 'Tag', name, ...
          'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
    set(value(myfig), 'Position', [1000   400   832   315], 'Visible', 'on');
    x = 1; y = 1;

%     SubHeaderParam(obj, 'YesOrNoProtocol', 'Yes or No Protocol', x, y); %next_row(y,2);

%     SoloParamHandle(obj, 'nvalves', 'value', 5)
%     disp(value(nvalves))
%     SoloParamHandle

%     nvalves.value = 2;
%     valveNumber.value = ceil(value(nvalves) * rand);
%     disp(value(valveNumber))

    PushbuttonParam(obj, 'SetOdorValvesVector', x, y, 'label','Set odor valves vector', ...
        'position', [x y 200 25], 'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1);
    set_callback(SetOdorValvesVector, {'YesOrNoSection', 'setOdorValvesVector'}); %next_row(y,1);
    NumEditParam(obj, 'probYesValve', 0.5, x, y, 'label', 'Prob. Yes valve');next_row(y,1.5);
%     NumEditParam(obj, 'probNoValve', 0.5, x, y, 'label', 'Prob. No valve'); next_row(y,1)
%     NumEditParam(obj, 'matrixLength', 0, x, y, 'label', 'Length of the matrix');%next_row(y,1.5)
    
%     DispParam(obj, 'odorPresent', 'No', x, y, 'label', ' Odor Present');% next_row(y,1.5);
        
%     SoloParamHandle(obj, 'valveNumber', 'value', 0);
%     disp(value(valveNumber))
    
%     DispParam(obj, 'leftPort', 0, x, y, ...
%         'label', 'Left port choices', 'labelfraction', 0.5); next_row(y, 1);
%     DispParam(obj, 'rightPort', 0, x, y, ...
%         'label', 'Right port choices', 'labelfraction', 0.5); next_row(y, 1);
%     
%     DispParam(obj, 'errorChoice', 0, x, y, ...
%         'label', 'Error', 'labelfraction', 0.5); next_row(y, 1);
%     DispParam(obj, 'correctChoice', 0, x, y, ...
%         'label', 'Correct', 'labelfraction', 0.5); %next_row(y, 1);


    SoloParamHandle(obj, 'odorValvesOpening');
    odorValvesOpening.value = zeros(1,1000);
    
 
%    n_started_trials + 1
    
%    disp(value(odorValvesOpening(1,n_started_trials + 1)))

    
    if value(odorValvesOpening(1,n_started_trials + 1)) == 0,
        odorPresent.value = 'No';
        valveNumber.value = 1;
    else
        odorPresent.value = 'Yes';
        valveNumber.value = 2;
    end
    
    
%     DeclareGlobals(obj, 'rw_args', {'odorPresent'});
%     SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'odorPresent'});
%     SoloFunctionAddVars('OdorProtocolSection', 'rw_args',  {'odorPresent'});
%     SoloFunctionAddVars('OlfactometerSection', 'ro_args', {'valveNumber'});

    case 'setOdorValvesVector',
%     valvesOpening.value = zeros(2,value(matrixLength));
    odorValvesOpening(1,:) = rand (1,1000) < value(probYesValve);

    
    case 'next_trial',
        
    if n_done_trials == 0,
%         numberTrials.value = 0;
%         SwitchInNTrials.value = value(TrialsPerBlock) + 1;
        return,
    end;
    
%    n_started_trials
    
   disp(value(odorValvesOpening(1,n_started_trials + 1)));

    
    if value(odorValvesOpening(1,n_started_trials + 1)) == 0,
        odorPresent.value = 'No';
        valveNumber.value = 1;
    else
        odorPresent.value = 'Yes';
        valveNumber.value = 2;
    end
    
%     case 'prepare_next_trial',
%     ~isempty(parsed_events.states.lin_no_water_olf)
%     ~isempty(parsed_events.states.lin_water_olf)
    
%     case 'prepare_next_trial'
%     case 'after_next_trial'
%     
%     if strcmpi(value(odorPresent), 'No') == 1
%         if (~isempty(parsed_events.states.rin_no_water_olf) == 1),
%             rightPort.value = value(rightPort) + 1
%             errorChoice.value = value(errorChoice) + 1
%         elseif (~isempty(parsed_events.states.lin_water_olf) == 1),
%             leftPort.value = value(leftPort) + 1
%             correctChoice.value = value(correctChoice) + 1
%         end
%         
% %     elseif strcmpi(value(odorPresent), 'Yes') == 1
%         if (~isempty(parsed_events.states.rin_water_olf) == 1),
%             rightPort.value = value(rightPort) + 1
%             correctChoice.value = value(correctChoice) + 1
%         elseif (~isempty(parsed_events.states.lin_no_water_olf) == 1),
%             leftPort.value = value(leftPort) + 1
%             errorChoice.value = value(errorChoice) + 1
%         end
%     end
    
%     valveNumber.value = ceil(value(nvalves) * rand);
%     
%     if value(valveNumber) == 1,
%         odorPresent.value = 'Yes';
%     elseif value(valveNumber) == 2,
%         odorPresent.value = 'No';
%     end
    

                
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
% %     currfig = gcf;
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