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
%%% CVS version control block - do not edit manually
%%%  $Revision: 1.2 $
%%%  $Date: 2007-10-10 13:09:11 $
%%%  $Source: /cvs/ExperPort/Protocols/@saja_reversal/SoundsSection.m,v $


function [x, y] = ProtocolPhaseSection(obj, action, varargin)
   
GetSoloFunctionArgs;


switch action

    case 'init',
        
    SoloParamHandle(obj, 'myfig', 'value', 0);
    myfig.value = figure;
    name = 'WaitingTime'; 
    set(value(myfig), 'Name', name, 'Tag', name, ...
          'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
    set(value(myfig), 'Position', [500   400   832   315]);
    x = 10; y = 5; %maxy=5;     % Initial position on main GUI window

    

%     PushbuttonParam(obj, 'SetWaitingTime', x, y, 'position', [x y 200 25], ...
%         'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1.5);
%     set_callback(SetWaitingTime, {'WaitingTimeSection','set'})
  
%     case 'set'
    
    MenuParam(obj, 'ProtocolPhase', {'water at the lateral pokes' 'wait at center poke' 'olfaction'},...
        'water at the lateral pokes', x, y, 'label','Protocol phase') %, ...
        %'labelpos', 'left', 'TooltipString','Protocol phase');
    next_row(y);

   
%     case 'next_trial',
 SoloParamHandle(obj, 'waitingTimeSet', 'value', NaN);
 SoloParamHandle(obj, 'TrialsPerBlockSet', 'value', NaN);
 
    switch value(ProtocolPhase)
        
        case {'water at the lateral pokes'}

            waitingTimeSet.value = NaN;
            TrialsPerBlockSet.value = NaN;
    
        case {'wait at center poke'}
                       
            waitingTimeSet.value = 0.2;
            TrialsPerBlockSet.value = 50;
            
            
        case {'olfaction'}

            waitingTimeSet.value = 'UnifDist';
            TrialsPerBlockSet.value = NaN;
            
    end

    SoloFunctionAddVars('WaitingTimeSection', 'rw_args', {'waitingTimeSet', 'TrialsPerBlockSet'});
    
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

    
 
  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); origfig = my_gui_info(3);

    
    feval(mfilename, obj, 'close');
    figure(origfig);
%     delete_sphandle('owner', ['^@' class(obj) '$'], ...
%       'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;