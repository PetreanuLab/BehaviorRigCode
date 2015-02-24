OLF_IP         = Settings('get', 'RIGS', 'olfactometer_server');
%       olf_ip_set     = OLF_IP;
olf = SimpleOlfClient(OLF_IP,3336);
Write(value(olf), 'BankFlow1_Actuator', 100);
Write(olf,'Bank1_Valves',1)