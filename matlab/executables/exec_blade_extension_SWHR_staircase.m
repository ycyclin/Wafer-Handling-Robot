close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")
addpath("../../matlab_control/ADXLLib")
load("SWHR_Commands_Staircase_Segments_start220_step10_end580_V60_A1000_J20000.mat")
global ADXL_file_name;
%%
for i = 1:size(x_cmd_uncompensated,1)
i
[status,cmdout] = system(sprintf("cd ..\\..\\UR5e_controller & python3 rtde_test.py %d",i))
ADXL_file_name = sprintf("Trial2_SWHR_Commands_Staircase_start220_step10_end580_V60_A1000_J20000//SWHR_Commands_Staircase_start220_step10_end580_V60_A1000_J20000_TVFBS_%d",210+10*i);
%% Generate trajectories
traj_ext=x_cmd_FBS_LTV(i,:);
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
end
