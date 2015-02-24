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

function [x, y] = WaterSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

    case 'init',
    
%     SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
%     name = 'Side choices'; 
%     set(value(myfig), 'Name', name, 'Tag', name, ...
%           'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
%     set(value(myfig), 'Position', [1000   400   832   315], 'Visible', 'on');
%     x = 1; y = 1;
    gcf;
% 
    
    DispParam(obj, 'lValve', 0.126, x, y, 'label', 'Left valve open time', 'labelfraction', 0.6);next_row(y,1);
    DispParam(obj, 'rValve', 0.127, x, y, 'label', 'Right valve open time', 'labelfraction', 0.6);next_row(y, 1.5);
    
    PushbuttonParam(obj, 'SetValvesOpeningMatrix', x, y, 'label','Set valves opening matrix', ...
        'position', [x y 200 25], 'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1);
    set_callback(SetValvesOpeningMatrix, {'WaterSection', 'setValvesOpeningMatrix'}); %next_row(y,1);
    NumEditParam(obj, 'probLvalve', 1, x, y, 'label', 'Prob. left valve'); next_row(y,1);
    NumEditParam(obj, 'probRvalve', 1, x, y, 'label', 'Prob. right valve');next_row(y,1.1);
    NumEditParam(obj, 'timeLvalve', 0.126, x, y, 'label', 'Time left valve'); next_row(y,1);
    NumEditParam(obj, 'timeRvalve', 0.27, x, y, 'label', 'Time right valve');next_row(y,1.2);
    MenuParam(obj, 'waterDelChange', {'Volume', 'Probability'}, 'Volume', ...
        x, y, 'label', 'Water delivery change', 'labelfraction', 0.6); next_row(y,1.5);
    
    NumEditParam(obj, 'nTrialsBonus', 3, x, y, 'label', 'number of Trials');next_row(y,1.1);
    DispParam(obj, 'lSmallRewTime', 0.1, x, y, 'label', 'Left small reward', 'labelfraction', 0.6);next_row(y,1);
    DispParam(obj, 'rSmallRewTime', 0.1, x, y, 'label', 'Right small reward', 'labelfraction', 0.6);next_row(y,1);
    DispParam(obj, 'lLargeRewTime', 0.5, x, y, 'label', 'Left large reward', 'labelfraction', 0.6);next_row(y,1);
    DispParam(obj, 'rLargeRewTime', 0.5, x, y, 'label', 'Right large reward', 'labelfraction', 0.6);next_row(y,1);
    MenuParam(obj, 'bonus', {'Off', 'On'}, 'Off', ...
        x, y, 'label', 'Bonus', 'labelfraction', 0.6); next_row(y,1); 
    SubHeaderParam(obj, 'waterValvesParams', 'Water Valves', x, y); next_row(y,2);    
    
    SoloParamHandle(obj, 'valvesOpening');
    valvesOpening.value = ones(2,1000);
    
    SoloParamHandle(obj, 'counterCorrect');
    counterCorrect.value = 0;

    
    SoloFunctionAddVars('StateMatrixSection', 'rw_args', ...
        {'rValve', 'lValve'});

    
    case 'setValvesOpeningMatrix'
        switch value(bonus)
        case 'Off'
            switch value(waterDelChange)
                case 'Volume'
                    lValve.value = value(timeLvalve);
                    rValve.value = value(timeRvalve);
                case 'Probability'
                        valvesOpening(1,:) = rand (1,1000) < value(probRvalve);
                        valvesOpening(2,:) = rand (1,1000) < value(probLvalve);
%                         disp(value(valvesOpening))
                        if value(valvesOpening(1,n_started_trials + 1)) == 0,
                            rValve.value = 0.001;
                        elseif value(valvesOpening(1,n_started_trials + 1)) == 1,
                            rValve.value = value(timeRvalve);
                        end
                        if value(valvesOpening(2,n_started_trials + 1)) == 0,
                            lValve.value = 0.001;
                        elseif value(valvesOpening(2,n_started_trials + 1)) == 1,
                            lValve.value = value(timeLvalve);  
                        end
            end
        case 'On'
            lValve.value = value(lSmallRewTime);% calibrar rig para 15 uL....
            rValve.value = value(rSmallRewTime);% calibrar rig para 15 uL...
        end
    
    
    case 'next_trial',
        
    if n_done_trials == 0,
        return,
    end;

%     disp(value(timeLvalve));
%     disp(value(timeRvalve));
    


    switch value(bonus)
        case 'Off'
            switch value(waterDelChange)
                case 'Volume'
                    lValve.value = value(timeLvalve);
                    rValve.value = value(timeRvalve);
                case 'Probability'
                    if value(valvesOpening(1,n_started_trials + 1)) == 0,
                        rValve.value = 0.001;
                    elseif value(valvesOpening(1,n_started_trials + 1)) == 1,
                        rValve.value = value(timeRvalve);
                    end
                    if value(valvesOpening(2,n_started_trials + 1)) == 0,
                        lValve.value = 0.001;
                    elseif value(valvesOpening(2,n_started_trials + 1)) == 1,
                        lValve.value = value(timeLvalve);  
                    end
            end
        case 'On'
            if ((~isempty(parsed_events.states.rin_water)  == 1) || (~isempty(parsed_events.states.lin_water) == 1))
               counterCorrect.value = value(counterCorrect) + 1;
            end
            if value(counterCorrect) == value(nTrialsBonus)
                lValve.value = value(lLargeRewTime);% calibrar rig para 40 uL....
                rValve.value = value(rLargeRewTime);% calibrar rig para 40 uL....
                counterCorrect.value = 0;
            else
                lValve.value = value(lSmallRewTime);% calibrar rig para 15 uL....
                rValve.value = value(rSmallRewTime);% calibrar rig para 15 uL....
            end
%             disp(value(counterCorrect))
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

    
 
end;