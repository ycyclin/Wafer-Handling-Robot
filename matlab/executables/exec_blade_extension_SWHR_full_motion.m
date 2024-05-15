close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")
addpath("../../matlab_control/ADXLLib")
load("SWHR_Commands_Full_Motion_220_to_580_V250_A2000_J100000.mat")
global ADXL_file_name;
%%
[status,cmdout] = system(sprintf("cd ..\\..\\UR5e_controller & python3 rtde_test.py %d",1))
ADXL_file_name = sprintf("SWHR_Commands_Full_Motion_220_to_580_V250_A2000_J100000//SWHR_Commands_Full_Motion_220_to_580_V250_A2000_J100000_TVFBS_trial1");
%% Generate trajectories
traj_ext=x_cmd_uncompensated(:);
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

