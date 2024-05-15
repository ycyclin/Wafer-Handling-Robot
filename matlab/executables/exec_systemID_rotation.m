%close all;clear;clc;
addpath("../twincat_interface")
addpath("../BaseLib")
addpath("../SystemIDLib")
addpath("../../matlab_control/ADXLLib")
%% Set parameters
bld = 220:20:580;
global finished;
for blade_distance = bld
finished = false;
% blade_distance = 220;
sin_amplitude = 150; %[deg/s^2] for theta axis
freq_range = 4:0.2:20;
set_time = 2; %s
Ts=1e-3;
%% File names
global ADXL_file_name;
filename = sprintf("systemID_data_rot\\sine_rot_bladedist=%.4f,freq_range=[%.4f,%.4f].mat",blade_distance,freq_range(1),freq_range(end));
ADXL_file_name = sprintf("systemID_data_rot\\ADXL_sine_rot_bladedist=%.4f,freq_range=[%.4f,%.4f]",blade_distance,freq_range(1),freq_range(end));

%% Generate trajectory
tic
[x_ref,idx] = generate_sine_sweep(sin_amplitude,freq_range,set_time,Ts);
toc

traj_rot = x_ref;
traj_ext = zeros(size(traj_rot))+blade_distance;


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
ADXL_read
IO.trigger();

while ~finished
    pause(1);
    fprintf("Waiting plot\n");
end
save(filename,"x_ref","traj_ext","traj_rot","idx");
end

exec_systemID_extension