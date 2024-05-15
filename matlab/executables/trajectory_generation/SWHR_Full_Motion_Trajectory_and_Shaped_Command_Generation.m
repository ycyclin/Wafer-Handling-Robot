clear all
close all
clc

addpath('./SWHR_data_and_functions')

%%%% Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Ts = 8e-3;          % Sampling time [s]
x_start = 220;        % Starting position [mm]
x_end = 580;  % Ending position [mm]
dwell = 2;        % Dwell time between each step [s]

% Define kinematic limits (choose one method from below)
% Method 1: limit from end effector
v_lim = 200;    % Velocity limit [mm/s]         default=600
a_lim = 3000;   % Acceleration limit [mm/s^2]   default=1500
j_lim = 10e4; % Jerk limit[mm/s^3]               default=1e4

% Set B-spline Parameters
m = 5;              % B-Spline Degree
CtrlPntFs = 20;    % Control poinr freq: number of control points per second [Hz]

traj_name = ['Full_Motion_',num2str(x_start),'_to_',num2str(x_end),'_V',num2str(v_lim),'_A',num2str(a_lim),'_J',num2str(j_lim),'_CP',num2str(CtrlPntFs)];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_step = abs(x_end - x_start);
x_dir = sign(x_end - x_start);

% initial position
t_ref = 0;
x_ref = x_start;

% add linear point to point motion
[t_linear, x_linear] = linear_motion(x_step, v_lim, a_lim, j_lim, Ts);

t_ref = [t_ref, t_ref(end) +          t_linear(2:end)];
x_ref = [x_ref, x_ref(end) +  x_dir * x_linear(2:end)];

% add dwell time
t_ref = [t_ref, t_ref(end) + (1:ceil(dwell/Ts))*Ts];
x_ref = [x_ref, x_ref(end) * ones(1,ceil(dwell/Ts))];


%%
v_ref = gradient(x_ref, Ts);
a_ref = gradient(v_ref, Ts);
j_ref = gradient(a_ref, Ts);

