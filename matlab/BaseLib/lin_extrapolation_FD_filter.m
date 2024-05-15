function [amp1,timestep1,amp2,timestep2] = lin_extrapolation_FD_filter(Td,amplitude,Ts)
% ==========================Start=of=Documentation=========================
% Author    Yung-Chun Lin
% Last rev  Feb.24,2024 
% @brief   Generate amplitude for each timestep from provided parameters
% @input   Td           [second]     time delay in continuous time
% @input   amplitude    [unit]       amplitude in continuous time
% @input   Ts           [second]     sample time
% @return  amp1         [double]     amplitude for timestep 1
% @return  timestep1    [integer]    discrete timestep for amp 1
% @return  amp2         [double]     amplitude for timestep 2
% @return  timestep2    [integer]    discrete time step for amp 2
% ===========================End=of=Documentation==========================    
timestep1 = floor(Td/Ts);
timestep2 = timestep1 + 1;
D = Td/Ts - timestep1;
amp2 = D*amplitude;
amp1 = amplitude - amp2; % in other words (1-D)*amplitude
end