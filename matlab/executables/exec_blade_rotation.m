close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")

%% Set parameters
accel=1500; %200 800 800
vel=400; %50 100 100
jerk = 4e3; %200 2000 10000
Ts = 1e-3;

%%%%%%%%%
%% 8 inch wafer, 580mm
%natural_freq = 2*pi*5.259018764902764;
%damp = 0.042740396946003;

%damp = 0.076861775580771;
%natural_freq = 2*pi*5.163634975921101;
%damp = 0.142808661186032;
%natural_freq = 2*pi*6.797761992952479;

%% no wafer, 600mm
%damp = log(0.113/0.057);
%natural_freq = 2*pi/0.157/sqrt(1-damp^2);
%%%%%%%%%

%% 8 inch wafer 220 mm
%damp = 0.097523159491968;
%natural_freq = 2*pi*8.104989498692813;

start_angle = 180;
end_angle = 600;
%% Generate trajectories
traj_rot=ScurveTBI(start_angle,end_angle,vel,accel,jerk,Ts);
%traj_rot=zvd_input_shaping(traj_rot,start_angle,natural_freq,damp,Ts);
traj_ext=ones(size(traj_rot))*220;




%% Initiazlize TwinCAT IO and execute
%{
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

while(IO.get_state()~=5)
    fprintf("Waiting for Robot stopping...\n")
    pause(1)
end
%}