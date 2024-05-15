clear all
close all
clc
 
%{
% traj_name = 'SWHR_Full_Motion_V250_A1500_J10000';
% traj_name = 'SWHR_Full_Motion_220_to_580_V250_A2000_J100000';
% traj_name = 'SWHR_Full_Motion_220_to_580_V250_A2000_J30000';
% traj_name = 'SWHR_Full_Motion_580_to_220_V250_A2000_J100000';
% traj_name = 'SWHR_Full_Motion_580_to_220_V250_A1000_J30000';
% traj_name = 'SWHR_Full_Motion_220_to_580_V250_A1000_J30000';
% traj_name = 'SWHR_Full_Motion_220_to_580_V250_A1500_J10000';
% traj_name = 'SWHR_Full_Motion_220_to_580_V100_A2000_J50000';
% traj_name = 'SWHR_Full_Motion_220_to_580_V100_A2500_J50000';
% traj_name = 'SWHR_Full_Motion_220_to_400_V100_A2000_J50000';
%}

%{
% traj_name = 'SWHR_Full_Motion_220_to_580_V200_A3000_J100000'; %selected
% traj_name = 'SWHR_Full_Motion_220_to_580_V200_A3000_J50000';
% traj_name = 'SWHR_Full_Motion_220_to_580_V150_A2500_J50000';
% traj_name = 'SWHR_Full_Motion_220_to_580_V200_A2000_J50000'; %selected
% traj_name = 'SWHR_Full_Motion_220_to_580_V100_A2000_J50000'; %selected
% traj_name = 'SWHR_Full_Motion_220_to_580_V100_A1500_J50000'; %incomplete
% traj_name = 'SWHR_Full_Motion_220_to_580_V100_A1500_J30000'; %incomplete
 
% traj_name = 'SWHR_Full_Motion_220_to_400_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_220_to_400_V200_A2000_J50000';
% traj_name = 'SWHR_Full_Motion_220_to_400_V100_A2000_J50000';

% traj_name = 'SWHR_Full_Motion_400_to_580_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_400_to_580_V200_A2000_J50000';
% traj_name = 'SWHR_Full_Motion_400_to_580_V100_A2000_J50000';

% traj_name = 'SWHR_Full_Motion_580_to_400_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_580_to_400_V200_A2000_J50000';
% traj_name = 'SWHR_Full_Motion_580_to_400_V100_A2000_J50000';

% traj_name = 'SWHR_Full_Motion_580_to_220_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_580_to_220_V200_A2000_J50000';
% traj_name = 'SWHR_Full_Motion_580_to_220_V100_A2000_J50000';

% traj_name = 'SWHR_Full_Motion_400_to_220_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_400_to_220_V200_A2000_J50000';
% traj_name = 'SWHR_Full_Motion_400_to_220_V100_A2000_J50000';

% traj_name = 'SWHR_Full_Motion_500_to_300_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_500_to_300_V200_A2000_J50000';
% traj_name = 'SWHR_Full_Motion_500_to_300_V100_A2000_J50000';

% traj_name = 'SWHR_Full_Motion_300_to_500_V200_A3000_J100000';
% traj_name = 'SWHR_Full_Motion_300_to_500_V200_A2000_J50000';
% traj_name = 'SWHR_Full_Motion_300_to_500_V100_A2000_J50000';
%}

traj_name = 'SWHR_Full_Motion_400_to_580_V200_A3000_J100000';

trial_number = 1;

