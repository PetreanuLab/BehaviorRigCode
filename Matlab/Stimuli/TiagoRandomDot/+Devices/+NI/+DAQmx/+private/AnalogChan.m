classdef AnalogChan < Devices.NI.DAQmx.Channel
    %ANALOGCHAN An abstract DAQmx Analog Channel class
    
    
    properties (Constant, Hidden)
        physChanIDsArgValidator = @isnumeric; %PhysChanIDs arg must be numeric (or a cell array of such, for multi-device case)
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = AnalogChan(createFunc,task,deviceName,physChanIDs,chanNames,varargin) 
            %%%TMW: We defer to a constructor-like superclass method that is not actually its constructor to avoid either 1) conditionally calling constructor, or 2) constructing abstract class (as would be done if this logic were shared in superclass constructor). This dilemma is annoying
            if nargin
                obj = obj.createChannels(createFunc, task, deviceName, physChanIDs, chanNames, varargin{:}); %TMW: Note that we are creating the object array with a non-constructor superclass method                                                         
           end
        end
        
    end
    
    
    %% METHODS
    methods (Hidden)
        %TMW: This function is a regular method, rather than being static (despite having no object-dependence). This allows caller in abstract superclass to invoke it  by the correct subclass version. 
        %%% This would not need to be a regular method if there were a simpler way to invoke static methods, without resorting to completely qualified names.
        function [physChanNameArray,chanNameArray] = createChanIDArrays(obj, numChans, deviceName, physChanIDs,chanNames)            
           
            [physChanNameArray,chanNameArray] = deal(cell(1,numChans));
            for i=1:numChans
                if ~isnumeric(physChanIDs)
                    error([class(obj) ':Arg Error'], ['Argument ''' inputname(4) ''' must be a numeric array (or cell array of such, for multi-device case)']);
                else
                    physChanNameArray{i} = [deviceName '/' lower(obj.typeCode) num2str(physChanIDs(i))];
                end
                if isempty(chanNames)
                    chanNameArray{i} = '';
                elseif ischar(chanNames)
                    if numChans > 1
                        chanNameArray{i} = [chanNames num2str(i)];
                    else 
                        chanNameArray{i} = chanNames;
                    end
                elseif iscellstr(chanNames) && length(chanNames)==numChans
                    chanNameArray{i} = chanNames{i};
                else
                    error(['Argument ''' inputname(5) ''' must be a string or cell array of strings of length equal to the number of channels.']);
                end
            end
        end
    end
    
end



