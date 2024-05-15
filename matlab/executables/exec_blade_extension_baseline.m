%close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")


%% Set parameters
accel=90; % 90      270
vel=126; % 126      126
jerk = 2e3; % 2e3   1e4
Ts = 1e-3;

start_distance = 180;
end_distance = 580;
angle = 0;
%% Generate trajectories
%motor_angles = inverse_kinematics([start_distance, end_distance]);
[angle1_start,angle2_start] = inverse_kinematics(start_distance,angle);
[angle1_end,angle2_end] = inverse_kinematics(end_distance,angle);
motor_traj1 = ScurveTBI(angle1_start, angle1_end, vel, accel, jerk, Ts);
motor_traj2 = ScurveTBI(angle2_start,angle2_end, vel, accel, jerk, Ts);
[traj_ext,traj_rot] = forward_kinematics(motor_traj1,motor_traj2);
%traj_ext = forward_kinematics(motor_traj);
%traj_rot=zeros(size(traj_ext));


%{
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
%}
%[motor1_tg,motor2_tg,motor1_fb,motor2_fb] = IO.read_t_fb(length(traj_ext)+100);
