
function  [x, y]  =  SoundsSection(obj, action, x,  y)

GetSoloFunctionArgs;

% Deals with sound generation and uploading to RTLSoundMachine

switch action,
    case 'init'
        
%         SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
%         name = 'Sounds'; 
%         set(value(myfig), 'Name', name, 'Tag', name, ...
%               'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
%         set(value(myfig), 'Position', [850   700   208   320], 'Visible', 'on');
%         x = 5; y = 5;
        gcf;
        
%         next_row(y,-1);
        SoundManagerSection(obj, 'init');
        
        
        % Go Signal ----------------------------------------------------- %
        MenuParam(obj, 'GoSignal', {'On', 'Off',}, ...
        'On', x, y, 'label','Go signal', 'labelfraction', 0.6); next_row(y,1);

        EditParam(obj, 'SoundSPL', 70,  x, y, 'label', 'Sound pressure level', ...
            'labelfraction', 0.6);   next_row(y);
        EditParam(obj, 'SoundDur', 0.1,  x, y, 'label', 'Sound duration', ...
            'labelfraction', 0.6); next_row(y);
        EditParam(obj, 'SoundFreq', 2000,  x, y, 'label', 'Sound frequency (Hz)', ...
            'labelfraction', 0.6); next_row(y);
        set_callback({GoSignal, SoundSPL, SoundDur, SoundFreq}, {'SoundsSection', 'set_tone'});
        
        SoloParamHandle(obj, 'IdSound', 'value', 0);
        SoundManagerSection(obj, 'declare_new_sound', 'Tone');
        IdSound.value = SoundManagerSection(obj, 'get_sound_id', 'Tone');
        PushbuttonParam(obj, 'PlayTone', x,y, 'label', 'Play Go Tone', ...
            'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1.5);
        set_callback(PlayTone,{'SoundManagerSection', 'play_sound', 'Tone'});
        
        
        % Punish Burst -------------------------------------------------- %
        MenuParam(obj, 'PunishBurst', {'On', 'Off',}, ...
        'Off', x, y, 'label','Punish Burst', 'labelfraction', 0.6); next_row(y,1);
    
        EditParam(obj, 'NoiseLoudness', 0.01,  x, y, 'label', 'Noise Loudness', ...
            'labelfraction', 0.6);   next_row(y);
        EditParam(obj, 'NoiseDur', 0.1,  x, y, 'label', 'Noise duration', ...
            'labelfraction', 0.6); next_row(y);
        set_callback({PunishBurst, NoiseLoudness, NoiseDur}, {'SoundsSection', 'set_noise'});
        
        SoloParamHandle(obj, 'IdNoiseBurst', 'value', 0);
        SoundManagerSection(obj, 'declare_new_sound', 'NoiseBurst');
        IdNoiseBurst.value = SoundManagerSection(obj, 'get_sound_id', 'NoiseBurst');
        PushbuttonParam(obj, 'PlayNoiseBurst', x,y, 'label', 'Play Noise Burst', ...
            'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1.5);
        set_callback(PlayNoiseBurst,{'SoundManagerSection', 'play_sound', 'NoiseBurst'});
        
        
        % Water Signal-------------------------------------------------- %
        MenuParam(obj, 'WaterSignal', {'On', 'Off',}, ...
        'On', x, y, 'label','Water signal', 'labelfraction', 0.6); next_row(y,1);

        EditParam(obj, 'SoundSPLWater', 70,  x, y, 'label', 'Sound pressure level', ...
            'labelfraction', 0.6);   next_row(y);
        EditParam(obj, 'SoundDurWater', 0.1,  x, y, 'label', 'Sound duration', ...
            'labelfraction', 0.6); next_row(y);
        EditParam(obj, 'SoundFreqWater', 2000,  x, y, 'label', 'Sound frequency (Hz)', ...
            'labelfraction', 0.6); next_row(y);
        set_callback({WaterSignal, SoundSPLWater, SoundDurWater, SoundFreqWater}, ...
            {'SoundsSection', 'set_WaterTone'});
        
        SoloParamHandle(obj, 'IdWaterTone', 'value', 0);
        SoundManagerSection(obj, 'declare_new_sound', 'WaterTone');
        IdWaterTone.value = SoundManagerSection(obj, 'get_sound_id', 'WaterTone');
        PushbuttonParam(obj, 'PlayWaterTone', x,y, 'label', 'Play Water Tone', ...
            'BackgroundColor', [0.75 0.75 0.80]); next_row(y,1);
        set_callback(PlayWaterTone,{'SoundManagerSection', 'play_sound', 'WaterTone'});
        
        
        
        SubHeaderParam(obj, 'SubHeaderSoundSection','Sound Section',x,y); next_row(y);
        
 %       sound_samp_rate = SoundManagerSection(obj, 'get_sample_rate');
        SoloParamHandle(obj, 'SoundSampRate', 'value', 0);
        
        SoloFunctionAddVars('StateMatrixSection', 'rw_args', {'IdSound', 'SoundDur', 'IdNoiseBurst', 'NoiseDur', ...
            'IdWaterTone', 'SoundDurWater'});
        
        SoundsSection(obj, 'set_tone', 'set_WaterTone', 'set_Noise');
        SoundsSection(obj, 'next_trial');
        
    case 'set_tone'
        
        switch value(GoSignal)
            case 'On'
                SoundDur.value = value(SoundDur);
                SoundFreq.value = value(SoundFreq);
            
            case 'Off'
                SoundDur.value = 0;
                SoundFreq.value = 0;
        end

        
       %make sound %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
       % RISE_FALL=5; %5ms
       t = 0 : (1/value(SoundSampRate)) : value(SoundDur);
       t = t(1:(end-1));

       %At first, make sound for 70dB, later adjust the amplitude according
       %to SoundSPL
       sound_machine_server = Settings('get', 'RIGS', 'sound_machine_server');
       card_slot = Settings('get', 'RIGS', 'card_slot');

       setTone = 10^((-74.5) / 20) * (sin(2 * pi * value(SoundFreq) * t));

       %set the amplitude
       SOUND_SPL_70 = value(SoundSPL) - 70;
       sound = (10^(SOUND_SPL_70 / 20)) * setTone;
       
       %"set"_sound using SoundManagerSection
       SoundManagerSection(obj, 'set_sound', 'Tone', sound);

        
    %%%%%BURST 
    
    case 'set_noise'
        switch value(PunishBurst)
            case 'On'
                NOISE_B_LEN = 0.06;
                NoiseLoudness.value = value(NoiseLoudness);
                NoiseDur.value = value(NoiseDur);
            case 'Off'
                NOISE_B_LEN = 0;
                NoiseLoudness.value = 0;
                NoiseDur.value = 0;
        end
        
        noise_burst = value(NoiseLoudness)*rand(2,NOISE_B_LEN*value(SoundSampRate));
        SoundManagerSection(obj, 'set_sound', 'NoiseBurst', noise_burst);
        
        
        case 'set_WaterTone'
        % Water Signal -------------------------------------------------- %
        switch value(WaterSignal)
            case 'On'
                SoundDurWater.value = value(SoundDurWater);
                SoundFreqWater.value = value(SoundFreqWater);
            
            case 'Off'
                SoundDurWater.value = 0;
                SoundFreqWater.value = 0;
        end

        
        %make sound %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % RISE_FALL=5; %5ms
        tWater = 0 : (1/value(SoundSampRate)) : value(SoundDurWater);
        tWater = tWater(1:(end-1));

%        %At first, make sound for 70dB, later adjust the amplitude according
%        %to SoundSPL
%        sound_machine_server = Settings('get', 'RIGS', 'sound_machine_server');
%        card_slot = Settings('get', 'RIGS', 'card_slot');

       setToneWater = 10^((-74.5) / 20) * (sin(2 * pi * value(SoundFreqWater) * tWater));

       %set the amplitude
       SOUND_SPL_70_Water = value(SoundSPLWater) - 70;
       soundWater = (10^(SOUND_SPL_70_Water / 20)) * setToneWater;
       
       %"set"_sound using SoundManagerSection
       SoundManagerSection(obj, 'set_sound', 'WaterTone', soundWater);


    case 'next_trial'
        
        switch value(GoSignal)
            case 'On'
                SoundDur.value = value(SoundDur);
                SoundFreq.value = value(SoundFreq);
            
            case 'Off'
                SoundDur.value = 0;
                SoundFreq.value = 0;
        end

        
        %make sound %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % RISE_FALL=5; %5ms
        t = 0 : (1/value(SoundSampRate)) : value(SoundDur);
        t = t(1:(end-1));

       %At first, make sound for 70dB, later adjust the amplitude according
       %to SoundSPL
       sound_machine_server = Settings('get', 'RIGS', 'sound_machine_server');
       card_slot = Settings('get', 'RIGS', 'card_slot');

       setTone = 10^((-74.5) / 20) * (sin(2 * pi * value(SoundFreq) * t));

       %set the amplitude
       SOUND_SPL_70 = value(SoundSPL) - 70;
       sound = (10^(SOUND_SPL_70 / 20)) * setTone;
       
       %"set"_sound using SoundManagerSection
       SoundManagerSection(obj, 'set_sound', 'Tone', sound);
        
       
       % Burst ---------------------------------------------------------- %
        switch value(PunishBurst)
            case 'On'
                NOISE_B_LEN = 0.06;
                NoiseLoudness.value = value(NoiseLoudness);
                NoiseDur.value = value(NoiseDur);
            case 'Off'
                NOISE_B_LEN = 0;
                NoiseLoudness.value = 0;
                NoiseDur.value = 0;
        end
        
        noise_burst = value(NoiseLoudness)*rand(2,NOISE_B_LEN*value(SoundSampRate));
        SoundManagerSection(obj, 'set_sound', 'NoiseBurst', noise_burst);


        
        % Water Signal ---------------------------------------------------%
        
        switch value(WaterSignal)
            case 'On'
                SoundDurWater.value = value(SoundDurWater);
                SoundFreqWater.value = value(SoundFreqWater);
            
            case 'Off'
                SoundDurWater.value = 0;
                SoundFreqWater.value = 0;
        end

        
        %make sound %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % RISE_FALL=5; %5ms
        tWater = 0 : (1/value(SoundSampRate)) : value(SoundDurWater);
        tWater = tWater(1:(end-1));

%        %At first, make sound for 70dB, later adjust the amplitude according
%        %to SoundSPL
%        sound_machine_server = Settings('get', 'RIGS', 'sound_machine_server');
%        card_slot = Settings('get', 'RIGS', 'card_slot');

       setToneWater = 10^((-74.5) / 20) * (sin(2 * pi * value(SoundFreqWater) * tWater));

       %set the amplitude
       SOUND_SPL_70_Water = value(SoundSPLWater) - 70;
       soundWater = (10^(SOUND_SPL_70_Water / 20)) * setToneWater;
       
       %"set"_sound using SoundManagerSection
       SoundManagerSection(obj, 'set_sound', 'WaterTone', soundWater);
       
       SoundManagerSection(obj, 'send_not_yet_uploaded_sounds');

     case 'close'
      
%       SoundsSection(obj, 'close');
    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    
    if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
      delete(value(myfig));
    end;    
    delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', ['^' mfilename '_']);

        
    otherwise
        error(['Don''t know how to handle action ' action]);
end;

return;