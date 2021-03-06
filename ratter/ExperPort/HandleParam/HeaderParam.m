
% Version History
% 092105        SSP         Initial write

function [] = HeaderParam(obj, parname, parval, x, y, varargin)

   if ischar(obj) && strcmp(obj, 'base'), param_owner = 'base';
   elseif isobject(obj),                  param_owner = ['@' class(obj)];
   else   error('obj must be an object or the string ''base''');
   end;

   pairs = {   ...
     'param_owner',        param_owner                ; ...
     'param_funcowner',    determine_fullfuncname     ; ...
     'HorizontalAlignment', 'left'                    ; ...
     'position',           []                         ; ...
     'width',              []                         ; ...
     'height',             15                         ; ...
   }; parseargs(varargin, pairs);

   % If position is explicitly specified, ignore width; otherwise, width is
   % 400 if not specified and the user-specified value if it was given.
   if isempty(position), %#ok<NODEF>
     if isempty(width), width = 400; end; %#ok<NODEF>
     position = gui_position(x, y);
     position(3) = width;
   end;

   SoloParamHandle(obj, parname, ...   
                   'type',            'header', ...
                   'value',           parval, ...
                   'position',        position, ...
                   'HorizontalAlignment', HorizontalAlignment, ...
                   'param_owner',     param_owner, ...
                   'param_funcowner', param_funcowner);

   assignin('caller', parname, eval(parname));
   return;

