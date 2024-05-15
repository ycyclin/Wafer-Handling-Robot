clear all
close all
clc


% traj_name = 'SWHR_Full_Motion_400_to_580_V200_A3000_J100000';
traj_name = 'SWHR_Full_Motion_220_to_580_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_300_to_500_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_220_to_400_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_580_to_220_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_400_to_220_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_500_to_300_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_580_to_400_V200_A3000_J100000';

trial_number = 1;

%%    
Ts = 1e-3;

info = regexp(traj_name, 'SWHR_Full_Motion_(\d+)_to_(\d+)_V(\d+)_A(\d+)_J(\d+)', 'tokens');
info = info{1};
Pos1 = info{1};
Pos2 = info{2};
Vlim = info{3};
Alim = info{4};
Jlim = info{5};

%% Scanner Data
StartRow = 'C72:C5071';
Scan_Uncompensated = readmatrix(['./',traj_name,'/',traj_name,'_uncompensated_trial',num2str(trial_number),'.csv'],'Range',StartRow);
Scan_TVFBS    = readmatrix(['./',traj_name,'/',traj_name,'_FBS_LTV_trial',num2str(trial_number),'.csv'],'Range',StartRow);
Scan_TIFBS220 = readmatrix(['./',traj_name,'/',traj_name,'_FBS_LTI220_trial',num2str(trial_number),'.csv'],'Range',StartRow);
Scan_TIFBS400 = readmatrix(['./',traj_name,'/',traj_name,'_FBS_LTI400_trial',num2str(trial_number),'.csv'],'Range',StartRow);
Scan_TIFBS580 = readmatrix(['./',traj_name,'/',traj_name,'_FBS_LTI580_trial',num2str(trial_number),'.csv'],'Range',StartRow);

Scan_Uncompensated(Scan_Uncompensated<-100) = nan;
Scan_TVFBS(Scan_TVFBS<-100)       = nan;
Scan_TIFBS220(Scan_TIFBS220<-100) = nan;
Scan_TIFBS400(Scan_TIFBS400<-100) = nan;
Scan_TIFBS580(Scan_TIFBS580<-100) = nan;

ScanTime = (0:4999)*Ts;
StarsIndices(1) = find(~isnan(Scan_Uncompensated), 1);
StarsIndices(2) = find(~isnan(Scan_TVFBS), 1);
StarsIndices(3) = find(~isnan(Scan_TIFBS220), 1);
StarsIndices(4) = find(~isnan(Scan_TIFBS400), 1);
StarsIndices(5) = find(~isnan(Scan_TIFBS580), 1);
StartIdx = min(StarsIndices);

%% Accelerometer Data
AccData_Uncompensated = load(['./',traj_name,'/',traj_name,'_uncompensated_trial',num2str(trial_number),'.mat']);
AccData_TVFBS    = load(['./',traj_name,'/',traj_name,'_FBS_LTV_trial',num2str(trial_number),'.mat']);
AccData_TIFBS220 = load(['./',traj_name,'/',traj_name,'_FBS_LTI220_trial',num2str(trial_number),'.mat']);
AccData_TIFBS400 = load(['./',traj_name,'/',traj_name,'_FBS_LTI400_trial',num2str(trial_number),'.mat']);
AccData_TIFBS580 = load(['./',traj_name,'/',traj_name,'_FBS_LTI580_trial',num2str(trial_number),'.mat']);

fc = 50;
fs = 1000;
[b,a] = butter(4,fc/(fs/2));
Acc_Uncompensated = filtfilt(b,a,double(AccData_Uncompensated.ADXL_data.y));
Acc_TVFBS    = filtfilt(b,a,double(AccData_TVFBS.ADXL_data.y));
Acc_TIFBS220 = filtfilt(b,a,double(AccData_TIFBS220.ADXL_data.y));
Acc_TIFBS400 = filtfilt(b,a,double(AccData_TIFBS400.ADXL_data.y));
Acc_TIFBS580 = filtfilt(b,a,double(AccData_TIFBS580.ADXL_data.y));

%%
fig = figure(2);
set(gcf,'unit','normalized','position',[0.15,0.2,0.7,0.5])
lay = tiledlayout(1,2,'padding','compact','tilespacing','compact');

nexttile(1);
plot(ScanTime(StartIdx:end), Scan_Uncompensated(StartIdx:end),'--','linewidth',2); hold on;
plot(ScanTime(StartIdx:end), Scan_TVFBS(StartIdx:end),        '-','linewidth',2); 
plot(ScanTime(StartIdx:end), Scan_TIFBS220(StartIdx:end),     '--','linewidth',2); 
plot(ScanTime(StartIdx:end), Scan_TIFBS400(StartIdx:end),     '-.','linewidth',2); 
plot(ScanTime(StartIdx:end), Scan_TIFBS580(StartIdx:end),     '--','linewidth',2); 
hold off; grid on; grid minor; 
xlim(ScanTime([StartIdx,StartIdx+300]));
xlabel('Time [s]','fontsize',12);
title('Scanner Readings at the end of motion [mm]','fontsize',12); 
%%
nexttile(2);
plot((0:length(Acc_Uncompensated)-1)*Ts, Acc_Uncompensated,'--','linewidth',2); hold on;
plot((0:length(Acc_TVFBS)-1)*Ts,    Acc_TVFBS,        '-','linewidth',2); 
plot((0:length(Acc_TIFBS220)-1)*Ts, Acc_TIFBS220,     '--','linewidth',2); 
plot((0:length(Acc_TIFBS400)-1)*Ts, Acc_TIFBS400,     '-.','linewidth',2); 
plot((0:length(Acc_TIFBS580)-1)*Ts, Acc_TIFBS580,     '--','linewidth',2); 
hold off; grid on; grid minor; 
xlim([0, (length(Acc_TVFBS)-1000)*Ts]);xlabel('Time [s]','fontsize',12);
title('Accelerometer Readings (not yet calibrated) [-]','fontsize',12); 

lgd = legend('Uncompensated','FBS (LTV)','FBS (LTI@220)','FBS (LTI@400)','FBS (LTI@580)','fontsize',12);
lgd.Layout.Tile = 'north';
lgd.NumColumns = 5;

title_strings = ['Motion from ',num2str(Pos1,'%d'),' mm to ',num2str(Pos2,'%d'),' mm with V_{lim}=',num2str(Vlim,'%d'),' mm/s, A_{lim}=',num2str(Alim,'%d'),' mm/s^2, J_{lim}=',num2str(Jlim,'%d'),' mm/s^3']
title(lay, title_strings,'fontsize',14)







