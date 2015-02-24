% This is a plugin that provides control over the components of the Laser 
% Stimulation Setup. 
% It creates a User Interface window that allows the user to control
% the locations to be stimulated in 2 different modes.
%
% STIMULATION MODES:
% The present version (16/08/13) has 2 possible modes to execute the
% photo-stimulation:
% 1 - Grid Mode: Creates a grid of locations by choosing a Right Top corner 
% and a Left Bottom corner and a grid resolution. Then the program choses
% one of the created locations to be stimulated in each trial. Photo
% Stimulation timings are controled by 2 parameters, the pulse duration,
% and the time of presentation relative to a Behavior Stimulus presentation
% 2 - Manual Selection Mode: Choose up to 4 positions to stimulate. 
% Both modes allow the user to input the coordinates by typing or by
% clicking a loaded image. 
% Time coordinates: 4 sets of 4 pairs of time coordinates. these allow to
% make custom photo stimulation 'waveforms', meaning the user can chose to
% just photo stimulate one position per trial, or up to 4 positions per
% trial, sequentially. One can also use the 4 different sets of time
% coordinates (A,B,C and D) to choose different positions (1,2,3 and4) for
% different trials with different probabilities each.
%
%
% LOADING IMAGE:
%
% Loading an image is pretty simple: we just need to write the image file 
% path in the string space: 'img_path'. If this string is empty or 
% numerical, when the user clicks the buttons an explorer window will pop 
% up for the user to search for the intended file. 
% IMPORTANT: The file should be saved from the 'qcam preview'(Ephus) 
% program by using the save icon on top right corner of the window. This 
% will create the file in the intended format.
%
% 
% COORDINATE SYSTEM:
% 
% Here the user will choose the coordinate system to use. There are 2
% availabe:
% 1 - Grid Coordinates: positions range from [-10,-10] to [10,10]
% 2 - Real Coordinates: distances given in millimitres (relative to origin)
% The origin can be the centre of the image or a custom point, chosen from
% the image by the user. To do this one must select the 'Origin: Custom'
% option, and then use the button 'get_origin' to click the intended
% position. If we want the center we need only to click the 'get_origin'
% button.
%
%
% ADDING THE PLUGIN TO A PROTOCOL:
%
% To use this plugin, simply add the following to your protocol's UI 
% generation code:
%  >> [x, y] = LaserControlSection(obj, 'init', x, y);
% The next two lines to the "prepare_next_trial" and "close" sections:
% >> LaserControlSection(obj, 'prepare_next_trial');
% >> LaserControlSection(obj, 'close');
%
%
% 
% This plugin aims to send 2 Analog scheduled waves (SW) and 3(+3 sequential 
% digitals and 3 inner digital) Digital SW. 
% For this to happen the user needs to add the SW implementation to their
% StateMatrixSection and the SW triggers in respective states of the
% protocol.
%
% To add the SW to your state machine assembler just copy this code 
% and add the 3 SWtriggers in respective states: 'AOM_pulse1' +
% 'shutter_pulse' + 'preamble_wave'
% (   for better understanding of these SW, please check the UI 
%     variables implementation further below                      )
%
%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
%       totalStimTime=0;
%     totalStimTime=value(current_time_rel_stim1)+value(currentPulseDuration1)+...
%             value(current_time_rel_stim2)+value(currentPulseDuration2)+...
%             value(current_time_rel_stim3)+value(currentPulseDuration3)+...
%             value(current_time_rel_stim4)+value(currentPulseDuration4);
% 
%         %SW to open and close the shutter.
%         sma = add_scheduled_wave(sma,'name','shutter_pulse',...
%             'preamble', value(stim_preamble)-0.009,...
%             'sustain',totalStimTime-value(stim_preamble)-0.001,...
%             'DOut',shuttertrig);      %channel DIO1 of cable 2
%         
%         %% AOM SCHEDULED WAVES 
% if value(simul_stim)
%     %MAYBE USE JUST SIMPLE TIMING METHOD LIKE BEFORE?? not allowing
%     %intervals between stimulation...
%     
%     %SW to shine the laser on the mouse: turns on  RF to AOM  
%     sma = add_scheduled_wave(sma,'name','AOM_pulse1', ...
%        'preamble', value(current_time_rel_stim1)-0.001,...
%        'trigger_on_up','AOM2');    
%       sma = add_scheduled_wave(sma, 'name', 'AOM2','preamble',0,...
%             'sustain', (1/(value(simul_pos)*value(frequency)))-0.005,...
%             'refraction',0.0045,'loop',value(currentPulseDuration1)*value(frequency)*value(simul_pos),...
%             'DOut',aomtrig);      
% %   sma = add_scheduled_wave(sma, 'name', 'teste','preamble',0,...
% %             'sustain', (1/(value(simul_pos)*value(frequency)))-0.005,...
% %             'refraction',0.0045,'loop',value(currentPulseDuration1)*value(frequency)*value(simul_pos),...
% %             'DOut',shuttertrig); 
%         
%         %% NOT DONE YET
% elseif value(gridSweep) %in case we are in grid mode  
%       sma = add_scheduled_wave(sma,'name','AOM_pulse1', ...
%        'preamble', value(current_time_rel_stim1)-0.001,...
%        'trigger_on_up','AOM_pulse1_go');    
%       sma = add_scheduled_wave(sma, 'name', 'AOM_pulse1_go','preamble',0,...
%             'sustain', value(DC)/value(frequency),...
%             'refraction',(1-value(DC))/value(frequency),...
%             'loop',value(currentPulseDuration1)*value(frequency),...
%             'DOut',aomtrig);    
%         
% else %If we are not in Simultaneous Stimulation Mode nor Grid these are the SW.
%      %SW to shine the laser on the mouse: turns on  RF to AOM  
%     
%      if value(currentTimeSlot)=='A'
%      sma = add_scheduled_wave(sma,'name','AOM_pulse1', ...
%        'preamble', value(current_time_rel_stim1)-0.0005,...
%               'trigger_on_up','AOM_pulse1_go');    
%     sma = add_scheduled_wave(sma,'name','AOM_pulse1_go', ...
%        'preamble',0,...
%        'sustain',value(DC)/value(frequency), ...
%        'refraction',(1-value(DC))/value(frequency),...
%        'loop',value(currentPulseDuration1)*value(frequency),...
%        'DOut',aomtrig);   
%      else
%        %Digital SW to serve as preamble to the AOM waves. 
%    sma = add_scheduled_wave(sma, 'name', 'AOM_pulse1',...
%             'preamble',value(current_time_rel_stim2)-0.0005, ...
%             'trigger_on_up', 'AOM_pulse1_go');        
%    sma = add_scheduled_wave(sma,'name','AOM_pulse1_go',... 
%        'preamble', 0,...
%        'sustain',value(DC)/value(frequency),...
%        'refraction',(1-value(DC))/value(frequency),...
%        'loop',value(currentPulseDuration2)*value(frequency),...
%        'DOut',aomtrig);      
%      end;
%         
% %    sma = add_scheduled_wave(sma, 'name', 'preamble_AOM3',...
% %             'preamble', value(currentPulseDuration2)+value(current_time_rel_stim3)-0.001, ...
% %             'trigger_on_up', 'AOM_pulse3');        
% %    sma = add_scheduled_wave(sma,'name','AOM_pulse3', 'preamble', 0.001,...
% %        'sustain',value(currentPulseDuration3),'DOut',aomtrig,'trigger_on_up','preamble_AOM4'); 
% %    
% %    sma = add_scheduled_wave(sma, 'name', 'preamble_AOM4',...
% %             'preamble', value(currentPulseDuration3)+value(current_time_rel_stim4)-0.001, ...
% %             'trigger_on_up', 'AOM_pulse4');        
% %    sma = add_scheduled_wave(sma,'name','AOM_pulse4', 'preamble', 0.001,...
% %        'sustain',value(currentPulseDuration4),'DOut',aomtrig);             
% end;
% %% 
%        %Digital SW to serve as preamble to the analog waves.  
%        % WHY THE "-0.001"???
%    sma = add_scheduled_wave(sma, 'name', 'preamble_wave',...
%             'preamble', value(stim_preamble)-0.001, ...
%             'trigger_on_up', 'sw_chn1+sw_chn2'); 
%    
%    axisSwitch1=[1 2]; %vectors responsible for switching axis - change 
%    axisSwitch2=[2 1];              %channel to which each AO signal is sent
%            
%         %Analog Scheduled Waves - rotate the mirrors!
%    sma = add_scheduled_wave(sma, 'name', 'sw_chn1', 'is_ao', 1, 'AOut', axisSwitch1(value(switch_xy)+1),...
%             'two_by_n_matrix', value(AOMatrix1));
%    sma = add_scheduled_wave(sma, 'name', 'sw_chn2', 'is_ao', 1, 'AOut', axisSwitch2(value(switch_xy)+1),...
%             'two_by_n_matrix', value(AOMatrix2));

%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%
% There will also be trials during which you want that no stimulation
% occurs. To modify the state machine, the SoloParamHandle
% "noStim" will need to be called (it is a global variable). Example: 
% if value(noStim)==0 
% (a different set of states will be chosen)
%
%
% PARAMETERS:
% -----------
%
% obj         Defaut object argument
%
% action      A string, one of the following:
%
%     'init' x y     RETURNS x, y
%             The 'init' action expects two more parameters, x and y, the
%             pixel position on the current figure on which a button that
%             opens/closes the LaserControl box figure will be placed. 
%             Returns an x and y position suitable for putting in a GUI 
%             element that will not overlap with the LaserControlSection one.
%
%     'close'  
%             Close and delete any figures or SoloParamHandles associated
%             with this section.
%
% Written by Rodrigo Dias, March 13 - Updated on 2nd July 13
%
% ----------------------------------------------------------------------- %

function [x, y] = LaserControlSection(obj, action, varargin)

GetSoloFunctionArgs(obj);

switch action,
    
  % ------------------------------------------------------------------
  %              INIT
  % ------------------------------------------------------------------    

  case 'init'
      
   if length(varargin) < 2,
      error('Need at least two arguments, x and y position, to initialize %s', mfilename);
    end;

    x = varargin{1}; y = varargin{2};
   
    SoloParamHandle(obj, 'my_xyfig', 'value', [x y gcf]);
    
    ToggleParam(obj, 'LaserControlShow', 0, x, y, 'OnString', 'Laser Trial params: showing', ...
      'OffString', 'Laser Trial params: hidden', 'TooltipString', 'Show/Hide parameters panel'); 
    set_callback(LaserControlShow, {mfilename, 'show_hide'}); %#ok<NODEF> (Defined just above)
    next_row(y);
    
    windowPos=[10 695];
    SoloParamHandle(obj, 'myfig', 'value', figure('Position', [windowPos(1:2)   200  5], ...
      'closerequestfcn', [mfilename '(' class(obj) ', ''hide'');'], 'MenuBar', 'none', ...
      'Name', mfilename), 'saveable', 0);
    set(gcf, 'Visible', 'off');
         
  % ------------------  GUI creation   ---------------------------------%

  
    x=0;y=0; %reinitialization of position variables, to allow new window
                    %to have buttons near the bottom.             
      
                    
                    
      NumeditParam(obj, 'AP_angle', 0, x, y, 'TooltipString', ...
            'Angle between the Anterior-Posterior Axis and the X-axis of the Camera view.');next_row(y,1.25);  
                    
      PushbuttonParam(obj, 'get_APaxis', x, y, 'position', [x y 200 30],...
            'BackgroundColor', [1 0 1],'TooltipString', 'Click here to define Anterior Posterior Axis'); next_row(y,1.5);
        set_callback(get_APaxis, {'LaserControlSection', 'get_APaxis'}); 
        
%         NumeditParam(obj, 'bregma_pos', [0 0], x, y, 'TooltipString', ...
%             'Origin Coordinates in pixels.');next_row(y,1.25);  
        
     PushbuttonParam(obj, 'get_origin', x, y, 'position', [x y 200 30],...
            'BackgroundColor', [0 1 0],'TooltipString', 'Click here to define origin: chose Bregma position or just leave centre of image'); next_row(y,1.5);
        set_callback(get_origin, {'LaserControlSection', 'get_origin'});         
      EditParam(obj, 'img_path', 'C:\Users\User\Desktop\Laser Settings\loadimage.fig', x, y,...
           'TooltipString', 'image to Choose the origin'); next_row(y,1.35);
        
        ToggleParam(obj, 'origin', 0, x,y, 'OnString', 'Origin: Custom Position', ...
      'OffString', 'Origin: Centre of Image','TooltipString', ...
            'Choose Origin of Coordinate system'); next_row(y);   
     ToggleParam(obj, 'coordinates', 0, x,y, 'OnString', 'Real Coordinates: ON', ...
      'OffString', 'Image Coordinates: ON','TooltipString', ...
            'Choose Coordinates system'); next_row(y);
     SubheaderParam(obj, 'CoordinateSystem', 'Coordinate System', x, y);next_row(y,1.25);               
     
      ToggleParam(obj, 'loadCalib', 1, x, y, 'OnString', 'Load Calibration: ON', ...
      'OffString', 'Load Calibration: OFF','TooltipString', ...
            'If ON, will load Calibration parameters from LaserCalib.'); next_row(y,1.25);  
      
        
%        ToggleParam(obj, 'seq_stim', 0, x, y, 'OnString', 'Sequential Stimulation: ON', ...
%       'OffString', 'Sequential Stimulation: OFF','TooltipString', ...
%             'If ON, stimulation positions will be squentially stimulated.'); next_row(y);

      PushbuttonParam(obj, 'check_calib_Overlay', x, y, 'position', [x y 200 30],...
            'BackgroundColor', [1 0 0],'TooltipString', 'Select Overlay Image'); next_row(y,1.25);
      EditParam(obj, 'img_path_overlay', 'C:\Users\User\Desktop\Laser Settings\loadimageOverlay.fig', x, y,...
           'TooltipString', 'Write path to Overlay figure to use as calibration check'); next_row(y,1.35);
      set_callback(check_calib_Overlay, {'LaserControlSection', 'check_calib_Overlay'}); 
       
       
      PushbuttonParam(obj, 'check_calib', x, y, 'position', [x y 200 30],...
            'BackgroundColor', [1 0 0],'TooltipString', 'Select mode first'); next_row(y,1.25);
      EditParam(obj, 'img_path2', 'C:\DATA\Rodrigo\laserpos\test.fig', x, y,...
           'TooltipString', 'Write path to figure to use as calibration check'); next_row(y,1.35);
        
        set_callback(check_calib, {'LaserControlSection', 'check_calib'});   
         
       PushbuttonParam(obj, 'load_image', x, y, 'position', [x y 200 30],...
            'BackgroundColor', [0 1 1],'TooltipString', 'Select mode first'); next_row(y,1.25);
        set_callback(load_image, {'LaserControlSection', 'load_img'});                  
        
        %Present Trial Info
        DispParam(obj, 'originPos_mm', [0 0], x, y, 'TooltipString', ...
            'Origin distance to centre of image (mm)'); next_row(y);
         DispParam(obj, 'currentLaserPower', 0, x, y, 'TooltipString',...
            'Shows which Laser Power was chosen'); next_row(y);
        DispParam(obj, 'currentTimeSlot', 0, x, y, 'TooltipString',...
            'Shows which Timing set was chosen'); next_row(y); 
        DispParam(obj, 'multiStim', 0, x, y, 'TooltipString',...
            'Shows if in Manual mode Multi or Single Stimulation are happening'); next_row(y); 
        DispParam(obj,'currentPos1', [0 0], x, y, 'TooltipString',...
            'Shows 1st Stimulated position'); next_row(y); 
        DispParam(obj, 'currentPos_mm', [0 0], x, y, 'TooltipString',...
            'Shows stimulated position in mm'); next_row(y); 
%         DispParam(obj,'currentPos', [0 0], x, y, 'TooltipString',...
%             'Shows stimulated position in grid mode'); next_row(y); 
        DispParam(obj, 'noStim', 0, x, y); next_row(y);
       
        
        SubheaderParam(obj, 'currentHeader', 'Current Trial', x, y); next_row(y,1.5); 
        
        HeaderParam(obj, 'LaserControl', 'Laser Control', x, y);next_row(y);                
                    
        y1=y;
        
       next_column(x); y=0;                     
       
     % MultiStimulation Mode
    ToggleParam(obj, 'multi_time', 0, x, y, 'OnString', 'Time Coordinates: Showing', ...
      'OffString', 'Time Coordinates: Hidden', 'TooltipString', 'Define time windows to Photo-Stimulate.'); 
    set_callback(multi_time, {mfilename, 'show_hideTime'}); %#ok<NODEF> (Defined just above)
    next_row(y,1.25); 
    
     %Toggle Button to show and hide Manual Mode Window
     ToggleParam(obj, 'open_manual', 0, x, y, 'OnString', 'Manual Mode: Showing', ...
      'OffString', 'Manual Mode: Hidden', 'TooltipString', 'Shows Window to define Manual Mode settings'); 
    set_callback(open_manual, {mfilename, 'show_hideManual'}); 
    next_row(y); 
        ToggleParam(obj, 'manual_img', 0, x,y, 'OnString', 'Manual Mode ON', ...
      'OffString', 'Manual Mode OFF','TooltipString', ...
            'Opens image to select n points'); next_row(y);
              SubheaderParam(obj, 'SelectionFromImage', 'Manual Selection Mode',...
                            x, y);next_row(y,1.25);  
        
     %Toggle Button to show and hide Grid Mode Window
     ToggleParam(obj, 'open_grid', 0, x, y, 'OnString', 'Grid Mode: Showing', ...
      'OffString', 'Grid Mode: Hidden', 'TooltipString', 'Shows Window to define Grid Mode'); 
    set_callback(open_grid, {mfilename, 'show_hideGrid'}); 
    next_row(y); 
        ToggleParam(obj, 'gridSweep', 0, x, y, 'OnString', 'Grid Mode ON', ...
      'OffString', 'Grid Mode OFF', 'TooltipString', ...
            'If pressed, will creat a grid of positions and chose one of them each trial'); next_row(y);
      SubheaderParam(obj, 'GridSweep', 'Grid Mode', x, y);next_row(y,1.25);
   
