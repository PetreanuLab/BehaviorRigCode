classdef LinearStageController < Devices.Interfaces.LinearStageControllerBasic
    %LinearStageController Class encapsulating Scientfica linear stage controller, and associated linear stages, which run under their LinLab software (and its corresponding serial command set)
       
    %TODO: Run through to handle cases where < 3 dimensions are used.
    
    
    %% PSEUDO-DEPENDENT PROPERTIES (Class-Specific)
    %   Used here to provide indirection for direct hardware maintained properties       
    
    properties (SetObservable,GetObservable)               
        current; %2 element array - [stationaryCurrent movingCurrent], specified as values 1-255. Not typically adjusted from default.
    end
    
    properties (SetObservable,GetObservable, Hidden)
        positionUnitsScaleFactor; %These are the UUX/Y/Z properties. %TODO: Determine if there is any reason these should be user-settable to be anything other than their default values (save for inverting). At moment, none can be determined. Perhaps related to steps.
    end
    
    %% OTHER CLASS-SPECIFIC PROPERTIES
    properties
        resetWarning = true; %Logical flag indicating, if true, that a warning should be given prior to executing reset() operations.
    end
    
    properties (Hidden) %TMW: Would prefer that SetAccess=private (or protected), but this prevents superclass from accessing it. Perhaps 'protected' could also allow superclass access?
        defaultCurrent; %Varies based on stage type
        defaultPositionUnitsScaleFactor; %Varies based on stage type. This effectively specifies the resolution of that stage type.
               
        maxVelocityStore;     
    end   
    
    properties (Hidden, Constant)
        defaultVelocityStart=5000; %Default value for /all/ stage types
        defaultAcceleration=500; %Default value for /all/ stage types       
    end
    
    %% ABSTRACT PROPERTY REALIZATIONS
    
    %%%%Abstract properties for sole purpose of allowing props to be (optionally) Hidden%%%%%%%%%%%%%%
    properties (Hidden, SetObservable, GetObservable)
        %Following properties are pseudo-dependent, but also Abstract, so that they may be Hidden
        
        velocityStart; %Scalar or 3 element array indicating/specifying start velocity to use during moves. If multiple resolutionModes are available, value pertains to current resolutionMode.
        acceleration; %Scalar or 3 element array indicating/specifying acceleration to use (between velocityStart and velocity) during moves. If multiple resolutionModes are available, value pertains to current resolutionMode.
    end
    
    properties (Hidden)
        zeroHardWarning=false; %Logical flag indicating, if true, that warning should be given prior to executing zeroHard() operations
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Following are copied/pasted from superclass definition, but with subclass-specific values set/initialized
    %TMW: This is reasonable, as the subclass does need to define/add information here. However, would be nice if documentation string from superclass could be reused, if appropriate (most common case!).
    properties (SetAccess=protected,Hidden)
        devicePositionUnits=1e-7;
        deviceVelocityUnits=nan;
        deviceAccelerationUnits=nan;
        deviceErrorResp = 'E';
        deviceSimpleResp = 'A';
    end
    
    properties (Constant,Hidden)
        moveModes={};
    end
    
    properties (Constant, Hidden)
        hardwareInterface='serial';
        safeReset=false;
        
        %TODO: Consider whether to support case of > 1 stage assembly ... sounds like it's rare for Scientifica stages, as they use virtual COM ports to individuate in most cases.
        maxNumStageAssemblies=1; %Maximum nuber of stage assemblies supported by this controller 
        requiredCustomStageProperties={}; %Cell array of properties that must be set on construction if one or more of the stages is 'custom'
        
        moveCompleteDetectStrategy = 'moveCompleteTimer'; %Use serial asyncReply event on terminator
        moveCompleteStrategy = 'isMovingPoll'; %Can wait for terminator
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = LinearStageController(varargin) 
            % Prop-Value pair args
            %    stageType: (REQUIRED) Specifies type of stage assembly connected to stage controller, e.g. 'patchstar' or 'mmtp'. Names match that specified in LinLab software.
            %    comPort: (REQUIRED) Number specifiying COM port to which linear stage controller is connected
            %    resolution: Resolution, in um, for all dimensions (specified as scalar) or per-dimension (specified as 3 element vector).If not, default resolution associated with specified 'stageType' is used.
            
            %Determine stage type
            pvargs = Programming.Interfaces.VClass.filterPropValArgs(varargin,{'stageType'},{'stageType'});
            stageType = pvargs{2};
            
            %Call superclass constructors %TMW: This is required, because
            %arguments must be passed. Would be nice to avoid, or at least avoid fully specifying class names (as it is done above)          
            obj = obj@Devices.Interfaces.LinearStageControllerBasic(stageType,'availableBaudRates',[9600],varargin{:});
            
            %Initialize serial port properties
            obj.hHardwareInterface.terminatorDefault = 'CR';
            
            %Subclass-specific initialization
            obj.resolution = obj.device2ClassUnits(1 ./ abs(obj.defaultPositionUnitsScaleFactor),'position');  %For Scientifica stages, the device (best) resolution can be determined from the position units           
            obj.velocity = obj.maxVelocity;                  
           
            %Method invoked to (re)initialize property values, applying values to hardware interface
            obj.initializeDefaultValues();             
        end

    end
    
    %% PROPERTY ACCESS METHODS
    
    %%%Pseudo property-access for pseudo-dependent properties
    methods (Access=protected)         
        function pdepPropHandleGetHook(obj,src,evnt)
            propName = src.Name;
            
            switch propName
                case {'positionAbsolute' 'velocity' 'velocityStart' 'acceleration' 'invertCoordinates' 'isMoving' 'limitReached' 'infoHardware' 'current' 'positionUnitsScaleFactor' 'maxVelocity'}
                    obj.pdepPropIndividualGet(src,evnt);                    
                case {'resolutionMode' 'moveMode' 'stageAssemblyIndex'}
                    %Do nothing --> pass-through (shoudl there be a method for this?)
                otherwise %Defer to superclass for default handling (error)
                    obj.pdepPropGetDisallow(src,evnt);
            end
            
        end
        
        function pdepPropHandleSetHook(obj,src,evnt)
            propName = src.Name;
            
            switch propName
                case {'velocity' 'velocityStart' 'acceleration' 'invertCoordinates' 'current' 'positionUnitsScaleFactor'} 
                    obj.pdepPropIndividualSet(src,evnt);
                case {'resolutionMode' 'moveMode'}
                    %Do nothing --> pass-through
                otherwise
                    obj.pdepPropSetDisallow(src,evnt);
            end            
        end
    end
    
    methods (Hidden)              
        
        function val = getPositionAbsolute(obj)
            posn = str2num(obj.hHardwareInterface.sendCommandStringReply('POS'));            
            val = obj.device2ClassUnits(posn,'position');  %Convert to units of class instance
        end
        
        function val = getMaxVelocity(obj)
            val = obj.maxVelocityStore;
        end
        
        function val = getVelocity(obj)
            resp=obj.hHardwareInterface.sendCommandStringReply('TOP');
            
            val=obj.device2ClassUnits(obj.processNumericReply(resp),'velocity');
        end
        
        function setVelocity(obj,val)             
            val=obj.class2DeviceUnits(val,'velocity');
            obj.hHardwareInterface.sendCommandSimpleReply(['TOP ' num2str(val)]);
            
            actVal = obj.velocity;
            if val ~= actVal
                fprintf(2,'WARNING: Actual value differs from set value\n');
            end
        end
        
        function val = getVelocityStart(obj)
            resp = obj.hHardwareInterface.sendCommandStringReply('FIRST');
            val=obj.device2ClassUnits(obj.processNumericReply(resp),'velocity');
        end
        
        function setVelocityStart(obj,val)
            val=obj.class2DeviceUnits(val,'velocity');
            obj.hHardwareInterface.sendCommandSimpleReply(['FIRST ' num2str(val)]);
            
            actVal = obj.velocityStart;
            if val ~= actVal
                fprintf(2,'WARNING: Actual value differs from set value\n');
            end
        end
        
        function val = getAcceleration(obj)
            resp = obj.hHardwareInterface.sendCommandStringReply('ACC');
            val=obj.device2ClassUnits(obj.processNumericReply(resp),'acceleration');
        end
        
        function setAcceleration(obj,val)
            val=obj.class2DeviceUnits(val,'acceleration');
            obj.hHardwareInterface.sendCommandSimpleReply(['ACC ' num2str(val)]);
           
            actVal = obj.acceleration;
            if val ~= actVal
                fprintf(2,'WARNING: Actual value differs from set value\n');
            end
        end
        
        function val = getInvertCoordinates(obj)           
            numDims = obj.numDimensions;
            resp = zeros(1,numDims);
            for i=1:numDims
                resp(i) = obj.processNumericReply(obj.hHardwareInterface.sendCommandStringReply(['UU' obj.dimensionNames{i}]),true);
            end
            val = (resp ./  obj.defaultPositionUnitsScaleFactor) < 0;            
        end
        
        function setInvertCoordinates(obj,val)
            if isscalar(val)
                val = repmat(val,1,3);
            end
            
            for i=1:obj.numDimensions
                obj.hHardwareInterface.sendCommandSimpleReply(['UU' obj.dimensionNames{i} ' ' num2str(-1^(val(i)) * obj.defaultPositionUnitsScaleFactor(i))]);
            end
        end
        
        
        function val = getLimitReached(obj)
            %TODO(5AM): Improve decoding of 6 bit (2 byte) data
            
            resp = obj.hHardwareInterface.sendCommandStringReply('LIMITS');
            
            val = zeros(1,obj.maxNumDimensions);
            
            resp = uint8(hex2dec(deblank(resp)));
                      
            for i=1:obj.maxNumDimensions
                val(i) =  obj.activeDimensions(i) && (bitget(resp,2*i-1) || bitget(resp,2*i));                
            end
            
            %             resp = fliplr(dec2bin(hex2dec(deblank(resp)),6));  %Reply is 6 bits long (assuming 3 dimensions-- hard-coded for now)
            %
            %             for i=1:obj.maxNumDimensions
            %                 val(i) =  obj.activeDimensions(i) && (resp(2*i-1) || resp(2*i));
            %             end
            
        end
        
        function tf = getIsMoving(obj)            
            resp = obj.hHardwareInterface.sendCommandStringReply('S');
            tf = obj.processNumericReply(resp) > 0;
        end
        
        function val = getInfoHardware(obj)
            val = deblank(obj.hHardwareInterface.sendCommandStringReply('DATE'));            
        end
        
        function val = getCurrent(obj)
            resp = obj.hHardwareInterface.sendCommandStringReply('CURRENT');
            val = obj.processNumericReply(resp);
        end
        
        function setCurrent(obj,val)
            obj.hHardwareInterface.sendCommandSimpleReply(['CURRENT ' num2str(val)]);
        end
        
        function val = getPositionUnitsScaleFactor(obj)
            val = zeros(1,obj.numDimensions);
            for i=1:obj.numDimensions
                resp = obj.hHardwareInterface.sendCommandStringReply(['UU' obj.dimensionNames{i}]);
                val(i) = obj.processNumericReply(resp);
            end
        end
        
        function setPositionUnitsScaleFactor(obj,val)
            if isscalar(val)
                val = repmat(val,1,3);
            end
            for i=1:obj.numDimensions
                obj.hHardwareInterface.sendCommandSimpleReply(['UU' obj.dimensionNames{i} ' ' num2str(val(i))]);
            end
        end
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    %% ABSTRACT METHOD IMPLEMENTATIONS
    methods (Access=protected,Hidden)
        
        function zeroHardHook(obj,coords)
            if ~all(coords)
                error('It is not possible to perform zeroHard() operation on individual dimensions for device of class %s',class(obj));
            end            
            obj.hHardwareInterface.sendCommandSimpleReply('ZERO');            
        end
                
        function moveStartHook(obj,targetPosn)                                                                  
            posn = obj.class2DeviceUnits(targetPosn,'position');
            obj.hHardwareInterface.sendCommandSimpleReply(['ABS ' num2str(round(posn))]); %Should get an 'A' reply immediately upon starting move                          
        end
        
        
        function interruptMoveHook(obj)
            obj.hHardwareInterface.sendCommandSimpleReply('INTERRUPT'); %TODO: This does not seem to work -- requires new firmware?
        end
        
        function resetHook(obj)
            %Warn user about reset() operation, if needed            
            if obj.resetWarning
               resp = questdlg('Executing reset() operation will reset the stage controller''s absolute origin and restore default values for speed and current. Proceed?','WARNING!','Yes','No','No');
               if strcmpi(resp,'No')
                   return;
               end
            end
            
            obj.hHardwareInterface.sendCommandStringReply('RESET');
            
            %Restore default values of this class (and specifically for stage type specified on construction)
            obj.initializeDefaultValues();           
        end        
        
    end
    
    methods (Static,Hidden)
        
        function stageTypeMap = getStageTypeMap()
            %Implements a static property containing Map indexed by the valid stageType values supported by this class, and containing properties for each
            
            persistent stageTypeMapStore
            
            if isempty(stageTypeMapStore)
                stageTypeMapStore = containers.Map();
                
                stageTypeMapStore('ums') = struct( ...
                    'maxVelocityStore', 40000, ...
                    'defaultCurrent', [200 100], ...
                    'defaultPositionUnitsScaleFactor', -5.12);
                
                
                stageTypeMapStore('ums_2') = struct( ...
                    'maxVelocityStore', 40000, ...
                    'defaultCurrent', [250 125], ...
                    'defaultPositionUnitsScaleFactor', [-4.032 -4.032 -5.12]);                
                
                stageTypeMapStore('mmtp') = struct( ...
                    'maxVelocityStore', 40000, ...
                    'defaultCurrent', [200 100], ...
                    'defaultPositionUnitsScaleFactor', -5.12);                
                
                stageTypeMapStore('slicemaster') = struct( ...
                    'maxVelocityStore', 40000, ...
                    'defaultCurrent', [200 100], ...
                    'defaultPositionUnitsScaleFactor', -5.12);
                
                stageTypeMapStore('patchstar') = struct( ...
                    'maxVelocityStore', 30000, ...
                    'defaultCurrent', [230 125], ...
                    'defaultPositionUnitsScaleFactor', -6.4);
                
                stageTypeMapStore('patchstar_2') = struct( ...
                    'maxVelocityStore', 30000, ...
                    'defaultCurrent', [250 125], ...
                    'defaultPositionUnitsScaleFactor', -6.4);
                
                stageTypeMapStore('mmsp') = struct( ...
                    'maxVelocityStore', 30000, ...
                    'defaultCurrent', [175 125], ...
                    'defaultPositionUnitsScaleFactor', -5.12);
                
                stageTypeMapStore('mmsp_z') = struct( ...
                    'maxVelocityStore', 30000, ...
                    'defaultCurrent', [175 125], ...
                    'defaultPositionUnitsScaleFactor', -5.12);
                
                stageTypeMapStore('mmbp') = struct( ...
                    'maxVelocityStore', 20000, ...
                    'defaultCurrent', [200 125], ...
                    'defaultPositionUnitsScaleFactor', [-4.032 -4.032 -6.4]);
                
                stageTypeMapStore('imtp') = struct( ...
                    'maxVelocityStore', 40000, ...
                    'defaultCurrent', [175 125], ...
                    'defaultPositionUnitsScaleFactor', -5.12);
                
                stageTypeMapStore('slice_scope') = struct( ...
                    'maxVelocityStore', 20000, ...
                    'defaultCurrent', [200 125], ...
                    'defaultPositionUnitsScaleFactor', [-4.032 -4.032 -6.4]);
                
                stageTypeMapStore('condenser') = struct( ...
                    'maxVelocityStore', 20000, ...
                    'defaultCurrent', [200 125], ...
                    'defaultPositionUnitsScaleFactor', [-4.032 -4.032 -6.4]);
                
                stageTypeMapStore('ivm_manipulator') = struct( ...
                    'maxVelocityStore', 30000, ...
                    'defaultCurrent', [255 125], ...
                    'defaultPositionUnitsScaleFactor', -5.12);
            end
            
            %Return the stored stageTypeMap value
            stageTypeMap = stageTypeMapStore;
        end
        
        
        function resolutionModeMap = getResolutionModeMap()
            %Implements a static property containing Map of resolution multipliers to apply for each of the named resolutionModes
            
            persistent resolutionModeMapStore
            
            if isempty(resolutionModeMapStore)
                resolutionModeMapStore = containers.Map();
                resolutionModeMapStore('default') = 1;
            end
            %Return the stored stageTypeMap value
            resolutionModeMap = resolutionModeMapStore;
        end
        
    end      
    
    
    %% PRIVATE/PROTECTED METHODS
    methods (Access=protected, Static)
        
        function replyArray = processNumericReply(deviceReply,isFloat)
            if nargin < 3 || isempty(isFloat)
                isFloat = false;
            end
            if isFloat
                replyArray = sscanf(deviceReply,'%f'); %TODO: Switch to textscan?
            else
                replyArray = sscanf(deviceReply,'%d'); %TODO: Switch to textscan?
            end
        end      

    end
    
    
end

