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


function [x, y] = OdorSection(obj, action, x, y)
   
GetSoloFunctionArgs;


switch action

    case 'init',
        SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
        name = 'Odors / Performance / Bias'; 
        set(value(myfig), 'Name', name, 'Tag', name, ...
              'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        set(value(myfig), 'Position', [20   40   830   950], 'Visible', 'on');
        x = 5; y = 5;
%     gcf;

        DispParam(obj, 'valveNumber', 0, x, y, 'label', 'Current valve number', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'OlfBank', 'OlfBankA', x, y, 'label', 'Current bank', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'currentConcORRatio', NaN, x, y, 'label', 'Current stimulus', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'currentOdorORMix', NaN, x, y, 'label', 'Current stimulus identity', 'labelfraction', 0.7); next_row(y,2);

        PushbuttonParam(obj, 'SetOdorVector', x, y,'label','Set stimulus vector',...
            'position', [x y 200 50], 'BackgroundColor', [0.1 0.5 0.5]); next_row(y,3);
        set_callback(SetOdorVector, {'OdorSection', 'setOdorVector'; ...
            'ChoiceSection', 'setOSTVector'; 'PlotSection', 'startPlot'});

        DispParam(obj, 'lengthCal', NaN, x, y, 'label', 'Calculated length'); next_row(y,1);        
        NumEditParam(obj, 'lastValue', NaN, x, y, 'label', 'Last value'); next_row(y,1);
        NumEditParam(obj, 'firstValue', NaN, x, y, 'label', 'First value'); next_row(y,1);
        NumEditParam(obj, 'logStep', NaN, x, y, 'label', 'Log step'); next_row(y,1);
%         disp(value(logStep))
        
        SoloParamHandle(obj, 'stimVector');
        stimVector.value = 0;
        SubHeaderParam(obj, 'stimHeader', 'Odor stimuli parameters', x, y); next_row(y,2);

        DispParam(obj, 'elapsedMix2Trials', 0, x, y, 'label', 'Elapsed trials', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'elapsedMix2ValidTrials', 0, x, y, 'label', 'Elapsed valid trials', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'wPerfMix2NR', 0, x, y, 'label', 'Performance', 'labelfraction', 0.7); next_row(y,1);
        EditParam(obj, 'Mix2', 'NaN', x, y, 'label', 'Mix #2', 'labelfraction', 0.55); next_row(y,1.3);
        
        DispParam(obj, 'elapsedMix1Trials', 0, x, y, 'label', 'Elapsed trials', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'elapsedMix1ValidTrials', 0, x, y, 'label', 'Elapsed valid trials', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'wPerfMix1NR', 0, x, y, 'label', 'Performance', 'labelfraction', 0.7); next_row(y,1);
        EditParam(obj, 'Odor1', 'NaN', x, y, 'label', 'Mix #1', 'labelfraction', 0.55); next_row(y,1.3);

        DispParam(obj, 'elapsedOdor2Trials', 0, x, y, 'label', 'Elapsed trials', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'elapsedOdor2ValidTrials', 0, x, y, 'label', 'Elapsed valid trials', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'wPerfOdor2NR', 0, x, y, 'label', 'Performance', 'labelfraction', 0.7); next_row(y,1);
        EditParam(obj, 'Odor2', 'R-(-)-2-Octanol', x, y, 'label', 'Odor #2', 'labelfraction', 0.55); next_row(y,1.3);
        
        DispParam(obj, 'elapsedOdor1Trials', 0, x, y, 'label', 'Elapsed trials', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'elapsedOdor1ValidTrials', 0, x, y, 'label', 'Elapsed valid trials', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'wPerfOdor1NR', 0, x, y, 'label', 'Performance', 'labelfraction', 0.7); next_row(y,1);
        EditParam(obj, 'Odor1', 'S-(+)-2-Octanol', x, y, 'label', 'Odor #1', 'labelfraction', 0.55); next_row(y,1);

        SubHeaderParam(obj, 'odorHeader', 'Odor stimuli', x, y); next_row(y,2);
        
        NumEditParam(obj, 'contextTaskTrialsPerBlock', NaN, x, y, 'label', 'Context task _ trials per block', ...
            'labelfraction', 0.8); next_row(y,1.2);
        NumEditParam(obj, 'stim4ForContext', NaN, x, y, 'label', 'Context task _ Stim 4', ...
            'labelfraction', 0.7); next_row(y,1);
        NumEditParam(obj, 'stim3ForContext', NaN, x, y, 'label', 'Context task _ Stim 3', ...
            'labelfraction', 0.7); next_row(y,1);
        NumEditParam(obj, 'stim2ForContext', NaN, x, y, 'label', 'Context task _ Stim 2', ...
            'labelfraction', 0.7); next_row(y,1);
        NumEditParam(obj, 'stim1ForContext', NaN, x, y, 'label', 'Context task _ Stim 1', ...
            'labelfraction', 0.7); next_row(y,1.1);
        MenuParam(obj, 'contextTask', {'Yes', 'No'}, 'No', x, y, ...
            'label', 'Context task', ...
            'labelfraction', 0.7); next_row(y,2);
        
        NumEditParam(obj, 'blockTaskTrialsPerBlock', NaN, x, y, 'label', 'Block task _ trials per block', ...
            'labelfraction', 0.8); next_row(y,1.2);
        MenuParam(obj, 'blockTaskFirstBlock', {'Concentration task', 'Mixture task'}, ...
            'Concentration task', x, y, 'labelfraction', 0.6, 'label','Block task _ 1st block'); next_row(y,2.35);
        
        MenuParam(obj, 'taskIdentity', {'Concentration task', 'Mixture task', 'Both - blocks', ...
            'Both - interleaved'}, ...
            'Concentration task', x, y, 'labelfraction', 0.6, 'label','Task identity'); next_row(y,2.35);
        
        MenuParam(obj, 'stim1Side', {'Left', 'Right'}, ...
            'Left', x, y, 'labelfraction', 0.6, 'label','Stimulus1 reward side'); next_row(y,1);

        
        next_column(x); 
        y = 5;
        
        
        PushbuttonParam(obj, 'SetBankAssignment', x, y,'label','Assign banks',...
            'position', [x y 200 50], 'BackgroundColor', [0.1 0.5 0.5]); next_row(y,5);
        set_callback(SetBankAssignment, {'OdorSection', 'setBankAssignment'});

        
        NumEditParam(obj, 'stim4Mix2Bank', NaN, x, y, 'label', 'Stim 4'); next_row(y,1);
        NumEditParam(obj, 'stim3Mix2Bank', NaN, x, y, 'label', 'Stim 3'); next_row(y,1);
        NumEditParam(obj, 'stim2Mix2Bank', NaN, x, y, 'label', 'Stim 2'); next_row(y,1);
        NumEditParam(obj, 'stim1Mix2Bank', NaN, x, y, 'label', 'Stim 1'); next_row(y,1);
        SubHeaderParam(obj, 'mix2BankHeader', 'Mix 2', x, y); next_row(y,4);
        NumEditParam(obj, 'stim4Mix1Bank', NaN, x, y, 'label', 'Stim 4'); next_row(y,1);
        NumEditParam(obj, 'stim3Mix1Bank', NaN, x, y, 'label', 'Stim 3'); next_row(y,1);
        NumEditParam(obj, 'stim2Mix1Bank', NaN, x, y, 'label', 'Stim 2'); next_row(y,1);
        NumEditParam(obj, 'stim1Mix1Bank', NaN, x, y, 'label', 'Stim 1'); next_row(y,1);
        SubHeaderParam(obj, 'mix1BankHeader', 'Mix 1', x, y); next_row(y,4);
        NumEditParam(obj, 'stim4Odor2Bank', NaN, x, y, 'label', 'Stim 4'); next_row(y,1);
        NumEditParam(obj, 'stim3Odor2Bank', NaN, x, y, 'label', 'Stim 3'); next_row(y,1);
        NumEditParam(obj, 'stim2Odor2Bank', NaN, x, y, 'label', 'Stim 2'); next_row(y,1);
        NumEditParam(obj, 'stim1Odor2Bank', NaN, x, y, 'label', 'Stim 1'); next_row(y,1);
        SubHeaderParam(obj, 'odor2BankHeader', 'Odor 2', x, y); next_row(y,4);
        NumEditParam(obj, 'stim4Odor1Bank', NaN, x, y, 'label', 'Stim 4'); next_row(y,1);
        NumEditParam(obj, 'stim3Odor1Bank', NaN, x, y, 'label', 'Stim 3'); next_row(y,1);
        NumEditParam(obj, 'stim2Odor1Bank', NaN, x, y, 'label', 'Stim 2'); next_row(y,1);
        NumEditParam(obj, 'stim1Odor1Bank', NaN, x, y, 'label', 'Stim 1'); next_row(y,1);
        SubHeaderParam(obj, 'odor1BankHeader', 'Odor 1', x, y); next_row(y,3);
        
        SubHeaderParam(obj, 'bankAssignmentHeader', 'Bank assignment (1 = easiest)', x, y); next_row(y,2);
        
        
        next_column(x); 
        y = 5;
        
        
        PushbuttonParam(obj, 'SetValveAssignment', x, y,'label','Assign valves',...
            'position', [x y 200 50], 'BackgroundColor', [0.1 0.5 0.5]); next_row(y,5);
        set_callback(SetValveAssignment, {'OdorSection', 'setValveAssignment'});
        
        NumEditParam(obj, 'stim4Mix2Valve', NaN, x, y, 'label', 'Stim 4'); next_row(y,1);
        NumEditParam(obj, 'stim3Mix2Valve', NaN, x, y, 'label', 'Stim 3'); next_row(y,1);
        NumEditParam(obj, 'stim2Mix2Valve', NaN, x, y, 'label', 'Stim 2'); next_row(y,1);
        NumEditParam(obj, 'stim1Mix2Valve', NaN, x, y, 'label', 'Stim 1'); next_row(y,1);
        SubHeaderParam(obj, 'mix2ValveHeader', 'Mix 2', x, y); next_row(y,4);
        NumEditParam(obj, 'stim4Mix1Valve', NaN, x, y, 'label', 'Stim 4'); next_row(y,1);
        NumEditParam(obj, 'stim3Mix1Valve', NaN, x, y, 'label', 'Stim 3'); next_row(y,1);
        NumEditParam(obj, 'stim2Mix1Valve', NaN, x, y, 'label', 'Stim 2'); next_row(y,1);
        NumEditParam(obj, 'stim1Mix1Valve', NaN, x, y, 'label', 'Stim 1'); next_row(y,1);
        SubHeaderParam(obj, 'mix1ValveHeader', 'Mix 1', x, y); next_row(y,4);
        NumEditParam(obj, 'stim4Odor2Valve', NaN, x, y, 'label', 'Stim 4'); next_row(y,1);
        NumEditParam(obj, 'stim3Odor2Valve', NaN, x, y, 'label', 'Stim 3'); next_row(y,1);
        NumEditParam(obj, 'stim2Odor2Valve', NaN, x, y, 'label', 'Stim 2'); next_row(y,1);
        NumEditParam(obj, 'stim1Odor2Valve', NaN, x, y, 'label', 'Stim 1'); next_row(y,1);
        SubHeaderParam(obj, 'odor2ValveHeader', 'Odor 2', x, y); next_row(y,4);
        NumEditParam(obj, 'stim4Odor1Valve', NaN, x, y, 'label', 'Stim 4'); next_row(y,1);
        NumEditParam(obj, 'stim3Odor1Valve', NaN, x, y, 'label', 'Stim 3'); next_row(y,1);
        NumEditParam(obj, 'stim2Odor1Valve', NaN, x, y, 'label', 'Stim 2'); next_row(y,1);
        NumEditParam(obj, 'stim1Odor1Valve', NaN, x, y, 'label', 'Stim 1'); next_row(y,1);
        SubHeaderParam(obj, 'odor1ValveHeader', 'Odor 1', x, y); next_row(y,3);
        
        SubHeaderParam(obj, 'valveAssignmentHeader', 'Valve assignment (1 = easiest)', x, y); next_row(y,2);

        
        next_column(x); 
        y = 5;
        
        
%         NumEditParam(obj, 'dStepStimMix', 0.5, x, y, 'label', 'Step mix', ...
%             'labelfraction', 0.7); next_row(y,1);
        NumEditParam(obj, 'dStimMix', 0.5, x, y, 'label', 'Difficulty  parameter mix', ...
            'labelfraction', 0.7); next_row(y,1.2);
%         NumEditParam(obj, 'dStepStimConc', 0.5, x, y, 'label', 'Step conc', ...
%             'labelfraction', 0.7); next_row(y,1);
        NumEditParam(obj, 'dStimConc', 0.5, x, y, 'label', 'Difficulty  parameter conc', ...
            'labelfraction', 0.7); next_row(y,1.2);
        DispParam(obj, 'distributionType', 'Geometric', x, y, 'label', 'Distribution type', ...
            'labelfraction', 0.7); next_row(y,1);
        SubHeaderParam(obj, 'stimDistHeader', 'Odor stimuli distribution', x, y); next_row(y,2);
        
        PushbuttonParam(obj, 'SetPerfDiffFunction', x, y,'label','Set performance / difficulty function',...
            'position', [x y 200 30], 'BackgroundColor', [0.1 0.5 0.5]); next_row(y,2);
        set_callback(SetPerfDiffFunction, {'OdorSection', 'setPerfDiffFunction'});
        
        NumEditParam(obj, 'slopePerfCont', 0.05, x, y, 'label', 'Slope Context', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'thresholdPerfCont', 0.8, x, y, 'label', 'Threshold Context', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'A1PerfCont', 0.0001, x, y, 'label', 'A1 Context', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'A2PerfCont', 0.999, x, y, 'label', 'A2 Context', 'labelfraction', 0.6); next_row(y,1.2);
        
        NumEditParam(obj, 'slopePerfMix', 0.05, x, y, 'label', 'Slope mix', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'thresholdPerfMix', 0.8, x, y, 'label', 'Threshold mix', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'A1PerfMix', 0.0001, x, y, 'label', 'A1 mix', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'A2PerfMix', 0.999, x, y, 'label', 'A2 mix', 'labelfraction', 0.6); next_row(y,1.2);
        
        NumEditParam(obj, 'slopePerfConc', 0.05, x, y, 'label', 'Slope conc', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'thresholdPerfConc', 0.8, x, y, 'label', 'Threshold conc', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'A1PerfConc', 0.0001, x, y, 'label', 'A1 conc', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'A2PerfConc', 0.999, x, y, 'label', 'A2 conc', 'labelfraction', 0.6); next_row(y,1.5);
        
        MenuParam(obj, 'functionPerfDiff', {'Boltzmann'}, 'Boltzmann', x, y, 'labelfraction', 0.6, ...
            'label', 'Function'); next_row(y,1);
        
        SubHeaderParam(obj, 'perfDiffHeader', 'Performance / Difficulty', x, y); next_row(y,1.5);
        
        NumEditParam(obj, 'ratePerformanceMix', 0.5, x, y, 'label', 'Rate mix', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'wPerfNRMix', 0, x, y, 'label', 'Overall performance mix', 'labelfraction', 0.7); next_row(y,1.2);
        
        NumEditParam(obj, 'ratePerformanceConc', 0.5, x, y, 'label', 'Rate conc', 'labelfraction', 0.7); next_row(y,1);
        DispParam(obj, 'wPerfNRConc', 0, x, y, 'label', 'Overall performance conc', 'labelfraction', 0.7); next_row(y,1);
        SubHeaderParam(obj, 'performanceHeader', 'Performance', x, y); next_row(y,2);
        
        
%         next_column(x); 
%         y = 5;
        
        
        NumEditParam(obj, 'probOdor1', 0.5, x, y, 'label', 'Probability of odor 1', 'labelfraction', 0.6); next_row(y,1.2);
        NumEditParam(obj, 'probMix1', 0.5, x, y, 'label', 'Probability of mix 1', 'labelfraction', 0.6); next_row(y,1);
        SubHeaderParam(obj, 'odorProbHeader', 'Odor probability', x, y); next_row(y,1.5);
        
        PushbuttonParam(obj, 'SetBiasOdorProbFunction', x, y,'label','Set bias / odorProb function',...
            'position', [x y 200 30], 'BackgroundColor', [0.1 0.5 0.5]); next_row(y,2);
        set_callback(SetBiasOdorProbFunction, {'OdorSection', 'setBiasOdorProbFunction'});
        
        NumEditParam(obj, 'slopeBias', 0.1, x, y, 'label', 'Slope', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'thresholdBias', 0.5, x, y, 'label', 'Threshold', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'A1Bias', 0, x, y, 'label', 'A1', 'labelfraction', 0.6); next_row(y,1);
        NumEditParam(obj, 'A2Bias', 1, x, y, 'label', 'A2', 'labelfraction', 0.6); next_row(y,1.2);
        MenuParam(obj, 'functionBiasOdorProb', {'Boltzmann'}, 'Boltzmann', x, y, 'labelfraction', 0.6, ...
            'label', 'Function'); next_row(y,1.3);
        
        MenuParam(obj, 'probChangeMode', {'Manual', 'Automatic'}, 'Manual', x, y, 'labelfraction', 0.6, ...
            'label', 'Prob change mode'); next_row(y,1);
        SubHeaderParam(obj, 'biasOdorProbHeader', 'Bias / OdorProbability', x, y); next_row(y,1.5);
        
        NumEditParam(obj, 'rateBias', 0.5, x, y, 'label', 'Rate', 'labelfraction', 0.6); next_row(y,1.2);
        DispParam(obj, 'wBiasConcNR', 0.5, x, y, 'label', 'Bias conc', 'labelfraction', 0.6); next_row(y,1.2);
        DispParam(obj, 'wBiasMixNR', 0.5, x, y, 'label', 'Bias mix', 'labelfraction', 0.6); next_row(y,1);
        SubHeaderParam(obj, 'biasHeader', 'Bias', x, y); next_row(y,2);
        
        
%        SoloParamHandle(obj, 'OlfBank');
%        OlfBank.value = 'OlfBankA';
%        SoloParamHandle(obj, 'valveNumber');
%        valveNumber.value = 0;
       
       SoloParamHandle(obj, 'sideList')
       sideList.value = zeros(1,1000);
       %        disp(value(sideList))

       SoloParamHandle(obj, 'stimListConc');
       stimListConc.value = 0;
       SoloParamHandle(obj, 'stimListMix');
       stimListMix.value = 0;
       
       SoloParamHandle(obj, 'currentOdor');
       currentOdor.value = zeros(1,1000);
       currentOdor(1,n_started_trials + 1) = 1;
       
       SoloParamHandle(obj, 'currentStimConc');
%        currentStimConc.value = nan(1000,2);
       SoloParamHandle(obj, 'currentStimOdor1');
%        currentStimOdor1.value = nan(1000,2);
       SoloParamHandle(obj, 'currentStimOdor2');
%        currentStimOdor2.value = nan(1000,2);
       SoloParamHandle(obj, 'nextStimConc');
       nextStimConc.value = 0;
%        SoloParamHandle(obj, 'nextStimVectorConc');
%        nextStimVectorConc.value = zeros(1,1000);

       SoloParamHandle(obj, 'currentStimMix');
%        currentStimMix.value = nan(1000,2);
       SoloParamHandle(obj, 'currentStimMix1');
%        currentStimMix1.value = nan(1000,2);
       SoloParamHandle(obj, 'currentStimMix2');
%        currentStimMix2.value = nan(1000,2);
       SoloParamHandle(obj, 'nextStimMix');
       nextStimMix.value = 0;
%        SoloParamHandle(obj, 'nextStimVectorMix');
%        nextStimVectorMix.value = zeros(1,1000);

       SoloParamHandle(obj, 'currentStim');
       currentStim.value = nan(1000,2);
       SoloParamHandle(obj, 'nextStim');
%        SoloParamHandle(obj, 'nextStimVector');
%        nextStimVector.value = zeros(1,1000);

       
       SoloParamHandle(obj, 'currentBank');
       currentBank.value = zeros(1,1000);
       SoloParamHandle(obj, 'currentValve');
       currentValve.value = zeros(1,1000);
       
       
       SoloParamHandle(obj, 'concPlot');
       
       SoloParamHandle(obj, 'correctOdor1');
       SoloParamHandle(obj, 'errorOdor1');
       SoloParamHandle(obj, 'performanceOdor1');
       performanceOdor1.value = 0;
       SoloParamHandle(obj, 'correctOdor2');
       SoloParamHandle(obj, 'errorOdor2');
       SoloParamHandle(obj, 'performanceOdor2');
       performanceOdor2.value = 0;
       SoloParamHandle(obj, 'correctMix1');
       SoloParamHandle(obj, 'errorMix1');
       SoloParamHandle(obj, 'performanceMix1');
       performanceMix1.value = 0;
       SoloParamHandle(obj, 'correctMix2');
       SoloParamHandle(obj, 'errorMix2');
       SoloParamHandle(obj, 'performanceMix2');
       performanceMix2.value = 0;

       
       SoloParamHandle(obj, 'currentOutcomeConc');
       currentOutcomeConc.value = nan(1, 1000);
       SoloParamHandle(obj, 'currentOutcomeMix');
       currentOutcomeMix.value = nan(1, 1000);
       SoloParamHandle(obj, 'currentOutcomeOdor1');
       currentOutcomeOdor1.value = nan(1, 1000);
       SoloParamHandle(obj, 'currentOutcomeOdor2');
       currentOutcomeOdor2.value = nan(1, 1000);
       SoloParamHandle(obj, 'currentOutcomeMix1');
       currentOutcomeMix1.value = nan(1, 1000);
       SoloParamHandle(obj, 'currentOutcomeMix2');
       currentOutcomeMix2.value = nan(1, 1000);
       
       SoloParamHandle(obj, 'currentChoiceConc');
       currentChoiceConc.value = nan(1, 1000);
       SoloParamHandle(obj, 'currentChoiceMix');
       currentChoiceMix.value = nan(1, 1000);
%        SoloParamHandle(obj, 'currentChoice2');
%        currentChoice2.value = 0;
%        SoloParamHandle(obj, 'leftChoice');
%        leftChoice.value = 0;
%        SoloParamHandle(obj, 'rightChoice');
%        rightChoice.value = 0;

       SoloParamHandle(obj, 'biasOdorProbFunction');
       biasOdorProbFunction.value = 0;
       SoloParamHandle(obj, 'bias');
       bias.value = 0 : 0.01 : 1;
       bias.value = round(value(bias) * 100) / 100;
       
       SoloParamHandle(obj, 'perfDiffFunctionConc');
       perfDiffFunctionConc.value = 0;
       SoloParamHandle(obj, 'perfDiffFunctionMix');
       perfDiffFunctionMix.value = 0;
       SoloParamHandle(obj, 'perf');
       perf.value = 0 : 0.01 : 1;
       perf.value = round(value(perf) * 100) / 100;

       
       SoloParamHandle(obj, 'weightedPerformanceSessionConc');
       weightedPerformanceSessionConc.value = nan(1, 1000);
       SoloParamHandle(obj, 'weightedPerformanceSessionMix');
       weightedPerformanceSessionMix.value = nan(1, 1000);
       SoloParamHandle(obj, 'weightedPerformanceOdor1Session');
       weightedPerformanceOdor1Session.value = nan(1, 1000);
       SoloParamHandle(obj, 'weightedPerformanceOdor2Session');
       weightedPerformanceOdor2Session.value = nan(1, 1000);
       SoloParamHandle(obj, 'weightedPerformanceMix1Session');
       weightedPerformanceMix1Session.value = nan(1, 1000);
       SoloParamHandle(obj, 'weightedPerformanceMix2Session');
       weightedPerformanceMix2Session.value = nan(1, 1000);
       
       SoloParamHandle(obj, 'weightedBiasConcSession');
       weightedBiasConcSession.value = nan(1000,2);
       SoloParamHandle(obj, 'weightedBiasMixSession');
       weightedBiasMixSession.value = nan(1000,2);
       SoloParamHandle(obj, 'probOdor1Session');
       probOdor1Session.value = nan(1000,2);
       SoloParamHandle(obj, 'probMix1Session');
       probMix1Session.value = nan(1000,2);
%        probOdor1Session(1, n_started_trials + 1) = value(probOdor1);
       
       SoloParamHandle(obj, 'dStimSessionConc');
       dStimSessionConc.value = nan(1, 1000);
%        dStimSessionConc(1, n_started_trials + 1) = value(dStimConc);
       SoloParamHandle(obj, 'dStimSessionMix');
       dStimSessionMix.value = nan(1, 1000);
%        dStimSessionMix(1, n_started_trials + 1) = value(dStimMix);
       

%        SoloParamHandle(obj, 'elapsedOdor1ValidTrials');
%        elapsedOdor1ValidTrials.value = 0;
%        SoloParamHandle(obj, 'elapsedOdor2ValidTrials');
%        elapsedOdor2ValidTrials.value = 0;
       SoloParamHandle(obj, 'elapsedValidTrials');
       elapsedValidTrials.value = 0;
%        SoloParamHandle(obj, 'elapsedMix1ValidTrials');
%        elapsedMix1ValidTrials.value = 0;
%        SoloParamHandle(obj, 'elapsedMix2ValidTrials');
%        elapsedMix2ValidTrials.value = 0;
       
       
       SoloParamHandle(obj, 'stimProportionOdor1');
       stimProportionOdor1.value = 0;
       SoloParamHandle(obj, 'stimsTrialNOdor1');
       stimsTrialNOdor1.value = 0;
       SoloParamHandle(obj, 'stimProportionOdor2');
       stimProportionOdor2.value = 0;
       SoloParamHandle(obj, 'stimsTrialNOdor2');
       stimsTrialNOdor2.value = 0;
%        SoloParamHandle(obj, 'stimListTrialNOdor1');
%        stimListTrialNOdor1.value = nan(1, 1000);
       SoloParamHandle(obj, 'stimProportionMix1');
       stimProportionMix1.value = 0;
       SoloParamHandle(obj, 'stimsTrialNMix1');
       stimsTrialNMix1.value = 0;
       SoloParamHandle(obj, 'stimProportionMix2');
       stimProportionMix2.value = 0;
       SoloParamHandle(obj, 'stimsTrialNMix2');
       stimsTrialNMix2.value = 0;
%        SoloParamHandle(obj, 'stimListTrialNMix1');
%        stimListTrialNMix1.value = nan(1, 1000);
   

       SoloParamHandle(obj, 'wPerfConc');
       wPerfConc.value = 0;
       SoloParamHandle(obj, 'wPerfMix');
       wPerfMix.value = 0;
       SoloParamHandle(obj, 'wBiasConc');
       wBiasConc.value = value(wBiasConcNR);
       SoloParamHandle(obj, 'wBiasMix');
       wBiasMix.value = value(wBiasMixNR);
       
       SoloParamHandle(obj, 'valveVectorOdor1');
       valveVectorOdor1.value = 0;
       SoloParamHandle(obj, 'valveVectorOdor2');
       valveVectorOdor2.value = 0;
       SoloParamHandle(obj, 'valveVectorMix1');
       valveVectorMix1.value = 0;
       SoloParamHandle(obj, 'valveVectorMix2');
       valveVectorMix2.value = 0;
       
       SoloParamHandle(obj, 'bankVectorOdor1');
       bankVectorOdor1.value = 0;
       SoloParamHandle(obj, 'bankVectorOdor2');
       bankVectorOdor2.value = 0;
       SoloParamHandle(obj, 'bankVectorMix1');
       bankVectorMix1.value = 0;
       SoloParamHandle(obj, 'bankVectorMix2');
       bankVectorMix2.value = 0;
       
       
       SoloParamHandle(obj, 'concListAll')
       concListAll.value = nan(1,1000);
       SoloParamHandle(obj, 'mixListAll')
       mixListAll.value = nan(1,1000);
       SoloParamHandle(obj, 'concList')
       concList.value = nan(1000,2);
       SoloParamHandle(obj, 'mixList')
       mixList.value = nan(1000,2);
       
       SoloParamHandle(obj, 'interleavedList')
       interleavedList.value = (rand(1,1000) < 0.5) + 1;

       
       SoloFunctionAddVars('PlotSection', 'rw_args', {'sideList', 'currentOdor', 'currentStim', ...
           'currentStimOdor1', 'currentStimOdor2', 'currentStimMix1', 'currentStimMix2', ...
           'concPlot', 'stimVector', 'performanceOdor1', 'performanceOdor2', 'performanceMix1', 'performanceMix2', ...
           'stimProportionOdor1', 'stimsTrialNOdor1', 'stimProportionOdor2', 'stimsTrialNOdor2', ...
           'stimProportionMix1', 'stimsTrialNMix1', 'stimProportionMix2', 'stimsTrialNMix2', ...
           'concList', 'mixList', 'weightedBiasConcSession', 'weightedBiasMixSession', 'probOdor1Session', 'probMix1Session'});
       SoloFunctionAddVars('ChoiceSection', 'rw_args', {'sideList', 'currentOdor', 'nextStimConc', ...
           'nextStimMix', 'stimVector', 'currentStim';});
       SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'OlfBank', 'valveNumber', 'currentOdor', ...
           'stim1Side'});
 
       
    case 'setBankAssignment'
        switch(value(taskIdentity))
            case 'Concentration task'
                bankVectorOdor1.value = [value(stim1Odor1Bank) value(stim2Odor1Bank) value(stim3Odor1Bank) value(stim4Odor1Bank)];
                bankVectorOdor1(find(isnan(value(bankVectorOdor1)) == 1)) = [];
                bankVectorOdor2.value = [value(stim1Odor2Bank) value(stim2Odor2Bank) value(stim3Odor2Bank) value(stim4Odor2Bank)];
                bankVectorOdor2(find(isnan(value(bankVectorOdor2)) == 1)) = [];
