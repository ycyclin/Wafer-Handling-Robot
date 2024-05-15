close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")

%% Set parameters
accel=200;
vel=180;
jerk = 200;
Ts = 1e-3;

start_angle = 0;
end_angle = 60;
%% Generate trajectories
traj_rot=ScurveTBI(start_angle,end_angle,vel,accel,jerk,Ts);
traj_ext=ones(size(traj_ext))*180;
%% Initiazlize TwinCAT IO and execute
IO = TrajInterface;
IO.activate()
IO.write_trajectory(traj_ext,traj_rot);
IO.start_operation()
while(IO.get_state()~=2)
    fprintf("Waiting for Robot Moving to Start Point...\n")
    pause(1)
end
fprintf("Follow the trajectory...\n")
IO.trigger();