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


function [x, y] = OdorProtocolSection(obj, action, x, y)
   
GetSoloFunctionArgs;


switch action

    case 'init',
        
        gcf
        
        MenuParam(obj, 'OdorProtocol', {'Yes or No', 'Random', 'Descending', 'Tracking', 'ML-PEST'}, ...
            'Yes or No', x, y, 'label','Odor Protocol'); next_row(y,1.5);
        set_callback(OdorProtocol, {'OdorProtocolSection', 'switch'});
       
        SubHeaderParam(obj, 'OdorProtocolSection', 'Odor Protocol Section', x, y); %next_row(y,1.5)
        
%         DispParam(obj, 'odorPresent', 'No', x, y, 'label', ' Odor Present'); next_row(y,1.5);
% %         
%         SoloParamHandle(obj, 'valveNumber', 'value', 0);
        
%         SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'OdorProtocol', 'valveNumber', 'odorPresent'});
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'OdorProtocol'});
%         SoloFunctionAddVars('YesOrNoSection', 'rw_args', {'valveNumber', 'odorPresent'});
%         SoloFunctionAddVars('RandomSection', 'rw_args', {'odorPresent', 'valveNumber'});
        
        
    case 'switch',
    
        switch value(OdorProtocol)
            case 'Yes or No'
                YesOrNoSection(obj, 'init');
                RandomSection(obj, 'close');
%                 DescendingSection(obj, 'close');
                                
            case 'Random'
                YesOrNoSection(obj, 'close');
                RandomSection(obj, 'init');
%                 DescendingSection(obj, 'close');
                
%             case 'Descending'
%                 YesOrNoSection(obj, 'close');
%                 RandomSection(obj, 'close');
%                 DescendingSection(obj, 'init');
                
%             case 'Tracking'
%             case 'ML-PEST'
                
        end
        
% SoloParamHandle(obj, 'myfig', 'value', 0);
% myfig.value = figure;
% name = 'Olfactometer'; 
% set(value(myfig), 'Name', name, 'Tag', name, ...
%       'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
% set(value(myfig), 'Position', [500   400   832   315]);
% x = 10; y = 5; %maxy=5;     % Initial position on main GUI window
% 
%     % -----------------------  Olf Server -----------------------
    
%   MenuParam(obj, 'OdorName', {'Limonene (R)-(+)', 'Ethylacetoacetate', '1-Propanol'}, ...
%       'Limonene (R)-(+)', x, y, 'label','Odor name');
%   next_row(y,2);
%   
%   NumeditParam(obj, 'OlfCueDuration', 0.5, x, y, 'label','OdorTmax',...
%         'labelpos', 'left','labelfraction',0.50,...
%         'TooltipString',' max olf cue duration [sec]'); next_row(y,1);

    
    case 'next_trial'
        
%         case 'switch'

            switch value(OdorProtocol)
                case 'Yes or No'
                    YesOrNoSection(obj, 'next_trial');
                    RandomSection(obj, 'close');
%                     DescendingSection(obj, 'close');
                
                case 'Random'
                    YesOrNoSection(obj, 'close');
                    RandomSection(obj, 'next_trial');
%                     DescendingSection(obj, 'close');

                    
%                 case 'Descending'
%                     YesOrNoSection(obj, 'close');
%                     RandomSection(obj, 'close');
%                     DescendingSection(obj, 'next_trial');
                    
    %             case 'Tracking'
    %             case 'ML-PEST'

            end

%     case 'after_next_trial'
%         
%         YesOrNoSection(obj, 'after_next_trial');
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