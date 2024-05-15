clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")
addpath("../../matlab_control/ADXLLib")

%{
% traj_name = 'Full_Motion_220_to_580_V250_A2000_J100000';
% traj_name = 'Full_Motion_580_to_220_V250_A2000_J100000';
% traj_name = 'Full_Motion_220_to_580_V250_A2000_J30000';
% traj_name = 'Full_Motion_580_to_220_V250_A2000_J30000';
% traj_name = 'Full_Motion_580_to_220_V250_A1000_J30000';
% traj_name = 'Full_Motion_220_to_580_V250_A1000_J30000';
% traj_name = 'Full_Motion_580_to_220_V250_A1500_J10000';
% traj_name = 'Full_Motion_220_to_580_V250_A1500_J10000';
% traj_name = 'Full_Motion_220_to_580_V100_A2000_J50000';
% traj_name = 'Full_Motion_220_to_580_V100_A2500_J50000';
% traj_name = 'Full_Motion_220_to_400_V100_A2000_J50000';
% traj_name = 'Full_Motion_400_to_220_V100_A2000_J50000';
%}

%{
% traj_name = 'Full_Motion_220_to_400_V200_A3000_J100000'; %selected
% traj_name = 'Full_Motion_220_to_400_V200_A2000_J50000'; %selected
% traj_name = 'Full_Motion_220_to_400_V100_A2000_J50000'; %selected
% traj_name = 'Full_Motion_220_to_400_V100_A1500_J50000';
% traj_name = 'Full_Motion_220_to_400_V100_A1500_J30000';

% traj_name = 'Full_Motion_220_to_580_V200_A3000_J100000'; %selected
% traj_name = 'Full_Motion_220_to_580_V200_A3000_J50000';
% traj_name = 'Full_Motion_220_to_580_V150_A2500_J50000';
% traj_name = 'Full_Motion_220_to_580_V200_A2000_J50000'; %selected
% traj_name = 'Full_Motion_220_to_580_V100_A2000_J50000'; %selected
% traj_name = 'Full_Motion_220_to_580_V100_A1500_J50000';
% traj_name = 'Full_Motion_220_to_580_V100_A1500_J30000';

% traj_name = 'Full_Motion_400_to_580_V200_A3000_J100000';
% traj_name = 'Full_Motion_400_to_580_V200_A2000_J50000';
% traj_name = 'Full_Motion_400_to_580_V100_A2000_J50000';

% traj_name = 'Full_Motion_580_to_400_V200_A3000_J100000';
% traj_name = 'Full_Motion_580_to_400_V200_A2000_J50000';
% traj_name = 'Full_Motion_580_to_400_V100_A2000_J50000';

% traj_name = 'Full_Motion_580_to_220_V200_A3000_J100000';
% traj_name = 'Full_Motion_580_to_220_V200_A2000_J50000';
% traj_name = 'Full_Motion_580_to_220_V100_A2000_J50000';

% traj_name = 'Full_Motion_400_to_220_V200_A3000_J100000';
% traj_name = 'Full_Motion_400_to_220_V200_A2000_J50000';
% traj_name = 'Full_Motion_400_to_220_V100_A2000_J50000';

% traj_name = 'Full_Motion_500_to_300_V200_A3000_J100000';
% traj_name = 'Full_Motion_500_to_300_V200_A2000_J50000';
% traj_name = 'Full_Motion_500_to_300_V100_A2000_J50000';

% traj_name = 'Full_Motion_300_to_500_V200_A3000_J100000';
% traj_name = 'Full_Motion_300_to_500_V200_A2000_J50000';
% traj_name = 'Full_Motion_300_to_500_V100_A2000_J50000';
%}


% traj_name = 'Full_Motion_400_to_580_V200_A3000_J100000';
traj_name = 'Full_Motion_220_to_580_V200_A3000_J100000_CP100';

% traj_name = 'Full_Motion_300_to_500_V200_A3000_J100000';

% traj_name = 'Full_Motion_220_to_400_V200_A3000_J100000';

% traj_name = 'Full_Motion_580_to_220_V200_A3000_J100000';
% traj_name = 'Full_Motion_400_to_220_V200_A3000_J100000';

% traj_name = 'Full_Motion_500_to_300_V200_A3000_J100000';

% traj_name = 'Full_Motion_580_to_400_V200_A3000_J100000';

load(['SWHR_Commands_',traj_name,'.mat'])
global ADXL_file_name;
%%
controller_selection = 2;
trial_number = 1;

if controller_selection == 1
    ctrl_prefix = 'uncompensated';
elseif controller_selection == 2
    ctrl_prefix = 'FBS_LTV';
elseif controller_selection == 3
    ctrl_prefix = 'FBS_LTI400';
elseif controller_selection == 4
    ctrl_prefix = 'FBS_LTI220';
elseif controller_selection == 5
    ctrl_prefix = 'FBS_LTI580';
end
ADXL_file_name_string = ['SWHR_',traj_name,'//SWHR_',traj_name,'_',ctrl_prefix,'_trial',num2str(trial_number)];
ADXL_file_name_string = string(ADXL_file_name_string);
mkdir( ['SWHR_',traj_name])

% [status,cmdout] = system(sprintf("cd ..\\..\\UR5e_controller & python3 rtde_test.py %d",1))
ADXL_file_name = sprintf(ADXL_file_name_string);
%% Generate trajectories
if controller_selection == 1
    traj_ext=x_cmd_uncompensated(:);
elseif controller_selection == 2
    traj_ext=x_cmd_FBS_LTV(:);
elseif controller_selection == 3
    traj_ext=x_cmd_FBS_LTI400(:);
elseif controller_selection == 4
    traj_ext=x_cmd_FBS_LTI220(:);
elseif controller_selection == 5
    traj_ext=x_cmd_FBS_LTI580(:);
end

traj_rot=zeros(size(traj_ext));
%% Initiazlize TwinCAT IO
IO = TrajInterface;
IO.activate();
IO.write_trajectory(traj_ext,traj_rot);
IO.start_operation()
while(IO.get_state()~=2)
    fprintf("Waiting for Robot Moving to Start Point...\n")
    pause(1)
 end
 %%
ADXL_read;
fprintf("Follow the trajectory...\n")
IO.trigger();
while(IO.get_state()~=5)
    fprintf("Waiting for Robot stopping...\n")
    pause(1)
end
pause(3)
%[motor1_tg,motor2_tg,motor1_fb,motor2_fb] = IO.read_t_fb(length(traj_ext)+100);
%}

