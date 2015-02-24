
function  [x, y]  =  NoGoSection(obj, action, x,  y)

GetSoloFunctionArgs;

% Deals with sound generation and uploading to RTLSoundMachine

switch action,
    case 'init'

        gcf;

        %SoundManagerSection(obj, 'init');

        %For Error Tone

        NumEditParam(obj, 'NoGo_light_amplitude', .5, x, y, 'label', 'amplitude'); next_row(y,1);
        
        NumEditParam(obj, 'NoGo_light_frequency', 20, x, y, 'label', 'frequency'); next_row(y,1);
        
        NumEditParam(obj, 'NoGo_light_pulse_duration', 0.01, x, y, 'label', 'pulse width'); next_row(y,1);

        NumEditParam(obj, 'NoGo_light_train_duration', 2, x, y, 'label', 'stim duration'); next_row(y,1);
        
        NumEditParam(obj, 'NoGo_light_train_delay', 0, x, y, 'label', 'delay'); next_row(y,1);
        
        NumEditParam(obj, 'NoGo_light_prob', 0, x, y, 'label', 'stim prob'); next_row(y,1);
        
        MenuParam(obj, 'NoGo_start_state', {'wait_4_odor','wait_4_lick','random'}, 'wait_4_odor', x, y, 'label','start astate'); next_row(y,1);
        
        SubHeaderParam(obj, 'NoGo_light', 'photostimulation', x, y); next_row(y,1);
        
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'NoGo_light_amplitude','NoGo_light_frequency','NoGo_light_pulse_duration',...
            'NoGo_light_train_duration','NoGo_light_train_delay','NoGo_start_state', 'NoGo_light_prob'});
        
        EditParam(obj, 'NoGoSoundSPL',     110,  x, y, 'label', 'NoGo Sound pressure', ...
            'labelfraction', 0.6);   next_row(y);
        EditParam(obj, 'NoGoSoundDur',    0.3,  x, y, 'label', 'NoGo Sound duration', ...
            'labelfraction', 0.6);   next_row(y);
        EditParam(obj, 'NoGoSoundFreq',    6000,  x, y, 'label', 'NoGo Sound frequency', ...
            'labelfraction', 0.6);   next_row(y);

        set_callback({NoGoSoundSPL, NoGoSoundDur, NoGoSoundFreq}, {'NoGoSection', 'set_tone'});

        sound_samp_rate = SoundManagerSection(obj, 'get_sample_rate');
        SoloParamHandle(obj, 'SoundSampRate', 'value', sound_samp_rate);

        SoloParamHandle(obj, 'IdNoGoTone', 'value', 0);
        SoundManagerSection(obj, 'declare_new_sound', 'NoGoTone');
        IdNoGoTone.value = SoundManagerSection(obj, 'get_sound_id', 'NoGoTone');

        PushbuttonParam(obj, 'Play_NoGoTone', x,y, 'label', 'Play NoGo Tone', 'position');next_row(y);
        set_callback(Play_NoGoTone,{'SoundManagerSection', 'play_sound', 'NoGoTone'});

        
        NoGoToneMenu = MenuParam(obj, 'NoGoSound', {'on', 'off',}, ...
            'on', x, y, 'label','NoGoSound'); next_row(y,1);
        
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'IdNoGoTone','NoGoSoundDur'});
                
        NumEditParam(obj, 'NoGoPuffDur', 0.2, x, y, 'label', 'air puff duration'); next_row(y,1);

        NoGoPuff = MenuParam(obj, 'NoGoAirPuff', {'on', 'off',}, ...
            'on', x, y, 'label','air puff'); next_row(y,1);
        
        NumEditParam(obj, 'NoGoMeanTime', 4, x, y, 'label', 'mean time NoGO'); next_row(y,1);

        NumEditParam(obj, 'NoGoSDTime', 1, x, y, 'label', 'SD time NoGo'); next_row(y,1);

        SubHeaderParam(obj, 'NoGotrials', 'NoGo', x, y); next_row(y,2);

        SoloFunctionAddVars('StateMatrixSection', 'rw_args', ...
            {'NoGoMeanTime','NoGoSDTime','NoGoPuff','NoGoPuffDur','NoGoToneMenu'});
        
        NoGoSection(obj, 'set_tone');
        
    case 'set_tone'


        %%%%%NoGo Tone-----------------------

        switch value(NoGoSound)
            case 'on'

                t=0:(1/value(SoundSampRate)):value(NoGoSoundDur);
                t=t(1:(end-1));

                setNoGoTone = 10^((-74.5) / 20) * (sin(2 * pi * value(NoGoSoundFreq) * t));
                NoGoSOUND_SPL_70 = value(NoGoSoundSPL) - 70;
                NoGosound = (10^(NoGoSOUND_SPL_70 / 20)) * setNoGoTone;

            case 'off'

                t=0:(1/value(SoundSampRate)):value(NoGoSoundDur);
                t=t(1:(end-1));

                NoGoSoundSPL.value=0;
                setNoGoTone = 10^((-74.5) / 20) * (sin(2 * pi * value(NoGoSoundFreq) * t));
                NoGoSOUND_SPL_70 = value(NoGoSoundSPL) - 70;
                NoGosound = (10^(NoGoSOUND_SPL_70 / 20)) * setNoGoTone;

        end

        %%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %"set"_sound using SoundManagerSection

        SoundManagerSection(obj, 'set_sound', 'NoGoTone', NoGosound);
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

    
    otherwise
        error(['Don''t know how to handle action ' action]);
end;

return;