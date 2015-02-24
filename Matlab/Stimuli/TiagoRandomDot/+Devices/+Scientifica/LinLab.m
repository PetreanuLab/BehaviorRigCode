classdef LinearStage < Devices.Interfaces.LinearStageBasic
    %LinearStage Class encapsulating Scientfica line stages which run under their LinLab software (and its corresponding serial command set)
    
    properties (SetAccess=protected, Hidden)
        
    end
    

    properties (Constant)
        resolutionModes = {'default'};  
    end
    
    
    %% ABSTRACT PROPERTY REALIZATIONS
    %TMW: Annoying that documentation string from abstract superclass is not used if none provided here

    properties (SetAccess=protected)
        devicePositionUnits=0.1e-6;
        deviceVelocityUnits=nan;
        deviceAccelerationUnits=nan;
    end
    
    %TMW: Annoying that Abstract Dependent properties have to be redefined. Ideally would just define the not-yet-implemented property access methods.
    properties (Dependent)
        velocity;
        velocityStart; %Scalar or 3 element array indicating/specifying start velocity to use during moves. If multiple resolutionModes are available, value pertains to current resolutionMode.
        acceleration; %Scalar or 3 element array indicating/specifying acceleration to use (between velocityStart and velocity) during moves. If multiple resolutionModes are available, value pertains to current resolutionMode.
    end     
    
    properties (Constant)               
        resolutionModes={'default'}; 
        %Only one resolutionMode supported
        
        
    end
    
    properties (Constant, Hidden)
        positionUnits = 1e-7;
        velocityUnits = nan;
        accelerationUnits = nan;
        
        hardwareInterface='serial';
        dimensions=[1 1 1]; 

        isMultiDevice=true;
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = LinLab(varargin)
            
            %Call superclass constructor
            obj = obj@Devices.Interfaces.LinearStage(varargin{:});
            
            %Further configure serial object
            obj.hSerial.Terminator = 'CR';
            
        end
        
    end
    
    %% PROPERTY ACCESS METHODS
    methods 
        function val = get.velocity(obj)
            obj.sendCommand('TOP');
            val=obj.device2ClassUnits(obj.receiveNumericReply(),'velocity');
        end
        
        function val = get.velocityStart(obj)
            obj.sendCommand('START');
            val=obj.device2ClassUnits(obj.receiveNumericReply(),'velocity');
        end
        
        function val = get.acceleration(obj)
            obj.sendCommand('ACC');
            val=obj.device2ClassUnits(obj.receiveNumericReply(),'acceleration');            
        end
        
        function val = set.velocity(obj,val)
            val=obj.class2DeviceUnits(obj.receiveNumericReply(),'velocity');
            obj.sendCommand(['TOP' num2str(val)]);
            
            actVal = obj.velocity;
            if val ~= actVal
               fprintf(2,'WARNING: Actual value differs from set value\n'); 
            end
        end
        
        function val = set.velocityStart(obj,val)
            val=obj.class2DeviceUnits(obj.receiveNumericReply(),'velocity');
            obj.sendCommand(['START' num2str(val)]);
            
            actVal = obj.velocityStart;
            if val ~= actVal
               fprintf(2,'WARNING: Actual value differs from set value\n'); 
            end
        end
        
        function val = set.acceleration(obj,val)
            val=obj.class2DeviceUnits(obj.receiveNumericReply(),'acceleration');            
            obj.sendCommand(['ACC' num2str(val)]);
            
            actVal = obj.acceleration;
            if val ~= actVal
                fprintf(2,'WARNING: Actual value differs from set value\n');
            end
        end
        
    end
    
    
    %% ABSTRACT METHOD IMPLEMENTATIONS
    methods (Access=protected,Hidden)
        function setPositionAbsolute(obj,value)
            
            %Compute position into units used by device
            posn = value .* (obj.devicePositionUnits./obj.positionUnits);
            
            obj.sendCommand(['ABS ' num2str(posn)]);
            obj.verifyCommandBasic();
            
            %TODO: Handle setPositionVerify
            if obj.setPositionVerify
                
            end
        end
        
        function setPositionRelative(obj,value)
            posn = value .* (obj.devicePositionUnits./obj.positionUnits) - obj.relativeOrigin;            

            obj.sendCommand(['ABS ' num2str(posn)]);
            obj.verifyCommandBasic();            
        end
        
        function value = getPositionAbsolute(obj)            
            obj.sendCommand('ABS');
            posn = obj.receiveCommandReply();
            
            %Convert to units of class instance
            value = posn .* (obj.positionUnits/obj.devicePositionUnits);
        end

        function value = getPositionRelative(obj)
            absPosn = obj.getPositionAbsolute();
            
            value = absPosn - obj.relativeOrigin;            
        end
    end
    
    methods 
        function zeroSoft(obj)
            
        end
        
        function zeroHard(obj)
            
        end
        
    end
    
    %% PRIVATE METHODS
    methods (Access=private)
        
        function sendCommand(obj,commandString)
            fprintf(obj.hSerial,commandString);             
        end
        
        function verifySimpleReply(obj)
           try
               resp = obj.receiveCommandReply();
               
               if ~strcmpi(resp(1),'A')
                    error('Unrecognized reply from stage device');
               end
           catch ME
               ME.throwAsCaller();
           end
        end
           
        function val = receiveNumericReply(obj)
            try 
                val = sscanf(obj.recieveCommandReply,'%g'); %TODO: Switch to textscan?               
            catch ME
                ME.throwAsCaller();
            end
        end
        
        
        function resp = receiveCommandReply(obj)
            %Handler for basic commands whose reply is 'A' upon successful receipt/execution
              
            try
                h1 = tic;
                while ~obj.hSerial.BytesAvailable %TODO: Consider using asynchronous serial port reads/writes
                    if toc(h1) > obj.responseTimeout
                        error('Device failed to reply within specified ''responseTimeout'' interval.')
                    else
                        pause(0.1);
                    end
                end
                
                resp = fscanf(obj.hSerial);
                
                if strcmpi(resp(1),'E')
                    error('Error in command sent to stage device');
                end
                
            catch ME
                ME.throwAsCaller();
            end
            
        end
        
    end
    
end

