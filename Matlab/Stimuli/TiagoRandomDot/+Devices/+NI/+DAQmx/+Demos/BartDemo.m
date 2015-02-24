function BartDemo()
%doc Devices.NI.DAQmx.Task
global CBSTRUCT

sampRate = 1000;
everyN = 2000;

import Devices.NI.DAQmx.*

hTask = Task('Bart Task');
hTask.createAIVoltageChan('Dev5',0:2);

hTask.cfgSampClkTiming(sampRate,'DAQmx_Val_ContSamps');

hTask.registerEveryNSamplesEvent('BartCallback',everyN);
CBSTRUCT.hTask = hTask;
CBSTRUCT.everyN = everyN;

hTimer = timer('StartDelay',10,'TimerFcn',@timerFcn);

hTask.start();
start(hTimer);

    function timerFcn(src,evnt)
        hTask.stop();
        delete(hTask); 
        disp('All done!');
    end
end


%delete(hTask);