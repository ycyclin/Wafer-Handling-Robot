close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")

%% Set parameters
accel=1500;
vel=400;
jerk = 4e3;
Ts = 1e-3;

start_distance = 600;
end_distance = 180;
%% Generate trajectories
traj_ext=ScurveTBI(start_distance,end_distance,vel,accel,jerk,Ts);
traj_rot=zeros(size(traj_ext));

%% Initiazlize TwinCAT IO
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