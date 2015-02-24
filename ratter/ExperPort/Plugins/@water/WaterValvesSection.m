% [x, y] = WaterValvesSection(obj, action, x, y)
%
% This plugin uses the water calibration table (constructed using
% @WaterCalibrationTable) to automatically translate from a desired water
% delivery amount into a time for which the water valve should be left
% open.
%
% GUI DISPLAY: Puts up two numerical editable fields, Left microliters and
% Right microliters, where the user can insert the desired dispense amount.
% To the right of these will be two display fields showing the
% corresponding times for which the valves should be left open. A title
% will be above all these GUI fields. If the GUIs for the desired amounts
% are edited by a user, (or changed by loading Solo settings), the dispense
% times will be automatically recalculated.
%
% Note that @WaterCalibrationTable figures out dispense times for amounts
% that are within 15% of the calibrated data points that it has; and that
% calibrations have finite lifetimes. If asking for a value that is beyond
% the known range of the calibration table, or the calibration table is out
% of date, a warning window will go up, dispense times will acquire a red
% background, and dispense times will go to a default value of 0.01 (i.e.,
% essentially nothing.) If your dispense times have a red background, that
% means "recalibrate your table before using them" !!
%
%
% PARAMETERS AND RETURNS:
% -----------------------
%
% obj      Default object argument.
%
% action   One of:
%
%   'init' x y 
%            Initializes the plugin and sets up the GUI for it. Requires
%            two extra arguments, which will be the (x, y) coords, in
%            pixels, of the lower left hand corner of where this plugin's
%            GUI elements will start to be displayed in the current figure.
%            Returns [x, y], the position of the top left hand corner of
%            the plugin's GUI elements after they have been added to the
%            current figure.
%       Optional Params:
%       'streak_gui' 0 
%            If 'streak_gui' is passed and set to 1 during init, then two
%            parameters are made visible that involve gemoetrically
%            increasing rewards for consecutive correct answers, ie.
%            'streaks': Streak_base and Streak_max.  See 'get_water_times'
%            for further details.
%            e.g. [x,y]=WaterValvesSection(obj,'init',x,y,'streak_gui',1);
%       'maxdays_error'    31
%            After this many days without a recalibration, the
%            @WaterCalibrationTable will give an error and refuse to
%            proceed.
%       'maxdays_warning'  25
%            After this many days without a recalibration, the
%            @WaterCalibrationTable will proceed ok, but will issue a
%            warning.
%       'show_calib_info' 0
%            If show_calib_info is passed in as 1 then two parameters are
%            made visible. Tech is the last technician to perform a
%            calibration on that rig and LastCalib is the date when that
%            rig was last calibrated.
%    
%
%   'set_water_amounts'  l_uL r_uL
%            Requires two extra arguments; sets the GUI parameter for left
%            volume to the first of these, l_uL, and sets the GUI
%            parameter for right volume to the second, r_uL; then
%            recalculates the appropriate water dispense times. This action
%            is provided here to allow a command-line way of changing the
%            GUIs for left and right volume; the user can also change them
%            by hand, directly in the GUI.
%
%   'get_water_times'  [streak_length=0]
%            Returns two values, LeftTime, and RightTime, which are the
%            water valve opening times that were calculated to correspond
%            to the GUI dispense amounts. Example call:
%              WaterValvesSection(obj,'get_water_times', 3);
%        Optional Params:
%            If an extra argument is passed in, this argument will be taken
%            to represent the "streak_length", i.e., the number of
%            immediately previous consecutive correct responses by the
%            subject. For example, if the previous four trials were miss,
%            correct, correct, correct, the streak would be three and you
%            could make the call as in:
%               WaterValvesSection(obj,'get_water_times', 3);
%            If this param is passed in, the returned Water time values are
%            augmented by the formula:
%               water_time*Streak_base^min(streak_length,Streak_max);
%            Generally you want Streak_base > 1, so that there is more
%            water for longer streaks.
% 
%   'calculate'
%            Force a recalculation of water dispanse times. This call
%            should normally never be needed by the user, since both
%            command line and GUI modes of changing desired dispense times
%            automaticaly force the recalculation.
%
%   'reinit' Delete all of this section's GUIs and data, and reinit, at the
%            same position on the same figure as the original section GUI
%            was placed.
%


% Written  by Carlos Brody 2007
% Modified by Jeff Erlich  2007
% Modified by Chuck Kopec  2009

function [x, y] = WaterValvesSection(obj, action, x, y, varargin)

GetSoloFunctionArgs(obj);


pairs = { ...
    'streak_gui', 0 ; ...
    'maxdays_error'        90  ; ... 
    'maxdays_warning'      80  ; ...  
    'show_calib_info'       0  ; ...
    };
parse_knownargs(varargin, pairs);

