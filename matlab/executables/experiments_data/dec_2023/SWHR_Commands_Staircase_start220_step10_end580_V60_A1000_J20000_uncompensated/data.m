clear;clc;close all;
LTV_FBS_data = xlsread('SWHR_Commands_Staircase_start220_step10_end580_V60_A1000_J20000_LTV.csv', 'C72:C5070');
LTI400 = xlsread('SWHR_Commands_Staircase_start220_step10_end580_V60_A1000_J20000_LTI400.csv','C72:C5070');
uncompensated = xlsread('SWHR_Commands_Staircase_start220_step10_end580_V60_A1000_J20000_uncompensated_220.csv','C72:C5070');
plot(LTV_FBS_data(1:600)-LTV_FBS_data(1))
hold on
plot(LTI400(1:600)-LTI400(1))
plot(uncompensated(1:600)-uncompensated(1))
hold off
legend("FBS","LTI400","uncompensate")