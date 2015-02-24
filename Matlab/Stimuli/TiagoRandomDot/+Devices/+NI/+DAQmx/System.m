classdef System <  Devices.NI.DAQmx.private.DAQmxClass
    %System A singleton class encapsulating the DAQmx 'System' -- i.e. global DAQmx properties/methods   
    
    properties
        tasks;        
    end
    
    properties (Dependent)
        channels;
        devices;
    end
    
    %Properties used to handle specifics of getting/setting properties for each DAQmx class
    properties (SetAccess=private, Hidden)
        gsPropRegExp =  '.*DAQmxGetSys(.*)\(\s*(\S*)[\),].*';
        gsPropPrefix = 'Sys';
        gsPropIDArgNames = {};
        gsPropNumStringIDArgs=0;
    end

    %% CONSTRUCTOR/DESTRUCTOR      
    methods 
        %%%TMW: This should be Access=private, but it's not allowed because the superclass destructor is not private or protected. 
        %%%%An abstract superclass delete method should be able to have subclass delete methods with differing access permissions
        function delete(obj)            
            %Remove all Device objects -- this is the level to do it, since no Task knows about Devices on other Tasks 
            devices = Devices.NI.DAQmx.Device.getAll();
            if ~isempty(devices)
                delete(Devices.NI.DAQmx.Device.getAll());
            end
        end 
    end
        
    methods  
        
        %% ADVANCED FUNCTIONS
        function connectTerms(obj, sourceTerminal, destinationTerminal, signalModifiers) 
            %Creates a route between a source and destination terminal. The route can carry a variety of digital signals, such as triggers, clocks, and hardware events.
            %These source and destination terminals can be on different devices as long as a connecting public bus, such as RTSI or the PXI backplane, is available. DAQmxConnectTerms does not modify a task. When connectTerms() runs, the route is immediately reserved and committed to hardware. This type of routing is called immediate routing.
            %
            %function connectTerms(obj, sourceTerminal, destinationTerminal, signalModifiers)
            %   sourceTerminal: The originating terminal of the route. You can specify a terminal name.
            %   destinationTerminal: The receiving terminal of the route. You can specify a terminal name.
            %   signalModifiers: (OPTIONAL) One of {'DAQmx_Val_InvertPolarity','DAQmx_Val_DoNotInvertPolarity'}. If empty/omitted, 'DAQmx_Val_DoNotInvertPolarity' is used. Specifies whether or not to invert the signal routed from the sourceTerminal to the destinationTerminal. If the device is not capable of signal inversion or if a previous route reserved the inversion circuitry in an incompatible configuration, attempting to invert the signal causes an error.                        
            
            if nargin < 4 || isempty(signalModifiers)
                signalModifiers = 'DAQmx_Val_DoNotInvertPolarity';
            end
            
            obj.driverCall('DAQmxConnectTerms',sourceTerminal,destinationTerminal, obj.encodePropVal(signalModifiers));
        end
        
        function disconnectTerms(obj, sourceTerminal, destinationTerminal) 
            %Removes signal routes previously created using DAQmxConnectTerms. DAQmxDisconnectTerms cannot remove task-based routes, such as those created through timing and triggering configuration.
            %When this function executes, the route is unreserved immediately. For this reason, this type of routing is called immediate routing.
            %
            %function disconnectTerms(obj, sourceTerminal, destinationTerminal)
            %   sourceTerminal: The originating terminal of the route. You can specify a terminal name.
            %   destinationTerminal: The receiving terminal of the route. You can specify a terminal name.
            
            obj.driverCall('DAQmxDisconnectTerms',sourceTerminal,destinationTerminal);
        end
     
        function tristateOutputTerm(obj, outputTerminal)
            %Sets a terminal to high-impedance state. If you connect an external signal to a terminal on the I/O connector, the terminal must be in high-impedance state. Otherwise, the device could double-drive the terminal and damage the hardware. If you use this function on a terminal in an active route, the function fails and returns an error.
            %DAQmxResetDevice sets all terminals on the I/O connector to high-impedance state but aborts any running tasks associated with the device.
            %
            %function tristateOutputTerm(obj, outputTerminal)
            %   outputTerminal: The terminal on the I/O connector to set to high-impedance state. You can specify a terminal name.
            %
            
            obj.driverCall('DAQmxTristateOutputTerm', outputTerminal);            
        end
        
        %% SYSTEM CONFIGURATION
        function setAnalogPowerUpStates(obj)
            
        end
        
        function setDigitalLogicFamilyPowerUpStates(obj)
            
        end
        
        function setDigitalPowerUpStates(obj)
            
        end
        
        
    end
    
  
   
    %% STATIC METHODS
    methods (Static)       
        function obj = getHandle()
            %A 'factory' method for getting handle to the ingleton System object
            %This is the de-facto constructor, as the constructor is private
            
            obj = Devices.NI.DAQmx.System.loadOrUnload('load');
        end 
        
        function unload(varargin)
            %User-acessible 'destructor' for (singleton) System object (a 'factory' method) 
            
            Devices.NI.DAQmx.System.loadOrUnload('unload');
        end

        function val = getByName(objectName,varargin)
            
            devObj = Devices.NI.DAQmx.Device.getByName(objectName);
            %taskObj = Devices.NI.DAQmx.Task.getByName(objectName);
            %Get other types of objects                     
            
            objects = {devObj}; 
            goodObjectIdx = find(cellfun(@(x)~isempty(x),objects));
            if length(goodObjectIdx) > 1
                error(['Specified object name ''' objectName ''' cannot be unambiguously resolved']);
            elseif isempty(goodObjectIdx)
                error(['Specified object name ''' objectName ''' not found']);
            else
                val = get(objects{goodObjectIdx},varargin{:});
            end

        end
        
        function updateDriver(obj)
            %Forces DAQmx driver to be reloaded. Should be used, for instance, when DAQmx version has been changed.
            %The object argument need not be supplied.
            
            if nargin < 1
                obj = Devices.NI.DAQmx.System.load();
            end
            if ~isempty(obj) && strcmpi(class(obj),mfilename('class'))
                obj.driver.update();
            else
                error(['Optional input argument must be of class ''' mfilename('class') '''. Command ignored.']);
            end            
        end
        

    end    
    
    %% PRIVATE METHODS
    
    methods (Access=private)             

        function [codeValueMap codeNameMap] = createCodeMaps(obj)
            %Parse header file to obtain all the named integer codes used by DAQmx driver functions, e.g. 'DAQmx_Val_FiniteSamps'
            %Currently computed each time System object is loaded...kind of slow. Consider pre-computing.             
            
            fid = fopen(obj.driverHeader);
            numAttr = 0;
            while feof(fid) ~= 1
                tline = fgets( fid );
                [token,rem] = strtok( tline);
                if strncmpi(token, '#define', 7)
                    [attribute, rem] = strtok(rem);
                    if strncmpi(attribute, 'DAQmx_', 6)
                        
                        [attrCode, rem] = strtok(rem);
                        % if the code is in Hex format
                        if strncmpi(attrCode, '0x', 2)
                            attrCode = hex2dec(strtok(attrCode, '0x'));
                            % in bit shift format
                        elseif strncmpi(attrCode, '(', 1)
                            pat='(?<base>\d+)<<(?<shift>\d+)';
                            res=regexp(attrCode, pat, 'names');
                            attrCode = bitshift(str2num(res.base), str2num(res.shift));
                            % in decimal format
                        else
                            attrCode = str2num(attrCode);
                            % exclude some speical format
                            if isempty(attrCode)
                                continue;
                            end
                        end
                        
                        numAttr = numAttr + 1;
                        codeData{1, numAttr} = attribute;
                        codeData{2, numAttr} = attrCode;                        
                    else
                        continue;
                    end
                else
                    continue;
                end
            end
            
            codeValueMap = containers.Map({codeData{1,:}},{codeData{2,:}});
            codeNameMap = containers.Map({codeData{2,:}},{codeData{1,:}});            
        end           
        
    end
    
    methods (Access=private,Static)        
        function varargout = loadOrUnload(action)
            %This is the real construtor/destructor method, enforcing singleton behavior
            persistent localObj
            
            if isempty(localObj) || ~isvalid(localObj) 
                switch action
                    case 'load' %Create object
                        localObj = Devices.NI.DAQmx.System(); %surpsingly, need to spell out package fully even here
                        varargout{1} = localObj;                  
                    case 'unload' %Nothing to destroy
                        return;
                end                    
            else  %Object already exists
                switch action
                    case 'load' %Si
                        varargout{1} = localObj;
                    case 'unload' %Destroy object
                        delete(localObj);                        
                end
            end
        end
        
    end
    
end


    