%       MenuParam(obj, 'frequency', {1,2,3,4,5,10,30,40,50,60,80,100,200}, 40, x, y, ...
%        'TooltipString', 'Frequency of Photo-Stimulation (Hz)');next_row(y); 
        SliderParam(obj, 'DC',0.4, 0,1, x, y, 'TooltipString', ...
            'Duty Cycle - percentage of stimulation time high.');next_row(y);
        
        
        NumeditParam(obj, 'ramp_lenght', 0.1, x, y, 'TooltipString', ...
            'Time lenght of the ramping down of the laser intensity (s)');next_row(y); 
        NumeditParam(obj, 'frequency', 40, x, y, 'TooltipString', ...
            'Photo-Stimulation frequency (Hz)');next_row(y,1.25);      

     % Probability of no photo-stimulation happening in each trial 
        SliderParam(obj, 'no_Pstim_prob',20, 0,100, x, y, 'TooltipString', ...
            'Probability for no photo stimulation (%)');next_row(y,1.25);
        
     SubheaderParam(obj, 'stimHeader', 'Photo-Stim Details', x, y); next_row(y,1.25);    
     
      NumeditParam(obj, 'realLaserPower', 0, x, y, 'TooltipString', ...
            'Write down maximum Laser power for the session (mW).');next_row(y,1);
     
     NumeditParam(obj, 'laserP', [1 0.5 0], x, y, 'TooltipString', ...
            'Adjusts Laser power between 1 (max) and 0 (minimum).');next_row(y,1);
        
     NumeditParam(obj, 'laserPProb', [1 0 0], x, y, 'TooltipString', ...
            'Probability of chosing one Laser Power each Trial.');next_row(y);
        
     SubheaderParam(obj, 'laserHeader', 'Laser Power', x, y); next_row(y,1.25);
     
     %Last Trial Info
     DispParam(obj, 'lastLaserPower', NaN, x, y, 'TooltipString',...
            'Shows which Laser Power was chosen'); next_row(y); 
        DispParam(obj, 'lastTimeSlot', NaN, x, y, 'TooltipString',...
            'Shows which Timing set was chosen'); next_row(y); 
        DispParam(obj, 'lastmultiStim', NaN, x, y, 'TooltipString',...
            'Shows if in Manual mode Multi or Single Stimulation are happening'); next_row(y); 
        DispParam(obj,'lastPos1', NaN, x, y, 'TooltipString',...
            'Shows 1st Stimulated position'); next_row(y); 
        DispParam(obj, 'lastPos_mm', NaN, x, y, 'TooltipString',...
            'Shows stimulated position in mm'); next_row(y); 
        DispParam(obj, 'lastnoStim', NaN, x, y); next_row(y);
        DispParam(obj, 'lastTrial', NaN, x, y); next_row(y);
     
     SubheaderParam(obj, 'lastHeader', 'Last Trial', x, y); next_row(y,1.5); 
   
        
    % Make the main figure window as wide as it needs to be and as tall as
    % it needs to be; 
    pos = get(value(myfig), 'Position');
%     set(value(myfig), 'Position', [pos(1:2) 400 y1]);
    set(value(myfig), 'Position', [600 600 400 y1]);

  %% Figure that has Grid Mode
   
    % Create figure time_fig for new stimulation mode, and set it to be invisible until 
   % button is pressed
    SoloParamHandle(obj, 'grid_fig', 'saveable', 0); grid_fig.value = figure; name = 'Grid Mode';
    set(value(grid_fig), 'Name', name, 'Tag', name,...
        'Position', [windowPos(1)-5   windowPos(2)-275   100   5], 'Visible', 'off',...
        'closerequestfcn', [mfilename '(' class(obj) ', ''closeGrid'');']);
  
    x=5;y=5;    
    
    
     PushbuttonParam(obj, 'show_grid_pos', x, y, 'position', [x y 200 30],...
            'BackgroundColor', [0 1 1],'TooltipString', 'Writes Grid positions to be created'); next_row(y,1.25);
        set_callback(show_grid_pos, {'LaserControlSection', 'show_grid_pos'});     
    
    
             % time_rel_stim - time (in seconds) to wait before sending pulses 
     % after it is triggered - this is to allow the user to easily control
     % the timing of the stimulus
        NumeditParam(obj, 'time_rel_stim', -0.4, x, y, 'TooltipString', ...
            'Time of photostimulation relative to the Visual Stimulus presentation (s)');next_row(y);  
        NumeditParam(obj, 'pulseDuration', 0.5, x, y, 'TooltipString', ...
            'Pulse Duration (s)');next_row(y,1.25);  
        
        NumeditParam(obj, 'eliminate', [0 0 0 0], x, y, 'TooltipString',...
            'Write the positions of the grid that are to be eliminated.'); next_row(y);
        
        ToggleParam(obj, 'img_grid', 0, x, y, 'OnString', 'Select Corners from Image: ON', ...
            'OffString', 'Write Corner Coordinates manually',...
            'TooltipString','Allows user to select if writes corner coordinates or selects them from image.');
        next_row(y);
        NumeditParam(obj, 'grid_res', [2 2], x, y, 'TooltipString', ...
            'Grid Resolution -(MxN)');next_row(y);
        NumeditParam(obj, 'grid_botleft', [-5 -5], x, y, 'TooltipString', ...
            'Position for the left bottom of the square grid');next_row(y);
        NumeditParam(obj, 'grid_topright', [5 5], x, y, 'TooltipString', ...
            'Position for the right top of the square grid');next_row(y,1.25);
        SubheaderParam(obj, 'GridSweep', 'Grid Mode', x, y);next_row(y,1.25);
          
    pos = get(value(grid_fig), 'Position');
    set(value(grid_fig), 'Position', [pos(1:2) 205 y]);
   
% -------------------------  END of GUI  ---------------------------------%  
    

  %% Figure that has the Manual Mode settings
   
    % Create figure time_fig for new stimulation mode, and set it to be invisible until 
   % button is pressed
    SoloParamHandle(obj, 'manual_fig', 'saveable', 0); manual_fig.value = figure; name = 'Manual Mode';
    set(value(manual_fig), 'Name', name, 'Tag', name,...
        'Position', [windowPos(1)-5   windowPos(2)-275   100   5], 'Visible', 'off',...
        'closerequestfcn', [mfilename '(' class(obj) ', ''closeManual'');']);
  
    x=5;y=5;    
     %Simultaneous Stimulation Mode  
    
    DispParam(obj, 'SinglePulseLength', 0, x, y, 'TooltipString', ...
        'Pulse duration for single photo-stimulation pulse in each position (ms)');next_row(y);
    NumeditParam(obj, 'mirrors_moving_time', 1, x, y, 'TooltipString', ...
        'Time that AOM will be off to allow the mirrors to change position (ms)');next_row(y);
    MenuParam(obj, 'simul_pos', {2,3,4}, 2, x, y, ...
       'TooltipString', 'Number of positions to be simultaneously photo-stimulated');next_row(y);
     ToggleParam(obj, 'simul_stim', 0, x, y, 'OnString', 'Simultaneous Stimulation: ON', ...
       'OffString', 'Simultaneous Stimulation: OFF', 'TooltipString', 'Activates Simultaneous Stimulation Mode');
       next_row(y,1.25);
       
       % manual Mode - several buttons to allow manual input of coordinates and
    % probabilities.
    NumeditParam(obj, 'position_4', [0 0], x, y, 'TooltipString', ...
        'Position 4');next_row(y);
    NumeditParam(obj, 'position_3', [0 0], x, y, 'TooltipString', ...
        'Position 3');next_row(y);
    NumeditParam(obj, 'position_2', [0 0], x, y, 'TooltipString', ...
        'Position 2');next_row(y);
    NumeditParam(obj, 'position_1', [0 0], x, y, 'TooltipString', ...
        'Position 1 ');next_row(y);     
                   
     % Mode 1 - introduce the number of positions that will be stimulated.              
        MenuParam(obj, 'n_pos', {0,1,2,3,4}, 0, x, y, ...
  'TooltipString', 'Number of Positions that will be chosen');next_row(y);
  
        SubheaderParam(obj, 'SelectionFromImage', 'Manual Selection Mode',...
                            x, y);next_row(y,1.25); 

    pos = get(value(manual_fig), 'Position');
    set(value(manual_fig), 'Position', [pos(1:2) 205 y]);
 
% -------------------------  END of GUI  ---------------------------------%      
   
   %% Figure that has Multi Stimulation Site Mode
   
    % Create figure time_fig for new stimulation mode, and set it to be invisible until 
   % button is pressed
    SoloParamHandle(obj, 'time_fig', 'saveable', 0); time_fig.value = figure; name = 'Time Coordinates';
    set(value(time_fig), 'Name', name, 'Tag', name,...
        'Position', [windowPos(1)-5   windowPos(2)-275   200   5], 'Visible', 'off',...
        'closerequestfcn', [mfilename '(' class(obj) ', ''closeTime'');']);
  
    x=5;y=5;    
    
    NumeditParam(obj, 'time_4C', [0 0], x, y, 'TooltipString', ...
        'Duration of position 4 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_3C', [0 0], x, y, 'TooltipString', ...
        'Duration of position 3 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_2C', [0 0], x, y, 'TooltipString', ...
        'Duration of position 2 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_1C', [0 0], x, y, 'TooltipString', ...
        'Duration of position 1 stimulation (s)');next_row(y,1.25);
    NumeditParam(obj, 'prob_C', 0, x, y, 'TooltipString', ...
        'Weighted probability of having this sequence of stimulation sites selected');next_row(y,1.5);
    
    NumeditParam(obj, 'time_4A', [0 0], x, y, 'TooltipString', ...
        'Duration of position 4 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_3A', [0 0], x, y, 'TooltipString', ...
        'Duration of position 3 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_2A', [0 0], x, y, 'TooltipString', ...
        'Duration of position 2 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_1A', [0 0], x, y, 'TooltipString', ...
        'Duration of position 1 stimulation (s)');next_row(y,1.25);
    NumeditParam(obj, 'prob_A', 0, x, y, 'TooltipString', ...
        'Weighted probability of having this sequence of stimulation sites selected');next_row(y);
    
    next_column(x); y=5;

    NumeditParam(obj, 'time_4D', [0 0], x, y, 'TooltipString', ...
        'Duration of position 4 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_3D', [0 0], x, y, 'TooltipString', ...
        'Duration of position 3 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_2D', [0 0], x, y, 'TooltipString', ...
        'Duration of position 2 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_1D', [0 0], x, y, 'TooltipString', ...
        'Duration of position 1 stimulation (s)');next_row(y,1.25);
    NumeditParam(obj, 'prob_D', 0, x, y, 'TooltipString', ...
        'Weighted probability of having this sequence of stimulation sites selected');next_row(y,1.5);
   
    NumeditParam(obj, 'time_4B', [0 0], x, y, 'TooltipString', ...
        'Duration of position 4 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_3B', [0 0], x, y, 'TooltipString', ...
        'Duration of position 3 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_2B', [0 0], x, y, 'TooltipString', ...
        'Duration of position 2 stimulation (s)');next_row(y);
    NumeditParam(obj, 'time_1B', [0 0], x, y, 'TooltipString', ...
        'Duration of position 1 stimulation (s)');next_row(y,1.25);
    NumeditParam(obj, 'prob_B', 0, x, y, 'TooltipString', ...
        'Weighted probability of having this sequence of stimulation sites selected');next_row(y);   

          
    pos = get(value(time_fig), 'Position');
    set(value(time_fig), 'Position', [pos(1:2) 410 y]);
   
   
% -------------------------  END of GUI  ---------------------------------%

%% ---------------------  Variables implementation   ----------------------%
    
    SoloParamHandle(obj,'currentPos2','value',zeros(2,1));
    SoloParamHandle(obj,'currentPos3','value',zeros(2,1));
    SoloParamHandle(obj,'currentPos4','value',zeros(2,1));
    
    SoloParamHandle(obj,'AOMatrix1'); %Matrix with positions to AOSW1
    SoloParamHandle(obj,'AOMatrix2'); %Matrix with positions to AOSW2
    SoloParamHandle(obj,'AOM_matrix'); %Matrix with timings to AOM       

    SoloParamHandle(obj,'img_pos','value',zeros(value(n_pos),2)); %vector to contains positions 
%     SoloParamHandle(obj,'img_grid','value',0); %0 means grid is set manually, not from image                                                                %taken from image (in pixels)
    SoloParamHandle(obj,'img_dim_func','value',zeros(1,3));%to store image dimensions in the function
    SoloParamHandle(obj,'img_dim','value',zeros(1,3));%to store image dimensions

    SoloParamHandle(obj,'g_Pos');
    
    SoloParamHandle(obj,'FinalValue1','value',0);
    SoloParamHandle(obj,'FinalValue2','value',0);
    SoloParamHandle(obj,'rotation','value',0);  %rotation (in degrees) to calibrate
    SoloParamHandle(obj,'voltage_bias','value',[0 0]); %voltage bias to calibrate laser position
    SoloParamHandle(obj,'xy_amplitudes','value',[10 10]); %voltage scaling parameters
    SoloParamHandle(obj,'invert_1','value',0); 
    SoloParamHandle(obj,'invert_2','value',0); 
    SoloParamHandle(obj,'switch_xy','value',0);
    SoloParamHandle(obj,'mm_pxl_scale','value',0.015); %standart value for mm/pixel scale
    
    SoloParamHandle(obj,'bregma_pos','value',[0 0]);  
    SoloParamHandle(obj,'centre','value',[0 0]);
    
    %Values to be sent to AOSW in manual mode.
     SoloParamHandle(obj,'FinalMultiPos1_1','value', 0);
     SoloParamHandle(obj,'FinalMultiPos2_1','value', 0);
     SoloParamHandle(obj,'FinalMultiPos1_2','value', 0);
     SoloParamHandle(obj,'FinalMultiPos2_2','value', 0);
     SoloParamHandle(obj,'FinalMultiPos1_3','value', 0);
     SoloParamHandle(obj,'FinalMultiPos2_3','value', 0);
     SoloParamHandle(obj,'FinalMultiPos1_4','value', 0);
     SoloParamHandle(obj,'FinalMultiPos2_4','value', 0);
     
     SoloParamHandle(obj,'time','value',[0 0 0 0]);
     SoloParamHandle(obj,'currentPulseDuration1','value',0);
     SoloParamHandle(obj,'current_time_rel_stim1','value',0);
     SoloParamHandle(obj,'currentPulseDuration2','value',0);
     SoloParamHandle(obj,'current_time_rel_stim2','value',0);
     SoloParamHandle(obj,'currentPulseDuration3','value',0);
     SoloParamHandle(obj,'current_time_rel_stim3','value',0);
     SoloParamHandle(obj,'currentPulseDuration4','value',0);
     SoloParamHandle(obj,'current_time_rel_stim4','value',0);
     SoloParamHandle(obj,'currentlaserP','value',0);
     
     SoloParamHandle(obj,'TotalStimTime','value',0);
     
     SoloParamHandle(obj,'stim_preamble','value',0);
     
     SoloParamHandle(obj,'input_points','value',[0 0 0]);
     SoloParamHandle(obj,'loadimage_points','value',[0 0 0]);
     
     SoloParamHandle(obj,'AllGrid','value',0);
     
     
    DeclareGlobals(obj, 'rw_args', {'img_path','img_path2',...
        'load_image','img_grid','img_dim_func','img_dim','img_pos','show_grid_pos',...  %variables to work with the image
        'manual_img','n_pos',...            % vars to image manual mode 
        'currentPos1','AOMatrix1','AOMatrix2','FinalValue1','FinalValue2'...   % vars to be sent to AOSW 
        'gridSweep','grid_topright', 'grid_botleft','grid_res','no_Pstim_prob','g_Pos','eliminate'... %grid mode
        'position_1', 'position_2','position_3', 'position_4',... $manual mode
        'time_rel_stim','pulseDuration','noStim','currentPos_mm','originPos_mm',...    % vars common to all modes
        'rotation','voltage_bias','xy_amplitudes','loadCalib',...  % vars from LaserCalib Protocol
        'invert_1','invert_2','switch_xy','mm_pxl_scale',...  % vars from LaserCalib Protocol 
        'coordinates','bregma_pos','origin','centre','AP_angle'...     %Coordinate system choosing 
        'multi_time','time_fig','multiStim','time','stim_preamble',... % Multi Time figure and variables  
        'currentTimeSlot','prob_A','prob_B','prob_C','prob_D',... 
        'time_4A','time_3A','time_2A','time_1A',...
        'time_4B','time_3B','time_2B','time_1B',...
        'time_4C','time_3C','time_2C','time_1C',...
        'time_4D','time_3D','time_2D','time_1D',...
        'currentPulseDuration1','currentPulseDuration2',...
        'currentPulseDuration3','currentPulseDuration4',...
        'current_time_rel_stim1','current_time_rel_stim2',...
        'current_time_rel_stim3','current_time_rel_stim4',...
        'FinalMultiPos1_1','FinalMultiPos2_1','FinalMultiPos1_2','FinalMultiPos2_2',...
        'FinalMultiPos1_3','FinalMultiPos2_3','FinalMultiPos1_4','FinalMultiPos2_4',...
        'simul_stim','frequency','DC','ramp_lenght', ...
        'simul_pos','TotalStimTime','mirrors_moving_time',...
        'input_points', 'loadimage_points','AllGrid','AOM_matrix',...
        'laserP','laserPProb','realLaserPower','currentlaserP'});    
    
  % ------------------------------------------------------------------
  %              NEXT TRIAL
  % ------------------------------------------------------------------   
    
 case 'prepare_next_trial'
    
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
   
 
  %% UPDATE STATE MATRIX SECTION
        if n_done_trials > 0      
            noStimHistory(n_done_trials) = value(noStim);
            currentPos1History(n_done_trials,:) = value(currentPos1);
            currentTimeSlotHistory(n_done_trials) = value(currentTimeSlot);
            currentLaserPowerHistory(n_done_trials) = value(currentLaserPower);
        end
 
 
 if value(loadCalib)     %Loading and assigning of calibration parameters.
                  
