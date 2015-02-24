OLF_IP = Settings('get', 'RIGS', 'olfactometer_server');
olf_ip_set = OLF_IP;
olf_bank_A_ID = Settings('get', 'RIGS', 'olfactometer_bank_A');
olf_bank_B_ID = Settings('get', 'RIGS', 'olfactometer_bank_B');
olf_bank_C_ID  = Settings('get', 'RIGS', 'olfactometer_bank_C');
olf_bank_D_ID  = Settings('get', 'RIGS', 'olfactometer_bank_D');
olf_carrier_ID = Settings('get', 'RIGS', 'olfactometer_carrier');

olf = SimpleOlfClient(value(OLF_IP),3336);
Write(olf, ['Bank' num2str(olf_bank_A_ID) '_Valves'], 1);