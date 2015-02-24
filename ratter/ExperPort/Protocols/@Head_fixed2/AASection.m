
function  [x, y]  =  AASection(obj, action, x,  y)

GetSoloFunctionArgs;

% Deals with sound generation and uploading to RTLSoundMachine

switch action,
    case 'init'

        gcf;

        %SoundManagerSection(obj, 'init');

        %For Error Tone

        NumEditParam(obj, 'AA_light_amplitude', .5, x, y, 'label', 'amplitude'); next_row(y,1);
        
        NumEditParam(obj, 'AA_light_frequency', 20, x, y, 'label', 'frequency'); next_row(y,1);
        
        NumEditParam(obj, 'AA_light_pulse_duration', 0.01, x, y, 'label', 'pulse width'); next_row(y,1);

        NumEditParam(obj, 'AA_light_train_duration', 2, x, y, 'label', 'stim duration'); next_row(y,1);
        
        NumEditParam(obj, 'AA_light_train_delay', 0, x, y, 'label', 'delay'); next_row(y,1);
        
        NumEditParam(obj, 'AA_light_prob', 0, x, y, 'label', 'stim prob'); next_row(y,1);
        
        MenuParam(obj, 'AA_start_state', {'wait_4_odor', 'odor_valve_on','wait_4_lick'}, 'wait_4_odor', x, y, 'label','start astate'); next_row(y,1);
        
        SubHeaderParam(obj, 'AA_light', 'photostimulation', x, y); next_row(y,1);
        
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'AA_light_amplitude','AA_light_frequency','AA_light_pulse_duration',...
            'AA_light_train_duration','AA_light_train_delay','AA_start_state', 'AA_light_prob'});
        
        EditParam(obj, 'AASoundSPL',     100,  x, y, 'label', 'AA Sound pressure', ...
            'labelfraction', 0.6);   next_row(y);
        EditParam(obj, 'AASoundDur',    0.3,  x, y, 'label', 'AA Sound duration', ...
            'labelfraction', 0.6);   next_row(y);
        EditParam(obj, 'AASoundFreq',    6000,  x, y, 'label', 'AA Sound frequency', ...
            'labelfraction', 0.6);   next_row(y);

        set_callback({AASoundSPL, AASoundDur, AASoundFreq}, {'AASection', 'set_tone'});

        sound_samp_rate = SoundManagerSection(obj, 'get_sample_rate');
        
        SoloParamHandle(obj, 'SoundSampRate', 'value', sound_samp_rate);

        SoloParamHandle(obj, 'IdAATone', 'value', 0);
        
        SoundManagerSection(obj, 'declare_new_sound', 'AATone');
        
        IdAATone.value = SoundManagerSection(obj, 'get_sound_id', 'AATone');
                
        PushbuttonParam(obj, 'Play_AATone', x,y, 'label', 'Play AA Tone', 'position');next_row(y);
        set_callback(Play_AATone,{'SoundManagerSection', 'play_sound', 'AATone'});

        AAToneMenu = MenuParam(obj, 'AASound', {'on', 'off',}, ...
            'on', x, y, 'label','AASound'); next_row(y,1);

        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'IdAATone','AASoundDur'});
                
        AASection(obj, 'set_tone');
        
        
        NumEditParam(obj, 'AAPuffDur', 0.1, x, y, 'label', 'air puff duration'); next_row(y,1);

        AAPuff = MenuParam(obj, 'AAAirPuff', {'on', 'off',}, ...
            'on', x, y, 'label','air puff'); next_row(y,1);

        NumEditParam(obj, 'AAMeanTime', 4, x, y, 'label', 'mean time'); next_row(y,1);

        NumEditParam(obj, 'AASDTime', 1, x, y, 'label', 'SD time'); next_row(y,1);

        SubHeaderParam(obj, 'AAtrials', 'AA', x, y); next_row(y,1);

        SoloFunctionAddVars('StateMatrixSection', 'rw_args', ...
            {'AAMeanTime','AASDTime','AAPuff','AAPuffDur','AAToneMenu'});

        
    case 'set_tone'


        %%%%%AA Tone-----------------------

        switch value(AASound)
            case 'on'

                t=0:(1/value(SoundSampRate)):value(AASoundDur);
                t=t(1:(end-1));

                setAATone = 10^((-74.5) / 20) * (sin(2 * pi * value(AASoundFreq) * t));
                AASOUND_SPL_70 = value(AASoundSPL) - 70;
                AAsound = (10^(AASOUND_SPL_70 / 20)) * setAATone;

            case 'off'

                t=0:(1/value(SoundSampRate)):value(AASoundDur);
                t=t(1:(end-1));

                AASoundSPL.value=0;
                setAATone = 10^((-74.5) / 20) * (sin(2 * pi * value(AASoundFreq) * t));
                AASOUND_SPL_70 = value(AASoundSPL) - 70;
                AAsound = (10^(AASOUND_SPL_70 / 20)) * setAATone;

        end

        %%%%%%%%%%


        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %"set"_sound using SoundManagerSection

        SoundManagerSection(obj, 'set_sound', 'AATone', AAsound);
        SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');
    otherwise
        error(['Don''t know how to handle action ' action]);
end;

return;