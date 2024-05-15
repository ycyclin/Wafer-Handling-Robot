function [path] = zvd_input_shaping(traj,start,nat_freq,damp_ratio,Ts)
% ==========================Start=of=Documentation=========================
% Author    Yung-Chun Lin
% Last rev  Oct.121,2023
% @brief  modify trajectory with provided parameters
%         The system may have different modes, we may have to filter
%         The trajectory multiple times
% @input  traj          [1xN array]   trajectory
% @input  start         [x]           start position of the motion
% @input  nat_freq      [1xM array]   array of natural frequency
% @input  damp_ratio    [1xM array]   array of damping ratios
% @input  Ts            [s]         sampling time
% @return path     [1xX array] filtered path 
% ===========================End=of=Documentation==========================

Td = 2*pi./(nat_freq.*sqrt(1-damp_ratio.^2));
d = 2*round(Td/Ts/2);
K = exp(-pi*damp_ratio./sqrt(1-damp_ratio.^2));
A = [1./(1+2*K+K.^2); 2*K./(1+2*K+K.^2); K.^2./(1+2*K+K.^2)]; % for zvd shaper
%A = [1./(1+K); K./(1+K)]; % for zv shaper
path_temp = [traj traj(end)*ones(1,round(1.1*sum(d)))]-start;
path = [traj traj(end)*ones(1,round(1.1*sum(d)))]-start;
num = size(path_temp,2);

for i = 1:size(nat_freq,2)
    for j = 1:num
        
        if j <=  d(i)
           path(j) = A(1,i)*path_temp(j); 
        end
        if j > d(i)/2 && j <= d(i)
            path(j) = A(1,i)*path_temp(j)+A(2,i)*path_temp(j-d(i)/2);
        end
        if j > d(i)
            path(j) = A(1,i)*path_temp(j)+A(2,i)*path_temp(j-d(i)/2)+A(3,i)*path_temp(j-d(i));
        end
        
        %{
        if j <=  d(i)/2
           path(j) = A(1,i)*path_temp(j); 
        end
        if j > d(i)/2
            path(j) = A(1,i)*path_temp(j)+A(2,i)*path_temp(j-d(i)/2);
        end
        %}
    end
    path_temp = path;
end
path = path + start;

