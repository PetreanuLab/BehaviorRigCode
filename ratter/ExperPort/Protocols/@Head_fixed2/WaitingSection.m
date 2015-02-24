
function  [x, y]  =  WaitingSection(obj, action, x,  y)

GetSoloFunctionArgs;

% Deals with sound generation and uploading to RTLSoundMachine

switch action,
    case 'init'

        gcf;

        %SoundManagerSection(obj, 'init');

        %For Error Tone

        NumEditParam(obj, 'Wait_light_amplitude', .5, x, y, 'label', 'amplitude'); next_row(y,1);
        
        NumEditParam(obj, 'Wait_light_frequency', 20, x, y, 'label', 'frequency'); next_row(y,1);
        
        NumEditParam(obj, 'Wait_light_pulse_duration', 0.01, x, y, 'label', 'pulse width'); next_row(y,1);

        NumEditParam(obj, 'Wait_light_train_duration', 2, x, y, 'label', 'stim duration'); next_row(y,1);
        
        NumEditParam(obj, 'Wait_light_train_delay', 0, x, y, 'label', 'delay'); next_row(y,1);
        
        NumEditParam(obj, 'Wait_light_prob', 0, x, y, 'label', 'stim prob'); next_row(y,1);
        
        MenuParam(obj, 'Wait_start_state', {'wait_4_odor','wait_4_lick','random'}, 'wait_4_odor', x, y, 'label','start astate'); next_row(y,1);
        
        SubHeaderParam(obj, 'Wait_light', 'photostimulation', x, y); next_row(y,1);
        
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'Wait_light_amplitude','Wait_light_frequency','Wait_light_pulse_duration',...
            'Wait_light_train_duration','Wait_light_train_delay','Wait_start_state', 'Wait_light_prob'});
        EditParam(obj, 'WaitingSoundSPL',     120,  x, y, 'label', 'Waiting Sound pressure', ...
            'labelfraction', 0.6);   next_row(y);
        EditParam(obj, 'WaitingSoundDur',    0.3,  x, y, 'label', 'Waiting Sound duration', ...
            'labelfraction', 0.6);   next_row(y);
        EditParam(obj, 'WaitingSoundFreq',    10000,  x, y, 'label', 'Waiting Sound frequency', ...
            'labelfraction', 0.6);   next_row(y);

        set_callback({WaitingSoundSPL, WaitingSoundDur, WaitingSoundFreq}, {'WaitingSection', 'set_tone'});



        %---------


        sound_samp_rate = SoundManagerSection(obj, 'get_sample_rate');
        SoloParamHandle(obj, 'SoundSampRate', 'value', sound_samp_rate);

        SoloParamHandle(obj, 'IdWaitingTone', 'value', 0);
        SoundManagerSection(obj, 'declare_new_sound', 'WaitingTone');
        IdWaitingTone.value = SoundManagerSection(obj, 'get_sound_id', 'WaitingTone');

        PushbuttonParam(obj, 'Play_WaitingTone', x,y, 'label', 'Play Waiting Tone', 'position');next_row(y);
        set_callback(Play_WaitingTone,{'SoundManagerSection', 'play_sound', 'WaitingTone'});

        MenuParam(obj, 'WaitingSound', {'on', 'off',}, ...
            'on', x, y, 'label','WaitingSound'); next_row(y,1);
        
   
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'IdWaitingTone','WaitingSoundDur'});

        
        NumEditParam(obj, 'WaitingWaterValve', 0.048, x, y, 'label', 'water valve'); next_row(y,1);
                
        NumEditParam(obj, 'WaitingMeanTime', 1.5, x, y, 'label', 'mean time Wait'); next_row(y,1);

        NumEditParam(obj, 'WaitingSDTime', 0, x, y, 'label', 'SD time Wait'); next_row(y,1);

        MenuParam(obj, 'WaitingAdaptiveMenu', {'on', 'off',}, ...
            'on', x, y, 'label','adaptive'); next_row(y,1);
        
        SubHeaderParam(obj, 'Waitingtrials', 'Waiting', x, y); next_row(y,2);

        SoloFunctionAddVars('StateMatrixSection', 'rw_args', ...
            {'WaitingSDTime','WaitingMeanTime','WaitingWaterValve'});

        SoloFunctionAddVars('Head_fixed2', 'ro_args', ...
            {'WaitingAdaptiveMenu','WaitingMeanTime'});
        
        WaitingSection(obj, 'set_tone');
        

    case 'set_tone'


        %%%%%Waiting Tone-----------------------

        switch value(WaitingSound)
            case 'on'

                t=0:(1/value(SoundSampRate)):value(WaitingSoundDur);
                t=t(1:(end-1));

                setWaitingTone = 10^((-74.5) / 20) * (sin(2 * pi * value(WaitingSoundFreq) * t));
                WaitingSOUND_SPL_70 = value(WaitingSoundSPL) - 70;
                Waitingsound = (10^(WaitingSOUND_SPL_70 / 20)) * setWaitingTone;

            case 'off'

                t=0:(1/value(SoundSampRate)):value(WaitingSoundDur);
                t=t(1:(end-1));

                WaitingSoundSPL.value=0;
                setWaitingTone = 10^((-74.5) / 20) * (sin(2 * pi * value(WaitingSoundFreq) * t));
                WaitingSOUND_SPL_70 = value(WaitingSoundSPL) - 70;
                Waitingsound = (10^(WaitingSOUND_SPL_70 / 20)) * setWaitingTone;

        end

        %%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %"set"_sound using SoundManagerSection

        SoundManagerSection(obj, 'set_sound', 'WaitingTone', Waitingsound);
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

    case 'update waiting time'
        if x
            WaitingMeanTime.value=WaitingMeanTime+0.04;
        else
            WaitingMeanTime.value=WaitingMeanTime-0.02;
        end


            
            
    otherwise
        error(['Don''t know how to handle action ' action]);
end;

return;