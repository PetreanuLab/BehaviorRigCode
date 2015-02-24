
function BartCallback()

global CBSTRUCT
persistent hFig 

if isempty(hFig)
    hFig = figure;
end

hTask = CBSTRUCT.hTask;


[n,d] = hTask.readAnalogData(inf,CBSTRUCT.everyN,'scaled',3);
figure(hFig);
plot(d);
drawnow expose;
