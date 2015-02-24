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


function [x, y] = GeoDistSection(obj, action, x, y)
   
GetSoloFunctionArgs;

switch action

    case 'init',
%         SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
%         name = 'Geometric Distribution'; 
%         set(value(myfig), 'Name', name, 'Tag', name, ...
%               'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
%         set(value(myfig), 'Position', [603   100   416   400], 'Visible', 'on');
%         x = 5; y = 5;
    gcf;
        
        NumEditParam(obj, 'dStepOdor1', 0.5, x, y, 'label', 'd(Odor1) step'); next_row(y,1);
        NumEditParam(obj, 'dOdor1', 0.5, x, y, 'label', 'd(Odor1)'); next_row(y,1.2);
        NumEditParam(obj, 'dStepOdor2', 0.5, x, y, 'label', 'd(Odor2) step'); next_row(y,1);
        NumEditParam(obj, 'dOdor2', 0.5, x, y, 'label', 'd(Odor2)'); next_row(y,1.2);
        DispParam(obj, 'distributionType', 'Geometric', x, y, 'label', 'Distribution type'); next_row(y,1);        
        SubHeaderParam(obj, 'concDistHeader', 'Odor concentration distribution', x, y); next_row(y,2);

       
       
       SoloFunctionAddVars('PlotSection', 'rw_args', {'sideList', 'currentOdor', 'currentConc1', 'currentConc2', ...
           'concPlot', 'concVector1', 'concVector2', 'performance1', 'performance2'});
       SoloFunctionAddVars('ChoiceSection', 'rw_args', {'sideList', 'currentOdor'});
       SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'OlfBank', 'valveNumber', 'currentOdor'});
 

    case 'setOdorVector'
       
%        elapsedTrials.value = 0;
       elapsedOdor1Trials.value = 0;
       elapsedOdor2Trials.value = 0;
       currentPerformance1.value = 0;
       currentPerformance2.value = 0;
       
       if n_done_trials == 0,
            sideList.value = zeros(1,1000);
            sideList.value = (rand(1,1000) > value(probOdor1)) + 1;
       else
            sideList(1, n_started_trials + 2:1000) = (rand(1,length(n_started_trials + 2:1000)) > value(probOdor1)) + 1;
       end

       currentOdor(1,n_started_trials + 1) = value(sideList(1, n_started_trials + 1));
       
       concCalType.value = value(concCalType);

% -------------------------- set odor vectors --------------------------- %

       concLengthCal1.value = floor((value(concLast1) - value(concFirst1)) / value(concLogStep1)) + 1;
       concVector1.value = zeros(1,value(concLengthCal1));
       concVector1.value = value(concFirst1) - value(concLogStep1) + value(concLogStep1) * (1:value(concLengthCal1));
       invConcVector1.value = fliplr(value(concVector1));
       correct1.value = zeros(1, value(concLengthCal1));
       error1.value = zeros(1, value(concLengthCal1)); 
       performance1.value = zeros(1, value(concLengthCal1)); 

       concLengthCal2.value = floor((value(concLast2) - value(concFirst2)) / value(concLogStep2)) + 1;
       concVector2.value = zeros(1,value(concLengthCal2));
       concVector2.value = value(concFirst2) - value(concLogStep2) + value(concLogStep2) * (1:value(concLengthCal2));
       invConcVector2.value = fliplr(value(concVector2));
       correct2.value = zeros(1, value(concLengthCal2));
       error2.value = zeros(1, value(concLengthCal2));
       performance2.value = zeros(1, value(concLengthCal1));

       
%-------------------------- geometric distribution ---------------------- %
       A = 500;
       x1 = abs(fliplr(value(concVector1)));
       x2 = abs(fliplr(value(concVector2)));
       
       gd1 = round(A * (1 - geocdf(x1,value(dOdor1))) / (1 - geocdf(x1(1), value(dOdor1))));
       gd2 = round(A * (1 - geocdf(x2,value(dOdor2))) / (1 - geocdf(x2(1), value(dOdor2))));
       
       last1 = 0;
       for i = 1 : length(x1)
           first1 = 1 + last1;
           last1 = last1 + gd1(i);
           concList1(first1:last1) = i;
       end
       
%        disp(value(concList1))
%        gd1
       concList1.value = value(concList1(randperm(length(value(concList1)))));
       concList1.value = -value(concList1);

       last2 = 0;
       for i = 1 : length(x2)
           first2 = 1 + last2;
           last2 = last2 + gd2(i);
           concList2(first2:last2) = i;
       end
       
%        disp(value(concList2))
%        gd2
       concList2.value = value(concList2(randperm(length(value(concList2)))));
       concList2.value = -value(concList2);
       
