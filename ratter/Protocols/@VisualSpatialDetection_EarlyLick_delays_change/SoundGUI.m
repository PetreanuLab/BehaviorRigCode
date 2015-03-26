

function [x, y] = SoundGUI(obj, action)

GetSoloFunctionArgs;


switch action
    
    %   ------------------------------------------------------------------
    %                INIT
    %   ------------------------------------------------------------------
    case 'init'
        
        % Create figure for setting the timing structure of the task,
        % and set it to be invisible until button is pressed
        SoloParamHandle(obj, 'sound_fig', 'saveable', 0); sound_fig.value = figure;
                name = 'Sound Settings';
        set(value(sound_fig), 'Name', name, 'Tag', name, ...
            'Position', [700   100 215   160], 'Visible', 'off',...
        'MenuBar', 'none',    'NumberTitle', 'off',...    
        'closerequestfcn', ['SoundGUI(' class(obj) ',''hide'')']);
        
        x=10; y=10;
        
        % ----------------------  sound Parameters -----------------------
        NumeditParam(obj, 'changeSoundVolume', [10 8 6 4 2], x, y, 'TooltipString', ' sound volume at change');next_row(y);
        NumeditParam(obj, 'changeSoundVolumeProb', [1 0 0 0 0], x, y, 'TooltipString', ' volume probabilities');next_row(y);
        MenuParam(obj, 'cue1Frequency', {'2','4','7','8','10','12'},12, x, y, 'TooltipString', 'Sound frequency paired with right direction in kHz.');next_row(y);
        MenuParam(obj, 'cue2Frequency', {'2','4','7','8','10','12'},7, x, y, 'TooltipString', 'Sound frequency paired with left direction in kHz.');next_row(y);
        SliderParam(obj, 'errorSoundVolume', 3, 0,10, x, y, 'TooltipString', 'Error sound volume');next_row(y)
        SliderParam(obj, 'soundVolume', 5, 0, 10, x, y, 'TooltipString', 'Sound volume');next_row(y);
        ToggleParam(obj, 'soundTrial', 1, x, y); next_row(y);
        %SubheaderParam(obj, 'soundHeader', 'Sound Parameters', x, y); next_row(y,1.5);
        
        DeclareGlobals(obj, 'rw_args', {'cue1Frequency', 'cue2Frequency',...
            'changeSoundVolume','changeSoundVolumeProb','errorSoundVolume'...
            'soundTrial','soundVolume'});
        
        
    %% CASE show
    case 'show'
            set(value(sound_fig), 'Visible', 'on');
        
  	%% CASE hide
    case 'hide'
            set(value(sound_fig), 'Visible', 'off');
            soundToggle.value = false;
            
    case 'close'
        if exist('sound_fig', 'var') && isa(sound_fig, 'SoloParamHandle') && ishandle(value(sound_fig)),
            delete(value(sound_fig));
        end;  
        
end