close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")

%% Set parameters
accel=2500;
vel=400;
jerk = 2e4;
Ts = 1e-3;

start_distance = 580;
end_distance = 220;
%% Generate trajectories
% traj_ext=ScurveTBI(start_distance,end_distance,vel,accel,jerk,Ts);
traj_ext = load('SWHR_Commands_Full_Motion_220_to_580_V200_A3000_J100000.mat').x_cmd_FBS_LTV;
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
fprintf("Follow the trajectory...\n")
IO.trigger();
while(IO.get_state()~=5)
    fprintf("Waiting for Robot stopping...\n")
    pause(1)
end
%[motor1_tg,motor2_tg,motor1_fb,motor2_fb] = IO.read_t_fb(length(traj_ext)+100);
%}

