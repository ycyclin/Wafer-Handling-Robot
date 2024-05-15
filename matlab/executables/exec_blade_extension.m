close all;clear;clc;
addpath("../BaseLib")
addpath("../twincat_interface")

%% Set parameters
accel=1500;
vel=400;
jerk = 4e3;
Ts = 1e-3;

start_distance = 580;
end_distance = 200;
%% Generate trajectories
traj_ext=ScurveTBI(start_distance,end_distance,vel,accel,jerk,Ts);
traj_rot=zeros(size(traj_ext));


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
%[motor1_tg,motor2_tg,motor1_fb,motor2_fb] = IO.read_t_fb(length(traj_ext)+100);

% comment this after you get the result
%{
figure(1)
%plot((1:1:size(motor1_tg,2))/1000,motor1_tg,'DisplayName','motor1_tg');
%hold on;
%plot((1:1:size(motor2_tg,2))/1000,motor2_tg,'DisplayName','motor2_tg');
plot((1:1:size(motor2_tg,2))/1000,motor1_tg(1,:)+motor2_tg(1,:),'DisplayName','sum');
xlabel('time [s]');
ylabel('position [step]');
title('tg')
legend('interpreter','none')

figure(2)
%plot((1:1:size(motor1_fb,2))/1000,motor1_fb,'DisplayName','motor1_fb');
%hold on;
%plot((1:1:size(motor2_fb,2))/1000,motor2_fb,'DisplayName','motor2_fb');
plot((1:1:size(motor2_fb,2))/1000,motor1_fb(1,:)+motor2_fb(1,:),'DisplayName','sum');
xlabel('time [s]');
ylabel('position [step]');
title('fb')
legend('interpreter','none')
%}
