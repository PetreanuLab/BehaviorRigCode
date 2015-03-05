function [f m]  = compare2Fields(dataParsed,fieldname1,fieldname2)
% function [f m] compare2Fields(dataParsed,field1,field2)
% 
% output: f
%           [fraction of Field1 true when Field2 true ...
%           fraction of Field1 true when Field2 false ]
%         e.g. [#Premature with stimulation 
%               #Premature with without stimulation] 
%               
%          m(1:4):    F1=true&F2=true 
%                     F1=true&F2=false
%                     F1=false&F2=true 
%                     F1=false&F2=false

sf = {};
sf(1) = {fieldname1};
sf(2) = {fieldname2};

dataParsed.(sf{2})(isnan(dataParsed.(sf{2})))=0;
dataParsed.(sf{1})(isnan(dataParsed.(sf{1})))=0;

m(1) = sum(dataParsed.(sf{1})~=0&dataParsed.(sf{2})~=0);
m(2) = sum(dataParsed.(sf{1})~=0&dataParsed.(sf{2})==0);
m(3) = sum(dataParsed.(sf{1})==0&dataParsed.(sf{2})~=0);
m(4) = sum(dataParsed.(sf{1})==0&dataParsed.(sf{2})==0);

f(1) = m(1)/(m(1)+m(3)); % fraction in stimulated (if field2 is stimulationon)

f(2) = m(2)/(m(2)+m(4));  % fraction in nonstimualted