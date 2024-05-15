close all;clear;clc;
addpath("../BaseLib")
addpath("../frf_results")
addpath("../twincat_interface")

%% Set parameters
% extension
accel=1500; % 1600 2000 1500
vel=600; % 400 400 600
jerk=1e4; % 1e4 4e3 1e4
Ts = 1e-3;

start_distance = 180;
end_distance = 580;
start_angle = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% io1
%damp_io1 = [52.104758783925561 79.357813127429097];
%natural_freq_io1 = [0.123175208095943 -0.322136438953817]; %(rad/s)

% io2
%damp_io2 = [0.050479357478370 0.111857866200373];
%natural_freq_io2 = [35.743985735186449 52.229152669981367]; %(rad/s) 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Load G
load lin_frf.mat
lin = frf;
clear frf
ind = 1; % the index to the frf that is closest to the end distance
temp = abs(end_distance-lin{1,1}.dist);
for i = 1:length(lin)
    if abs(end_distance-lin{1,i}.dist) < temp
        ind = i;
    end
end

f = 4:0.2:20;
f = 2*pi*f;

sys = frd(lin{1,ind}.io2,f);
g_rt = tfest(sys,4);
[wn_lin_io2, zn_lin_io2] = damp(g_rt); % estimate natural frequency and damping from frf
index = floor((wn_lin_io2(1)/(2*pi)-4)/0.2+1);
g_rt = tf([2*wn_lin_io2(1)*zn_lin_io2(1)*interp1([f(index) f(index+1)],[abs(lin{1,ind}.io2(index)) abs(lin{1,ind}.io2(index+1))],wn_lin_io2(1)) 0],...
[1 2*zn_lin_io2(1)*wn_lin_io2(1) wn_lin_io2(1)^2]);

%% Generate trajectories with input shaping
traj_ext=ScurveTBI(start_distance,end_distance,vel,accel,jerk,Ts);
%traj_ext=zvd_input_shaping(traj_ext,start_distance,wn_lin_io1(1),zn_lin_io1(1),Ts);
traj_rot=zeros(1,length(traj_ext))*start_angle;
t = 1:1:length(traj_ext(1:end));
y = lsim(g_rt,traj_ext-start_distance,(t-1)*Ts);

%{
%% Plot
t = 1:1:length(traj_ext(2:end));
plot(t*Ts,(traj_ext(1,2:end)-traj_ext(1,1:end-1))/Ts,'k','LineWidth',3);
hold on

accel=2000;
vel=700;
jerk=2e4;
Ts = 1e-3;

start_distance = 180;
end_distance = 580;
traj_ext=ScurveTBI(start_distance,end_distance,vel,accel,jerk,Ts);
t = 1:1:length(traj_ext(2:end));
plot(t*Ts,(traj_ext(1,2:end)-traj_ext(1,1:end-1))/Ts,':k','LineWidth',3);

legend('Baseline', 'Fast')
xlabel('time [s]')
ylabel('v [mm/s]','rotation',0,'HorizontalAlignment','right')
%}

%{
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
%}