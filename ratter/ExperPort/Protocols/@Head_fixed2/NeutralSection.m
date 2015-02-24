
function  [x, y]  =  NeutralSection(obj, action, x,  y)

GetSoloFunctionArgs;

% Deals with sound generation and uploading to RTLSoundMachine

switch action,
    case 'init'

        gcf;
        
        NumEditParam(obj, 'Neutral_light_amplitude', .5, x, y, 'label', 'amplitude'); next_row(y,1);
        
        NumEditParam(obj, 'Neutral_light_frequency', 20, x, y, 'label', 'frequency'); next_row(y,1);
        
        NumEditParam(obj, 'Neutral_light_pulse_duration', 0.01, x, y, 'label', 'pulse width'); next_row(y,1);

        NumEditParam(obj, 'Neutral_light_train_duration', 2, x, y, 'label', 'stim duration'); next_row(y,1);
        
        NumEditParam(obj, 'Neutral_light_train_delay', 0, x, y, 'label', 'delay'); next_row(y,1);
        
        NumEditParam(obj, 'Neutral_light_prob', 0, x, y, 'label', 'stim prob'); next_row(y,1);
        
        MenuParam(obj, 'Neutral_start_state', {'wait_4_odor','wait_4_lick','random'}, 'wait_4_odor', x, y, 'label','start astate'); next_row(y,1);
        
        SubHeaderParam(obj, 'Neutral_light', 'photostimulation', x, y); next_row(y,1);
        
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'Neutral_light_amplitude','Neutral_light_frequency','Neutral_light_pulse_duration',...
            'Neutral_light_train_duration','Neutral_light_train_delay','Neutral_start_state', 'Neutral_light_prob'});
        
        NumEditParam(obj, 'NeutralMeanTime', 4, x, y, 'label', 'time after wait'); next_row(y,1);

        NumEditParam(obj, 'NeutralSDTime', 1, x, y, 'label', 'SD after wait'); next_row(y,1);

        SubHeaderParam(obj, 'NeutralTrials', 'Neutral', x, y); next_row(y,1);

        SoloFunctionAddVars('StateMatrixSection', 'rw_args', ...
            {'NeutralMeanTime', 'NeutralSDTime'});


    otherwise
        error(['Don''t know how to handle action ' action]);
end;

return;