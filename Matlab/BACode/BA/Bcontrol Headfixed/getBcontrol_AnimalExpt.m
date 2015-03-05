function [directory files] = getBcontrol_AnimalExpt(AnimalStr)
% function [directory files] = getAnimalExpt(AnimalStr)
%       directory -  the fullpath of the first directory in  rd.Dir.DataBehav that contains AnimalStr
%       files -  all text files in the directory
% BA
rd = visRigDefs();
datadir = rd.DIR.ratterData;
expter = rd.ratterDefault.USER ;
animalDirs = dir(fullfile(datadir,expter));
directory = [];
files = [];
for ifile = 1:length(animalDirs)
    
    if(animalDirs(ifile).isdir)
       ind =  strfind(lower(animalDirs(ifile).name),lower(AnimalStr));
       if ~isempty(ind)
          directory = fullfile(datadir,expter, animalDirs(ifile).name);
          files = dirc(fullfile(directory,'data*.mat'),'f','d');
           files = files(end:-1:1,:);
           return
       end
          
    end
end

if isempty(directory)
    disp([AnimalStr ' animal directory not found'])
end

if isempty(files)
    disp([AnimalStr ' animal behavior files not found'])
end