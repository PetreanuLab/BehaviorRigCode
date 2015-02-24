%function JohannesDemo()

import Devices.NI.DAQmx.*

%clear classes
if exist('hTask','var') && isvalid(hTask)
    delete(hTask);
end

if exist('hAOTask','var') && isvalid(hAOTask)
    delete(hAOTask);
end

global CBSTRUCT

sampleRate = 10e3; %Hz
updatePeriod = 2e-3; %s
updatePeriodSamples = round(updatePeriod * sampleRate);

hTask = Task('Johannes Task');
hAOTask = Task('Smart Task');

hTask.createAIVoltageChan('Dev4',0:1);
hAOTask.createAOVoltageChan('Dev4',0);

%hTask.createAOVoltageChan('Dev4',0);

hTask.cfgSampClkTiming(sampleRate,'DAQmx_Val_ContSamps');

hTask.registerEveryNSamplesEvent(@(src,evnt)JohannesCallback,updatePeriodSamples);
hTask.registerDoneEvent(@(src,evnt)JohannesDoneCallback);

CBSTRUCT.hTask = hTask;
CBSTRUCT.callbackCounter = 0;
CBSTRUCT.updatePeriodSamples = updatePeriodSamples;
CBSTRUCT.hAOTask = hAOTask;

tic;
hAOTask.start();
hTask.start();


%end