%     calibs=struct2cell(load('D:\FChampalimaud\ratter\Calibration\CalibParams'));  
%     calibs=struct2cell(load('C:\Documents and Settings\Admin\Desktop\CalibParams'));
     calibs=struct2cell(load('C:\Users\User\Desktop\Laser Settings\CalibParams'));
    
     voltage_bias.value=calibs{1};
     xy_amplitudes.value=calibs{2};
     rotation.value=calibs{3}; 
     invert_1.value=calibs{4};
     invert_2.value=calibs{5};
     switch_xy.value=calibs{6};
     mm_pxl_scale.value=calibs{7};
 else
     voltage_bias.value=[0 0];
     xy_amplitudes.value=[10 10];
     rotation.value=0; 
     invert_1.value=0;
     invert_2.value=0;
     switch_xy.value=0;
     mm_pxl_scale.value=0.010;
 end;
 
 %importing value from function, in order to be saved with rest of data -
 %30/10/13 - Rodrigo Dias
%  img_dim.value=value(img_dim_func)
 
 % Definition of the origin of the coordinate system
 if value(origin)  %if user wants to click bregma
     centre.value=value(bregma_pos);
     originPos_mm.value=[(value(bregma_pos(1))-(value(img_dim(2))/2))*value(mm_pxl_scale) ...
                       ((value(img_dim(1))/2)-value(bregma_pos(2)))*value(mm_pxl_scale)];
 else             %if user wants to use centre of image
     centre.value=[value(img_dim(2))/2 value(img_dim(1))/2];
     originPos_mm.value=[0 0];
 end;
 
 %% Stimulation Conditions
 if rand(1) <= (value(no_Pstim_prob)/100)
     noStim.value=1;
     currentPos1.value=[0 0]; %send a default value to stimulate
     laserPwr=.016963; % =0
 else
     % Assuring there will be stimulation by setting the flag to Go value
     noStim.value=0;
     
     % Deciding wich Laser Power is going to be used this trial    
     lp_size = length(value(laserPProb));
     for i=1:lp_size
         lp_prob(i) = value(laserPProb(i))/sum(value(laserPProb));
     end
     cumsum_lp_prob=cumsum(lp_prob);
     
     lp_rand = rand*cumsum_lp_prob(end);
     done=0;
     for i=1:lp_size
         if lp_rand<= cumsum_lp_prob(i) && ~done
             currentlaserP.value = value(laserP(i)); % THIS needs to be multiplied in the AOM
             if value(laserP(i))>.9844
                 laserPwr=.9844;
             elseif value(laserP(i))<.016963
                 laserPwr=.016963;
             else
                 laserPwr=value(laserP(i));
             end
             
             currentLaserPower.value = value(laserP(i))*value(realLaserPower);
             done=1;
         end
     end
%%%%%%%%%%%%% ADD SPACE TO WRITE DOWN LASER POWER FOR THAT SESSION - then
%%%%%%%%%%%%% use that for laser power to be shown as currentLaserPower
%%%%%%%%%%%%% (show in mW like this!!)
     
     % --------------------- SELECTION MODES --------------------------%
     
     %---------------------------- GRID SWEEP MODE ----------------------------%
     if value(gridSweep) && value(manual_img)==0
         
         if value(img_grid)==0    % Corners introduced manually
             
             if value(coordinates) %define positions in millimitres
                 
                 gPos=GridCreation([value(grid_topright);value(grid_botleft)],value(grid_res),...
                         value(eliminate), value(AP_angle),value(origin),value(coordinates));
                     
                 gPos(:,1)=value(centre(1)) + gPos(:,1)/value(mm_pxl_scale);
                 gPos(:,2)=value(centre(2)) - gPos(:,2)/value(mm_pxl_scale); 
                 
                 gPos=Pix2Cart(value(img_dim),size(gPos),gPos);
                 
%                  % ORIGINAL - inverting in relation to origin? or roatation in pixels?
%                  pixel_pos1=[0 0];
%                  pixel_pos2=[0 0];
%                  
%                  pixel_pos1(1)=value(centre(1)) + (value(grid_topright(1))/value(mm_pxl_scale));
%                  pixel_pos1(2)=value(centre(2)) - (value(grid_topright(2))/value(mm_pxl_scale));
%                  pixel_pos2(1)=value(centre(1)) + (value(grid_botleft(1))/value(mm_pxl_scale));
%                  pixel_pos2(2)=value(centre(2)) - (value(grid_botleft(2))/value(mm_pxl_scale));            
%                                   
%                  posTR=Pix2Cart(value(img_dim), 1, pixel_pos1);
%                  posBL=Pix2Cart(value(img_dim), 1, pixel_pos2);
%                 
%                  gPos=GridCreation([posTR(1,1:2); posBL(1,1:2)],value(grid_res),...
%                      value(eliminate),value(AP_angle),value(origin),value(coordinates));
%                  %
                 
                
             else
                 cart_centre = Pix2Cart(value(img_dim),1,value(centre));
                 gPos=GridCreation([value(grid_topright)+cart_centre(1,:); value(grid_botleft)+cart_centre(1,:)],...
                     value(grid_res),value(eliminate),value(AP_angle),value(origin),0);
             end;
             
         elseif value(img_grid)==1  % Corners obtained from image
             imgDimension=value(img_dim);  %imgDimension = [rows columns dim]
             [tru_pos]=Pix2Cart(imgDimension, 2, value(img_pos));  %Calib(imgDimension, n_pos, img_pos)
             gPos=GridCreation(tru_pos(1:2,:), value(grid_res),value(eliminate),value(AP_angle),0,0);
             grid_topright.value = tru_pos(1,:); %Update GUI values
             grid_botleft.value = tru_pos(2,:);
         end;
         
         n=size(gPos,1);
         
         % Choosing the actual coordinates to be sent. These will always be
         % randomly selected from among all possible positions (with
         % reposition)
         AllGrid.value=gPos;
         currentPos1.value=gPos(randsample(n, true),1:2);
         
         %------------------------- MANUAL SELECTION MODE -------------------------%
         % If n_pos = 0  will use inputs from edit boxes. If != 0 will
         % expect input from image clicking. Probabilities for different
         % positions are chosen using different time sets.
         
     elseif value(manual_img) && value(gridSweep)==0 %&& ~multiStimMode
         
         imgDimension=value(img_dim);  %imgDimension = [rows columns dim]
         
         if value(n_pos)==0 %atributing positions manually
                
             if value(coordinates) %define positions in millimitres
                 
                 %rotating mm coordinates
                 APrads= (value(AP_angle)*pi)/180;
                         
                 [t1 r1]=cart2pol(value(position_1(1)), value(position_1(2)));
                 [Tposition_1(1) Tposition_1(2)]=pol2cart(t1 + APrads,r1);
                 Tposition_1 = round( Tposition_1 * 10000)/10000;
                 
                 [t2 r2]=cart2pol(value(position_2(1)), value(position_2(2)));
                 [Tposition_2(1) Tposition_2(2)]=pol2cart(t2 + APrads,r2);
                 Tposition_2 = round( Tposition_2 * 10000)/10000;
                 
                 [t3 r3]=cart2pol(value(position_3(1)), value(position_3(2)));
                 [Tposition_3(1) Tposition_3(2)]=pol2cart(t3 + APrads,r3);
                 Tposition_3 = round( Tposition_3 * 10000)/10000;
                 
                 [t4 r4]=cart2pol(value(position_4(1)), value(position_4(2)));
                 [Tposition_4(1) Tposition_4(2)]=pol2cart(t4 + APrads,r4);
                 Tposition_4 = round( Tposition_4 * 10000)/10000;
                 %
                 
                 pixel_pos1(1)=value(centre(1)) + Tposition_1(1)/value(mm_pxl_scale);
                 pixel_pos1(2)=value(centre(2)) - Tposition_1(2)/value(mm_pxl_scale);
                 TemporaryPos1=Pix2Cart(value(img_dim), 1, pixel_pos1);
                 currentPos1.value=TemporaryPos1(1,:);
                 
                 pixel_pos2(1)=value(centre(1)) + Tposition_2(1)/value(mm_pxl_scale);
                 pixel_pos2(2)=value(centre(2)) - Tposition_2(2)/value(mm_pxl_scale);
                 TemporaryPos2=Pix2Cart(value(img_dim), 1, pixel_pos2);
                 currentPos2.value=TemporaryPos2(1,:);
                 
                 pixel_pos3(1)=value(centre(1)) + Tposition_3(1)/value(mm_pxl_scale);
                 pixel_pos3(2)=value(centre(2)) - Tposition_3(2)/value(mm_pxl_scale);
                 TemporaryPos3=Pix2Cart(value(img_dim), 1, pixel_pos3);
                 currentPos3.value=TemporaryPos3(1,:);
                 
                 pixel_pos4(1)=value(centre(1)) + Tposition_4(1)/value(mm_pxl_scale);
                 pixel_pos4(2)=value(centre(2)) - Tposition_4(2)/value(mm_pxl_scale);
                 TemporaryPos4=Pix2Cart(value(img_dim), 1, pixel_pos4);
                 currentPos4.value=TemporaryPos4(1,:);
                 
                 %old version
%                  pixel_pos1(1)=value(centre(1)) + value(position_1(1))/value(mm_pxl_scale);
%                  pixel_pos1(2)=value(centre(2)) - value(position_1(2))/value(mm_pxl_scale);
%                  TemporaryPos1=Pix2Cart(value(img_dim), 1, pixel_pos1);
%                  currentPos1.value=TemporaryPos1(1,:);
%                  
%                  pixel_pos2(1)=value(centre(1)) + value(position_2(1))/value(mm_pxl_scale);
%                  pixel_pos2(2)=value(centre(2)) - value(position_2(2))/value(mm_pxl_scale);
%                  TemporaryPos2=Pix2Cart(value(img_dim), 1, pixel_pos2);
%                  currentPos2.value=TemporaryPos2(1,:);
%                  
%                  pixel_pos3(1)=value(centre(1)) + value(position_3(1))/value(mm_pxl_scale);
%                  pixel_pos3(2)=value(centre(2)) - value(position_3(2))/value(mm_pxl_scale);
%                  TemporaryPos3=Pix2Cart(value(img_dim), 1, pixel_pos3);
%                  currentPos3.value=TemporaryPos3(1,:);
%                  
%                  pixel_pos4(1)=value(centre(1)) + value(position_4(1))/value(mm_pxl_scale);
%                  pixel_pos4(2)=value(centre(2)) - value(position_4(2))/value(mm_pxl_scale);
%                  TemporaryPos4=Pix2Cart(value(img_dim), 1, pixel_pos4);
%                  currentPos4.value=TemporaryPos4(1,:);
                 
   %     %   %   %   % added to have rotation - 25-11-14
                 %taken from grid creation, way to use the roation angle
