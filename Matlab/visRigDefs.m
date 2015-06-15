function r = visRigDefs(sconfig)
df = 'default_rigdef_config';
if nargin < 1
    if exist(df,'file')
        sconfig = default_rigdef_config;
    else
        sconfig='default';
    end
end

switch(sconfig)
    case 'basslaptop'
        r.DIR.psychtoolbox = '/Applications/Psychtoolbox';
        r.DIR.visualStimuli = '/Volumes/BassamHome/GoogleDriveChampalimaud/PetreanuLab/Code/Matlab/Stimuli';
        r.DIR.ratter = '/Volumes/BassamHome/GoogleDriveChampalimaud/PetreanuLab/Code/ratter';
        r.DIR.ratterExperPort = fullfile(r.DIR.ratter,'ExperPort'); % NOTE MUST BE MANUALLY SET THE SAME as Settings_Custom.conf in ratter directory
        r.DIR.ratterData = '/Volumes/BassamHome/GoogleDriveChampalimaud/PetreanuLab/Data/ratter'; % Should be outside of ratter NOTE MUST BE MANUALLY SET THE SAME as Settings_Custom.conf in ratter directory
        r.DIR.ratterProtocols = fullfile(r.DIR.ratter,'Protocols'); % NOTE MUST BE MANUALLY SET THE SAME as Settings_Custom.conf
        r.visualScreen.ID = 1; % this is the ID that windows identifies the screen used for stimulus presentation (Right click on desktop, click screen resolution, click identify)
        r.DIR.BStruct = '/Volumes/BassamHome/GoogleDriveChampalimaud/PetreanuLab/Data/ratter/Bstruct';
        r.DIR.DailyFig = '/Volumes/BassamHome/GoogleDriveChampalimaud/PetreanuLab/Data/ratter/DailyFig';
    otherwise % default
        r.ratterDefault.USER = 'BVA';
        r.DIR.psychtoolbox = 'C:\psychophysicsToolBox\Psychtoolbox';
        r.DIR.visualStimuli = 'C:\Users\User\Google Drive\PetreanuLab\Code\Matlab\Stimuli';
        r.DIR.ratter = 'C:\Users\User\Google Drive\PetreanuLab\Code\ratter';
        r.DIR.ratterExperPort = fullfile(r.DIR.ratter,'ExperPort'); % NOTE MUST BE MANUALLY SET THE SAME as Settings_Custom.conf in ratter directory
        r.DIR.ratterData = 'C:\Users\User\Google Drive\PetreanuLab\Data\ratter\Data'; % Should be outside of ratter NOTE MUST BE MANUALLY SET THE SAME as Settings_Custom.conf in ratter directory
        r.DIR.ratterProtocols = fullfile(r.DIR.ratter,'Protocols'); % NOTE MUST BE MANUALLY SET THE SAME as Settings_Custom.conf
        r.DIR.BStruct = 'C:\Users\User\Google Drive\PetreanuLab\Data\ratter\Bstruct';
        r.DIR.DailyFig = 'C:\Users\User\Google Drive\PetreanuLab\Data\ratter\DailyFig';
        r.visualScreen.ID = 2; % this is the ID that windows identifies the screen used for stimulus presentation (Right click on desktop, click screen resolution, click identify)
        
end