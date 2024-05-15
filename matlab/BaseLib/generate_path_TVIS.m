function path = generate_path_TVIS(start,stop,v,a,jerk,Exp_Parameters,SWHR_Parameters,Ts,B,K)
% ==========================Start=of=Documentation=========================
% Author    Yung-Chun Lin
% Last rev  Feb.22,2024
% include "BaseLib" and "SWHR_control_functions" in your path when running this script 
% @brief  Generate trajectories and filter it with TVIS with provided parameters
%         using FD-OSA algorithm
% @input  start     [mm]   start point
% @input  end       [mm]   end point
% @input  v         [mm/s]      desired feedrate at constant speed (in final trajectory may differs a little)
% @input  a         [mm/s^2]    desired acceleration.
% @input  jerk      [mm/s^3]    desired jerk.
% @input  Ts        [sec]       sampling time.
% @return path      [1xN array] trajectory for extension
% ===========================End=of=Documentation==========================    
    traj_ext = ScurveTBI(start,stop,v,a,jerk,Ts);

    % find the position that has the lowest frequency
    angles = SWHR_inverse_kinematics_v2(traj_ext/1000, SWHR_Parameters);
    Ms = SWHR_Polar_Mass_Matrix_ExperimentalBaseInertia(angles, SWHR_Parameters, Exp_Parameters, 0);
    [~,index] = max(Ms(1,1,:));
    freq = sqrt(K/Ms(1,1,index))/(2*pi); % Hz
    
    
    % extend path by one period of the lowest frequency
    traj_ext = [traj_ext traj_ext(end)*ones(1,round(1/freq/Ts))];
    traj_ext = traj_ext - start;
    traj_ext_filt = zeros(1,length(traj_ext));

    
    % filter the trajectory with FD-OSA algorithm
    % initialize traj_ext_filt
    angle = SWHR_inverse_kinematics_v2(start/1000, SWHR_Parameters);
    Ms = SWHR_Polar_Mass_Matrix_ExperimentalBaseInertia(angle, SWHR_Parameters, Exp_Parameters, 0);
    natural_freq = sqrt(K/Ms(1,1)); % rad/s
    damp = B/(2*sqrt(K*Ms(1,1)));
    Td = 2*pi/(natural_freq*sqrt(1-damp^2)); % seconds
    K_IS = exp(-pi*damp/sqrt(1-damp^2)); % K for input shaping, not be to confused with robot stiffness K
    A = [1/(1+2*K_IS+K_IS^2); 2*K_IS/(1+2*K_IS+K_IS^2); K_IS^2/(1+2*K_IS+K_IS^2)]; % Amplitude for ZVD

    [A_21,T_21,A_22,T_22] = lin_extrapolation_FD_filter(Td/2,A(2),Ts);
    [A_31,T_31,A_32,T_32] = lin_extrapolation_FD_filter(Td,A(3),Ts);

    buffer = [zeros(1,T_32) traj_ext(1,1)];
        
    traj_ext_filt(1,1) = A(1)*buffer(1,end)+...
                         A_21*buffer(1,end-T_21)+...
                         A_22*buffer(1,end-T_22)+...
                         A_31*buffer(1,end-T_31)+...
                         A_32*buffer(1,end-T_32);
    for i = 2:length(traj_ext_filt)
        % calculate where the impulse should be
        angle = SWHR_inverse_kinematics_v2((traj_ext_filt(1,i-1)+start)/1000, SWHR_Parameters);
        Ms = SWHR_Polar_Mass_Matrix_ExperimentalBaseInertia(angle, SWHR_Parameters, Exp_Parameters, 0);
        natural_freq = sqrt(K/Ms(1,1)); % rad/s
        damp = B/(2*sqrt(K*Ms(1,1)));
        Td = 2*pi/(natural_freq*sqrt(1-damp^2)); % seconds
        K_IS = exp(-pi*damp/sqrt(1-damp^2)); % K for input shaping, not be to confused with robot stiffness K
        A = [1/(1+2*K_IS+K_IS^2); 2*K_IS/(1+2*K_IS+K_IS^2); K_IS^2/(1+2*K_IS+K_IS^2)]; % Amplitude for ZVD

        [A_21,T_21,A_22,T_22] = lin_extrapolation_FD_filter(Td/2,A(2),Ts);
        [A_31,T_31,A_32,T_32] = lin_extrapolation_FD_filter(Td,A(3),Ts);
        
        if i >= T_32+1
            buffer = traj_ext(1,i-T_32:i);
        else
            buffer = [zeros(1,T_32+1-i) traj_ext(1,1:i)];
        end
        
        traj_ext_filt(1,i) = A(1)*buffer(1,end)+...
                             A_21*buffer(1,end-T_21)+...
                             A_22*buffer(1,end-T_22)+...
                             A_31*buffer(1,end-T_31)+...
                             A_32*buffer(1,end-T_32);
    end
    
    % output path
    path = traj_ext_filt+start;
end