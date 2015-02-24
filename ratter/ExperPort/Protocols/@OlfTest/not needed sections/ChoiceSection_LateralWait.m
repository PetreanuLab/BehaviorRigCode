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

function [x, y] = ChoiceSection_LateralWait(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

    case 'init',
        
    
    SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
    name = 'Side choices'; 
    set(value(myfig), 'Name', name, 'Tag', name, ...
          'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
    set(value(myfig), 'Position', [1000   400   832   315], 'Visible', 'on');
    x = 1; y = 1;
%     gcf;

    DispParam(obj, 'leftPort', 0, x, y, ...
        'label', 'Left port choices', 'labelfraction', 0.5); next_row(y, 1);
    DispParam(obj, 'rightPort', 0, x, y, ...
        'label', 'Right port choices', 'labelfraction', 0.5); next_row(y, 1.5);
    
    DispParam(obj, 'leftPortWater', 0, x, y, ...
        'label', 'Left port choices with water', 'labelfraction', 0.75); next_row(y, 1);
    DispParam(obj, 'rightPortWater', 0, x, y, ...
        'label', 'Right port choices with water', 'labelfraction', 0.75); %next_row(y, 1);
    
%     NumEditParam(obj, 'leftPort', 0, x, y, ...
%         label, 'Left port choices', 'labelfraction', 0.7); next_row(y, 1);
%     NumEditParam(obj, 'rightPort', 0, x, y, ...
%         label, 'Right port choices', 'labelfraction', 0.7); next_row(y, 1);
%     NumEditParam(obj, 'wrongLeftPort', 0, x, y, ...
%         label, 'Wrong left port choices', 'labelfraction', 0.7); next_row(y, 1);
%     NumEditParam(obj, 'wrongRightPort', 0, x, y, ...
%         label, 'Wrong right port choices', 'labelfraction', 0.7); next_row(y, 1);

%     if (~isempty(parsed_events.states.left_poke_in_water) == 1) 
%         leftPort.value = 1;
%     elseif (~isempty(parsed_events.states.right_poke_in_water) == 1),
%         leftPort.value = 1;
   

    case 'next_trial',
        
    if n_done_trials == 0,
%         numberTrials.value = 0;
%         SwitchInNTrials.value = value(TrialsPerBlock) + 1;
        return,
    end;
     
    
    if (~isempty(parsed_events.states.left_poke_in) == 1),
        leftPort.value = value(leftPort) + 1;
    elseif (~isempty(parsed_events.states.right_poke_in) == 1),
        rightPort.value = value(rightPort) + 1;
    end
    
    if (~isempty(parsed_events.states.lin_water) == 1),
        leftPortWater.value = value(leftPortWater) + 1;
    elseif (~isempty(parsed_events.states.rin_water) == 1),
        rightPortWater.value = value(rightPortWater) + 1;
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