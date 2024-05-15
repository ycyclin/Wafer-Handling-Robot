close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")

%% Set parameters
accel=90;
vel=126;
jerk = 2e3; 
Ts = 1e-3;

start_distance = 180;
end_distance = 600;
%% Generate trajectories
motor_angles = inverse_kinematics([start_distance, end_distance]);
motor_traj = ScurveTBI(motor_angles(1), motor_angles(2), vel, accel, jerk, Ts);
%traj_ext = forward_kinematics(motor_traj);
%%%%%%%%%%%%%%%
damp = log(0.113/0.057);
%damp = 1.8939;
%damp = 0.683;
natural_freq = 2*pi/0.157/sqrt(1-damp^2);
%traj_ext=zvd_input_shaping(traj_ext,start_distance,natural_freq,damp,Ts);
%%%%%%%%%%%%%%%%
% traj_ext=ScurveTBI(start_distance,end_distance,vel,accel,jerk,Ts);
%traj_rot=zeros(size(traj_ext));


traj_ext_baseline = forward_kinematics(motor_traj);
accel=1500;
vel=400;
jerk = 4e3;
traj_ext_moderate = ScurveTBI(start_distance,end_distance,vel,accel,jerk,Ts);
accel=2000;
vel=400;
jerk = 2e4;
traj_ext_fast = ScurveTBI(start_distance,end_distance,vel,accel,jerk,Ts);
figure(1)
t = 1:1:length(traj_ext_baseline(2:end));
plot(t*Ts,(traj_ext_baseline(1,2:end)-traj_ext_baseline(1,1:end-1))/Ts,':k','LineWidth',3);
hold on;
xlabel('time [s]')
y1 = ylabel('v [mm/s]','Rotation',0,'HorizontalAlignment','right','VerticalAlignment','middle');
t = 1:1:length(traj_ext_moderate(2:end));
plot(t*Ts,(traj_ext_moderate(1,2:end)-traj_ext_moderate(1,1:end-1))/Ts,'-k','LineWidth',3);
t = 1:1:length(traj_ext_fast(2:end));
plot(t*Ts,(traj_ext_fast(1,2:end)-traj_ext_fast(1,1:end-1))/Ts,'--k','LineWidth',3);
legend('baseline','moderate','fast')
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

[motor1_tg,motor2_tg,motor1_fb,motor2_fb] = IO.read_t_fb(length(traj_ext)+100);
%}