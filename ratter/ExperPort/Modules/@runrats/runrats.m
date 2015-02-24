% RunRats(varargin)
% This is the GUI for technicians in the lab to use for day to day running
% of rats.  The logic of the code follows that of dispatcher.

% Originally written by Jeff Erlich
%     Modifications by Sebastien Awwad, 2007-2008
%     Modifications by Sundeep Tuteja, 2009


function [obj, varargout]=runrats(varargin)

CALLBACK_MFILENAME = 'runrats_wrapper';

HIDE_PROTOCOL=0;

% <~> Argument handling (This interface method is technically a constructor.)
obj = class(struct, mfilename);
varargout = {};
if nargin==0 || nargin==1 && ischar(varargin{1}) && strcmp(varargin{1}, 'empty'),
    return;
end;

% This line is required for the use of SoloParams
GetSoloFunctionArgs;

if nargin>=2 && isa(varargin{1}, class(obj)), action = varargin{2}; varargin = varargin(3:end);
else                                          action = varargin{1}; varargin = varargin(2:end);
end;
if ~ischar(action), error('Runrats expects to be called with a string as the first argument specifying the action to perform. E.g.: runrats(''init'');'); end;

action = lower(action); % <~> We lowercase the action string to be case insensitive.

switch action,
    
    case 'physinit',
        SoloParamHandle(obj,'phys','value',1);
        feval(CALLBACK_MFILENAME, 'init');
        
case 'init',
    %%     case INIT: Construct the module
    
    sync_calibration_data(obj);
    
    %If at this stage we find do not find valid calibration data that is
    %newer than 14 days, we exit out.        
    if ~is_valid_calibration_data_available(obj, 14)
        waitfor(errordlg('It looks like calibration data has expired. Please calibrate and try again.', 'ERROR', 'modal'));
        return;
    elseif ~is_valid_calibration_data_available(obj, 13)
        waitfor(warndlg('WARNING: Calibration data will expire in one day!', 'WARNING', 'modal'));
    elseif ~is_valid_calibration_data_available(obj, 12)
        waitfor(warndlg('WARNING: Calibration data will expire in two days!', 'WARNING', 'modal'));
    end
        
    
    % this syntax means that only a single RunRats module can exist in a instantiaion of matlab
    % This is the desired behavior, since matlab is very serial in its processing, and we do not
    % want to end up waiting.

    % <~> Create a figure for the Dispatcher window.
    if exist('myfig', 'var'),
        if isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)), delete(value(myfig)); end;
    end;
    
    if ~exist('phys','var')
       SoloParamHandle(obj,'phys','value',0);
    end

    % Start and hide the dispatcher.

    dispobj=dispatcher('init');
    h=get_sphandle('owner','dispatcher','name','myfig');
    set(value(h{1}), 'Visible','Off');
    SoloParamHandle(obj, 'dispobj','value',dispobj);
    
    %SoloParamHandle storing the settings file
    SoloParamHandle(obj, 'settings_file_sph', 'value', '');
    SoloParamHandle(obj, 'settings_file_load_time', 'value', 0);


    % The main RunRats window
    if nargin==2
        pos=varargin{2};
    else
        pos=[400 400];
    end
    wh=[650 250];  % width x height
    SoloParamHandle(obj, 'myfig', 'value',...
        figure('Position',[pos wh], ...
        'MenuBar','none', ...
        'ToolBar','none', ...
        'NumberTitle', 'off',...
        'Name','Run Rats GUI',...
        'Resize','off',...
        'closerequestfcn', [CALLBACK_MFILENAME '(''Close'')']) ...
        );
    
try
    jf=get(value(myfig), 'JavaFrame');
    pause(0.01); %total hack for stupid java bug.
    javaMethod('setAlwaysOnTop', jf.fFigureClient.getWindow, 1);
catch
   warning('runrats:java:notontop', 'Failed to keep runrats on top');