%                  if value(origin) && value(coordinates)
%                      % Rotating by AP_angle degrees to be able to use mm from bregma
%                      APrads= ((AP_angle)*pi)/180;
%                      
%                      [t1 r1]=cart2pol(TemporaryPos1(:,1), TemporaryPos1(:,2));
%                      [TemporaryPos1(:,1) TemporaryPos1(:,2)]=pol2cart(t1 + APrads,r1); 
%                      TemporaryPos1 = round( TemporaryPos1 * 10000)/10000;
%                      
%                      [t1 r1]=cart2pol(TemporaryPos2(:,1), TemporaryPos2(:,2));
%                      [TemporaryPos2(:,1) TemporaryPos2(:,2)]=pol2cart(t1 + APrads,r1); 
%                      TemporaryPos2 = round( TemporaryPos2 * 10000)/10000;
%                      
%                      [t1 r1]=cart2pol(TemporaryPos3(:,1), TemporaryPos3(:,2));
%                      [TemporaryPos3(:,1) TemporaryPos3(:,2)]=pol2cart(t1 + APrads,r1); 
%                      TemporaryPos3 = round( TemporaryPos3 * 10000)/10000;
%                      
%                      [t1 r1]=cart2pol(TemporaryPos4(:,1), TemporaryPos4(:,2));
%                      [TemporaryPos4(:,1) TemporaryPos4(:,2)]=pol2cart(t1 + APrads,r1); 
%                      TemporaryPos4 = round( TemporaryPos4 * 10000)/10000;                     
%                   
%                  end;
%                   currentPos1.value=TemporaryPos1(1,:);
%                  currentPos2.value=TemporaryPos2(1,:);
%                  currentPos3.value=TemporaryPos3(1,:);
%                  currentPos4.value=TemporaryPos4(1,:);
  %      %     %    % %
             else
                 cart_centre = Pix2Cart(value(img_dim),1,value(centre));
                 currentPos1.value=value(position_1)+cart_centre(1,:);
                 currentPos2.value=value(position_2)+cart_centre(1,:);
                 currentPos3.value=value(position_3)+cart_centre(1,:);
                 currentPos4.value=value(position_4)+cart_centre(1,:);
             end;
             
         else  %Getting positions from image clicking.
             
             %Calibration function - pixel to cart coords
             tru_pos=zeros(4,2);
             [tru_pos]=Pix2Cart(imgDimension, value(n_pos), value(img_pos));
             
             %storing values in variable to be used
             currentPos1.value=tru_pos(1,:);
             currentPos2.value=tru_pos(2,:);
             currentPos3.value=tru_pos(3,:);
             currentPos4.value=tru_pos(4,:);
             
             if value(coordinates) %define positions in millimitres
                 img2man=ones(4,1)*[imgDimension(2) imgDimension(1)]/2;
                 for j=1:value(n_pos)
                     img2man(j,:) = value(img_pos(j,:));
                 end;
                 %updating UI values
                 position_1.value=[(img2man(1,1)-value(centre(1)))*value(mm_pxl_scale) ...
                     (value(centre(2))-img2man(1,2))*value(mm_pxl_scale)];
                 position_2.value=[(img2man(2,1)-value(centre(1)))*value(mm_pxl_scale) ...
                     (value(centre(2))-img2man(2,2))*value(mm_pxl_scale)];
                 position_3.value=[(img2man(3,1)-value(centre(1)))*value(mm_pxl_scale) ...
                     (value(centre(2))-img2man(3,2))*value(mm_pxl_scale)];
                 position_4.value=[(img2man(4,1)-value(centre(1)))*value(mm_pxl_scale) ...
                     (value(centre(2))-img2man(4,2))*value(mm_pxl_scale)];
                 
             else %send positions in cartesian coordinates
                 %passing values from image clicking to UI
                 img2man=zeros(4,2);
                 for j=1:value(n_pos)
                     img2man(j,:) = tru_pos(j,:);
                 end;
                 %updating UI values
                 position_1.value=img2man(1,:);
                 position_2.value=img2man(2,:);
                 position_3.value=img2man(3,:);
                 position_4.value=img2man(4,:);
             end;
             
         end;
         
         %% Time handling 
         % Weighting the different multiple stimulation sets.
         probA=value(prob_A)/(value(prob_A)+value(prob_B)+value(prob_C)+value(prob_D));
         probB=value(prob_B)/(value(prob_A)+value(prob_B)+value(prob_C)+value(prob_D));
         probC=value(prob_C)/(value(prob_A)+value(prob_B)+value(prob_C)+value(prob_D));
         probD=value(prob_D)/(value(prob_A)+value(prob_B)+value(prob_C)+value(prob_D));
         
         timeProb = zeros(4,1) ; %vector with 0s to all probabilities and sums
         timeProb = cumsum([probA probB probC probD]);
         
         timeRand = rand*timeProb(end);
         
         time1=0; time2=0; time3=0; time4=0;
 
         %Chosing the correct set of timings
         if timeRand <= timeProb(1)
             currentTimeSlot.value = 'A';
             
             %Creating variables that are the difference between time
             %coordinates
             time1=value(time_1A(2))-value(time_1A(1));
             time2=value(time_2A(2))-value(time_2A(1));
             time3=value(time_3A(2))-value(time_3A(1));
             time4=value(time_4A(2))-value(time_4A(1));
             
             %Time lenghts for each period in which AOM should be ON - each
             %photo-stim interval has its individual time lenght
             if time1~=0
                 currentPulseDuration1.value=time1;
                 currentPulseDuration2.value=time2;
                 currentPulseDuration3.value=time3;
                 currentPulseDuration4.value=time4;
             else %if time1=0
                 currentPulseDuration1.value=0.001;
                 if time2~=0
                     currentPulseDuration2.value=time2;
                     currentPulseDuration3.value=time3;
                     currentPulseDuration4.value=time4;
                 else %if time2=0
                     currentPulseDuration2.value=0.001;
                     if time3~=0
                         currentPulseDuration3.value=time3;
                         currentPulseDuration4.value=time4;
                     else %if time3=0
                         currentPulseDuration3.value=0.001;
                         if time4~=0
                             currentPulseDuration4.value=time4;
                         else
                             currentPulseDuration4.value=0.001;
                         end
                     end
                 end
             end
             
             %Creating vector with times to send to AOSW - each should be
             %the time during which position should be the one stimulated
             if time1 ~= 0  
                 if time2==0
                     time.value = [value(time_1A(2))-value(time_1A(1)) 0 ...
                         0 0];
                 elseif time3==0
                     time.value = [value(time_1A(2))-value(time_1A(1)) value(time_2A(2))-value(time_1A(2))...
                         0 0];
                 elseif time4==0
                     time.value = [value(time_1A(2))-value(time_1A(1)) value(time_2A(2))-value(time_1A(2))...
                         value(time_3A(2))-value(time_2A(2)) 0];
                 else
                     time.value = [value(time_1A(2))-value(time_1A(1)) value(time_2A(2))-value(time_1A(2))...
                         value(time_3A(2))-value(time_2A(2)) value(time_4A(2))-value(time_3A(2))];
                 end;
             else %if time1=0 
                 if time2 ~=0 
                     if time3==0
                     time.value = [0 value(time_2A(2))-value(time_2A(1))...
                         0 0];
                     elseif time4==0
                         time.value = [0 value(time_2A(2))-value(time_2A(1)) value(time_3A(2))-value(time_2A(2))...
                         0];
                     else
                         time.value = [0 value(time_2A(2))-value(time_2A(1)) value(time_3A(2))-value(time_2A(2))...
                         value(time_4A(2))-value(time_3A(2))];
                     end;
                 elseif time3 ~=0
                     if time4==0
                         time.value = [0 0 value(time_3A(2))-value(time_3A(1)) ...
                         0];
                     else
                         time.value = [0 0 value(time_3A(2))-value(time_3A(1)) ...
                             value(time_4A(2))-value(time_3A(2))];
                     end;
                 elseif time4 ~=0
                     time.value = [0 0 0 value(time_4A(2))-value(time_4A(1))];
                 end;
             end;

             
             %Time lenghts to serve as Preamble for each AOM SW - using
             %total difference between begining of first stim interval and
             %the beggining of the current photo-stim position.
             
             if time1 ~=0
                 current_time_rel_stim1.value=value(time_1A(1))+value(preStimulus);
                 stim_preamble.value=value(current_time_rel_stim1);
                 if time2== 0
                     current_time_rel_stim2.value=0;
                 else
                     current_time_rel_stim2.value=value(time_2A(1))-value(time_1A(2));
                 end
                 if time3== 0
                     current_time_rel_stim3.value=0;
                 else
                     current_time_rel_stim3.value=value(time_3A(1))-value(time_2A(2));
                 end
                 if time4== 0
                     current_time_rel_stim4.value=0;
                 else
                     current_time_rel_stim4.value=value(time_4A(1))-value(time_3A(2));
                 end
             else %if time1=0
                 current_time_rel_stim1.value=0;
                 if time2 ~=0
                         current_time_rel_stim2.value=value(time_2A(1))+value(preStimulus);
                         stim_preamble.value=value(current_time_rel_stim2);
                     if time3 ==0
                         current_time_rel_stim3.value=0;
                     else
                         current_time_rel_stim3.value=value(time_3A(1))-value(time_2A(2));
                     end
                     if time4==0
                         current_time_rel_stim4.value=0;
                     else
                         current_time_rel_stim4.value=value(time_4A(1))-value(time_3A(2));
                     end
                 else %if time2=0
                     current_time_rel_stim2.value=0;
                     if time3 ~=0
                         current_time_rel_stim3.value=value(time_3A(1))+value(preStimulus);
                         stim_preamble.value=value(current_time_rel_stim3);
                         if time4==0
                             current_time_rel_stim4.value=0;
                         else
                             current_time_rel_stim4.value=value(time_4A(1))-value(time_3A(2));
                         end
                     else %if time3=0
                         current_time_rel_stim3.value=0;
                         if time4~=0
                             current_time_rel_stim4.value=value(time_4A(1))+value(preStimulus);
                             stim_preamble.value=value(current_time_rel_stim4);
                         end
                     end
                 end    
             end;
             
             
         elseif timeRand <= timeProb(2)
             currentTimeSlot.value = 'B';
             
             %Creating variables that are the difference between time
             %coordinates
             time1=value(time_1B(2))-value(time_1B(1));
             time2=value(time_2B(2))-value(time_2B(1));
             time3=value(time_3B(2))-value(time_3B(1));
             time4=value(time_4B(2))-value(time_4B(1));
             
             %Time lenghts for each period in which AOM should be ON - each
             %photo-stim interval has its individual time lenght
             if time1~=0
                 currentPulseDuration1.value=time1;
                 currentPulseDuration2.value=time2;
                 currentPulseDuration3.value=time3;
                 currentPulseDuration4.value=time4;
             else %if time1=0
                 currentPulseDuration1.value=0.001;
                 if time2~=0
                     currentPulseDuration2.value=time2;
                     currentPulseDuration3.value=time3;
                     currentPulseDuration4.value=time4;
                 else
                     currentPulseDuration2.value=0.001;
                     if time3~=0
                         currentPulseDuration3.value=time3;
                         currentPulseDuration4.value=time4;
                     else %if time3=0
                         currentPulseDuration3.value=0.001;
                         if time4~=0
                             currentPulseDuration4.value=time4;
                         else
                             currentPulseDuration4.value=0.001;
                         end
                     end
                 end
             end
             
             %Creating vector with times to send to AOSW - each should be
             %the time during which position should be the one stimulated
             if time1 ~= 0  
                 if time2==0
                     time.value = [value(time_1B(2))-value(time_1B(1)) 0 ...
                         0 0];
                 elseif time3==0
                     time.value = [value(time_1B(2))-value(time_1B(1)) value(time_2B(2))-value(time_1B(2))...
                         0 0];
                 elseif time4==0
                     time.value = [value(time_1B(2))-value(time_1B(1)) value(time_2B(2))-value(time_1B(2))...
                         value(time_3B(2))-value(time_2B(2)) 0];
                 else
                     time.value = [value(time_1B(2))-value(time_1B(1)) value(time_2B(2))-value(time_1B(2))...
                         value(time_3B(2))-value(time_2B(2)) value(time_4B(2))-value(time_3B(2))];
                 end;
             else %if time1=0 
                 if time2 ~=0 
                     if time3==0
                     time.value = [0 value(time_2B(2))-value(time_2B(1))...
                         0 0];
                     elseif time4==0
                         time.value = [0 value(time_2B(2))-value(time_2B(1)) value(time_3B(2))-value(time_2B(2))...
                         0];
                     else
                         time.value = [0 value(time_2B(2))-value(time_2B(1)) value(time_3B(2))-value(time_2B(2))...
                         value(time_4B(2))-value(time_3B(2))];
                     end;
                 elseif time3 ~=0
                     if time4==0
                         time.value = [0 0 value(time_3B(2))-value(time_3B(1)) ...
                         0];
                     else
                         time.value = [0 0 value(time_3B(2))-value(time_3B(1)) ...
                             value(time_4B(2))-value(time_3B(2))];
                     end;
                 elseif time4 ~=0
                     time.value = [0 0 0 value(time_4B(2))-value(time_4B(1))];
                 end;
             end;

             
             %Time lenghts to serve as Preamble for each AOM SW - using
             %total difference between begining of first stim interval and
             %the beggining of the current photo-stim position.
             
             if time1 ~=0
                 current_time_rel_stim1.value=value(time_1B(1))+value(preStimulus);
                 stim_preamble.value=value(current_time_rel_stim1);
                 if time2== 0
                     current_time_rel_stim2.value=0;
                 else
                     current_time_rel_stim2.value=value(time_2B(1))-value(time_1B(2));
                 end
                 if time3== 0
                     current_time_rel_stim3.value=0;
                 else
                     current_time_rel_stim3.value=value(time_3B(1))-value(time_2B(2));
                 end
                 if time4== 0
                     current_time_rel_stim4.value=0;
                 else
                     current_time_rel_stim4.value=value(time_4B(1))-value(time_3B(2));
                 end
             else %if time1=0
                 current_time_rel_stim1.value=0;
                 if time2 ~=0
                         current_time_rel_stim2.value=value(time_2B(1))+value(preStimulus);
                         stim_preamble.value=value(current_time_rel_stim2);
                     if time3 ==0
                         current_time_rel_stim3.value=0;
                     else
                         current_time_rel_stim3.value=value(time_3B(1))-value(time_2B(2));
                     end
                     if time4==0
                         current_time_rel_stim4.value=0;
                     else
                         current_time_rel_stim4.value=value(time_4B(1))-value(time_3B(2));
                     end
                 else %if time2=0
                     current_time_rel_stim2.value=0;
                     if time3 ~=0
                         current_time_rel_stim3.value=value(time_3B(1))+value(preStimulus);
                         stim_preamble.value=value(current_time_rel_stim3);
                         if time4==0
                             current_time_rel_stim4.value=0;
                         else
                             current_time_rel_stim4.value=value(time_4B(1))-value(time_3B(2));
                         end
                     else %if time3=0
                         current_time_rel_stim3.value=0;
                         if time4~=0
                             current_time_rel_stim4.value=value(time_4B(1))+value(preStimulus);
                             stim_preamble.value=value(current_time_rel_stim4);
                         end
                     end
                 end    
             end;
             
         elseif timeRand <= timeProb(3)
             currentTimeSlot.value = 'C';
             
             %Creating variables that are the difference between time
             %coordinates
             time1=value(time_1C(2))-value(time_1C(1));
             time2=value(time_2C(2))-value(time_2C(1));
             time3=value(time_3C(2))-value(time_3C(1));
             time4=value(time_4C(2))-value(time_4C(1));
             
             %Time lenghts for each period in which AOM should be ON - each
             %photo-stim interval has its individual time lenght
             if time1~=0
                 currentPulseDuration1.value=time1;
                 currentPulseDuration2.value=time2;
                 currentPulseDuration3.value=time3;
                 currentPulseDuration4.value=time4;
             else %if time1=0
                 currentPulseDuration1.value=0.001;
                 if time2~=0
                     currentPulseDuration2.value=time2;
                     currentPulseDuration3.value=time3;
                     currentPulseDuration4.value=time4;
                 else
                     currentPulseDuration2.value=0.001;
                     if time3~=0
                         currentPulseDuration3.value=time3;
                         currentPulseDuration4.value=time4;
                     else %if time3=0
                         currentPulseDuration3.value=0.001;
                         if time4~=0
                             currentPulseDuration4.value=time4;
                         else
                             currentPulseDuration4.value=0.001;
                         end
                     end
                 end
             end
             
             %Creating vector with times to send to AOSW - each should be
             %the time during which position should be the one stimulated
             if time1 ~= 0  
                 if time2==0
                     time.value = [value(time_1C(2))-value(time_1C(1)) 0 ...
                         0 0];
                 elseif time3==0
                     time.value = [value(time_1C(2))-value(time_1C(1)) value(time_2C(2))-value(time_1C(2))...
                         0 0];
                 elseif time4==0
                     time.value = [value(time_1C(2))-value(time_1C(1)) value(time_2C(2))-value(time_1C(2))...
                         value(time_3C(2))-value(time_2C(2)) 0];
                 else
                     time.value = [value(time_1C(2))-value(time_1C(1)) value(time_2C(2))-value(time_1C(2))...
                         value(time_3C(2))-value(time_2C(2)) value(time_4C(2))-value(time_3C(2))];
                 end;
             else %if time1=0 
                 if time2 ~=0 
                     if time3==0
                     time.value = [0 value(time_2C(2))-value(time_2C(1))...
                         0 0];
                     elseif time4==0
                         time.value = [0 value(time_2C(2))-value(time_2C(1)) value(time_3C(2))-value(time_2C(2))...
                         0];
                     else
                         time.value = [0 value(time_2C(2))-value(time_2C(1)) value(time_3C(2))-value(time_2C(2))...
                         value(time_4C(2))-value(time_3C(2))];
                     end;
                 elseif time3 ~=0
                     if time4==0
                         time.value = [0 0 value(time_3C(2))-value(time_3C(1)) ...
                         0];
                     else
                         time.value = [0 0 value(time_3C(2))-value(time_3C(1)) ...
                             value(time_4C(2))-value(time_3C(2))];
                     end;
                 elseif time4 ~=0
                     time.value = [0 0 0 value(time_4C(2))-value(time_4C(1))];
                 end;
             end;

             
             %Time lenghts to serve as Preamble for each AOM SW - using
             %total difference between begining of first stim interval and
             %the beggining of the current photo-stim position.
             
             if time1 ~=0
                 current_time_rel_stim1.value=value(time_1C(1))+value(preStimulus);
                 stim_preamble.value=value(current_time_rel_stim1);
                 if time2== 0
                     current_time_rel_stim2.value=0;
                 else
                     current_time_rel_stim2.value=value(time_2C(1))-value(time_1C(2));
                 end
                 if time3== 0
                     current_time_rel_stim3.value=0;
                 else
                     current_time_rel_stim3.value=value(time_3C(1))-value(time_2C(2));
                 end
                 if time4== 0
                     current_time_rel_stim4.value=0;
                 else
                     current_time_rel_stim4.value=value(time_4C(1))-value(time_3C(2));
                 end
             else %if time1=0
                 current_time_rel_stim1.value=0;
                 if time2 ~=0
                         current_time_rel_stim2.value=value(time_2C(1))+value(preStimulus);
                         stim_preamble.value=value(current_time_rel_stim2);
                     if time3 ==0
                         current_time_rel_stim3.value=0;
                     else
                         current_time_rel_stim3.value=value(time_3C(1))-value(time_2C(2));
                     end
                     if time4==0
                         current_time_rel_stim4.value=0;
                     else
                         current_time_rel_stim4.value=value(time_4C(1))-value(time_3C(2));
                     end
                 else %if time2=0
                     current_time_rel_stim2.value=0;
                     if time3 ~=0
                         current_time_rel_stim3.value=value(time_3C(1))+value(preStimulus);
                         stim_preamble.value=value(current_time_rel_stim3);
                         if time4==0
                             current_time_rel_stim4.value=0;
                         else
                             current_time_rel_stim4.value=value(time_4C(1))-value(time_3C(2));
                         end
                     else %if time3=0
                         current_time_rel_stim3.value=0;
                         if time4~=0
                             current_time_rel_stim4.value=value(time_4C(1))+value(preStimulus);
                             stim_preamble.value=value(current_time_rel_stim4);
                         end
                     end
                 end    
             end;
             
         elseif timeRand <= timeProb(4)
             currentTimeSlot.value = 'D';
             
             %Creating variables that are the difference between time
             %coordinates
             time1=value(time_1D(2))-value(time_1D(1));
             time2=value(time_2D(2))-value(time_2D(1));
             time3=value(time_3D(2))-value(time_3D(1));
             time4=value(time_4D(2))-value(time_4D(1));
             
             %Time lenghts for each period in which AOM should be ON - each
             %photo-stim interval has its individual time lenght
             if time1~=0
                 currentPulseDuration1.value=time1;
                 currentPulseDuration2.value=time2;
                 currentPulseDuration3.value=time3;
                 currentPulseDuration4.value=time4;
             else %if time1=0
                 currentPulseDuration1.value=0.001;
                 if time2~=0
                     currentPulseDuration2.value=time2;
                     currentPulseDuration3.value=time3;
                     currentPulseDuration4.value=time4;
                 else
                     currentPulseDuration2.value=0.001;
                     if time3~=0
                         currentPulseDuration3.value=time3;
                         currentPulseDuration4.value=time4;
                     else %if time3=0
                         currentPulseDuration3.value=0.001;
                         if time4~=0
                             currentPulseDuration4.value=time4;
                         else
                             currentPulseDuration4.value=0.001;
                         end
                     end
                 end
             end
             
             %Creating vector with times to send to AOSW - each should be
             %the time during which position should be the one stimulated
             if time1 ~= 0  
                 if time2==0
                     time.value = [value(time_1D(2))-value(time_1D(1)) 0 ...
                         0 0];
                 elseif time3==0
                     time.value = [value(time_1D(2))-value(time_1D(1)) value(time_2D(2))-value(time_1D(2))...
                         0 0];
                 elseif time4==0
                     time.value = [value(time_1D(2))-value(time_1D(1)) value(time_2D(2))-value(time_1D(2))...
                         value(time_3D(2))-value(time_2D(2)) 0];
                 else
                     time.value = [value(time_1D(2))-value(time_1D(1)) value(time_2D(2))-value(time_1D(2))...
                         value(time_3D(2))-value(time_2D(2)) value(time_4D(2))-value(time_3D(2))];
                 end;
             else %if time1=0 
                 if time2 ~=0 
                     if time3==0
                     time.value = [0 value(time_2D(2))-value(time_2D(1))...
                         0 0];
                     elseif time4==0
                         time.value = [0 value(time_2D(2))-value(time_2D(1)) value(time_3D(2))-value(time_2D(2))...
                         0];
                     else
                         time.value = [0 value(time_2D(2))-value(time_2D(1)) value(time_3D(2))-value(time_2D(2))...
                         value(time_4D(2))-value(time_3D(2))];
                     end;
                 elseif time3 ~=0
                     if time4==0
                         time.value = [0 0 value(time_3D(2))-value(time_3D(1)) ...
                         0];
                     else
                         time.value = [0 0 value(time_3D(2))-value(time_3D(1)) ...
                             value(time_4D(2))-value(time_3D(2))];
                     end;
                 elseif time4 ~=0
                     time.value = [0 0 0 value(time_4D(2))-value(time_4D(1))];
                 end;
             end;

             
             %Time lenghts to serve as Preamble for each AOM SW - using
             %total difference between begining of first stim interval and
             %the beggining of the current photo-stim position.
             
             if time1 ~=0
                 current_time_rel_stim1.value=value(time_1D(1))+value(preStimulus);
                 stim_preamble.value=value(current_time_rel_stim1);
                 if time2== 0
                     current_time_rel_stim2.value=0;
                 else
                     current_time_rel_stim2.value=value(time_2D(1))-value(time_1D(2));
                 end
                 if time3== 0
                     current_time_rel_stim3.value=0;
                 else
                     current_time_rel_stim3.value=value(time_3D(1))-value(time_2D(2));
                 end
                 if time4== 0
                     current_time_rel_stim4.value=0;
                 else
                     current_time_rel_stim4.value=value(time_4D(1))-value(time_3D(2));
                 end
             else %if time1=0
                 current_time_rel_stim1.value=0;
                 if time2 ~=0
                         current_time_rel_stim2.value=value(time_2D(1))+value(preStimulus);
                         stim_preamble.value=value(current_time_rel_stim2);
                     if time3 ==0
                         current_time_rel_stim3.value=0;
                     else
                         current_time_rel_stim3.value=value(time_3D(1))-value(time_2D(2));
                     end
                     if time4==0
                         current_time_rel_stim4.value=0;
                     else
                         current_time_rel_stim4.value=value(time_4D(1))-value(time_3D(2));
                     end
                 else %if time2=0
                     current_time_rel_stim2.value=0;
                     if time3 ~=0
                         current_time_rel_stim3.value=value(time_3D(1))+value(preStimulus);
                         stim_preamble.value=value(current_time_rel_stim3);
                         if time4==0
                             current_time_rel_stim4.value=0;
                         else
                             current_time_rel_stim4.value=value(time_4D(1))-value(time_3D(2));
                         end
                     else %if time3=0
                         current_time_rel_stim3.value=0;
                         if time4~=0
                             current_time_rel_stim4.value=value(time_4D(1))+value(preStimulus);
                             stim_preamble.value=value(current_time_rel_stim4);
                         end
                     end
                 end    
             end;
         end;
         
     end;
     
 end;
 

 %%  
  % Converting the stimulation position from the "cartesian coordinates"
  % to the millimetre value in relation to centre, to be updated in the
  % user interface display
  max_x=10; max_y = 10;
   
  pixel1=(  value(currentPos1(1))+max_x ) * ( value(img_dim(2))/(2*max_x) );
  pixel2=( -value(currentPos1(2))+max_y ) * ( value(img_dim(1))/(2*max_y) );  
  
  currentPos_mm.value=[(pixel1-value(centre(1)))*value(mm_pxl_scale) ...
                       (value(centre(2))-pixel2)*value(mm_pxl_scale)];
                   
  t=2000; %Duration in FSM steps (6000kHz)/3 to use in AOmatrix to convert seconds
  
  %If calibration parameters are on, Or there is instruction to 
  % stimulate, correct the voltages to be sent to the mirrors (in grid mode) 
  if  value(gridSweep) && loadCalib && ~value(noStim) 
 
       %Rotation correction.
