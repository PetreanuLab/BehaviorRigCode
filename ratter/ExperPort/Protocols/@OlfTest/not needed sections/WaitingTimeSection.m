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

function [x, y] = WaitingTimeSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

    case 'init',
    
        
    SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
    name = 'WaitingTime'; 
    set(value(myfig), 'Name', name, 'Tag', name, ...
          'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
    set(value(myfig), 'Position', [1000   400   832   315], 'Visible', 'on');
    x = 1; y = 1;
    
    
    NumeditParam(obj, 'minWaitingTime', 0.2, x, y, 'label','Minimum waiting time',...
              'labelfraction', 0.53); next_row(y,1);
%         set_callback(minWaitingTime, {'OlfactionSection', 'set'});
    NumeditParam(obj, 'maxWaitingTime', 0.5, x, y, 'label','Maximum waiting time',...
              'labelfraction', 0.53); next_row(y,2);  
%         set_callback(maxWaitingTime, {'OlfactionSection', 'set'});

    PushbuttonParam(obj, 'SetWaitingTime1', x, y, 'position', [x y 200 25], ...
          'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1);
    set_callback(SetWaitingTime1, {'WaitingTimeSection', 'set1'});% next_row(y,1);
    EditParam(obj, 'setWaitingTime1', 0.2, x, y, 'label','Set waitingTime1'); next_row(y,1.5);
    
    PushbuttonParam(obj, 'SetWaitingTime2', x, y, 'position', [x y 200 25], ...
          'BackgroundColor', [0.75 0.75 0.80]); next_row(y);
    set_callback(SetWaitingTime2, {'WaitingTimeSection', 'set2'}); %next_row(y,1);
    EditParam(obj, 'setWaitingTime2', 0.3, x, y, 'label','Set waitingTime2'); next_row(y,1.5);
    
    PushbuttonParam(obj, 'SetWaitingTime3', x, y, 'position', [x y 200 25], ...
          'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1);
    set_callback(SetWaitingTime3, {'WaitingTimeSection', 'set3'}); %next_row(y,1);
    EditParam(obj, 'setWaitingTime3', 0.4, x, y, 'label','Set waitingTime3'); next_row(y,1.5); 
    
    PushbuttonParam(obj, 'SetWaitingTime4', x, y, 'position', [x y 200 25], ...
          'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1);
    set_callback(SetWaitingTime4, {'WaitingTimeSection', 'set4'}); %next_row(y,1);
    EditParam(obj, 'setWaitingTime4', 0.5, x, y, 'label','Set waitingTime4'); next_row(y,1.5);

    PushbuttonParam(obj, 'SetWaitingTimeRandom', x, y, 'position', [x y 200 25], ...
          'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1);
    set_callback(SetWaitingTimeRandom, {'WaitingTimeSection', 'setRnd'}); %next_row(y,1);
    MenuParam(obj, 'setWaitingTimeRnd', {'UnifDist', NaN}, 'UnifDist', ...
        x, y, 'label','Set waitingTimeRnd'); next_row(y,1.5);
    
    SubHeaderParam(obj, 'waitingTimeParams', 'Waiting Time Parameters', x, y); next_row(y,2);
    
    NumeditParam(obj, 'TrialsPerBlockTraining', 0, x, y, 'label', 'Trials per block_Training', ...
        'labelfraction', 0.6); next_row(y,1);
    NumeditParam(obj, 'TrialsPerBlock', 1000, x, y, 'label', 'Trials per block', ...
        'labelfraction', 0.6); next_row(y,1);
%     DispParam(obj, 'SwitchInNTrials', value(TrialsPerBlock), x, y, 'label', ' Switch in n trials'); next_row(y);
%     set_callback(TrialsPerBlock, {'WaitingTimeSection', 'set'});
%     SwitchInNTrials.value = value(TrialsPerBlock)+ 1;
    DispParam(obj, 'numberTrials', 0, x, y, 'label', ' Number of trials'); next_row(y,1);
    DispParam(obj, 'waitingTimeSet', 0, x, y, 'label','Waiting time set'); next_row(y,1);
    DispParam(obj, 'waitingTime', 0, x, y, 'label', 'Waiting time'); next_row(y,1);
    
%     NumEditParam(obj, 'setPerformance', 0, x, y); next_row(y,1);
    DispParam(obj, 'Performance', 0, x, y); next_row(y,1.5);
    %     PushbuttonParam(obj, 'SetPerformance', x, y, 'label','Set Performance', ...
%         'position', [x y 200 25], 'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1);
%     set_callback(SetPerformance, {'WatingTimeSection', 'setPerformance'}); %next_row(y,1);

    SubHeaderParam(obj, 'blockParams', 'Block Parameters', x, y); %next_row(y,2);
    
%     figure(fig);x=oldx;y=oldy;
%     SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'ProtocolPhase', 'waitingTime'});    
    SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'waitingTime'});
%       SoloFunctionAddVars('OlfactionSection', 'rw_args', {'setwaitingTime1', 'setwaitingTime4'});     
    
    SoloParamHandle(obj, 'waitingTimeVector');
    waitingTimeVector.value = zeros(1,1000);
%     waitingTime.value = value(waitingTimeVector(1, n_started_trials + 1));

    numberTrials.value = value(numberTrials);% + 1;
    
    SoloParamHandle(obj, 'sum_score', 'value', 0);

    case 'set1'
        waitingTimeSet.value = value(setWaitingTime1);
        waitingTime.value = value(waitingTimeSet);
        numberTrials.value = 0;
        sum_score.value = 0;
        Performance.value = 0;
    
    case 'set2'
        waitingTimeSet.value = value(setWaitingTime2);
        waitingTime.value = value(waitingTimeSet);
        numberTrials.value = 0;
        sum_score.value = 0;
        Performance.value = 0;
        
    case 'set3'
        waitingTimeSet.value = value(setWaitingTime3);
        waitingTime.value = value(waitingTimeSet);
        numberTrials.value = 0;
        sum_score.value = 0;
        Performance.value = 0;
    
    case 'set4'
        waitingTimeSet.value = value(setWaitingTime4);
        waitingTime.value = value(waitingTimeSet);
        numberTrials.value = 0;
        sum_score.value = 0;
        Performance.value = 0;
        
    case 'setRnd'
        if strcmp (value(setWaitingTimeRnd), 'UnifDist') == 1
            waitingTimeSet.value = value(setWaitingTimeRnd);
            waitingTimeVector.value = value(minWaitingTime) + (value(maxWaitingTime) - ...
                value(minWaitingTime)) * rand(1,1000);
            waitingTime.value = value(waitingTimeVector(1, n_started_trials + 1));
        else
            waitingTime.value = 0;
        end
       
        
        

%         SwitchInNTrials.value = value(TrialsPerBlock) + 1;
      
   
    case 'next_trial',
        
    if n_done_trials == 0,
        numberTrials.value = 0;
%         SwitchInNTrials.value = value(TrialsPerBlock) + 1;
        return,
    end;
    
%     sum_score = 0
%     score = [];
    numberTrials.value = value(numberTrials) + 1;
    trials = value(numberTrials);


%     SoloParamHandle(obj, 'Performance')
    
    a=0;
    if value(numberTrials) > value(TrialsPerBlockTraining),

        if (~isempty(parsed_events.states.lin_water) == 1) ||...
                (~isempty(parsed_events.states.rin_water) == 1),
            a = 1;
    %         a.value = 1;
              score(trials) = value(a);
        elseif (~isempty(parsed_events.states.premature_cout) == 1) ||...
                (~isempty(parsed_events.states.too_late) == 1) || ...
                (~isempty(parsed_events.states.left_poke_in) == 1) ||...
                (~isempty(parsed_events.states.right_poke_in) == 1),
            a = 0;
        end

%         a;
        sum_score.value = a + value(sum_score);
        disp(value(sum_score))
   %      score(trials) = value(a)
   %      score
   %            numberTrials.value = length(a);
   %            Performance.value = cumsum(a) / length(a);
   %     value(numberTrials)
   %     value(a) 
       Performance.value = value(sum_score) / (trials - value(TrialsPerBlockTraining));
   %       end
%        numberTrials.value = 0;
      
        if (value(numberTrials) >= value(TrialsPerBlock)) && (value(Performance) >= 0.8)
            if value(waitingTimeSet) == value(setWaitingTime1)
                waitingTimeSet.value = value(setWaitingTime2);
                waitingTime.value = value(setWaitingTime2);
            elseif value(waitingTimeSet) == value(setWaitingTime2)
                waitingTimeSet.value = value(setWaitingTime3);
                waitingTime.value = value(setWaitingTime3);
            elseif value(waitingTimeSet) == value(setWaitingTime3);
                waitingTimeSet.value = value(setWaitingTime4);
               waitingTime.value = value(setWaitingTime4);
            elseif value(waitingTimeSet) == value(setWaitingTime4);
                if value(waitingTimeSet) < value(maxWaitingTime),
                    waitingTimeSet.value = value(setWaitingTime4);
                elseif value(setWaitingTime4) == value(maxWaitingTime),
                    waitingTimeSet.value = value(setWaitingTimeRnd);
                    if strcmp (value(setWaitingTimeRnd), 'UnifDist') == 1
                        waitingTime.value = value(waitingTimeVector(1, n_started_trials + 1));
%                         waitingTime.value = value(minWaitingTime) + (value(maxWaitingTime) - value(minWaitingTime)) * rand;
                    else
                      waitingTime.value = 0;
                    end
                end
            end
            numberTrials.value = 0;
            sum_score.value = 0;
            Performance.value = 0;
%         SwitchInNTrials.value = value(TrialsPerBlock);
        end
    end
%         else 
            if value(waitingTimeSet) == value(setWaitingTimeRnd);
              if strcmp (value(setWaitingTimeRnd), 'UnifDist') == 1
                  waitingTime.value = value(waitingTimeVector(1, n_started_trials + 1));
%                   waitingTime.value = value(WaitingTimeMin) + (value(WaitingTimeMax) - value(WaitingTimeMin)) * rand;
              else
                  waitingTime.value = 0;
              end  
            end
%         end
%     end
           
           
    
%     SwitchInNTrials.value = value(SwitchInNTrials) - 1;
    
 
%     if value(SwitchInNTrials) == 0, 
%         if value(waitingTimeSet) == value(setWaitingTime1)
%             waitingTimeSet.value = value(setWaitingTime2);
%             waitingTime.value = value(setWaitingTime2);
%         elseif value(waitingTimeSet) == value(setWaitingTime2)
%             waitingTimeSet.value = value(setWaitingTime3);
%             waitingTime.value = value(setWaitingTime3);
%         elseif value(waitingTimeSet) == value(setWaitingTime3);
%             waitingTimeSet.value = value(setWaitingTime4);
%             waitingTime.value = value(setWaitingTime4);
%         elseif value(waitingTimeSet) == value(setWaitingTime4);
%             waitingTimeSet.value = value(setWaitingTimeRnd);
%             if strcmp (value(setWaitingTimeRnd), 'UnifDist') == 1
%                 waitingTime.value = value(setWaitingTime1) + (value(setWaitingTime4) - value(setWaitingTime1)) * rand;
%             else
%                 waitingTime.value = 0;
%             end
% %         elseif value(waitingTimeSet) == value(setWaitingTimeRnd);
% %             if strcmp (value(setWaitingTimeRnd), 'UnifDist') == 1
% %                 waitingTime.value = value(setWaitingTime1) + (value(setWaitingTime4) - value(setWaitingTime1)) * rand;
% %             else
% %                 waitingTime.value = 0;
% %             end
%         end
%         SwitchInNTrials.value = value(TrialsPerBlock);
%     else
%         if value(waitingTimeSet) == value(setWaitingTimeRnd);
%             if strcmp (value(setWaitingTimeRnd), 'UnifDist') == 1
%                 waitingTime.value = value(setWaitingTime1) + (value(setWaitingTime4) - value(setWaitingTime1)) * rand;
%             else
%                 waitingTime.value = 0;
%             end
% %         
% %         if value(setWaitingTime) == 0.2
% %             waitingTime.value = 0.2;
% %         elseif value(setWaitingTime) == 0.3
% %             waitingTime.value = 0.3;
% %         elseif value(setWaitingTime) == 0.4
% %             waitingTime.value = 0.4;
% %         elseif value(setWaitingTime) == 0.5
% %             waitingTime.value = 0.5;
% %         elseif strcmp(value(setWaitingTime), 'UnifDist') == 1,
% %             waitingTime.value = min + (max - min) * rand;   
%         end
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