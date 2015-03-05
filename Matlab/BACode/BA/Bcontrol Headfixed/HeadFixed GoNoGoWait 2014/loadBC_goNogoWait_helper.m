function dp = loadBC_goNogoWait_helper(dp, saved_history)

% Manually entered % BA % Protocol head_fixed2
dp.odorDesc = {'AmylAcitate','Oct','Carv'};
dp.trialTypeDesc = {'Go','No Go','Wait'};

start = zeros(num_trials, 1)';
dp.TrialInit =  NaN(num_trials, 1)';
dp.TrialAvail =  NaN(num_trials, 1)';
dp.trialTypeIndex = NaN(num_trials, 1)';
dp.trialType = cell(num_trials,1)';
dp.timeResponseAvailable = NaN(num_trials, 1)';
dp.timeOutcome = NaN(num_trials, 1)';
dp.water = NaN(num_trials, 1)';
dp.airpuff = NaN(num_trials, 1)';
dp.ChoiceCorrect= NaN(num_trials, 1)';
dp.ChoiceCorrectGo= NaN(num_trials, 1)';
dp.ChoiceCorrectNoGo= NaN(num_trials, 1)';
dp.ChoiceCorrectWait= NaN(num_trials, 1)';
dp.timeOutcome= NaN(num_trials, 1)';
dp.Premature =  NaN(num_trials, 1)';

dp.timeStimulationOff =  NaN(num_trials, 1)';
dp.stimulation =  NaN(num_trials, 1)';
dp.delayStimulationOn  =  NaN(num_trials, 1)';
dp.startStateStimulationOn  =  cell(num_trials, 1)';
dp.stimulationFreq  =  NaN(num_trials, 1)';
dp.stimulationPulseDuration  =  NaN(num_trials, 1)';

% for compatiblity
dp.controlLoop = NaN(num_trials, 1)';
dp.reDraw = NaN(num_trials, 1)';

dp.odorValve = cell2mat(saved_history.Head_fixed2_current_odor(1:num_trials))'; % note this will be insufficient for odor definition if more than 1 Bank is used

% stimulation coordinates
dp.stimulationCoordX = cell2mat(saved_history.Head_fixed2_photostimulationCoordX(1:num_trials))';
dp.stimulationCoordY = cell2mat(saved_history.Head_fixed2_photostimulationCoordY(1:num_trials))';
dp.stimulationCoordZ = cell2mat(saved_history.Head_fixed2_photostimulationCoordZ(1:num_trials))';

% trialTypesInSession = unique(saved_history.OdorSection_odor_type2);
% if any(~ismember(trialTypesInSession,dp.trialTypeDesc))
%     error('unknown trial type in this session')
% end


% licks
% ParsedEvents_history{10}.pokes.C % remember beginings and ends

%% Extract trial by trial information
% get all state transition data
ParsedEvents_history=saved_history.ProtocolsSection_parsed_events(start_trial:end_trial);

for trial_num = 1:num_trials
    
    dp.trialType(trial_num) = eval(['saved_history.OdorSection_odor_type' num2str(dp.odorValve(trial_num)) '('  num2str(trial_num),')']);
    dp.trialTypeIndex(trial_num) = ismember(dp.trialType{trial_num},dp.trialTypeDesc);
    
    % get the matrix of states, actions, and times for each trial
    parsed_events = ParsedEvents_history{trial_num};
    
    % extract trial start time
    % TrialInit
    current_trial_start = parsed_events.states.state_0(1,2); % BA check this with Eran or code
    start(trial_num) = current_trial_start;
    
    dp.TrialInit(trial_num) =current_trial_start*1000;
    dp.TrialAvail(trial_num) =current_trial_start*1000;
    % Odor On
    dp.timeOdorOn(trial_num) = parsed_events.states.odor_valve_on(1,1)*1000;
    dp.timeOdorOff(trial_num) = parsed_events.states.odor_valve_on(1,2)*1000;
    dp.timeResponseAvailable(trial_num) = parsed_events.states.wait(1,2)*1000; % this is the end of the wait time that exists for all trials
    
    dp.ChoiceCorrect(trial_num) = 0;
    switch (lower(dp.trialType{trial_num}))
        case 'go'
            if ~isempty(parsed_events.states.water)
                dp.water(trial_num) = 1;
                dp.ChoiceCorrect(trial_num) = 1;
                dp.ChoiceCorrectGo(trial_num) = 1;
                dp.timeOutcome(trial_num)  = parsed_events.states.water(1,1)*1000;% not could be water/punishment/water+tone, impatient trials have NaN outcome.
            else dp.water(trial_num) = 0;
                dp.ChoiceCorrectGo(trial_num) = 0;
                dp.timeOutcome(trial_num)  = parsed_events.states.iti(1,1)*1000;
            end
            thisSection = 'GoSection_Go_';
        case 'nogo'
            if ~isempty(parsed_events.states.punish)
                dp.airpuff(trial_num) = 1;
                dp.timeOutcome(trial_num)  = parsed_events.states.punish(1,1)*1000;% not could be water/punishment/water+tone, impatient trials have NaN outcome.
                dp.ChoiceCorrectNoGo(trial_num) = 0;
            else
                dp.ChoiceCorrect(trial_num) = 1;
                dp.ChoiceCorrectNoGo(trial_num) = 1;
                dp.airpuff(trial_num) = 0;
                dp.timeOutcome(trial_num)  = parsed_events.states.iti(1,1)*1000;
            end
            thisSection = 'NoGoSection_NoGo_';
        case 'wait'
            if ~isempty(parsed_events.states.water)
                dp.water(trial_num) = 1;
                dp.ChoiceCorrect(trial_num) = 1;
                dp.ChoiceCorrectWait(trial_num) = 1;
                
                dp.Premature(trial_num) =0;
                dp.timeOutcome(trial_num)  = parsed_events.states.water(1,1)*1000;% not could be water/punishment/water+tone, impatient trials have NaN outcome.
            else dp.water(trial_num) = 0;
                dp.Premature(trial_num) =1;
                dp.ChoiceCorrectWait(trial_num) = 0;
                dp.timeOutcome(trial_num)  = parsed_events.states.iti(1,1)*1000;
            end
            thisSection = 'WaitingSection_Wait_';
        otherwise
            error(' unknown trial type');
            
            
    end
    
    
    % stimulation
    if ~isempty(parsed_events.states.iti_stim)
        dp.stimulation(trial_num) = 1;
        dp.timeStimulationOff(trial_num)  = parsed_events.states.iti_stim(1,1)*1000;%
        
        % NOTE these shouldn't change unless the user is messing them
        % during the session. Have not verified that they are correct (may
        % be offset where these values are changed a trial BEFORE the trial
        % they are actually used
        dp.delayStimulationOn(trial_num)  = saved_history.([thisSection 'light_train_delay']){trial_num};
        dp.startStateStimulationOn(trial_num)  = saved_history.([thisSection 'start_state'])(trial_num);
        dp.stimulationFreq(trial_num)  = saved_history.([thisSection 'light_frequency']){trial_num};
        dp.stimulationPulseDuration(trial_num)  = saved_history.([thisSection 'light_pulse_duration']){trial_num};
    elseif ~isempty(parsed_events.states.iti_nostim)
        dp.stimulation(trial_num) = 0;
    end
    
    dp.TrialNumber(trial_num) = trial_num;
    
    
end; %end trial for-loop

dp(ifile).parsedEvents_history = ParsedEvents_history'