%%
StartRow = 72;
Scan_Uncompensated = readmatrix(['./',traj_name,'/',traj_name,'_uncompensated_trial',num2str(trial_number),'.csv'],'Range',StartRow);
Scan_TVFBS    = readmatrix(['./',traj_name,'/',traj_name,'_FBS_LTV_trial',num2str(trial_number),'.csv'],'Range',StartRow);
Scan_TIFBS220 = readmatrix(['./',traj_name,'/',traj_name,'_FBS_LTI220_trial',num2str(trial_number),'.csv'],'Range',StartRow);
Scan_TIFBS400 = readmatrix(['./',traj_name,'/',traj_name,'_FBS_LTI400_trial',num2str(trial_number),'.csv'],'Range',StartRow);
Scan_TIFBS580 = readmatrix(['./',traj_name,'/',traj_name,'_FBS_LTI580_trial',num2str(trial_number),'.csv'],'Range',StartRow);

figure;
plot(Scan_Uncompensated(:,3),'-','linewidth',2); hold on;
plot(Scan_TVFBS(:,3),'-','linewidth',2); 
plot(Scan_TIFBS220(:,3),':','linewidth',1.5); 
plot(Scan_TIFBS400(:,3),':','linewidth',1.5); 
plot(Scan_TIFBS580(:,3),':','linewidth',1.5); 
legend('Uncompensated','FBS (LTV)','FBS (LTI@220)','FBS (LTI@400)','FBS (LTI@580)')
% ylim([8.8,9.5])
ylim([-11,-9])

%%
Acc_Uncompensated = load(['./',traj_name,'/',traj_name,'_uncompensated_trial',num2str(trial_number),'.mat']);
Acc_TVFBS    = load(['./',traj_name,'/',traj_name,'_FBS_LTV_trial',num2str(trial_number),'.mat']);
Acc_TIFBS220 = load(['./',traj_name,'/',traj_name,'_FBS_LTI220_trial',num2str(trial_number),'.mat']);
Acc_TIFBS400 = load(['./',traj_name,'/',traj_name,'_FBS_LTI400_trial',num2str(trial_number),'.mat']);
Acc_TIFBS580 = load(['./',traj_name,'/',traj_name,'_FBS_LTI580_trial',num2str(trial_number),'.mat']);

fc = 50;
fs = 1000;
[b,a] = butter(4,fc/(fs/2));
Acc_Uncompensated.ADXL_data.y = filtfilt(b,a,double(Acc_Uncompensated.ADXL_data.y));
Acc_TVFBS.ADXL_data.y    = filtfilt(b,a,double(Acc_TVFBS.ADXL_data.y));
Acc_TIFBS220.ADXL_data.y = filtfilt(b,a,double(Acc_TIFBS220.ADXL_data.y));
Acc_TIFBS400.ADXL_data.y = filtfilt(b,a,double(Acc_TIFBS400.ADXL_data.y));
Acc_TIFBS580.ADXL_data.y = filtfilt(b,a,double(Acc_TIFBS580.ADXL_data.y));

figure;
plot(Acc_Uncompensated.ADXL_data.y,'-','linewidth',2); hold on;
plot(Acc_TVFBS.ADXL_data.y,'-','linewidth',2); 
plot(Acc_TIFBS220.ADXL_data.y,':','linewidth',1.5); 
plot(Acc_TIFBS400.ADXL_data.y,':','linewidth',1.5); 
plot(Acc_TIFBS580.ADXL_data.y,':','linewidth',1.5); 
legend('Uncompensated','FBS (LTV)','FBS (LTI@220)','FBS (LTI@400)','FBS (LTI@580)')

figure;
subplot(321);
plot(Acc_Uncompensated.ADXL_data.y,'-','linewidth',2);
title('Uncompensated');
subplot(323);
plot(Acc_TVFBS.ADXL_data.y,'-','linewidth',2); 
title('FBS (LTV)');
subplot(322);
plot(Acc_TIFBS220.ADXL_data.y,'-','linewidth',2); 
title('FBS (LTI@220)');
subplot(324);
plot(Acc_TIFBS400.ADXL_data.y,'-','linewidth',2); 
title('FBS (LTI@400)');
subplot(326);
plot(Acc_TIFBS580.ADXL_data.y,'-','linewidth',2); 
title('FBS (LTI@580)');
linkaxes;










