close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")
addpath("../../matlab_control/ADXLLib")
load("SWHR_Commands_Full_Motion_V250_A1500_J10000.mat")
global ADXL_file_name;
% filename = sprintf("SWHR_Commands_Full_Motion_V600_A1500_J10000.mat");
ADXL_file_name = sprintf("SWHR_Commands_Full_Motion_V250_A1500_J10000_uncompensated");
%% Generate trajectories
traj_ext=x_cmd_uncompensated;
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
%[motor1_tg,motor2_tg,motor1_fb,motor2_fb] = IO.read_t_fb(length(traj_ext)+100);
%}
