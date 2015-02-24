function  [] =  StateMatrixSection(obj, action)

global center1led;

GetSoloFunctionArgs;


switch action
  case 'init',
    StateMatrixSection(obj, 'next_trial');
    
  case 'next_trial',   
      
      
   t=2000; %Duration in FSM steps (6000Hz)/3 to use in AOmatrix to convert seconds
         % presently I do not know the frequency of the Emulator, so this is random
    
   correction_theta=value(rotation)*(pi/180);  %conversion of angle to radians
   axisInversion=[1 -1]; % vector responsible for inverting axis
   axisSwitch1=[1 2]; %vectors responsible for switching axis - change 
   axisSwitch2=[2 1];              %channel to which each AO sign is sent
   
    %if 4 corners flash mode is on, different SW will be created.
   if value(corners_flash)
       StimPositions=zeros(4,2); 
       
       StimPositions(1,1:2)=value(xy_amplitudes); 
       StimPositions(2,1:2)=[-value(xy_amplitudes(1)) value(xy_amplitudes(2))]; 
       StimPositions(3,1:2)=[value(xy_amplitudes(1)) -value(xy_amplitudes(2))]; 
       StimPositions(4,1:2)=-value(xy_amplitudes);
       
       value1_1=( StimPositions(1,1) + value(voltage_bias(1)) ); 
       value2_1=( StimPositions(1,2) + value(voltage_bias(2)) );
       [theta rho] = cart2pol(value1_1,value2_1);
       new_theta = theta + correction_theta;
       [FinalValue1_1 FinalValue2_1] = pol2cart(new_theta,rho);  
       AOMatrix1_1=[ axisInversion(value(invert_1)+1)*(FinalValue1_1/10 * ones(1, t*( value(pulseDuration)+0.001) ));...
				zeros(1,t*(value(pulseDuration)+0.001))]; 
       AOMatrix2_1=[ axisInversion(value(invert_2)+1)*(FinalValue2_1/10 * ones(1, t*( value(pulseDuration)+0.001) ));...
				zeros(1,t*(value(pulseDuration)+0.001))]; 
            
       value1_2=( StimPositions(2,1) + value(voltage_bias(1)) ); 
       value2_2=( StimPositions(2,2) + value(voltage_bias(2)) );
       [theta rho] = cart2pol(value1_2,value2_2);
       new_theta = theta + correction_theta;
       [FinalValue1_2 FinalValue2_2] = pol2cart(new_theta,rho);
       AOMatrix1_2=[ axisInversion(value(invert_1)+1)*(FinalValue1_2/10 * ones(1, t*( value(pulseDuration)+0.001) ));...
				zeros(1,t*(value(pulseDuration)+0.001))]; 
       AOMatrix2_2=[ axisInversion(value(invert_2)+1)*(FinalValue2_2/10 * ones(1, t*( value(pulseDuration)+0.001) ));...
				zeros(1,t*(value(pulseDuration)+0.001))]; 
       
       value1_3=( StimPositions(3,1) + value(voltage_bias(1)) ); 
       value2_3=( StimPositions(3,2) + value(voltage_bias(2)) );
       [theta rho] = cart2pol(value1_3,value2_3);
       new_theta = theta + correction_theta;
       [FinalValue1_3 FinalValue2_3] = pol2cart(new_theta,rho);
       AOMatrix1_3=[ axisInversion(value(invert_1)+1)*(FinalValue1_3/10 * ones(1, t*( value(pulseDuration)+0.001) ));...
				zeros(1,t*(value(pulseDuration)+0.001))]; 
       AOMatrix2_3=[ axisInversion(value(invert_2)+1)*(FinalValue2_3/10 * ones(1, t*( value(pulseDuration)+0.001) ));...
				zeros(1,t*(value(pulseDuration)+0.001))];
       
       value1_4=( StimPositions(4,1) + value(voltage_bias(1)) );
       value2_4=( StimPositions(4,2) + value(voltage_bias(2)) );
       [theta rho] = cart2pol(value1_4,value2_4);
       new_theta = theta + correction_theta;
       [FinalValue1_4 FinalValue2_4] = pol2cart(new_theta,rho); 
       AOMatrix1_4=[ axisInversion(value(invert_1)+1)*(FinalValue1_4/10 * ones(1, t*( value(pulseDuration)+0.001) ));...
				zeros(1,t*(value(pulseDuration)+0.001))]; 
       AOMatrix2_4=[ axisInversion(value(invert_2)+1)*(FinalValue2_4/10 * ones(1, t*( value(pulseDuration)+0.001) ));...
				zeros(1,t*(value(pulseDuration)+0.001))];     
       
   else
       StimPosition = value(position);   %value that simulates user input
       %Values to be sent to each matrix.
       value1=( StimPosition(1) + value(voltage_bias(1)) ); 
       value2=( StimPosition(2) + value(voltage_bias(2)) );
  
       %Rotation correction.
       [theta rho] = cart2pol(value1,value2);
       [FinalValue1 FinalValue2] = pol2cart(theta + correction_theta,rho);
        
       AOMatrix1.value=[ axisInversion(value(invert_1)+1)*(FinalValue1/10 * ones(1, t*( value(pulseDuration)+0.001) ) );...
				zeros(1,t*(value(pulseDuration)+0.001))]; 
       AOMatrix2.value=[ axisInversion(value(invert_2)+1)*(FinalValue2/10 * ones(1, t*( value(pulseDuration)+0.001) ) );...
				zeros(1,t*(value(pulseDuration)+0.001))];          
   end;         
      
   
   
   sma = StateMachineAssembler('full_trial_structure');   
    
    %SW to shine the laser on the mouse: opens AOM (something like that)
   sma = add_scheduled_wave(sma,'name','inhibition_pulse',...
            'preamble', 0.001,'sustain',value(pulseDuration),...
            'DOut',center1led);

   if value(corners_flash)
           %Analog Scheduled Waves - rotate the mirrors!
       sma = add_scheduled_wave(sma, 'name', 'sw_chn1_1', 'is_ao', 1, 'AOut', axisSwitch1(value(switch_xy)+1),...
            'two_by_n_matrix', AOMatrix1_1);
       sma = add_scheduled_wave(sma, 'name', 'sw_chn2_1',  'is_ao', 1, 'AOut', axisSwitch2(value(switch_xy)+1),...
            'two_by_n_matrix', AOMatrix2_1);
        
            %Analog Scheduled Waves - rotate the mirrors!
       sma = add_scheduled_wave(sma, 'name', 'sw_chn1_2', 'is_ao', 1, 'AOut', axisSwitch1(value(switch_xy)+1),...
            'two_by_n_matrix', AOMatrix1_2);
       sma = add_scheduled_wave(sma, 'name', 'sw_chn2_2',  'is_ao', 1, 'AOut', axisSwitch2(value(switch_xy)+1),...
            'two_by_n_matrix', AOMatrix2_2);
        
            %Analog Scheduled Waves - rotate the mirrors!
       sma = add_scheduled_wave(sma, 'name', 'sw_chn1_3', 'is_ao', 1, 'AOut', axisSwitch1(value(switch_xy)+1),...
            'two_by_n_matrix', AOMatrix1_3);
       sma = add_scheduled_wave(sma, 'name', 'sw_chn2_3',  'is_ao', 1, 'AOut', axisSwitch2(value(switch_xy)+1),...
            'two_by_n_matrix', AOMatrix2_3);
        
            %Analog Scheduled Waves - rotate the mirrors!
       sma = add_scheduled_wave(sma, 'name', 'sw_chn1_4', 'is_ao', 1, 'AOut', axisSwitch1(value(switch_xy)+1),...
            'two_by_n_matrix', AOMatrix1_4);
       sma = add_scheduled_wave(sma, 'name', 'sw_chn2_4',  'is_ao', 1, 'AOut', axisSwitch2(value(switch_xy)+1),...
            'two_by_n_matrix', AOMatrix2_4);
   else
       %Analog Scheduled Waves - rotate the mirrors!
       sma = add_scheduled_wave(sma, 'name', 'sw_chn1', 'is_ao', 1,...
           'AOut', axisSwitch1(value(switch_xy)+1), 'two_by_n_matrix', value(AOMatrix1));
       sma = add_scheduled_wave(sma, 'name', 'sw_chn2',  'is_ao', 1,...
           'AOut', axisSwitch2(value(switch_xy)+1), 'two_by_n_matrix', value(AOMatrix2));
   end;
   
        
          %Machine States 
   sma = add_state(sma, 'name', 'begin', 'self_timer',0.001,...
            'input_to_statechange', {'Tup', 'final_state'});  

   if value(corners_flash)
       sma = add_state(sma ,'name', 'final_state','self_timer',value(pulseDuration),...
            'input_to_statechange', {'Tup', 'final_state2'},...
            'output_actions',{'SchedWaveTrig','inhibition_pulse+sw_chn1_1+sw_chn2_1'});
       sma = add_state(sma ,'name', 'final_state2','self_timer',value(pulseDuration),...
            'input_to_statechange', {'Tup', 'final_state3'},...
            'output_actions',{'SchedWaveTrig','inhibition_pulse+sw_chn1_2+sw_chn2_2'});
       sma = add_state(sma ,'name', 'final_state3','self_timer',value(pulseDuration),...
            'input_to_statechange', {'Tup', 'final_state4'},...
            'output_actions',{'SchedWaveTrig','inhibition_pulse+sw_chn1_3+sw_chn2_3'});
       sma = add_state(sma ,'name', 'final_state4','self_timer',value(pulseDuration),...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'},...
            'output_actions',{'SchedWaveTrig','inhibition_pulse+sw_chn1_4+sw_chn2_4'});
   else
       sma = add_state(sma ,'name', 'final_state','self_timer',value(pulseDuration)+1,...
            'input_to_statechange', {'Tup', 'check_next_trial_ready'},...
            'output_actions',{'SchedWaveTrig','inhibition_pulse+sw_chn1+sw_chn2'});
   end;
  
 
   dispatcher('send_assembler', sma,{'final_state','final_state4'});
    
    
  case 'reinit',

    % Delete all SoloParamHandles who belong to this object and whose
    % fullname starts with the name of this mfile:
    delete_sphandle('owner', ['^@' class(obj) '$'], ...
      'fullname', ['^' mfilename]);

    % Reinitialise at the original GUI position and figure:
    feval(mfilename, obj, 'init');
    
  otherwise,
    warning('%s : %s  don''t know action %s\n', class(obj), mfilename, action);
end;

   
      