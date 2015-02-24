
function  [x, y]  =  GoSection(obj, action, x,  y)

GetSoloFunctionArgs;

% Deals with sound generation and uploading to RTLSoundMachine

switch action,
    case 'init'

        gcf;

        %SoundManagerSection(obj, 'init');

        %For Error Tone

        %---------
        
        NumEditParam(obj, 'Go_light_amplitude', .5, x, y, 'label', 'amplitude'); next_row(y,1);
        
        NumEditParam(obj, 'Go_light_frequency', 20, x, y, 'label', 'frequency'); next_row(y,1);
        
        NumEditParam(obj, 'Go_light_pulse_duration', 0.01, x, y, 'label', 'pulse width'); next_row(y,1);

        NumEditParam(obj, 'Go_light_train_duration', 2, x, y, 'label', 'stim duration'); next_row(y,1);
        
        NumEditParam(obj, 'Go_light_train_delay', 0, x, y, 'label', 'delay'); next_row(y,1);
        
        NumEditParam(obj, 'Go_light_prob', 0, x, y, 'label', 'stim prob'); next_row(y,1);
        
        MenuParam(obj, 'Go_start_state', {'wait_4_odor','wait_4_lick','random'}, 'wait_4_odor', x, y, 'label','start astate'); next_row(y,1);
        
        SubHeaderParam(obj, 'Go_light', 'photostimulation', x, y); next_row(y,1);
        
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'Go_light_amplitude','Go_light_frequency','Go_light_pulse_duration',...
            'Go_light_train_duration','Go_light_train_delay','Go_start_state', 'Go_light_prob'});
        %---------
        
        EditParam(obj, 'GoSoundSPL',     110,  x, y, 'label', 'Go Sound pressure', ...
            'labelfraction', 0.6);   next_row(y);
        EditParam(obj, 'GoSoundDur',    0.3,  x, y, 'label', 'Go Sound duration', ...
            'labelfraction', 0.6);   next_row(y);
        EditParam(obj, 'GoSoundFreq',    10000,  x, y, 'label', 'Go Sound frequency', ...
            'labelfraction', 0.6);   next_row(y);

        set_callback({GoSoundSPL, GoSoundDur, GoSoundFreq}, {'GoSection', 'set_tone'});



        
        
        sound_samp_rate = SoundManagerSection(obj, 'get_sample_rate');
        SoloParamHandle(obj, 'SoundSampRate', 'value', sound_samp_rate);

        SoloParamHandle(obj, 'IdGoTone', 'value', 0);
        SoundManagerSection(obj, 'declare_new_sound', 'GoTone');
        IdGoTone.value = SoundManagerSection(obj, 'get_sound_id', 'GoTone');

        PushbuttonParam(obj, 'Play_GoTone', x,y, 'label', 'Play Go Tone', 'position');next_row(y);
        set_callback(Play_GoTone,{'SoundManagerSection', 'play_sound', 'GoTone'});

        MenuParam(obj, 'GoSound', {'on', 'off',}, ...
            'on', x, y, 'label','GoSound'); next_row(y,1);

        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'IdGoTone','GoSoundDur'});
        %---------
        
        NumEditParam(obj, 'GoWaterValve', 0.048, x, y, 'label', 'water valve'); next_row(y,1);
        
        NumEditParam(obj, 'GoMeanTime', 4, x, y, 'label', 'time reward available'); next_row(y,1);

        NumEditParam(obj, 'GoSDTime', 1, x, y, 'label', 'SD reward available'); next_row(y,1);

        SubHeaderParam(obj, 'GOtrials', 'Go', x, y); next_row(y,1);

        SoloFunctionAddVars('StateMatrixSection', 'rw_args', ...
            {'GoWaterValve','GoMeanTime','GoSDTime'});

        GoSection(obj, 'set_tone');
    case 'set_tone'


        %%%%%Go Tone-----------------------

        switch value(GoSound)
            case 'on'

                t=0:(1/value(SoundSampRate)):value(GoSoundDur);
                t=t(1:(end-1));

                setGoTone = 10^((-74.5) / 20) * (sin(2 * pi * value(GoSoundFreq) * t));
                GoSOUND_SPL_70 = value(GoSoundSPL) - 70;
                Gosound = (10^(GoSOUND_SPL_70 / 20)) * setGoTone;

            case 'off'

                t=0:(1/value(SoundSampRate)):value(GoSoundDur);
                t=t(1:(end-1));

                GoSoundSPL.value=0;
                setGoTone = 10^((-74.5) / 20) * (sin(2 * pi * value(GoSoundFreq) * t));
                GoSOUND_SPL_70 = value(GoSoundSPL) - 70;
                Gosound = (10^(GoSOUND_SPL_70 / 20)) * setGoTone;

        end

        %%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %"set"_sound using SoundManagerSection

        SoundManagerSection(obj, 'set_sound', 'GoTone', Gosound);
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    otherwise
        error(['Don''t know how to handle action ' action]);
end;

return;