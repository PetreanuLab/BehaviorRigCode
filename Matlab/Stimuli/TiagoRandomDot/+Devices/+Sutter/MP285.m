classdef MP285 < Devices.Interfaces.LinearStageControllerBasic
    %MP285 Class encapsulating MP-285 device from Sutter Instruments
    
    %TODO: set manualMoveMode/inputDeviceResolutionMode/displayMode (or make GetObservable only)
    %TODO: Handle getStatusProperty in a more efficient fashion
    %TODO: Add set capability for absolute/relative coordinate display. Consider initializing to absolute coordinates in constructor; and switching to relative following zeroSoft() (? - is this a good idea since there's no way to force, via serial interface, the hardware soft-zero operation, it seems)
    
    %% PSEUDO-DEPENDENT PROPERTIES (Class-Specific)
    %   Used here to provide indirection for direct hardware maintained properties
    
    properties (SetObservable, GetObservable)
        manualMoveMode; %Specifies if 'continuous' or 'pulse' mode is currently configured for manual moves, e.g. joystick or ROE
        inputDeviceResolutionMode; %Specifies if 'fine' or 'coarse' resolutionMode is being used for manual moves, e.g. with joystick or ROE
        displayMode; %Specifies if 'absolute' or 'relative' coordinates, with respect to linear controller itself, are currently being displayed
    end    
    
    %% OTHER CLASS-SPECIFIC PROPERTIES
    properties (Hidden) %TMW: Would prefer these were protected/private, but this is not possible as they are set by superclass logic        
        initialVelocity; %Value based on stage type (nominally at least)        
        maxVelocityFine; %Max velocity in fine resolution mode
    end
    
    properties (Hidden, SetAccess=protected)                        
        fineVelocityStore; %cache of last velocity value set in fine (slow) resolution mode
        coarseVelocityStore; %cache of last velocity value set in coarse (fast) resolution mode        
    end
    
    properties (Hidden, Constant)
        %Default values for properties initialized in constructor
        defaultResolutionMode = 'coarse';
        defaultZeroHardWarning = true;        
        
        postResetDelay = 0.2; %Time, in seconds, to wait following a reset command before proceeding                       
    end
    
    %% ABSTRACT PROPERTY REALIZATIONS
            
    %%%%Abstract properties for sole purpose of allowing props to be (optionally) Hidden%%%%%%%%%%%%%%    
    properties (Hidden, SetObservable, GetObservable)
        %Following properties are pseudo-dependent, but also Abstract, so that they may be Hidden

        velocityStart; %Scalar or 3 element array indicating/specifying start velocity to use during moves. If multiple resolutionModes are available, value pertains to current resolutionMode.
        acceleration; %Scalar or 3 element array indicating/specifying acceleration to use (between velocityStart and velocity) during moves. If multiple resolutionModes are available, value pertains to current resolutionMode.
    end
   
    properties
        zeroHardWarning=true; %Logical flag indicating, if true, that warning should be given prior to executing zeroHard() operations
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Following are copied/pasted from superclass definition, but with subclass-specific values set/initialized
    %TMW: This is reasonable, as the subclass does need to define/add information here. However, would be nice if documentation string from superclass could be reused, if appropriate (most common case!).
    properties (SetAccess=protected, Hidden)
        devicePositionUnits; %Units, in meters, in which the device's position values (as reported by its hardware interface) are given
        deviceVelocityUnits=nan; %Units, in meters/sec, in which the device's velocity values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        deviceAccelerationUnits=nan; %Units, in meters/sec^2, in which the device's acceleration values (as reported by its hardware interface) are given. Value of NaN implies arbitrary units.
        
        deviceErrorResp='';
        deviceSimpleResp='';
    end
    
    %Some subclasses may make these properties Hidden as well, in particular if there is only one mode supported
    properties (Constant,Hidden)
        moveModes={}; %Cell array of possible moveModes for particular subclass device type
    end
    
    properties (Constant, Hidden)  %TMW: Combination of 'Abstract' and 'Constant' in superclass works (as it well should), but documentation would suggest otherwise.
        hardwareInterface='serial'; %One of {'serial'}. Indicates type of hardware interface used to control device. NOTE: Other hardware interface types may be supported in the future.
        safeReset=false;

        maxNumStageAssemblies=1; %Maximum nuber of stage assemblies supported by device
        requiredCustomStageProperties={'resolution'}; %Cell array of properties that must be set on construction if one or more of the stages is 'custom'
        
        moveCompleteDetectStrategy = 'hardwareInterfaceEvent'; %Use serial asyncReply event on terminator
        moveCompleteStrategy = 'moveCompleteHook'; %Can wait for terminator
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
   

    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = MP285(varargin)            
           % Prop-Value pair args
           %    comPort: (REQUIRED) Number specifiying COM port to which linear stage controller is connected
           %    baudRate: Specify baud rate to use during communication. Must match that set on hardware.
           %    stageType: One of {'mp-285'}. Specifies type of stage assembly connected to stage controller.
           %    resolution: Resolution, in um, for all dimensions (specified as scalar) or per-dimension (specified as 3 element vector).If not, default resolution associated with specified 'stageType' is used.              
           
            %Determine stage type from input argument, if supplied. However, do not require, since MP-285 controller uses same name for its default and only officially supported linear stage, so no need to make user specify.
            pvargs = Programming.Interfaces.VClass.filterPropValArgs(varargin,{'stageType'});
            if isempty(pvargs) || isempty(pvargs{2})
                stageType = 'mp285'; %Same name used for stage and controller
            else
                stageType = pvargs{2};
            end
                        
            %Call superclass constructors 
            %TMW: This is required, because arguments must be passed. Would be nice to avoid, or at least avoid fully specifying class names (as it is done above)
            obj = obj@Devices.Interfaces.LinearStageControllerBasic(stageType,'availableBaudRates',[1200 2400 4800 9600 19200], 'standardBaudRate',9600,varargin{:});        
            
            %Process resolution argument, if supplied. Not required.
            pvargs = obj.filterPropValArgs(varargin,{'resolution'});
            if ~isempty(pvargs) %TMW: Annoying this can't be done via abstract superclass or separate function for private/protected properties
                obj.set(pvargs(1:2:end),pvargs(2:2:end));
            end
            
            %Initialize serial port properties
            obj.hHardwareInterface.terminatorDefault = 'CR';
            
            %Subclass-specific initialization
            obj.devicePositionUnits =  obj.resolution * obj.positionUnits; %MP-285 reports coordinates in microsteps -- i.e. the unit of finest resolution
            obj.reset(); %Resets the device, preparing it to receive remote commands
            
            for i=1:length(obj.resolutionModes) %velocity initialization for each of the resolution modes
                resModeVelocity = obj.initialVelocity * obj.resolutionModeMap(obj.resolutionModes{i});
                obj.([obj.resolutionModes{i} 'VelocityStore']) = resModeVelocity;
                obj.resolutionMode = obj.resolutionModes{i};
                obj.velocity = resModeVelocity;
            end
            
            %Method invoked to (re)initialize property values, applying values to hardware interface
            obj.initializeDefaultValues(); 
        end
    end
    
    %% PROPERTY ACCESS METHODS
    
    %%%Pseudo property-access for pseudo-dependent properties
    methods (Access=protected,Hidden)
        function pdepPropHandleGetHook(obj,src,evnt)
            propName = src.Name;
            
            switch propName
                case {'positionAbsolute' 'velocity' 'isMoving' 'maxVelocity'}
                    obj.pdepPropIndividualGet(src,evnt);
                case {'invertCoordinates' 'infoHardware' 'manualMoveMode' 'inputDeviceResolutionMode' 'displayMode'} %TODO: Perhaps replace infoHardware with individuated get, since the firmware version word from controller seems inscrutable/buggy
                    obj.pdepPropGroupedGet(@obj.getStatusProperty,src,evnt);
                case {'limitReached'}
                    obj.pdepPropGroupedGet(@obj.getNonProperty,src,evnt);
                case {'moveMode' 'resolutionMode' 'stageAssemblyIndex'}
                    %Do nothing --> pass-through (shoudl there be a method for this?)
                otherwise %Defer to superclass for default handling (error)
                    obj.pdepPropGetDisallow(src,evnt);
            end 
        end       
        
        function pdepPropHandleSetHook(obj,src,evnt)
            propName = src.Name;
            
            switch propName
                case {'velocity' 'resolutionMode'} 
                    obj.pdepPropIndividualSet(src,evnt);
                case {'moveMode'}
                    %Do nothing --> pass-through
                otherwise
                    obj.pdepPropSetDisallow(src,evnt);
                    %obj.pdepPropHandleSet@Programming.Interfaces.VClass(src,evnt);                    
            end            
        end
    end
    
    methods (Hidden)   
        function val = getPositionAbsolute(obj)
            posn = obj.hHardwareInterface.sendCommandBinaryReply('c','int32');
            val = obj.device2ClassUnits(posn,'position'); %Converts to units of class instance
        end

        function val = getVelocity(obj)
            val = obj.([obj.resolutionMode 'VelocityStore']);
        end
        
        function setVelocity(obj,val)            
            %Ensure maximum value is not exceeded
            
            if ~isscalar(val)
                error('It is not possible to set axis-specific velocities for device of class %s',class(obj));
            end            
            
            if  val > obj.maxVelocity
                error('Velocity value provided exceeds maximum permitted value (%d)',obj.maxVelocity);
            end
            
            %Cache the velocity value to be set
            obj.([obj.resolutionMode 'VelocityStore']) = val;
            
            %Actually set value on device
            obj.resolutionMode = obj.resolutionMode;
        end
        
        function val = getMaxVelocity(obj)
            val = obj.maxVelocityFine * obj.resolutionModeMap(obj.resolutionMode); 
        end
        
        function tf = getIsMoving(obj)
            tf = obj.hHardwareInterface.isAwaitingReply();
        end        

        function setResolutionMode(obj,val)            
            obj.setVelocityRaw(obj.([val 'VelocityStore']));
        end                  
        
    end       
    
    %Helper functions specifically for property access methods
    methods (Access=protected)
        function val = getStatusProperty(obj,statusProp)
            status = obj.getStatus();
            val = status.(statusProp);
        end
    end
    
    %% ABSTRACT METHOD IMPLEMENTATIONS
    methods (Access=protected,Hidden)
        

        function zeroHardHook(obj,coords)
            if ~all(coords)
                error('It is not possible to perform zeroHard() operation on individual dimensions for device of class %s',class(obj));
            end
            
            obj.hHardwareInterface.sendCommandSimpleReply('o');
            obj.relativeOrigin = zeros(1,obj.maxNumDimensions);
        end
        
        
        function moveCompleteHook(obj,targetPosn)
            posn = obj.class2DeviceUnits(targetPosn,'position'); %Converts into units used by device
            
            %Send string and binary portions of command in separate calls
            obj.hHardwareInterface.sendCommand('m','terminator','');
            obj.hHardwareInterface.sendCommandSimpleReply(int32(posn),'replyTimeout',obj.moveTimeout,'robustTerminatedReplyAttempts',0); %Awaits carriage return (terminatorDefault) signalling end of move
        end
        
        function moveStartHook(obj,targetPosn)
            posn = obj.class2DeviceUnits(targetPosn,'position'); %Converts into units used by device            
           
            %Send string and binary portions of command in separate calls
            obj.hHardwareInterface.sendCommand('m','terminator','');
            obj.hHardwareInterface.sendCommandAsyncReply(int32(posn)); %Awaits carriage return (terminatorDefault) signalling end of move        

        end
        
        function recoverHook(obj)
            %tf = false;
            numTries = 15;
            for i=1:numTries 
                try
                    obj.hHardwareInterface.sendCommand(char(3),'terminator','');
                    obj.hHardwareInterface.sendCommandSimpleReply('','replyTimeout',0.2); %Wait for reply up to 0.2s
                catch ME
                    if i < numTries
                        continue;
                    else
                        throwAsCaller(obj.VException('','RecoverFailed','Recover operation for device of type %s FAILED',class(obj)));
                    end
                end
                %tf = true; %Recovered successfully               
                break;
            end
        end        
        
        function interruptMoveHook(obj)
            %TODO: Fix the Key-value pairs here, consolidate to one command (using skipSendTerminator)
            obj.hHardwareInterface.sendCommand(char(3),'terminator',''); %Control-c is 03h %Don't send terminator
            obj.hHardwareInterface.sendCommandSimpleReply('','replyTimeout',2); %Don't wait too long...it either works or it doesn't
        end
        
        function resetHook(obj)
            %obj.sendCommandSimpleReply('r');
            obj.hHardwareInterface.sendCommand('r'); %No reply expected
            pause(obj.postResetDelay);
        end
        
    end
    
    methods        
       
    end
    
    
    %% HIDDEN METHODS
    methods (Hidden)
        function statusStruct = getStatus(obj,verbose)
            %function getStatus(obj,verbose)
            %   verbose: Indicates if status information should be displayed to command line. If omitted/empty, false is assumed
            %   statusStruct: Structure containing fields indicating various aspects of the device status...
            %           invertCoordinates: Array in format appropriate for invertCoordinates property
            %           displayMode: One of {'absolute' 'relative'} indicating which display mode controller is in
            %           inputDeviceResolutionMode: One of {'fine','coarse'} indicating resolution mode of input device, e.g. ROE or joystick.
            %           resolutionMode: One of {'fine','coarse'} indicating resolution mode of device with respect to its computer interface -- i.e. the 'resolutionMode' of this class
            %
            
            if nargin < 2 || isempty(verbose)
                verbose = false;
            end
            
            status = obj.hHardwareInterface.sendCommandBinaryReply('s','uint8');
            
            %Parsing pertinent values based on status return data table in MP-285 manual
            statusStruct.invertCoordinates = [status(2) status(3) status(4)] - [0 2 4];
            statusStruct.infoHardware = word2str(status(31:32));
            
            flags = dec2bin(uint8(status(1)),8);
            flags2 = dec2bin(uint8(status(16)),8);
            
            if str2double(flags(2))
                statusStruct.manualMoveMode = 'continuous';
            else
                statusStruct.manualMoveMode = 'pulse';
            end
            
            if str2double(flags(3))
                statusStruct.displayMode = 'relative'; %NOTE: This is reversed in the documentation (rev 3.13)
            else
                statusStruct.displayMode = 'absolute'; %NOTE: This is reversed in the documentation (rev 3.13)
            end
            
            if str2double(flags2(6));
                statusStruct.inputDeviceResolutionMode = 'fine';
            else
                statusStruct.inputDeviceResolutionMode = 'coarse';
            end
            
            speedval = 2^8*status(30) + status(29);
            if speedval >= 2^15
                statusStruct.resolutionMode = 'fine';
                speedval = speedval - 2^15;
            else
                statusStruct.resolutionMode = 'coarse';
            end
            statusStruct.resolutionModeVelocity = speedval;
            
            if verbose
                disp(['FLAGS: ' num2str(dec2bin(status(1)))]);
                disp(['UDIRX: ' num2str(status(2))]);
                disp(['UDIRY: ' num2str(status(3))]);
                disp(['UDIRZ: ' num2str(status(4))]);
                
                disp(['ROE_VARI: ' word2str(status(5:6))]);
                disp(['UOFFSET: ' word2str(status(7:8))]);
                disp(['URANGE: ' word2str(status(9:10))]);
                disp(['PULSE: ' word2str(status(11:12))]);
                disp(['USPEED: ' word2str(status(13:14))]);
                
                disp(['INDEVICE: ' num2str(status(15))]);
                disp(['FLAGS_2: ' num2str(dec2bin(status(16)))]);
                
                disp(['JUMPSPD: ' word2str(status(17:18))]);
                disp(['HIGHSPD: ' word2str(status(19:20))]);
                disp(['DEAD: ' word2str(status(21:22))]);
                disp(['WATCH_DOG: ' word2str(status(23:24))]);
                disp(['STEP_DIV: ' word2str(status(25:26))]);
                disp(['STEP_MUL: ' word2str(status(27:28))]);
                
                %I'm not sure what happens to byte #28
                
                %Handle the Remote Speed value. Unlike all the rest...it's big-endian.
                speedval = 2^8*status(30) + status(29);
                if strcmpi(statusStruct.resolutionMode,'coarse')
                    disp('XSPEED RES: COARSE');
                else
                    disp('XSPEED RES: FINE');
                end
                disp(['XSPEED: ' num2str(speedval)]);
                
                disp(['VERSION: ' word2str(status(31:32))]);
            end
            
            
            function outstr = word2str(bytePair)
                val = 2^8*bytePair(2) + bytePair(1); %value comes in little-endian
                outstr = num2str(val);
            end
            
        end
    end
    
    methods (Static,Hidden)
        
        function stageTypeMap = getStageTypeMap()
            %Implements a static property containing Map indexed by the valid stageType values supported by this class, and containing properties for each
            
            persistent stageTypeMapStore
            
            if isempty(stageTypeMapStore)
                stageTypeMapStore = containers.Map();
                
                stageTypeMapStore('mp285') = struct( ... %Note that stage assembly has same name as controller (as only one assembly type is officially supported)
                    'maxVelocityFine', 1300, ... %NOTE - this is maximum velocity in 'fine' mode.
                    'resolution', .04, ... %0.04um fine mode resolution for default stages
                    'initialVelocity',1300); %Use 'initialVelocity' instead of 'defaultVelocity' -- as we do not defer to superclass default property value for velocity for this class %Use a much lower value than maxVelocity, to keep things in the (approximately) 'linear' range of velocity behavior. At higher values, below the maximum, velocity adjustments become notably sublinear.
            end
            
            %Return the stored stageTypeMap value
            stageTypeMap = stageTypeMapStore;
        end
        
        function resolutionModeMap = getResolutionModeMap()
            %Implements a static property containing Map of resolution multipliers to apply for each of the named resolutionModes
            
            persistent resolutionModeMapStore
            
            if isempty(resolutionModeMapStore)
                resolutionModeMapStore = containers.Map();
                resolutionModeMapStore('fine') = 1;
                resolutionModeMapStore('coarse') = 5;
            end
            %Return the stored stageTypeMap value
            resolutionModeMap = resolutionModeMapStore;
        end
        
    end
    
    
    %% PRIVATE/PROTECTED METHODS      
    
    methods (Access=protected)
        
        
        function setVelocityRaw(obj,val)
            switch obj.resolutionMode
                case 'fine'
                    commandValue = bitor(val,2^15);
                case 'coarse'
                    commandValue = bitor(val,0);
                otherwise
                    assert(false,'Logical programming error. Should not happen');
            end
            
            %TODO: Try/Catch and verify correct velocity setting occurred (?)
            obj.hHardwareInterface.sendCommand('V','terminator','');
            obj.hHardwareInterface.sendCommandSimpleReply(uint16(commandValue));
        end
        
        
    end
    
    
end

