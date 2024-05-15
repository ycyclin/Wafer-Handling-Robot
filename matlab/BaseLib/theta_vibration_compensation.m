function path = theta_vibration_compensation(traj_ext,frf,freq_range,Ts)
% ==========================Start=of=Documentation=========================
% Author    Yung-Chun Lin
% Last rev  Feb.24,2024 
% @brief  Generate trajectories in the theta direction for vibration
%         compensation
% @input  traj_ext  [1xN array] extension trajectory
% @input  frf       [complex]   frf at the final position
% @input  freq_range[Hz]        frequency range of the frf
% @input  Ts        [second]    sample time
% @return path      [1xN array] trajectory for the theta direction
% ===========================End=of=Documentation==========================    
    freq_range = 2*pi*freq_range;
    sys = frd(frf,freq_range);
    sys = tfest(sys,2);
    [wn,zn] = damp(sys);

    g_rt = tf([2*wn(1)*zn(1)*max(abs(frf)) 0],...
    [1 2*zn(1)*wn(1) wn(1)^2]);
    
    t = 1:1:length(traj_ext(1:end));
    out = lsim(g_rt,traj_ext-traj_ext(1),(t-1)*Ts);
    path = out';
end