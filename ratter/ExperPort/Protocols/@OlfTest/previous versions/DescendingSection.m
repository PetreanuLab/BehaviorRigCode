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

function [x, y] = DescendingSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

    case 'init',
    
    SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
    name = 'Descending Protocol'; 
    set(value(myfig), 'Name', name, 'Tag', name, ...
          'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
    set(value(myfig), 'Position', [1000   400   832   315], 'Visible', 'on');
    x = 1; y = 1;

    NumEditParam(obj, 'nOdorConcentrations', value(nOdorConcentrations), x, y, ...
        label, 'Number of odor concentrations', 'labelfraction', 0.7); next_row(y, 1);
%     DispParam(obj, 'odorPresent', 'No', x, y, 'label', ' Odor Present'); next_row(y,1);
    DispParam(obj, 'odorConcentration', 0, x, y, 'label', 'Odor Concentration (...)'); next_row(y,1.5);
    
%     SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
%     name = 'WaitingTime'; 
%     set(value(myfig), 'Name', name, 'Tag', name, ...
%           'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
%     set(value(myfig), 'Position', [1000   400   832   315], 'Visible', 'on');
%     x = 1; y = 1;
%     
%     EditParam(obj, 'setWaitingTime1', 0.2, x, y, 'label','Set waitingTime1'); next_row(y,1);
%     EditParam(obj, 'setWaitingTime2', 0.3, x, y, 'label','Set waitingTime2'); next_row(y,1);
%     EditParam(obj, 'setWaitingTime3', 0.4, x, y, 'label','Set waitingTime3'); next_row(y,1); 
%     EditParam(obj, 'setWaitingTime4', 0.5, x, y, 'label','Set waitingTime4'); next_row(y,1);
%     MenuParam(obj, 'setWaitingTimeRnd', {'UnifDist', NaN}, 'UnifDist', ...
%         x, y, 'label','Set waitingTimeRnd'); next_row(y,1.5);

%     SubHeaderParam(obj, 'Random', 'Random', x, y); %next_row(y,2);

%     SoloParam(obj, 'valveNumber')
%     nOdorConcentrations = 4;
    if rand > 0.5
        valveNumber.value = value(nOdorConcentrations) + 1;
    else %if rand < 1/8
        valveNumber.value = ceil(nOdorConcentrations * rand);
    end 

    
    if value(valveNumber) == 1,
        odorPresent.value = 'Yes';
        odorConcentration.value = 0.1;
    elseif value(valveNumber) == 2,
        odorPresent.value = 'Yes';
        odorConcentration.value = 0.2;
    elseif value(valveNumber) == 3,
        odorPresent.value = 'Yes';
        odorConcentration.value = 0.3;
    elseif value(valveNumber) == 4,
        odorPresent.value = 'Yes';
        odorConcentration.value = 0.4;
    elseif value(valveNumber) > value(nOdorConcetrations),
        odorPresent.value = 'No';
        odorConcentration.value = 0;
    end

    
    
%     if value(valveNumber) <= value(nOdorConcetrations),
%         odorPresent.value = 'Yes';
%     elseif value(valveNumber) > value(nOdorConcetrations),
%         odorPresent.value = 'No';
%     end
    
%     NumeditParam(obj, 'TrialsPerBlock', 3, x, y, 'label', 'Trials per block'); next_row(y,1);
%     DispParam(obj, 'SwitchInNTrials', value(TrialsPerBlock), x, y, 'label', ' Switch in n trials'); next_row(y);
%     set_callback(TrialsPerBlock, {'WaitingTimeSection', 'set'});
%     SwitchInNTrials.value = value(TrialsPerBlock)+ 1;
%     DispParam(obj, 'numberTrials', 0, x, y, 'label', ' Number of trials'); next_row(y,1);
%     DispParam(obj, 'waitingTimeSet', value(setWaitingTime1), x, y, 'label','Waiting time set'); next_row(y,1);
%     DispParam(obj, 'waitingTime', value(setWaitingTime1), x, y, 'label', 'Waiting time');
%     set_callback(setWaitingTime1, {'WaitingTimeSection', 'set'}); next_row(y,1);
%     DispParam(obj, 'Performance', 0, x, y); next_row(y,1.5);
%     
%     SubHeaderParam(obj, 'blockParams', 'Block Parameters', x, y); %next_row(y,2);
    
%     figure(fig);x=oldx;y=oldy;
%     SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'ProtocolPhase', 'waitingTime'}); 

    SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'waitingTime', 'valveNumber', 'odorPresent'});
    
%       SoloFunctionAddVars('OlfactionSection', 'rw_args', {'setwaitingTime1', 'setwaitingTime4'});     
    
%     case 'switch'
%     
%         switch value(ProtocolPhase)
%             case 'water at the lateral pokes'
%                 set(value(myfig), 'Visible', 'off');
% 
%             case 'wait at center poke'
%                 set(value(myfig), 'Visible', 'on');
%                 SwitchInNTrials.value = value(TrialsPerBlock) + 1;
%                 waitingTime.value = value(setWaitingTime1);
% 
%             case 'olfaction'
%                 set(value(myfig), 'Visible', 'off');
%         end

    
%     case 'set'
%         waitingTimeSet.value = value(setWaitingTime1);
%         waitingTime.value = value(setWaitingTime1);
%         SwitchInNTrials.value = value(TrialsPerBlock) + 1;
      
   
    case 'next_trial',
        
    if n_done_trials == 0,
