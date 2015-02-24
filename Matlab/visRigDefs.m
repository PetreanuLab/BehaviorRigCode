function r = visRigDefs
r.DIR.psychtoolbox = 'C:\psychophysicsToolBox\Psychtoolbox';
r.DIR.visualStimuli = 'C:\Users\User\Google Drive\Matlab\Stimuli';
r.DIR.ratter = 'C:\Users\User\Google Drive\Code\ratter';
r.DIR.ratterExperPort = fullfile(r.DIR.ratter,'ExperPort'); % NOTE MUST BE MANUALLY SET THE SAME as Settings_Custom.conf in ratter directory
r.DIR.ratterData = 'C:\Users\User\Google Drive\Data\ratter\'; % Should be outside of ratter NOTE MUST BE MANUALLY SET THE SAME as Settings_Custom.conf in ratter directory
r.DIR.ratterProtocols = fullfile(r.DIR.ratter,'Protocols');
r.visualScreen.ID = 2; % this is the ID that windows identifies the screen used for stimulus presentation (Right click on desktop, click screen resolution, click identify)