%        correction_theta= value(rotation)*(pi/180) %radians conversion    
%        [theta rho] = cart2pol(value(currentPos1(1)),value(currentPos1(2)));
%        [rotatedXpos rotatedYpos] = pol2cart(theta + correction_theta,rho);
%        
%        [theta2 rho2] = cart2pol(value(voltage_bias(1)),value(voltage_bias(2)));
%        [rotatedBias1 rotatedBias2] = pol2cart(theta2 + correction_theta,rho2);
% 
%        %ROD 12 03 14 attempt to correct weird bug with rotation - makes it
%        %WORST streches the square even further (diagonal subir para a direita s
%        %somar o angulo)
% %        [theta3 rho3] = cart2pol(value(xy_amplitudes(1)),value(xy_amplitudes(2)));
% %        [rotatedAmp1 rotatedAmp2] = pol2cart(theta3 + correction_theta,rho3);
%        
%        
%    %Scaling of voltages to the amplitudes determined in calibration. This
%    %way, user only has to give cartesian coordinates. + bias correction
%         % round(x*10000)/10000 is used to prevent numerical errors from
%     %coordinates conversion function to crash program due to values higher
%     %than 10V
%        
%        FinalValue1.value = (((round(rotatedXpos*10000)/10000)/10) * value(xy_amplitudes(1)))+ rotatedBias1;
%        FinalValue2.value = (((round(rotatedYpos*10000)/10000)/10) * value(xy_amplitudes(2)))+ rotatedBias2;

       correction_theta= value(rotation)*(pi/180); %radians conversion    
       
       voltageCurrentPos1=((round(value(currentPos1(1))*10000)/10000)/10) * value(xy_amplitudes(1));
       voltageCurrentPos2=((round(value(currentPos1(2))*10000)/10000)/10) * value(xy_amplitudes(2));
        
       [theta rho] = cart2pol(voltageCurrentPos1,voltageCurrentPos2);
       [rotatedXpos rotatedYpos] = pol2cart(theta + correction_theta,rho);
       
       [theta2 rho2] = cart2pol(value(voltage_bias(1)),value(voltage_bias(2)));
       [rotatedBias1 rotatedBias2] = pol2cart(theta2 + correction_theta,rho2);
    
       FinalValue1.value = rotatedXpos + rotatedBias1;
       FinalValue2.value = rotatedYpos + rotatedBias2;

  elseif value(manual_img) && loadCalib && ~value(noStim)   % normal or multi stim s ON  
                  
       correction_theta= value(rotation)*(pi/180);
       [thetaB rhoB] = cart2pol(value(voltage_bias(1)),value(voltage_bias(2)));
       [rotatedBias1 rotatedBias2] = pol2cart(thetaB + correction_theta,rhoB); 
       
       % Position 1
       voltageCurrentPos1_1=((round(value(currentPos1(1))*10000)/10000)/10) * value(xy_amplitudes(1));
       voltageCurrentPos2_1=((round(value(currentPos1(2))*10000)/10000)/10) * value(xy_amplitudes(2));
        
       [theta1 rho1] = cart2pol(voltageCurrentPos1_1,voltageCurrentPos2_1);
       [rotatedXpos1 rotatedYpos1] = pol2cart(theta1 + correction_theta,rho1);
          
       FinalMultiPos1_1.value = rotatedXpos1+ rotatedBias1;
       FinalMultiPos2_1.value = rotatedYpos1+ rotatedBias2;
       
       % Position 2
       voltageCurrentPos1_2=((round(value(currentPos2(1))*10000)/10000)/10) * value(xy_amplitudes(1));
       voltageCurrentPos2_2=((round(value(currentPos2(2))*10000)/10000)/10) * value(xy_amplitudes(2));
        
       [theta2 rho2] = cart2pol(voltageCurrentPos1_2,voltageCurrentPos2_2);
       [rotatedXpos2 rotatedYpos2] = pol2cart(theta2 + correction_theta,rho2);
          
       FinalMultiPos1_2.value = rotatedXpos2+ rotatedBias1;
       FinalMultiPos2_2.value = rotatedYpos2+ rotatedBias2;
       % Position 3
       voltageCurrentPos1_3=((round(value(currentPos3(1))*10000)/10000)/10) * value(xy_amplitudes(1));
       voltageCurrentPos2_3=((round(value(currentPos3(2))*10000)/10000)/10) * value(xy_amplitudes(2));
        
       [theta3 rho3] = cart2pol(voltageCurrentPos1_3,voltageCurrentPos2_3);
       [rotatedXpos3 rotatedYpos3] = pol2cart(theta3 + correction_theta,rho3);
          
       FinalMultiPos1_3.value = rotatedXpos3+ rotatedBias1;
       FinalMultiPos2_3.value = rotatedYpos3+ rotatedBias2;
       % Position 4
       voltageCurrentPos1_4=((round(value(currentPos4(1))*10000)/10000)/10) * value(xy_amplitudes(1));
       voltageCurrentPos2_4=((round(value(currentPos4(2))*10000)/10000)/10) * value(xy_amplitudes(2));
        
       [theta4 rho4] = cart2pol(voltageCurrentPos1_4,voltageCurrentPos2_4);
       [rotatedXpos4 rotatedYpos4] = pol2cart(theta4 + correction_theta,rho4);
          
       FinalMultiPos1_4.value = rotatedXpos4+ rotatedBias1;
       FinalMultiPos2_4.value = rotatedYpos4+ rotatedBias2;
      
  else %If we do not load calibration, or chances dictate No stimulation 
       % should occur,just use direct input from user / values without
       % calibration
       FinalValue1.value = value(currentPos1(1));
       FinalValue2.value = value(currentPos1(2));
  end;
  
  
   % vector responsible for inverting axis
  axisInversion=[1 -1]; 
  
  
   %% Simultaneous Photo-Stimulation!
 if value(simul_stim)
     % Need to atribute position 1 and 2 from manual mode (up to 4 after all);
     % Calculate time variables that define the positions in each moment
     %individualpulse; timetomovethemirrors; -> depend on frequency;
     % Total time, will dictate the number of repetitions for each step.
     % Create teh vectors with appropriate lenght, respecting times 
     %soomething in the lines of [Pos1 0 pos2 0]*ones(1,t*total_duration/4)
     %where Pos1 and Pos2 will variable lenghts depending on the frequenncy
     %chosen..
     
        % allow 2 pairs of simultaneous stimulation randomly chjosen each
     % trial - this will only change first two positions (simultaneous
     % simtulation of 2 positions). if user wants 4positions, the last two
     % will rewmain the same. this allows to do 2x2, 3x2 and 4x2 simul
     % photostim
     PeriodVector=0;
     SimulPos1=[value(FinalMultiPos1_1) value(FinalMultiPos2_1)];
     SimulPos2=[value(FinalMultiPos1_2) value(FinalMultiPos2_2)];
     
     if value(currentTimeSlot) == 'B'  %choosing set B of po
         SimulPos1=[value(FinalMultiPos1_3) value(FinalMultiPos2_3)];
         SimulPos2=[value(FinalMultiPos1_4) value(FinalMultiPos2_4)];
     end   
     
%      TotalStimTime.value=value(current_time_rel_stim1)+value(currentPulseDuration1);
     TotalStimTime.value=value(currentPulseDuration1);
        
     mirrors_moving = value(mirrors_moving_time)*2; %time for mirrors moving (in fsm units) (put variable) 
     
     %vectors with Positions that mirrors will move to...The
         %(2000/2*f)-2 -> 2000 is the multiplicative factor to have 1
         %second. 1/f is the period we want, -2 is to subtract 1ms (each
         %unit is 0.5ms) to allow the mirrors to start moving to the next
         %position in time for the AOM.
     if value(simul_pos)==2
         PeriodicSignal1=[SimulPos1(1)*ones(1,(2000/(value(simul_pos)*value(frequency)))-mirrors_moving) ...
             SimulPos2(1)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos1(2)*ones(1,mirrors_moving)]; 
         PeriodicSignal2=[SimulPos1(2)*ones(1,(2000/(value(simul_pos)*value(frequency)))-mirrors_moving) ...
             SimulPos2(2)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos1(2)*ones(1,mirrors_moving)];
               
     elseif value(simul_pos)==3
         SimulPos3=[value(FinalMultiPos1_3) value(FinalMultiPos2_3)];
         
         PeriodicSignal1=[SimulPos1(1)*ones(1,(2000/(value(simul_pos)*value(frequency)))-mirrors_moving) ...
             SimulPos2(1)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos3(1)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos1(2)*ones(1,mirrors_moving)]; 
         PeriodicSignal2=[SimulPos1(2)*ones(1,(2000/(value(simul_pos)*value(frequency)))-mirrors_moving) ...
             SimulPos2(2)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos3(2)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos1(2)*ones(1,mirrors_moving)];

     else %value(simul_pos)==4
         SimulPos3=[value(FinalMultiPos1_3) value(FinalMultiPos2_3)];
         SimulPos4=[value(FinalMultiPos1_4) value(FinalMultiPos2_4)];
         
         PeriodicSignal1=[SimulPos1(1)*ones(1,(2000/(value(simul_pos)*value(frequency)))-mirrors_moving) ...
             SimulPos2(1)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos3(1)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos4(1)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos1(1)*ones(1,mirrors_moving)]; 
         PeriodicSignal2=[SimulPos1(2)*ones(1,(2000/(value(simul_pos)*value(frequency)))-mirrors_moving) ...
             SimulPos2(2)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos3(2)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos4(2)*ones(1,2000/(value(simul_pos)*value(frequency))) ...
             SimulPos1(2)*ones(1,mirrors_moving)];   
     end;
     
     Signal1=repmat(PeriodicSignal1, 1, value(frequency)*value(TotalStimTime));
     Signal2=repmat(PeriodicSignal2, 1, value(frequency)*value(TotalStimTime));
     
 end;
 
 %% 
%Changing multiStim display variable to inform user that multi stim is
%happening - CHANGE THE WAY THIS IS DONE!!!
if ((value(time(1))+value(time(2))+value(time(3)))==0 || (value(time(1))+value(time(2))+value(time(4)))==0 || (value(time(1))+value(time(3))+value(time(4)))==0 || (value(time(2))+value(time(3))+value(time(4)))==0) &&  value(manual_img)
    %This means that only one of the positions will be stimulated
    multiStim.value=0;
else
    multiStim.value=1;
end;

%%
if ~value(gridSweep) && value(manual_img) && value(simul_stim)  %SIMUL STIM ON
    AOMatrix1.value=[axisInversion(value(invert_1)+1)*(Signal1/10);...
        zeros(1,size(Signal1,2))];
    value(AOMatrix1);
    AOMatrix2.value=[axisInversion(value(invert_2)+1)*(Signal2/10);...
        zeros(1,size(Signal2,2))];
    
    if value(simul_pos)==2
        simul_values_unit = [0 0.5*ones(1,(2000/(value(simul_pos)*value(frequency)))-(mirrors_moving+1)) ...
            zeros(1,mirrors_moving+1) 0.5*ones(1,(2000/(value(simul_pos)*value(frequency)))-(mirrors_moving+1)) ...
            zeros(1,mirrors_moving)];
    elseif value(simul_pos)==3
        simul_values_unit = [0 0.5*ones(1,(2000/(value(simul_pos)*value(frequency)))-(mirrors_moving+1)) ...
            zeros(1,mirrors_moving+1) 0.5*ones(1,(2000/(value(simul_pos)*value(frequency)))-(mirrors_moving+1)) ...
            zeros(1,mirrors_moving+1) 0.5*ones(1,(2000/(value(simul_pos)*value(frequency)))-(mirrors_moving+1)) ...
            zeros(1,mirrors_moving)];
    else %value(simul_pos)==4
        simul_values_unit = [0 0.5*ones(1,(2000/(value(simul_pos)*value(frequency)))-(mirrors_moving+1)) ...
            zeros(1,mirrors_moving+1) 0.5*ones(1,(2000/(value(simul_pos)*value(frequency)))-(mirrors_moving+1)) ...
            zeros(1,mirrors_moving+1) 0.5*ones(1,(2000/(value(simul_pos)*value(frequency)))-(mirrors_moving+1)) ...
            zeros(1,mirrors_moving+1) 0.5*ones(1,(2000/(value(simul_pos)*value(frequency)))-(mirrors_moving+1)) ...
            zeros(1,mirrors_moving)];
    end;
       
    simul_values = repmat(simul_values_unit, 1, value(frequency)*value(TotalStimTime));
    
    % Intensity ramping down    
    step_down = 1/(value(ramp_lenght)*t);
    ramp_down = 1-step_down:(-step_down):0 ; 
    
    rampFunction = [ones( 1, size(simul_values,2)-(value(ramp_lenght)*t) ) ramp_down]; 
    
    % AOM case 1