%------------------------------------------------------------------------ %
       
       nextConc1.value = value(concList1(n_started_trials + 1));
       nextConc2.value = value(concList2(n_started_trials + 1));
       disp(value(nextConc1));
       disp(value(nextConc2));
       
       currentConc1.value = [];
       currentConc2.value = [];

       if value(currentOdor(1, n_started_trials + 1)) == 1;
           OlfBank.value = 'OlfBankA';
           currentConc1.value = [n_started_trials + 1 value(nextConc1)];
           valveNumber.value = find(invConcVector1 == value(nextConc1));
           nextConcVector(1, n_started_trials + 1) = value(nextConc1);
       elseif value(currentOdor(1, n_started_trials + 1)) == 2
           OlfBank.value = 'OlfBankB';
           currentConc2.value = [n_started_trials + 1 value(nextConc2)];
           valveNumber.value = find(invConcVector2 == value(nextConc2));
           nextConcVector(1, n_started_trials + 1) = value(nextConc2);
       end       

%        disp(value(OlfBank));
%        disp(value(currentConc1));
%        disp(value(currentConc2));
%        disp(value(valveNumber));
%        disp(value(nextConcVector));
       
        
    case 'next_trial',
        
       if n_done_trials == 0,
           elapsedTrials.value = 0;
           return,
       end;
       
%        elapsedTrials.value = value(elapsedTrials) + 1;
       if value(currentOdor(1, n_started_trials)) == 1
           elapsedOdor1Trials.value = value(elapsedOdor1Trials) + 1;
       elseif value(currentOdor(1, n_started_trials)) == 2
           elapsedOdor2Trials.value = value(elapsedOdor2Trials) + 1;
       end
       
       
%-------------------------------- performance ----------------------------%
       
       if ((~isempty(parsed_events.states.rin_no_water)  == 1) || (~isempty(parsed_events.states.lin_no_water) == 1)),
%             a = 'error'
            if value(currentOdor(1, n_started_trials)) == 1;
                errorOdor1.value = errorOdor1 + 1;
                error1 (find(value(concVector1) == value(nextConc1))) = ...
                    error1 (find(value(concVector1) == value(nextConc1))) + 1;
                error1.value = value(error1);
            elseif value(currentOdor(1,n_started_trials)) == 2;
                errorOdor2.value = errorOdor2 + 1;
                error2 (find(value(concVector2) == value(nextConc2))) = ...
                    error2 (find(value(concVector2) == value(nextConc2))) + 1;
                error2.value = value(error2);
            end
        elseif ((~isempty(parsed_events.states.rin_water)  == 1) || (~isempty(parsed_events.states.lin_water) == 1)),
%             b = 'correct'
            if value(currentOdor(1,n_started_trials)) == 1;
                correctOdor1.value = correctOdor1 + 1;
                correct1 (find(value(concVector1) == value(nextConc1))) = ...
                    correct1 (find(value(concVector1) == value(nextConc1))) + 1;
                correct1.value = value(correct1);
            elseif value(currentOdor(1,n_started_trials)) == 2;
                correctOdor2.value = correctOdor2 + 1;
                correct2 (find(value(concVector2) == value(nextConc2))) = ...
                    correct2 (find(value(concVector2) == value(nextConc2))) + 1;
                correct2.value = value(correct2);
            end
       end
       
       
%        if value(currentOdor(1,n_started_trials)) == 1
%            performance1.value = value(correct1) ./ (value(correct1) + value(error1));
%            overallPerformance1.value = value(correctOdor1) ./ (value(correctOdor1) + value(errorOdor1));
%            if  (0.7 <= value(overallPerformance1) <= 0.8) == 1
%                d1.value = value(d1);
%            elseif value(overallPerformance1) > 0.8
%                d1.value = value(d1) - 0.1;
%            elseif value(overallPerformance1) < 0.7
%                d1.value = value(d1) + 0.1;
%            end
%        elseif value(currentOdor(1,n_started_trials)) == 2
%            performance2.value = value(correct2) ./ (value(correct2) + value(error2));
%            overallPerformance2.value = value(correctOdor2) ./ (value(correctOdor2) + value(errorOdor2));
%            if  (0.7 <= value(overallPerformance2) <= 0.8) == 1
%                d2.value = value(d2);
%            elseif value(overallPerformance2) > 0.8
%                d2.value = value(d2) - 0.1;
%            elseif value(overallPerformance2) < 0.7
%                d2.value = value(d2) + 0.1;
%            end
%        end
       
