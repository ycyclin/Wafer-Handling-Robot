close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")
addpath("../SystemIDLib")
%% Set parameters
blade_distance = 580;
sin_amplitude = 1; %[m/s^2]
freq_range = 4:0.2:20;
set_time = 1.5; %s
Ts=1e-3;
%% File names
filename = sprintf("systemID_data_lin\\sine_lin_bladedist=%.4f,freq_range=[%.4f,%.4f]",blade_distance,freq_range(1),freq_range(end));
ADXL_filename = sprintf("systemID_data_lin\\ADXL_sine_lin_bladedist=%.4f,freq_range=[%.4f,%.4f]",blade_distance,freq_range(1),freq_range(end));
%% Generate trajectory
tic
[x_ref,idx] = generate_sine_sweep(sin_amplitude*1e3,freq_range,set_time,Ts);
toc

traj_ext = x_ref+blade_distance;
traj_rot = zeros(size(traj_ext));
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