%     AOM_matrix.value=[ (value(currentlaserP)*simul_values).*rampFunction; ...
%                         zeros(1,size(simul_values,2))] ; 

AOM_matrix.value=[ (norminv(laserPwr,.4961, .2339)*simul_values).*rampFunction; ...
                        zeros(1,size(simul_values,2))] ; 

%          AOM_mtx_values = (laserPwr*simul_values).*rampFunction;
%          AOM_mtx_values(AOM_mtx_values<.016963)=.016963;
%    AOM_matrix.value=[ norminv(AOM_mtx_values,.4961, .2339); ...
%                         zeros(1,size(simul_values,2)) ]; 
    
   % The +1 in moving mirrors is to correct for the drag we'd see in the displacement 
   % of the mirrors to the first position. also added in second to even the pulse's length  
    SinglePulseLength.value = (1000/(value(frequency)*value(simul_pos))) - (value(mirrors_moving_time)+0.5); 
    
                    
elseif  ~value(gridSweep) && value(manual_img) && ~value(simul_stim)%Manual Mode or Multi Stim is ON)
    
    if value(currentTimeSlot)=='A'
        AOMatrix1.value=[ axisInversion(value(invert_1)+1)*( value(FinalMultiPos1_1)/10 * ones(1, t*(value(time(1))+0.050)) ); ...);...
            zeros(1,t*(value(time(1)) +0.050) )];
        AOMatrix2.value=[ axisInversion(value(invert_2)+1)*(value(FinalMultiPos2_1)/10 * ones(1, t*(value(time(1))+0.050)) ); ...); ...
            zeros(1,t*( value(time(1))+0.050 ) )]; 
        
        CurrentTimeRelStimulus = value(current_time_rel_stim1);
        CurrentPulseDuration = value(currentPulseDuration1);
        
    elseif value(currentTimeSlot)=='B'
        AOMatrix1.value=[ axisInversion(value(invert_1)+1)*( value(FinalMultiPos1_2)/10 * ones(1, t*(value(time(2))+0.050)) ); ...);...
            zeros(1,t*(value(time(2)) +0.050) )];
        AOMatrix2.value=[ axisInversion(value(invert_2)+1)*(value(FinalMultiPos2_2)/10 * ones(1, t*(value(time(2))+0.050)) ); ...); ...
            zeros(1,t*( value(time(2))+0.050 ) )];
        
        CurrentTimeRelStimulus = value(current_time_rel_stim2);
        CurrentPulseDuration = value(currentPulseDuration2);
        
    elseif value(currentTimeSlot)=='C'
        AOMatrix1.value=[ axisInversion(value(invert_1)+1)*( value(FinalMultiPos1_3)/10 * ones(1, t*(value(time(3))+0.050)) ); ...);...
            zeros(1,t*(value(time(3)) +0.050) )];
        AOMatrix2.value=[ axisInversion(value(invert_2)+1)*(value(FinalMultiPos2_3)/10 * ones(1, t*(value(time(3))+0.050)) ); ...); ...
            zeros(1,t*( value(time(3))+0.050 ) )];
        
        CurrentTimeRelStimulus = value(current_time_rel_stim3);
        CurrentPulseDuration = value(currentPulseDuration3);
         
    else 
        AOMatrix1.value=[ axisInversion(value(invert_1)+1)*( value(FinalMultiPos1_4)/10 * ones(1, t*(value(time(4))+0.050)) ); ...);...
            zeros(1,t*(value(time(4)) +0.050) )];
        AOMatrix2.value=[ axisInversion(value(invert_2)+1)*(value(FinalMultiPos2_4)/10 * ones(1, t*(value(time(4))+0.050)) ); ...); ...
            zeros(1,t*( value(time(4))+0.050 ) )];
        
        CurrentTimeRelStimulus = value(current_time_rel_stim4);
        CurrentPulseDuration = value(currentPulseDuration4);
    end
        
      %AOM analog
    aom_x = 1:((CurrentPulseDuration+0.001)*t) ;
    
    sinus_values = ( sin(aom_x * ( (2*pi*value(frequency))/t ))*0.5 + 0.5 )/2;
%     final_sinus_value = sinus_values(end-(value(ramp_lenght)*t));
    final_sinus_value=1;
    
    step_down = 1/(value(ramp_lenght)*t);
    ramp_down = 1-step_down:(-step_down):0 ;
    
    % AOM case 2
    AOM_matrix.value=[ value(currentlaserP)*sinus_values(1:(end-(value(ramp_lenght)*t)))  value(currentlaserP)*sinus_values((end-(value(ramp_lenght)*2000)+1):end).*ramp_down; ...
        zeros(1,t*(CurrentPulseDuration+0.001))];
    

%     AOM_matrix.value=[ norminv(laserPwr,.4961, .2339)*sinus_values(1:(end-(value(ramp_lenght)*t)))  norminv(laserPwr,.4961, .2339)*sinus_values((end-(value(ramp_lenght)*2000)+1):end).*ramp_down; ...
%         zeros(1,t*(CurrentPulseDuration+0.001))];

%     AOM_mtx_values1 = laserPwr*sinus_values(1:(end-(value(ramp_lenght)*t)));
%     AOM_mtx_values1(AOM_mtx_values1<.016963)=.016963;
%     AOM_mtx_values2 = laserPwr*sinus_values((end-(value(ramp_lenght)*2000)+1):end).*ramp_down;
%     AOM_mtx_values2(AOM_mtx_values2<.016963)=.016963;
%     
%     AOM_matrix.value=[ norminv(AOM_mtx_values1,0.4881, 0.23)  norminv(AOM_mtx_values2,0.4881, 0.23); ...
%         zeros(1,t*(CurrentPulseDuration+0.001))]; 
    
elseif value(gridSweep) && ~value(manual_img)      %Grid Mode is ON
    
    stim_preamble.value=value(time_rel_stim)+value(preStimulus);
    current_time_rel_stim1.value=value(time_rel_stim)+value(preStimulus);
    currentPulseDuration1.value=value(pulseDuration);
    current_time_rel_stim2.value=0;
    currentPulseDuration2.value=0;
    current_time_rel_stim3.value=0;
    currentPulseDuration3.value=0;
    current_time_rel_stim4.value=0;
    currentPulseDuration4.value=0;
    
    AOMatrix1.value=[ axisInversion(value(invert_1)+1)*(value(FinalValue1)/10 * ones(1, t*( value(pulseDuration)+0.010) ));...
        zeros(1,t*(value(pulseDuration)+0.010))];
    AOMatrix2.value=[ axisInversion(value(invert_2)+1)*(value(FinalValue2)/10 * ones(1, t*( value(pulseDuration)+0.010) ));...
        zeros(1,t*(value(pulseDuration)+0.010))]; %plus 1+9ms is to account for the time the aom might be delayed due to errors in timing.

    CurrentPulseDuration = value(currentPulseDuration1);  
    
    
    % DO IF with choice of AOM_wave - either = sinus_values or
    % square_values... allow user to choose.
    %AOM timings calculations
    aom_x = 1:((CurrentPulseDuration+0.001)*t) ;
    
    sinus_values = ( sin(aom_x * ( (2*pi*value(frequency))/t ))*0.5 + 0.5 )/2;
%     final_sinus_value = sinus_values(end-(value(ramp_lenght)*t));
  
    step_down = 1/(value(ramp_lenght)*t);
    ramp_down = 1-step_down:(-step_down):0 ;
    
    % AOM case 3
    AOM_matrix.value=[ value(currentlaserP)*sinus_values(1:(end-(value(ramp_lenght)*t)))  value(currentlaserP)*sinus_values((end-(value(ramp_lenght)*2000)+1):end).*ramp_down; ...
        zeros(1,t*(CurrentPulseDuration+0.001))]; 
   
% AOM_matrix.value=[ norminv(laserPwr,.4961, .2339)*sinus_values(1:(end-(value(ramp_lenght)*t)))  norminv(laserPwr,.4961, .2339)*sinus_values((end-(value(ramp_lenght)*2000)+1):end).*ramp_down; ...
%         zeros(1,t*(CurrentPulseDuration+0.001))]; 

%     AOM_mtx_values1 = laserPwr*sinus_values(1:(end-(value(ramp_lenght)*t)));
%     AOM_mtx_values1(AOM_mtx_values1<.016963)=.016963;
%     AOM_mtx_values2 = laserPwr*sinus_values((end-(value(ramp_lenght)*2000)+1):end).*ramp_down;
%     AOM_mtx_values2(AOM_mtx_values2<.016963)=.016963;
%     AOM_matrix.value=[ norminv( AOM_mtx_values1 ,0.4881, 0.23)  norminv(AOM_mtx_values2,0.4881, 0.23); ...
%         zeros(1,t*(CurrentPulseDuration+0.001))]; 

end;
  
if n_done_trials > 0
    lastnoStim.value = noStimHistory(n_done_trials);
    lastTimeSlot.value = currentTimeSlotHistory(n_done_trials);
    lastPos1.value = currentPos1History(n_done_trials,:);
    lastLaserPower.value = currentLaserPowerHistory(n_done_trials); 
    lastTrial.value = n_done_trials;
end


  % ------------------------------------------------------------------
  %              CHECK_CALIB
  % ------------------------------------------------------------------ 
  %Opens the image taken by qcam from the laser stimulation and plots the 
  %positions selected by the user. Used to check if calibration is well done.
  case 'check_calib'  
      
      picturesPath='C:\Users\User\Desktop\Photo-Stim Pictures';
      cd(picturesPath);
        % Possibility to write the file path or search in explorer.
          if ischar(value(img_path2)) && ~isempty(value(img_path2))
              fullImageFileName=value(img_path2);
          elseif isempty(value(img_path2)) || ~ischar(value(img_path2))
              % Browse for the image file.
              [baseFileName, folder] = uigetfile('*.*', 'Specify an image file');
           % Create the full file name.
              fullImageFileName = fullfile(folder, baseFileName);           
          end;
         
         aux_fig = load(fullImageFileName,'-mat');
          %fig_data = aux_fig.hgS_070000.children(2,1).children.properties.CData;
         fig_data = aux_fig.hgS_070000.children(2,1).children(1,1).properties.CData;
%           if exist('aux_fig.hgS_070000.children(2,1).children(1,1).properties.CData')
%          fig_data = aux_fig.hgS_070000.children(2,1).children(1,1).properties.CData;
%           else
%               fig_data= aux_fig.hgS_070000.children.children.properties.CData;
%           end
         
         figure; 
         colormap gray;
         imagesc(fig_data);
         %truesize();
         
         hold on 
         
         if value(gridSweep)==1
             if value(img_grid)==0    % Corners introduced manually 
                 if value(origin)
                     centre.value=value(bregma_pos);
                 else
                     centre.value=[value(img_dim(2))/2 value(img_dim(1))/2];
                 end;
                 
                 if value(coordinates) %if coordinates are introduced in mm
                     %
                     
                     gPos=GridCreation([value(grid_topright);value(grid_botleft)],value(grid_res),...
                         value(eliminate), value(AP_angle),value(origin),value(coordinates));
                     
                     gPos(:,1)=value(centre(1)) + gPos(:,1)/value(mm_pxl_scale);
                     gPos(:,2)=value(centre(2)) - gPos(:,2)/value(mm_pxl_scale);              
                    
                 else  %coordinates in cart
                     
                     if value(origin)
                         centreCart=Pix2Cart(value(img_dim), 1, value(centre));
                     else
                         centreCart=[0 0];
                     end;
                     
                     max_x=10; max_y = 10;
                     TR=[( value(grid_topright(1))+max_x+centreCart(1) ) * ( value(img_dim(2))/(2*max_x) )...
                     ( -value(grid_topright(2))+max_y-centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )]; 
                     BL=[( value(grid_botleft(1))+max_x+centreCart(1)  ) * ( value(img_dim(2))/(2*max_x) )...
                     ( -value(grid_botleft(2))+max_y -centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )];   
%                      TR=[( value(grid_topright(1))+max_x ) * ( centre(1)/(max_x) )...
%                      ( -value(grid_topright(2))+max_y ) * ( centre(2)/(max_y) )]; 
%                      BL=[( value(grid_botleft(1))+max_x ) * ( centre(1)/(max_x) )...
%                      ( -value(grid_botleft(2))+max_y ) * ( centre(2)/(max_y) )]; 
                         
                     gPos=GridCreation([TR; BL],value(grid_res),value(eliminate),value(AP_angle),value(origin),0);
                 end;
                 
                 x=gPos(:,1);
                 y=gPos(:,2); 
             else % Corners from image
                 gPos=GridCreation(value(img_pos), value(grid_res),value(eliminate),value(AP_angle),0,0);
                 x=gPos(:,1);
                 y=gPos(:,2);   
             end;
         elseif value(manual_img)==1
             if value(n_pos)==0    % positions introduced manually 
                 if value(origin)
                     centre.value=value(bregma_pos);
                 else
                     centre.value=[value(img_dim(2))/2 value(img_dim(1))/2];
                 end;
                 
                 if value(coordinates)
                       %rotating mm coordinates
                 APrads= (value(AP_angle)*pi)/180;
                         
                 [t1 r1]=cart2pol(value(position_1(1)), value(position_1(2)));
                 [Tposition_1(1) Tposition_1(2)]=pol2cart(t1 + APrads,r1);
                 Tposition_1 = round( Tposition_1 * 10000)/10000;
                 
                 [t2 r2]=cart2pol(value(position_2(1)), value(position_2(2)));
                 [Tposition_2(1) Tposition_2(2)]=pol2cart(t2 + APrads,r2);
                 Tposition_2 = round( Tposition_2 * 10000)/10000;
                 
                 [t3 r3]=cart2pol(value(position_3(1)), value(position_3(2)));
                 [Tposition_3(1) Tposition_3(2)]=pol2cart(t3 + APrads,r3);
                 Tposition_3 = round( Tposition_3 * 10000)/10000;
                 
                 [t4 r4]=cart2pol(value(position_4(1)), value(position_4(2)));
                 [Tposition_4(1) Tposition_4(2)]=pol2cart(t4 + APrads,r4);
                 Tposition_4 = round( Tposition_4 * 10000)/10000;
                 %             
                 pixel_pos1(1)=value(centre(1)) + Tposition_1(1)/value(mm_pxl_scale);
                 pixel_pos1(2)=value(centre(2)) - Tposition_1(2)/value(mm_pxl_scale);
                               
                 pixel_pos2(1)=value(centre(1)) + Tposition_2(1)/value(mm_pxl_scale);
                 pixel_pos2(2)=value(centre(2)) - Tposition_2(2)/value(mm_pxl_scale);
                  
                 pixel_pos3(1)=value(centre(1)) + Tposition_3(1)/value(mm_pxl_scale);
                 pixel_pos3(2)=value(centre(2)) - Tposition_3(2)/value(mm_pxl_scale);
                    
                 pixel_pos4(1)=value(centre(1)) + Tposition_4(1)/value(mm_pxl_scale);
                 pixel_pos4(2)=value(centre(2)) - Tposition_4(2)/value(mm_pxl_scale);                 
                     %
                     
%           old           pixel_pos1(1)=value(centre(1)) + value(position_1(1))/value(mm_pxl_scale);
%                      pixel_pos1(2)=value(centre(2)) - value(position_1(2))/value(mm_pxl_scale);
%                      
%                      pixel_pos2(1)=value(centre(1)) + value(position_2(1))/value(mm_pxl_scale);
%                      pixel_pos2(2)=value(centre(2)) - value(position_2(2))/value(mm_pxl_scale);
%                      
%                      pixel_pos3(1)=value(centre(1)) + value(position_3(1))/value(mm_pxl_scale);
%                      pixel_pos3(2)=value(centre(2)) - value(position_3(2))/value(mm_pxl_scale);
%                      
%                      pixel_pos4(1)=value(centre(1)) + value(position_4(1))/value(mm_pxl_scale);
%                      pixel_pos4(2)=value(centre(2)) - value(position_4(2))/value(mm_pxl_scale);
                     
                     x=[pixel_pos1(1); pixel_pos2(1); pixel_pos3(1); pixel_pos4(1)];
                     y=[pixel_pos1(2); pixel_pos2(2); pixel_pos3(2); pixel_pos4(2)];
                 else
                     if value(origin)
                         centreCart=Pix2Cart(value(img_dim), 1, value(centre));
                     else
                         centreCart=[0 0];
                     end;
                     
                     max_x=10; max_y = 10;
                     cartpos1=[( value(position_1(1))+max_x+centreCart(1) ) * ( value(img_dim(2))/(2*max_x) )...
                         ( -value(position_1(2))+max_y-centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )];
                     cartpos2=[( value(position_2(1))+max_x+centreCart(1)  ) * ( value(img_dim(2))/(2*max_x) )...
                         ( -value(position_2(2))+max_y -centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )];
                     cartpos3=[( value(position_3(1))+max_x+centreCart(1)  ) * ( value(img_dim(2))/(2*max_x) )...
                         ( -value(position_3(2))+max_y -centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )];
                     cartpos4=[( value(position_4(1))+max_x+centreCart(1)  ) * ( value(img_dim(2))/(2*max_x) )...
                         ( -value(position_4(2))+max_y -centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )]; 
                     
                     x=[cartpos1(1); cartpos2(1); cartpos3(1); cartpos4(1)];
                     y=[cartpos1(2); cartpos2(2); cartpos3(2); cartpos4(2)];
                 end;
                     
             else % positions from image
                 x=value(img_pos(:,1));
                 y=value(img_pos(:,2));
             end;
         end;
         
         plot(x,y,'bo','MarkerSize',30,'LineWidth',2 )

   
  % ------------------------------------------------------------------
  %              CHECK_CALIB_OVERLAY
  % ------------------------------------------------------------------ 
  %Opens the image taken by qcam from the laser stimulation and plots the 
  %positions selected by the user. Used to check if calibration is well done.
  case 'check_calib_Overlay'  
      
      picturesPath='C:\Users\User\Desktop\Photo-Stim Pictures';
      cd(picturesPath);
        % Possibility to write the file path or search in explorer.
          if ischar(value(img_path_overlay)) && ~isempty(value(img_path_overlay))
              fullImageFileName=value(img_path_overlay);
          elseif isempty(value(img_path_overlay)) || ~ischar(value(img_path_overlay))
              % Browse for the image file.
              [baseFileName, folder] = uigetfile('*.*', 'Specify the Overlayed Image created with loadimage');
           % Create the full file name.
              fullImageFileName = fullfile(folder, baseFileName);           
          end;
         
         aux_fig = load(fullImageFileName,'-mat');
          %fig_data = aux_fig.hgS_070000.children(2,1).children.properties.CData;