%                 disp(value(bankVectorOdor1))
%                 disp(value(bankVectorOdor2))
            case 'Mixture task'
                bankVectorMix1.value = [value(stim1Mix1Bank) value(stim2Mix1Bank) value(stim3Mix1Bank) value(stim4Mix1Bank)];
                bankVectorMix1(find(isnan(value(bankVectorMix1)) == 1)) = [];
                bankVectorMix2.value = [value(stim1Mix2Bank) value(stim2Mix2Bank) value(stim3Mix2Bank) value(stim4Mix2Bank)];
                bankVectorMix2(find(isnan(value(bankVectorMix2)) == 1)) = [];
            case 'Both - blocks'
                bankVectorOdor1.value = [value(stim1Odor1Bank) value(stim2Odor1Bank) value(stim3Odor1Bank) value(stim4Odor1Bank)];
                bankVectorOdor1(find(isnan(value(bankVectorOdor1)) == 1)) = [];
                bankVectorOdor2.value = [value(stim1Odor2Bank) value(stim2Odor2Bank) value(stim3Odor2Bank) value(stim4Odor2Bank)];
                bankVectorOdor2(find(isnan(value(bankVectorOdor2)) == 1)) = [];
                bankVectorMix1.value = [value(stim1Mix1Bank) value(stim2Mix1Bank) value(stim3Mix1Bank) value(stim4Mix1Bank)];
                bankVectorMix1(find(isnan(value(bankVectorMix1)) == 1)) = [];
                bankVectorMix2.value = [value(stim1Mix2Bank) value(stim2Mix2Bank) value(stim3Mix2Bank) value(stim4Mix2Bank)];
                bankVectorMix2(find(isnan(value(bankVectorMix2)) == 1)) = [];
            case 'Both - interleaved'
                bankVectorOdor1.value = [value(stim1Odor1Bank) value(stim2Odor1Bank) value(stim3Odor1Bank) value(stim4Odor1Bank)];
                bankVectorOdor1(find(isnan(value(bankVectorOdor1)) == 1)) = [];
                bankVectorOdor2.value = [value(stim1Odor2Bank) value(stim2Odor2Bank) value(stim3Odor2Bank) value(stim4Odor2Bank)];
                bankVectorOdor2(find(isnan(value(bankVectorOdor2)) == 1)) = [];
                bankVectorMix1.value = [value(stim1Mix1Bank) value(stim2Mix1Bank) value(stim3Mix1Bank) value(stim4Mix1Bank)];
                bankVectorMix1(find(isnan(value(bankVectorMix1)) == 1)) = [];
                bankVectorMix2.value = [value(stim1Mix2Bank) value(stim2Mix2Bank) value(stim3Mix2Bank) value(stim4Mix2Bank)];
                bankVectorMix2(find(isnan(value(bankVectorMix2)) == 1)) = [];
        end
       
       
    case 'setValveAssignment'
        switch(value(taskIdentity))
            case 'Concentration task'
                valveVectorOdor1.value = [value(stim1Odor1Valve) value(stim2Odor1Valve) value(stim3Odor1Valve) value(stim4Odor1Valve)];
                valveVectorOdor1(find(isnan(value(valveVectorOdor1)) == 1)) = [];
                valveVectorOdor2.value = [value(stim1Odor2Valve) value(stim2Odor2Valve) value(stim3Odor2Valve) value(stim4Odor2Valve)];
                valveVectorOdor2(find(isnan(value(valveVectorOdor2)) == 1)) = [];