end

    % Put a clock on the title.
    t=timer('TimerFcn',['set(' num2str(value(myfig))   ',''Name'', [''RunRats   '' datestr(now, ''mmm dd, HH:MM'')])'], ...
        'Period',60, 'ExecutionMode', 'FixedRate');
    start(t);
    % save a handle to the timer, so that we can delete it when we close
    % the object
    SoloParamHandle(obj, 'figclock' , 'value', t);
    
    
    % <~> Create and start a clock that toggles the color of the main
    %       button whenever a protocol is running. We give it the handle
    %       clockFlicker. It will be started on Run and stopped on End.
    u=timer('TimerFcn',[CALLBACK_MFILENAME '(''flickerRunButtonColor'');'],'Period',0.7, 'ExecutionMode', 'FixedRate');
    SoloParamHandle(obj,'clockFlicker','value',u);


    % Create 2 non-GUI SoloParams, that will be useful.

    SoloParamHandle(obj, 'curProtocol', 'value', '');  %Current Protocol
    SoloParamHandle(obj, 'Session', 'value',1); % This increments with each 'END action'
    SoloParamHandle(obj, 'OldRats', 'value', {''});


    % Then the experimenter menu
    MenuParam(obj, 'ExprmtrMenu', {''}, 1 , 5, 100, 'label', 'Experimenter', ...
        'TooltipString', sprintf('\nPick an experimenter.  Or pick none to\n select a rat using the old system.') ...
        );
    disable(ExprmtrMenu); %#ok<NODEF>
    mh= get_ghandle(ExprmtrMenu);
    lh=get_glhandle(ExprmtrMenu);
    set(mh,'ButtonDownFcn','');  % This prevents the auto_set dialog from accidentaly popping up.
    set(lh(2), 'Position', [180 205 190 35]);
    set(mh, 'FontSize', 24);
    set(lh(2), 'FontSize', 24);
    set(lh(2), 'BackgroundColor', [1 .7 .4]);
    ph=get(mh,'Parent');
    set(ph, 'BackgroundColor',[1 .7 .4]);
    set(ph, 'BorderType','none');
    set(mh, 'Position', [10 210 170 35]);
    set_callback(ExprmtrMenu , {CALLBACK_MFILENAME, 'do_ExprmtrMenuCallback'}); % <~> 2008.June.08: fillRatMenu -> do_ExprmtrMenuCallback

    % The Rat Menu
    MenuParam(obj, 'RatMenu', {''}, 1 , 5, 5, 'label', 'Rat', ...
        'TooltipString', sprintf('\nPick an experimenter.  Or pick none to\n select a rat using the old system.') ...
        );
    disable(RatMenu); %#ok<NODEF>
    set_callback(RatMenu,{CALLBACK_MFILENAME,'do_RatMenuCallback'});
    mh= get_ghandle(RatMenu);
    set(mh,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
    lh=get_glhandle(RatMenu);
    set(mh, 'FontSize', 24);
    set(lh(2), 'FontSize', 24);
    set(lh(2), 'BackgroundColor', [1 .7 .4]);
    set(lh(2), 'Position', [180 173 50 34]);
    set(mh, 'Position', [10 175 170 35]);

    
    % <~> New section (starting 2008.July.24 locally) for Brody Lab--only
    %       controls and displays. (I just didn't want to clutter things
    %       for other labs.)
    if Settings('compare','GENERAL','Lab','Brody'),

        % <~> New: Select any of the day's schedule slots.
        MenuParam(obj, 'SchedList', {'(Not Enabled Here)'}, 1 , 180, 120, 'label', 'Change Timeslot', ...
            'TooltipString', sprintf('\nSelect to load a rat running at a different time.'), ...
            'position',[10 140 290 35]);
        set_callback(SchedList,{CALLBACK_MFILENAME,'do_SchedListCallback'});
        hMain  = get_ghandle( SchedList);
        hLabel = get_glhandle(SchedList);
        set(hMain,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
        set(hMain, 'FontSize', 16);
        set(hLabel(2), 'FontSize', 16);
        set(hLabel(2), 'BackgroundColor', [1 .7 .4]);
        set(hMain,'Position', [10 140 210 35]);
        set(hLabel(2), 'Position', [220 140 130 29]);
        set(hMain,'enable','on');
        
        % <~> New: Tech instructions display field.
        DispParam(obj, 'Instructions', '', 180, 100, ...
            'label','', ...
            'TooltipString', 'Special instructions for this rat today. (This is only available via the Brody Lab msyql service.)');
        hMain  = get_ghandle( Instructions);
        hLabel = get_glhandle(Instructions);
        set(hMain,'Position',[10 100 350 40], ...
            'FontSize', 14, ...
            'BackgroundColor',[1 .7 .4]); % <~> temporarily shifted color
        set(hLabel(2),'Position',[0 0 1 1],...
            'BackgroundColor',[1 .7 .4]);
        
        % <~> New: LED Toggle button. Only make if stim1 exists as a DIOLine
        alldio=Settings('get','DIOLINES','ALL');
        if ~isempty(alldio) && sum(strcmp(alldio(:,1),'stim1')) > 0
            PushbuttonParam(obj, 'LEDs', 40, 55,  ...
                'TooltipString', sprintf('\nCycles through the stim DIOLines') ...
                );
            set_callback(LEDs , {CALLBACK_MFILENAME, 'cycleleds'});

            mh= get_ghandle(LEDs);
            set(mh,'ButtonDownFcn','');
            set(mh, 'Position', [10 100 60 35]);
            set(mh, 'FontSize', 14);
            set(mh, 'String', 'LEDs');
            set(mh, 'BackgroundColor', [0.9 0.9 0.9]);
        end
        
        % <~> New: IR Light Toggle button. Only make if IRLEDs exists as a DIOLine
        alldio=Settings('get','DIOLINES','ALL');
        if ~isempty(alldio) && sum(strcmp(alldio(:,1),'irleds')) > 0
            PushbuttonParam(obj, 'IR_LEDs', 40, 55,  ...
                'TooltipString', sprintf('\nTurns on Ceiling IR LEDs') ...
                );
            set_callback(IR_LEDs , {CALLBACK_MFILENAME, 'irled'});

            mh= get_ghandle(IR_LEDs);
            set(mh,'ButtonDownFcn','');
            set(mh, 'Position', [10 100 100 35]);
            set(mh, 'FontSize', 14);
            set(mh, 'String', 'IR_LEDs');
            set(mh, 'BackgroundColor', [0.2 0.2 0.2]);
        end
        
        % <~> New: Tech comments window.
        EditParam(obj,'TechComment',' ',180,120,'label',sprintf('Tech\nNote:'),'TooltipString','Comments entered here before data is saved are submitted.');
        hMain  = get_ghandle( TechComment);
        hLabel = get_glhandle(TechComment);
        set(hLabel(2), 'Position', [360 210 32 34], ...
            'FontSize',12, ...
            'BackgroundColor',[1 .7 .4]);
        set(hMain, 'Position', [395 215 250 35], ...
            'FontSize', 12, ...
            'BackgroundColor',[1 .7 .4]);
        
        
        % <~> New variable, 2008.Sep.02, for preserving day's schedule.
        %     This is populated in runrats.m:fillSchedList with the
        %       full schedule for today for this rig. Clicking on an
        %       element in this menu will switch to that rat. Its
        %       convenience is born of the fact that it is labeled with
        %       times and kept up-to-date.
        SoloParamHandle(obj,'schedDay','value',[]);
        
    end; %     end section for Brody Lab--only controls and displays

    
    %     The Rescan Current Experimenter Button
    PushbuttonParam(obj, 'ReScanExp', 40, 55,   ...
        'BackgroundColor', [.5 .8 1],           ...
        'TooltipString', 'Clicking this updates all settings for the current experimenter.');
    set(get_ghandle(ReScanExp),                 ...
        'String', 'Update Experimenter',       ...
        'FontSize', 12,                         ...
        'Position', [120 55 140 35],            ...
        'ButtonDownFcn','');
    set_callback(ReScanExp , {CALLBACK_MFILENAME, 'updateExperimenterCurrent'});
    disable(ReScanExp);
    %     The Rescan All Button
    PushbuttonParam(obj, 'ReScan', 40, 55,      ...
        'BackgroundColor', [.5 .8 1],           ...
        'TooltipString', 'Clicking this updates all code and all settings.');
    set(get_ghandle(ReScan),                    ...
        'String', 'Update ALL',                 ...
        'FontSize', 14,                         ...
        'Position', [265 55 105 35],            ...
        'ButtonDownFcn','');
    set_callback(ReScan , {CALLBACK_MFILENAME, 'updateAll'});
    disable(ReScan);
    
%     mh= get_ghandle(ReScan);
%     set(mh, ...
%         'ButtonDownFcn','',             ...
%         'Position', [130 55 110 35],    ...
%         'FontSize', 14,                 ...
%         'BackgroundColor', [.5 .8 1],   ...
%         'String', 'Update ALL',         ...
%         'TooltipString', 'Clicking this updates all code and all settings.');
	
	 % The Water Button
    PushbuttonParam(obj, 'FlushValves', 40, 55,  ...
        'TooltipString', sprintf('\nFlush valves at the beginning of the day') ...
        );
    set_callback(FlushValves , {CALLBACK_MFILENAME, 'flushWaterValves'});

    mh= get_ghandle(FlushValves);
    set(mh,'ButtonDownFcn','');
    set(mh, 'Position', [5 55 110 35]);
    set(mh, 'FontSize', 14);
    set(mh, 'String', 'Flush Valves');
	set(mh, 'BackgroundColor', [.5 0 .8]);

    

    % The MultiPurpose Button
    PushbuttonParam(obj, 'Multi', 260, 25, 'label','Load Settings', ...
        'TooltipString', sprintf('\nAfter you select the Experimenter and Rat, press this button to initialize the protocol and load the settings.') ...
        );

    set_callback(Multi , {CALLBACK_MFILENAME, 'Load'});
    disable(Multi);
    SoloFunctionAddVars('get_runbutton', 'rw_args','Multi'); % <~> Added June 3 2008
    mh= get_ghandle(Multi);
    set(mh,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
    set(mh, 'Position', [380 65 240 150]);
    set(mh, 'FontSize', 24);
    set(mh, 'BackgroundColor', [.99 1 .62]);

    % The Status Bar
    SubheaderParam(obj,'StatusBar','Ready',5,5);
    mh= get_ghandle(StatusBar); %#ok<NODEF>
    set(mh,'ButtonDownFcn','');   % This prevents the auto_set dialog from accidentaly popping up.
    set(mh, 'Position', [0 0 650 45]);
    set(mh, 'FontName','Arial');
    set(mh, 'FontSize',14);
    set(mh, 'BackgroundColor', [.9 1 1]);

    drawnow;
    SoloParamHandle(obj,'ttt','value',t); % <~> Is this even used??

    % <~> This timer is a part of the stopping process for individual
    %       sessions. It is started shortly after the end button is pressed
    %       and when it is triggered later after the next Dispatcher
    %       update, the ending process continues. Without this awkward
    %       flow, problematic race conditions arise.
    scr = timer;
    set(scr, ...
        'Period', 0.2, ...
        'tag','runrats__stopping_complete_timer', ...
        'ExecutionMode', 'FixedRate', ...
        'TasksToExecute', Inf, ...
        'BusyMode', 'drop', ...
        'TimerFcn', [CALLBACK_MFILENAME '(''End_Continued'')']);
    SoloParamHandle(obj, 'stopping_complete_timer', 'value', scr);

    
    % <~> This call sets up the menus for the first rat to run.
    feval(CALLBACK_MFILENAME, 'prepare_next_session'); % <~> 2008.June.08    

    %     end of case init

    case 'get_experimenter_ratname_info'
        try
            varargout{1} = value(ExprmtrMenu);
            if isempty(varargout{1})
                varargout{1} = 'experimenter';
            end
            varargout{2} = value(RatMenu);
            if isempty(varargout{2})
                varargout{2} = 'ratname';
            end
        catch
            varargout{1} = 'experimenter';
            varargout{2} = 'ratname';
        end
        return;
        
        %% case get_settings_file_load_time
    case 'get_settings_file_load_time'
        if exist('settings_file_load_time', 'var') && isa(settings_file_load_time, 'SoloParamHandle')
            varargout{1} = value(settings_file_load_time);
        else
            varargout{1} = 0;
        end
        return;
        
        
    case 'prepare_next_session'
        %%     case prepare_next_session
        %       1. Update Code.
        %       2. Select Next Rat & Update Settings
        %       3. Unload Previous Protocol (if loaded)
        %       4. Allow User to Continue Onto Manual Test
        
        % <~> Lock menus to prevent race conditions.
        feval(CALLBACK_MFILENAME,'disableGUIControls');

        % <~> ---1--- Update Code
        %StatusBar.value='Updating code in case of changes to BControl.';
        mh = get_ghandle(value(Multi)); % <~> Fetch Run button's gui handle.
        set(mh,'BackgroundColor',[1,1,1],'String','Updating CODE'); pause(0.1);
        getLatestCode();
        

        % <~> ---2--- Select Next Rat & Update Settings
        %       ONLY IF THE Schedule_Checking FLAG IS ON,
        %       Use the wiki to determine which experimenter&rat are
        %       running next in this rig, download its settings, and select
        %       it in the menus.
        if Settings('compare','GENERAL','Schedule_Checking',1),
            [nextrat errID] = determine_next_rat_mysql();
            if ~errID && ~isempty(nextrat) && ~isempty(nextrat.ratname),
                feval(CALLBACK_MFILENAME,'updateRat',nextrat.experimenter,nextrat.ratname);
            end;                %     end if detnextrat results are valid
        else
            nextrat.experimenter = 1;   % <~> default experimenter: blank
            nextrat.ratname = 1;        % <~> default rat: blank
        end;                    %     end if-else schedule checking is on
        
        % <~> New section (starting 2008.July.24 locally) for Brody Lab--only
        %       controls and displays. (I just didn't want to clutter things
        %       for other labs.)
        if Settings('compare','GENERAL','Lab','Brody'),
            
            % <~> New code for tech instructions.
            %       (Active when mysql scheduling is turned on.)
            if isfield(nextrat,'instructions'), % && ~isempty(nextrat.instructions),
                Instructions.value = nextrat.instructions;
            end;
            TechComment.value = ' ';            % <~> Clear the technician notes from the last rat.

        
        end; %     end new section for Brody Lab only
        
        
        % <~> Fill the menus.
        feval(CALLBACK_MFILENAME,'do_fillExprmtrMenu');      % <~> Fill the experimenters menu.
        ExprmtrMenu.value   = nextrat.experimenter; % <~> Select the next or blank experimenter.
        feval(CALLBACK_MFILENAME,'do_fillRatMenu');          % <~> Fill the rats menu.
        RatMenu.value       = nextrat.ratname;      % <~> Select the next or blank rat.

        % <~> 2008.Sep.02. If Brody Lab, fill the schedule list that can be
        %       be used to switch to a different timeslot during the day.
        if Settings('compare','GENERAL','Lab','Brody'),
            feval(CALLBACK_MFILENAME,'do_fillSchedList');
        end;
        
        % <~> ---3--- Unload Previous Protocol (if loaded) and
        % <~> ---4--- Allow User to Continue Onto Manual Test
        feval(CALLBACK_MFILENAME,'readyToLoad'); 

        
    case 'do_fillschedlist',
        %% <~> case do_fillSchedList
        %     This case queries the full schedule from the mysql server and
        %       populates a menu that can be used to view or select rats &
        %       experimenters corresponding to particular times of the day
        %       from today's schedule for the current rig. This is a
        %       Brodylab-only feature that is part of the Zut suite.
        %     It should only be called if the following evaluates to true:
        %       Settings('compare','GENERAL','Lab','Brody');

        %     FIRST, disable the GUI menu since we'll be changing it.
        disable(SchedList);
        
        %     SECOND, attempt to retrieve the day's schedule from the mysql
        %       table using Zut:getDaySched.
        [schedDay_temp errID errmsg] = getDaySched(clock,getRigID);
        %     If we weren't successful for whatever reason, empty the
        %       schedule SPH and menu GUI, then leave the menu GUI disabled
        %       and just return.
        if errID || isempty(schedDay_temp),
            SchedList.value = {'(Can''t Connect to Sched)'};
            schedDay.value  = [];
            warning('RUNRATS:Zut',['Unable to retrieve day''s schedule in effort to fill SchedList GUI. getDaySched returned: ' errmsg]);
            return;
        end;
        
        %     THIRD, save the day's schedule struct in a SoloParamHandle
        %       for access if the technician uses the SchedList GUI to
        %       switch to another of the day's sessions.
        schedDay.value      = schedDay_temp;

        %     FOURTH, create a string array to display in the SchedList
        %       menu GUI to allow selection of a session.
        nTimeslots          = length(schedDay_temp);
        list_temp           = cell(nTimeslots,1);
        for i=1:nTimeslots,
            list_temp{i}    = [lookup_timeslot(i) ': ' schedDay_temp(i).ratname];
        end;

        %     Fetch the GUI handle of the SchedList menu and change its
        %       displayed string of options to the spooled schedule we just
        %       generated.
        mh=get_ghandle(SchedList);
        list_temp={'' list_temp{:}};
        set(mh,'String',list_temp);
        
        if ~isempty(list_temp), set(mh,'Enable','on'); end;
        
        
        feval(CALLBACK_MFILENAME,'readyToLoad'); 
        
        %           end case do_fillSchedList

        
    case 'readytoload',  
        %%     case readyToLoad
        % <~> This case is called as part of the normal
        %       prepare_next_session sequence, after the updating and
        %       schedule checking is done, but also if a rat is manually
        %       selected/changed, each time that happens.

        % <~> Double-check that the control buttons are disabled, just in
        %       case the protocol is later changed recklessly.
        feval(CALLBACK_MFILENAME,'disableGUIControls');
        
        % <~> Unload previous protocol (if loaded)
        dispatcher('set_protocol','');
        
        % <~> Check Brody Lab mysql database for special instructions if
        %       this is a Brody Lab rig.
        if Settings('compare','GENERAL','Lab','Brody'),
            %     Reset instructions box color in case it was red from last
            %       session. It turns red for comments starting with "!!".
            set(get_ghandle( Instructions),'BackgroundColor',[1 .7 .4]);
            set(get_glhandle(Instructions),'BackgroundColor',[1 .7 .4]);
            strInstructions = '';
            try %     Use date, rig, experimenter, and ratname to guess which session this should be. We don't use timeslot because sometimes times are off and we still want instructions to appear correctly....
                strInstructions = bdata(['select instructions from ratinfo.schedule where date="' ...
                    datestr(now,'yyyy-mm-dd') '" and rig=' int2str(getRigID()) ...
                    ' and experimenter="' value(ExprmtrMenu) ...
                    '" and ratname="' value(RatMenu) '"']);
                strInstructions = strInstructions{1};
            catch
                strInstructions = '';
            end;
            if ischar(strInstructions),
                feval(CALLBACK_MFILENAME,'set_special_instructions',strInstructions);
            end;
        end; %     end if setting GENERAL;Lab;Brody

        % <~> Modified code just below to allow skipping of manual test on
        %       experimenters' emulators etc, based on a setting.
        if Settings('compare','RUNRATS','skip_manual_test',1),
            % <~> Pressing the main button will now load the protocol.
            set_callback(Multi , {CALLBACK_MFILENAME, 'load'});
        else
            % <~> Pressing the main button will now load the manual test.
            set_callback(Multi , {CALLBACK_MFILENAME, 'preload_test'});
        end;
        
        % <~> Relabel main button.
        mh= get_ghandle(Multi);
        set(mh,'BackgroundColor',[.99,1,.62],'String','Load Protocol');
        
        % <~> Unlock control buttons for user input.
        feval(CALLBACK_MFILENAME,'enableGUIControls');


        % <~> Then we do nothing until user presses main button, which now
        %       calls the preload_test case below.

    case 'do_exprmtrmenucallback'
        %% <~> case do_ExprmtrMenuCallback
        %     When an experimenter is selected/changed MANUALLY through the
        %       gui, we:
        %           1: Update the rat menu (to contain his rats).
        %           2: Update the settings of the first rat in the list.
        %                We HAVE to do this because if we don't, and it is
        %                this first rat that needs to run, there is a
        %                special case in which rat settings would not
        %                otherwise be updated for this rat (if the
        %                experimenter is manually, not automatically,
        %                selected, and the rat to be run is the first rat
        %                in the list).
        disable(RatMenu);
        try
        feval(CALLBACK_MFILENAME,'do_fillRatMenu');
        feval(CALLBACK_MFILENAME,'updateRat',value(ExprmtrMenu),value(RatMenu));
        feval(CALLBACK_MFILENAME,'readyToLoad');
        catch
        end
        enable(RatMenu);

    case 'do_ratmenucallback'
        %% <~> case do_RatMenuCallback
        %     When a rat is selected/changed MANUALLY through the gui, we
        %       update the rat's settings and run preload_test to prepare
        %       the manual test that precedes each rat session.
        feval(CALLBACK_MFILENAME,'updateRat',value(ExprmtrMenu),value(RatMenu));
        feval(CALLBACK_MFILENAME,'readyToLoad');

    case 'do_schedlistcallback'
        %% <~> case do_SchedListCallback
        %     When it exists, the Schedule List displays all sessions to be
        %       performed today by this rig. When a value is selected, the
        %       experimenter and rat should be switched accordingly,
        %       settings should be updated for that rat, and special
        %       instructions should be loaded if they exist.
        
        %     Find out which timeslot was selected.
        %     Unfortunately, this comes to us as the string. We need the
        %       integer index of this string in the list of strings in that
        %       menu - i.e. the timeslot of that session (+1).
        timeslotSelected    = value(SchedList);
        %     To get the index, we loop over the possible values. /: There
        %       are only a few, so this is okay... though it is icky.
        strSessions = get(get_ghandle(SchedList),'String'); %     Get the list of sessions/strings in the SchedList menu. Cell array.
        for i=1:length(strSessions),
            if strcmp(strSessions{i},timeslotSelected),
                timeslotSelected = i-1;
                break;
            end;
        end;
        if ~isnumeric(timeslotSelected), return; end;
        
        
        %     Get the name of the rat and experimenter from the schedule
        %       for the day, which was saved on loading.
        %     The information saved in the variable schedDay is retrieved
        %       via the function getDaySched, in Utility/Zut/. It is
        %       populated when RunRats loads, by looking at the MySQL table
        %       ratinfo.schedule for the Brody Lab.
        expSelected         = schedDay(timeslotSelected).experimenter;
        ratSelected         = schedDay(timeslotSelected).ratname;
        instrSelected       = schedDay(timeslotSelected).instructions;

        %     If the selected timeslot doesn't have an associated rat, do
        %       nothing.
        if isempty(ratSelected), return; end;
            
        %     Update settings for the selected rat.
        feval(CALLBACK_MFILENAME,'updateRat',expSelected,ratSelected);
        
        %     Set the experimenter and rat menus accordingly.
        ExprmtrMenu.value = expSelected;
        feval(CALLBACK_MFILENAME,'do_fillRatMenu');
        RatMenu.value     = ratSelected;
        
        %     Set special instructions, if they exist.
        feval(CALLBACK_MFILENAME,'set_special_instructions',instrSelected);
        
        feval(CALLBACK_MFILENAME,'readyToLoad');
        
    case 'preload_test'
        %%     case preload_test
        % <~> Load the Rigtest Singletrial protocol and start it. When it
        %       completes, the loading process will continue.
        
        % <~> Disable the multi-purpose button and change it so that it's
        %       ready for the next stage: the start of the manual test.
        feval(CALLBACK_MFILENAME,'disableGUIControls');
        
        mh=get_ghandle(Multi);
        set(mh,'String','Loading Test...');
        StatusBar.value='Loading rig test - please be patient!';
        set(mh, 'BackgroundColor', [.8 0.8 0.9]);
        
        dispatcher('set_protocol','Rigtest_singletrial');

        % <~> Hide protocol window.
        h=get_sphandle('owner','Rigtest_singletrial','name', 'myfig');
        for hi=1:numel(h)
            set(value(h{hi}), 'Visible','Off');
        end;
        
        set(mh,'String','MANUAL TEST');
        StatusBar.value='Please test the rig by poking in the lit pokes.';
        enable(FlushValves); % <~> Re-enable only FlushValves to allow flushing during the manual test for convenience.
        
        % <~> Begin execution of the manual test protocol.
        dispatcher(value(dispobj),'Run'); %#ok<NODEF>
        
        % <~> Then we return and do nothing until the protocol
        %       RigTest_singletrial calls
        %       runrats('rigtest_singletrial_is_complete'), the case below,
        %       to continue the loading process.
        
        

    case 'do_fillexprmtrmenu'
        %%     case do_fillExprmtrMenu
        % <~> The actual function of filling the experimenter menu needs to
        %       be done in several different places, so I'm divorcing the
        %       code tied to the progress of runrats's loading from the
        %       actual modular utility code. I'm not changing the original
        %       fn name because I have no interest in breaking things.
        mh=get_ghandle(ExprmtrMenu);
        [xprs, OldRats.value]=getExperimenters;
        xprs{end+1}='None';
        xprs={'' xprs{:}};
        set(mh,'String',xprs);
        ExprmtrMenu.value = 1; % <~> Select blank.

    case 'do_fillratmenu'        
        %%     case do_fillRatMenu
        % <~> The actual function of filling the rat menu needs to
        %       be done in several different places, so I'm divorcing the
        %       code tied to the progress of runrats's loading from the
        %       actual modular utility code. I'm not changing the original
        %       fn name because I have no interest in breaking things.
        mh=get_ghandle(RatMenu);
        % <~> If 'None' is the experimenter selected and we're supposed to
        %       fill the rat menu, we load up the rats without associated
        %       experimenters (old).
        if strcmp(value(ExprmtrMenu), 'None')
            set(mh, 'String', value(OldRats)); %#ok<NODEF>
        elseif isempty(value(ExprmtrMenu))
            set(mh, 'String', {''});
        else
            rats=getRats(value(ExprmtrMenu));
            set(mh, 'String', rats);
        end
		RatMenu.value = 1; % <~> Select blank.
        
    
    case 'updaterat'
        %%     case updateRat
        % <~> Update settings directory for a given rat.
        %     The runrats control buttons should already be disabled when
        %       calling this case.
        
        % <~> Verify arguments: 2 args, all strings.
        error(nargchk(2,2,length(varargin),'struct'));
        experimenter    = varargin{1};
        ratname         = varargin{2};
        if ~ischar(experimenter) || ~ischar(ratname),
            error('runrats.m:updateRat expects experimenter name and rat name strings, e.g. runrats(''updateRat'',''Lucy'',''L013'');');
        end;

        % <~> Relabel the big Run button to show what's going on.
        mh = get_ghandle(Multi); % <~> Fetch its gui handle.
        strOldLabel = get(mh,'String');
        iOldBGColor = get(mh,'BackgroundColor');
        set(mh,'BackgroundColor',[1,1,1]);
        set(mh,'String',['Updating ' experimenter ': ' ratname]); pause(0.05);
        
        % <~> Download the settings for the indicated rat.
        updateSettings(experimenter,ratname);
        
        % <~> Restore old label to big Run button to show we're done.
        set(mh,'BackgroundColor',iOldBGColor);
        set(mh,'String',strOldLabel);
        
        
    case 'updateexperimenter'
        %%     case updateExperimenter
        % <~> Update settings directory for an experimenter (all rat dirs).
        %     The runrats control buttons should already be disabled when
        %       calling this case.
        
        % <~> Verify arguments: 1 arg, string.
        error(nargchk(1,1,length(varargin),'struct'));
        experimenter    = varargin{1};
        if ~ischar(experimenter),
            error('runrats.m:updateExperimenter expects experimenter name string, e.g. runrats(''updateExperimenter'',''Lucy'');');
        end;

        feval(CALLBACK_MFILENAME,'updateRat',experimenter,'_all');

    case 'updateexperimentercurrent'
        %% <~> case updateExperimenterCurrent
        %     Update settings dir for experimenter selected currently.

        feval(CALLBACK_MFILENAME,'disableGUIControls');          % <~> Disable all controls during scan.
        error(nargchk(0,0,length(varargin),'struct'));  % <~> Verify arguments: 0 args
        feval(CALLBACK_MFILENAME,'updateExperimenter',value(ExprmtrMenu));
        feval(CALLBACK_MFILENAME,'enableGUIControls');           % <~> Re-enable all controls after scan.

        
    case 'updateall'
        %% <~> case updateall
        %     Update settings directory for all experimenters and update
        %       code directory.
        
        feval(CALLBACK_MFILENAME,'disableGUIControls');          % <~> Disable all controls during scan.
        getLatestCode();                                % <~> Grab latest code.
        feval(CALLBACK_MFILENAME,'updateRat','_all','_all');     % <~> Grab all latest settings.
        feval(CALLBACK_MFILENAME,'enableGUIControls');           % <~> Re-enable all controls after scan.


	case 'cycleleds'
        %%     case cycleLEDs
        % <~> When the LEDs button is pressed the each of the stim DIOLines
        % is toggled for 0.5s after a delay of 3s
		
		disable(LEDs);
		oldval=value(StatusBar);
		StatusBar.value='Toggling LEDs. Observe Implant';
		diolist=[]; 
		
        % <~> Fetch the values of the stim output channels.
		alldio=Settings('get','DIOLINES','ALL');
        for di=1:size(alldio,1)
            if ~isempty(strfind(alldio{di,1},'stim')) && ~isnan(alldio{di,2})
                diolist=[diolist alldio{di,2}]; %#ok<AGROW>
            end
        end
        
        % <~> Take the log of the channel values to get the channel numbers
        %       that dispatcher needs to toggle bypass lines.
        diolist = log2(diolist);
		
        % <~> Call dispatcher to toggle the stim lines in succession
        pause(3);
        for c = 1:length(diolist)
            dispatcher('toggle_bypass',diolist(c));
            pause(0.2);
            dispatcher('toggle_bypass',diolist(c));
            pause(1);
        end
		
		StatusBar.value=oldval;
        enable(LEDs);
        
        
	case 'irled'
        %%     case irleds
        % <~> The IR_LEDs button will toggle the ceiling IR LEDs
		
		diolist=[]; 
		
        % <~> Fetch the values of the stim output channels.
		alldio=Settings('get','DIOLINES','ALL');
        for di=1:size(alldio,1)
            if ~isempty(strfind(alldio{di,1},'irleds')) && ~isnan(alldio{di,2})
                diolist=[diolist alldio{di,2}]; %#ok<AGROW>
            end
        end
        
        % <~> Take the log of the channel values to get the channel numbers
        %       that dispatcher needs to toggle bypass lines.
        diolist = log2(diolist);
		
        % <~> Call dispatcher to toggle the stim lines in succession
        for c = 1:length(diolist)
            pause(0.1);
            dispatcher('toggle_bypass',diolist(c));
            
            mh= get_ghandle(IR_LEDs);
            bc = get(mh, 'BackgroundColor');
            if c == 1
                if bc(1) == 0.2
                    set(mh,'BackgroundColor',[0.9 0.9 0.9]);
                else
                    set(mh,'BackgroundColor',[0.2 0.2 0.2]);
                end
            end
            
            pause(0.1);
        end
        
        
	case 'flushwatervalves'
        %%     case flushWaterValves
        % <~> When the flush valves button is pressed, the bypass buttons
        %       should be set so that all water valves are opened, for 10
        %       seconds.
		
		disable(FlushValves);
		oldval=value(StatusBar);
		StatusBar.value='Flushing Valves for 10 seconds';
		diolist=[]; % <~> stripped the 0, 2008.June.08
		
        % <~> Fetch the values of the water valve output channels.
		alldio=Settings('get','DIOLINES','ALL');
        for di=1:size(alldio,1)
        if ~isempty(strfind(alldio{di,1},'water')) && ~isnan(alldio{di,2})
			diolist=[diolist alldio{di,2}]; %#ok<AGROW>
        end
        end
        
        % <~> Take the log of the channel values to get the channel numbers
        %       that dispatcher needs to toggle bypass lines.
        diolist = log2(diolist);
		
        % <~> Call dispatcher to toggle the water valves selected via
        %       bypass, wait 10 seconds, then toggle again.
        dispatcher('toggle_bypass',diolist);
        pause(10);
        dispatcher('toggle_bypass',diolist);
        
        % <~> Removed the old, fsm-direct mode of bypassing used below,
        %       2008.June.08
        %
        %
        % 		fsm=dispatcher('get_state_machine');
        %
        % 		BypassDout(fsm, sum(diolist));
        % 		pause(10)
        % 		BypassDout(fsm, 0);
        %
        % 		clear fsm;
		
		StatusBar.value=oldval;
        enable(FlushValves);

%% Close

    case  'close'
        %%     case close
        try
            StatusBar.value='Cleaning up......';
            feval(CALLBACK_MFILENAME,'disableGUIControls'); % <~> Disable all controls during close attempt.
        catch
            warning('Close attempt in runrats:close failed.'); %#ok<WNTAG>
        end
        try
            stop(value(figclock));
            stop(value(clockFlicker)); % <~> added 2008.June.08
            delete(value(figclock));
            delete(value(clockFlicker)); % <~> added 2008.June.08
        catch
        end
        % should we check if it exists first?
        try
            dispatcher(value(dispobj),'close');
        catch
            warning('Dispatcher:close attempt in runrats:close failed.'); %#ok<WNTAG>
        end
        delete(value(myfig));

        delete_sphandle('owner', ['^@', mfilename '$']);
        obj = [];


%% Load
    case  'load'
        %%     case load

        %change label to 'Loading....'
        disable(Multi);
        mh=get_ghandle(Multi);
        
        % <~> Code to specifically update the settings for the rat
        %       selected. New runrats private method.
        if Settings('compare','GENERAL','Schedule_Checking',1),
            set(mh,'String',['Updating ' value(RatMenu)]);
            updateSettings(value(ExprmtrMenu),value(RatMenu));
        end;

        set(mh,'String','Loading...');        %find protocol
        set(mh, 'BackgroundColor', [0.8 0.8 0.6])

        StatusBar.value='Loading protocol and settings.  Please be patient!';
        curProtocol.value=getProtocol(value(ExprmtrMenu), value(RatMenu));
        if isempty(value(curProtocol))
            StatusBar.value=['No Settings for ' value(RatMenu)];
            feval(CALLBACK_MFILENAME, 'readyToLoad');
            return;
        end
        try
        dispatcher(value(dispobj),'set_protocol',value(curProtocol));         %load protocol
        catch
            StatusBar.value=['"' value(curProtocol) '" failed to load. Incompatible w/ Dispatcher?'];
            le=lasterror;
            fprintf(1,[le.message '\n']);
            fprintf(1,'On line %i in %s', le.stack(1).line, le.stack(1).file);
            feval(CALLBACK_MFILENAME, 'readyToLoad');
            return;
        end
        % hide protocol?

        if HIDE_PROTOCOL
            h=get_sphandle('owner',value(curProtocol),'name', 'myfig');
            for hi=1:numel(h)
                set(value(h{hi}), 'Visible','Off');
            end
        end


        rath=get_sphandle('name','ratname','owner',value(curProtocol));
        exph=get_sphandle('name','experimenter','owner',value(curProtocol));
        rath{1}.value=value(RatMenu); %#ok<NASGU>
        exph{1}.value=value(ExprmtrMenu); %#ok<NASGU>
        try
            protobj=eval(value(curProtocol));
            
            [out, sfile]=load_solouiparamvalues(value(RatMenu),'experimenter',value(ExprmtrMenu),...
                'owner',class(protobj),'interactive',0);
              settings_file_sph.value = sfile;
              settings_file_load_time.value = now;
              if ~dispatcher('is_running'),
                % If we're not yet running, then current stored values for this
                % trial will be overriden by the settings that are being loaded
                % before the trial starts. Pop the history.  Added by CDB to fix
                % bug introduced by 'prepare_next_trial' below.
                pop_history(class(protobj), 'include_non_gui', 1);
                feval(value(curProtocol), protobj, 'prepare_next_trial');
              end;  % If we *are* already running a trial, then prepare_next_trial will be run when the trial ends, so don't do it now.
        catch
            display(lasterr)
        end

        %load settings
        %change button to RUN
        mh=get_ghandle(Multi);
        set(mh,'String',['RUN: ' value(RatMenu)], 'BackgroundColor', [.3 1 .3]);
        set_callback(Multi , {CALLBACK_MFILENAME, 'RUN'});
        while ~isempty(sfile)
            [r,sfile]=strtok(sfile,filesep);
        end
        StatusBar.value=['Using settings file : ' r];
        if value(phys)==1
                create_phys_session(eval(value(curProtocol)))
        end
		
        feval(CALLBACK_MFILENAME,'enableGUIControls');           % <~> Re-enable all controls.

        figure(value(myfig));
    
    %% get_settings_file_path    
    case 'get_settings_file_path'
        if exist('settings_file_sph', 'var') && isa(settings_file_sph, 'SoloParamHandle')
            varargout{1} = value(settings_file_sph);
        else
            varargout{1} = '';
        end


%% RUN
    case  'run'
        %%     case run
        feval(CALLBACK_MFILENAME,'disableGUIControls'); % <~> Disenable all controls after scan.

        mh=get_ghandle(Multi);
        set(mh,'String',sprintf(['End Session:' value(RatMenu)]), 'BackgroundColor', [1 .3 .36]);
        set_callback(Multi , {CALLBACK_MFILENAME, 'End'});

        StatusBar.value = ['Start Time: ' datestr(now,'HH:MM PM') '. ' value(StatusBar)]; %#ok<NODEF>

        % <~> Start the clock that causes the color of the run button to
        %       flicker so that if e.g. MATLAB freezes, it will be noticed.
        try, start(value(clockFlicker)); catch, end; %#ok<NOCOM> % <~> If the clock is already started for some stupid reason, that's fine.
        
        % <~> Re-enable only the stop button so that the user can end the
        %       session.
        enable(Multi); % <~> moved this up so that it occurs before Run (necessary because of no-timers case)
		
		try
			% <~> Sends the starttime to the sess_started sql table, added 20091214
			sendstarttime(eval(value(curProtocol))); %#ok<NODEF>
        catch
			fprintf(2, 'Failed to call starttime from runrats\n');
			showerror
		end;
		
        % <~> Moved this run command down from near the top of this
        %       case so that dispatcher without timers will execute
        %       them when intended instead of after the loop returns.
        %       2007.09.06 afternoon
        % THIS STARTS THE RUNNING!
        dispatcher(value(dispobj), 'Run'); %#ok<NODEF>
        
        

%% End Experiment

    case  'end'
        %%     case end
        %     This case signals for dispatcher to stop the experiment on
        %       the next update.
        %     Unfortunately, we have no way of waiting for dispatcher to
        %       finish stopping in this code (This is much more complex
        %       than it appears; ask me in person before making changes.),
        %       so we spawn a timer that calls the End_Continued case
        %       below to do the checking for us.

        % <~> Stop the clock that causes the color of the run button to
        %       flicker now that we're done running.
        stop(value(clockFlicker));
        
        %Change Label to 'saving'
        lh=get_ghandle(Multi);
        set(lh,'String','Saving...');
        disable(Multi);

        dispatcher(value(dispobj),'Stop'); %#ok<NODEF>
        if strcmp('on', get(value(stopping_complete_timer),'Running')), 
            warndlg('Curious behavior observed. Please contact a developer with the warning message printed in the command window! You may continue as normal.');
            warning('In runrats(rigtest_singletrial_is_complete), the stopping_complete_timer was already running when it was to be started. The timer properties are printed below.'); %#ok<WNTAG>
            display(get(value(stopping_complete_timer)));
            display(' ');
            display('Stopping the timer now.');
            stop(value(stopping_complete_timer));
        end;
        set(value(stopping_complete_timer), 'TimerFcn', [CALLBACK_MFILENAME '(''End_Continued'');']);
        
        % <~> We start the timer here. It is stopped after the next update,
        %       and then the case below, End_Continued, is called.
        start(value(stopping_complete_timer));

        
    case 'end_continued',
        %%     case end_continued
        %     If the stopping process is done, we continue our sequence of
        %       end-experiment actions and stop the timer. Otherwise, we
        %       wait until the next timer event. Rinse & repeat.
        %     This arrangement accomplishes the equivalent of a
        %       while(dispatcher hasn't finished stopping yet), pause; end;
        if value(stopping_process_completed), %     This is provided by dispatcher to runrats (via GetSoloFunctionArgs).
            stop(value(stopping_complete_timer)); %     Stop looping.

            protobj=eval(value(curProtocol)); %#ok<NODEF>
            % call end_session action of protocol
            feval(value(curProtocol), protobj, 'end_session');
          
            sfile=SavingSection(protobj, 'savedata','interactive',0);

            % There may be things we want to do at the end of the session
            % that happen before saving the data (e.g., compile summary
            % stats for the day). That can happen in the 'end_session' call
            % above. But there may also be things we want to do before
            % saving settings for tomorrow and that should *not* affect the
            % saved data (e.g., jump to a different training stage). That
            % can happen in the 'pre_saving_settings' call below.
            try
              feval(value(curProtocol), protobj, 'pre_saving_settings');
            catch
              fprintf(1, ['RunRats:End Session:  Your protocol does not seem to have a\n' ...
                '''pre_saving_settings'' section. That''s fine. Just letting you know.\n']);
            end;
            
            SavingSection(protobj, 'savesets','interactive',0);
            % This call means that all Protocols are required to
            % instantiate SavingSection or to use the saveload plugin.
			

            while ~isempty(sfile)
                [r,sfile]=strtok(sfile,filesep);
            end
            StatusBar.value=['Saved data file: ' r];

            %     Change button label to 'Reloading'
            lh=get_ghandle(Multi);
            set(lh,'String','Reloading');

            dispatcher('set_protocol','');
            %increment session
            Session.value=Session+1; %#ok<NODEF>
            %rescan
            feval(CALLBACK_MFILENAME, 'prepare_next_session');
        
        end; %     end if stopping process complete


        
    case 'rigtest_singletrial_is_complete'
        %%     case rigtest_singletrial_is_complete
        % <~> End-of-rigtest call. This is called by the Rigtest_singletrial
        %       protocol when that protocol is complete (after one trial).

        % <~> Disable the multi-purpose button and change it so that it's
        %       ready for the next stage.
        feval(CALLBACK_MFILENAME,'disableGUIControls');           % <~> Disable all controls while unloading rigtest.
        
        mh=get_ghandle(Multi);
        set(mh,'String','Unloading Test...');
        StatusBar.value='Completing Test. Please be patient!';

        dispatcher(value(dispobj),'Stop'); %#ok<NODEF>
        
        if strcmp('on', get(value(stopping_complete_timer),'Running')), 
            warndlg('Curious behavior observed. Please contact a developer with the warning message printed in the command window! You may continue as normal.');
            warning('In runrats(rigtest_singletrial_is_complete), the stopping_complete_timer was already running when it was to be started. The timer properties are printed below.'); %#ok<WNTAG>
            display(get(value(stopping_complete_timer)));
            display(' ');
            display('Stopping the timer now.');
            stop(value(stopping_complete_timer));
        end;
        set(value(stopping_complete_timer), 'TimerFcn', [CALLBACK_MFILENAME '(''rigtest_singletrial_is_complete_continued'');']);
        start(value(stopping_complete_timer));
        
        % <~> Then we wait to catch the next update so that
        %       Dispatcher can be stopped and RigTest_singletrial can be
        %       unloaded. Unpleasant, isn't it? When that happens, the
        %       timer is triggered in Dispatcher, which now calls the case
        %       below.
        
        
    case 'rigtest_singletrial_is_complete_continued',
        %%     case rigtest_singletrial_is_complete_continued
        %     If the stopping process is done, we continue our sequence of
        %       end-test actions and stop the timer. Otherwise, we
        %       wait until the next timer event. Rinse & repeat.
        %     This arrangement accomplishes the equivalent of a
        %       while(dispatcher hasn't finished stopping yet), pause; end;
        if value(stopping_process_completed), %     This is provided by dispatcher to runrats (via GetSoloFunctionArgs).
            stop(value(stopping_complete_timer)); %     Stop looping.
            dispatcher('set_protocol','');
            feval(CALLBACK_MFILENAME,'Load');
        end;


	case 'is_running',
        %%     case is_running
        %     If the multipurpose button exists, we assume that RunRats is
        %       operational (i.e. loaded). This has nothing to do with
        %       whether or not an experiment is currently running.
		if exist('Multi', 'var'), obj = 1; else obj = 0; end;
		
        
    case 'flickerrunbuttoncolor',
        %%     case flickerRunButtonColor
        %     This call is attached to a timer. While an experiment is
        %       running, the blueness of the color of the running button
        %       inverts every second to indicate that MATLAB hasn't
        %       crashed, etc.
        mh = get_ghandle(Multi); % <~> fetch the handle of the run button
        iBGColor = get(mh,'BackgroundColor'); % <~> fetch current color
        set(mh,'BackgroundColor',[iBGColor(1:2) 1-iBGColor(3)]); % <~> invert blueness of current color
        
        
    case 'set_special_instructions'
        %% <~> set special instructions on RunRats window
        
        %     This feature is written only for the Brody Lab currently, as
        %       it uses a mysql-based rat training scheduler.
        if Settings('compare','GENERAL','Lab','Brody'),
            
            %     Verify arguments: 1 arg, an instructions string.
            error(nargchk(1,1,length(varargin),'struct'));
            strInstructions = varargin{1};
            if ~ischar(strInstructions), error('Special instructions string ... has to be a string. (call to runrats:'); end;
            nl = sprintf('\n'); %     nl is now a linebreak.

            %     Display to command window.
            display([nl nl nl nl '       TECHNICIAN SPECIAL INSTRUCTIONS FOR THIS RAT:' nl nl strInstructions nl nl nl]);

            %     Display in runrats instructions box.
            Instructions.value = strInstructions;
            
            %     If the field is highlighted (starts with !! or %!), then
            %       display a messagebox as well, and adjust to red.
            if (length(strInstructions) > 1) && (strcmp(strInstructions(1:2),'%!') || strcmp(strInstructions(1:2),'!!')),
                msgbox(['IMPORTANT :' nl nl 'For ' value(RatMenu) ', ' nl nl strInstructions],value(RatMenu));
                set(get_ghandle( Instructions),'BackgroundColor',[1 0 0]);
                set(get_glhandle(Instructions),'BackgroundColor',[1 0 0]);
            end;
            
        end; %          end if Setting: GENERAL;Lab;Brody
    %     end of case set_special_instructions
        

    case 'enableguicontrols',
        %% <~> case enableGUIControls
        %     This enables the various GUI elements generally locked while
        %       sensitive code is executing (loading/unloading, etc.).
        %     This allows user input.
        enable(Multi);
        enable(RatMenu);
        enable(FlushValves);
        enable(ExprmtrMenu);
        enable(ReScan);
        enable(ReScanExp);
        
    case 'disableguicontrols',
        %% <~> case disableGUIControls
        %     This disables the various GUI elements generally locked while
        %       sensitive code is executing (loading/unloading, etc.).
        %     This prevents user input.
        disable(Multi);
		disable(RatMenu);
		disable(ExprmtrMenu);
		disable(FlushValves);
        disable(ReScan);
        disable(ReScanExp);
        
    
    
    
    
        
        
%% ONLY DEPRECATED CASES FOLLOW -----------------------------
%% ONLY DEPRECATED CASES FOLLOW -----------------------------
%% ONLY DEPRECATED CASES FOLLOW -----------------------------
%% ONLY DEPRECATED CASES FOLLOW -----------------------------
%% ONLY DEPRECATED CASES FOLLOW -----------------------------




%% fillExprmtrMenu --- DEPRECATED
    case 'fillexprmtrmenu',

        feval(CALLBACK_MFILENAME,'disableGUIControls');           % <~> Disable all controls during scan&manipulation.

        StatusBar.value='Getting latest settings from server... ';
        getLatestCode;
        
        if Settings('compare','GENERAL','Schedule_Checking',1),
            % <~> det next rat fills the expr & rat menus and selects an
            %       experimenter and rat for the next session according to
            %       the online schedule.
%             try
                feval(CALLBACK_MFILENAME,'determine_next_rat_mysql');
%             catch
%                 warning('Warning: Wiki not correctly formatted? Experimenter set or ratname set based on wiki schedule failed. Please set manually.'); %#ok<WNTAG>
%                 feval(CALLBACK_MFILENAME,'do_fillExprmtrMenu');
%                 feval(CALLBACK_MFILENAME,'do_fillRatMenu'); %     We do this here, too, because when schedule checking is used, fillRatMenu doesn't do anything because all the work is normally already done in determine_next_rat_mysql, which is called from fillExprmtrMenu.
%             end; %     end try-catch schedule-based rat selection
        else
            %     Fill the experimenter menu. (I didn't want to change the
            %       name of the current case because of neurobrowser.)
            feval(CALLBACK_MFILENAME,'do_fillExprMtrMenu');
        end; %     end if-else using schedule-based rat selection

        feval(CALLBACK_MFILENAME, 'fillRatMenu'); %     Continue the runrats load procedure. The name may be deceptive at this point.
        
%% fillRatMenu --- DEPRECATED
    case 'fillratmenu'

        feval(CALLBACK_MFILENAME,'disableGUIControls');           % <~> Disable all controls during scan&manipulation.
        RatMenu.value=1;

        %     If schedule-based rat selection is not in use, we load the
        %       rat menu up; otherwise, the work has already been done.
        if ~Settings('compare','GENERAL','Schedule_Checking',1),
            feval(CALLBACK_MFILENAME,'do_fillRatMenu');
        end;
        
        if isempty(value(RatMenu))
			StatusBar.value=['Sorry, ' value(ExprmtrMenu) ' does not have any rats with settings.'];
		else
			StatusBar.value='Please pick an Experimenter, then a rat';
        end
        
        %     Re-enable the controls.
        feval(CALLBACK_MFILENAME,'enableGUIControls');           % <~> Re-enable all controls after scan&manipulation.
        feval(CALLBACK_MFILENAME, 'readyToLoad');


    otherwise
        warning('Unknown action " %s" !', action);%#ok<WNTAG>
end;

return;
