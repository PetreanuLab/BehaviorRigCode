classdef Task < Devices.NI.DAQmx.private.DAQmxClass
    %TASK An object encapsulating an NI DAQmx 'task'
    %A 'task' is a collection of one or more channels of the same type (e.g. 'AnalogInput', 'DigitalOutput', etc) plus associated timing properties
    
    %% PROPERTIES
    properties
        taskName; %Unique name (string) for this instance
        
        everyNSamples=[]; %Number of samples to input/output prior to generating EveryNSamples event, to which callbacks can respond
        everyNSamplesEventCallbacks={}; %Cell array of callback function handles to invoke (in order) upon everyNSamples events. Like typical Matlab arguments, the callback must take/expect 2 arguments -- source and event. The source contains the Task object handle. Event is an empty array (unused).
        %everyNSamplesEventCallbackDataStructs={}; %Cell array of structures to pass to callbacks for everyNSamples event
        
        doneEventCallbacks={}; %Cell array of callback names to invoke (in order) upon Done event
        %doneEventCallbackDataStructs={}; %Cell array of structures to pass to callbacks for Done event
        
        signalID=''; %One of {'DAQmx_Val_SampleClock', 'DAQmx_Val_SampleCompleteEvent', 'DAQmx_Val_ChangeDetectionEvent', 'DAQmx_Val_CounterOutputEvent'}, indicating which type of signal event is registered for specified signalEventCallbacks.
        signalEventCallbacks={}; %Cell array of callback names to invoke (in order) upon Signal events
        %signalEventCallbackDataStructs={}; %Cell array of structures to pass to callbacks for Signal events

        verbose=false; %Logical value indicating, if true, to display additional status/warning information to command line
    end
    
    properties (Hidden)
        %These are hidden, rather than private, to allow for access by MEX functions. Should be considered private.
        
        %These properties are stored as part of Task, to allow for ready access by MEX function during read/write operations.
        rawDataArrayAI=[]; %Scalar array of the class which the device(s) associated with this Task use for their Analog Input raw data. There can be only one. Empty array indicates freshly constructed.
        rawDataArrayAO=[]; %Scalar array of the class which the device(s) associated with this Task use for their Analog Output raw data. There can be only one. Empty array indicates freshly constructed.
        
        %Properties for DAQmx events and their corresponding MATLAB callbacks
        everyNSamplesEventReadDataIndex=0; %Index indicating on which callback to automatically read data prior to callback execution. Value of 0 indicates not to read data.
        everyNSamplesEventReadDataOptions=struct.empty(); %Structure of options pertaining to read data operation
        
    end
    
    %DAQmx-defined properties explicitly added to task, because they are commonly used. Remaining properties are added dynamically, based on demand.
    properties (GetObservable, SetObservable)
        sampQuantSampMode;
        sampQuantSampPerChan;
        sampTimingType;
        
        sampClkRate;
        sampClkSrc;
        
        startTrigType;
        refTrigType;
        pauseTrigType;
    end
    
    properties (SetAccess=private)
        taskID;  %A unique integer identifying this Task object (maintains a count of Tasks)
    end
    
    properties (SetAccess=private, Dependent)
        taskType=''; %Member of {'AnalogInput', 'AnalogOutput', 'DigitalInput', 'DigitalOutput', 'CounterInput', 'CounterOutput'}
        deviceNames; %Cell array of device names (though in most cases, there's only one device per task)
        channels; %Array of Channel objects associated with this Task  %TMW: This indirection is used to allow a property to be publically gettable, but only settable by 'friends' or package-mates. Would prefer some native 'package scope' concept.
        %startTriggerSource; %TODO: Get startTriggerSource by determining type, if any, of start trigger
        %refTriggerSource; %TODO: Get refTriggerSource by determining type, if any, of reference trigger
    end
    
    %Properties used to handle specifics of getting/setting properties for each DAQmx class
    properties (SetAccess=private, Hidden)
        gsPropRegExp =  '.*DAQmxGet(?!(AI|AO|CO|CI|DO|DI|Scale|Sys|Persisted|Cal|Dev|Physical|Switch))(.*)\(ulong,\s*(\S*)[\),].*';
        gsPropPrefix = '';
        gsPropIDArgNames = {'taskID'};
        gsPropNumStringIDArgs=0;       
    end
    
    properties (SetAccess=private, Hidden)
        everyNSamplesEventRegisteredFlag=false;
        doneEventRegisteredFlag=false
        signalEventRegisteredFlag=false;
        
        signalIDHidden; %Used by RegisterSignalEvent MEX function        
        taskObjID; %Used by maintainObjectIDs
    end
    
    properties (SetAccess=private, Dependent, Hidden)
        devices; %Array of device objects (though in most cases, there's only one device per task). Property is hidden as 'deviceNames' is recommended way to access Device objects.
    end
    
    %Hidden properties, to allow access by class package-mates TMW: Might prefer some native 'package scope' concept
    properties (Hidden)
        deviceNamesHidden;
        channelsHidden;
        taskTypeHidden;
    end
    
    %Private properties
    properties (GetAccess=private, Constant)
       memoryErrorCode = -50352; %Error: 'NI Platform Services:  The requested memory could not be allocated.'       
    end
    
    
    
    %% PUBLIC METHODS
    
    methods
        
        %% TASK CONSTRUCTION/DESTRUCTION
        %Constructor method
        function obj = Task(taskName)
            %The constructor method
            %taskName: (OPTIONAL) A unique string identifying Task
            
            obj.taskObjID = maintainObjectIDs('add');
            
            if nargin == 0
                obj.taskName = ['Task ' num2str(obj.taskObjID)];
            else
                obj.taskName = taskName;
            end
            
            %Create the task
            [taskName, obj.taskID] = obj.driverCall('DAQmxCreateTask',obj.taskName, 0);
            
            %Add self to System's list
            obj.system.tasks = [obj.system.tasks obj];
            
        end
        
        %Destructor
        function delete(obj)
            
            %Clear Task if needed
            if ~isempty(obj.taskID)
                obj.driverCall('DAQmxClearTask',obj.taskID);
            end
            
            %Delete associated objects
            delete(obj.channels);
            
            %Add self to System's list
            obj.system.tasks(obj==obj.system.tasks) = [];
            
            %Unload System if no other Tasks remain
            %             numIDs = maintainObjectIDs('remove',obj.taskObjID);
            %             if ~numIDs
            %                 %unload(obj.system); %%%TMW: Wish we could access static methods by object instances
            %                 %Devices.NI.DAQmx.System.unload();
            %                 obj.system.unload();
            %             end
            
            
        end
        
        %% TASK CONTROL
        function start(obj)
            %Transitions the task from the committed state to the running state, which begins measurement or generation.
            %VECTORIZED
            
            for i=1:length(obj)   
                obj(i).driverCall('DAQmxStartTask', obj(i).taskID);
            end
        end
        
        function stop(obj)
            %Stops the task and returns it to the state it was in before you called DAQmxStartTask or called an NI-DAQmx Write function with autoStart set to TRUE.
            %VECTORIZED
            
            for i=1:length(obj)
                obj(i).driverCall('DAQmxStopTask', obj(i).taskID);
            end
        end
        
        function abort(obj)
            %Identical to stop(), but should be used to abort ongoing Finite acquisitions/generations.
            %Unlike stop(), DAQmx Error -200010 is suppressed. This error occurs when stop() is called to terminate a Finite acquisition/generation prior to the specified number of samples
            %VECTORIZED
           for i=1:length(obj)          
               obj(i).driverCallFiltered('DAQmxStopTask',200010, obj(i).taskID);                                           
           end
        end
        
        function tf = isTaskDone(obj)
            %Queries the status of the task and indicates if it completed execution. Use this function to ensure that the specified operation is complete before you stop the task.
            
            tf = obj.driverCall('DAQmxIsTaskDone',obj.taskID,0);
        end
        
        function waitUntilTaskDone(obj,timeToWait)
            %Waits for the measurement or generation to complete. Use this function to ensure that the specified operation is complete before you stop the task.
            %VECTORIZED
            %
            %function waitUntilTaskDone(obj,timeToWait)
            %   timeToWait: The maximum amount of time, in seconds, to wait for the measurement or generation to complete. The function returns an error if the time elapses before the measurement or generation is complete.
            %               A value of -1 or Inf means to wait indefinitely.
            %               If you set timeToWait to 0, the function checks once and returns an error if the measurement or generation is not done.
            %
            
            if nargin < 2 || isempty(timeToWait) || isinf(timeToWait)
                timeToWait = -1;
            end
            
            for i=1:length(obj)
                obj(i).driverCall('DAQmxWaitUntilTaskDone',obj(i).taskID, timeToWait);
            end
        end
        
        function clear(obj) %TODO: Consider renaming this to 'remove', or similar, to avoid confusion with MATLAB builtin 'clear'
            %Clears the task. Before clearing, this function stops the task, if necessary, and releases any resources reserved by the task. You cannot use a task once you clear the task without recreating or reloading the task.
            %If you use the DAQmxCreateTask function or any of the NI-DAQmx Create Channel functions within a loop, use this function within the loop after you finish with the task to avoid allocating unnecessary memory
            %VECTORIZED
            
            for i=1:length(obj)
                obj(i).driverCall('DAQmxClearTask',obj(i).taskID);
                delete(obj(i)); %TODO: Is this the right thing to do? Any reason to not delete the task?
            end
        end
        
        function control(obj,state)
            %Alters the state of a task according to the action you specify. To minimize the time required to start a task, for example, DAQmxTaskControl can commit the task prior to starting.
            %function control(obj,state)
            %   state: Member of {'DAQmx_Val_Task_Start' 'DAQmx_Val_Task_Stop' 'DAQmx_Val_Task_Verify' 'DAQmx_Val_Task_Commit' 'DAQmx_Val_Task_Reserve' 'DAQmx_Val_Task_Unreserve' 'DAQmx_Val_Task_Abort'}
            %VECTORIZED
            
            for i=1:length(obj)
                obj(i).driverCall('DAQmxTaskControl', obj(i).taskID, obj(i).encodePropVal(state));
            end
        end
        
        %% EVENTS
        function registerEveryNSamplesEvent(obj, callbackFunc, everyNSamples)
            %Registers a callback function to receive an event when the specified number of samples is written from the device to the buffer or from the buffer to the device. This function only works with devices that support buffered tasks.
            %When you stop a task explicitly any pending events are discarded. For example, if you call DAQmxStopTask then you do not receive any pending events.
            %NOTE: Method arguments differ in several ways from DAQmxRegisterEveryNSampleEvent()
            %NOTE: This method is effectively a macro to set the the everyNSamplesEventCallbacks and everyNSamples properties in tandem used to bind one and only one callback function to the EveryNSamples event, analagous to DAQmxRegisterEveryNSamplesEvent(). 
            %NOTE: To bind multiple callbacks in a specified order, then the everyNSamplesEventCallbacks and everyNSamples properties must be set directly.
            %
            %function registerEveryNSamplesEvent(obj, callbackName, everyNSamples)
            %  callbackFunc: (OPTIONAL) Function handle identifying single callback to set as the 'everyNSamplesEventCallbacks' property. This single callback will be invoked upon the everyNSamples event. Argument can be omitted if the 'everyNSamplesEventCallbacks' property has been previously set (i.e. is not empty).
            %  everyNSamples: (OPTIONAL) Number to set 'everyNSamples' property to, which specifies number of samples to acquire/output before EveryNSamples event is generated. Argument can be omitted if the 'everyNSamples' property has already been set.
                        
%             if nargin < 2  %The everyNSamplesEventCallbacks and everyNSamples properties must already have been set
%                 if isempty(obj.everyNSamplesEventCallbacks) || isempty(obj.everyNSamples)
%                     error('Cannot register EveryNSamples Event without either specifying callback function and everyNSamples, either as arguments or previously via ''everyNSamplesEventCallbacks'' and ''everyNSamples'' properties');
%                 elseif obj.everyNSamplesEventRegisteredFlag
%                     disp('WARNING: EveryNSamples Event is already registered. No action taken.');
%                     return;
%                 end
%             elseif nargin < 3
%                 error('Both the ''callbackFunc'' and ''everyNSamples'' values must be set together, or neither set at all when using this method');

            if nargin == 1
                obj.unregisterXXXEvent('everyNSamples','RegisterEveryNCallback');
            elseif nargin < 3
                error('Cannot register EveryNSamples Event without specifying both callback function and everyNSamples value, either as arguments to this method, or via the ''everyNSamplesEventCallbacks'' and ''everyNSamples'' properties');
            else %The callbackFunc and everyNSamples must be specified here
                obj.everyNSamples = []; %This will unregister if needed, to prevent double registration
                try 
                    obj.everyNSamplesEventCallbacks = callbackFunc;
                catch ME
                    obj.everyNSamplesEventCallbacks = {};
                    ME.rethrow();
                end
                obj.everyNSamples = everyNSamples; %will register event, with new values
                
            end
            
            %No need to explicitly register here .. this occurs via setting the properties!
            
        end       
        
               
        function registerDoneEvent(obj, callbackFunc)
            %Registers a callback function to receive an event when the specified number of samples is written from the device to the buffer or from the buffer to the device. This function only works with devices that support buffered tasks.
            %When you stop a task explicitly any pending events are discarded. For example, if you call DAQmxStopTask then you do not receive any pending events.
            %NOTE: Method arguments differ in several ways from DAQmxRegisterDoneEvent()
            %NOTE: This method is equivalent to setting the doneEventCallbacks property to a cell array of one and only one function, given by callbackFunc
            %NOTE: To bind multiple callbacks in a specified order, then the doneEventCallbacks property must be set directly.
            %
            %function registerDoneEvent(obj, callbackName)
            %  callbackFunc: Function handle identifying single callback to set as the 'doneEventCallbacks' property, which specifies a list of callbacks to invoke, in order, upon the Done event.                       
            
            
            if nargin == 1
                obj.unregisterXXXEvent('done','RegisterDoneCallback');
            else
                try 
                    obj.doneEventCallbacks = callbackFunc;
                catch ME
                    obj.doneEventCallbacks = {};
                    ME.rethrow();
                end               
            end
            
            %No need to explicitly register here .. this occurs via
            
        end
        
        
        %         function registerDoneEvent(obj, callbackName, callbackDataStruct)
        %             %Registers a callback function to receive an event when a task stops due to an error or when a finite acquisition task or finite generation task completes execution. A Done event does not occur when a task is stopped explicitly, such as by calling DAQmxStopTask.
        %             %NOTE: Method arguments differ in several ways from DAQmxRegisterDoneEvent()
        %             %
        %             %function registerDoneEvent(obj, callbackName, callbackDataStruct)
        %             %  callbackName: (OPTIONAL) String identifying callback to append to 'doneEventCallbacks' property, which identifies a list of callbacks to execute upon Done event.  Argument can be omitted if the 'doneEventCallbacks' property has been previously set (i.e. is not empty).
        %             %  callbackDataStruct: (OPTIONAL) A structure to pass to the callback as an argument. The structure cannot contain any nested structures.
        %
        %             if nargin < 2 || isempty(callbackName)
        %                 if obj.doneEventRegisteredFlag
        %                     disp('WARNING: Done Event is already registered. No action taken.');
        %                 elseif ~isempty(obj.doneEventCallbacks)
        %                     status = RegisterDoneCallback(obj,true);
        %                     if status
        %                         obj.driver.decodeStatus(status); %throws an error, if found
        %                     end
        %                     obj.doneEventRegisteredFlag = true;
        %                     obj.stop(); %NI: In some circumstances, Task must be stopped for the callback to be in effect on the first time the Task is next started (even if the Task wasn't started yet). However not seeing this behavior at moment.
        %                 else
        %                     error('Cannot register Done Event without either specifying a callbackName or setting ''doneEventCallbacks'' property value first.');
        %                 end
        %             elseif ~ischar(callbackName) || ~exist(callbackName, 'file')
        %                 error('The ''callbackName'' argument must specify a valid function on path');
        %             else
        %                 %Append callback and callbackDataStruct to Task's cell arrays
        %                 obj.doneEventCallbacks{end+1} = callbackName;
        %
        %                 if nargin < 3 || isempty(callbackDataStruct)
        %                     obj.doneEventCallbackDataStructs{end+1} = [];
        %                 elseif ~isstruct(callbackDataStruct)
        %                     error('The ''callbackDataStruct'' argument must be a structure');
        %                 else
        %                     obj.doneEventCallbackDataStructs{end+1} = callbackDataStruct;
        %                 end
        %
        %                 %Register Done Event with DAQmx driver, if not done so already
        %                 status = RegisterDoneCallback(obj,true); %This re-registers the Done Event, reflecting the updated doneEventCallbacks and doneEventCallbackDataStructs property values
        %                 if status
        %                     obj.driver.decodeStatus(status); %throws an error, if found
        %                 else
        %                     obj.stop(); %NI: In some circumstances, Task must be stopped for the callback to be in effect on the first time the Task is next started (even if the Task wasn't started yet). However not seeing this behavior at moment.
        %                     obj.doneEventRegisteredFlag = true;
        %                 end
        %             end
        %         end
        
        

        
        
        function registerSignalEvent(obj, callbackFunc, signalID)
            
            %%%%%%%%%%%TODO%%%%%%%%
            %Registers a callback function to receive an event when the specified hardware event occurs. When you stop a task explicitly any pending events are discarded. For example, if you call stop() then you do not receive any pending events.
            %The signalID must be set at time of this call and cannot be changed (event must be unregistered/re-registered to change). The callbackName can be set before, during, or after time of registration, via signalEventCallbacks property.
            %NOTE: Method arguments differ in several ways from DAQmxRegisterSignalEvent()
  
            %Registers a callback function to receive an event when the specified number of samples is written from the device to the buffer or from the buffer to the device. This function only works with devices that support buffered tasks.
            %When you stop a task explicitly any pending events are discarded. For example, if you call DAQmxStopTask then you do not receive any pending events.
            %NOTE: Method arguments differ in several ways from DAQmxRegisterDoneEvent()
            %NOTE: This method is equivalent to setting the doneEventCallbacks property to a cell array of one and only one function, given by callbackFunc
            %NOTE: To bind multiple callbacks in a specified order, then the doneEventCallbacks property must be set directly.
            %
            %function registerDoneEvent(obj, callbackName)
            %  callbackFunc: Function handle identifying single callback to set as the 'doneEventCallbacks' property, which specifies a list of callbacks to invoke, in order, upon the Done event.
            %%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if nargin == 1 
                obj.unregisterXXXEvent('signal','RegisterSignalCallback'); 
            elseif nargin < 3
                error('Cannot register Signal Event without specifying both callback function and signalID value');
            else %The callbackFunc and everyNSamples must be specified here
                obj.signalID = ''; %This will unregister if needed, to prevent double registration
                try 
                    obj.signalEventCallbacks = callbackFunc;
                catch ME
                    obj.signalEventCallbacks = {};
                    ME.rethrow();
                end       
                obj.signalID = signalID;
            end

            
            %No need to explicitly register here .. this occurs via
            
        end
        
        
        
        
        %         function registerSignalEvent(obj, signalID, callbackName, callbackDataStruct)
        %             %Registers a callback function to receive an event when the specified hardware event occurs. When you stop a task explicitly any pending events are discarded. For example, if you call stop() then you do not receive any pending events.
        %             %The signalID must be set at time of this call and cannot be changed (event must be unregistered/re-registered to change). The callbackName can be set before, during, or after time of registration, via signalEventCallbacks property.
        %             %NOTE: Method arguments differ in several ways from DAQmxRegisterSignalEvent()
        %             %
        %             %function registerSignalEvent(obj, signalID, callbackName, callbackDataStruct)
        %             %  signalID: One of {'DAQmx_Val_SampleClock', 'DAQmx_Val_SampleCompleteEvent', 'DAQmx_Val_ChangeDetectionEvent', 'DAQmx_Val_CounterOutputEvent'}. The signal for which you want to receive results.
        %             %  callbackName: (OPTIONAL) String identifying callback to append to 'doneEventCallbacks' property, which identifies a list of callbacks to execute upon Done event.  Argument can be omitted if the 'doneEventCallbacks' property has been previously set (i.e. is not empty).
        %             %  callbackDataStruct: (OPTIONAL) A structure to pass to the callback as an argument. The structure cannot contain any nested structures.
        %
        %             if nargin < 2 || isempty(signalID)
        %                 error('The ''signalID'' argument must be supplied');
        %             elseif ~isempty(obj.signalID)
        %                 disp('WARNING: Signal Event is already registered. No action taken.');
        %                 return;
        %             end
        %
        %             if nargin < 3 || isempty(callbackName)
        %                 if ~isempty(obj.signalEventCallbacks)
        %                     register();
        %                 else
        %                     error('Cannot register Signal Event without either specifying a callbackName or setting ''signalEventCallbacks'' property value first.');
        %                 end
        %             elseif ~ischar(callbackName) || ~exist(callbackName, 'file')
        %                 error('The ''callbackName'' argument must specify a valid function on path');
        %             else
        %                 %Append callback and callbackDataStruct to Task's cell arrays
        %                 obj.signalEventCallbacks{end+1} = callbackName;
        %
        %                 appendStruct=false;
        %                 if nargin < 4 || isempty(callbackDataStruct)
        %                     obj.signalEventCallbackDataStructs{end+1} = [];
        %                 elseif ~isstruct(callbackDataStruct)
        %                     error('The ''callbackDataStruct'' argument must be a structure');
        %                 else
        %                     obj.signalEventCallbackDataStructs{end+1} = callbackDataStruct;
        %                     appendStruct=true;
        %                 end
        %
        %                 try
        %                     register();
        %                 catch ME %Remove appended callbacks
        %                     obj.signalEventCallbacks(end)=[];
        %                     if appendStruct
        %                        obj.signalEventCallbackDataStructs(end)=[];
        %                     end
        %                     ME.rethrow();
        %                 end
        %             end
        %
        %             function status = register()
        %                 obj.signalID = signalID;
        %                 status = RegisterSignalCallback(obj,true);
        %                 if status
        %                     obj.signalID = '';
        %                     obj.driver.decodeStatus(status); %throws an error, if found
        %                 end
        %                 obj.stop(); %NI: In some circumstances, Task must be stopped for the callback to be in effect on the first time the Task is next started (even if the Task wasn't started yet). However not seeing this behavior at moment.
        %             end
        %
        %         end
        %        

            
        
        %% CHANNEL CONFIGURATION/CREATION
        
        function chanObjs = createAIVoltageChan(obj,deviceNames,chanIDs,chanNames,minVal,maxVal,units,customScaleName,terminalConfig)
            %Creates channel(s) to measure voltage and adds the channel(s) to the Task. If your measurement requires the use of internal excitation or you need the voltage to be scaled by excitation, call createAIVoltageChanWithExcit()
            %
            %%function chanObjs = createAIVoltageChan(obj,deviceNames,chanIDs,chanNames,minVal,maxVal,units,customScaleName,terminalConfig)
            %   deviceNames: String or string cell array specifying names of device on which channel(s) should be added, e.g. 'Dev1'. If a cell array, chanIDs must also be a cell array (of equal length).
            %   chanIDs: A numeric array of channel IDs or, in the case of multiple deviceNames (a multi-device Task), a cell array of such numeric arrays
            %   chanNames: (OPTIONAL) A string or string cell array specifying names to assign to each of the channels in chanIDs (if a single string, the chanID is appended for each channel) In the case of a multi-device Task, a cell array of such strings or string cell arrays. If omitted/empty, then default DAQmx channel name is used.
            %   minVal: (OPTIONAL) The minimum value, in units, that you expect to measure. If omitted/blank, then largest possible range supported by device is used.
            %   maxVal: (OPTIONAL) The maximum value, in units, that you expect to measure. If omitted/blank, then largest possible range supported by device is used.
            %   units: (OPTIONAL) One of {'DAQmx_Val_Volts', 'DAQmx_Val_FromCustomScale'}. Specifies units to use to return the voltage measurements. 'DAQmx_Val_FromCustomScale' specifies that units of a supplied scale are to be used (see 'units' argument). If blank/omitted, default is 'DAQmx_Val_Volts'.
            %   customScaleName: (OPTIONAL) The name of a custom scale to apply to the channel. To use this parameter, you must set units to 'DAQmx_Val_FromCustomScale'. If you do not set units to DAQmx_Val_FromCustomScale, this argument is ignored.
            %   terminalConfig: (OPTIONAL) One of {'DAQmx_Val_Cfg_Default', 'DAQmx_Val_RSE', 'DAQmx_Val_NRSE', 'DAQmx_Val_Diff', 'DAQmx_Val_PseudoDiff'}. Specifies the input terminal configuration for the channel. If omitted/blank, 'DAQmx_Val_Cfg_Default' is used, NI-DAQmx to choose the default terminal configuration for the channel.
            %
            %   chanObjs: The created Channel object(s)
            
            %Create default arguments, as needed
            if nargin < 4 || isempty(chanNames)
                chanNames = '';
            end
            
            if (nargin < 5 || isempty(minVal)) || (nargin < 6 || isempty(maxVal))
                %Get voltage min/max.
                maxArrayLength = 100;
                [deviceNames, voltageRangeArray] = obj.driverCall('DAQmxGetDevAIVoltageRngs', deviceNames, zeros(maxArrayLength,1), maxArrayLength);
                
                %Choose the range which maximizes the total range by default.
                rangeSpans = voltageRangeArray(2:2:end) - voltageRangeArray(1:2:end);
                [maxRangeSpan, maxRangeSpanIdx] = max(rangeSpans);
                
                if (nargin < 5 || isempty(minVal))
                    minVal = voltageRangeArray(2*maxRangeSpanIdx-1);
                end
                if (nargin < 6 || isempty(maxVal))
                    maxVal = voltageRangeArray(2*maxRangeSpanIdx);
                end
            end
            
            if nargin < 7 || isempty(units)
                units = 'DAQmx_Val_Volts';
            end
            
            if strcmpi(units,'DAQmx_Val_Volts')
                customScaleName = libpointer(); %Ignores any supplied argument
            elseif strcmpi(units,'DAQmx_Val_FromCustomScale') && (nargin < 8 || isempty(customScaleName) || ~ischar(customScaleName))
                error('A ''customScaleName'' must be supplied when ''units'' is specified as ''DAQmx_Val_FromCustomScale''');
            end
            
            if nargin < 9
                terminalConfig = 'DAQmx_Val_Cfg_Default';
            end
            
            %Create the channel(s)!
            chanObjs = Devices.NI.DAQmx.AIChan('DAQmxCreateAIVoltageChan',obj,deviceNames,chanIDs,chanNames,...
                obj.encodePropVal(terminalConfig),minVal,maxVal,obj.encodePropVal(units),customScaleName);
            
            
        end
        
        
        function chanObjs = createAOVoltageChan(obj,deviceNames,chanIDs,chanNames,minVal,maxVal,units,customScaleName)
            %Creates channel(s) to generate voltage and adds the channel(s) to the Task.
            %
            %%function chanObjs = createAIVoltageChan(obj,deviceNames,chanIDs,chanNames,minVal,maxVal,units,customScaleName,terminalConfig)
            %   deviceNames: String or string cell array specifying names of device on which channel(s) should be added, e.g. 'Dev1'. If a cell array, chanIDs must also be a cell array (of equal length).
            %   chanIDs: A numeric array of channel IDs or, in the case of multiple deviceNames (a multi-device Task), a cell array of such numeric arrays
            %   chanNames: (OPTIONAL) A string or string cell array specifying names to assign to each of the channels in chanIDs (if a single string, the chanID is appended for each channel) In the case of a multi-device Task, a cell array of such strings or string cell arrays. If omitted/empty, then default DAQmx channel name is used.
            %   minVal: (OPTIONAL) The minimum value, in units, that you expect to generate. If omitted/blank, then largest possible range supported by device is used.
            %   maxVal: (OPTIONAL) The maximum value, in units, that you expect to generate. If omitted/blank, then largest possible range supported by device is used.
            %   units: (OPTIONAL) One of {'DAQmx_Val_Volts', 'DAQmx_Val_FromCustomScale'}. Specifies units in which to generate voltage. 'DAQmx_Val_FromCustomScale' specifies that units of a supplied scale are to be used (see 'units' argument). If blank/omitted, default is 'DAQmx_Val_Volts'.
            %   customScaleName: (OPTIONAL) The name of a custom scale to apply to the channel. To use this parameter, you must set units to 'DAQmx_Val_FromCustomScale'. If you do not set units to DAQmx_Val_FromCustomScale, this argument is ignored.
            %
            %   chanObjs: The created Channel object(s)
            
            %Create default arguments, as needed
            if nargin < 4 || isempty(chanNames)
                chanNames = '';
            end
            
            if (nargin < 5 || isempty(minVal)) || (nargin < 6 || isempty(maxVal))
                %Get voltage min/max.
                maxArrayLength = 100;
                [deviceNames, voltageRangeArray] = obj.driverCall('DAQmxGetDevAOVoltageRngs', deviceNames, zeros(maxArrayLength,1), maxArrayLength);
                
                %Choose the range which maximizes the total range by default.
                rangeSpans = voltageRangeArray(2:2:end) - voltageRangeArray(1:2:end);
                [maxRangeSpan, maxRangeSpanIdx] = max(rangeSpans);
                
                if (nargin < 5 || isempty(minVal))
                    minVal = voltageRangeArray(2*maxRangeSpanIdx-1);
                end
                if (nargin < 6 || isempty(maxVal))
                    maxVal = voltageRangeArray(2*maxRangeSpanIdx);
                end
            end
            
            if nargin < 7 || isempty(units)
                units = 'DAQmx_Val_Volts';
            end
            
            if strcmpi(units,'DAQmx_Val_Volts')
                customScaleName = libpointer(); %Ignores any supplied argument
            elseif strcmpi(units,'DAQmx_Val_FromCustomScale') && (nargin < 8 || isempty(customScaleName) || ~ischar(customScaleName))
                error('A ''customScaleName'' must be supplied when ''units'' is specified as ''DAQmx_Val_FromCustomScale''');
            end
            
            
            %Create the channel(s)!
            chanObjs = Devices.NI.DAQmx.AOChan('DAQmxCreateAOVoltageChan',obj,deviceNames,chanIDs,chanNames,...
                minVal,maxVal,obj.encodePropVal(units),customScaleName);
            
            
        end
        
        function chanObj = createDOChan(obj,deviceNames,chanIDs,chanNames,lineGrouping)
            %Creates channel(s) to generate digital signals and adds the channel(s) to the task you specify with taskHandle. You can group digital lines into one digital channel or separate them into multiple digital channels. 
            %If you specify one or more entire ports in lines by using port physical channel names, you cannot separate the ports into multiple channels. To separate ports into multiple channels, use this function multiple times with a different port each time.
            %
            %%function chanObj = addDigitalOutputChannel(obj,deviceNames,chanIDs,chanNames)
            %   deviceNames: String or string cell array specifying names of device on which channel(s) should be added, e.g. 'Dev1'. If a cell array, chanIDs must also be a cell array (of equal length).
            %   chanIDs: A string identifying port and/or line IDs for this Channel, e.g. 'port0','port0/line0:1', or 'line0:15'. In the case of multiple deviceNames (a multi-device Task), a cell array of such strings
            %   chanNames: (OPTIONAL) A string or string cell array specifying names to assign to each of the channels in chanIDs (if a single string, the chanID is appended for each channel) In the case of a multi-device Task, a cell array of such strings or string cell arrays. If omitted/empty, then default DAQmx channel name is used.
            %   lineGrouping: (OPTIONAL) One of {'DAQmx_Val_ChanPerLine', 'DAQmx_Val_ChanForAllLines'}. If empty/omitted, 'DAQmx_Val_ChanForAllLines' is used. Specifies whether to group digital lines into one or more virtual channels. If you specify one or more entire ports in chanIDs, you must set lineGrouping to DAQmx_Val_ChanForAllLines.
            %
            %   chanObj: The created Channel object
            
            %Supply default input arguments, as needed
            if nargin < 4
                chanNames = '';
            end
            
            if nargin < 5
                lineGrouping = 'DAQmx_Val_ChanForAllLines';
            end
            
            %Create the channel!
            chanObj = Devices.NI.DAQmx.DOChan('DAQmxCreateDOChan',obj,deviceNames,chanIDs,chanNames,obj.encodePropVal(lineGrouping));
        end

        
        function chanObj = createDIChan(obj,deviceNames,chanIDs,chanNames,lineGrouping)
            %Creates channel(s) to measure digital signals and adds the channel(s) to the task you specify with taskHandle. You can group digital lines into one digital channel or separate them into multiple digital channels. If you specify one or more entire ports in lines by using port physical channel names, you cannot separate the ports into multiple channels. To separate ports into multiple channels, use this function multiple times with a different port each time.            %
            %
            %%function chanObj = addDigitalOutputChannel(obj,deviceNames,chanIDs,chanNames)
            %   deviceNames: String or string cell array specifying names of device on which channel(s) should be added, e.g. 'Dev1'. If a cell array, chanIDs must also be a cell array (of equal length).
            %   chanIDs: A string identifying port and/or line IDs for this Channel, e.g. 'port0','port0/line0:1', or 'line0:15'. In the case of multiple deviceNames (a multi-device Task), a cell array of such strings
            %   chanNames: (OPTIONAL) A string or string cell array specifying names to assign to each of the channels in chanIDs (if a single string, the chanID is appended for each channel) In the case of a multi-device Task, a cell array of such strings or string cell arrays. If omitted/empty, then default DAQmx channel name is used.
            %   lineGrouping: (OPTIONAL) One of {'DAQmx_Val_ChanPerLine', 'DAQmx_Val_ChanForAllLines'}. If empty/omitted, 'DAQmx_Val_ChanForAllLines' is used. Specifies whether to group digital lines into one or more virtual channels. If you specify one or more entire ports in chanIDs, you must set lineGrouping to DAQmx_Val_ChanForAllLines.
            %
            %   chanObj: The created Channel object
            
            %Supply default input arguments, as needed
            if nargin < 4
                chanNames = '';
            end
            
            if nargin < 5
                lineGrouping = 'DAQmx_Val_ChanForAllLines';
            end
            
            %Create the channel!
            chanObj = Devices.NI.DAQmx.DIChan('DAQmxCreateDIChan',obj,deviceNames,chanIDs,chanNames,obj.encodePropVal(lineGrouping));
        end        
                
        
        function chanObjs = createCOPulseChanFreq(obj, deviceNames, chanIDs, chanNames, freq, dutyCycle, initialDelay, idleState, units)
            %Creates channel(s) to generate digital pulses that freq and dutyCycle define and adds the channel to the task you specify with taskHandle.
            %The pulses appear on the default output terminal of the counter unless you select a different output terminal (by setting the OutputTerminal property after creating the Channel)
            %NOTE: Multiple CO channels can be created with this call, but they will have same frequency, dutyCycle, initialDelay, idleState, and units.
            %
            %function chanObj = createCOPulseChanFreq(obj, deviceName, chanIDs, chanNames, freq, dutyCycle, initialDelay, idleState, units)
            %   deviceNames: String or string cell array specifying names of device on which channel(s) should be added, e.g. 'Dev1'. If a cell array, chanIDs must also be a cell array (of equal length).
            %   chanIDs: A numeric array of channel IDs or, in the case of multiple deviceNames (a multi-device Task), a cell array of such numeric arrays
            %   chanNames: (OPTIONAL) A string or string cell array specifying names to assign to each of the channels in chanIDs (if a single string, the chanID is appended for each channel) In the case of a multi-device Task, a cell array of such strings or string cell arrays. If omitted/empty, then default DAQmx channel name is used.
            %   freq: The frequency at which to generate pulses.
            %   dutyCycle: (OPTIONAL) The width of the pulse divided by the pulse period. NI-DAQmx uses this ratio, combined with frequency, to determine pulse width and the interval between pulses. If omitted/empty, value of 0.5 used.
            %   initialDelay: (OPTIONAL) The amount of time in seconds to wait before generating the first pulse. If omitted/empty, value of 0 is used.
            %   idleState: (OPTIONAL) One of {'DAQmx_Val_High', 'DAQmx_Val_Low'}. The resting state of the output terminal. If omitted/empty, 'DAQmx_Val_Low' is used.
            %   units: (OPTIONAL) One of {'DAQmx_Val_Hz'}. The units in which to specify freq. If omitted/empty, default value of 'DAQmx_Val_Hz' is used.
            %
            %   chanObjs: The created Channel object(s)
            
            %Create default arguments, as needed
            if nargin < 5
                error(['Insufficient number of input arguments. ']);
            end
            
            if isempty(chanNames)
                chanNames = '';
            end
            
            if nargin < 6 || isempty(dutyCycle)
                dutyCycle = 0.5;
            end
            
            if nargin < 7 || isempty(initialDelay)
                initialDelay = 0.0;
            end
            
            if nargin < 8 || isempty(idleState)
                idleState = 'DAQmx_Val_Low';
            end
            
            if nargin < 9 || isempty(units)
                units = 'DAQmx_Val_Hz';
            end
            
            %Create the channel!
            chanObjs = Devices.NI.DAQmx.COChan('DAQmxCreateCOPulseChanFreq',obj,deviceNames,chanIDs,chanNames,...
                obj.encodePropVal(units), obj.encodePropVal(idleState), initialDelay, freq, dutyCycle);
        end
        
        
        function chanObjs = createCOPulseChanTicks(obj, deviceNames, chanIDs, chanNames, sourceTerminal, lowTicks, highTicks, initialDelay, idleState)
            %Creates channel(s) to generate digital pulses defined by the number of timebase ticks that the pulse is at a high state and the number of timebase ticks that the pulse is at a low state and also adds the channel to the task you specify with taskHandle.
            %The pulses appear on the default output terminal of the counter unless you select a different output terminal.
            %NOTE: Multiple CO channels can be created with this call, but they will have same lowTicks, highTicks, sourceTerminal, initialDelay, and idleState.
            %
            %function chanObj = createCOPulseChanTicks(obj, deviceName, chanIDs, chanNames, freq, dutyCycle, initialDelay, idleState, units)
            %   deviceNames: String or string cell array specifying names of device on which channel(s) should be added, e.g. 'Dev1'. If a cell array, chanIDs must also be a cell array (of equal length).
            %   chanIDs: A numeric array of channel IDs or, in the case of multiple deviceNames (a multi-device Task), a cell array of such numeric arrays
            %   chanNames: (OPTIONAL) A string or string cell array specifying names to assign to each of the channels in chanIDs (if a single string, the chanID is appended for each channel) In the case of a multi-device Task, a cell array of such strings or string cell arrays. If omitted/empty, then default DAQmx channel name is used.
            %   lowTicks: The number of timebase ticks that the pulse is low.
            %   highTicks: The number of timebase ticks that the pulse is high.
            %   sourceTerminal: The terminal to which you connect an external timebase. The terminal will have  You also can specify a source terminal by using a terminal name.
            %   initialDelay: <OPTIONAL - Default=0> The number of timebase ticks to wait before generating the first pulse.
            %   idleState: <OPTIONAL - Default='DAQmx_Val_Low'> One of {'DAQmx_Val_High', 'DAQmx_Val_Low'}. The resting state of the output terminal.
            %
            %   chanObjs: The created Channel object(s)
            
            %Create default arguments, as needed
            if nargin < 7
                error('Insufficient number of input arguments.');
            end
            
            if isempty(chanNames)
                chanNames = '';
            end
            
            if nargin < 8 || isempty(initialDelay)
                initialDelay = 0.0;
            end
            
            if nargin < 9 || isempty(idleState)
                idleState = 'DAQmx_Val_Low';
            end
            
            %Create the channel!
            chanObjs = Devices.NI.DAQmx.COChan('DAQmxCreateCOPulseChanTicks',obj,deviceNames,chanIDs,chanNames,...
                sourceTerminal, obj.encodePropVal(idleState), initialDelay, lowTicks, highTicks);
        end
        
        function chanObjs = createCOPulseChanTime(obj, deviceNames, chanIDs, chanNames, lowTime, highTime, initialDelay, idleState, units)
            %Creates channel(s) to generate digital pulses defined by the number of timebase ticks that the pulse is at a high state and the number of timebase ticks that the pulse is at a low state and also adds the channel to the task you specify with taskHandle. 
            %The pulses appear on the default output terminal of the counter unless you select a different output terminal.
            %NOTE: Multiple CO channels can be created with this call, but they will have same lowTicks, highTicks, sourceTerminal, initialDelay, and idleState.
            %
            %function chanObj = createCOPulseChanTicks(obj, deviceName, chanIDs, chanNames, freq, dutyCycle, initialDelay, idleState, units)
            %   deviceNames: String or string cell array specifying names of device on which channel(s) should be added, e.g. 'Dev1'. If a cell array, chanIDs must also be a cell array (of equal length).
            %   chanIDs: A numeric array of channel IDs or, in the case of multiple deviceNames (a multi-device Task), a cell array of such numeric arrays
            %   chanNames: <OPTIONAL> A string or string cell array specifying names to assign to each of the channels in chanIDs (if a single string, the chanID is appended for each channel) In the case of a multi-device Task, a cell array of such strings or string cell arrays. If omitted/empty, then default DAQmx channel name is used.
            %   lowTime: The amount of time the pulse is low, in seconds.
            %   highTime: The amount of time the pulse is high, in seconds.
            %   initialDelay: <OPTIONAL - Default: 0> The amount of time in seconds to wait before generating the first pulse.
            %   idleState: <OPTIONAL - Default: 'DAQmx_Val_Low'> One of {'DAQmx_Val_High', 'DAQmx_Val_Low'}. The resting state of the output terminal.
            %   units: <OPTIONAL - Default: 'DAQmx_Val_Seconds'> One of {'DAQmx_Val_Seconds'}. The units in which to specify time.
            %
            %   chanObjs: The created Channel object(s)
        
            %Create default arguments, as needed
            if nargin < 6
                error('Insufficient number of input arguments.');
            end            
            
            if isempty(chanNames)
                chanNames = '';
            end
            
            if nargin < 7 || isempty(initialDelay)
                initialDelay = 0.0;
            end
            
            if nargin < 8 || isempty(idleState)
                idleState = 'DAQmx_Val_Low';
            end      
            
            if nargin < 9 || isempty(units)
                units = 'DAQmx_Val_Seconds';
            end
            

            %Create the channel!
            chanObjs = Devices.NI.DAQmx.COChan('DAQmxCreateCOPulseChanTime',obj,deviceNames,chanIDs,chanNames,...
                obj.encodePropVal(units), obj.encodePropVal(idleState), initialDelay, lowTime, highTime);            
        end        
        
        
        
        
        
        
        
        function chanObjs = createCICountEdgesChan(obj, deviceNames, chanIDs, chanNames, countDirection, edge, initialCount)
            %Creates a channel to count the number of rising or falling edges of a digital signal and adds the channel to the task you specify with taskHandle.
            %You can create only one counter input channel at a time with this function because a task can include only one counter input channel.
            %To read from multiple counters simultaneously, use a separate task for each counter. Connect the input signal to the default input terminal of the counter unless you select a different input terminal.
            %
            %function chanObj = createCICountEdgesChan(obj, deviceName, chanIDs, chanNames, freq, dutyCycle, initialDelay, idleState, units)
            %   deviceNames: String or string cell array specifying names of device on which channel(s) should be added, e.g. 'Dev1'. If a cell array, chanIDs must also be a cell array (of equal length).
            %   chanIDs: A numeric array of counter IDs or, in the case of multiple deviceNames (a multi-device Task), a cell array of such numeric arrays
            %   chanNames: (OPTIONAL) A string or string cell array specifying names to assign to each of the channels in chanIDs (if a single string, the chanID is appended for each channel) In the case of a multi-device Task, a cell array of such strings or string cell arrays. If omitted/empty, then default DAQmx channel name is used.
            %   countDirection: (OPTIONAL) One of {'DAQmx_Val_CountUp', 'DAQmx_Val_CountDown', 'DAQmx_Val_ExtControlled'}. If empty/omitted, 'DAQmx_Val_CountUp' is assumed. Specifies whether to increment or decrement the counter on each edge.
            %   edge: (OPTIONAL) One of {'DAQmx_Val_Rising', 'DAQmx_Val_Falling'}. If empty/omitted, 'DAQmx_Val_Rising' is assumed. Specifies on which edges of the input signal to increment or decrement the count.
            %   initialCount: (OPTIONAL) The value from which to start counting. If empty/omitted, the value 0 is assumed.
            %
            %   chanObjs: The created Channel object(s)
            
            
            
            %Create default arguments, as needed
            if nargin < 3
                error('Insufficient number of input arguments.');
            end
            
            if nargin < 4 || isempty(chanNames)
                chanNames = '';
            end
            
            if nargin < 5 || isempty(countDirection)
                countDirection = 'DAQmx_Val_CountUp';
            end
            
            if nargin < 6 || isempty(edge)
                edge = 'DAQmx_Val_Rising';
            end
            
            if nargin < 7 || isempty(initialCount)
                initialCount = 0;
            elseif ~isnumeric(initialCount) || initialCount < 0 || round(initialCount) ~= (initialCount)
                error('Argument ''initialCount'' must be non-negative integer value');
            end
            
            %Create the channel!
            chanObjs = Devices.NI.DAQmx.CIChan('DAQmxCreateCICountEdgesChan',obj,deviceNames,chanIDs,chanNames,...
                obj.encodePropVal(edge),initialCount, obj.encodePropVal(countDirection));
            
        end
        
        
        
        
        %% TIMING
        function cfgSampClkTiming(obj, rate, sampleMode, sampsPerChanToAcquire, source, activeEdge)
            %Sets the source of the Sample Clock, the rate of the Sample Clock, and the number of samples to acquire or generate.
            %
            %function cfgSampClkTiming(obj, rate, sampleMode, sampsPerChanToAcquire, source, activeEdge)
            %   rate: Sampling rate in samples per second per channel.
            %   sampleMode: One of {'DAQmx_Val_FiniteSamps','DAQmx_Val_ContSamps','DAQmx_Val_HWTimedSinglePoint'}. Specifies whether the task acquires or generates samples continuously or if it acquires or generates a finite number of samples.
            %   sampsPerChanToAcquire: (OPTIONAL) If sampleMode is DAQmx_Val_FiniteSamps, this property is mandatory, and represents the number of samples to acquire or generate for each channel in the task . If sampleMode is DAQmx_Val_ContSamps, NI-DAQmx uses this value to determine the buffer size. If empty/omitted, the DAQmx default value is used for Task's sample rate.
            %   source: (OPTIONAL) String specifying the source terminal of the Sample Clock. If empty/omitted, the internal clock is used.
            %   activeEdge: (OPTIONAL) One of {'DAQmx_Val_Rising', 'DAQmx_Val_Falling'}.  Specifies on which edge of the clock to acquire or generate samples. If empty/omitted, 'DAQmx_Val_Rising' is used.
            
            if nargin < 4 || isempty(sampsPerChanToAcquire)
                if strcmpi(sampleMode,'DAQmx_Val_FiniteSamps')
                    sampsPerChanToAcquire = 2; %This represents minimum value advisable when using FiniteSamps mode. If this isn't set, then Error -20077 can occur if writeXXX() operation precedes configuring sampQuantSampPerChan property to a non-zero value -- a bit strange, considering that it is allowed to buffer/write more data than specified to generate.
                else
                    sampsPerChanToAcquire = 0; %For input Tasks, this should force the default values to be used, given Task's sample rate and specified sampleMode.
                end
            end
            
            if nargin < 5 || isempty(source)
                source = libpointer();
            end
            if nargin < 6 || isempty(activeEdge)
                activeEdge = 'DAQmx_Val_Rising';
            end
            obj.driverCall('DAQmxCfgSampClkTiming', obj.taskID, source, rate, obj.encodePropVal(activeEdge), ...
                obj.encodePropVal(sampleMode), sampsPerChanToAcquire);
        end
        
        
        function cfgChangeDetectionTiming(obj, risingEdgeChan, fallingEdgeChan, sampleMode, sampsPerChanToAcquire)
            %Configures the task to acquire samples on the rising and/or falling edges of the lines or ports you specify.
            %
            %function cfgChangeDetectionTiming(obj, risingEdgeChan, fallingEdgeChan, sampleMode, sampsPerChanToAcquire)
            %   risingEdgeChan: The names of the digital lines or ports on which to detect rising edges.You can specify a list or range of lines and/or ports.
            %   fallingEdgeChan: The names of the digital lines or ports on which to detect falling edges.You can specify a list or range of lines and/or ports.
            %   sampleMode: One of {'DAQmx_Val_FiniteSamps','DAQmx_Val_ContSamps','DAQmx_Val_HWTimedSinglePoint'}. Specifies whether the task acquires or generates samples continuously or if it acquires or generates a finite number of samples.            
            %   sampsPerChanToAcquire: (OPTIONAL) If sampleMode is DAQmx_Val_FiniteSamps, this property is mandatory, and represents the number of samples to acquire or generate for each channel in the task . If sampleMode is DAQmx_Val_ContSamps, NI-DAQmx uses this value to determine the buffer size. If empty/omitted, the DAQmx default value is used for Task's sample rate.
            
            if nargin < 4 || isempty(sampsPerChanToAcquire)
                if strcmpi(sampleMode,'DAQmx_Val_FiniteSamps')
                    sampsPerChanToAcquire = 2; %This represents minimum value advisable when using FiniteSamps mode. If this isn't set, then Error -20077 can occur if writeXXX() operation precedes configuring sampQuantSampPerChan property to a non-zero value -- a bit strange, considering that it is allowed to buffer/write more data than specified to generate.
                else
                    sampsPerChanToAcquire = 0; %For input Tasks, this should force the default values to be used, given Task's sample rate and specified sampleMode.
                end
            end

            obj.driverCall('DAQmxCfgChangeDetectionTiming', obj.taskID, risingEdgeChan, fallingEdgeChan, obj.encodePropVal(sampleMode), sampsPerChanToAcquire);
        end
        
        
        function cfgImplicitTiming(obj, sampleMode, sampsPerChanToAcquire)
            %Sets only the number of samples to acquire or generate without specifying timing. Typically, you should use this function when the task does not require sample timing, such as tasks that use counters for buffered frequency measurement, buffered period measurement, or pulse train generation.
            %
            %function cfgImplicitTiming(obj, sampleMode, sampsPerChanToAcquire)
            %   sampleMode: One of {'DAQmx_Val_FiniteSamps','DAQmx_Val_ContSamps','DAQmx_Val_HWTimedSinglePoint'}. Specifies whether the task acquires or generates samples continuously or if it acquires or generates a finite number of samples.
            %   sampsPerChanToAcquire: (OPTIONAL) The number of samples to acquire or generate for each channel in the task if sampleMode is DAQmx_Val_FiniteSamps. If sampleMode is DAQmx_Val_ContSamps, NI-DAQmx uses this value to determine the buffer size. If empty/omitted, the DAQmx default value is used for Task's sample rate.
            
            if nargin < 3 || isempty(sampsPerChanToAcquire)
                sampsPerChanToAcquire = 0; %This should force the default values to be used, for Task's sample rate and specified sampleMode
            end
            
            obj.driverCall('DAQmxCfgImplicitTiming', obj.taskID, obj.encodePropVal(sampleMode), sampsPerChanToAcquire);
            
        end
        
        
        %% TRIGGERING
        function cfgAnlgEdgeStartTrig(obj, triggerSource, triggerSlope, triggerLevel)
            %Configures the task to start acquiring or generating samples when an analog signal crosses the level you specify.
            %
            %function cfgAnlgEdgeStartTrig(obj, triggerSource, triggerSlope, triggerLevel)
            %   triggerSource: The name of a channel or terminal where there is an analog signal to use as the source of the trigger. For E Series devices, if you use a channel name, the channel must be the first channel in the task. The only terminal you can use for E Series devices is PFI0.
            %   triggerSlope: One of {'DAQmx_Val_RisingSlope' 'DAQmx_Val_FallingSlope'}. If empty, 'DAQmx_Val_RisingSlope' is used. Specifies on which slope of the signal to start acquiring or generating samples when the signal crosses triggerLevel.
            %   triggerLevel: The threshold at which to start acquiring or generating samples. Specify this value in the units of the measurement or generation. Use triggerSlope to specify on which slope to trigger at this threshold.
            
            
        end
        
        function cfgDigEdgeStartTrig(obj, triggerSource, triggerEdge)
            %Configures the task to start acquiring or generating samples on a rising or falling edge of a digital signal.
            %
            %function cfgDigEdgeStartTrig(obj, triggerSource, triggerEdge)
            %   triggerSource: The name of a terminal where there is a digital signal to use as the source of the trigger.
            %   triggerEdge: (OPTIONAL) One of {'DAQmx_Val_Rising' 'DAQmx_Val_Falling'}. If empty/omitted, 'DAQmx_Val_Rising' is used. Specifies on which edge of a digital signal to start acquiring or generating samples.
            
            if nargin < 3 || isempty(triggerEdge)
                triggerEdge = 'DAQmx_Val_Rising';
            end
            
            obj.driverCall('DAQmxCfgDigEdgeStartTrig', obj.taskID, triggerSource, obj.encodePropVal(triggerEdge));
        end
        
        function disableStartTrig(obj)
            obj.driverCall('DAQmxDisableStartTrig', obj.taskID);            
        end
        
        function cfgDigEdgeRefTrig(obj, triggerSource, pretriggerSamples, triggerEdge)
            %Configures the task to stop the acquisition when the device acquires all pretrigger samples, detects a rising or falling edge of a digital signal, and acquires all posttrigger samples.
            %
            %function cfgDigEdgeStartTrig(obj, triggerSource, triggerEdge)
            %   triggerSource: The name of a terminal where there is a digital signal to use as the source of the trigger.
            %   pretriggerSamples: (OPTIONAL) The minimum number of samples per channel to acquire before recognizing the Reference Trigger. The number of posttrigger samples per channel is equal to number of samples per channel in the NI-DAQmx Timing functions minus pretriggerSamples. If empty/omitted, value of 0 is used.
            %   triggerEdge: (OPTIONAL) One of {'DAQmx_Val_Rising' 'DAQmx_Val_Falling'}. If empty/omitted, 'DAQmx_Val_Rising' is used. Specifies on which edge of a digital signal to start acquiring or generating samples.
            
            if nargin < 3 || isempty(pretriggerSamples)
                pretriggerSamples = 0;
            end
            
            if nargin < 4 || isempty(triggerEdge)
                triggerEdge = 'DAQmx_Val_Rising';
            end
            
            obj.driverCall('DAQmxCfgDigEdgeRefTrig', obj.taskID, triggerSource, obj.encodePropVal(triggerEdge), pretriggerSamples);
        end
        
        
        
        
        %% READ FUNCTIONS
        function [sampsRead, outputData] = readAnalogData(task, varargin)
            %function [sampsRead, outputData] = readAnalogData(task, numSampsPerChan, outputFormat, timeout, outputVarOrSize)
            %	task: A DAQmx.Task object handle
            %	numSampsPerChan: (OPTIONAL) Specifies number of samples per channel to read. If omitted/empty, value of 'inf' is used. If 'inf' or < 0, then all available samples are read, up to the size of the output array.
            %	outputFormat: (OPTIONAL) One of {'native','scaled'}. If omitted/empty, 'scaled' is assumed. Indicate native unscaled format and double scaled format, respectively.
            %   timeout: (OPTIONAL) Time, in seconds, to wait for function to complete read. If omitted/empty, value of 'inf' is used. If 'inf' or < 0, then function will wait indefinitely.
            %	outputVarOrSize: (OPTIONAL) Either name of preallocated MATLAB variable into which to store read data, or the size in samples of the output variable to create (to be returned as outputData argument).
            %
            %   sampsRead: Number of samples actually read
            %   outputData: Array of output data with samples arranged in rows and channels in columns. This value is not output if outputVarOrSize is a string specifying a preallocated output variable.
            
            if nargout == 1
                sampsRead = ReadAnalogData(task, varargin{:});
            else
                [sampsRead, outputData] = ReadAnalogData(task, varargin{:});
            end
            
        end
        
        function value = readCounterDataScalar(task,timeout)
            %Reads a single sample from a Counter Input task. 
            %function value = readCounterDataScalar(task,varargin)
            %   task: A DAQmx.Task object handle
            %   timeout: (OPTIONAL) Time, in seconds, to wait for function to complete read. If omitted/empty, value of 'inf' is used. If 'inf' or < 0, then function will wait indefinitely.
            %
            %   value: Counter value, returned as double.
            %
            
            if nargin < 2 || isempty(timeout) || isinf(timeout) || timeout < 0
                timeout = -1;
            end           
            
            if strcmpi(get(task.channels(1),'measType'),'DAQmx_Val_CountEdges')
                value = double(task.driverCall('DAQmxReadCounterScalarU32',task.taskID,timeout,0,libpointer()));
            else
                value = task.driverCall('DAQmxReadCounterScalarF64',task.taskID,timeout,0,libpointer());
            end
            
        end
        
        
        %% WRITE FUNCTIONS
        
        function sampsPerChanWritten = writeAnalogData(task, varargin) %%TMW: Too bad have to use varargin
            %function sampsPerChanWritten = WriteAnalogData(task, writeData, timeout, numSampsPerChan)
            % writeData: Data to write to the Channel(s) of this Task.Supplied as matrix, whose rows represent samples and columns represent channels. Data should be of type uint8, uint16, or uint32, and sufficiently long to encompass number of lines for channel.
            %            Data can be either 'scaled' (of type double and specified in the units of each Channel) or 'native' (of integer type, of the appropriate class for the Task device(s)' Channels)
            % timeout: (OPTIONAL) Time, in seconds, to wait for function to complete read. Default value is 'inf'. If 'inf' or < 0, then function will wait indefinitely. A value of 0 indicates to try once to write the submitted samples. If this function successfully writes all submitted samples, it does not return an error. Otherwise, the function returns a timeout error and returns the number of samples actually written.
            % autoStart: (OPTIONAL) Logical value specifies whether or not this function automatically starts the task if you do not start it. If omitted/empty, 'false' is assumed.
            % numSampsPerChan: (OPTIONAL) Specifies number of samples per channel to write. If omitted/empty, the number of rows in the writeData array will be written.
            %
            % sampsPerChanWritten: The actual number of samples per channel successfully written to the buffer.
            
            %%%TMW: Nearly 'direct' indirection...would be nice to directly associate a MEX function as a method. Though maybe this is very little performance hit.
            sampsPerChanWritten = WriteAnalogData(task, varargin{:});
            %disp(['Wrote ' num2str(sampsPerChanWritten) ' samples of data.']);
        end
        
        %         function sampsPerChanWritten = writeDigitalData(task, varargin)
        %             %function sampsPerChanWritten = writeDigitalData(task, writeData, timeout, numSampsPerChan)
        %             % writeData: Data to write to the Channel(s) of this Task. Supplied as matrix, whose rows represent samples and columns represent channels. Data should be of type uint8, uint16, or uint32, and sufficiently long to encompass number of lines for channel. If channel has > 32 lines, then 'uint8' type should be used and each sample should consist of successive 'uint8' values -- exatctly as many as are required for the number of lines.
        %             % timeout: (OPTIONAL) Time, in seconds, to wait for function to complete read. Default value is 'inf'. If 'inf' or < 0, then function will wait indefinitely. A value of 0 indicates to try once to write the submitted samples. If this function successfully writes all submitted samples, it does not return an error. Otherwise, the function returns a timeout error and returns the number of samples actually written.
        %             % autoStart: (OPTIONAL) Logical value specifies whether or not this function automatically starts the task if you do not start it. If omitted/empty, 'false' is assumed.
        %             % numSampsPerChan: (OPTIONAL) Specifies number of samples per channel to write. If omitted/empty, the number of rows in the writeData array will be written.
        %             %
        %             % sampsPerChanWritten: The actual number of samples per channel successfully written to the buffer.
        %
        %             %%%TMW: Nearly 'direct' indirection...would be nice to directly associate a MEX function as a method. Though maybe this is very little performance hit.
        %             sampsPerChanWritten = WriteDigitalData(task, varargin{:});
        %             %disp(['Wrote ' num2str(sampsPerChanWritten) ' samples of data.']);
        %         end
        %
        
        %% EXPORT HW SIGNALS
        function exportSignal(obj,signalID, outputTerminal)
            obj.driverCall('DAQmxExportSignal', obj.taskID, obj.encodePropVal(signalID), outputTerminal);
        end
        
        
        %% INTERNAL BUFFER CONFIGURATION
        function cfgInputBuffer(obj, numSampsPerChan)
            %Overrides the automatic output buffer allocation that NI-DAQmx performs.
            %
            %function cfgInputBuffer(obj, numSampsPerChan)
            %   numSampsPerChan: The number of samples the buffer can hold for each channel in the task. Zero indicates no buffer should be allocated. Use a buffer size of 0 to perform a hardware-timed operation without using a buffer.
            %VECTORIZED
            
            obj.cfgInputBufferEx(numSampsPerChan,false);  %Provides default DAQmx behavior of allocating an /intended/ amount of memory, deferring allocation error until Task is started (or otherwise reserved)
            
        end
        
        function sampsAllocated = cfgInputBufferVerify(obj, numSampsPerChan, reductionIncrement)
            %Overrides the automatic output buffer allocation that NI-DAQmx performs.
            %Unlike default cfgInputBuffer(), method will immediately reserve the specified memory (and will immediately produce error if unable to do so)
            %In addition, for Continuous Tasks with Sample Clock timing, if the allocation is unsuccesful, allocation of smaller amounts, in steps of 'reductionIncrement' will be tried iteratively until allocation succeeds.
            %A typical usage is where reductionIncrement = (2 * everyNSamples), which ensures that buffer size is an even multiple of everyNSamples (as required to avoid Error -200877)
            %
            %function sampsAllocated = cfgInputBufferSafe(obj, numSampsPerChan, reductionIncrement)
            %   numSampsPerChan: The number of samples the buffer can hold for each channel in the task. Zero indicates no buffer should be allocated. Use a buffer size of 0 to perform a hardware-timed operation without using a buffer.
            %   reductionIncrement: (OPTIONAL) For Continuous Tasks with Sample Clock timing, the amount by which to reduce numSampsPerChan iteratively until allocation is successful.
            %   
            %   sampsAllocated: Amount of memory actually allocated
                        
            
            %Parse input arguments
            if nargin < 3 || isempty(reductionIncrement)
                reductionIncrement = false;
            end
            
            %Handle cases to pass through to default behavior, with auto-reserve function enabled
            if ~reductionIncrement || ~strcmpi(obj.get('sampQuantSampMode'), 'DAQmx_Val_ContSamps') || ~strcmpi(obj.get('sampTimingType'),'DAQmx_Val_SampClk')
                sampsAllocated = numSampsPerChan;
                obj.cfgInputBufferEx(numSampsPerChan,true);
                return;
            end           
            
            %Determine if there is an EveryNSamples 'floor' that cannot be crossed
            if ~isempty(obj.everyNSamples) && ~isempty(obj.everyNSamplesEventCallbacks)
                minBufSize = obj.everyNSamples;
            else
                minBufSize = 2;
            end
            
            %Attempt allocation, iteratively
            requestedNumSamps = numSampsPerChan;
            success = attemptAllocation();
            while ~success
                numSampsPerChan = numSampsPerChan - reductionIncrement;
                if numSampsPerChan >= minBufSize
                    success = attemptAllocation();
                else
                    error('DAQmx:InputBufAllocation', ['Failed to allocate memory for input buffer. Final attempt to allocate ' num2str(numSampsPerChan+reductionIncrement) ' samples was unsuccessful.']);
                end
            end
            
            %Return amount actually allocated
            sampsAllocated = numSampsPerChan;
            
            %Provide feedback
            if obj.verbose && sampsAllocated < requestedNumSamps
                disp(['Allocated input buffer of smaller size (' num2str(sampsAllocated) ' samples) than was requested (' num2str(requestedNumSamps) ' samples).']);
            end
            
            
            return;
                
            function success = attemptAllocation()
                memoryAllocationError = ['DAQmx:E' num2str(abs(obj.memoryErrorCode))];

                success=true;
                try
                    obj.cfgInputBufferEx(numSampsPerChan,true);
                catch ME
                    switch ME.identifier
                        case memoryAllocationError
                            success = false;
                            return;
                        otherwise
                            ME.throwAsCaller();
                    end
                end                            
                                
            end
        end        
               
   
    
        function cfgOutputBuffer(obj, numSampsPerChan)
            %Wrapper of DAQmxCfgInputBuffer, which allows the automatic output buffer allocation of DAQmx to be overridden
            %
            %function cfgOutputBuffer(obj, numSampsPerChan)
            %   numSampsPerChan: The number of samples the buffer can hold for each channel in the task. Zero indicates no buffer should be allocated. Use a buffer size of 0 to perform a hardware-timed operation without using a buffer.
            %VECTORIZED
            
            for i=1:length(obj)
                obj.driverCall('DAQmxCfgOutputBuffer', obj.taskID, numSampsPerChan);
            end
        end
    
end

%% ADVANCED FUNCTIONS


%% PROPERTY ACCESS METHODS
methods
         
    function val = setXXXCallbacks(obj,propName,val)
        errMsg = ['Property ''' propName ''' must be a function handle or cell array of function handles'];
        try
            if isa(val,'function_handle')
                val = {val};
            elseif iscell(val)
                %Do nothing to val =
                if ~all(cellfun(@(x)isa(x,'function_handle'),val))
                    error(errMsg);
                end
            elseif isempty(val)
                val = {};
            else
                error(errMsg);
            end
        catch ME
            ME.throwAsCaller();
        end
    end
    
    %TODO: Add set.signalEventCallbacks() and set.doneEventCallbacks(), providing error validation (i.e. ensure string, etc)
    
    function set.everyNSamplesEventCallbacks(obj,val)
        
        %         errMsg = 'Property ''everyNSamplesEventCallbacks'' must be a function handle or cell array of function handles';
        %         if isa(val,'function_handle')
        %             obj.everyNSamplesEventCallbacks = {val};
        %         elseif iscell(val)
        %             if all(cellfun(@(x)isa(x,'function_handle'),val))
        %                 obj.everyNSamplesEventCallbacks = val;
        %             else
        %                 error(errMsg);
        %             end
        %         elseif isempty(val)
        %             obj.everyNSamplesEventCallbacks = {};
        %         else
        %             error(errMsg);
        %         end
        
        
        %         %         if ischar(val)
        %         %             if exist(val,'file')
        %         %                 obj.everyNSamplesEventCallbacks = {val};
        %         %             else
        %         %                 error(generateErrMsg(val));
        %         %             end
        %         %         elseif iscellstr(val) && isvector(val)
        %         %             for i=1:length(val)
        %         %                 if ~exist(val{i},file')
        %         %                     error(generateErrMsg(val{i}));
        %         %                 end
        %         %             end
        %         %             obj.everyNSamplesEventCallbacks = val;
        %         %         elseif isempty(val)
        %         %             obj.everyNSamplesEventCallbacks = {};
        %         %         end
        
        obj.everyNSamplesEventCallbacks = obj.setXXXCallbacks('everyNSamplesEventCallbacks',val);
        
        if isempty(obj.everyNSamplesEventCallbacks) %Unregister if property is set to empty
            obj.registerEveryNSamplesEvent();
            %Register automatically, if possible, every time value is updated. This forces new everyNSamplesEventCallbacks value to take.
        elseif  ~isempty(obj.everyNSamples)
            obj.registerXXXEventPriv('everyNSamples','RegisterEveryNCallback');
        end
        
        %         function errMsg = generateErrMsg(badName)
        %             errMsg = ['''' badName ''' does not specify a valid function on path as required'];
        %         end
    end
    
    function set.doneEventCallbacks(obj,val)
       obj.doneEventCallbacks = obj.setXXXCallbacks('doneEventCallbacks',val);
       
       if isempty(obj.doneEventCallbacks) %Unregister if property is set to empty
            obj.registerDoneEvent();            
       else %Register automatically every time value is updated. This forces new doneEventCallbacks value to take.
            obj.registerXXXEventPriv('done','RegisterDoneCallback');
       end
        
    end
    
    
    function set.signalEventCallbacks(obj,val)
       obj.signalEventCallbacks = obj.setXXXCallbacks('signalEventCallbacks',val);
        
        if isempty(obj.signalEventCallbacks) %Unregister if property is set to empty
            obj.registerDoneEvent();
        elseif ~isempty(obj.signalID) %Register automatically, if possible, every time value is updated. This forces new signalEventCallbacks value to take.
            obj.registerXXXEventPriv('signal','RegisterSignalCallback');
        end
        
    end
    
    function set.signalID(obj,val)
        
        if isempty(val)
            obj.registerSignalEvent(); %Unregisters Signal event, if it has been previously registered
            obj.signalID = '';
            obj.signalIDHidden = [];
        elseif ~ischar(val) || ~isvector(val) || ~ismember(val, {'DAQmx_Val_SampleClock', 'DAQmx_Val_SampleCompleteEvent', 'DAQmx_Val_ChangeDetectionEvent', 'DAQmx_Val_SampleClock', 'DAQmx_Val_CounterOutputEvent'})
            error('Unrecognized ''signalID'' name.');
        elseif ~strcmpi(val,obj.signalID)
            obj.signalID = val;
            obj.signalIDHidden = obj.encodePropVal(val);
            
            %Register automatically, if possible, every time value is updated. This forces new everyNSamples value to take.
            if ~isempty(obj.signalEventCallbacks)
                obj.registerXXXEventPriv('signal','RegisterSignalCallback');
            end
        end        
    end   
    
    function set.everyNSamples(obj,val)
        if isempty(val)
            obj.registerEveryNSamplesEvent(); %Unregisters EveryNSamples event, if it has been previously registered
            obj.everyNSamples = [];
        elseif ~isnumeric(val) || ~isscalar(val) || round(val)~=val || val <= 0
            error('Property ''everyNSamples'' must be a positive scalar integer value');
        elseif isempty(obj.everyNSamples) || val ~= obj.everyNSamples
            obj.everyNSamples = val;
            %Register automatically, if possible, every time value is updated. This forces new everyNSamples value to take.
            if ~isempty(obj.everyNSamplesEventCallbacks)
                obj.registerXXXEventPriv('everyNSamples','RegisterEveryNCallback');
            end
        end
    end
    
    
    function deviceNames = get.deviceNames(obj)
        deviceNames = obj.deviceNamesHidden;
    end
    
    function devices = get.devices(obj)
        devices = Devices.NI.DAQmx.Device.getByName(obj.deviceNames);
    end
    
    function channels = get.channels(obj)
        %TMW: This indirection is used to allow a property to be publically gettable, but only settable by 'friends' or package-mates
        channels = obj.channelsHidden; %Gets a hidden property
    end
    
    function taskType = get.taskType(obj)
        %TMW: This indirection is used to allow a property to be publically gettable, but only settable by 'friends' or package-mates
        taskType = obj.taskTypeHidden; %Gets a hidden property
    end
    
end

%% PROTECTED/PRIVATE METHODS
methods (Access=protected)
    
    function val = getDAQmxPropertyFilterStatus(obj, status, val)
        %Override default class behavior to filter status values that can be more gracefully handled
        
        %Handled errors:
        %   -200478: Specified operation cannot be performed when there are no channels in the task. [Attempt to get property before channels are added]
        %   -200452: Specified property is not supported by the device or is not applicable to the task. [Some properties not applicable to particular task types, e.g. for DI/DO]
        
        %Handle Error -2004
        if ismember(status,[-200478 -200452]) %Error codes to gracefully trap
            val = []; %Use empty vector, regardless of type's natural property
        else %default behavior
            obj.driver.decodeStatus(status);
        end
    end
    
end

methods (Access=private)
    
    function registerXXXEventPriv(obj,eventName,eventRegistrationMethod)
        
        
        flagName = [lower(eventName(1)) eventName(2:end) 'EventRegisteredFlag'];
        
        %If event has been previously registered, then un-register it before re-registering
        if obj.(flagName)
            obj.unregisterXXXEvent(eventName,eventRegistrationMethod); %A bit wasteful, but more elegant to call this
        end

        status = feval(eventRegistrationMethod,obj,true);
        if status
            obj.driver.decodeStatus(status); %throws an error, if found
            obj.(flagName) = false;
        end
        obj.stop();
        obj.(flagName) = true;

        pause(.01); %This seems to be necessary to gurantee that registration takes effect before subsequent start command (if it happens right away)        
    end   
    
            
    function unregisterXXXEvent(obj,eventName,eventRegistrationMethod)
        
        flagName = [eventName 'EventRegisteredFlag'];
        if obj.(flagName)
            obj.(flagName) = false;
            status = feval(eventRegistrationMethod,obj,false); %Calls MEX method that actually does unregistration
            if status
                obj.driver.decodeStatus(status); %throws an error, if found
            end
        end
        
    end
    
    function cfgInputBufferEx(obj, numSampsPerChan, autoReserve)
        %Overrides the automatic output buffer allocation that NI-DAQmx performs.
        %
        %function cfgInputBufferEx(obj, numSampsPerChan, autoReserve)
        %   numSampsPerChan: The number of samples the buffer can hold for each channel in the task. Zero indicates no buffer should be allocated. Use a buffer size of 0 to perform a hardware-timed operation without using a buffer.
        %   autoReserve: (OPTIONAL) Logical value indicating, if true, to automatically reserve the specified number of samples. If needed, the incremental allocation strategy will be attempted to successfully allocate the specified memory.
        %
        %VECTORIZED
        
        %Parse input arguments
        if nargin < 3
            autoReserve = false;
        end
        
        try
            for i=1:length(obj)
                obj(i).driverCall('DAQmxCfgInputBuffer', obj(i).taskID, numSampsPerChan);
                
                if autoReserve
                    status = obj(i).driverCallRaw('DAQmxTaskControl',obj(i).taskID, obj(i).encodePropVal('DAQmx_Val_Task_Reserve'));
                    if status == -50352
                        status = iterativeAllocation(obj(i));
                        if status
                            obj(i).driver.decodeStatus(status); %will throw an error, if any
                        elseif obj(i).verbose
                            disp(['Iterative strategy was required to allocate input buffer for Task ''' obj(i).taskName '''']);
                        end
                    else
                        obj(i).driver.decodeStatus(status); %will throw an error, if any
                    end
                end
            end

        catch ME
            ME.throwAsCaller();
        end
        
        function status = iterativeAllocation(item)
            subBufferFractions = [.6 .7 .8 .9 1];
            
            for j = 1:length(subBufferFractions)
                item.driverCall('DAQmxCfgInputBuffer', item.taskID, numSampsPerChan*subBufferFractions(j));
            end
            status = item.driverCallRaw('DAQmxTaskControl',item.taskID, obj.encodePropVal('DAQmx_Val_Task_Reserve'));
        end
        
    end    
    
end

end


%% HELPERS
%Maintain a list of unique object IDs. Can add or remove objects; or return total # of objects.
%%TMW: Ideally, this could be a static method, but that cannot apparently be called from constructor/destructor, apparently
%Official way to do this is to use a private constructor and static factory method. But I don't like factory methods (I prefer meta-methods, so constructor syntax can be used uniformly for all classes)
function val = maintainObjectIDs(cmd,objID)
persistent objectIDs;
switch cmd
    case 'getCount' %Just return # of objects
        val = length(objectIDs);
    case 'add' %Create a new object ID
        if isempty(objectIDs)
            objectIDs = 1;
        else
            objectIDs = [objectIDs max(objectIDs)+1];
        end
        val = max(objectIDs); %Return the newly created object ID
    case 'remove'
        if nargin < 2
            error('Must specify an object ID for ''remove'' command');
        end
        %Destroy an object ID
        objectIDs(find(objectIDs==objID)) = []; %TODO: Verify that removing 'find' works as expected
        val = length(objectIDs); %Return the # of objects, for good measure
end


end













