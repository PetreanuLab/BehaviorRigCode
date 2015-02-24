function JohannesCallback()
%JOHANNESCALLBACK Summary of this function goes here
%   Detailed explanation goes here

global CBSTRUCT

CBSTRUCT.callbackCounter = CBSTRUCT.callbackCounter + 1;
updatePeriodSamples = CBSTRUCT.updatePeriodSamples;


hTask = CBSTRUCT.hTask;
hAOTask = CBSTRUCT.hAOTask;

[~,inData] = readAnalogData(hTask,updatePeriodSamples,'scaled');

%Compute difference between input chans
meanDifference = mean(inData(:,2)-inData(:,1));

%Output difference value on D/A channel
hAOTask.writeAnalogData(meanDifference);
%toc,tic;
    
if ~mod(CBSTRUCT.callbackCounter ,10)
    fprintf(1,'Mean Difference: %g\n',mean(inData(:,2)-inData(:,1)));
end

%Hard-code ending of Task here...in reality would do this from command-line or application
if ~mod(CBSTRUCT.callbackCounter ,1000)
    hTask.stop();
end


end

