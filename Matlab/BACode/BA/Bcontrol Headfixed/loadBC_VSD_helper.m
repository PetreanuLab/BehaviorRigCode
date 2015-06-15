function dp = loadBC_VSD_helper(dp, saved_history,saved)

% Manually entered % BA % Protocol head_fixed2
dp.trialTypeDesc = {'Valid','InValid'};

num_trials = dp.ntrials;

start = zeros(num_trials, 1)';
dp.TrialInit =  NaN(num_trials, 1)';
dp.TrialAvail =  NaN(num_trials, 1)';

dp.timeCueOn = NaN(num_trials, 1)';
dp.timeCueOff = NaN(num_trials, 1)';
dp.timeStimulusOn = NaN(num_trials, 1)';
dp.timeStimulusChange = NaN(num_trials, 1)';
dp.currdelayStimulusChange =cell2mat(saved_history.SetGUI_currChangeStimDelay(1:num_trials))'*1000;

% dp.water = NaN(num_trials, 1)';
% dp.timeWater = NaN(num_trials, 1)';
% dp.timePunish = NaN(num_trials, 1)';
dp.timeOutcome = NaN(num_trials, 1)';
dp.ChoiceCorrect= NaN(num_trials, 1)';
dp.ChoiceCorrectValid= NaN(num_trials, 1)';
dp.ChoiceCorrectInvalid= NaN(num_trials, 1)';
dp.Premature =  NaN(num_trials, 1)';
dp.ChoiceMissed = NaN(num_trials, 1)';

dp.isValid = saved.SetGUI_validHistory(1:num_trials); % =1 valid 0 invalid
dp.validLocation = saved.SetGUI_validLocHistory(1:num_trials); % the stimulus location number that is valid
dp.punishEarlyLick =  cell2mat(saved_history.TrialGUI_punishEarlyLick(1:num_trials))';
dp.punishError =  cell2mat(saved_history.TrialGUI_punishError(1:num_trials))';
dp.rewardWitholding =  cell2mat(saved_history.TrialGUI_rewardWitholding(1:num_trials))';
dp.freeWaterAtChange =  cell2mat(saved_history.TrialGUI_freeWaterAtChange(1:num_trials))';
dp.isRandom = ismember(saved_history.StimulusGUI_validTrialSelection(1:num_trials),'random')';
dp.probValid = cell2mat(saved_history.StimulusGUI_validTrialProb(1:num_trials))';
dp.probChangeLocation = cell2mat(saved_history.StimulusGUI_changeLocation1(1:num_trials))';
dp.noChangeInvalid = cell2mat(saved_history.StimulusGUI_stimlusChangeProb(1:num_trials))';
dp.changeLocation =  NaN(num_trials, 1)';
dp.changeLocation(dp.validLocation==1 & dp.isValid==1) = 1; % the stimulus location number that is valid
dp.changeLocation(dp.validLocation==1 & dp.isValid==0) = 2; % the stimulus location number that is valid
dp.changeLocation(dp.validLocation==2 & dp.isValid==2) = 2; % the stimulus location number that is valid
dp.changeLocation(dp.validLocation==2 & dp.isValid==0) = 1; % the stimulus location number that is valid

% for compatiblity
dp.controlLoop = NaN(num_trials, 1)';
dp.reDraw = NaN(num_trials, 1)';


%% Extract trial by trial information
for trial_num = 1:num_trials
    
    % get the matrix of states, actions, and times for each trial
    parsed_events = dp.parsedEvents_history{trial_num}';
    
    % extract trial start time
    % TrialInit
    current_trial_start = parsed_events.states.state_0(1,2); % BA check this with Eran or code
    start(trial_num) = current_trial_start;
    
    dp.TrialInit(trial_num) =current_trial_start*1000;
    dp.TrialAvail(trial_num) =current_trial_start*1000;
    
    % Cue and Stimuli
    % ( NOTE all these times are State machine times and
    % may not correspond to the exact time te stimulus is presented)
    
    if ~isempty(parsed_events.states.cue)
        dp.timeCueOn(trial_num) = parsed_events.states.cue(1,1)*1000;
        dp.timeCueOff(trial_num) = parsed_events.states.cue(1,2)*1000;
    end
    if ~isempty(parsed_events.states.stim_onset)
        dp.timeStimulusOn(trial_num) =parsed_events.states.stim_onset(1,1)*1000;
    end
    dp.timeResponseAvailable(trial_num) = dp.timeStimulusOn(trial_num);
    
    if ~isempty(parsed_events.states.response_window)
        dp.timeStimulusChange(trial_num)  = parsed_events.states.response_window(1,1)*1000;
    end
    
    if ~isempty(parsed_events.states.correct_valid) ||~isempty(parsed_events.states.correct_invalid)
        dp.ChoiceCorrect(trial_num) = 1;
    else % could be premature, missed
        dp.ChoiceCorrect(trial_num) = 0;
        if ~isempty(parsed_events.states.wrong_choice)
            dp.timeOutcome(trial_num) = parsed_events.states.wrong_choice(1,1)*1000;
        end
    end
    
    
    % valid or invalid only makes sense after the stimulus change
    if ~isempty(parsed_events.states.response_window)
        if dp.isValid(trial_num)==1
            dp.ChoiceCorrectValid(trial_num) = 0;
            dp.ChoiceMissed(trial_num) = 0;
        else
            dp.ChoiceCorrectInvalid(trial_num) = 0;
        end
        
        if ~isempty(parsed_events.states.correct_valid)
            dp.ChoiceCorrectValid(trial_num) = 1;
            dp.timeOutcome(trial_num) = parsed_events.states.correct_valid(1,1)*1000;
        elseif   ~isempty(parsed_events.states.correct_invalid)
            dp.ChoiceCorrectInvalid(trial_num) = 1;
            dp.timeOutcome(trial_num) = parsed_events.states.correct_invalid(1,1)*1000;
        elseif ~isempty(parsed_events.states.missed_response)% this can only happen on valid trials
            dp.ChoiceMissed(trial_num) = 1;
        end
        if   dp.punishEarlyLick(trial_num)  % premature is only defined when early licks are punished
            dp.Premature(trial_num) = 0;
        end
    elseif   dp.punishEarlyLick(trial_num) 
        dp.Premature(trial_num) = 1;
    end
    
    
    dp.TrialNumber(trial_num) = trial_num;
    
    
end; %end trial for-loop

dp.isValid(dp.Premature==1) = nan;
dp.ChoiceCorrect(dp.Premature==1|(dp.freeWaterAtChange==1 & dp.isValid==1)) = nan;
dp.ChoiceCorrectValid(dp.Premature==1|(dp.freeWaterAtChange==1 & dp.isValid==1)) = nan;
dp.ChoiceCorrectInvalid(dp.Premature==1) = nan;
dp.ChoiceMissed(dp.Premature==1|(dp.freeWaterAtChange==1 & dp.isValid==1)) = nan;
dp.changeLocation(dp.Premature==1) = NaN;