%          fig_data = aux_fig.hgS_070000.children(2,1).children(1,1).properties.CData;

% loadimage overlay
%           fig_data= aux_fig.hgS_070000.children.children.properties.CData;
% intrinsic overlay
          fig_data= aux_fig.hgS_070000.children.children(1,1).properties.CData;
    
%Custom Colormap for intrinsic plot!!
            colormapRes = 128;
            anglesMap = hsv(colormapRes);
            vesselsMap = gray(size(anglesMap,1));
            cmap = [vesselsMap; anglesMap];


         figure; 
         colormap(cmap);
         imagesc(fig_data);
         %truesize();
         
         hold on 
         
         if value(gridSweep)==1
             if value(img_grid)==0    % Corners introduced manually 
                 if value(origin)
                     centre.value=value(bregma_pos);
                 else
                     centre.value=[value(img_dim(2))/2 value(img_dim(1))/2];
                 end;
                 
                 if value(coordinates) %if coordinates are introduced in mm
                     %
                     
                     gPos=GridCreation([value(grid_topright);value(grid_botleft)],value(grid_res),...
                         value(eliminate), value(AP_angle),value(origin),value(coordinates));
                     
                     gPos(:,1)=value(centre(1)) + gPos(:,1)/value(mm_pxl_scale);
                     gPos(:,2)=value(centre(2)) - gPos(:,2)/value(mm_pxl_scale);              
                    
                 else  %coordinates in cart
                     
                     if value(origin)
                         centreCart=Pix2Cart(value(img_dim), 1, value(centre));
                     else
                         centreCart=[0 0];
                     end;
                     
                     max_x=10; max_y = 10;
                     TR=[( value(grid_topright(1))+max_x+centreCart(1) ) * ( value(img_dim(2))/(2*max_x) )...
                     ( -value(grid_topright(2))+max_y-centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )]; 
                     BL=[( value(grid_botleft(1))+max_x+centreCart(1)  ) * ( value(img_dim(2))/(2*max_x) )...
                     ( -value(grid_botleft(2))+max_y -centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )];   
%                      TR=[( value(grid_topright(1))+max_x ) * ( centre(1)/(max_x) )...
%                      ( -value(grid_topright(2))+max_y ) * ( centre(2)/(max_y) )]; 
%                      BL=[( value(grid_botleft(1))+max_x ) * ( centre(1)/(max_x) )...
%                      ( -value(grid_botleft(2))+max_y ) * ( centre(2)/(max_y) )]; 
                         
                     gPos=GridCreation([TR; BL],value(grid_res),value(eliminate),value(AP_angle),value(origin),0);
                 end;
                 
                 x=gPos(:,1);
                 y=gPos(:,2); 
             else % Corners from image
                 gPos=GridCreation(value(img_pos), value(grid_res),value(eliminate),value(AP_angle),0,0);
                 x=gPos(:,1);
                 y=gPos(:,2);   
             end;
         elseif value(manual_img)==1
             if value(n_pos)==0    % positions introduced manually 
                 if value(origin)
                     centre.value=value(bregma_pos);
                 else
                     centre.value=[value(img_dim(2))/2 value(img_dim(1))/2];
                 end;
                 
                 if value(coordinates)
                     
                     %rotating mm coordinates
                 APrads= (value(AP_angle)*pi)/180;
                         
                 [t1 r1]=cart2pol(value(position_1(1)), value(position_1(2)));
                 [Tposition_1(1) Tposition_1(2)]=pol2cart(t1 + APrads,r1);
                 Tposition_1 = round( Tposition_1 * 10000)/10000;
                 
                 [t2 r2]=cart2pol(value(position_2(1)), value(position_2(2)));
                 [Tposition_2(1) Tposition_2(2)]=pol2cart(t2 + APrads,r2);
                 Tposition_2 = round( Tposition_2 * 10000)/10000;
                 
                 [t3 r3]=cart2pol(value(position_3(1)), value(position_3(2)));
                 [Tposition_3(1) Tposition_3(2)]=pol2cart(t3 + APrads,r3);
                 Tposition_3 = round( Tposition_3 * 10000)/10000;
                 
                 [t4 r4]=cart2pol(value(position_4(1)), value(position_4(2)));
                 [Tposition_4(1) Tposition_4(2)]=pol2cart(t4 + APrads,r4);
                 Tposition_4 = round( Tposition_4 * 10000)/10000;
                 %             
                 pixel_pos1(1)=value(centre(1)) + Tposition_1(1)/value(mm_pxl_scale);
                 pixel_pos1(2)=value(centre(2)) - Tposition_1(2)/value(mm_pxl_scale);
                               
                 pixel_pos2(1)=value(centre(1)) + Tposition_2(1)/value(mm_pxl_scale);
                 pixel_pos2(2)=value(centre(2)) - Tposition_2(2)/value(mm_pxl_scale);
                  
                 pixel_pos3(1)=value(centre(1)) + Tposition_3(1)/value(mm_pxl_scale);
                 pixel_pos3(2)=value(centre(2)) - Tposition_3(2)/value(mm_pxl_scale);
                    
                 pixel_pos4(1)=value(centre(1)) + Tposition_4(1)/value(mm_pxl_scale);
                 pixel_pos4(2)=value(centre(2)) - Tposition_4(2)/value(mm_pxl_scale);                 
                     %
                                       
%      old                pixel_pos1(1)=value(centre(1)) + value(position_1(1))/value(mm_pxl_scale);
%                      pixel_pos1(2)=value(centre(2)) - value(position_1(2))/value(mm_pxl_scale);
%                      
%                      pixel_pos2(1)=value(centre(1)) + value(position_2(1))/value(mm_pxl_scale);
%                      pixel_pos2(2)=value(centre(2)) - value(position_2(2))/value(mm_pxl_scale);
%                      
%                      pixel_pos3(1)=value(centre(1)) + value(position_3(1))/value(mm_pxl_scale);
%                      pixel_pos3(2)=value(centre(2)) - value(position_3(2))/value(mm_pxl_scale);
%                      
%                      pixel_pos4(1)=value(centre(1)) + value(position_4(1))/value(mm_pxl_scale);
%                      pixel_pos4(2)=value(centre(2)) - value(position_4(2))/value(mm_pxl_scale);
                     
                     x=[pixel_pos1(1); pixel_pos2(1); pixel_pos3(1); pixel_pos4(1)];
                     y=[pixel_pos1(2); pixel_pos2(2); pixel_pos3(2); pixel_pos4(2)];
                 else
                     if value(origin)
                         centreCart=Pix2Cart(value(img_dim), 1, value(centre));
                     else
                         centreCart=[0 0];
                     end;
                     
                     max_x=10; max_y = 10;
                     cartpos1=[( value(position_1(1))+max_x+centreCart(1) ) * ( value(img_dim(2))/(2*max_x) )...
                         ( -value(position_1(2))+max_y-centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )];
                     cartpos2=[( value(position_2(1))+max_x+centreCart(1)  ) * ( value(img_dim(2))/(2*max_x) )...
                         ( -value(position_2(2))+max_y -centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )];
                     cartpos3=[( value(position_3(1))+max_x+centreCart(1)  ) * ( value(img_dim(2))/(2*max_x) )...
                         ( -value(position_3(2))+max_y -centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )];
                     cartpos4=[( value(position_4(1))+max_x+centreCart(1)  ) * ( value(img_dim(2))/(2*max_x) )...
                         ( -value(position_4(2))+max_y -centreCart(2) ) * ( value(img_dim(1))/(2*max_y) )]; 
                     
                     x=[cartpos1(1); cartpos2(1); cartpos3(1); cartpos4(1)];
                     y=[cartpos1(2); cartpos2(2); cartpos3(2); cartpos4(2)];
                 end;
                     
             else % positions from image
                 x=value(img_pos(:,1));
                 y=value(img_pos(:,2));
             end;
         end;
         
         plot(x,y,'bo','MarkerSize',30,'LineWidth',2 )
         
         
         % ------------------------------------------------------------------
         %              LOAD_IMG
         % ------------------------------------------------------------------
         %Loads an image chosen from the computer.
    case 'load_img'
        
%         % Conditions to see how many points will be chosen.
%         if value(gridSweep)==1
%             n_pos.value=2;
%             img_grid.value=1;  %flag to use correct values to position
%         elseif value(gridSweep)==0
%             img_grid.value=0;
%         end;
        if value(img_grid)
            n_pos.value=2;
        end;

        
        %Only opens image to select points if one of the modes is selected
        if value(gridSweep)==1 || value(manual_img)==1
            
            intrinsicPath='C:\Users\User\Desktop\Intrinsic DATA';
            picturesPath='C:\Users\User\Desktop\Photo-Stim Pictures';
            cd(intrinsicPath)
            % Vessels Image
            [baseFileName1, folder1] = uigetfile('*.*', 'Specify Vessels image acquired during Intrinsic with Green LED');
            fullImageFileName1 = fullfile(folder1, baseFileName1);
            aux_fig1 = load(fullImageFileName1,'-mat');
            vessels = aux_fig1.hgS_070000.children.children(1,1).properties.CData;
            
%             % Intrinsic Azimuth Image
%             [baseFileName2, folder2] = uigetfile('*.*', 'Specify Azimuth/Elevation image created during Intrinsic Analysis');
%             fullImageFileName2 = fullfile(folder2, baseFileName2);
%             aux_fig2 = load(fullImageFileName2,'-mat');
%             intrinsic = aux_fig2.hgS_070000.children(1,1).children(1,1).properties.CData;
            
            cd(picturesPath)
            % Vessels image - picture taken right before photo-Stim
            [baseFileName3, folder3] = uigetfile('*.*', 'Specify loadImage file (picture of vessels taken before photo-stim');
            fullImageFileName3 = fullfile(folder3, baseFileName3);
            aux_fig3 = load(fullImageFileName3,'-mat');
            loadimage = aux_fig3.hgS_070000.children(2,1).children(1,1).properties.CData;
            
            
            %works as a double ginput that allows to see both pictures simultaneously
            [input_points loadimage_points]=cpselect(vessels*10, loadimage*10,'wait',true);
            
            % Storing pixel values in BControl
%             input_points.value= input_points;
%             loadimage_points.value= loadimage_points;
            
            %points for tm0065 - 13/06/14
%             input_points=[274.1250  169.1250; 209.6250    5.3750; 264.3750    9.1250];
%             loadimage_points=[595.0000  129.0000;  362.0000  616.0000;  252.0000  494.0000];
            
            %           Selecting type of transform by number of points clicked
            n_points=2;            
            
            if n_points==2
                transformType='nonreflective similarity';
            elseif n_points==3
                transformType='affine';
            elseif n_points==4
                transformType='projective';
            end;
            
            mytform = cp2tform(input_points, loadimage_points, transformType);
            
%             angleAzimuth= intrinsic;
            
            lambda = .1;
            elevationBorders = [-40 60];
            azimuthBorders = [-60 60];
            
            offset = [200,45];
            
            save_flag = 1;
            
            colormapRes = 128;
            
            cd(intrinsicPath)
            [mapsFile, mapsPath]=uigetfile('.mat','Select maps data file');
            
            load([mapsPath mapsFile],'*');
            
%             anglesMap = jet(colormapRes);
            anglesMap = hsv(colormapRes);
            vesselsMap = gray(size(anglesMap,1));
            cmap = [vesselsMap; anglesMap];
            
            %AZIMUTH VERSION
            angleAzimuth(angleAzimuth<azimuthBorders(1))=azimuthBorders(1);
            angleAzimuth(angleAzimuth>azimuthBorders(2))=azimuthBorders(2);
% Rescaling Azimuth image - reducing its values to [128 256]
            azimuthRescaled = size(anglesMap,1)*(double(angleAzimuth)-double(min(angleAzimuth(:))))/(double(max(angleAzimuth(:))-double(min(angleAzimuth(:)))))+size(vesselsMap,1);            

