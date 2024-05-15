close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")

%% parameters for moving to start point
accel=1500;
vel=400;
jerk = 4e3;
Ts = 1e-3;

start_distance = 580;
end_distance = 200;

%% load trajectories
files = ls("MSEC_trajectories");
path = "MSEC_trajectories/";
files = string(files);
for j = 1:length(files)
    if ~contains(files(j,1),".mat")
        continue
    end

    load(path+files(j))

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

    % wait for the laser sensor for 10 sec before moving back to staring point
    pause(10);
    traj_ext = ScurveTBI(start_distance,end_distance,vel,accel,jerk,Ts);

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

    sec = 60;
    for i = 1:sec
        disp(files(j) + " completed");
        disp((sec-i) + " seconds remaining");
        pause(1)
    end
end