switch action
  case 'init',
    % Save the figure and the position in the figure where we are
    % going to start adding GUI elements:
    SoloParamHandle(obj, 'my_gui_info', 'value', [x y gcf]);
    
    
    NumeditParam(obj, 'Streak_base', 1, x,y, 'position', [x y 80 20], ...
      'labelfraction', 0.7, 'label', 'Streak Base');
    tts=sprintf(['\n The streak mulitplier is streak_base^streak_length.\n  '...
        'If streak base is 1, then water is delivered as normal, since 1^n is 1\n. '...
        'If streak base is >1 then the water delivered will grow exponentially\n'...
        'with # of correct trials in a row.  The streak length is passed as an input \n'...
        'parameter to get_water_times']);
    
    set_tooltipstring(Streak_base, tts);
  
    NumeditParam(obj, 'Streak_max', 6, x, y, 'position', ...
      [x+90 y 110 20], 'labelfraction', 0.65, ...
      'label', 'Max Streak Length');
    
    tts=sprintf(['\n If streak length is >= MaxStreak then water  is watertime*streak_base^maxstreak.']);
    set_tooltipstring(Streak_max, tts);
    
  
  
    if streak_gui
        next_row(y);
    else
        make_invisible(Streak_base);
        make_invisible(Streak_max);
    end
        
    

    EditParam(obj, 'Right_volume', 24, x, y, 'position', [x y 75 20], ...
      'labelfraction', 0.7, 'label', 'Right uL');
    DispParam(obj, 'RightWValveTime', 0, x, y, 'position', ...
      [x+75 y 125 20], 'labelfraction', 0.45, ...
      'label', 'Rt Wtr time');
    next_row(y);

    EditParam(obj, 'Left_volume', 24, x, y, 'position', [x y 75 20], ...
      'labelfraction', 0.7, 'label', 'Left uL');
    DispParam(obj, 'LeftWValveTime', 0, x, y, 'position', ...
      [x+75 y 125 20], 'labelfraction', 0.45, ...
      'label', 'Lt Wtr time');
    next_row(y);


    SoloParamHandle(obj, 'water_table',    'value', WaterCalibrationTable, 'saveable', 0);
    SoloParamHandle(obj, 'MaxDaysError',   'value', maxdays_error); 
    SoloParamHandle(obj, 'MaxDaysWarning', 'value', maxdays_warning); 
    
    try
        lastcalib = get_last_calib_info(value(water_table));
    catch %#ok<CTCH>
        lastcalib.tech = '';
        lastcalib.date = '';
    end
    
    DispParam(obj, 'Tech',     lastcalib.tech, x, y, 'position', [x    y  75 20], 'labelfraction', 0.7);
    DispParam(obj, 'LastCalib',lastcalib.date, x, y, 'position', [x+75 y 125 20], 'labelfraction', 0.45);
    
    if show_calib_info
        next_row(y);
    else
        make_invisible(Tech);
        make_invisible(LastCalib);
    end
        
    
    set_callback({Right_volume;Left_volume}, {mfilename, 'calculate'});
    feval(mfilename, obj, 'calculate');

    SubheaderParam(obj, 'title', mfilename, x, y);
    next_row(y, 1.5);


  case 'calculate',
    [wt, errid, message] = ...
      interpolate_value(value(water_table), 'right1water', ...
      value(Right_volume), 'gui_warning', 1, 'maxdays_error', value(MaxDaysError), ...
      'maxdays_warning', value(MaxDaysWarning),...
      'linearfit_allpoints',1,'use_mostrecent_day_only',1);
    if isnan(wt),
      set(get_ghandle(RightWValveTime), 'BackgroundColor', [1 0.1 0.1]);
      RightWValveTime.value = 0.01;
    else
      set(get_ghandle(RightWValveTime), 'BackgroundColor', 0.8*[1 1 1]);
      RightWValveTime.value = wt;
    end;

    [wt, errid, message] = ...
      interpolate_value(value(water_table), 'left1water', ...
      value(Left_volume), 'gui_warning', 1, 'maxdays_error', value(MaxDaysError), ...
      'maxdays_warning', value(MaxDaysWarning),...
      'linearfit_allpoints',1,'use_mostrecent_day_only',1);
    if isnan(wt),
      set(get_ghandle(LeftWValveTime), 'BackgroundColor', [1 0.1 0.1]);
      LeftWValveTime.value = 0.01;
    else
      set(get_ghandle(LeftWValveTime), 'BackgroundColor', 0.8*[1 1 1]);
      LeftWValveTime.value = wt;
    end;

    
  case 'set_water_amounts'
    if nargin < 4, error('Need two extra args for this action'); end;
    Left_volume.value  = x; 
    Right_volume.value = y;
    feval(mfilename, obj, 'calculate');
    
    
  case 'get_water_times'
    if nargin>2
        streak_len=min(x,value(Streak_max));
    else
        streak_len=1;
    end
    
    x = LeftWValveTime*Streak_base^streak_len; 
    y = RightWValveTime*Streak_base^streak_len;
    return;
    
  case 'get_water_volumes'
    x = value(Left_volume);
    y = value(Right_volume);
    

  case 'reinit',
    currfig = gcf;

    % Get the original GUI position and figure:
    x = my_gui_info(1); y = my_gui_info(2); figure(my_gui_info(3));

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    [x, y] = feval(mfilename, obj, 'init', x, y);

    % Restore the current figure:
    figure(currfig);
end;