%                 disp(value(valveVectorOdor1))
%                 disp(value(valveVectorOdor2))
            case 'Mixture task'
                valveVectorMix1.value = [value(stim1Mix1Valve) value(stim2Mix1Valve) value(stim3Mix1Valve) value(stim4Mix1Valve)];
                valveVectorMix1(find(isnan(value(valveVectorMix1)) == 1)) = [];
                valveVectorMix2.value = [value(stim1Mix2Valve) value(stim2Mix2Valve) value(stim3Mix2Valve) value(stim4Mix2Valve)];
                valveVectorMix2(find(isnan(value(valveVectorMix2)) == 1)) = [];
            case 'Both - blocks'
                valveVectorOdor1.value = [value(stim1Odor1Valve) value(stim2Odor1Valve) value(stim3Odor1Valve) value(stim4Odor1Valve)];
                valveVectorOdor1(find(isnan(value(valveVectorOdor1)) == 1)) = [];
                valveVectorOdor2.value = [value(stim1Odor2Valve) value(stim2Odor2Valve) value(stim3Odor2Valve) value(stim4Odor2Valve)];
                valveVectorOdor2(find(isnan(value(valveVectorOdor2)) == 1)) = [];
                valveVectorMix1.value = [value(stim1Mix1Valve) value(stim2Mix1Valve) value(stim3Mix1Valve) value(stim4Mix1Valve)];
                valveVectorMix1(find(isnan(value(valveVectorMix1)) == 1)) = [];
                valveVectorMix2.value = [value(stim1Mix2Valve) value(stim2Mix2Valve) value(stim3Mix2Valve) value(stim4Mix2Valve)];
                valveVectorMix2(find(isnan(value(valveVectorMix2)) == 1)) = [];
            case 'Both - interleaved'
                valveVectorOdor1.value = [value(stim1Odor1Valve) value(stim2Odor1Valve) value(stim3Odor1Valve) value(stim4Odor1Valve)];
                valveVectorOdor1(find(isnan(value(valveVectorOdor1)) == 1)) = [];
                valveVectorOdor2.value = [value(stim1Odor2Valve) value(stim2Odor2Valve) value(stim3Odor2Valve) value(stim4Odor2Valve)];
                valveVectorOdor2(find(isnan(value(valveVectorOdor2)) == 1)) = [];
                valveVectorMix1.value = [value(stim1Mix1Valve) value(stim2Mix1Valve) value(stim3Mix1Valve) value(stim4Mix1Valve)];
                valveVectorMix1(find(isnan(value(valveVectorMix1)) == 1)) = [];
                valveVectorMix2.value = [value(stim1Mix2Valve) value(stim2Mix2Valve) value(stim3Mix2Valve) value(stim4Mix2Valve)];
                valveVectorMix2(find(isnan(value(valveVectorMix2)) == 1)) = [];
        end
       
        
     case 'setBiasOdorProbFunction'
        
        switch value(probChangeMode)
            case 'Manual'
                if n_done_trials == 0,
                    probOdor1Session(:,1) = 1 : 1000;
                    probOdor1Session(:,2) = ones (1,1000) * value(probOdor1);
                    concListAll (1,:) = (rand(1,1000) > value(probOdor1)) + 1;
                    
                    probMix1Session(:,1) = 1 : 1000;
                    probMix1Session(:,2) = ones (1,1000) * value(probMix1);
                    mixListAll (1,:) = (rand(1,1000) > value(probMix1)) + 1;
                else