%         numberTrials.value = 0;
%         SwitchInNTrials.value = value(TrialsPerBlock) + 1;
        return,
    end;
    
    if rand > 0.5
        valveNumber.value = value(nOdorConcentrations) + 1;
    elseif rand < 1/8
        valveNumber.value = ceil(nOdorConcentrations * rand);
    end 

    
    
    if value(valveNumber) == 1,
        odorPresent.value = 'Yes';
        odorConcentration.value = 0.1;
    elseif value(valveNumber) == 2,
        odorPresent.value = 'Yes';
        odorConcentration.value = 0.2;
    elseif value(valveNumber) == 3,
        odorPresent.value = 'Yes';
        odorConcentration.value = 0.3;
    elseif value(valveNumber) == 4,
        odorPresent.value = 'Yes';
        odorConcentration.value = 0.4;
    elseif value(valveNumber) > value(nOdorConcetrations),
        odorPresent.value = 'No';
        odorConcentration.value = 0;
    end
    
%     numberTrials.value = value(numberTrials) + 1;
%     
% %     SoloParamHandle(obj, 'a')
% %     SoloParamHandle(obj, 'Performance')
%     
% %       for i = 1 : n_done_trials
%      if ~isempty(parsed_events.states.left_poke_in_water)  || ~isempty(parsed_events.states.right_poke_in_water),
%          a(value(numberTrials)) = 1;
%      elseif ~isempty(parsed_events.states.premature_cout) || ~isempty(parsed_events.states.too_late),
%          a(value(numberTrials)) = 0;
%      end
% %            numberTrials.value = length(a);
% %            Performance.value = cumsum(a) / length(a);
%      Performance.value = cumsum(a) / value(numberTrials);
% %       end
%       
%       if value(numberTrials) >= value(TrialsPerBlock) && value(Performance) >= 0.8
%           if value(waitingTimeSet) == value(setWaitingTime1)
%               waitingTimeSet.value = value(setWaitingTime2);
%               waitingTime.value = value(setWaitingTime2);
%           elseif value(waitingTimeSet) == value(setWaitingTime2)
%               waitingTimeSet.value = value(setWaitingTime3);
%               waitingTime.value = value(setWaitingTime3);
%           elseif value(waitingTimeSet) == value(setWaitingTime3);
%               waitingTimeSet.value = value(setWaitingTime4);
%               waitingTime.value = value(setWaitingTime4);
%           elseif value(waitingTimeSet) == value(setWaitingTime4);
%               waitingTimeSet.value = value(setWaitingTimeRnd);
%               if strcmp (value(setWaitingTimeRnd), 'UnifDist') == 1
%                   waitingTime.value = value(setWaitingTime1) + (value(setWaitingTime4) - value(setWaitingTime1)) * rand;
%               else
%                   waitingTime.value = 0;
%               end
%           end
%           numberTrials.value = 0;
%           a = [];
% %         SwitchInNTrials.value = value(TrialsPerBlock);
%       else 
%           if value(waitingTimeSet) == value(setWaitingTimeRnd);
%             if strcmp (value(setWaitingTimeRnd), 'UnifDist') == 1
%                 waitingTime.value = value(setWaitingTime1) + (value(setWaitingTime4) - value(setWaitingTime1)) * rand;
%             else
%                 waitingTime.value = 0;
%             end  
%           end
%       end
%            
%            
%     
% %     SwitchInNTrials.value = value(SwitchInNTrials) - 1;
%     
%  
% %     if value(SwitchInNTrials) == 0, 
% %         if value(waitingTimeSet) == value(setWaitingTime1)
% %             waitingTimeSet.value = value(setWaitingTime2);
% %             waitingTime.value = value(setWaitingTime2);
% %         elseif value(waitingTimeSet) == value(setWaitingTime2)
% %             waitingTimeSet.value = value(setWaitingTime3);
% %             waitingTime.value = value(setWaitingTime3);
% %         elseif value(waitingTimeSet) == value(setWaitingTime3);
% %             waitingTimeSet.value = value(setWaitingTime4);
% %             waitingTime.value = value(setWaitingTime4);
% %         elseif value(waitingTimeSet) == value(setWaitingTime4);
% %             waitingTimeSet.value = value(setWaitingTimeRnd);
% %             if strcmp (value(setWaitingTimeRnd), 'UnifDist') == 1
% %                 waitingTime.value = value(setWaitingTime1) + (value(setWaitingTime4) - value(setWaitingTime1)) * rand;
% %             else
% %                 waitingTime.value = 0;
% %             end
% % %         elseif value(waitingTimeSet) == value(setWaitingTimeRnd);
% % %             if strcmp (value(setWaitingTimeRnd), 'UnifDist') == 1
% % %                 waitingTime.value = value(setWaitingTime1) + (value(setWaitingTime4) - value(setWaitingTime1)) * rand;
% % %             else
% % %                 waitingTime.value = 0;
% % %             end
% %         end
% %         SwitchInNTrials.value = value(TrialsPerBlock);
% %     else
% %         if value(waitingTimeSet) == value(setWaitingTimeRnd);
% %             if strcmp (value(setWaitingTimeRnd), 'UnifDist') == 1
% %                 waitingTime.value = value(setWaitingTime1) + (value(setWaitingTime4) - value(setWaitingTime1)) * rand;
% %             else
% %                 waitingTime.value = 0;
% %             end
% % %         
% % %         if value(setWaitingTime) == 0.2
% % %             waitingTime.value = 0.2;
% % %         elseif value(setWaitingTime) == 0.3
% % %             waitingTime.value = 0.3;
% % %         elseif value(setWaitingTime) == 0.4
% % %             waitingTime.value = 0.4;
% % %         elseif value(setWaitingTime) == 0.5
% % %             waitingTime.value = 0.5;
% % %         elseif strcmp(value(setWaitingTime), 'UnifDist') == 1,
% % %             waitingTime.value = min + (max - min) * rand;   
% %         end
% %     end

                
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