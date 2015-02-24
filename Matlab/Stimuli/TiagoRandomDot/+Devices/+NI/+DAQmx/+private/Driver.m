classdef Driver < hgsetget
    %DRIVER Singleton class encapsulating the DAQmx driver. Instantiated when any other DAQmx class is insantiated for first time.
    %
    % TODO: Revisit whether methodNargoutMap is actually needed/useful

  
    
    properties 
        codeValueMap; %Map keyed by DAQmx code 'names', e.g. 'DAQmx_Val_FiniteSamps'
        codeNameMap; %Map keyed by DAQmx code values, e.g. 10178
        methodNargoutMap; %Map keyed by DAQmx function names, containing number of output arguments for each function, not including 'status'
        
        versionNumber; %Version of DAQmx driver encapsulated
    end

    properties (Constant)        
        %driverHeaderFile = 'C:\Program Files\National Instruments\NI-DAQ\DAQmx ANSI C Dev\include\NIDAQmx.h';
        driverLib = 'nicaiu';
        dataFileName = 'DriverData.mat';       
        driverPrettyName = 'NI DAQmx Driver';
    end
    
    properties (Constant, Hidden)
        minUniqueCode = 10000; %Minimum value of unique integer codes that are associated with this driver.
        dataFileFields = {'codeValueMap' 'codeNameMap' 'methodNargoutMap' 'versionNumber'};
        supportedVersions = {'9.0' '8.9.5' '8.9' '8.8'};
        driverHeaderFilenames = {'NIDAQmx_9_0.h' 'NIDAQmx_8_9_5.h' 'NIDAQmx_8_9.h' 'NIDAQmx_8_8.h'};
    end
        
    properties (Dependent)
        driverLibFile;
        driverHeaderFile;
        dataFullFileName;
    end

    %% CONSTRUCTOR/DESTRUCTOR
    
    methods (Static)
        function obj = getHandle(getOnly)
            %A 'factory' method for getting handle to the Singleton Driver object
            %This is the de-facto constructor, as the constructor is private
            
            persistent localObj
            
            %Return existing object if it exists
            if ~isempty(localObj) && isvalid(localObj)
                obj = localObj;
                return;
            elseif nargin && getOnly %Suppress construction if getOnly is true
                %obj = eval([mfilename('class') '.empty()']); %%TMW: It should not be this difficult to return an empty version of the class being defined!
                obj = [];
            else
                localObj = feval(mfilename('class')); %Actually construct the object %%TMW: Weird that I can't acess the constructor from within the class
                obj = localObj;
            end
        end
        
        
    end
    
    methods (Access=private)          
        
        function obj = Driver()
            
            %Update the driver data file, if needed
            if ~exist(obj.dataFullFileName,'file')
                if ~obj.driverDataUpdate() %This loads header file and data, and loads the library as well
                    delete(obj);
                    return;
                end                
            else  
               
                %Load properties from file
                fileProps = obj.dataFileFields;
                foundFileProps = who('-file',obj.dataFullFileName);
                if ~isempty(setdiff(fileProps,foundFileProps)) %Some properties weren't found
                    if ~obj.driverDataUpdate(); %Update en masse
                        delete(obj);
                        return;
                    end
                else
                    %A silly two-step
                    structVar = load(obj.dataFullFileName, fileProps{:});
                    for i=1:length(fileProps)
                        obj.(fileProps{i}) = structVar.(fileProps{i});
                    end
                end
                                                
                %Load the NI DAQmx DLL, if needed              
                obj.smartLoadLibrary();
            end
        end
        
    end
    
    methods
        %NOTE: We leave commented out for now, since deletion upon exit is much more common than explicit deletion
        %         function delete(obj)
        %             %Unloads the driver library
        %             %%%TMW: The following works fine when delete is invoked at command line or script (whether directly or indirectly)
        %             %%%However, a segmentation violation occurs when delete is invoked at Matlab exit (or perhaps any automatic invocation by garbage collector)
        %
        %             %             if libisloaded(obj.driverLib)
        %             %                 unloadlibrary(obj.driverLib);
        %             %             end
        %         end
    end
    
    %% PROP ACCESS METHODS
    methods
        function driverLibFile = get.driverLibFile(obj)
            driverLibFile = [obj.driverLib '.dll'];
        end
        
        function dataFullFileName = get.dataFullFileName(obj)
            dataFullFileName = fullfile(fileparts(mfilename('fullpath')),obj.dataFileName);            
        end
        
        function driverHeaderFile = get.driverHeaderFile(obj)
            
            [tf,idx] = ismember(obj.versionNumber, obj.supportedVersions); %#ok<ASGLU>
            if idx              
                mfilepath = fileparts(mfilename('fullpath'));
                driverHeaderFile = fullfile(mfilepath,obj.driverHeaderFilenames{idx});
            else
                error('Version of driver not yet determined. Cannot select header. Should not occur: programming logic error.');                 
            end
            
        end
    end
    
    %% ACTION METHODS    
    methods 
        
        function codeVal = encodePropVal(obj,codeName)
            %Extract value for DAQmx driver code name
            
            if obj.codeValueMap.isKey(codeName)
                codeVal = obj.codeValueMap(codeName);
            else
                codeVal = [];
            end
        end
        
        function codeName = decodePropVal(obj,codeVal)
            %Extract name for DAQmx driver code value
            
            if obj.codeNameMap.isKey(codeVal)
                codeName = obj.codeNameMap(codeVal);
            else
                codeName = '';
            end
        end
        
                
        
        function decodeStatus(obj, status)

            persistent dummyString
            
            %Handle error, if found
            if status
                if isempty(dummyString)
                    dummyString = repmat('a',[1 512]); %Allows error strings up to 512 character
                end
                [err,errString] = calllib(obj.driverLib,'DAQmxGetErrorString',status,dummyString,length(dummyString));
                ME = MException(['DAQmx:E' num2str(abs(status))],'DAQmx ERROR(%d): %s\n', status, errString); %TMW: Alphanumeric restrictions on MException 'identifier' are annoying
                ME.throwAsCaller();
            end
        end
        
        
    end
    
    methods (Access=private)
                
        function ok = driverDataUpdate(obj)   
            
            %Determine driver version
            [selection,ok] = listdlg('ListString',obj.supportedVersions, 'SelectionMode','single','ListSize',[160 160],'Name','Driver Version','PromptString','Select the installed DAQmx version');
            if ok
                try 
                    disp('Updating DAQmx driver data....');
                    
                    obj.versionNumber = obj.supportedVersions{selection};
                   
                    %Unload library, if previously loaded
                    if libisloaded(obj.driverLib)
                        unloadlibrary(obj.driverLib);
                    end
                    
                    %Load the library 
                    obj.smartLoadLibrary();
                    
                    %Determine code Maps
                    codeData = parseCodeData(obj.driverHeaderFile); %Returns a Nx2 cell array of code names (column 1) and code values (column 2)
                    obj.codeValueMap = containers.Map({codeData{1,:}},{codeData{2,:}}); %Map of value associated with all strings (some values are redundant, and are used as inputs to functions, but not as properties)
                    
                    codeData(:,[codeData{2,:}] < obj.minUniqueCode) = []; %Remove all values below 10000
                    obj.codeNameMap = containers.Map({codeData{2,:}},{codeData{1,:}});  %Map of (unique) strings associated with all values above 10000
                    
                    %Determine nargout for each function
                    prototypes = libfunctions(obj.driverLib, '-full');
                    tokens = regexp(prototypes,'(.*)\s*(DAQmx\w*)\(.*','tokens','once'); %Captures the output arguments of each function
                    tokens(cellfun(@isempty,tokens)) = []; %Shouldn't be any of these!
                    tokens = cat(1,tokens{:}); %Creates Nx2 cell array
                    outArgs = tokens(:,1);
                    funcNames = tokens(:,2);
                    outArgs = regexp(outArgs,'long(.*)','tokens','once'); % A cell array of cell arrays, each containing 2 elements: the first containing the void* argument and the second the comma-delimited list of remaining arguments
                    numOutArgs = cellfun(@(x)length(strfind(x{1},',')),outArgs);
                    
                    obj.methodNargoutMap = containers.Map(funcNames',num2cell(numOutArgs')); %#ok<STRNU>
                    
                    %Save variables to file
                    warning('off','MATLAB:structOnObject');
                    tempStruct = struct(obj); %#ok<NASGU> %Have to create a struct, since save won't take an object directly
                    warning('on','MATLAB:structOnObject');
                    save(obj.dataFullFileName,'-struct','tempStruct',obj.dataFileFields{:});
                    
                catch ME
                    ok = false; 
                    disp(['ERROR parsing driver header file data: ' ME.getReport()]);
                end
            end
        end
        
        function smartLoadLibrary(obj)
            %Loads driver library with options providing best performance
            
            if ~libisloaded(obj.driverLib)
                disp([obj.driverPrettyName ': Loading... (may take a few seconds)']);
                warning('off','MATLAB:loadlibrary:parsewarnings');
                feature accel off %Recommended following service request 1-C76DED
                loadlibrary(obj.driverLibFile,obj.driverHeaderFile);
                feature accel on
                warning('on','MATLAB:loadlibrary:parsewarnings');
            end
        end

        
    end   
    
    
    %% STATIC METHODS
    methods (Static)
        function update()
            %Function to force a Driver update
            obj = Devices.NI.DAQmx.private.Driver.getHandle();
            obj.driverDataUpdate();
        end
    end
    
    
    
end
    
%% HELPERS
function codeData = parseCodeData(headerFile)
fid = fopen(headerFile);
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





end