%                     probOdor1Session(n_started_trials + 2:1000,1) = 1 : n_started_trials + 2:1000;
                    probOdor1Session(n_started_trials + 2:1000,2) = ones (1,1000) * value(probOdor1);
                    concListAll(1, n_started_trials + 2:1000) = (rand(1, length(n_started_trials + 2:1000)) > value(probOdor1)) + 1;
                    
                    probMix1Session(n_started_trials + 2:1000,2) = ones (1,1000) * value(probMix1);
                    mixListAll(1, n_started_trials + 2:1000) = (rand(1, length(n_started_trials + 2:1000)) > value(probMix1)) + 1;
                end
                probOdor1.value = probOdor1Session(n_started_trials + 1,2);
                probMix1.value = probMix1Session(n_started_trials + 1,2);
                
            case 'Automatic'
                
        %         x = -1 : 0.01 : 1;
                biasOdorProbFunction.value = (value(A2Bias) - value(A1Bias)) ./ (1 + ...
                    exp((value(bias) - value(thresholdBias))./ value(slopeBias))) + value(A1Bias);
        %         disp(value(biasOdorProbFunction));
        %         disp(value(bias))
        %         figure; plot(value(bias), value(biasOdorProbFunction), 'o');
                probOdor1Session(n_started_trials + 1, :) = [n_started_trials + 1 value(probOdor1)];
                concListAll (1,:) = (rand(1,1000) > value(probOdor1)) + 1;
                probMix1Session(n_started_trials + 1, :) = [n_started_trials + 1 value(probMix1)];
                mixListAll (1,:) = (rand(1,1000) > value(probMix1)) + 1;
        end
        
    
    case 'setPerfDiffFunction'
        
%         x = -1 : 0.01 : 1;
        perfDiffFunctionConc.value = (value(A2PerfConc) - value(A1PerfConc)) ./ (1 + ...
            exp((value(perf) - value(thresholdPerfConc))./ value(slopePerfConc))) + value(A1PerfConc);
        figure; plot(value(perf), value(perfDiffFunctionConc), 'o');
        perfDiffFunctionMix.value = (value(A2PerfMix) - value(A1PerfMix)) ./ (1 + ...
            exp((value(perf) - value(thresholdPerfMix))./ value(slopePerfMix))) + value(A1PerfMix);
        figure; plot(value(perf), value(perfDiffFunctionMix), 'o');
        
    case 'setOdorVector'
       
%        elapsedTrials.value = 0;
       elapsedOdor1Trials.value = 0;
       elapsedOdor2Trials.value = 0;
       elapsedOdor1ValidTrials.value = 0;
       elapsedOdor2ValidTrials.value = 0;
       elapsedMix1Trials.value = 0;
       elapsedMix2Trials.value = 0;
       elapsedMix1ValidTrials.value = 0;
       elapsedMix2ValidTrials.value = 0;
       
       currentPerformance1.value = 0;
       currentPerformance2.value = 0;
       
       currentStimConc.value = nan(1000,2);
       currentStimOdor1.value = nan(1000,2);
       currentStimOdor2.value = nan(1000,2);
       currentStimMix.value = nan(1000,2);
       currentStimMix1.value = nan(1000,2);
       currentStimMix2.value = nan(1000,2);
            
%        concList.value = nan(1000,2);
%        mixList.value = nan(1000,2);
%        sideList.value = zeros(1,1000);

%         if n_done_trials == 0,
%             sideList.value = (rand(1,1000) > value(probOdor1)) + 1;
%         else
%             sideList(1,n_started_trials + 2:1000) = (rand (1,1000-(n_started_trials+1)) > value(probOdor1)) + 1;
%         end

       
           
       % gives a value to currentOdor
       switch(value(taskIdentity))
            case 'Concentration task'
                if value(concListAll(1, n_started_trials + 1)) == 1
                    sideList(1, n_started_trials + 1) = 1;
                    currentOdor(1, n_started_trials + 1) = 1;
                    currentOdorORMix.value = 'Odor 1';
                    concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))]; 
%                     currentBank(n_started_trials + 1) = value(bankVectorOdor1(value(nextStimConc)));
%                     currentValve(n_started_trials + 1) = value(valveVectorOdor1(value(nextStimConc)));
                elseif value(concListAll(1, n_started_trials + 1)) == 2
                    sideList(1, n_started_trials + 1) = 2;
                    currentOdor(1, n_started_trials + 1) = 2;
                    currentOdorORMix.value = 'Odor 2';
                    concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
%                     currentBank(n_started_trials + 1) = value(bankVectorOdor2(value(nextStimConc)));
%                     currentValve(n_started_trials + 1) = value(valveVectorOdor2(value(nextStimConc)));                    
                end
                    
            case 'Mixture task'
                if value(mixListAll(1, n_started_trials + 1)) == 1
                    sideList(1, n_started_trials + 1) = 1;
                    currentOdor(1, n_started_trials + 1) = 3;
                    currentOdorORMix.value = 'Mix 1';
                    mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
%                     currentBank(n_started_trials + 1) = value(bankVectorMix1(value(nextStimMix)));
%                     currentValve(n_started_trials + 1) = value(valveVectorMix1(value(nextStimMix)));   
                elseif value(mixListAll(1, n_started_trials + 1)) == 2
                    sideList(1, n_started_trials + 1) = 2;
                    currentOdor(1, n_started_trials + 1) = 4;
                    currentOdorORMix.value = 'Mix 2';
                    mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
%                     currentBank(n_started_trials + 1) = value(bankVectorMix2(value(nextStimMix)));
%                     currentValve(n_started_trials + 1) = value(valveVectorMix2(value(nextStimMix)));
                end
                    
                                
            case 'Both - blocks'
                switch(value(blockTaskFirstBlock))
                    case 'Concentration task'
                        if value(concListAll(1, n_started_trials + 1)) == 1
                            sideList(1, n_started_trials + 1) = 1;
                            currentOdor(1, n_started_trials + 1) = 1;
                            currentOdorORMix.value = 'Odor 1';
                            concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
%                             currentBank(n_started_trials + 1) = value(bankVectorOdor1(value(nextStimConc)));
%                             currentValve(n_started_trials + 1) = value(valveVectorOdor1(value(nextStimConc)));
                            
                        elseif value(concListAll(1, n_started_trials + 1)) == 2
                            sideList(1, n_started_trials + 1) = 2;
                            currentOdor(1, n_started_trials + 1) = 2;
                            currentOdorORMix.value = 'Odor 2';
                            concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
%                             currentBank(n_started_trials + 1) = value(bankVectorOdor2(value(nextStimConc)));
%                             currentValve(n_started_trials + 1) = value(valveVectorOdor2(value(nextStimConc)));
                            
                        end
                   
                    case 'Mixture task'
                        if value(mixListAll(1, n_started_trials + 1)) == 1
                            sideList(1, n_started_trials + 1) = 1;
                            currentOdor(1, n_started_trials + 1) = 3;
                            currentOdorORMix.value = 'Mix 1';
                            mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
%                             currentBank(n_started_trials + 1) = value(bankVectorMix1(value(nextStimMix)));
%                             currentValve(n_started_trials + 1) = value(valveVectorMix1(value(nextStimMix)));
                            
                        elseif value(mixListAll(1, n_started_trials + 1)) == 2
                            sideList(1, n_started_trials + 1) = 2;
                            currentOdor(1, n_started_trials + 1) = 4;
                            currentOdorORMix.value = 'Mix 2';
                            mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
%                             currentBank(n_started_trials + 1) = value(bankVectorMix2(value(nextStimMix)));
%                             currentValve(n_started_trials + 1) = value(valveVectorMix2(value(nextStimMix)));
                            
                        end
                end
                
            case 'Both - interleaved'
                if value(interleavedList(1, n_started_trials + 1)) == 1
                    if randi(2,1) == 1
                        sideList(1, n_started_trials + 1) = 1;
                        currentOdor(1, n_started_trials + 1) = 1;
                        currentOdorORMix.value = 'Odor 1';
                        concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
%                         currentBank(n_started_trials + 1) = value(bankVectorOdor1(value(nextStimConc)));
%                         currentValve(n_started_trials + 1) = value(valveVectorOdor1(value(nextStimConc)));
                        
                    elseif randi(2,1) == 2
                        sideList(1, n_started_trials + 1) = 2;
                        currentOdor(1, n_started_trials + 1) = 3;
                        currentOdorORMix.value = 'Mix 1';
                        mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
%                         currentBank(n_started_trials + 1) = value(bankVectorMix1(value(nextStimMix)));
%                         currentValve(n_started_trials + 1) = value(valveVectorMix1(value(nextStimMix)));
                        
                    end
                        
                elseif value(interleavedList(1, n_started_trials + 1)) == 2
                    if randi(2,1) == 1
                        sideList(1, n_started_trials + 1) = 2;
                        currentOdor(1, n_started_trials + 1) = 2;
                        currentOdorORMix.value = 'Odor 2';
                        concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
%                         currentBank(n_started_trials + 1) = value(bankVectorOdor2(value(nextStimConc)));
%                         currentValve(n_started_trials + 1) = value(valveVectorOdor2(value(nextStimConc)));
                        
                    elseif randi(2,1) == 2
                        sideList(1, n_started_trials + 1) = 2;
                        currentOdor(1, n_started_trials + 1) = 4;
                        currentOdorORMix.value = 'Mix 2';
                        mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
%                         currentBank(n_started_trials + 1) = value(bankVectorMix2(value(nextStimMix)));
%                         currentValve(n_started_trials + 1) = value(valveVectorMix2(value(nextStimMix)));
                    end
                end
                
       end
       
