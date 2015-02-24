% set_path_bcontrol script
% Adds c:/ratter/ExperPort, c:/ratter/Protocols and all subfolders to the Matlab path
r = visRigDefs;
addpath(genpath(r.DIR.ratterExperPort));
addpath(genpath(r.DIR.ratterProtocols));
cd(r.DIR.ratterExperPort)
go