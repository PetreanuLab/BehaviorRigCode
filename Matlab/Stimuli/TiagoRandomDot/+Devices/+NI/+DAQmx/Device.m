classdef Device < Devices.NI.DAQmx.private.DAQmxClass
    %DEVICE Class encapsulating a DAQmx device
    
    properties
        deviceName='';
        %rawDataClassAO=''; %MATLAB type corresponding to data type used by device for raw Analog write operations
    end
    
    %Properties used to handle specifics of getting/setting properties for each DAQmx class
    properties (SetAccess=private, Hidden)
        gsPropRegExp = '.*DAQmxGetDev(.*)\(\s*cstring,\s*(\S*)[\),].*'; 
        gsPropPrefix = 'Dev'; 
        gsPropIDArgNames = {'deviceName'};
        gsPropNumStringIDArgs=1;
    end
   
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = Device(deviceName)      
            if nargin
                %Check if object with this device name already exists
                obj = getDevice(lower(deviceName),obj); %Adds object-in-construction (if it's needed) to objectMap
                if ~isvalid(obj) %Object-in-construction not needed
                    obj = getDevice(lower(deviceName)); %Point to already existing object with this device name
                    return;
                end
                
                obj.deviceName = deviceName;
            end           
        end
        
        %function delete(obj)
        %end
        
    end
    
    %     %% PROP ACCESS METHODS
    %     methods
    %
    %         function classString = get.rawDataClassAO(obj)
    %
    %             %NOTE: Assuming that all devices of a given class use the same data ordering forma
    %             deviceCategory = get(obj,'productCategory');
    %
    %             switch (deviceCategory)
    %                 case 'DAQmx_Val_MSeriesDAQ'
    %                     classString = 'int16'; %Guess
    %                 case 'DAQmx_Val_ESeriesDAQ'
    %                     classString = 'int16'; %Guess
    %                 case 'DAQmx_Val_SSeriesDAQ'
    %                     classString = 'int16'; %Guess
    %                 case 'DAQmx_Val_BSeriesDAQ'
    %                     classString = 'double';
    %                 case 'DAQmx_Val_USBDAQ'
    %                     classString = 'double';
    %                 case 'DAQmx_Val_AOSeriesDAQ'
    %                     classString = 'double';
    %                 otherwise
    %                     classString = 'double';
    %             end
    %
    %             if strcmpi(classString,'double')
    %                 warning(['Class of raw data for device ''' obj.deviceName ''' is unknown. Will only allow data of format ''double'' to be written.']);
    %             end
    %
    %         end
    %     end

    %% PRIVATE/HIDDEN METHODS

    methods (Static, Hidden)        
        function objArray = getAll()
            %Return all valid objects of this class
            objArray = getDevice(); 
        end
        
        function val = getByName(deviceName)
            %Return Device object for each unique deviceName specified
            
            if ischar(deviceName)
                deviceName = {deviceName};
            elseif iscellstr(deviceName)
                deviceName = unique(deviceName);
            else
                error('Argument must be a string or cell array of strings');
            end           
                      
            for i=1:length(deviceName)
                val(i) = getDevice(deviceName{i});  %#ok<AGROW>
            end
        end
    end

    
end

%% Helper Functions

function obj = getDevice(deviceName,obj)
%Function allows Device objects to be stored and retrieved by unique deviceName values
persistent objectMap

if isempty(objectMap)
    objectMap = containers.Map();
end

%If no arguments --> return all devices
if ~nargin
    keys = objectMap.keys();
    obj = Devices.NI.DAQmx.Device.empty();
    for i=1:length(keys)
        nextObj = getDevice(keys{i});
        if ~isempty(nextObj)
            obj = [obj nextObj]; %#ok<AGROW>
        end
    end
    return;
end

if objectMap.isKey(lower(deviceName))
    if nargin > 1 %Constructor case
        delete(obj); %Signal that object-in-construction is not needed
    else   
        obj = objectMap(lower(deviceName));
        if ~isvalid(obj) %Object's been deleted -- refresh Map
            objectMap.remove(lower(deviceName));
            obj = Devices.NI.DAQmx.Device.empty();
        end
    end
else
    if nargin > 1 %Constructor case
        objectMap(lower(deviceName)) = obj; %Add object-in-construction to objectMap
    else
        obj = Devices.NI.DAQmx.Device.empty();
    end
end

end



