%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% three speed profiles are used: baseline, fast, ultra fast
% controllers: 
% 1. no controller
% 2. TVIS
% 3. VC1 (Vibration Compensation)
% 4. VC2
% 5. TVIS + VC1
% 6. TVIS + VC2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load parameters
clear;
close;
clc;

addpath("../frf_results");
addpath("../BaseLib");
addpath("../SWHR_control_functions/")
load H.mat
load Silicon_Wafer_Handling_Robot_Params_for_Experiments.mat

Ts = 1e-3;
start = 200;
stop = 580;

FRF = cell2mat(FRF);
FRF = reshape(FRF,[length(freq_range),2,2,length(wafer_center_dist)]);

%% baseline
v = 400;
a = 1500;
jerk = 4e3;

% no controller
traj_ext = ScurveTBI(start,stop,v,a,jerk,Ts);
traj_rot = zeros(size(traj_ext));

save("MSEC_trajectories\baseline_NoController","traj_ext","traj_rot");

% TVIS
traj_ext = generate_path_TVIS(start,stop,v,a,jerk,Exp_Parameters,SWHR_Parameters,Ts,B,K);
traj_rot = zeros(size(traj_ext));

save("MSEC_trajectories\baseline_TVIS","traj_ext","traj_rot");

% VC1
traj_ext = ScurveTBI(start,stop,v,a,jerk,Ts);
traj_rot = theta_vibration_compensation(traj_ext,FRF(:,2,1,end),freq_range,Ts); % we are using the frf of the final position in this case

save("MSEC_trajectories\baseline_VC1","traj_ext","traj_rot");

% VC2
traj_rot = -traj_rot;

save("MSEC_trajectories\baseline_VC2","traj_ext","traj_rot");

% TVIS + VC1
traj_ext = generate_path_TVIS(start,stop,v,a,jerk,Exp_Parameters,SWHR_Parameters,Ts,B,K);
traj_rot = theta_vibration_compensation(traj_ext,FRF(:,2,1,end),freq_range,Ts);

save("MSEC_trajectories\baseline_TVISVC1","traj_ext","traj_rot");

% TVIS + VC2
traj_rot = -traj_rot;

save("MSEC_trajectories\baseline_TVISVC2","traj_ext","traj_rot");

%% fast
v = 400;
a = 2000;
jerk = 2e4;

% no controller
traj_ext = ScurveTBI(start,stop,v,a,jerk,Ts);
traj_rot = zeros(size(traj_ext));

save("MSEC_trajectories\fast_NoController","traj_ext","traj_rot");

% TVIS
traj_ext = generate_path_TVIS(start,stop,v,a,jerk,Exp_Parameters,SWHR_Parameters,Ts,B,K);
traj_rot = zeros(size(traj_ext));

save("MSEC_trajectories\fast_TVIS","traj_ext","traj_rot");

% VC1
traj_ext = ScurveTBI(start,stop,v,a,jerk,Ts);
traj_rot = theta_vibration_compensation(traj_ext,FRF(:,2,1,end),freq_range,Ts); % we are using the frf of the final position in this case

save("MSEC_trajectories\fast_VC1","traj_ext","traj_rot");

% VC2
traj_rot = -traj_rot;

save("MSEC_trajectories\fast_VC2","traj_ext","traj_rot");

% TVIS + VC1
traj_ext = generate_path_TVIS(start,stop,v,a,jerk,Exp_Parameters,SWHR_Parameters,Ts,B,K);
traj_rot = theta_vibration_compensation(traj_ext,FRF(:,2,1,end),freq_range,Ts);

save("MSEC_trajectories\fast_TVISVC1","traj_ext","traj_rot");

% TVIS + VC2
traj_rot = -traj_rot;

save("MSEC_trajectories\fast_TVISVC2","traj_ext","traj_rot");

%% ultra fast
v = 400;
a = 3000;
jerk = 1e5;

% no controller
traj_ext = ScurveTBI(start,stop,v,a,jerk,Ts);
traj_rot = zeros(size(traj_ext));

save("MSEC_trajectories\ultra_NoController","traj_ext","traj_rot");

% TVIS
traj_ext = generate_path_TVIS(start,stop,v,a,jerk,Exp_Parameters,SWHR_Parameters,Ts,B,K);
traj_rot = zeros(size(traj_ext));

save("MSEC_trajectories\ultra_TVIS","traj_ext","traj_rot");

% VC1
traj_ext = ScurveTBI(start,stop,v,a,jerk,Ts);
traj_rot = theta_vibration_compensation(traj_ext,FRF(:,2,1,end),freq_range,Ts); % we are using the frf of the final position in this case

save("MSEC_trajectories\ultra_VC1","traj_ext","traj_rot");

% VC2
traj_rot = -traj_rot;

save("MSEC_trajectories\ultra_VC2","traj_ext","traj_rot");

% TVIS + VC1
traj_ext = generate_path_TVIS(start,stop,v,a,jerk,Exp_Parameters,SWHR_Parameters,Ts,B,K);
traj_rot = theta_vibration_compensation(traj_ext,FRF(:,2,1,end),freq_range,Ts);

save("MSEC_trajectories\ultra_TVISVC1","traj_ext","traj_rot");

% TVIS + VC2
traj_rot = -traj_rot;

save("MSEC_trajectories\ultra_TVISVC2","traj_ext","traj_rot");