figure;
set(gcf,'unit','normalized','position',[0.3,0.1,0.4,0.7])
tiledlayout(4,1,'tilespacing','compact','padding','compact');
nexttile(1);
plot(t_ref, x_ref, '-', 'linewidth',2);
grid on; grid minor; ylabel('Position','fontsize',12);
nexttile(2);
plot(t_ref, v_ref, '-', 'linewidth',2); hold on;
plot(t_ref,  v_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', 'r');
plot(t_ref, -v_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', 'r');
grid on; grid minor; ylabel('Velocity','fontsize',12);
nexttile(3);
plot(t_ref, a_ref, '-', 'linewidth',2); hold on;
plot(t_ref,  a_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', 'r');
plot(t_ref, -a_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', 'r');
grid on; grid minor; ylabel('Acceleration','fontsize',12);
nexttile(4);
plot(t_ref, j_ref, '-', 'linewidth',2); hold on;
plot(t_ref,  j_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', 'r');
plot(t_ref, -j_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', 'r');
grid on; grid minor; ylabel('Jerk','fontsize',12);

%%
%% Load Parameters Obtained from Modeling
load('Silicon_Wafer_Handling_Robot_Params_for_Experiments_v2_new.mat','SWHR_Parameters','Exp_Parameters','K','B','K_individual','B_individual')

angle_220 = SWHR_inverse_kinematics_v2(220*1e-3, SWHR_Parameters);
M_220 = SWHR_Polar_Mass_Matrix_ExperimentalBaseInertia(angle_220, SWHR_Parameters, Exp_Parameters);
M_220 = squeeze(M_220(1,1,:))';
K_220 = K_individual((220:20:580)==220);
B_220 = B_individual((220:20:580)==220);

angle_400 = SWHR_inverse_kinematics_v2(400*1e-3, SWHR_Parameters);
M_400 = SWHR_Polar_Mass_Matrix_ExperimentalBaseInertia(angle_400, SWHR_Parameters, Exp_Parameters);
M_400 = squeeze(M_400(1,1,:))';
K_400 = K_individual((220:20:580)==400);
B_400 = B_individual((220:20:580)==400);

angle_580 = SWHR_inverse_kinematics_v2(580*1e-3, SWHR_Parameters);
M_580 = SWHR_Polar_Mass_Matrix_ExperimentalBaseInertia(angle_580, SWHR_Parameters, Exp_Parameters);
M_580 = squeeze(M_580(1,1,:))';
K_580 = K_individual((220:20:580)==580);
B_580 = B_individual((220:20:580)==580);

clearvars -except M_220 K_220 B_220 M_400 K_400 B_400 M_580 K_580 B_580...
    K B x_ref t_ref Ts SWHR_Parameters Exp_Parameters traj_name CtrlPntFs

%% Generate FBS Matrix, Extend Reference, and Compute Inertia
t_ref = reshape(t_ref(1:end), [], 1);
x_ref = reshape(x_ref(1:end), [], 1) * 1e-3;

N0 = Generate_B_Spline_Matrix(x_ref,5,CtrlPntFs); % FBS Matrix

x0_abs = x_ref(1);
t_ref = [t_ref; t_ref(end) + (1:(size(N0,1)-length(x_ref)))'*Ts];
x_ref = [x_ref; x_ref(end) * ones(size(N0,1)-length(x_ref),1)] - x0_abs;

angle_ref = SWHR_inverse_kinematics_v2(x_ref + x0_abs, SWHR_Parameters);
M_ref = SWHR_Polar_Mass_Matrix_ExperimentalBaseInertia(angle_ref, SWHR_Parameters, Exp_Parameters);
M_ref = squeeze(M_ref(1,1,:))';

%% Construct Lifted System Representation Matrix
%% FBS_LTV
tic
FBS = zeros(size(N0));
for kt = 1:length(x_ref)
    if rem(kt,100) == 0
        disp(['Generating TV-LSR using ISA method - Timestep ',num2str(kt),' / ',num2str(length(x_ref))])
    end
    
    angle = SWHR_inverse_kinematics_v2(x0_abs + x_ref(kt), SWHR_Parameters);
    M = SWHR_Polar_Mass_Matrix_ExperimentalBaseInertia(angle, SWHR_Parameters, Exp_Parameters);
    M = M(1,1,:);
    Gc_tf = tf([0, B, K],[M, B, K]);
    Gd_tf = c2d(Gc_tf,Ts,'matched');
    
    %  Y        b(2)*z^-1 + b(3)*z^-2      
    % --- = ------------------------------
    %  U     a(1) + a(2)*z^-1 + a(3)*z^-2
    Gd_b = Gd_tf.Numerator{:};
    Gd_a = Gd_tf.Denominator{:};
        
    if kt == 1
        FBS(kt,:) = 0;
    elseif kt == 2
        FBS(kt,:) = (Gd_b(2)*N0(kt-1,:) - Gd_a(2)*FBS(kt-1,:))/Gd_a(1);
    else
        FBS(kt,:) = (Gd_b(2)*N0(kt-1,:) + Gd_b(3)*N0(kt-2,:) - Gd_a(2)*FBS(kt-1,:) - Gd_a(3)*FBS(kt-2,:))/Gd_a(1);
    end
    
end
FBS_LTV = FBS;
t_Gen_FBS_LTV = toc;

%% FBS_LTI220
tic
Gc_tf = tf([0, B_220, K_220],[M_220, B_220, K_220]);
LSR = zeros(length(x_ref));
u_cmd = eye(length(x_ref));
t = (0:length(x_ref)-1)*Ts;
for kt = 1:length(x_ref)
    if rem(kt,100) == 0
        disp(['Generating TI-LSR (@200) - Timestep ',num2str(kt),' / ',num2str(length(x_ref))])
    end
    
    LSR(:,kt) = lsim(Gc_tf, u_cmd(:,kt), t);
end
LSR_LTI220 = LSR;
FBS_LTI220 = LSR_LTI220 * N0;
t_Gen_FBS_LTI220 = toc;

%% FBS_LTI400
tic
Gc_tf = tf([0, B_400, K_400],[M_400, B_400, K_400]);
LSR = zeros(length(x_ref));
u_cmd = eye(length(x_ref));
t = (0:length(x_ref)-1)*Ts;
for kt = 1:length(x_ref)
    if rem(kt,100) == 0
        disp(['Generating TI-LSR (@400) - Timestep ',num2str(kt),' / ',num2str(length(x_ref))])
    end
    
    LSR(:,kt) = lsim(Gc_tf, u_cmd(:,kt), t);
end
LSR_LTI400 = LSR;
FBS_LTI400 = LSR_LTI400 * N0;
t_Gen_FBS_LTI400 = toc;

%% FBS_LTI580
tic
Gc_tf = tf([0, B_580, K_580],[M_580, B_580, K_580]);
LSR = zeros(length(x_ref));
u_cmd = eye(length(x_ref));
t = (0:length(x_ref)-1)*Ts;
for kt = 1:length(x_ref)
    if rem(kt,100) == 0
        disp(['Generating TI-LSR (@580) - Timestep ',num2str(kt),' / ',num2str(length(x_ref))])
    end
    
    LSR(:,kt) = lsim(Gc_tf, u_cmd(:,kt), t);
end
LSR_LTI580 = LSR;
FBS_LTI580 = LSR_LTI580 * N0;
t_Gen_FBS_LTI580 = toc;

%% Generate Command Trajectories for Different Cases
x_cmd_uncompensated = x_ref;
x_cmd_FBS_LTV    = N0 * (FBS_LTV\x_ref);
x_cmd_FBS_LTI220 = N0 * (FBS_LTI220\x_ref);
x_cmd_FBS_LTI400 = N0 * (FBS_LTI400\x_ref);
x_cmd_FBS_LTI580 = N0 * (FBS_LTI580\x_ref);

x_ref               = (x_ref + x0_abs) * 1e3;
x_cmd_uncompensated = (x_cmd_uncompensated + x0_abs) * 1e3;
x_cmd_FBS_LTV       = (x_cmd_FBS_LTV + x0_abs) * 1e3;
x_cmd_FBS_LTI220    = (x_cmd_FBS_LTI220 + x0_abs) * 1e3;
x_cmd_FBS_LTI400    = (x_cmd_FBS_LTI400 + x0_abs) * 1e3;
x_cmd_FBS_LTI580    = (x_cmd_FBS_LTI580 + x0_abs) * 1e3;

%% Save
mkdir('./Trajectories')
save(['./Trajectories/SWHR_Commands_',traj_name,'.mat'],'t_ref','x_ref','Ts',...
    'x_cmd_FBS_LTV','x_cmd_FBS_LTI220','x_cmd_FBS_LTI400','x_cmd_FBS_LTI580','x_cmd_uncompensated');







