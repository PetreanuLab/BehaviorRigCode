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

function [x, y] = ChoiceSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

    case 'init',
        
    
%     SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
%     name = 'Side choices'; 
%     set(value(myfig), 'Name', name, 'Tag', name, ...
%           'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
%     set(value(myfig), 'Position', [603   600   210   110], 'Visible', 'on');
%     x = 5; y = 5;
%     gcf;

%     DispParam(obj, 'leftPort', 0, x, y, ...
%         'label', 'Left port choices', 'labelfraction', 0.75); next_row(y, 1);
%     DispParam(obj, 'rightPort', 0, x, y, ...
%         'label', 'Right port choices', 'labelfraction', 0.75); next_row(y, 1);
    
%     DispParam(obj, 'leftPortWater', 0, x, y, ...
%         'label', 'Left port choices with water', 'labelfraction', 0.75); next_row(y, 1);
%     DispParam(obj, 'rightPortWater', 0, x, y, ...
%         'label', 'Right port choices with water', 'labelfraction', 0.75); next_row(y, 1);
    
%     SubHeaderParam(obj, 'ChoiceSection', 'Choice Section', x, y); next_row(y,2);
    
    SoloParamHandle(obj, 'premature_cout');
    SoloParamHandle(obj, 'too_late');
    SoloParamHandle(obj, 'choice');
    SoloParamHandle(obj, 'correct');
    SoloParamHandle(obj, 'incorrect');
    
    SoloParamHandle(obj, 'premature_cout_conc');
    SoloParamHandle(obj, 'too_late_conc');
    SoloParamHandle(obj, 'left_poke_in_conc');
    SoloParamHandle(obj, 'right_poke_in_conc');
    SoloParamHandle(obj, 'correct_conc');
    SoloParamHandle(obj, 'error_conc');

    premature_cout.value = [];
    premature_cout.value = zeros (1,2);
    too_late.value = [];
    too_late.value = zeros (1,2);
    choice.value = [];
    choice.value = zeros (1,2);
    correct.value = [];
    correct.value = zeros (1,2);
    incorrect.value = [];
    incorrect.value = zeros (1,2);
%     disp(value(incorrect))
    
%     premature_cout_conc.value = [];
%     premature_cout_conc.value = zeros (1,2);
%     too_late_conc.value = [];
%     too_late_conc.value = zeros (1,2);
%     left_poke_in_conc.value = [];
%     left_poke_in_conc.value = zeros (1,2);
%     right_poke_in_conc.value = [];
%     right_poke_in_conc.value = zeros (1,2);
%     correct_conc.value = [];
%     correct_conc.value = zeros (1,2);
%     error_conc.value = [];
%     error_conc.value = zeros (1,2);
    
  
    SoloFunctionAddVars('PlotSection', 'ro_args', {'premature_cout', ...
        'too_late', 'choice', 'correct', 'incorrect'});
%     SoloFunctionAddVars('PlotSection', 'ro_args', {'premature_cout', ...
%         'too_late', 'choice', 'correct', 'incorrect', 'premature_cout_conc', ...
%         'too_late_conc', 'left_poke_in_conc', 'right_poke_in_conc', ...
%         'correct_conc', 'error_conc'});

   
    case 'next_trial',
        
    if n_done_trials == 0,
        return,
    end;
     
    if (~isempty(parsed_events.states.premature_cout) == 1) || (~isempty(parsed_events.states.cout_before_go_signal) == 1),
        premature_cout.value = [value(premature_cout); n_started_trials value(sideList(n_started_trials))];
%         premature_cout_conc.value = [value(premature_cout_conc); n_started_trials value(nextConcVector(n_started_trials))];
%         disp(value(premature_cout_conc));
    elseif (~isempty(parsed_events.states.too_late) == 1),
        too_late.value = [value(too_late); n_started_trials value(sideList(n_started_trials))];
%         too_late_conc.value = [value(too_late_conc); n_started_trials value(nextConcVector(n_started_trials))];
%         disp(value(too_late));
    elseif (~isempty(parsed_events.states.left_poke_in) == 1),
        choice.value = [value(choice); n_started_trials value(sideList(n_started_trials))];
%         left_poke_in_conc.value = [value(left_poke_in_conc); n_started_trials value(nextConcVector(n_started_trials))];
%         disp(value(choice));
%         leftPort.value = value(leftPort) + 1;
    elseif (~isempty(parsed_events.states.right_poke_in) == 1),
        choice.value = [value(choice); n_started_trials value(sideList(n_started_trials))];
%         right_poke_in_conc.value = [value(right_poke_in_conc); n_started_trials value(nextConcVector(n_started_trials))];
% %         disp(value(choice));
%         rightPort.value = value(rightPort) + 1;
    end
    
    if (~isempty(parsed_events.states.lin_water) == 1) || (~isempty(parsed_events.states.rin_water) == 1),
        correct.value = [value(correct); n_started_trials value(sideList(n_started_trials))];
%         correct_conc.value = [value(correct_conc); n_started_trials value(nextConcVector(n_started_trials))];
%         disp(value(correct));
%         leftPortWater.value = value(leftPortWater) + 1;
    elseif (~isempty(parsed_events.states.lin_no_water) == 1) || (~isempty(parsed_events.states.rin_no_water) == 1),
        incorrect.value = [value(incorrect); n_started_trials value(sideList(n_started_trials))];
%         error_conc.value = [value(error_conc); n_started_trials value(nextConcVector(n_started_trials))];
%         disp(value(correct));
%         rightPortWater.value = value(rightPortWater) + 1;
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