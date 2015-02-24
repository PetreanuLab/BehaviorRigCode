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

function [x, y] = ProtocolPhaseSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

    case 'init',
    
        gcf; %main figure of olfprotocol
        MenuParam(obj, 'ProtocolPhase', {'water at the lateral pokes' 'wait at center poke' 'olfaction'},...
        'water at the lateral pokes', x, y, 'label','Protocol phase'); next_row(y);
        set_callback(ProtocolPhase, {'ProtocolPhaseSection', 'switch'});
        SubHeaderParam(obj, 'ProtocolPhaseSection', 'Protocol Phase Section', x, y);
        next_row(y);
  
        SoloFunctionAddVars('WaitingTimeSection', 'rw_args', {'ProtocolPhase'});
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'ProtocolPhase'});
        SoloFunctionAddVars('olfprotocol', 'rw_args', {'ProtocolPhase'});    
      
    case 'switch'
    
        switch value(ProtocolPhase)
            case 'water at the lateral pokes'
                OlfactionSection(obj, 'close');
                WaitingTimeSection(obj, 'close');
                ChoiceSection_LateralWait(obj, 'close');
                ChoiceSection_LateralWait(obj, 'init');
%                 ChoiceSection_Olf(obj, 'close');
%                 WaterProbSection(obj, 'init');
%                 ChoiceSection(obj, 'init');
%                 set(value(myfig), 'Visible', 'off');
                  

            case 'wait at center poke'
                WaitingTimeSection(obj, 'init');
                OlfactionSection(obj, 'close');
                ChoiceSection_LateralWait(obj, 'close');
                ChoiceSection_LateralWait(obj, 'init');
%                 ChoiceSection_Olf(obj, 'close');
%                 WaterProbSection(obj, 'init');
%                 ChoiceSection(obj, 'init');
%                 set(value(myfig), 'Visible', 'on');
%                 SwitchInNTrials.value = value(TrialsPerBlock) + 1;
%                 waitingTime.value = value(setWaitingTime1);

            case 'olfaction'
                OlfactionSection(obj, 'init');
                WaitingTimeSection(obj, 'close');
                ChoiceSection_LateralWait(obj, 'close');
%                 ChoiceSection_Olf(obj, 'init');
%                 ChoiceSection(obj, 'close');
%                 set(value(myfig), 'Visible', 'off');
        end
        

    case 'next_trial'
    
        switch value(ProtocolPhase)
            case 'water at the lateral pokes'
                OlfactionSection(obj, 'close');
                WaitingTimeSection(obj, 'close');
                ChoiceSection_LateralWait(obj, 'next_trial');
%                 ChoiceSection_Olf(obj, 'close');
%                 WaterProbSection(obj, 'next_trial');
%                 ChoiceSection(obj, 'next_trial');
% %                 set(value(myfig), 'Visible', 'off');
                  

            case 'wait at center poke'
                WaitingTimeSection(obj, 'next_trial');
                OlfactionSection(obj, 'close');
                ChoiceSection_LateralWait(obj, 'next_trial');
%                 ChoiceSection_Olf(obj, 'close');
%                 WaterProbSection(obj, 'next_trial');
%                 ChoiceSection(obj, 'next_trial');
%                 set(value(myfig), 'Visible', 'on');
%                 SwitchInNTrials.value = value(TrialsPerBlock) + 1;
%                 waitingTime.value = value(setWaitingTime1);


            case 'olfaction'
                OlfactionSection(obj, 'next_trial');
                WaitingTimeSection(obj, 'close');
                ChoiceSection_LateralWait(obj, 'close');
%                 ChoiceSection_Olf(obj, 'next_trial');
%                 ChoiceSection(obj, 'close');
% %                 set(value(myfig), 'Visible', 'off');
        end
%         
    case 'update'
    
        switch value(ProtocolPhase)
%             case 'water at the lateral pokes'
%                 OlfactometerSection(obj, 'close');
%                 WaitingTimeSection(obj, 'close');
% %                 set(value(myfig), 'Visible', 'off');
                  

%             case 'wait at center poke'
%                 WaitingTimeSection(obj, 'init');
%                 OlfactometerSection(obj, 'close');
% %                 set(value(myfig), 'Visible', 'on');
% %                 SwitchInNTrials.value = value(TrialsPerBlock) + 1;
% %                 waitingTime.value = value(setWaitingTime1);

            case 'olfaction'
                OlfactionSection(obj, 'update');
                WaitingTimeSection(obj, 'close');
%                 set(value(myfig), 'Visible', 'off');
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