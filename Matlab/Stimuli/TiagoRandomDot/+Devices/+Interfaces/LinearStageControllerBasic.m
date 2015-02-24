classdef LinearStageControllerBasic < Programming.Interfaces.VClass
    %LINEARSTAGECONTROLLERBASIC Abstract superclass representing general basic linear stage controller device, controlling one or more linear stage assemblies, each containing up to 3 linear stages (one per physical dimension)
    %
    %% NOTES
    %   3 types of move operations are supported (i.e. implemented by all subclasses): moveComplete(), moveStart(), and moveStartCompleteEvent()
    %   Some devices may have different move 'modes', which is specified by the moveMode property.
    %   Some devices may have different resolution 'modes', specified by resolutionMode property.
    %   A 'two-step' move option is allowed for so that moves are carried out in two steps, with a velocity/moveMode/resolutionMode triad set for each step
    %
    %   'Custom' stage capability was added, in a per-dimension manner, but this is not actually used/supported at this time. -- Vijay Iyer 3/16/10
    %
    %   This class nominally supports multiple stage assemblies, but this has not been used/vetted -- some issues remain. For instance, currently there is no provision for stageType per stage assembly. -- Vijay Iyer 3/28/10
    %
    %   TODO: Handle automatic setPositionVerify for async reply in manner that deals with error appropriately (since it occurs in a callback)
    %   TODO: Perhaps make moveCompleteTimer period a public property
    %   TODO: Consider using genericErrorHandler() scheme akin to RS232DeviceBasic, that resets all flag variables following error.
    %   TODO: Consider whether cleanupAsyncMove code should be moved outside of moveStartHidden() nested function, so that it can be shared with handleErrorCondReset() 
    %
    %% CHANGES
    %   VI040510A: Added handleErrorCondReset(), which basically does an asyncMoveCleanup operation, since async move cruft often remains from previous errors -- Vijay Iyer 4/5/10
    %
    %% CREDITS
    %   Created originally February 2010, by Vijay Iyer
    %% ******************************************************************
    
    %%%Properties user-settable only via constructor %%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess=protected)
        activeDimensions=[1 1 1]; %3 element array of logicals indicating which of the physical dimensions X, Y, and Z - in that order - are controlled by this stage controller instance
        stageType; %String specifying stage type used for all of the active dimensions, or 3-element string cell array specifying stage type per-axis (empty strings for any inactive dimensions). Can specify 'custom' for one or more stages, which often requires that some properties be initialized on construction. See 'requiredCustomStageProperties'.
    end
    
    properties (SetAccess=protected,Hidden)
        %Following are often/generally set by default values for stages, but can be overridden if specified on construction
        resolution; %Scalar or 3 element per-dimension array containing smallest size move, in units specified by positionUnits, supported by device in each dimension.
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        setPositionVerifyAutomatic=false; %Logical value indicating, if true, that position is read automatically at end of moveComplete() calls and when moveComplete event occurs for moveStartCompleteEvent() calls.
        setPositionVerifyAccuracy=0; %Scalar, or 3 element per-dimension array, containing difference between intended and obtained position in positionUnits above which an error will be thrown. Note if resolutionCurrent value is higher, than that difference will be used as error threshold instead.
        %setPositionVerifyManual=false; %Logical value indicating, if true, that verification of set position should occur manually, by calling the verifySetPosition() method, rather than automatically as part of a set position command
        setPositionVerifyAccuracyPerDimension=true; %Logical value indicating, if true, that setPositionVerifyAccuracy is applied per-dimension, i.e. each dimension must fall within specified accuracy. Otherwise, accuracy pertains to vectorial distance between target and actual position.
        
        %These represent the behavior implemented now by default in ScanImage. Only applies for moveComplete() operations at this time.
        twoStepMoveEnable=false; %Logical value indicating, if true, that large moveComplete() operations are done in two steps, with the second 'slow' step using one or more distinct properties (velocity, resolutionMode, moveMode, setPositionVerifyAutomatic) distinct from first step. 
        twoStepMoveSlowDistance; %If specified, value gives a distance threshold, in units given by positionUnits, below which moves with twoStepMoveEnable=true will be done in only one step (using the 'slow' step). Moves above that threshold will will be done in two steps.
        twoStepMoveSlowVelocity; %Value specifying velocity to use when within range of twoStepMoveSlowDistance.
        twoStepMoveSlowSetPositionVerifyAutomatic; %Logical value specifing whether setPositionVerifyAutotomatic should be in force during final step of two step moves.
        twoStepMoveSlowResolutionMode=''; %Value specifying resolutionMode to use when with range of twoStepMoveSlowDistance. Must be one of available resolutionModes.
        twoStepMoveSlowMoveMode=''; %Value specifying moveMode to use when with range of twoStepMoveSlowDistance. Must be one of available moveModes.
        twoStepMoveInProgress=false; %Logical value indicating, if true, that an event-driven two step move is in progress. %ADDED BY DEQ
        twoStepMoveTarget=[];%Value specifying the target position for an event-driven two step move. %ADDED BY DEQ
        
        moveTimeout=inf; %Time, in seconds, to allow for moveCompleteXXX() operations before generating a timeout error
        asyncMoveTimeout=inf; %Time, in seconds, to allow for asynchronous move operations (moveStartXXX() and moveStartCompleteEventXXX() operations) before generating error
        
        blockOnError=true; %Logical indicating, if true, that pertinent commands should be blocked when an error condition has been detected and not reset. %TODO(5AM): SKIP - Consider actually implementing this. Requires that all pertinent methods, including for property access, be wrapped into m
        autoInterruptAsyncMoveOnError=true; %Logical indicating, if true, that any pending asynchronous moves will be 
        %autoRecover=false; %Logical indicating, if true, that recover() operation should be automatically attemped when error condition has been set
    end
    
    properties (SetAccess=private)
        zeroSoftFlag=[false false false]; %Flag indicating, for each dimension, if a successful zeroSoft() operation has been applied since object was constructed
    end      
    
    properties (SetAccess=private, Dependent)
        positionRelative; %3 element array indicating position in relative coordinates, relative to 'soft' origin stored by this class. Unless/until zeroSoft() is used, this value equals positionAbsolute.
    end       
    
    properties (Hidden)
        moveCompletePauseInterval=0.01; %Time in seconds to give to pause() command for tight while loop used in moveComplete() method. Only applies if moveCompleteStrategy='isMovingPoll'.
        moveWaitForFinishPauseInterval=0.01;  %Time in seconds to give to pause()/pauseTight() command for tight while loop used in moveWaitForFinish() method.
        moveWaitForFinishPauseTight=false; %Logical indicating, if true, to use pauseTight() command, in lieu of built-in pause() command in moveWaitForFinish().
    end

    
    
    %% PSEUDO-DEPENDENT PROPERTIES
    %Pseudo-dependent properties is a convention used employing Set/GetObservable attributes in a manner allowing superclass to define default get/set actions and subclasses to override these.
    %TMW: It might be preferable if these properties were Dependent and property access methods used, but those do not support inheritance
    %TMW: Would be nice to have option to make these selections of these properties Hidden in subclasses, i.e. those for which they're not relevant -- /without/ making them into Abstract properties. (or if an abstract property, at least with 'documentation inheritance').
    
    properties (SetObservable,GetObservable)
        
        positionAbsolute; %3 element array indicating position in absolute coordinates, i.e the coordinates maintained by device firmware.

        
        stageAssemblyIndex=1; %Integer specifying index of stage assembly currently addressed by this controller. Cannot exceed maxNumStageAssemblies.
        
        moveMode; %String indicating which of the devices's moveModes is currently in effect. If only one mode is supported, this will always be 'default'
        resolutionMode; %String indicating which of the device's named resolutionModes is currently in effect. If only one mode is supported, this will always be 'default'
        velocity; %Scalar or 3 element array indicating/specifying velocity. If multiple resolutionModes are available, value pertains to current resolutionMode.
        invertCoordinates; %Scalar, or 3 element per-dimension array, logical value(s) specifying, if true, to invert position reported in specified dimension(s)
        
        %%%FOllowing are read-only -- they will defer to VClass default setter
        %TMW: Would prefer to make this SetAccess=protected, but that precludes access by a named /super/ class -- can there be a version of protected that allows this? Alternatively a 'friend' concept. Take back my comment from the meeting..package scope is not enough.
        
        maxVelocity; %Scalar or 3 element per-dimension array containing maximum value that can be set for velocity, in units specified by velocityUnits (if deviceVelocityUnits~=NaN).
        
        infoHardware; %String providing information about the hardware, e.g. firmware version, manufacture date, etc. Information provided is specific to each device type.
        isMoving; %Logical indicating, if true, that stage is currently moving
        limitReached; %3 element per-dimension array of logical values specifying, if true, that stage in given dimension(s) has reached end-of-travel limit
    end

    
    %% ABSTRACT PROPERTIES
    
    properties (GetAccess=protected,Constant)
        setErrorStrategy = 'leaveErrorValue';
    end   
    
    %Abstract properties MUST be realized in subclasses, generally by copy/pasting these property blocks (sans 'Abstract', with subclass-specific constant/initial values as needed, and possibly with Hidden attribute added/removed), into each concrete subclass.
    %TMW: For case where subclasses are defining subclass-specific constant or intial values, this is reasonable. But documentation inheritance would be nice.
    properties (Abstract, SetAccess=protected, Hidden)
        devicePositionUnits; %Units, in meters, in which the device's position values (as reported by its hardware interface) are given
        deviceVelocityUnits; %Units, in meters/sec, in which the device's velocity values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        deviceAccelerationUnits; %Units, in meters/sec^2, in which the device's acceleration values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        deviceErrorResp;
        deviceSimpleResp;
    end
    
    properties (Abstract, Constant, Hidden)  %TMW: Combination of 'Abstract' and 'Constant' in superclass works (as it well should), but documentation would suggest otherwise.
        hardwareInterface; %One of {'serial'}. Indicates type of hardware interface used to control device. NOTE: Other hardware interface types may be supported in the future.
        safeReset; %Logical indicating, if true, that reset() operation (if any) should be considered safe backup to recover() operation, if former fails or doesn't exist. 'Safe' implies that operation has no side-effects and that motor operation can continue following reset() in same state as existed prior to error condition.
        
        maxNumStageAssemblies; %Maximum nuber of stage assemblies supported by device                
        requiredCustomStageProperties; %Cell array of properties that must be set on construction if one or more of the stages is 'custom'
        
        %Identifies strategy that subclass uses to signal move complete event on moveStartGenerateEvent() operations (and moveStart() operations, with twoStepMoveEnable=true and active)
        %   'moveStartCompleteEventHook': Subclass implements moveStartCompleteEventHook() method and handles these operations itself
        %   'hardwareInterfaceEvent': Appropriate underlying hardware interface (e.g. RS232DeviceBasic) 'asyncReplyEvent' event will be used
        %   'moveCompleteTimer': A Matlab timer object maintained by this class will periodically poll the isMoving property to determine if move has completed.
        moveCompleteDetectStrategy; %One of {'moveStartCompleteEventHook','hardwareInterfaceEvent','moveCompleteTimer'}.
        
        %Identifies strategy that subclass uses to determine that move has completed during moveComplete() operations
        %   'moveCompleteHook': Subclass implements moveCompleteHook() method which handles moveComplete() operations
        %   'isMovingPoll': The isMoving property will be polled in a tight loop until the move has completed
        moveCompleteStrategy; %One of {'moveCompleteHook','isMovingPoll'}        
    end

    properties (Abstract, Constant)
        moveModes; %Cell array of possible moveModes for particular subclass device type. If only one type of move is supported, mode is 'default'.
    end
    
    %%%%%%%Following are Abstract only for purpose of allowing subclasses to override the Hidden attribute.
    %TMW: Would be nice if there were a) another mechanism to add/remove Hidden attribute based on class or b) some documentation inheritance, so documentation string need not be copy/pasted
    
    properties (Abstract)
        zeroHardWarning; %Logical flag indicating, if true, that warning should be given prior to executing zeroHard() operations
    end
    
    properties (Abstract, SetObservable, GetObservable)
        %Following properties are pseudo-dependent, but also Abstract, so that they may be Hidden
        %TMW: Would be nice to have option to make these selections of these properties Hidden in subclasses, i.e. those for which they're not relevant -- /without/ making them into Abstract properties. Being Abstract a) requires excessive copy/past, including of doc string, and b) prevents property set method from being specified
        
        velocityStart; %Scalar or 3 element array indicating/specifying start velocity to use during moves. If multiple resolutionModes are available, value pertains to current resolutionMode.
        acceleration; %Scalar or 3 element array indicating/specifying acceleration to use (between velocityStart and velocity) during moves. If multiple resolutionModes are available, value pertains to current resolutionMode.
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    
    %% PRIVATE/PROTECTED PROPERTIES
    properties (SetAccess=protected)
        hHardwareInterface; %Handle to hardware interface which this device complies to. Type depends on 'hardwareInterface'.
        
        resolutionModes; %Cell array of possible resolutionModes for particular subclass device type
        resolutionCurrent; %Specifies resolution, minimum movement size in each dimension specified in positionUnits, that is in force with current resolutionMode
        
        relativeOrigin=[0 0 0]; %3 element array indicating position, in absolute coordinates, stored by this class that serves as current relative origin. Values of 0 indicate that no relative origin is specified for given coordinate.
    end       
    
    properties (SetAccess=protected,Hidden)
        stageTypeMap; %Map containing property intializations for each of the stage types supported by subclass controller
        resolutionModeMap; %Map containing resolution multipliers for each of the named resolutionModes
        
        numDimensions; %Specifies number of dimensions supported by stages controlled by this class
        setPositionVerifyPositionStore; %Stored position, in absolute coordinates, that was last specified in a position-set command
               
        asyncMovePending=false; %Flag indicating if an async move is in progress
        asyncMoveTimeReference; %Time reference, obtained via tic(), of start of async move

        twoStepMovePropertyStore; %A containers.Map object used to cache property        
    end
    
    properties (Constant, Hidden)
        maxNumDimensions=3; %Maximum number of dimensions per stage assembly
        dimensionNames={'X' 'Y' 'Z'}; %Cell array of elements 'X', 'Y', and 'Z', specified in order in which they appear in other properties
        positionUnits=1e-6; %Value specifying, in meters, the physical units (if available) in which 'resolution' and 'position' properties are specified by this class
        velocityUnits=1e-6; %Value specifying, in meters/sec, the physical units (if available) in which velocity property(s) are specified by this class
        accelerationUnits=1e-6; %Value specifying, in meters/sec^2, the physical units (if available) in which acceleration property(s) are specified by this class
                
        %Properties which can be overridden for second and/or slow step when two-step move is enabled
        %NOTE: Order of this list is order in which properties are set in changing between fast/slow set of properties. This order works for all known subclasses at this time. -- Vijay Iyer 3/20/10        
        twoStepMoveProperties = {'moveMode' 'resolutionMode' 'velocity' 'setPositionVerifyAutomatic'};  
    end
    
    
    %% EVENTS
    events (NotifyAccess=protected)
        moveCompleteEvent;
    end
    
    events (NotifyAccess=protected, ListenAccess=protected)
        moveCompleteDetect; %Must be generated by concrete subclass in some manner, when 'moveStartCompleteEventHook' is the moveCompleteDetectStrategy
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        
        function obj = LinearStageControllerBasic(stageType,varargin)
            %import Programming.Utilities.*
            
            %Add listener to superclass-generated event
            addlistener(obj, 'errorCondReset',@obj.handleErrorCondReset);
            
            %Initialize 'static properties'
            obj.stageTypeMap = obj.getStageTypeMap();
            obj.resolutionModeMap = obj.getResolutionModeMap();
            
            
            %Determine number of active dimensions
            pvargs = obj.filterPropValArgs(varargin,{'activeDimensions'});
            if ~isempty(pvargs) %TMW: Annoying this can't be done via abstract superclass or separate function for private/protected properties
                obj.set(pvargs(1:2:end),pvargs(2:2:end));
            end
            
            %Handle multi-stage-assembly possibility
            if obj.maxNumStageAssemblies > 1
                pvargs = obj.filterPropValArgs(varargin,{'stageAssemblyIndex'});
                if ~isempty(pvargs) %TMW: Annoying this can't be done via abstract superclass or separate function for private/protected properties
                    obj.set(pvargs(1:2:end),pvargs(2:2:end));
                end
            end
            
            %Initialize stage type, handling possibility of custom stages
            %NOTE: The 'custom' stage possibility is largely unused at this time; biggest application is MP-285 and mainly this is handled by initializing the 'resolution' property on construction
            obj.stageType = stageType;
            if ischar(stageType)
                if strcmpi(stageType,'custom') %all active dimensions are custom
                    customDimensions = find(obj.activeDimensions);
                    initializedStageType = [];
                else
                    customDimensions = [];
                    initializedStageType = stageType;
                end
            elseif iscellstr(stageType)
                nonCustomStageTypes = setdiff(stageType,'custom');
                
                %For now -- only allow one type of non-custom stage type. Covers all immediate use cases.
                assert(length(nonCustomStageTypes) <= 1, 'At this time, only one non-custom stage type can be specified for a given linear stage assembly');
                
                [~,customStageIndices] = ismember('custom',stageType);
                customDimensions = intersect(obj.activeDimensions,customStageIndices);
            end
            obj.initializeStageType(initializedStageType); %Initialize the one and only one (for now) non-custom stage type specified
            
            %Handle custom stages - initialize properties that must be specified to override defaults.
            if ~isempty(customDimensions)
                if ~isempty(obj.requiredCustomStageProperties)
                    pvargs = filterPropValArgs(varargin,obj.requiredCustomStageProperties, obj.requiredCustomStageProperties);
                    
                    if ischar(customDimensions) %all dimensions are custom
                        obj.set(pvargs(1:2:end),pvargs(2:2:end)); %TMW: Annoying this can't be done via abstract superclass or separate function for private/protected properties
                    else %only some dimensions are custom
                        for i=1:(length(pvargs)/2)
                            val = obj.get(pvargs{2*i-1}); %current value (as initialized)
                            val(customDimensions) = pvargs{2*i}(customDimensions);
                            obj.set(pvargs{2*i-1}, val);
                        end
                    end
                end
            end
            
            %Initialize default values, in 'passive' mode, so that hardware interface is not invoked yet.
            obj.initializeDefaultValues(true);
            
            
            %Handle device interface type intialization
            switch obj.hardwareInterface
                case 'serial'                    
                    % Construct and initialize the RS232DeviceBasic 'mixin'
                    obj.hHardwareInterface = Devices.Interfaces.RS232DeviceBasic(obj, varargin{:}, 'deviceErrorResp', obj.deviceErrorResp, 'deviceSimpleResp', obj.deviceSimpleResp);
                    obj.hHardwareInterface.initialize(varargin{:});
                    
                    %Add listeners for serial interface events
                    addlistener(obj.hHardwareInterface,'errorCondSet',@obj.interfaceErrorCondSet);
            end
            
        end
        
        function delete(obj)
            if ~isempty(obj.hHardwareInterface) && isvalid(obj.hHardwareInterface)
                delete(obj.hHardwareInterface);
            end            

        end
        
    end
    
    %% PROPERTY ACCESS
    
    methods (Access=protected)
        
        function pdepPropHandleGet(obj,src,evnt)                                   
            propName = src.Name;      
            
            obj.blockOnErrorCond();
            try 
                obj.pdepPropHandleGetHook(src,evnt); %Subclass implements the 'real' pdepPropHandleGet() logic, with typical switch-yard
            catch ME
                obj.genericErrorHandler(obj.VException('','PropGetFail','Error occurred while attempting to access property %s',propName),true); %Issue callback type exception (warn only)
                ME.rethrow();
            end
        end        
        
        function pdepPropHandleSet(obj,src,evnt)
            propName = src.Name;
            
            obj.blockOnErrorCond();
            obj.blockOnPendingMove(); %Don't allow property sets during pending move.
            
            try              
                obj.pdepPropHandleSetHook(src,evnt); %Subclass implements the 'real' pdepPropHandleSet() logic, with typical switch-yard
            catch ME
                obj.genericErrorHandler(obj.VException('','PropSetFail','Error occurred while attempting to set property %s',propName),true); %Issue callback type exception (warn only)
                ME.throwAsCaller();
            end
        end       
    end
    
    methods        
        
        function val = get.positionRelative(obj)
            val = obj.positionAbsolute - obj.relativeOrigin;
        end
        
        function set.twoStepMoveEnable(obj,val)
            assert(ismember(val,[0 1]),'Value must be a logical -- 0 or 1, true or false');           
               
            if val
                %Verify that various twoStepMove properties pass through set property-access methods without error
                currLock = obj.pdepPropGlobalLock;
                obj.pdepPropGlobalLock = true;
                obj.twoStepMovePrepareFirstStep();
                try
                    for i=1:length(obj.twoStepMoveProperties)
                        prop = obj.twoStepMoveProperties{i};
                        twoStepMovePropVal =  obj.(['twoStepMoveSlow' upper(prop(1)) prop(2:end)]);
                        if ~isempty(twoStepMovePropVal) %Only try setting those that need to be set
                            obj.(prop) = twoStepMovePropVal;
                        end
                    end
                catch ME
                    obj.twoStepMoveFinish();
                    obj.pdepPropGlobalLock = currLock;
                    obj.twoStepMoveEnable = false;
                    error('One or more of the specified twoStepMove ''slow'' properties is either unspecified or incorrectly specified. Cannot enable two-step move.');
                end
                obj.twoStepMoveFinish();
                obj.pdepPropGlobalLock = currLock;
            end
            
            obj.twoStepMoveEnable = val;
        end
        
        function val = get.resolution(obj)
            %Report resolution as a scalar, if it's constant for all dimensions
            if length(unique(obj.resolution)) == 1
                val = obj.resolution(1);
            else
                val = obj.resolution;
            end
        end
        
        function set.resolution(obj,val)
            assert(isscalar(val) || (isvector(val) && length(val) == 3), '''resolution'' must be specified as a scalar or 3-element array of minimum size moves in all or each physical dimension');
            
            if isscalar(val)
                obj.resolution = repmat(val,1,3);
            elseif isvector(val) && length(val) == 3
                obj.resolution = val;
            end
        end
        
        function val = get.resolutionModes(obj)
            val = obj.resolutionModeMap.keys;
        end
        
        function val = get.resolutionCurrent(obj)
            val = obj.resolution .* obj.resolutionModeMap(obj.resolutionMode);
        end
        
        function set.stageAssemblyIndex(obj,val)
            obj.pdepSetAssert(val,isscalar(val) && ismember(val,1:obj.maxNumStageAssemblies),'Value must be an integer ranging from 1 to the maximum number of stage assemblies (%d) allowed for controllers of type %s',obj.maxNumStageAssemblies, class(obj));
            obj.stageAssemblyIndex = val;
        end
        
        function set.resolutionMode(obj,val)
            errMsg = 'Value must be a string specifying one of the available resolutionModes (or can be empty or ''default'' if only one mode is supported)';
            obj.pdepSetAssert(val,ischar(val) && ismember(val,{obj.resolutionModes{:} '' 'default'}) , errMsg);
            
            switch length(obj.resolutionModes)
                case 0
                    obj.resolutionMode = 'default';
                case 1
                    obj.resolutionMode = obj.resolutionModes{1};
                otherwise
                    if ismember(val,{'' 'default'})
                        error(errMsg);
                    else
                        obj.resolutionMode = val;
                    end
            end
        end
        
        function set.moveMode(obj,val)
            obj.pdepSetAssert(val,ischar(val) && ((~isempty(obj.moveModes) && ismember(val,obj.moveModes)) || (isempty(obj.moveModes) && ismember(val,{'' 'default'}))), 'Value must be a string specifying one of the available moveModes (or should be empty or ''default'' if only one mode is supported)'); %TMW: Should the warning about accessing another property from a dependent property's property-access method apply when that other property is Constant??
            obj.moveMode = val;
        end
        
        function set.velocity(obj,val)
            %NOTE - ideally would check to ensure that maxVelocity is not exceeded here. However, this causes issue for MP-285, which has maxVelocity per-resolution-mode.
            obj.pdepSetAssert(val,isnumeric(val) && (isscalar(val) || (isvector(val) && length(val)==3)) && all(val>=0), 'Value must be a non-negative scalar or 3 element per-dimension array of values.');
            obj.velocity = val;
        end
        
        function set.invertCoordinates(obj,val)
            obj.pdepSetAssert(val,(isnumeric(val) || islogical(val)) && (isscalar(val) || (isvector(val) && length(val)==3)), 'Value must be a scalar or 3 element per-dimension array');
            obj.invertCoordinates = val;
        end
        
        function set.activeDimensions(obj,val)
            assert(isnumeric(val) && isvector(val) && length(val)==3, '''activeDimensions'' must be specified as a 3 element vector of logicals');
            obj.activeDimensions = val;
        end
        
        function val = get.numDimensions(obj)
            val = length(find(obj.activeDimensions));
        end
        
    end
    
    %% ABSTRACT METHODS (including 'semi-abstract')

    %Methods that all subclasses MUST define in a subclass-specific way.
    methods (Abstract,Access=protected,Hidden)        
        moveStartHook(obj,targetPosn); %Starts move and returns immediately. 
        
        %Pseudo-dependent property get/set handler logic
        pdepPropHandleGetHook(obj,src,evnt);
        pdepPropHandleSetHook(obj,src,evnt);
    end
    
    %Static methods for each subclass to define
    methods (Abstract, Static, Hidden) %TMW: Would prefer this was set to AccessType=private, but this is not possible as it prevents superclass access
        stageTypeMap = getStageTypeMap(); %Implements a static property containing Map indexed by the valid stageType values supported by this class, and containing properties for each
        resolutionModeMap = getResolutionModeMap(); %Implements a static property containing Map of resolution multipliers to apply for each of the named resolutionModes
    end
    
    %Semi-abstract methods - generic implementations that are often overridden by subclasses
    methods (Access=protected,Hidden)
        
        function moveCompleteHook(obj,targetPosn)
            %Starts move and blocks command execution until move is completed. If setPositionVerify is true, final position is checked before returning.
            %Must be implemented if obj.moveCompleteStrategy = 'moveCompleteHook'
            error('The method ''moveCompleteHook'' was invoked but not defined for objects of class %s',class(obj));
        end        
  
        function moveStartCompleteEventHook(obj,targetPosn)
            %Starts move, returns immediately, and implements mechanism to generate moveComplete event
            %Must be implmented if obj.moveCompleteDetectStrategy = 'moveStartCompleteEventHook'                  
            error('The method ''moveStartCompleteEventHook'' was invoked but not defined for objects of class %s',class(obj));
        end        
        
        function interruptMoveHook(obj)
            obj.VException('','InterruptMoveNotSupported','Device of class %s does not support ''interruptMove()'' operation.',class(obj));
        end
        
        function recoverHook(obj)
            
            %Provide a default recover() behavior for serial port devices, that may help to restore operation
            %Individual subclasses can/should override this recover() behavior if a better mechanism exists for that particular device
            if strcmpi(obj.hardwareInterface,'serial')
                fclose(obj.hHardwareInterface.hSerial);
                fopen(obj.hHardwareInterface.hSerial);
               
                try
                    obj.errorConditionReset();                    
                    posn = obj.positionAbsolute;
                    if obj.errorCondition %See if any error condition was caused during get operation
                        error('dummy');
                    end
                catch 
                    ME = obj.VException('','DefaultSerialRecoveryFailed','Attempted default serial port device recover() operation, but was unsuccessful');
                    obj.errorConditionSet(ME);                                        
                    ME.throw();
                end
            else                          
                obj.VException('','RecoverNotSupported','Device of class %s does not support ''recover()'' operation.',class(obj));
            end
        end
        
        function resetHook(obj)
            obj.VException('','ResetNotSupported','Device of class %s does not support ''reset()'' operation.',class(obj));
        end
        
        function zeroHardHook(obj)
            obj.VException('','ZeroHardNotSupported','Device of class %s does not support ''zeroHard()'' operation.',class(obj));
        end
        
        
    end
    
    
    %% PUBLIC METHODS
    methods
        function defaultInitialize(obj)
            %Method containing typical initializations to do at end of constructing concrete linear stage controller class
            %This method can be invoked by concrete subclass constructor
            
            %Other initializations
            obj.velocity = obj.maxVelocity; %Initialize velocity to maximum velocity
        end
        
        function reset(obj)
            %Reset device. For some devices, this will automatically cause a zeroHard() action to occur
            
            try
                obj.resetHook(); 
            catch ME
                if ~strcmpi(ME.message,'ResetNotSupported') && ~obj.errorCondition %Just pass through if reset not supported, and no error exists
                    return;
                else
                    ME.rethrow();
                end
            end 
            
            %If successful, reset error flag
            obj.errorConditionReset();
        end
        
        function recover(obj)
            %Recover from error condition. This should represent an operation less drastic than reset() that will often allow device to return to good state (or verify that it has done so on its own) following error.                    

            try
                obj.recoverHook(); 
            catch ME
                ME.rethrow();
            end
            
            %If successful, reset error flag
            obj.errorConditionReset();
        end

 
        function interruptMove(obj)
            %Attempt to interrupt (cancel) pending move, if any
            
            if obj.asyncMovePending
                try
                    obj.interruptMoveHook(); %Attempt 'hard' interrupt of move
                catch ME
                    ME.rethrow();
                end
                
                %If successful, reset asyncMovePending flag. This allows new move to be started (even if timer from last move continues).
                obj.asyncMovePending = false;
            end
        end
        
        function zeroHard(obj,coords)
            %Set current position as absolute origin (maintained by device hardware). Argument 'coords' specifies 3 element logical array indicating which dimensions to zero. If omitted, [1 1 1] is assumed (all dimensions).

            %Check if command should proceed
            obj.blockOnError();
            obj.blockOnPendingMove();               
            
            %Do argument checking/processing %TMW: This is identical to that in zeroSoft(), but messy to do as a helper function. Inline functions would be handy.
            if nargin < 2 || isempty(coords)
                coords = ones(1,obj.maxNumDimensions);
            else
                assert(isnumeric(coords) && isvector(coords) && length(coords)==obj.maxNumDimensions && all(ismember(coords,[0 1])), 'Argument ''coords'' must be a logical vector consisting of %d elements -- one per dimension',obj.maxNumDimensions);
            end
            
            %Warn user about zeroHard() operation, if needed
            if obj.zeroHardWarning
                resp = questdlg('Executing zeroHard() operation will reset stage controller''s absolute origin. Proceed?','WARNING!','Yes','No','No');
                if strcmpi(resp,'No')
                    return;
                end
            end
            
            %Execute zeroHard() operation in subclass-specific manner; reset the zeroHardWarning flag
            obj.zeroHardHook(coords); %Pass on to subclass concrte method implementation
            obj.zeroHardWarning = false; %Do not warn multiple times %TODO(?): Consider means of only resetting if a 'Do Not Warn Again' option is selected.
            
        end
        
        function zeroSoft(obj,coords)
            %Set current position to software-maintained origin (maintained by this class). Argument 'coords' specifies 3 element logical array indicating which dimensions to zero. If omitted, [1 1 1] is assumed (all dimensions).
            
            %Check if command should proceed
            obj.blockOnError();
            obj.blockOnPendingMove();   
            
            %Do argument checking/processing %TMW: This is identical to that in zeroHard(), but messy to do as a helper function. Inline functions would be handy.
            if nargin < 2 || isempty(coords)
                coords = ones(1,obj.maxNumDimensions);
            else
                assert(isnumeric(coords) && isvector(coords) && length(coords)==obj.maxNumDimensions && all(ismember(coords,[0 1])), 'Argument ''coords'' must be a logical vector consisting of %d elements -- one per dimension',obj.maxNumDimensions);
            end
            
            currPosn = obj.positionAbsolute;
            
            zeroCoords = coords & obj.activeDimensions;
            obj.relativeOrigin(zeroCoords) = currPosn(zeroCoords);
            
            %Set flag indicating successful zeroSoft() action has occurred
            obj.zeroSoftFlag = obj.zeroSoftFlag | logical(coords);
        end
        
        
        function moveComplete(obj, targetPosn)
            %Starts move to targetPosn, specified in relative coordinates, and blocks command execution until move is completed. If setPositionVerify is true, final position is checked before returning.                        
            obj.moveCompleteHidden(targetPosn,false);
        end
        
        function moveCompleteAbsolute(obj,targetPosn)
            %Starts move to targetPosn, specified in absolute coordinates, and blocks command execution until move is completed. If setPositionVerify is true, final position is checked before returning.
            obj.moveCompleteHidden(targetPosn,true);
        end
        
        function moveCompleteIncremental(obj, increment)
            %Starts incremental move and blocks command execution until move is completed. If setPositionVerify is true, final position is checked before returning.
            currPosn = obj.positionAbsolute();
            obj.moveCompleteAbsolute(currPosn + increment);
        end
        
        function moveStart(obj,targetPosn)
            %Starts relative move and returns immediately. Can check for move completion via isMoving().            
            obj.moveStartHidden(targetPosn, false, false);
        end
        
        function moveStartIncremental(obj, increment)
            %Starts incremental move and returns immediately. Can check for move completion via isMoving().
            currPosn = obj.positionAbsolute();
            obj.moveStart(currPosn + increment);
        end
        
        function moveStartAbsolute(obj, targetPosn)
            %Starts move, specified in absolute coordinates, and returns immediately. Can check for move completion via isMoving().            
            obj.moveStartHidden(targetPosn, true, false);
        end       
        
        function moveStartCompleteEvent(obj,targetPosn)
            %Starts move, specified in relative coordinates, and returns immediately. Generates event when move has completed.            
            obj.moveStartHidden(targetPosn, false, true);
        end
        
        function moveStartCompleteEventIncremental(obj, increment)
            %Starts incremental move and returns immediately. Generates event when move has completed.
            assert(isvector(increment) && length(increment) == 3, 'Error: parameter ''increment'' should be a 3 vector.');
            
            currPosn = obj.positionAbsolute();
            obj.moveStartCompleteEvent(currPosn + increment);
        end
        
        function moveStartCompleteEventAbsolute(obj, targetPosn)   
            %Starts move, specified in absolute coordinates, and returns immediately. Generates event when move has completed.
            obj.moveStartHidden(targetPosn, true, true);
        end       
        
        function moveFinish(obj)
            %Manually signal end-of-move following a (one-step) moveStart() command (not a moveStartGenerateEvent()). This is required to clear asyncMovePending flag before subsequent asynchronous moves can be started. 
            %This should be done before the asyncMoveTimeout period, if specified, has expired, or timeout error will occur (even if move has physically completed).
            
            %Check if command should proceed
            obj.blockOnError();
            if ~obj.asyncMovePending
                return;
            end
            
            %Reset asyncMovePending flag if not moving
            if obj.isMoving()
                obj.genericErrorHandler(obj.VException('','CannotFinishWhileMoving','The device of class %s appears to still be moving, so asynchronous move cannot be deemed finished.'),class(obj));
            else
                obj.asyncMovePending = false;
            end
        end       
        
        function moveWaitForFinish(obj,pauseInterval)
            %Wait for end-of-move following a (one-step) moveStart() command (not a moveStartGenerateEvent()). This method polls the isMoving property in a tight loop with pause() statement -- blocking Matlab execution, but allowing callbacks to fire.
            %   pauseInterval: Time, in seconds, to use in pause() or pauseTight() command in tight loop. If omitted, the value given by the 'moveWaitForFinishPauseInterval' property is used.
            %
            %NOTES
            %   The moveWaitForFinishPauseTight property determines if pauseTight() is used, in lieu of built-in pause commadn
            
            import Programming.Utilities.*            
            
            if nargin < 2 || isempty(pauseInterval)
                pauseInterval = obj.moveWaitForFinishPauseInterval;
            end                                           
            
            %Check if command should proceed
            obj.blockOnError();
            if ~obj.asyncMovePending
                return;
            end
            
            try                              
                
                %Wait in tight loop for move to complete
                %Relies on asyncMoveTimeout mechanism to signal if timeout occurs
                while obj.isMoving()
                    if obj.errorCondition %Handle case where error occurs while waiting -- in particular, asyncMoveTimeout
                        throw(obj.errorConditionArray(end));
                    end
                    if toc(obj.asyncMoveTimeReference) > obj.asyncMoveTimeout
                        throw(obj.VException('','AsyncMoveTimeout','Move failed to complete within specified ''asyncMoveTimeout'' period (%d s)',obj.asyncMoveTimeout));
                    end
                    
                    if obj.moveWaitForFinishPauseTight
                        pauseTight(pauseInterval);
                    else
                        pause(pauseInterval);
                    end

                end
                obj.moveFinish(); %Signals that move is complete
                
            catch ME
                obj.genericErrorHandler(ME);
            end
        end

                    
        function verifySetPosition(obj)
            
            %Check if command should proceed
            obj.blockOnError();
            obj.blockOnPendingMove();
            
            assert(~isempty(obj.setPositionVerifyPositionStore),'No recently set position is stored. Unable to verify set position accuracy.');
            
            currPosn = obj.positionAbsolute;
            targetPosn = obj.setPositionVerifyPositionStore;
            
            generateException = false;
            if obj.setPositionVerifyAccuracyPerDimension
                if any((currPosn(obj.activeDimensions) - targetPosn(obj.activeDimensions)) > obj.setPositionVerifyAccuracy)
                    generateException = true;
                end
            else
                if sqrt(sum(currPosn(obj.activeDimensions) - targetPost(obj.activeDimensions))) > obj.setPositionVerifyAccuracy
                    generateException = true;
                end
            end
            
            %Reset the stored position
            obj.setPositionVerifyPositionStore = [];
            
            if generateException
                %error([mfilename('class') ':SetPositionMismatch'],'Final obtained position does not match the intended position within required accuracy');
                error('Final obtained position does not match the intended position within required accuracy'); %TMW: For some reason, the message identifier, not message string appears as the error message. Not in a try/catch block, but error originates from property access method.
            end
        end
    end
    
    
    %% PROTECTED/PRIVATE METHODS
    
    methods (Access=protected)
        function blockOnPendingMove(obj)
            %Method which blocks subsequent action on pending move            
            if obj.asyncMovePending
                throwAsCaller(obj.VException('','BlockOnPendingMove','A move is pending. Unable to proceed with current command.'));                
            end
        end
        
        function blockOnErrorCond(obj)
            %Blocks subsequent action if error condition is present
            if obj.errorCondition
                throwAsCaller(obj.VException('','BlockOnError','An error condition exists for device of class %s. Unable to proceed with current command.',class(obj)));
            end
        end
    end
    
    
    methods (Access=private)                

        function moveType = determineMoveType(obj,targetPosnAbs)
            %Determine type of move to use
            if obj.twoStepMoveEnable
                if isempty(obj.twoStepMoveSlowDistance)
                    moveType = 'twoStep';
                else
                    currPosn = obj.positionAbsolute();
                    distance = sqrt(sum((targetPosnAbs - currPosn).^2));
                    if distance < obj.twoStepMoveSlowDistance
                        moveType = 'oneStepSlow';
                    else
                        moveType = 'twoStep';
                    end
                end
            else
                moveType = 'oneStep';
            end            
        end
        
        function moveCompleteHidden(obj,targetPosn, forceAbsolute)
            %Generalized move function used by moveCompleteXXX() methods
            
            %Check if command should proceed
            obj.blockOnError();
            obj.blockOnPendingMove();            
            
            isMovingPoll = strcmpi(obj.moveCompleteStrategy,'isMovingPoll');
            useMoveCompleteHook = ~isMovingPoll; 
                        
            
            function waitForMoveComplete()                
                %Handler for case where underlying move command is not blocking..we do blocking/timeout detection here
                
                if isMovingPoll      
                    t = tic();
                    while obj.isMoving
                        if toc(t) > obj.moveTimeout
                            throwAsCaller(obj.VException('','MoveTimeout','Move failed to complete within specified ''moveTimeout'' period (%d s)',obj.moveTimeout));
                        end
                        pause(obj.moveCompletePauseInterval);
                    end
                end
                
                %Signal end of any async move. Harmless if none was used.
                obj.moveFinish();
            end
            
            function moveCompleteReal(targetPosn)
               if useMoveCompleteHook
                   obj.moveCompleteHook(targetPosn);
               else
                   obj.moveStartHook(targetPosn);
               end
                
            end
            

            %Convert targetPosn to absolute coordinates, if needed
            if ~forceAbsolute
                targetPosn = targetPosn + obj.relativeOrigin;
            end
            
            %Store target position, for manual setPositionVerify call
            if ~obj.setPositionVerifyAutomatic
                obj.setPositionVerifyPositionStore = targetPosn;
            end
            
            try
                moveType = obj.determineMoveType(targetPosn);
                
                if strcmpi(moveType,'oneStep')
                    moveCompleteReal(targetPosn);  %Move to target position at current velocity/resolution settings
                    waitForMoveComplete();
                else
                    obj.twoStepMovePrepareFirstStep(); %Caches initial properties (after verifying slow-step settings are OK)
                    
                    try
                        switch moveType
                            case 'oneStepSlow' %Move to target position at slow velocity/resolution settings
                                obj.twoStepMovePrepareSlowStep(); %Skip to second step
                                moveCompleteReal(targetPosn);
                                waitForMoveComplete();
                            case 'twoStep' %Use two steps to move to target position
                                
                                %Do first move at current velocity/resolution settings, and without checking position
                                moveCompleteReal(targetPosn);
                                waitForMoveComplete();                                
                                
                                %Do second move at special slow velocity/resolution settings
                                if ~all(obj.positionAbsolute == targetPosn) %TODO: Should we do this check? Or just forcibly do second move anyway?
                                    obj.twoStepMovePrepareSlowStep();
                                    moveCompleteReal(targetPosn);
                                    waitForMoveComplete();
                                end
                        end
                        
                        %Restore initial properties
                        obj.twoStepMoveFinish();
                    catch ME
                        obj.setPositionVerifyPositionStore = [];
                        obj.twoStepMoveFinish();
                        ME.throwAsCaller()
                    end
                end
                
                %Verify final position, if needed
                if obj.setPositionVerifyAutomatic
                    obj.verifySetPosition();
                end
                
            catch ME
                obj.genericErrorHandler(ME);                
            end
            
        end
        
        
        function moveStartHidden(obj, targetPosn, forceAbsolute, generateEvent)
            %Generalized move function called by other moveStartXXX()and moveStartCompleteEventXXX() methods.
            
            try
                %Check if command should proceed
                obj.blockOnError();
                obj.blockOnPendingMove();
                
                %Convert targetPosn to absolute coordinates, if needed
                if ~forceAbsolute
                    targetPosn = targetPosn + obj.relativeOrigin;
                end
                
                %Store target position, for manual setPositionVerify call
                if ~obj.setPositionVerifyAutomatic
                    obj.setPositionVerifyPositionStore = targetPosn;
                end
                
                %Determine move type, and prepare/set flags as needed
                moveType = obj.determineMoveType(targetPosn);
                if strcmpi(moveType,'oneStep')
                    twoStepEnable = false;
                    finalStep = true;
                else
                    twoStepEnable = true; %Flags that twoStep is enabled, whether used or not, and that cached properties must be restored
                    obj.twoStepMovePrepareFirstStep(); %Caches initial properties (after verifying slow-step settings are OK)
                    
                    switch moveType
                        case 'oneStepSlow' %Move to target position at slow velocity/resolution settings
                            obj.twoStepMovePrepareSlowStep(); %Skip to second step
                            finalStep = true;
                        case 'twoStep' %Use two steps to move to target position
                            finalStep = false;
                    end
                end
                
                
                %Determine if & what move-complete-detection mechanism to use (for two-step move with generateEvent=false, these values pertain to /first/ of two move)
                detectMoveComplete = generateEvent || strcmpi(moveType,'twoStep'); 
                useMoveCompleteTimer = detectMoveComplete && strcmpi(obj.moveCompleteDetectStrategy,'moveCompleteTimer');
                useMoveStartCompleteEventHook = detectMoveComplete && strcmpi(obj.moveCompleteDetectStrategy,'moveStartCompleteEventHook');
                useHardwareEvent = detectMoveComplete && strcmpi(obj.moveCompleteDetectStrategy,'hardwareInterfaceEvent');
                
                %Create Timer objects, as needed
                if useMoveCompleteTimer
                    %Timer that polls for move completion without blocking command line
                    hMoveCompleteTimer = timer('TimerFcn',@moveCompleteTimerFcn,'StartDelay',0.2,'Period',0.2,'ExecutionMode','fixedRate','Name','moveCompletePoll');
                else
                    hMoveCompleteTimer = [];
                end
                
                if ~isinf(obj.asyncMoveTimeout) && generateEvent
                    %Timer that will fire if event-generating async move times out
                    %If no event is generated, the moveWaitForFinish() method determines asyncMoveTimeout 
                    hAsyncMoveTimeoutTimer = timer('TimerFcn',@handleAsyncMoveTimeout,'StartDelay',obj.asyncMoveTimeout,'Name','asyncMoveTimeoutCheck'); %single-shot timer
                else
                    hAsyncMoveTimeoutTimer = [];
                end
                
                %Register appropriate event listener, if needed
                asyncMoveCompleteDetectListener = [];
                if useHardwareEvent
                    asyncMoveCompleteDetectListener = addlistener(obj.hHardwareInterface,'asyncReplyReceived',@handleMoveCompleteDetect);
                end
                
                if useMoveStartCompleteEventHook
                    asyncMoveCompleteDetectListener = addlistener(obj,'moveCompleteDetect',@handleMoveCompleteDetect);
                end                

                %Determine move type, and prepare/set flags as needed
                %Start move
                moveStartReal();
                obj.asyncMoveTimeReference = tic();
                
            catch ME
                obj.genericErrorHandler(ME);                                
            end

            function moveStartReal()
                %Dispatch of actual moveStart operation, and start of required timer objects
               
                obj.asyncMovePending = true;
                if useMoveStartCompleteEventHook && detectMoveComplete
                    obj.moveStartCompleteEventHook(targetPosn);
                else
                    obj.moveStartHook(targetPosn);
                end                         
                
                %Start moveCompleteTimer, if needed
                if useMoveCompleteTimer && detectMoveComplete
                    start(hMoveCompleteTimer);
                end
                
                %Start asyncMoveTimeoutTimer, if needed
                if ~isempty(hAsyncMoveTimeoutTimer)
                    start(hAsyncMoveTimeoutTimer);
                end
                            
            end
            
            function asyncMoveStopTimers()
                %Stop timers..but don't delete them, as they may be used again
                
                if ~isempty(hMoveCompleteTimer)
                    stop(hMoveCompleteTimer);
                end
                
                if ~isempty(hAsyncMoveTimeoutTimer)
                    stop(hAsyncMoveTimeoutTimer);
                end                               
            end
            
            function asyncMoveCleanup()
                
                %Stop & Delete timer resources
                timers = [hMoveCompleteTimer hAsyncMoveTimeoutTimer];
                for i=1:length(timers)
                    if ~isempty(timers(i))
                        stop(timers(i));
                        delete(timers(i));
                    end
                end
                %Delete listerner resources
                if ~isempty(asyncMoveCompleteDetectListener) 
                    delete(asyncMoveCompleteDetectListener);
                end
                
                %Restore initial properties, if changed
                if twoStepEnable 
                    obj.twoStepMoveFinish();                    
                end
                
                %Reset flags
                obj.asyncMovePending = false;
                
            end
            
            function moveCompleteTimerFcn(~,~)
                %Timer function that polls to see if motor is still moving
                
                if obj.asyncMovePending %Move completed before timeout
                    if ~obj.isMoving
                        handleMoveCompleteDetect();
                    end
                else %Move may have been interrupted
                    asyncMoveCleanup();
                end
            end
                          
            
            function handleAsyncMoveTimeout(~,~)
                if obj.asyncMovePending %timeout occurred before move complete was detected (or manually specified) 
                    obj.genericErrorHandler(obj.VException('','AsyncMoveTimeout', 'Move failed to complete within specified ''asyncMoveTimeout'' period (%d s)',obj.asyncMoveTimeout),true); %Warn only, as this is a callback
                else %Move may have been previously interrupted
                    asyncMoveCleanup();
                end
            end                        
            
            function handleMoveCompleteDetect(~,~)
                %Move may have been interrupted
                if ~obj.asyncMovePending
                    asyncMoveCleanup();
                    return;
                end
                
                obj.asyncMovePending = false; 
                asyncMoveStopTimers(); %This stops asyncMoveTimeoutTimer, as move complete came before timeout
                
                if twoStepEnable && ~finalStep
                    obj.twoStepMovePrepareSlowStep(); 
                    finalStep = true;                    
                    if ~generateEvent %Don't detect final move-completion if not generating event
                        delete(asyncMoveCompleteDetectListener);
                        detectMoveComplete = false;
                    end
                    moveStartReal();                    
                else
                    try                                             
                        %Verify set position accuracy, if indicated
                        if obj.setPositionVerifyAutomatic
                            obj.verifySetPosition();
                        end
                        
                        asyncMoveCleanup(); %Delete all resources related to async move
                        
                        if generateEvent
                            obj.notify('moveCompleteEvent');
                        end
                        
                    catch ME
                        asyncMoveCleanup();
                        ME.rethrow();
                    end
                end
            end
            
         
        end 
                       

        %%%VI040510A
        function handleErrorCondReset(obj,~,~)
            %Cleanup anything that might be in wrong state following a previous error

            obj.asyncMovePending = false; 
            timers = [timerfindall('Name','moveCompletePoll') timerfindall('Name','asyncMoveTimeoutCheck')];
            if ~isempty(timers)
                stop(timers);
                delete(timers);
            end
        end
               
        
             
        %         function asyncMoveCleanup(obj)
        %             obj.asyncMovePending=false;
        %             obj.asyncMoveTwoStepPending=false;
        %             obj.asyncMoveSignalComplete=false;
        %
        %             listener = obj.asyncMoveHardwareEventListener;
        %             if ~isempty(listener) || isvalid(listener)
        %                 delete(listener);
        %             end
        %         end
        
        function twoStepMovePrepareFirstStep(obj)
            %assert(obj.twoStepMoveEnable,'Two step move operation occurred despite being disabled. Suggests logical programming error.');
            
            %Initialize twoStepMovePropertyStore, if needed
            if isempty(obj.twoStepMovePropertyStore)
                obj.twoStepMovePropertyStore = containers.Map();
            end
            
            %Clear twoStepMovePropertyStore
            propStore = obj.twoStepMovePropertyStore;
            propStore.remove(propStore.keys());
            
            for i=1:length(obj.twoStepMoveProperties)
                propName = obj.twoStepMoveProperties{i};
                slowPropVal = obj.(['twoStepMoveSlow' upper(propName(1)) propName(2:end)]);
                if ~isempty(slowPropVal)
                    obj.twoStepMovePropertyStore(propName) = obj.(propName);
                end
            end
        end
        
        function twoStepMovePrepareSlowStep(obj)            
            assert(obj.twoStepMoveEnable,'Two step move operation occurred despite being disabled. Suggests logical programming error.');
            
            try
                for i=1:length(obj.twoStepMoveProperties)
                    propName = obj.twoStepMoveProperties{i};
                    slowPropVal = obj.(['twoStepMoveSlow' upper(propName(1)) propName(2:end)]);
                    if ~isempty(slowPropVal)
                        obj.(propName) = obj.(['twoStepMoveSlow' upper(propName(1)) propName(2:end)]);
                    end
                end
            catch ME
                obj.twoStepMoveFinish(); %Try to restore properties
                ME.rethrow();
            end
        end
        
        function twoStepMoveFinish(obj)
            %assert(obj.twoStepMoveEnable,'Two step move operation occurred despite being disabled. Suggests logical programming error.');
            
            propStore = obj.twoStepMovePropertyStore;
            propStoreVars = propStore.keys();
            for i=1:length(propStoreVars)
                obj.(propStoreVars{i}) = obj.twoStepMovePropertyStore(propStoreVars{i});
            end
        end
        
        function interfaceErrorCondSet(obj,~,~)
            %Listener for hardware interface errors
            %At moment, just issue warning. Not sure if this handler is ever really useful/desirable.
            
            %Don't use generic error handler -- this will lead to more attempts to interrupt, and can get into infinite loop
            %obj.genericErrorHandler(obj.VException('','HardwareInterfaceError','Hardware interface error detected.'),true); %Warn only, as this is a callback           
            
            fprintf(2,'WARNING(%s): Error has occurred on hardware interface of class %s:\n\t%s\n',class(obj),class(obj.hHardwareInterface),obj.hHardwareInterface.errorMessages{end});            
        end
        
        
        
        function genericErrorHandler(obj,ME,warnOnly)
            %ME: MException object, passed on from the source of the error
            %warnOnly: Flag indicating that warning, instead of error, should be given. This is often appropriate from a callback, since error does not block operation and warning would appear anyway. 
            
            if nargin < 3 || isempty(warnOnly)
                warnOnly = false;
            end
            
            %Attempt to stop async move, if one is pending
            interruptFailNotice = false;
            if obj.asyncMovePending  && obj.autoInterruptAsyncMoveOnError          
                try 
                    obj.interruptMove(); %Does both 'soft' and attempt of 'hard' cleanup of async move
                catch ME2
                    interruptFailNotice = true;
                end
            end
            
            %Signal error
            obj.errorConditionSet(ME);

            %Reset variables
            obj.setPositionVerifyPositionStore = [];
            
            if interruptFailNotice
                fprintf(2,'WARNING(%s): Attempted to interrupt move but was unsuccessful. Motor may remain in motion.\n',class(obj));
            end

            %Throw/display errors/warnings
            if warnOnly
                fprintf(2,'WARNING(%s): %s\n',class(obj),ME.message);
            else
                ME.throwAsCaller();
            end            

        end
    end
    
    methods (Access=protected)
        
        function val = device2ClassUnits(obj,val,quantity)
            deviceQuantity = obj.(['device' upper(quantity(1)) lower(quantity(2:end)) 'Units']);
            
            if ~isnan(deviceQuantity)
                classQuantity = obj.([lower(quantity) 'Units']);
                val = val .* (deviceQuantity./classQuantity);
            end
        end
        
        function val = class2DeviceUnits(obj,val,quantity)
            deviceQuantity = obj.(['device' upper(quantity(1)) lower(quantity(2:end)) 'Units']);
            
            if ~isnan(deviceQuantity)
                classQuantity = obj.([lower(quantity) 'Units']);
                val = val .* (classQuantity./deviceQuantity);
            end
        end
        
        function initializeStageType(obj,stageType)
            
            currLockVal = obj.pdepPropGlobalLock;
            obj.pdepPropGlobalLock = true; %Disable listeners for pseudo-dependent properties
            
            try
                obj.stageTypeMap = obj.getStageTypeMap();
                
                if ~obj.stageTypeMap.isKey(lower(stageType))
                    error(['Unrecognized stage type: ' stageType]);
                else
                    obj.stageType = lower(stageType);
                    props = fieldnames(obj.stageTypeMap(obj.stageType));
                    
                    %Initialize object properties based on stageType
                    cellfun(@(x)set(obj,x,obj.stageTypeMap(obj.stageType).(x)),props);
                end
                
                obj.pdepPropGlobalLock = currLockVal;
            catch ME
                obj.pdepPropGlobalLock = currLockVal;
                ME.throwAsCaller();
            end
        end
        
        function initializeDefaultValues(obj,passive)
            %Utility function for subclasses to initialize property values in various ways - including based on hidden properties of same name, but starting with 'default'
            %Typically subclasses will use this in their constructors; sometimes first in 'passive' mode and later in 'active' mode
            %Not all subclasses may do this and different subclasses may need to do this following other initialization - hence this is not coded into this abstract class's constructor
            
            if nargin < 2 || isempty(passive)
                passive = false;
            end
            
            currLockVal = obj.pdepPropGlobalLock;
            
            try
                %If in passive mode, lock out property get/set listeners, allowing properties to be directly set
                if passive
                    obj.pdepPropGlobalLock = true;
                end
                
                %Determine property names for class
                mc = metaclass(obj);
                props = mc.Properties;
                propNames = cellfun(@(x)x.Name,props,'UniformOutput',false);
                defaultPropNames = propNames(cellfun(@(x)~isempty(x) && x(1)==1,strfind(propNames,'default')));
                
                %Initialize modes, if not done so by the subclass property block.
                modeTypes = {'resolutionMode' 'moveMode'};
                for i=1:length(modeTypes)
                    if isempty(obj.(modeTypes{i})) && ~ismember(lower(['default' modeTypes{i}]),lower(defaultPropNames))
                        if isempty(obj.([modeTypes{i} 's']))
                            obj.(modeTypes{i}) = 'default'; %Use 'default' as placeholder mode value
                        else
                            obj.(modeTypes{i}) = obj.([modeTypes{i} 's']){1};
                        end
                    end
                end
                
                %propNames = properties(obj); %TMW: No access to hidden props this way
                for i=1:length(defaultPropNames)
                    actPropName = defaultPropNames{i}(8:end); %strip off 'default'
                    actPropName = propNames(strcmpi(actPropName,propNames));
                        
                    if obj.errorCondition
                        obj.VError('','InitDefaultsFail','Error condition prevents completion of object initialization');
                    end                    
                    obj.(actPropName{1}) = obj.(defaultPropNames{i});                                        

                end
                
                %Restore global lock on property get/set listeners to initial value
                if passive
                    obj.pdepPropGlobalLock = currLockVal;
                end
                
            catch ME
                obj.pdepPropGlobalLock = currLockVal;
                ME.rethrow();
            end
        end

        %
        %         function signalMoveComplete(obj,~,~)
        %             %Generic handler for move completion event, passing on to all registered listeners
        %             %For serial port devices, this is bound to 'asyncReplyReceived' event
        %
        %             % check if we're in the middle of a two-step move...if so, we want
        %             % to re-call moveStartHidden, and not notify anyone of the event
        %             if obj.twoStepMoveInProgress
        %                 obj.moveStartHidden(obj.twoStepMoveTarget, false, true);
        %             else
        %                 %Verify set position accuracy, if indicated
        %                 if obj.setPositionVerifyAutomatic
        %                     verifySetPosition();
        %                 end
        %                 notify(obj,'moveCompleteEvent');
        %             end
        %         end
        %
        %         function asyncReplyReceived(obj,~,~)
        %             % do something with the data...
        %             disp(obj.hHardwareInterface.receiveResponse());
        %         end
        %
    end
    
end