%        overallPerformance1.value = value(correctOdor1) / (value(correctOdor1) +  value(errorOdor1));
%        overallPerformance2.value = value(correctOdor2) / (value(correctOdor2) +  value(errorOdor2));

              
    if value(currentOdor(1,n_started_trials)) == 1
        if isempty(find((elapsedOdor1Trials == value(trialsPerformance1)*(1:100)) == 1)),
            performance1.value = value(correct1) ./ (value(correct1) + value(error1));
            overallPerformance1.value = value(correctOdor1) ./ (value(correctOdor1) + value(errorOdor1));
            if  (0.7 <= value(overallPerformance1) <= 0.8) == 1
                dOdor1.value = value(dOdor1);
            elseif value(overallPerformance1) > 0.8
                dOdor1.value = value(dOdor1) - value(dStepOdor1);
                A = 500;
                x1 = abs(fliplr(value(concVector1)));
                x2 = abs(fliplr(value(concVector2)));
                gd1 = round(A * (1 - geocdf(x1,value(dOdor1))) / (1 - geocdf(x1(1), value(dOdor1))));
                gd2 = round(A * (1 - geocdf(x2,value(dOdor2))) / (1 - geocdf(x2(1), value(dOdor2))));
                last1 = 0;
                for i = 1 : length(x1)
                    first1 = 1 + last1;
                    last1 = last1 + gd1(i);
                    concList1(first1:last1) = i;
                end
%                 disp(value(concList1))
%                 gd1
                concList1.value = value(concList1(randperm(length(value(concList1)))));
                concList1.value = -value(concList1);
            elseif value(overallPerformance1) < 0.7
                dOdor1.value = value(dOdor1) + value(dStepOdor1);
                A = 500;
                x1 = abs(fliplr(value(concVector1)));
                x2 = abs(fliplr(value(concVector2)));
                gd1 = round(A * (1 - geocdf(x1,value(dOdor1))) / (1 - geocdf(x1(1), value(dOdor1))));
                gd2 = round(A * (1 - geocdf(x2,value(dOdor2))) / (1 - geocdf(x2(1), value(dOdor2))));
                last1 = 0;
                for i = 1 : length(x1)
                    first1 = 1 + last1;
                    last1 = last1 + gd1(i);
                    concList1(first1:last1) = i;
                end
%                 disp(value(concList1))
%                 gd1
                concList1.value = value(concList1(randperm(length(value(concList1)))));
                concList1.value = -value(concList1);
            end
            nextConc1.value = value(concList1(n_started_trials + 1));
            correctOdor1.value = 0;
            errorOdor1.value = 0;
            overallPerformance1.value = 0;
    elseif value(currentOdor(1,n_started_trials)) == 2
        elseif isempty(find((elapsedOdor2Trials == value(trialsPerformance1)*(1:100)) == 1)),
            performance2.value = value(correct2) ./ (value(correct2) + value(error2));
            overallPerformance2.value = value(correctOdor2) ./ (value(correctOdor2) + value(errorOdor2));
            if  (0.7 <= value(overallPerformance2) <= 0.8) == 1
                dOdor2.value = value(dOdor2);
            elseif value(overallPerformance2) > 0.8
                dOdor2.value = value(dOdor2) - value(dStepOdor1);
                last2 = 0;
                for i = 1 : length(x2)
                   first2 = 1 + last2;
                   last2 = last2 + gd2(i);
                   concList2(first2:last2) = i;
                end
            %        disp(value(concList2))
            %        gd2
                concList2.value = value(concList2(randperm(length(value(concList2)))));
                concList2.value = -value(concList2);
            elseif value(overallPerformance2) < 0.7
                dOdor2.value = value(dOdor2) + value(dStepOdor1);
                last2 = 0;
                for i = 1 : length(x2)
                   first2 = 1 + last2;
                   last2 = last2 + gd2(i);
                   concList2(first2:last2) = i;
                end
            %        disp(value(concList2))
            %        gd2
                concList2.value = value(concList2(randperm(length(value(concList2)))));
                concList2.value = -value(concList2);
            end
            nextConc2.value = value(concList2(n_started_trials + 1));
            correctOdor2.value = 0;
            errorOdor2.value = 0;
            overallPerformance2.value = 0;
        end
    end
% ------------%
       
       disp(value(nextConc1));
       disp(value(nextConc2));
               
       currentOdor(1,n_started_trials + 1) = value(sideList(1, n_started_trials + 1));
%        disp(value(currentOdor));
       
        if value(currentOdor(1,n_started_trials + 1)) == 1,
           OlfBank.value = 'OlfBankA';
           currentConc1.value = [value(currentConc1); n_started_trials + 1 value(nextConc1)];
%            disp(value(currentConc1))
%            invConcVector1 = fliplr(value(concVector1));
           valveNumber.value = find(invConcVector1 == value(nextConc1));
           nextConcVector(1, n_started_trials + 1) = value(nextConc1);
        elseif value(currentOdor(1,n_started_trials + 1)) == 2,
           OlfBank.value = 'OlfBankB';
%            currentConc2.value = [n_started_trials + 1 value(concVector2(end))];
           currentConc2.value = [value(currentConc2); n_started_trials + 1 value(nextConc2)];
%            disp(value(currentConc2))
%            invConcVector2 = fliplr(value(concVector2));
           valveNumber.value = find(invConcVector2 == value(nextConc2));
           nextConcVector(1, n_started_trials + 1) = value(nextConc2);
       end       

%        disp(value(OlfBank));
%        disp(value(valveNumber));
%        disp(value(nextConcVector));
       
        

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