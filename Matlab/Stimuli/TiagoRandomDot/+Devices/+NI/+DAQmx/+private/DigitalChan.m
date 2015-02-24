classdef DigitalChan < Devices.NI.DAQmx.Channel
    %DIGITALCHAN  An abstract DAQmx Digital Channel class    
   
    properties (Constant, Hidden)
        physChanIDsArgValidator = @ischar; %PhysChanIDs arg must be a string (or a cell array of such, for multi-device case)
    end
        
   %% CONSTRUCTOR/DESTRUCTOR
    methods (Access=protected)       
        function obj = DigitalChan(createFunc,task,deviceName,physChanIDs,chanNames,varargin)
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
            %NOTE: For DOChan objects, physChanIDs 
            
            [physChanNameArray,chanNameArray] = deal(cell(1,numChans));
            
            if numChans == 1
                physChanIDs = {physChanIDs};
            end
            
            for i=1:numChans     
                portOrLineID = regexpi(physChanIDs{i},'\s*/?(.*)','tokens','once'); %Removes leading slash, if any  
                physChanNameArray{i} = [deviceName '/' portOrLineID{1}];           
                if isempty(chanNames)
                    chanNameArray{i} = ''; %Would prefer to give it the physical chan name, but DAQmx won't take any special characters in the given channel name (even as it proceeds to use them in supplying the default itself)
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
        
        function postCreationListener(obj)
            %Concrete realization of abstract superclass method
            %Do Nothing
        end
    end
    
    
end