% ELEVATION VERSION
            angleElevation(angleElevation<elevationBorders(1))=elevationBorders(1);
            angleElevation(angleElevation>elevationBorders(2))=elevationBorders(2);  

            elevationRescaled = size(anglesMap,1)*(double(angleElevation)-double(min(angleElevation(:))))/(double(max(angleElevation(:))-double(min(angleElevation(:)))))+size(vesselsMap,1);
            %
            
            % Rescaling loadimage - reducing its values to [0 128]
            minLoad=double(min(loadimage(:)));
            maxLoad=double(max(loadimage(:)));
            loadimageRescaled=((double(loadimage)-minLoad)*127)/(maxLoad-minLoad);
            
            %AZIMUTH VERSION
            % Rescaling Azimuth Filter - reducing its values to [128 256]
            minFilt=double(min(amplitudeAzimuthFilt(:)));
            maxFilt=double(max(amplitudeAzimuthFilt(:)));
            amplitudeAzimuthFiltRescaled=((double(amplitudeAzimuthFilt)-minFilt)*128)/(maxFilt-minFilt);
        %ELEVATION VERSION            
            minFilt=double(min(amplitudeElevationFilt(:)));
            maxFilt=double(max(amplitudeElevationFilt(:)));
            amplitudeElevationFiltRescaled=((double(amplitudeElevationFilt)-minFilt)*128)/(maxFilt-minFilt);
            %


            % Applying image transformation to Intrisic image
            azimuthFinal = imtransform(azimuthRescaled, mytform,'XYScale',1,...
                'FillValues', 0,...
                'XData', [1 size(loadimage,2)],...
                'YData', [1 size(loadimage,1)]);
            
            elevationFinal = imtransform(elevationRescaled, mytform,'XYScale',1,...
                'FillValues', 0,...
                'XData', [1 size(loadimage,2)],...
                'YData', [1 size(loadimage,1)]);
            
            % Applying image transformation to Intrinsic amplitude modulator image
            amplitudeAzimuthFiltTrfm= imtransform(amplitudeAzimuthFiltRescaled, mytform,'XYScale',1,...
                'FillValues', 0,...
                'XData', [1 size(loadimage,2)],...
                'YData', [1 size(loadimage,1)]);
            
            % Applying image transformation to Intrinsic amplitude modulator image
            amplitudeElevationFiltTrfm= imtransform(amplitudeElevationFiltRescaled, mytform,'XYScale',1,...
                'FillValues', 0,...
                'XData', [1 size(loadimage,2)],...
                'YData', [1 size(loadimage,1)]);
            
            % Rescaling the Intrinsic amplitude modulator image back to [0 1] range
            minFiltTrfm=double(min(amplitudeAzimuthFiltTrfm(:)));
            maxFiltTrfm=double(max(amplitudeAzimuthFiltTrfm(:)));
            amplitudeAzimuthFiltFinal =((double(amplitudeAzimuthFiltTrfm)-minFiltTrfm)*1)/(maxFiltTrfm-minFiltTrfm);
            
            minFiltTrfm=double(min(amplitudeElevationFiltTrfm(:)));
            maxFiltTrfm=double(max(amplitudeElevationFiltTrfm(:)));
            amplitudeElevationFiltFinal =((double(amplitudeElevationFiltTrfm)-minFiltTrfm)*1)/(maxFiltTrfm-minFiltTrfm);
            
            
            G= real2rgb(loadimageRescaled,gray);
            J= real2rgb(azimuthFinal,hsv);
            A= real2rgb((1-exp(-amplitudeAzimuthFiltFinal*lambda))/(1-exp(-lambda)),gray);
            AzimuthOverlayed = J .* A + G .* (1-A);
            figure(29)
            image(AzimuthOverlayed);
            

            J= real2rgb(elevationFinal,hsv);
            A= real2rgb((1-exp(-amplitudeElevationFiltFinal*lambda))/(1-exp(-lambda)),gray);
            ElevationOverlayed = J .* A + G .* (1-A);
            figure(30)
            image(ElevationOverlayed);
            
            
            figure(31)
            colormap(cmap)
            image(elevationFinal)
    
            figure(32)
            colormap(cmap)
            image(azimuthFinal)
            %          truesize();
            img_pos.value=ginput(value(n_pos));

            img_dim.value=size(AzimuthOverlayed);  
            cd(picturesPath)
        end;
 
  % ------------------------------------------------------------------
  %              GET_ORIGIN
  % ------------------------------------------------------------------ 
  case 'get_origin'
      
      %Only opens image to select bregma position if correct mode is ON
        picturesPath='C:\Users\User\Desktop\Photo-Stim Pictures';
        cd(picturesPath)
         % Possibility to write the file path or search in explorer.
          if ischar(value(img_path)) && ~isempty(value(img_path))
              fullImageFileName=value(img_path);
          elseif isempty(value(img_path)) || ~ischar(value(img_path))
              % Browse for the image file.
              [baseFileName, folder] = uigetfile('*.*', 'Specify an image file');
           % Create the full file name.
              fullImageFileName = fullfile(folder, baseFileName);           
          end; 
         aux_fig = load(fullImageFileName,'-mat');
         %fig_data = aux_fig.hgS_070000.children(2,1).children.properties.CData;
         fig_data = aux_fig.hgS_070000.children(2,1).children(1,1).properties.CData;
         
         figure; 
         colormap gray;
         imagesc(fig_data);
        % truesize();
         if value(origin) 
         bregma_pos.value=ginput(1); 
         end;
         close;
         img_dim.value=size(fig_data);
       
  % ------------------------------------------------------------------
  %              GET_AnteriorPosterior_Axis
  % ------------------------------------------------------------------ 
    case 'get_APaxis'
      
        % Possibility to write the file path or search in explorer.
        if ischar(value(img_path)) && ~isempty(value(img_path))
            fullImageFileName=value(img_path);
        elseif isempty(value(img_path)) || ~ischar(value(img_path))
            % Browse for the image file.
            [baseFileName, folder] = uigetfile('*.*', 'Choose the Vessels image taken for the Photo-Stim Session.');
            % Create the full file name.
            fullImageFileName = fullfile(folder, baseFileName);
        end;
        aux_fig = load(fullImageFileName,'-mat');
        fig_data = aux_fig.hgS_070000.children(2,1).children(1,1).properties.CData;
        
        img_dim.value=size(fig_data);
        figure;
        colormap gray;
        imagesc(fig_data);
        
        %teach the user that should click anterior before, and posterior after
        [Atemp Ptemp]=ginput(2);
        close;
        
        ap=Pix2Cart(value(img_dim), 2, [Atemp Ptemp]);
        A=ap(1,:);
        P=ap(2,:);
        APaxis = P-A;
        [APaxis_polar(1) APaxis_polar(2)] = cart2pol(APaxis(1),APaxis(2));
        APaxis_polar(1)=APaxis_polar(1)*180/pi;
        %this variable gives (angle made between the vector, and horizontal (positive X)
        AP_angle.value=APaxis_polar(1);     

      
  % ------------------------------------------------------------------
  %              SHOW_MAN_POS
  % ------------------------------------------------------------------    
  %Shows a figure with the coordinates chosen by the user.
  case 'show_man_pos' 
      
      imgDimension=value(img_dim);  %imgDimension = [rows columns dim]
      
      %Calib(imgDimension, n_pos, img_pos)
      [tru_pos]=Pix2Cart(imgDimension, value(n_pos), value(img_pos));
     
%       pixel_pos1(1)=centre(1) + value(img_pos(1))/value(mm_pxl_scale);
%       pixel_pos1(2)=centre(2) - value(img_pos(2))/value(mm_pxl_scale);
      
      myfig=figure;
      x=5;
      y=5;
 
      str_pos = cell(value(n_pos), 1);
      
      for j=1:value(n_pos)
         str_pos{j} = strcat('pos', num2str(j)); 
         DispParam(obj, str_pos{j} , tru_pos(j,1:2) , x , y); next_row(y); 
      end;
      set(myfig, 'Position', [650 100 150 y]); 
      
       
  % ------------------------------------------------------------------
  %              SHOW_GRID_POS
  % ------------------------------------------------------------------  
  %Shows a figure with the Grid coordinates chosen by the user.
  case 'show_grid_pos' 
      
      imgDimension=value(img_dim);  %imgDimension = [rows columns dim]
      
      if value(img_grid)     
          if value(coordinates)     %Conversion from Cartesian to millimitre if mode is selected   
%               pixel1=value(img_pos(:,1));
%               pixel2=value(img_pos(:,2));

% POSITIONS MUST BE ROTATED BEFORE changin center! like in check calib!
%  gPos(:,1)=value(centre(1)) + gPos(:,1)/value(mm_pxl_scale);
%                  gPos(:,2)=value(centre(2)) - gPos(:,2)/value(mm_pxl_scale); 
%                  
 %change from pixel to mm (using center of imgDim)

              % from pixel to mm with cneter of image as origin
              tru_pos(1,1)= (value(img_pos(1,1))-value(img_dim(2))/2)*value(mm_pxl_scale);
              tru_pos(1,2)= (value(img_dim(1))/2-value(img_pos(1,2)))*value(mm_pxl_scale);
              tru_pos(2,1)= (value(img_pos(2,1))-value(img_dim(2))/2)*value(mm_pxl_scale);
              tru_pos(2,2)= (value(img_dim(1))/2-value(img_pos(2,2)))*value(mm_pxl_scale);
              
              
%               tru_pos
          else % user wants cartesian
              [tru_pos]=Pix2Cart(imgDimension, value(n_pos), value(img_pos));
          end;       
          
      else
          [tru_pos]= [value(grid_topright); value(grid_botleft)];
      end;
      

      
      % Creation of the grid points.
      gPos=GridCreation(tru_pos, value(grid_res),value(eliminate),...
          value(AP_angle),value(origin),value(coordinates));
      
     % add correct centre in mm in the necesary case DO THIS
     if value(img_grid)     
          if value(coordinates)  
               gPos(:,1) = gPos(:,1) + (value(bregma_pos(1))-(value(img_dim(2))/2))*value(mm_pxl_scale);
               gPos(:,2) = gPos(:,2) + ((value(img_dim(1))/2)-value(bregma_pos(2)))*value(mm_pxl_scale);
          end
     end
%      gPos

      
%       n=value(grid_res(1))*value(grid_res(2));    
      n=size(gPos,1);      

      myfig=figure;
       
      str_pos = cell(n, 1);
      x=5;
      y=5;
      
      % Cycle that creates the display of the position coordinate pairs. It
      % adds more displays according to the number of positions chosen.
      for m=1:n
         str_pos{m} = strcat('pos', num2str(m)); 
         DispParam(obj, str_pos{m} , gPos(m,1:2) , x , y); next_row(y); 
      end;   
      set(myfig, 'Position', [650 70 150 y]);
  
  
  % ------------------------------------------------------------------
  %              SHOW HIDE
  % ------------------------------------------------------------------    
  case 'hide',
    LaserControlShow.value = 0; set(value(myfig), 'Visible', 'off');

  case 'show',
    LaserControlShow.value = 1; set(value(myfig), 'Visible', 'on');

  case 'show_hide',
    if LaserControlShow == 1, set(value(myfig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else                   set(value(myfig), 'Visible', 'off');
    end;
    
  case 'show_hideTime',
    if value(multi_time) == 1, set(value(time_fig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else                        set(value(time_fig), 'Visible', 'off');
    end;     
 
  case 'show_hideGrid',
    if value(open_grid) == 1, set(value(grid_fig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else                        set(value(grid_fig), 'Visible', 'off');
    end;  
    
  case 'show_hideManual',
    if value(open_manual) == 1, set(value(manual_fig), 'Visible', 'on'); %#ok<NODEF> (defined by GetSoloFunctionArgs)
    else                        set(value(manual_fig), 'Visible', 'off');
    end;     
            
  % ------------------------------------------------------------------
  %              CLOSE
  % ------------------------------------------------------------------    
  case 'close'    
      
    %SetGUI(obj, 'close');  
%       if exist('myfig', 'var') && isa(myfig, 'SoloParamHandle') && ishandle(value(myfig)),
%       delete(value(myfig));
%       end;    
%       delete_sphandle('owner', ['^@' class(obj) '$'], 'fullname', ['^' mfilename '_']);

    delete(value(myfig));
    delete(value(time_fig));
    delete(value(grid_fig)); 
    delete(value(manual_fig)); 
      
  case 'closeTime'
    multi_time.value=0;
    set(value(time_fig), 'Visible', 'off');
  case 'closeGrid'
    open_grid.value=0;
    set(value(grid_fig), 'Visible', 'off');
  case 'closeManual'
    open_manual.value=0;
    set(value(manual_fig), 'Visible', 'off');
      
      
  % ------------------------------------------------------------------
  %              REINIT
  % ------------------------------------------------------------------    
  case 'reinit',
    %  SetGUI(obj, 'reinit'); 
 
x = my_xyfig(1); y = my_xyfig(2); origfig = my_xyfig(3); 
        currfig = gcf;

        feval(mfilename, obj, 'close');

        figure(origfig);
        feval(mfilename, obj, 'init', x, y);
        figure(currfig);
     
  otherwise
    warning('LaserControlSection:Invalid', 'Don''t know action %s\n', action);  
end;
% ------------------------------------------------------------------


function [tru_pos] = Pix2Cart(imgDimension, n_pos, img_pos)
% calib(image dimensions, vector of 2 or3; number of positions intended; the
%values of the positions)

  tru_pos=zeros(4, 2);
  max_x=10;
  max_y=10;

%conversion from pixel positions to the voltage values 
  for i=1:n_pos
     tru_pos(i, 1)=-max_x + ((2*max_x)/imgDimension(2))*img_pos(i,1);
     tru_pos(i, 2)=+max_y - ((2*max_y)/imgDimension(1))*img_pos(i,2);
  end;



function [g_Positions] = GridCreation(tru_pos, grid_res,eliminate,AP_angle,originBregma,realCoords)
    
    % Creation of the grid points.
      gTopR=tru_pos(1,1:2);
      gBotL=tru_pos(2,1:2);
      gRes=grid_res;  
%       g_Pos.value=zeros(gRes(1)*gRes(2),2);
      gPos=zeros(gRes(1)*gRes(2),2);  %non global parameter created
      
      stepX=(gTopR(1)-gBotL(1))/(gRes(1)-1);  %Steps given from one grid   
      stepY=(gTopR(2)-gBotL(2))/(gRes(2)-1);  % point to another.
      k=1;
      
      % Cycle to create the grid, each step given it calculates a new
      %coordinate. It starts from the top right corner, descending in that
      %column. Afterwords it goes back to first line, adjacent column to
      %the left.
      for l=1:gRes(1)
          for j=1:gRes(2)
             gPos(k,1:2)=[(gTopR(1)-(l-1)*stepX) (gTopR(2)-(j-1)*stepY)];
             k=k+1;
          end;
      end;
      
      %Eliminating specific positions of the grid
      k=1;
      l=1;
      for i=(size(eliminate,2)+1):size(gPos,1)
      eliminate(1,i) = 0;
      end
     
      if eliminate(1)==0
          g_Pos.value=gPos;
          g_Positions=gPos;
      else
          for i=1:size(gPos,1) 
              if eliminate(k)==i
                  k=k+1;
              else 
                  g_Positions(l,1:2) = gPos(i,1:2);
                  l=l+1;
              end;              
          end;
          g_Pos.value=g_Positions;
      end;
      
      if originBregma && realCoords
      % Rotating by AP_angle degrees to be able to use mm from bregma
      APrads= ((AP_angle)*pi)/180;
      
      [t1 r1]=cart2pol(g_Positions(:,1), g_Positions(:,2));
      [g_Positions(:,1) g_Positions(:,2)]=pol2cart(t1 + APrads,r1);
      
      g_Positions = round( g_Positions * 10000)/10000;
      end;
 
      %% Function downloaded from MatlabCentral(2April2014) - by Oliver Woodford 
      % This requires the folder "Private" and the custom Colormaps to
      % work.
      function [B lims map] = real2rgb(A, cmap, lims)
%REAL2RGB  Converts a real-valued matrix into a truecolor image
%
% Examples:
%   B = real2rgb(A, cmap);
%   B = real2rgb(A, cmap, lims);
%   [B lims map] = real2rgb(...);
%
% This function converts a real-valued matrix into a truecolor image (i.e.
% double array with values between 0 and 1) using the colormap specified
% (either user-defined or the name of a colormap function). The output
% image is suitable for display using IMAGE or IMSHOW, exporting using
% IMWRITE, texture mapping a surface etc.
%
% Colormaps specified by name, e.g. 'hot', can be reversed ('-hot'), made
% to convert linearly to grayscale when printed on a black & white printer
% ('hot*'), or both ('-hot*').
%
% Value limits and a colormap table can be output, for use generating the
% correct colorbar, e.g.:
%   [B lims map] = real2rgb(peaks(256), '-hot*');
%   hIm = imshow(B);
%   set(gcf, 'Colormap', map);
%   set(gca, 'CLim', lims);
%   set(hIm, 'CDataMapping', 'scaled');
%   colorbar;
%
% IN:
%   A - MxN real matrix.
%   cmap - JxK user-defined colormap, or a string indicating the name
%          of the colormap to be used. K = 3 or 4. If K == 4 then
%          cmap(1:end-1,4) contains the relative widths of the bins between
%          colors. If cmap is a colormap function name then the prefix '-'
%          indicates that the colormap is to be reversed, while the suffix
%          '*' indicates that the colormap bins are to be rescaled so that
%          each bin produces the same change in gray level, such that the
%          colormap converts linearly to grayscale when printed in black
%          and white.
%   lims - 1x2 array of saturation limits to be used on A. Default:
%          [min(A(:)) max(A(:))].
%
% OUT:
%   B - MxNx3 truecolor image.
%   lims - 1x2 array of saturation limits used on A. Same as input lims, if
%          given.
%   map - 256x3 colormap similar to that used to generate B.

% Copyright: Oliver Woodford, 2009-2010

% Thank you to Peter Nave for reporting a bug whereby colormaps larger than
% 256 entries long are returned.

% Don't do much if A is wrong size
[y x c] = size(A);
if c > 1
    error('A can only have 2 dimensions');
end
if y*x*c == 0
    % Create an empty array with the correct dimensions
    B = zeros(y, x, (c~=0)*3);
    return
end

% Generate the colormap
if ischar(cmap)
    % If map starts with a '-' sign, invert the colormap
    reverseMap = cmap(1) == '-';
    % If the map ends with a '*', attempt to make map convert linearly to
    % grayscale
    grayMap = cmap(end) == '*';
    % Extract the map name
    cmap = lower(cmap(reverseMap+1:end-grayMap));
    % Load the map
    try
        % Check for a concise table first
        map = feval(cmap, Inf);
    catch
        map = [];
    end
    if invalid_map(map)
        try
            % Just load a large table
            map = feval(cmap, 256);
        catch
            error('Colormap ''%s'' not found', cmap);
        end
        if invalid_map(map)
            error('Invalid colormap');
        end
    end
    if reverseMap
        % Reverse the map
        map = map(end:-1:1,:);
        if size(map, 2) == 4
            % Shift up the bin lengths
            map(1:end-1,4) = map(2:end,4);
        end
    end
    if grayMap && size(map, 1) > 2
        % Ensure the map converts linearly to grayscale
        map(1:end-1,4) = abs(diff(map(:,1:3) * [0.299; 0.587; 0.114]));
    end
else
    % Table-based colormap given
    map = cmap;
end

% Only work with real doubles
B = reshape(double(real(A)), y*x, c);

% Compute limits and scaled values
maxInd = 1 + (size(map, 1) - 2) * (size(map, 2) ~= 4);
if nargin < 3
    lims = [];
end
[B lims] = rescale(B, lims, [0 maxInd]);

% Compute indices and offsets
if size(map, 2) == 4
    % Non-linear colormap
    bins = map(1:end-1,4);
    cbins = cumsum(bins);
    bins(bins==0) = 1;
    bins = cbins(end) ./ bins;
    cbins = [0; cbins(1:end-1) ./ cbins(end); 1+eps];
    [ind ind] = histc(B, cbins);
    B = (B - cbins(ind)) .* bins(ind);
    clear bins cbins
else
    % Linear colormap
    ind = min(floor(B), maxInd-1);
    B = B - ind;
    ind = ind + 1;
end

% Compute the output image
B = B(:,[1 1 1]);
B = map(ind,1:3) .* (1 - B) + map(ind+1,1:3) .* B;
B = min(max(B, 0), 1); % Rounding errors can make values slip outside bounds
B = reshape(B, y, x, 3);

if nargout > 2 && (size(map, 1) ~= 256 || size(map, 2) == 4)
    % Generate the colormap (for creating a colorbar with)
    map = reshape(real2rgb(0:255, map, [0 255]), 256, 3);
end
return

function notmap = invalid_map(map)
notmap = isempty(map) || ndims(map) ~= 2 || size(map, 1) < 1 || size(map, 2) < 3 || size(map, 2) > 4 || ~all(reshape(map(:,1:3) >= 0 & map(:,1:3) <= 1, [], 1));