%        disp(currentOdor(1,n_started_trials + 1));
       

       % set odor vectors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       lengthCal.value = floor((-value(firstValue) - (-value(lastValue))) / value(logStep)) + 1;
       stimVector.value = zeros(1,value(lengthCal));
       stimVector.value = -value(lastValue) - value(logStep) + value(logStep) * (1:value(lengthCal));
       
       correctOdor1.value = zeros(1, value(lengthCal));
       errorOdor1.value = zeros(1, value(lengthCal)); 
       performanceOdor1.value = zeros(1, value(lengthCal));
       
       correctOdor2.value = zeros(1, value(lengthCal));
       errorOdor2.value = zeros(1, value(lengthCal)); 
       performanceOdor2.value = zeros(1, value(lengthCal));
       
       correctMix1.value = zeros(1, value(lengthCal));
       errorMix1.value = zeros(1, value(lengthCal)); 
       performanceMix1.value = zeros(1, value(lengthCal));
       
       correctMix2.value = zeros(1, value(lengthCal));
       errorMix2.value = zeros(1, value(lengthCal)); 
       performanceMix2.value = zeros(1, value(lengthCal));

       concProportionOdor1.value = zeros(1000, value(lengthCal));
       concProportionOdor2.value = zeros(1000, value(lengthCal));

       disp(value(stimVector))
       
       % geometric distribution %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
       A = 500;
       x = fliplr(-stimVector(find((isnan(value(stimVector))) == 0)));
       
        %%% concentration
        if value(dStimConc) >= 0.999
            dStimConc.value = 0.999;
        elseif (value(dStimConc) <= 0.0001 && value(dStimConc) >= 0) == 1
            dStimConc.value = 0.0001;
        elseif value(dStimConc) <= -0.999
            dStimConc.value = -0.999;
        elseif (value(dStimConc) >= -0.0001 && value(dStimConc) < 0) == 1
            dStimConc.value = -0.0001;
        end       
        dStimSessionConc(1, n_started_trials + 1) = value(dStimConc);
%         disp(dStimSessionConc(1, n_started_trials + 1))
        
%         if (value(dStimConc) > -0.0001 && value(dStimConc) < 0.0001) == 1
%             dStim = 0.0001;
%         elseif (value(dStimConc) < -0.0001 || value(dStimConc) > 0.0001) == 1
            dStim = abs(value(dStimConc));
%         end
    
        gd = round(A * (1 - geocdf(x,value(dStim))) / (1 - geocdf(x(1), value(dStim))));
        last = 0;
        stimList = [];
        for i = 1 : length(x)
            first = 1 + last;
            last = last + gd(i);
            stimList(first:last) = x(i);
        end
%         figure; hist(stimList)
%         disp(value(dStimConc))
        
        if value(dStimConc) >= 0
            stimList = stimList(randperm(length(stimList)));
            stimListConc.value = -stimList;
            figure; hist(value(stimListConc))
        elseif value(dStimConc) < 0
            stimList1 = nan(1, length(stimList));
            for i = 1 : length(x)
                stimList1(find(stimList == x(1)+i-1)) = x(end)-i+1;
            end
            stimList1 = stimList1(randperm(length(stimList1)));
           stimListConc.value = -stimList1;
           figure; hist(value(stimListConc))
        end
          
        %%% mixture
        if value(dStimMix) >= 0.999
            dStimMix.value = 0.999;
        elseif (value(dStimMix) <= 0.0001 && value(dStimMix) >= 0) == 1
            dStimMix.value = 0.0001;
        elseif value(dStimMix) <= -0.999
            dStimMix.value = -0.999;
        elseif (value(dStimMix) >= -0.0001 && value(dStimMix) < 0) == 1
            dStimMix.value = -0.0001;
        end       
        dStimSessionMix(1, n_started_trials + 1) = value(dStimMix);
        
%         if (value(dStimConc) > -0.0001 && value(dStimConc) < 0.0001) == 1
%             dStim = 0.0001;
%         elseif (value(dStimConc) < -0.0001 || value(dStimConc) > 0.0001) == 1
            dStim = abs(value(dStimMix));
%         end
    
        gd = round(A * (1 - geocdf(x,value(dStim))) / (1 - geocdf(x(1), value(dStim))));
        last = 0;
        stimList = [];
        for i = 1 : length(x)
            first = 1 + last;
            last = last + gd(i);
            stimList(first:last) = x(i);
        end
%         figure; hist(stimList)
%         disp(value(dStimMix))
        
        if value(dStimMix) >= 0
            stimList = stimList(randperm(length(stimList)));
            stimListMix.value = -stimList;
            figure; hist(value(stimListMix))
        elseif value(dStimMix) < 0
            stimList1 = nan(1, length(stimList));
            for i = 1 : length(x)
                stimList1(find(stimList == x(1)+i-1)) = x(end)-i+1;
            end
            stimList1 = stimList1(randperm(length(stimList1)));
            stimListMix.value = -stimList1;
            figure; hist(value(stimListMix))
        end  
%------------------------------------------------------------------------ %
 
       nextStimConc.value = value(stimListConc(n_started_trials + 1));
%        disp(value(nextStimConc));
%        disp(value(stimListConc));
       
       nextStimMix.value = value(stimListMix(n_started_trials + 1));
