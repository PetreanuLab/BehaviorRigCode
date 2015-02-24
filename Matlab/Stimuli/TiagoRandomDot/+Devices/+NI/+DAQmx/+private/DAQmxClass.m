classdef DAQmxClass < hgsetget & dynamicprops
    %DAQMXCLASS Abstract class representing a generic DAQmx 'class', i.e. a level of DAQmx entity that has Get/Set and other methods, e.g. 'Task', 'Channel', 'Device', etc.
    %
    % TODO: Revisit whether methodNargoutMap is actually needed/useful
    
    properties (SetAccess=private)
        system; %Handle to the singleton System object -- makes this available to end user!
    end
    
    properties (Hidden,SetAccess=private)
        driver; %Handle to the singleton Driver object
        objID; %An objectID that maintains count of unique DAQmxClass objects
    end
    
    properties (Hidden, SetAccess=private, Dependent)
        driverPropMap; %Map of properties and their respective data types for this particular DAQmx class
    end
    
    %Properties used to handle specifics of getting/setting properties for each DAQmx class
    properties (Abstract, SetAccess=private, Hidden)
        gsPropRegExp; %Regular expression used to extract the properties for this particular DAQmx class
        gsPropPrefix; %Prefix before property name used during 'DAQmxGet/Set' calls, for this particular DAQmx class
        gsPropIDArgNames; %Cell array of argument names, specified as names of properties of this object, required for get/set calls for this particular DAQmx class
        gsPropNumStringIDArgs; %Number of string ID arguments, e.g. device or channel name. This is used to determine number of output arguments to discard (becaused shared library interface appends output arguments for every string input argument)
    end
    
    properties (Access=private)
        setPropDirect=false; %Lock var used to allow getting current object property directly, without calling through to DAQmx
        getPropDirect=false; %Lock var used to allow setting current object property directly, without calling through to DAQmx
    end
    
    properties (Access=private,Dependent)
        gsPropIDArgs;
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = DAQmxClass()
            
            %Maintain object ID
            obj.objID = maintainObjectIDs('add'); 
            
            %Bind DAQmx singleton System object to new object (creating it if necessary)
            if strcmpi(class(obj),'Devices.NI.DAQmx.System') %Don't allow infinite recursion! NOTE: This is a case of handling the special case logic in the abstract superclass...not ideal. Should find a better way.
                obj.system = obj;
            else 
                obj.system = Devices.NI.DAQmx.System.getHandle(); %This loads driver DLL, if not done already
            end                
            
            %Bind singleton DAQmx Driver object to new object (for convenience)             
            %obj.driver = Devices.NI.DAQmx.private.Driver.load(); %factory method...returns one-and-only Driver object
            obj.driver = Devices.NI.DAQmx.private.Driver.getHandle(); %factory method...returns one-and-only Driver object
            
            %Add listeners for get/set-observable properties pre-defined for the class (if any)
            mc = metaclass(obj);
            props = mc.Properties;
            observableProps = {};
            for i=1:length(props)
                if props{i}.GetObservable
                    observableProps{end+1} = props{i}.Name; %#ok<AGROW>
                end
            end
            addlistener(obj,observableProps,'PreGet',@obj.getDAQmxProperty);
            addlistener(obj,observableProps,'PostSet',@obj.setDAQmxProperty);
        end
        
        
         function delete(obj)
             %NOTE: Leave commented out for now, as deletion upon exit is more common than explicit deletion
             %              %%TMW: The following works just fine when deletes are called during command-line/script operation
             %              %%However, an error is caused when this delete is invoked automatically at MATLAB's exit (and maybe any automatic invocation, i.e. by garbage collector?)
             %              numIDs = maintainObjectIDs('remove',obj.objID)
             %              if ~numIDs %No more objects left
             %                  %uiwait(msgbox('Removed last DAQmx object','modal'));
             %                  hDriver = Devices.NI.DAQmx.private.Driver.getHandle(true);
             %                  if ~isempty(hDriver)
             %                      delete(hDriver);%Delete the one-and-only Driver object
             %                  end
             %              end
         end
    end
    

    
    %% PROPERTY ACCESS METHODS
    methods
        function map = get.driverPropMap(obj)
            %Computes driverPropMap property value the first time it's needed.
            
            map = Devices.NI.DAQmx.private.DAQmxClass.getClassDriverPropMap(class(obj));
            
            if isempty(map)
                prototypes = libfunctions(obj.driver.driverLib,'-full');
                %varTypes = regexp(prototypes, '.*DAQmxGet(?!(AI|AO|CO|CI|DO|DI|Scale|Sys|Persisted|Cal|Dev|Physical|Switch))(.*)\(ulong,\s*(\S*)[\),].*','tokens','once');
                varTypes = regexp(prototypes, obj.gsPropRegExp, 'tokens','once');
                varTypes(cellfun(@isempty,varTypes)) = [];
                
                %TODO: Deal with handful of channel-related Task variables, which have a compainion property with 'Ex' appended at end
                
                varTypes = cat(1,varTypes{:}); %Concatenate into single Nx2 cell array
                map = containers.Map(varTypes(:,1),varTypes(:,2)); %Convert into Map container
                
                %Store the map
                Devices.NI.DAQmx.private.DAQmxClass.getClassDriverPropMap(class(obj), map); %TMW: So much typing to access a local static method!
            end
        end
        
        function idArgs = get.gsPropIDArgs(obj)
            %Determines arguments to use to identify entity whose property to get/set
            
            idArgs = cell(length(obj.gsPropIDArgNames),1);
            for i=1:length(idArgs)
                idArgs{i} = eval(['obj.' obj.gsPropIDArgNames{i}]); %Use eval' because dynamic property referencing does not allow multiple fields (e.g. 'task.taskID')
            end
        end
        
    end
    
    %% METHODS
    methods
        function outVal = get(obj,varargin)
            % Override hgsetget's default 'get' method to handle case where DAQmx-defined property is requested
            
            %Handle case of array of objects
            if length(obj) > 1
                %outVal = arrayfun(@(x)get(x,varargin),obj);
                for i=1:length(obj)
                    get(obj(i),varargin{:});
                end
                return;
            end
            
            if length(varargin) < 1 || ~ischar(varargin{1}) || ~isempty(findprop(obj,varargin{1}))  %Array first argument, or Cell array second argument not supported (at this time)
                outVal = get@hgsetget(obj,varargin{:}); %Defer to hgsetget (superclass) get method
            else
                %Not a native Class property -- is it a DAQmx Task property?
                
                %Convert to our case standard
                [ourPropName, driverPropName] = deal(varargin{1});
                driverPropName(1) = upper(driverPropName(1));
                
                %Check if it's in the DAQmx property map for this class
                if ~obj.driverPropMap.isKey(driverPropName)
                    outVal = get@hgsetget(obj,varargin{:}); %Defer to superclass method, for now...this will give the usual property-not-found error
                else %Add the property!
                    mp = obj.addprop(ourPropName);
                    mp.GetObservable = true;
                    mp.SetObservable = true;
                    addlistener(obj, ourPropName, 'PreGet', @(src,evnt)getDAQmxProperty(obj,src,evnt));
                    addlistener(obj, ourPropName, 'PostSet', @(src,evnt)setDAQmxProperty(obj,src,evnt));
                    
                    %Now call through to get()
                    outVal = get@hgsetget(obj,ourPropName);
                end
            end
        end
        
        function set(obj,propName,setVal, varargin)
            % Override hgsetget's default 'set' method to handle case where DAQmx-defined property is set
            
            %Handle case of multiple property sets %TODO: Verify this can't be done via deferring to superclass set method (which does handle multiple property sets correctly)
            if ~isempty(varargin) && ~mod(length(varargin),2)
                set(obj,propName,setVal);                 
                for i=1:(length(varargin)/2)
                    set(obj,varargin{2*i-1},varargin{2*i});
                end
            end            
            
            %Handle case of array of objects
            if length(obj) > 1
                %arrayfun(@(x)set(x,propName,setVal),obj); %TODO: Double check this doesn't work
                for i=1:length(obj)
                    set(obj(i),propName,setVal);
                end
                return;
            end          
              
            if ~isempty(findprop(obj,propName))  %Is property already found
                set@hgsetget(obj,propName,setVal); %Defer to hgsetget (superclass) get method
            else
                %Not a native Class property -- is it a DAQmx Task property?
                
                %Convert to our case standard
                [ourPropName, driverPropName] = deal(propName);
                driverPropName(1) = upper(driverPropName(1));
                
                %Check if it's in the DAQmx property map for this class
                if ~obj.driverPropMap.isKey(driverPropName)
                    set@hgsetget(obj,ourPropName,setVal); %Defer to superclass method, for now...this will give the usual property-not-found error
                else %Add the property!
                    mp = obj.addprop(ourPropName);
                    mp.GetObservable = true;
                    mp.SetObservable = true;
                    addlistener(obj, ourPropName, 'PreGet', @(src,evnt)getDAQmxProperty(obj,src,evnt));
                    addlistener(obj, ourPropName, 'PostSet', @(src,evnt)setDAQmxProperty(obj,src,evnt));
                    
                    %Now call through to get()
                    set@hgsetget(obj,ourPropName,setVal);
                end
            end
        end
        
    end
    
    
    %Methods made available all the subclasses
    methods (Access=protected)
        
        function outVal = getQuiet(obj,varargin)
            %A getter which does not add dynamically created properties to the object following the get
            needToDelete = cellfun(@(propName)isempty(findprop(obj,propName)),varargin); %Find properties that didn't exist with object prior to operation
            outVal = get(obj,varargin{:});
            
            for i=1:length(varargin)
                if needToDelete(i)
                    delete(findprop(obj,varargin{i}));
                end
            end
        end
        
        function varargout = driverCall(obj,funcName,varargin)
            %Call 'funcName' with supplied arguments. Status value is not returned to caller; any error reported by driver will result in a Matlab error.
            
            varargout = cell(nargout,1);
            [status, varargout{:}] = obj.driverCallRaw(funcName, varargin{:});
            
            %Handle error       
            obj.driver.decodeStatus(status); %will throw an error if one is found            
        end
        
        function varargout = driverCallFiltered(obj,funcName,ignoreStatusCodes, varargin)
            %Call 'funcName' with supplied arguments. If status value matches one of the 'ignoreStatusCodes', it is ignored; otherwise, any error reported by driver will result in a Matlab error.
            
            %Determine # of output arguments
            outArgs = cell(min(obj.driver.methodNargoutMap(funcName),nargout)+1,1); %add extra argument for 'status'
            
            %Call the DAQmx driver function
            [outArgs{:}] = calllib(obj.driver.driverLib,funcName,varargin{:});
            status = outArgs{1};
            
            
            if ~status || ismember(status,ignoreStatusCodes) %Filter out no-error or ignorable-error cases
                varargout = outArgs(2:end);
            else %handle error 
                obj.driver.decodeStatus(status); %will throw an error 
            end
                
        end
        
        
        
        function [status,varargout] = driverCallRaw(obj,funcName,varargin)
            %Call 'funcName' with supplied arguments. Status code is passed to caller to handle.
            
            %Determine # of output arguments
            outArgs = cell(min(obj.driver.methodNargoutMap(funcName),nargout)+1,1); %add extra argument for 'status'
            
            %Call the DAQmx driver function
            [outArgs{:}] = calllib(obj.driver.driverLib,funcName,varargin{:});
            status = outArgs{1};
            varargout = outArgs(2:end);
        end
        
        function codeVal = encodePropVal(obj,codeName)
            %Extract value for DAQmx driver code name
            
            codeVal = obj.driver.encodePropVal(codeName);
        end
        
        function codeName = decodePropVal(obj,codeVal)
            %Extract name for DAQmx driver code value
            
            codeName = obj.driver.decodePropVal(codeVal);
        end
        
        function val = getDAQmxPropertyFilterStatus(obj, status, val)
           % Method to filter status returned on called to DAQmxGetXXX. Method may be overridden by particular subclasses 
           
           obj.driver.decodeStatus(status); %Throws an error if status ~= 0
        end
        
        function setDAQmxPropertyFilterStatus(obj, status)
            % Method to filter status returned on called to DAQmxSetXXX. Method may be overridden by particular subclasses
            
            obj.driver.decodeStatus(status); %Throws an error if status ~= 0
        end
        
    end
    
    %% PRIVATE METHODS    
    methods (Access=private)
        function getDAQmxProperty(obj, src, evnt)
            %Pre-Get callback for DAQmx-defined property access
            
            if ~obj.getPropDirect
                [ourPropName,devPropName] = deal(src.Name);
                devPropName(1) = upper(ourPropName(1)); %Convert to DAQmx casing convention
                
                %Determine property arguments to use, based on data type of property
                mightNeedDecode = false;
                switch obj.driverPropMap(devPropName)
                    case 'cstring'
                        maxStringLength = 512;
                        propArgs{1} = repmat('a',[1 maxStringLength]); %Al
                        propArgs{2} = maxStringLength;
                    case 'longPtr'
                        mightNeedDecode = true;
                        propArgs{1} = 0;
                    otherwise %A numeric type; definitely not one with a code
                        propArgs{1} = 0; %All other types can be handled by a numeric double type (even if integer-valued)
                end
                
                %Determine number of output arguments, including those to discard
                outArgs = cell(obj.gsPropNumStringIDArgs+1,1);
                
                %Get the property
                [status, outArgs{:}] = obj.driverCallRaw(['DAQmxGet' obj.gsPropPrefix devPropName], obj.gsPropIDArgs{:}, propArgs{:}); %This will throw an error, if DAQmx complains
                val = obj.getDAQmxPropertyFilterStatus(status, outArgs{end}); %By default, this will throw an error if any non-zero status is found
                
                
                %Decode property if needed
                if mightNeedDecode && ~isempty(val)
                    codeName = obj.decodePropVal(val);
                    if ~isempty(codeName)
                        val = codeName;
                    end
                end
                
                %Set property to match what DAQmx returns
                obj.setPropDirect = true;
                set(obj,ourPropName, val);
                obj.setPropDirect = false;
            end
        end
        
        function setDAQmxProperty(obj, src, evnt)
            %Post-set callback for DAQmx-defined property access
            
            if ~obj.setPropDirect
                [ourPropName,devPropName] = deal(src.Name);
                devPropName(1) = upper(ourPropName(1)); %Convert to DAQmx casing convention
                
                %First check if there is a DAQmx setter (i.e. not a read-only property)
                setFuncName = ['DAQmxSet' obj.gsPropPrefix devPropName];
                if ~ismember(setFuncName,libfunctions(obj.driver.driverLib)) %Could maintain a list of all setter functions, to speed this
                    error(['Property ' devPropName ' is read-only. Cannot be set.']);
                end
                
                %Determine value that was set
                obj.getPropDirect=true;
                setVal = get(obj,ourPropName);
                obj.getPropDirect=false;
                
                %Determine if value must be encoded, based on data type of property
                if strcmpi(obj.driverPropMap(devPropName),'longPtr')
                    setValEncoded = obj.encodePropVal(setVal);
                    if ~isempty(setValEncoded)
                        setVal = setValEncoded;
                    end
                    %TODO: Flag cases for which encode fails, to notify that subsequent errors /may/ be due to incorrect spelling of code, etc
                end
                
                
                %Set the property in DAQmx
                try
                    status = obj.driverCallRaw(setFuncName, obj.gsPropIDArgs{:}, setVal);
                    obj.setDAQmxPropertyFilterStatus(status); 
                catch ME
                    %If set fails, set the property to whatever value DAQmx returns
                    obj.setPropDirect = deal(true);
                    set(obj,ourPropName,get(obj,ourPropName)); %Set property back to current DAQmx value (that was not set to anything new)
                    obj.setPropDirect = deal(false);
                    
                    %Display the error message
                    disp(ME.message);
                    return;
                end
            end
        end
               

    end

    %% STATIC  METHODS
    
    methods (Static,Access=private)
        function driverPropMap = getClassDriverPropMap(className, driverPropMap)
            %Function to store and retrieve driverPropMap for each class
            
            persistent driverPropMaps
            
            if isempty(driverPropMaps)
                driverPropMaps = containers.Map();
            end
            
            if nargin > 1 %Store supplied driverPropMap
                driverPropMaps(className) = driverPropMap;
                return;
            else
                if driverPropMaps.isKey(className)
                    driverPropMap = driverPropMaps(className);
                else
                    driverPropMap = containers.Map(); %Return an empty map
                end
            end
        end
    end
    
    
    
end

%% HELPERS
%Maintain a list of unique object IDs. Can add or remove objects; or return total # of objects.
%%%TMW: Ideally, this could be a static method, but that cannot apparently be called from constructor/destructor, apparently
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




