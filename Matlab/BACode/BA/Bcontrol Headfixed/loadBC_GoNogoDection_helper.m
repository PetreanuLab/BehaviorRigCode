function dp = loadBC_GoNogoDection_helper(dp, saved_history,saved)

% Manually entered % BA 
dp.trialTypeDesc = {'Go','Nogo'};

num_trials = dp.ntrials;

start = zeros(num_trials, 1)';
dp.TrialInit =  NaN(num_trials, 1)';
dp.TrialAvail =  NaN(num_trials, 1)';

dp.timeStimulusOn = NaN(num_trials, 1)';

% dp.water = NaN(num_trials, 1)';
% dp.timeWater = NaN(num_trials, 1)';
% dp.timePunish = NaN(num_trials, 1)';
dp.timeOutcome = NaN(num_trials, 1)';
dp.ChoiceCorrect= NaN(num_trials, 1)';
dp.ChoiceCorrectGo= NaN(num_trials, 1)';
dp.ChoiceCorrectNogo= NaN(num_trials, 1)';
dp.ChoiceMissed = NaN(num_trials, 1)';

dp.isGo = saved.SetGUI_goHistory(1:num_trials);
dp.location = saved.SetGUI_loc1History(1:num_trials); % the stimulus location number that is valid
dp.punishError =  cell2mat(saved_history.TrialGUI_punishError(1:num_trials))';
dp.rewardWitholding =  cell2mat(saved_history.TrialGUI_rewardWitholding(1:num_trials))';
dp.freeWaterAtChange =  cell2mat(saved_history.TrialGUI_freeWaterAtChange(1:num_trials))';
dp.goTrialSelection = saved_history.StimulusGUI_goTrialSelection(1:num_trials)';
dp.goTrialProbablity =  cell2mat(saved_history.StimulusGUI_goTrialProb(1:num_trials))';


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
    
    if ~isempty(parsed_events.states.stim_onset)
        dp.timeStimulusOn(trial_num) =parsed_events.states.stim_onset(1,1)*1000;
    end
    dp.timeResponseAvailable(trial_num) = dp.timeStimulusOn(trial_num);
    
    if ~isempty(parsed_events.states.correct_go) ||~isempty(parsed_events.states.correct_nogo)
        dp.ChoiceCorrect(trial_num) = 1;
    else 
        dp.ChoiceCorrect(trial_num) = 0;
        if ~isempty(parsed_events.states.wrong_choice)
            dp.timeOutcome(trial_num) = parsed_events.states.wrong_choice(1,1)*1000;
        end
    end
    
    
    if dp.isGo(trial_num)
        dp.ChoiceCorrectGo(trial_num) = 0;
    else
        dp.ChoiceCorrectNoGo(trial_num) = 0;
    end
    
    if ~isempty(parsed_events.states.correct_go)
        dp.ChoiceCorrectGo(trial_num) = 1;
        dp.timeOutcome(trial_num) = parsed_events.states.reward_state(1,1)*1000;
    elseif   ~isempty(parsed_events.states.correct_nogo)
        dp.ChoiceCorrectNoGo(trial_num) = 1;
        if ~isempty(parsed_events.states.reward_state_nogo)
            dp.timeOutcome(trial_num) = parsed_events.states.reward_state_nogo(1,1)*1000;
        else
            dp.timeOutcome(trial_num) = parsed_events.states.correct_nogo(1,1)*1000;
        end
    elseif ~isempty(parsed_events.states.missed_response)% this can only happen on valid trials
        dp.ChoiceMissed(trial_num) = 1;
    end

    
    
    dp.TrialNumber(trial_num) = trial_num;
    
    
end; %end trial for-loop


