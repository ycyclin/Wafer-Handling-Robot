LTV_FBS_data = xlsread('SWHR_Commands_Full_Motion_V600_A1500_J10000_TV_FBS_trial1.csv', 'C72:C350');
x_ref_data = xlsread('SWHR_Commands_Full_Motion_V600_A1500_J10000_uncompensated_trial1.csv', 'C72:C350');
LTV_FBS_data = LTV_FBS_data(LTV_FBS_data~=-1000);
x_ref_data = x_ref_data(x_ref_data~=-1000);
plot(LTV_FBS_data)
hold on
plot(x_ref_data)
hold off
legend("FBS","uncompensate")

%%
clear;clc;close all;
load("SWHR_Commands_Full_Motion_V600_A1500_J10000_TV_FBS_trial1.mat")
ADXL_data.t = ADXL_data.t - ADXL_data.t(find(ADXL_data.e~=0,1));
plot(ADXL_data.t,ADXL_data.y)
hold on
load("SWHR_Commands_Full_Motion_V600_A1500_J10000_uncompensated_trial1.mat")
ADXL_data.t = ADXL_data.t - ADXL_data.t(find(ADXL_data.e~=0,1));
plot(ADXL_data.t,ADXL_data.y)
hold off
legend("FBS","uncompensated")