classdef MovieFrames < handle
    
    properties (SetAccess = protected, GetAccess = public)
        Frames
        FrameInds
        FrameTimes
        NFrames=0;
        Background
        BackgroundWeight
        Width
        Height
        NumberOfFrames
        MovieName
        Angle
        Axs
        Pos
        Time
        T0
        Settings
        IsGPU
        DataType
    end
  
    methods
        function obj=MovieFrames(MovieName,isGPU,datatype)
            if nargin<2
                try 
                    gsingle(1);
                    obj.IsGPU=true;
                    disp('Using CUDA device, use ginfo for more information.')
                catch exception
                    disp(exception.message);
                    disp('Either no CUDA device detected or Jacket is not installed properly.');
                    disp('Using boring old CPU mode.');
                    obj.IsGPU=false;
                end
            else
                if isGPU
                    try
                        gsingle(1);
                        obj.IsGPU=true;
                        disp('Using CUDA device, use ginfo for more information.')
                    catch exception
                        disp(exception.message);
                        disp('Unable to connect to CUDA device or Jacket is not installed properly.');
                        disp('Using CPU mode rather than requested GPU mode.');
                    end
                else
                    obj.IsGPU=isGPU;
                    disp('Using CPU.')
                end
            end
            if nargin<3, datatype='double'; end
            if ~strcmpi(datatype,'double') && ~strcmpi(datatype,'single')
                error('MovieFrames:MovieFrames:incorrectDataType',...
                      'datatype must be either ''single'' or ''double''.');
            end
        
%             mobj=mmreader(MovieName);
%             obj.MovieName      = [mobj.Path '/' mobj.Name];
            warning off;
            obj.MovieName      = fullpath(MovieName);
            v                  = my_mmread(obj.MovieName,1000000000);
            obj.Width          = v.width;
            obj.Height         = v.height;            
            obj.NumberOfFrames = abs(v.nrFramesTotal);
            obj.Angle          = zeros(1,obj.NumberOfFrames);
            obj.Axs            = zeros(2,obj.NumberOfFrames);
            obj.Pos            = zeros(2,obj.NumberOfFrames);
            obj.Time           = zeros(1,obj.NumberOfFrames);
            obj.DataType       = lower(datatype);
            warning on;
        end
        GrabFrames(obj,framenos) 
        ClearFrames(obj)
        EstimateBackground(obj,nrandframes,israndomsample)
        [pos,frameinds]=EstimatePosition(obj,varargin)  
        [ratvals,frameinds]=EstimateRatPDF(obj,varargin)
        [boxvals,frameinds]=EstimateBoxPDF(obj,varargin)
        RecalculateBackground(obj,pos,frameinds,varargin)
        [blockvals,rowcol,valtimes]=BlockPixels(obj,frameinds,varargin)
        stats=AlignMovie(obj,bv,bvt,peh,varargin)
        chunks=ChunkInds(obj,firstind,lastind,chunksize)
        Fit(obj,varargin)
        OutputMovie(obj,varargin)
        SetProperties(obj,varargin)
    end
end
  


%
% function dependencies:
%   mmread
%   my_mmread
%   parseargs
%   bdata
%   reward_function
%   align_twovectors
%   extract_stringsfrommoviename
%   calc_angaxsfromcov2
%   ellipse
%   ts2epoch
%   fullpath

