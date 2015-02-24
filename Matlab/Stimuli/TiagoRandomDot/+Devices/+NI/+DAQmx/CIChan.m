classdef CIChan < Devices.NI.DAQmx.private.CounterChan
    %COCHANNEL A DAQmx Counter Input Channel
    
    properties (Constant)
        type = 'CounterInput';
    end
    
    properties (Constant, Hidden)
        typeCode = 'CI';
    end
    
    %% CONSTRUCTOR/DESTRUCTOR
    methods
        function obj = CIChan(varargin) 
            %%%TMW: Constructor required, as this is a concrete subclass of abstract lineage
            obj = obj@Devices.NI.DAQmx.private.CounterChan(varargin{:});            
        end
    end
    
end

