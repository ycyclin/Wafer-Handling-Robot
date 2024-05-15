function [path] = ScurveTBI(p_start,p_end,feedrate,accel,jerk,Ts)
% ==========================Start=of=Documentation=========================
% Author    Chen Qian
% Last rev  Jul.18,2023
% @brief  Generate S-curve trajectories with provided parameters
%         We assume fs, fe are all zeros.
%         The code could override acceleration and velocity to fullfill
%         jerk requirements while precisely keeping the travel length.
% @input  p_start  [x]   start point
% @input  p_end    [e]   end point
% @input  feedrate [mm/s]      desired feedrate at constant speed (in final trajectory may differs a little)
% @input  accel    [mm/s^2]    desired acceleration.
% @input  jerk     [mm/s^3]    desired jerk.
% @input  Ts       [sec]       sampling time.
% @return path     [4*N array] interpolated path
%         fe       [mm/s]      end feedrate (for next TBI) 
% ===========================End=of=Documentation==========================
    % Normalize the length, get direction.
    L = (p_end-p_start);
    dir    = L/abs(L);
    L = abs(L);
    % First check if able to fully accelerate
    [t1_jerk,t2_accel,~,accel] = get_trapz_t(jerk,accel,feedrate);
    % Then check if able to reaches to top feedrate
    l123_accel = feedrate*(t1_jerk+t2_accel/2);
    l4_const = L-2*l123_accel;
    % If cannot reaches to target feedrate
    if(l4_const < 0) 
        % Check, if it cannot reaches to maximum feedrate
        if(L>accel^3/jerk^2)
            % if L is larger than the length that can reaches to max
            % acceleration
            feedrate = -accel^2/2/jerk+sqrt(accel^4/4/jerk^2+accel*L);
        else
            % if L is smaller than the length that can reaches to max
            % acceleration
            accel = nthroot(L*jerk^2,3);
            feedrate = accel^2/jerk;
        end
        [~,t2_accel,~,accel] = get_trapz_t(jerk,accel,feedrate);
        t4_const = 0;
    else
       % Check, if it can reaches to maximum feedrate
       t4_const = l4_const/feedrate;
    end
    % calculate time
    t1_jerk = accel/jerk;
    t3_jerkd = t1_jerk;
    t5_jerk = t1_jerk;
    t6_accel = t2_accel;
    t7_jerkd = t1_jerk;

    % Discretize round up.
    n1_jerk  = ceil(t1_jerk /Ts);
    n2_accel = ceil(t2_accel/Ts);
    n3_jerkd = ceil(t3_jerkd/Ts);
    n4_const = ceil(t4_const/Ts);
    n5_jerk  = ceil(t5_jerk /Ts);
    n6_accel = ceil(t6_accel/Ts);
    n7_jerkd = ceil(t7_jerkd/Ts);
    
    % Discretize the parameters
    feedrate_dis = L/(n1_jerk+n2_accel+n3_jerkd+n4_const)/Ts;
    accel_dis = feedrate_dis/(n1_jerk+n2_accel)/Ts;
    jerk_dis = accel_dis/n1_jerk/Ts;
    
    % Generate s.
    s_end = 0;
    if(n1_jerk > 0) 
        t1d = (0:n1_jerk)*Ts;
        s1 = (1/6)*jerk_dis*t1d.^3;
        s_end = s1(end);
    else
        s1 = [];
    end
    if(n2_accel > 0)
        t2d = (1:n2_accel)*Ts;
        s2 = s_end + 1/2*jerk_dis*(n1_jerk*Ts)^2*t2d+1/2*accel_dis*t2d.^2;
        s_end = s2(end);
    else
        s2 = [];
    end
    if(n3_jerkd > 0)
        t3d = (1:n3_jerkd)*Ts;
        s3 = s_end + t3d*feedrate_dis-(1/6)*jerk_dis*(n1_jerk*Ts)^3+(1/6)*jerk_dis*(n3_jerkd*Ts-t3d).^3;
        s_end = s3(end);
    else
        s3 = [];
    end
    if(n4_const > 0) 
        t4d = (1:n4_const)*Ts;
        s4 = s_end+feedrate_dis*t4d;
        s_end = s4(end);
    else
        s4 = [];
    end
    
    if(n5_jerk > 0)
        t5d = (1:n5_jerk)*Ts;
        s5 = s_end+feedrate_dis*t5d-(1/6)*jerk_dis*t5d.^3;
        s_end = s5(end);
    else
        s5 = [];
    end
    if(n6_accel > 0)
        t6d = (1:n6_accel)*Ts;
        s6 = s_end+(feedrate_dis-1/2*jerk_dis*(n5_jerk*Ts)^2)*t6d-1/2*accel_dis*t6d.^2;
        s_end = s6(end);
    else
        s6 = [];
    end
    if(n7_jerkd > 0)
        t7d = (1:n7_jerkd)*Ts;
        s7 = s_end+(1/6)*jerk_dis*(n7_jerkd*Ts)^3-(1/6)*jerk_dis*(n7_jerkd*Ts-t7d).^3;
    else
        s7 = [];
    end
    s = [s1 s2 s3 s4 s5 s6 s7];
    path = repmat(p_start,[1,size(s,2)]) + repmat(s,[size(p_start,1),1]).*repmat(dir,[1,size(s,2)]);
end

function [t1,t2,t3,height] = get_trapz_t(slope, height, area)
    t1 = height/slope;
    t2 = area/height - t1;
    if(t2 < 0)
        height = sqrt(area*slope);
        t1 = height/slope;
        t2 = 0;
    end
    t3 = t1;
end