%        disp(value(nextStimMix));   
       
       
       % assign values to currentStim, currentBank and currentValve
       switch(value(taskIdentity))
            case 'Concentration task'
                if value(currentOdor(1, n_started_trials + 1)) == 1
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimOdor1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentBank(n_started_trials + 1) = value(bankVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                    currentValve(n_started_trials + 1) = value(valveVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                elseif value(currentOdor(1, n_started_trials + 1)) == 2
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimOdor2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentBank(n_started_trials + 1) = value(bankVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                    currentValve(n_started_trials + 1) = value(valveVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                end
%                     disp(value(stimVector))
%                     disp(value(currentBank(n_started_trials + 1)))
%                     disp(value(currentValve(n_started_trials + 1)))
            case 'Mixture task'
                if value(currentOdor(1, n_started_trials + 1)) == 3
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentBank(n_started_trials + 1) = value(bankVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                    currentValve(n_started_trials + 1) = value(valveVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                elseif value(currentOdor(1, n_started_trials + 1)) == 4
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentBank(n_started_trials + 1) = value(bankVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                    currentValve(n_started_trials + 1) = value(valveVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                end
                
            case 'Both - blocks'
                switch(value(blockTaskFirstBlock))
                    case 'Concentration task'
                        if value(currentOdor(1, n_started_trials + 1)) == 1
                            currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                            currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                            currentStimOdor1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                            currentBank(n_started_trials + 1) = value(bankVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                            currentValve(n_started_trials + 1) = value(valveVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                        elseif value(currentOdor(1, n_started_trials + 1)) == 2
                            currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                            currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                            currentStimOdor2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                            currentBank(n_started_trials + 1) = value(bankVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                            currentValve(n_started_trials + 1) = value(valveVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                        end
                   
                    case 'Mixture task'
                        if value(currentOdor(1, n_started_trials + 1)) == 3
                            currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                            currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                            currentStimMix1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                            currentBank(n_started_trials + 1) = value(bankVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                            currentValve(n_started_trials + 1) = value(valveVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                        elseif value(currentOdor(1, n_started_trials + 1)) == 4
                            currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                            currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                            currentStimMix2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                            currentBank(n_started_trials + 1) = value(bankVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                            currentValve(n_started_trials + 1) = value(valveVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                        end
                end
                
            case 'Both - interleaved'
                if value(currentOdor(1, n_started_trials + 1)) == 1
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimOdor1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentBank(n_started_trials + 1) = value(bankVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                    currentValve(n_started_trials + 1) = value(valveVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                elseif value(currentOdor(1, n_started_trials + 1)) == 2
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimOdor2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentBank(n_started_trials + 1) = value(bankVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                    currentValve(n_started_trials + 1) = value(valveVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                elseif value(currentOdor(1, n_started_trials + 1)) == 3
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentBank(n_started_trials + 1) = value(bankVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                    currentValve(n_started_trials + 1) = value(valveVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                elseif value(currentOdor(1, n_started_trials + 1)) == 4
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentBank(n_started_trials + 1) = value(bankVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                    currentValve(n_started_trials + 1) = value(valveVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                end
                
       end
       
%        currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStim)];
%        disp(value(currentStim));
        currentConcORRatio.value = abs(value(currentStim(n_started_trials + 1, 2)));  
       
       valveNumber.value = value(currentValve(n_started_trials + 1));
       if value(currentBank(n_started_trials + 1)) == 1
           OlfBank.value = 'OlfBankA';
       elseif value(currentBank(n_started_trials + 1)) == 2
           OlfBank.value = 'OlfBankB';
       elseif value(currentBank(n_started_trials + 1)) == 3
           OlfBank.value = 'OlfBankC';
       elseif value(currentBank(n_started_trials + 1)) == 4
           OlfBank.value = 'OlfBankD';
       end
%        disp(currentOdor(1,n_started_trials + 1));
%        disp(value(currentStim));
%        disp(value(OlfBank));
%        disp(value(valveNumber));
       
       
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
% case 'next_trial' %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    case 'next_trial',
        
       if n_done_trials == 0,
%            elapsedTrials.value = 0;
           return,
       end;
       
%        elapsedTrials.value = value(elapsedTrials) + 1;
       if value(currentOdor(1, n_started_trials)) == 1
           elapsedOdor1Trials.value = value(elapsedOdor1Trials) + 1;
       elseif value(currentOdor(1, n_started_trials)) == 2
           elapsedOdor2Trials.value = value(elapsedOdor2Trials) + 1;
       elseif value(currentOdor(1, n_started_trials)) == 3
           elapsedMix1Trials.value = value(elapsedMix1Trials) + 1;
       elseif value(currentOdor(1, n_started_trials)) == 4
           elapsedMix2Trials.value = value(elapsedMix2Trials) + 1;
       end

       if ((~isempty(parsed_events.states.left_poke_in_correct)  == 1 || ...
               ~isempty(parsed_events.states.left_poke_in_error) == 1  || ...
               ~isempty(parsed_events.states.right_poke_in_correct)  == 1 || ...
               ~isempty(parsed_events.states.right_poke_in_error) == 1)) == 1
           elapsedValidTrials.value = value(elapsedValidTrials) + 1;
       end
%        disp(value(elapsedValidTrials))

       
       if (value(currentOdor(1, n_started_trials)) == 1 && (((~isempty(parsed_events.states.rin_no_water)  == 1) || ...
               (~isempty(parsed_events.states.lin_no_water) == 1)  || (~isempty(parsed_events.states.rin_water)  == 1) || ...
               (~isempty(parsed_events.states.lin_water) == 1))))
           elapsedOdor1ValidTrials.value = value(elapsedOdor1ValidTrials) + 1;
       elseif (value(currentOdor(1, n_started_trials)) == 2 && (((~isempty(parsed_events.states.rin_no_water)  == 1) || ...
               (~isempty(parsed_events.states.lin_no_water) == 1)  || (~isempty(parsed_events.states.rin_water)  == 1) || ...
               (~isempty(parsed_events.states.lin_water) == 1))))
           elapsedOdor2ValidTrials.value = value(elapsedOdor2ValidTrials) + 1;
       elseif (value(currentOdor(1, n_started_trials)) == 3 && (((~isempty(parsed_events.states.rin_no_water)  == 1) || ...
               (~isempty(parsed_events.states.lin_no_water) == 1)  || (~isempty(parsed_events.states.rin_water)  == 1) || ...
               (~isempty(parsed_events.states.lin_water) == 1))))
           elapsedMix1ValidTrials.value = value(elapsedMix1ValidTrials) + 1;
       elseif (value(currentOdor(1, n_started_trials)) == 4 && (((~isempty(parsed_events.states.rin_no_water)  == 1) || ...
               (~isempty(parsed_events.states.lin_no_water) == 1)  || (~isempty(parsed_events.states.rin_water)  == 1) || ...
               (~isempty(parsed_events.states.lin_water) == 1))))
           elapsedMix2ValidTrials.value = value(elapsedMix2ValidTrials) + 1;
       end
%        disp(value(elapsedOdor1ValidTrials))
%        disp(value(elapsedOdor2ValidTrials))
%        disp(value(elapsedMix1ValidTrials))
%        disp(value(elapsedMix2ValidTrials))
       


       % performance %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       previousStim = value(currentStim(n_started_trials, 2));
       if (~isempty(parsed_events.states.rin_no_water)  == 1 || ...
               ~isempty(parsed_events.states.lin_no_water) == 1) == 1,
%             a = 'error'
            if value(currentOdor(1, n_started_trials)) == 1;
                currentOutcomeConc(1,n_started_trials) = 0;
                currentOutcomeOdor1(1,n_started_trials) = 0;
                errorOdor1 (find(value(stimVector) == previousStim)) = ...
                    errorOdor1 (find(value(stimVector) == previousStim)) + 1;
                errorOdor1.value = value(errorOdor1);
            elseif value(currentOdor(1,n_started_trials)) == 2;
                currentOutcomeConc(1,n_started_trials) = 0;
                currentOutcomeOdor2(1,n_started_trials) = 0;
                errorOdor2 (find(value(stimVector) == previousStim)) = ...
                    errorOdor2 (find(value(stimVector) == previousStim)) + 1;
                errorOdor2.value = value(errorOdor2);
            elseif value(currentOdor(1,n_started_trials)) == 3;
                currentOutcomeMix(1,n_started_trials) = 0;
                currentOutcomeMix1(1,n_started_trials) = 0;
                errorMix1 (find(value(stimVector) == previousStim)) = ...
                    errorMix1 (find(value(stimVector) == previousStim)) + 1;
                errorMix1.value = value(errorMix1);
            elseif value(currentOdor(1,n_started_trials)) == 4;
                currentOutcomeMix(1,n_started_trials) = 0;
                currentOutcomeMix2(1,n_started_trials) = 0;
                errorMix2 (find(value(stimVector) == previousStim)) = ...
                    errorMix2 (find(value(stimVector) == previousStim)) + 1;
                errorMix2.value = value(errorMix2);
            end
        elseif (~isempty(parsed_events.states.rin_water)  == 1 || ...
                ~isempty(parsed_events.states.lin_water) == 1) == 1,
%             b = 'correct'
            if value(currentOdor(1,n_started_trials)) == 1;
                currentOutcomeConc(1,n_started_trials) = 1;
                currentOutcomeOdor1(1,n_started_trials) = 1;
                correctOdor1 (find(value(stimVector) == previousStim)) = ...
                    correctOdor1 (find(value(stimVector) == previousStim)) + 1;
                correctOdor1.value = value(correctOdor1);
            elseif value(currentOdor(1,n_started_trials)) == 2;
                currentOutcomeConc(1,n_started_trials) = 1;
                currentOutcomeOdor2(1,n_started_trials) = 1;
                correctOdor2 (find(value(stimVector) == previousStim)) = ...
                    correctOdor2 (find(value(stimVector) == previousStim)) + 1;
                correctOdor2.value = value(correctOdor2);
            elseif value(currentOdor(1,n_started_trials)) == 3;
                currentOutcomeMix(1,n_started_trials) = 1;
                currentOutcomeMix1(1,n_started_trials) = 1;
                correctMix1 (find(value(stimVector) == previousStim)) = ...
                    correctMix1 (find(value(stimVector) == previousStim)) + 1;
                correctMix1.value = value(correctMix1);
            elseif value(currentOdor(1,n_started_trials)) == 4;
                currentOutcomeMix(1,n_started_trials) = 1;
                currentOutcomeMix2(1,n_started_trials) = 1;
                correctMix2 (find(value(stimVector) == previousStim)) = ...
                    correctMix2 (find(value(stimVector) == previousStim)) + 1;
                correctMix2.value = value(correctMix2);
            end
       end
%       disp(value(currentOutcomeConc)) 
%     disp(value(correctOdor1))
%     disp(value(correctOdor2))
%     disp(value(errorOdor1))
%     disp(value(errorOdor2))
    
    performanceOdor1.value = value(correctOdor1) ./ (value(correctOdor1) + value(errorOdor1));
    performanceOdor2.value = value(correctOdor2) ./ (value(correctOdor2) + value(errorOdor2));
    performanceMix1.value = value(correctMix1) ./ (value(correctMix1) + value(errorMix1));
    performanceMix2.value = value(correctMix2) ./ (value(correctMix2) + value(errorMix2));
%     disp(value(performanceOdor1))
%     disp(value(performanceOdor2))
%     disp(value(performanceMix1))
%     disp(value(performanceMix2))
    

    if (~isempty(parsed_events.states.rin_no_water)  == 1 || ~isempty(parsed_events.states.lin_no_water) == 1  || ...
            ~isempty(parsed_events.states.rin_water)  == 1 || ~isempty(parsed_events.states.lin_water) == 1) == 1,
        if (value(currentOdor(1, n_started_trials)) == 1 || ...
                value(currentOdor(1, n_started_trials)) == 2) == 1
            if ((value(elapsedOdor1ValidTrials) == 1 && value(elapsedOdor2ValidTrials) == 0) == 1 || ...
                    (value(elapsedOdor1ValidTrials) == 0 && value(elapsedOdor2ValidTrials) == 1) == 1) == 1
                weightedPerformanceSessionConc(1,n_started_trials) = value(currentOutcomeConc(1,n_started_trials));
                wPerfNRConc.value = value(weightedPerformanceSessionConc(1,n_started_trials));
                wPerfConc.value = round(value(weightedPerformanceSessionConc(1,n_started_trials)) * 100) / 100;
            
            elseif ismember(n_started_trials-1, value(contextTaskTrialsPerBlock)*([1 3 5])) == 1
                if strcmp(value(contextTask), 'Yes') == 1                
                    weightedPerformanceSessionConc(1,n_started_trials) = value(currentOutcomeConc(1,n_started_trials));
                    wPerfNRConc.value = value(weightedPerformanceSessionConc(1,n_started_trials));
                    wPerfConc.value = round(value(weightedPerformanceSessionConc(1,n_started_trials)) * 100) / 100;
                end
            elseif ismember(n_started_trials-1, value(contextTaskTrialsPerBlock)*([2 4 6])) == 1
                if strcmp(value(contextTask), 'Yes') == 1                
                    weightedPerformanceSessionConc(1,n_started_trials) = value(currentOutcomeConc(1,n_started_trials));
                    wPerfNRConc.value = value(weightedPerformanceSessionConc(1,n_started_trials));
                    wPerfConc.value = round(value(weightedPerformanceSessionConc(1,n_started_trials)) * 100) / 100;
                end
                
            else
                weightedPerformanceSessionConc(1,n_started_trials) = (1 - value(ratePerformanceConc)) * ...
                    value(wPerfNRConc) + value(ratePerformanceConc) * value(currentOutcomeConc(1,n_started_trials));
                wPerfNRConc.value = value(weightedPerformanceSessionConc(1,n_started_trials));
                wPerfConc.value = round(value(weightedPerformanceSessionConc(1,n_started_trials)) * 100) / 100;
            end
        elseif (value(currentOdor(1, n_started_trials)) == 3 || ...
                value(currentOdor(1, n_started_trials)) == 4) == 1
            if ((value(elapsedMix1ValidTrials) == 1 && value(elapsedMix2ValidTrials) == 0) == 1 || ...
                    (value(elapsedMix1ValidTrials) == 0 && value(elapsedMix2ValidTrials) == 1) == 1) == 1
                weightedPerformanceSessionMix(1,n_started_trials) = value(currentOutcomeMix(1,n_started_trials));
                wPerfNRMix.value = value(weightedPerformanceSessionMix(1,n_started_trials));
                wPerfMix.value = round(value(weightedPerformanceSessionMix(1,n_started_trials)) * 100) / 100;
            
            elseif ismember(n_started_trials-1, value(contextTaskTrialsPerBlock)*([1 3 5])) == 1
                if strcmp(value(contextTask), 'Yes') == 1                
                    weightedPerformanceSessionMix(1,n_started_trials) = value(currentOutcomeMix(1,n_started_trials));
                    wPerfNRMix.value = value(weightedPerformanceSessionMix(1,n_started_trials));
                    wPerfMix.value = round(value(weightedPerformanceSessionMix(1,n_started_trials)) * 100) / 100;
                end
            elseif ismember(n_started_trials-1, value(contextTaskTrialsPerBlock)*([2 4 6])) == 1
                if strcmp(value(contextTask), 'Yes') == 1                
                    weightedPerformanceSessionMix(1,n_started_trials) = value(currentOutcomeMix(1,n_started_trials));
                    wPerfNRMix.value = value(weightedPerformanceSessionMix(1,n_started_trials));
                    wPerfMix.value = round(value(weightedPerformanceSessionMix(1,n_started_trials)) * 100) / 100;
                end
                
            else
                weightedPerformanceSessionMix(1,n_started_trials) = (1 - value(ratePerformanceMix)) * ...
                    value(wPerfNRMix) + value(ratePerformanceMix) * value(currentOutcomeMix(1,n_started_trials));
                wPerfNRMix.value = value(weightedPerformanceSessionMix(1,n_started_trials));
                wPerfMix.value = round(value(weightedPerformanceSessionMix(1,n_started_trials)) * 100) / 100;
            end
        end
    end
        



%  bias %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if (~isempty(parsed_events.states.left_poke_in_correct) == 1 || ...
            ~isempty(parsed_events.states.left_poke_in_error) == 1) == 1,
        if (value(currentOdor(1, n_started_trials)) == 1 || ...
                value(currentOdor(1, n_started_trials)) == 2) == 1
            currentChoiceConc(1,n_started_trials) = 1;
        elseif (value(currentOdor(1, n_started_trials)) == 3 || ...
            value(currentOdor(1, n_started_trials)) == 4) == 1
            currentChoiceMix(1,n_started_trials) = 1;
        end
    elseif (~isempty(parsed_events.states.right_poke_in_correct) == 1 || ...
            ~isempty(parsed_events.states.right_poke_in_error) == 1) == 1,
        if (value(currentOdor(1, n_started_trials)) == 1 || ...
                value(currentOdor(1, n_started_trials)) == 2) == 1
            currentChoiceConc(1,n_started_trials) = 0;
        elseif (value(currentOdor(1, n_started_trials)) == 3 || ...
            value(currentOdor(1, n_started_trials)) == 4) == 1
            currentChoiceMix(1,n_started_trials) = 0;
        end
    end
    
%     disp(value(currentChoiceConc))
%     disp(value(currentChoiceMix))
    
    
    if (~isempty(parsed_events.states.left_poke_in_correct) == 1 || ...
            ~isempty(parsed_events.states.left_poke_in_error) == 1 || ...
            ~isempty(parsed_events.states.right_poke_in_correct) == 1 || ...
            ~isempty(parsed_events.states.right_poke_in_error) == 1) == 1,

        if (value(currentOdor(1, n_started_trials)) == 1 || ...
                value(currentOdor(1, n_started_trials)) == 2) == 1
            
%             if ((value(elapsedOdor1ValidTrials) == 1 && value(elapsedOdor2ValidTrials) == 0) == 1 || ...
%                     (value(elapsedOdor1ValidTrials) == 0 && value(elapsedOdor2ValidTrials) == 1) == 1) == 1
%                 
%                 weightedBiasConcSession(n_started_trials, :) = [n_started_trials value(wBiasConcNR)];
%                 wBiasConcNR.value = value(weightedBiasConcSession(n_started_trials, 2));
%                 wBiasConc.value = round(value(weightedBiasConcSession(n_started_trials, 2)) * 100) / 100;
%             else
                
               weightedBiasConcSession(n_started_trials, :) = [n_started_trials (1 - value(rateBias)) * value(wBiasConcNR) + ...
                   value(rateBias) * value(currentChoiceConc(1,n_started_trials))];
               wBiasConcNR.value = value(weightedBiasConcSession(n_started_trials, 2));
               wBiasConc.value = round(value(weightedBiasConcSession(n_started_trials, 2)) * 100) / 100;
%             end
        elseif (value(currentOdor(1, n_started_trials)) == 3 || ...
                value(currentOdor(1, n_started_trials)) == 4) == 1
            
%             if ((value(elapsedMix1ValidTrials) == 1 && value(elapsedMix2ValidTrials) == 0) == 1 || ...
%                     (value(elapsedMix1ValidTrials) == 0 && value(elapsedMix2ValidTrials) == 1) == 1) == 1
%                 
%                 weightedBiasMixSession(n_started_trials, :) = [n_started_trials value(wBiasMixNR)];
%                 wBiasMixNR.value = value(weightedBiasMixSession(n_started_trials, 2));
%                 wBiasMix.value = round(value(weightedBiasMixSession(n_started_trials, 2)) * 100) / 100;
%             else
                
               weightedBiasMixSession(n_started_trials, :) = [n_started_trials (1 - value(rateBias)) * value(wBiasMixNR) + ...
                   value(rateBias) * value(currentChoiceMix(1,n_started_trials))];
               wBiasMixNR.value = value(weightedBiasMixSession(n_started_trials, 2));
               wBiasMix.value = round(value(weightedBiasMixSession(n_started_trials, 2)) * 100) / 100;
%             end
        end
%         end
    end
%     disp(value(weightedBiasSession(n_started_trials, :)))
%     disp(value(wBiasNR))
%     disp(value(wBias))
% ----------------------------------------------------------------------- %
    if ismember(n_started_trials, value(contextTaskTrialsPerBlock)*([1 3 5])) == 1
        if strcmp(value(contextTask), 'Yes') == 1
            stimVectorCont = nan(1,4);
            i(1) = value(stim1ForContext);
            i(2) = value(stim2ForContext);
            i(3) = value(stim3ForContext);
            i(4) = value(stim4ForContext);
            i(find(isnan(i)==1))=[];
            stimVectorCont(i) = stimVector(i);
            stimVector.value = stimVectorCont;
            disp(value(stimVector))
            perfDiffFunctionConc.value = (value(A2PerfCont) - value(A1PerfCont)) ./ (1 + ...
                exp((value(perf) - value(thresholdPerfCont))./ value(slopePerfCont))) + value(A1PerfCont);
            perfDiffFunctionMix.value = (value(A2PerfCont) - value(A1PerfCont)) ./ (1 + ...
                exp((value(perf) - value(thresholdPerfCont))./ value(slopePerfCont))) + value(A1PerfCont);
%             wPerfNRConc.value = 0.5;
%             wPerfNRMix.value = 0.5;
%             figure; plot(value(perf), value(perfDiffFunctionConc), 'o');
%             figure; plot(value(perf), value(perfDiffFunctionMix), 'o');
        end
        
    elseif ismember(n_started_trials, value(contextTaskTrialsPerBlock)*([2 4 6])) == 1
        if strcmp(value(contextTask), 'Yes') == 1
            stimVector.value = ...
                -value(lastValue) - value(logStep) + value(logStep) * (1:value(lengthCal));
%             disp(value(stimVector))
            perfDiffFunctionConc.value = (value(A2PerfConc) - value(A1PerfConc)) ./ (1 + ...
                exp((value(perf) - value(thresholdPerfConc))./ value(slopePerfConc))) + value(A1PerfConc);
            perfDiffFunctionMix.value = (value(A2PerfMix) - value(A1PerfMix)) ./ (1 + ...
                exp((value(perf) - value(thresholdPerfMix))./ value(slopePerfMix))) + value(A1PerfMix);
%             wPerfNRConc.value = 0.5;
%             wPerfNRMix.value = 0.5;
%             figure; plot(value(perf), value(perfDiffFunctionConc), 'o');
%             figure; plot(value(perf), value(perfDiffFunctionMix), 'o');
        end
    end
% disp(value(bankVectorMix1))
% disp(value(nextStimMix))
    
% changing d %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    first = [];
    last = [];
                     
    if (~isempty(parsed_events.states.rin_no_water)  == 1 || ~isempty(parsed_events.states.lin_no_water) == 1  || ...
            ~isempty(parsed_events.states.rin_water)  == 1 || ~isempty(parsed_events.states.lin_water) == 1) == 1,
        if (value(currentOdor(1, n_started_trials)) == 1 || ...
                value(currentOdor(1, n_started_trials)) == 2) == 1
            
%             disp(value(wPerfConc))
%             disp(value(perf))
%             disp(find(value(wPerfConc) == value(perf)))
%             disp(value(perfDiffFunctionConc(find(value(wPerfConc) == value(perf)))))
            
            stimListConc.value = [];
            dStimSessionConc(1, n_started_trials + 1) = ...
                value(perfDiffFunctionConc(find(value(wPerfConc) == value(perf))));
%             disp(dStimSessionConc(1, n_started_trials + 1))
            dStimConc.value = dStimSessionConc(1, n_started_trials + 1);
            
        A = 500;
        x = fliplr(-stimVector(find((isnan(value(stimVector))) == 0)));
       
        %%% concentration
        if value(dStimConc) >= 0.999
            dStimConc.value = 0.999;
        elseif (value(dStimConc) <= 0.0001 && value(dStimConc) >= 0) == 1
            dStimConc.value = 0.0001;
        elseif value(dStimConc) <= -0.999
            dStimConc.value = -0.999;
        elseif (value(dStimConc) >= -0.0001 && value(dStimConc) < 0) == 1
            dStimConc.value = -0.0001;
        end       

        
%         if (value(dStimConc) > -0.0001 && value(dStimConc) < 0.0001) == 1
%             dStim = 0.0001;
%         elseif (value(dStimConc) < -0.0001 || value(dStimConc) > 0.0001) == 1
            dStim = abs(value(dStimConc));
%         end
    
        gd = round(A * (1 - geocdf(x,value(dStim))) / (1 - geocdf(x(1), value(dStim))));
        last = 0;
        stimList = [];
        for i = 1 : length(x)
            first = 1 + last;
            last = last + gd(i);
            stimList(first:last) = x(i);
        end
%         figure; hist(stimList)
%         disp(value(dStimConc))
        
        if value(dStimConc) >= 0
            stimList = stimList(randperm(length(stimList)));
            stimListConc.value = -stimList;
%             figure; hist(value(stimListConc))
        elseif value(dStimConc) < 0
            stimList1 = nan(1, length(stimList));
            for i = 1 : length(x)
                stimList1(find(stimList == x(1)+i-1)) = x(end)-i+1;
            end
            stimList1 = stimList1(randperm(length(stimList1)));
            stimListConc.value = -stimList1;
%             figure; hist(value(stimListConc))
        end
            nextStimConc.value = value(stimListConc(n_started_trials + 1));
%             disp(value(stimListConc));
%             disp(value(nextStimConc));
            
            
        elseif (value(currentOdor(1, n_started_trials)) == 3 || ...
                value(currentOdor(1, n_started_trials)) == 4) == 1
            
            stimListMix.value = [];
            dStimSessionMix(1, n_started_trials + 1) = ...
                value(perfDiffFunctionMix(find(value(wPerfMix) == value(perf))));
            dStimMix.value = dStimSessionMix(1, n_started_trials + 1);
            
        %%% mixture
        A = 500;
        x = fliplr(-stimVector(find((isnan(value(stimVector))) == 0)));
        
        if value(dStimMix) >= 0.999
            dStimMix.value = 0.999;
        elseif (value(dStimMix) <= 0.0001 && value(dStimMix) >= 0) == 1
            dStimMix.value = 0.0001;
        elseif value(dStimMix) <= -0.999
            dStimMix.value = -0.999;
        elseif (value(dStimMix) >= -0.0001 && value(dStimMix) < 0) == 1
            dStimMix.value = -0.0001;
        end       
        
%         if (value(dStimConc) > -0.0001 && value(dStimConc) < 0.0001) == 1
%             dStim = 0.0001;
%         elseif (value(dStimConc) < -0.0001 || value(dStimConc) > 0.0001) == 1
            dStim = abs(value(dStimMix));
%         end
    
        gd = round(A * (1 - geocdf(x,value(dStim))) / (1 - geocdf(x(1), value(dStim))));
        last = 0;
        stimList = [];
        for i = 1 : length(x)
            first = 1 + last;
            last = last + gd(i);
            stimList(first:last) = x(i);
        end
%         figure; hist(stimList)
%         disp(value(dStimMix))
        
        if value(dStimMix) >= 0
            stimList = stimList(randperm(length(stimList)));
            stimListMix.value = -stimList;
%             figure; hist(value(stimListMix))
        elseif value(dStimMix) < 0
            stimList1 = nan(1, length(stimList));
            for i = 1 : length(x)
                stimList1(find(stimList == x(1)+i-1)) = x(end)-i+1;
            end
            stimList1 = stimList1(randperm(length(stimList1)));
            stimListMix.value = -stimList1;
%             figure; hist(value(stimListMix)
        end
        nextStimMix.value = value(stimListMix(n_started_trials + 1));
        end
    end
    
%     disp(value(nextStimConc));
%     disp(value(nextStimMix))
% ----------------------------------------------------------------------- %


% changing probability of odors %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     value(biasOdorProbFunction)

    if (~isempty(parsed_events.states.left_poke_in_correct) == 1 || ...
                ~isempty(parsed_events.states.left_poke_in_error) == 1 || ...
                ~isempty(parsed_events.states.right_poke_in_correct) == 1 || ...
                ~isempty(parsed_events.states.right_poke_in_error) == 1) == 1,
        
            
        switch value(probChangeMode)
            case 'Manual'
                probOdor1.value = probOdor1Session(n_started_trials + 1,2);
                probMix1.value = probMix1Session(n_started_trials + 1,2);
                
            case 'Automatic'
                if (value(currentOdor(1, n_started_trials)) == 1 || ...
                    value(currentOdor(1, n_started_trials)) == 2) == 1
                    probOdor1Session(n_started_trials + 1, :) = ...
                        [n_started_trials + 1 value(biasOdorProbFunction(find(value(wBiasConc) == value(bias))))];
                    probOdor1.value = probOdor1Session(n_started_trials + 1,2);
                    concListAll(1, n_started_trials + 2:1000) = ...
                        (rand(1,length(n_started_trials + 2:1000)) > value(probOdor1)) + 1;
                
                elseif (value(currentOdor(1, n_started_trials)) == 3 || ...
                    value(currentOdor(1, n_started_trials)) == 4) == 1
                    probMix1Session(n_started_trials + 1, :) = ...
                        [n_started_trials + 1 value(biasOdorProbFunction(find(value(wBiasMix) == value(bias))))];
                    probMix1.value = probMix1Session(n_started_trials + 1,2);
                    mixListAll(1, n_started_trials + 2:1000) = ...
                        (rand(1,length(n_started_trials + 2:1000)) > value(probMix1)) + 1;
                end
                
%                 if (value(currentOdor(1, n_started_trials)) == 1 || ...
%                     value(currentOdor(1, n_started_trials)) == 2) == 1
%                     sideList(1, n_started_trials + 2) = concListAll(1, n_started_trials + 2);
%                 elseif (value(currentOdor(1, n_started_trials)) == 1 || ...
%                     value(currentOdor(1, n_started_trials)) == 2) == 1
%                     sideList(1, n_started_trials + 2) = mixListAll(1, n_started_trials + 2);
%                 end
                
                
                
        end
    
    end
%     disp(value(probOdor1Session(n_started_trials + 1, :)))
    
%     sideList(1, n_started_trials + 2:1000) = ...
%         (rand(1,length(n_started_trials + 2:1000)) > value(probOdor1)) + 1;

%     currentOdor(1,n_started_trials + 1) = value(sideList(1, n_started_trials + 1));
%        disp(value(currentOdor));
    
% ----------------------------------------------------------------------- %

% stimuli proportion %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        stimListTrialNOdor1 = value(currentStimOdor1(:,2));
        stimProportionTrialNOdor1 = hist(stimListTrialNOdor1);
        stimProportionTrialNOdor1(find(stimProportionTrialNOdor1 == 0)) = [];
        stimListTrialNOdor1(find(isnan(stimListTrialNOdor1) == 1)) = [];
        stimsTrialNOdor1.value = unique(stimListTrialNOdor1);
        stimProportionOdor1.value = stimProportionTrialNOdor1;
        
        stimListTrialNOdor2 = value(currentStimOdor2(:,2));
        stimProportionTrialNOdor2 = hist(stimListTrialNOdor2);
        stimProportionTrialNOdor2(find(stimProportionTrialNOdor2 == 0)) = [];
        stimListTrialNOdor2(find(isnan(stimListTrialNOdor2) == 1)) = [];
        stimsTrialNOdor2.value = unique(stimListTrialNOdor2);
        stimProportionOdor2.value = stimProportionTrialNOdor2;
        
%         disp(value(stimsTrialNConc(n_started_trials)))
%         disp(value(stimProportionConc(n_started_trials)))
        
        stimListTrialNMix1 = value(currentStimMix1(:,2));
        stimProportionTrialNMix1 = hist(stimListTrialNMix1);
        stimProportionTrialNMix1(find(stimProportionTrialNMix1 == 0)) = [];
        stimListTrialNMix1(find(isnan(stimListTrialNMix1) == 1)) = [];
        stimsTrialNMix1.value = unique(stimListTrialNMix1);
        stimProportionMix1.value = stimProportionTrialNMix1;
        
        stimListTrialNMix2 = value(currentStimMix2(:,2));
        stimProportionTrialNMix2 = hist(stimListTrialNMix2);
        stimProportionTrialNMix2(find(stimProportionTrialNMix2 == 0)) = [];
        stimListTrialNMix2(find(isnan(stimListTrialNMix2) == 1)) = [];
        stimsTrialNMix2.value = unique(stimListTrialNMix2);
        stimProportionMix2.value = stimProportionTrialNMix2;
        
% ----------------------------------------------------------------------- %

        
        switch(value(taskIdentity))
            case 'Concentration task'
                if value(concListAll(1, n_started_trials + 1)) == 1
                    sideList(1, n_started_trials + 1) = 1;
                    concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                    currentOdor(1, n_started_trials + 1) = 1;
                    currentOdorORMix.value = 'Odor 1';
                    currentBank(n_started_trials + 1) = value(bankVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                    currentValve(n_started_trials + 1) = value(valveVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimOdor1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                elseif value(concListAll(1, n_started_trials + 1)) == 2
                    sideList(1, n_started_trials + 1) = 2;
                    concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                    currentOdor(1, n_started_trials + 1) = 2;
                    currentOdorORMix.value = 'Odor 2';
                    currentBank(n_started_trials + 1) = value(bankVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                    currentValve(n_started_trials + 1) = value(valveVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                    currentStimOdor2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                end
                    
            case 'Mixture task'
                if value(mixListAll(1, n_started_trials + 1)) == 1
                    sideList(1, n_started_trials + 1) = 1;
                    currentOdor(1, n_started_trials + 1) = 3;
                    currentOdorORMix.value = 'Mix 1';
                    mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                    currentBank(n_started_trials + 1) = value(bankVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                    currentValve(n_started_trials + 1) = value(valveVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                elseif value(mixListAll(1, n_started_trials + 1)) == 2
                    sideList(1, n_started_trials + 1) = 2;
                    mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                    currentOdor(1, n_started_trials + 1) = 4;
                    currentOdorORMix.value = 'Mix 2';
                    currentBank(n_started_trials + 1) = value(bankVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                    currentValve(n_started_trials + 1) = value(valveVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                    currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                    currentStimMix2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                end
                    
                                
            case 'Both - blocks'
                block = [];
                last = 0;
                for i = 1 : floor(500 / value(blockTaskTrialsPerBlock))
                    first = last + 1;
                    last = i * value(blockTaskTrialsPerBlock);
                    block = first : last;
                    if ismember(n_started_trials + 1, block) == 1
                        break
                    end
                end
                a = i/2;
                whole = floor(a);
                part = a - whole;
                if part > 0;  
                    r = 'odd';
                else
                    r = 'even';
                end
                switch(value(blockTaskFirstBlock))
                    case 'Concentration task'
                        if strcmp(r, 'odd')
                            if value(concListAll(1, n_started_trials + 1)) == 1
                                sideList(1, n_started_trials + 1) = 1;
                                currentOdor(1, n_started_trials + 1) = 1;
                                currentOdorORMix.value = 'Odor 1';
                                concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                                currentBank(n_started_trials + 1) = value(bankVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                                currentValve(n_started_trials + 1) = value(valveVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                                currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                                currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                                currentStimOdor1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];

                            elseif value(concListAll(1, n_started_trials + 1)) == 2
                                sideList(1, n_started_trials + 1) = 2;
                                currentOdor(1, n_started_trials + 1) = 2;
                                currentOdorORMix.value = 'Odor 2';
                                concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                                currentBank(n_started_trials + 1) = value(bankVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                                currentValve(n_started_trials + 1) = value(valveVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                                currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                                currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                                currentStimOdor2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                                
                            end
                            
                        elseif strcmp(r, 'even')
                            if value(mixListAll(1, n_started_trials + 1)) == 1
                                sideList(1, n_started_trials + 1) = 1;
                                currentOdor(1, n_started_trials + 1) = 3;
                                currentOdorORMix.value = 'Mix 1';
                                mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                                currentBank(n_started_trials + 1) = value(bankVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                                currentValve(n_started_trials + 1) = value(valveVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                                currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                                currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                                currentStimMix1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                                disp(value(currentValve(n_started_trials + 1)))
                                
                            elseif value(mixListAll(1, n_started_trials + 1)) == 2
                                sideList(1, n_started_trials + 1) = 2;
                                currentOdor(1, n_started_trials + 1) = 4;
                                currentOdorORMix.value = 'Mix 2';
                                mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                                currentBank(n_started_trials + 1) = value(bankVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                                currentValve(n_started_trials + 1) = value(valveVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                                currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                                currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                                currentStimMix2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                                disp(value(currentValve(n_started_trials + 1)))

                            end
                        end
                           
                    case 'Mixture task'
                        if strcmp(r, 'even')
                            if value(mixListAll(1, n_started_trials + 1)) == 1
                                sideList(1, n_started_trials + 1) = 1;
                                currentOdor(1, n_started_trials + 1) = 3;
                                currentOdorORMix.value = 'Mix 1';
                                mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                                currentBank(n_started_trials + 1) = value(bankVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                                currentValve(n_started_trials + 1) = value(valveVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                                currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                                currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                                currentStimMix1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];

                            elseif value(mixListAll(1, n_started_trials + 1)) == 2
                                sideList(1, n_started_trials + 1) = 2;
                                currentOdor(1, n_started_trials + 1) = 4;
                                currentOdorORMix.value = 'Mix 2';
                                mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                                currentBank(n_started_trials + 1) = value(bankVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                                currentValve(n_started_trials + 1) = value(valveVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                                currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                                currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                                currentStimMix2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                                
                            end
                        elseif strcmp(r, 'odd')
                            if value(concListAll(1, n_started_trials + 1)) == 1
                                sideList(1, n_started_trials + 1) = 1;
                                currentOdor(1, n_started_trials + 1) = 1;
                                currentOdorORMix.value = 'Odor 1';
                                concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                                currentBank(n_started_trials + 1) = value(bankVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                                currentValve(n_started_trials + 1) = value(valveVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                                currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                                currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                                currentStimOdor1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];

                            elseif value(concListAll(1, n_started_trials + 1)) == 2
                                sideList(1, n_started_trials + 1) = 2;
                                currentOdor(1, n_started_trials + 1) = 2;
                                currentOdorORMix.value = 'Odor 2';
                                concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                                currentBank(n_started_trials + 1) = value(bankVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                                currentValve(n_started_trials + 1) = value(valveVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                                currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                                currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                                currentStimOdor2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                                
                            end
                        end
                end
                
            case 'Both - interleaved'
                if value(interleavedList(1, n_started_trials + 1)) == 1
                    sideList(1, n_started_trials + 1) = 1;
                    a = randi(2,1);
                    if a == 1
                        currentOdor(1, n_started_trials + 1) = 1;
                        currentOdorORMix.value = 'Odor 1';
                        concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                        currentBank(n_started_trials + 1) = value(bankVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                        currentValve(n_started_trials + 1) = value(valveVectorOdor1(find(fliplr(value(stimVector)) == value(nextStimConc))));
                        currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                        currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                        currentStimOdor1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                        
                    elseif a == 2
                        currentOdor(1, n_started_trials + 1) = 3;
                        currentOdorORMix.value = 'Mix 1';
                        mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                        currentBank(n_started_trials + 1) = value(bankVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                        currentValve(n_started_trials + 1) = value(valveVectorMix1(find(fliplr(value(stimVector)) == value(nextStimMix))));
                        currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                        currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                        currentStimMix1(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                        
                    end
                        
                elseif value(interleavedList(1, n_started_trials + 1)) == 2
                    sideList(1, n_started_trials + 1) = 2;
                    a = randi(2,1);
                    if a == 1
                        currentOdor(1, n_started_trials + 1) = 2;
                        currentOdorORMix.value = 'Odor 2';
                        concList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                        currentBank(n_started_trials + 1) = value(bankVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                        currentValve(n_started_trials + 1) = value(valveVectorOdor2(find(fliplr(value(stimVector)) == value(nextStimConc))));
                        currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                        currentStimConc(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                        currentStimOdor2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimConc)];
                        
                    elseif a == 2
                        currentOdor(1, n_started_trials + 1) = 4;
                        currentOdorORMix.value = 'Mix 2';
                        mixList(n_started_trials + 1, :) = [n_started_trials + 1 value(sideList(1, n_started_trials + 1))];
                        currentBank(n_started_trials + 1) = value(bankVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                        currentValve(n_started_trials + 1) = value(valveVectorMix2(find(fliplr(value(stimVector)) == value(nextStimMix))));
                        currentStim(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                        currentStimMix(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                        currentStimMix2(n_started_trials + 1, :) = [n_started_trials + 1 value(nextStimMix)];
                        
                    end
                end
                
        end
       
        currentConcORRatio.value = abs(value(currentStim(n_started_trials + 1, 2)));
       
       
       valveNumber.value = value(currentValve(n_started_trials + 1));
%        disp(value(valveNumber))
       if value(currentBank(n_started_trials + 1)) == 1
           OlfBank.value = 'OlfBankA';
       elseif value(currentBank(n_started_trials + 1)) == 2
           OlfBank.value = 'OlfBankB';
       elseif value(currentBank(n_started_trials + 1)) == 3
           OlfBank.value = 'OlfBankC';
       elseif value(currentBank(n_started_trials + 1)) == 4
           OlfBank.value = 'OlfBankD';
       end
%        disp(currentOdor(1,n_started_trials + 1));
%        disp(value(OlfBank));
%        disp(value(valveNumber));
%        disp(value(currentStim));
       
%        disp(value(currentStimOdor1))
        
 
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