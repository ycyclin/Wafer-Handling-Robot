function [trajectory,indexes] = generate_sine_sweep(amp_accel,freq_range,set_time,Ts)
% ==========================Start=of=Documentation=========================
% Author    Chen Qian chq@umich.edu
% Last rev  Aug.07,2023
% @brief    Generate the desired sine sweep command in position, with the
%           given acceleration level. 

% @input    accel_amp       The amplitude of acceleration sine signal.
%                                                               [x/s^2]
% @input    freq_range      The sine sweep frequency range.     [Hz]
% @input    set_time        The time that waits between each sine signal, 
%                           to make machine fully stop.         [s]
% @input    Ts              The output signal's sampling time.  [s]      
% ===========================End=of=Documentation==========================

% Invoke function to generate cell arrays that contains the trajectory and
% indexes for the ID signals.

result = arrayfun(@pack_function, ...
    repmat(amp_accel,1,length(freq_range)), ... % acceleration parameter
    freq_range, ...                             % frequency parameter
    repmat(set_time,1,length(freq_range)),...   % settling time parameter
    repmat(15,1,length(freq_range)), ...        % number of periods parameter
    repmat(Ts,1,length(freq_range)));           % sampling time parameter
trajectory = horzcat(result.trajectory);
trajectory_start_idx = [1 (cumsum(horzcat(result.length))+1)];
trajectory_start_idx = trajectory_start_idx(1:end-1);
indexes = horzcat(result.indexes) + repmat(trajectory_start_idx,2,1);
end

% A pass-through function for arrayfun.
function result = pack_function(amp_accel,frequency,set_time,np,Ts)
    [result.trajectory, result.indexes] = sine_generate_function(amp_accel,frequency,np,Ts);
    result.trajectory = [result.trajectory repmat(result.trajectory(end), 1, ceil(set_time/Ts))];
    result.length = length(result.trajectory);
end

function [trajectory, indexes] = sine_generate_function(amp_accel,sin_frequency,np,Ts)
% ==========================Start=of=Documentation=========================
% Author    Chen Qian chq@umich.edu
% Last rev  Aug.08,2023
% @brief    Generate the single sine frequency test command, with
%           calibration signal

% @input    amp_accel       The amplitude of acceleration sine
%                           signal.                             [x/s^2]
% @input    sin_frequency   The sine signal's frequency.        [Hz]
% @input    np              Number of periods of sine signal    [N]
% @input    Ts              The output signal's sampling time.  [s]
% @return   trajectory      The generated system ID trajectory  [x]
% @return   indexes         The indexes that indicates the indexes of start
%                           and end of sine signal.             [N]
% ===========================End=of=Documentation==========================
%%%%%%%%%%%%%%%%%%% Begin of internal parameters %%%%%%%%%%%%%%%%%%%
calib_vel   = 30;  % Velocity for the calibration signal
calib_accel = 500; % Acceleration for the calibration signal
calib_jerk  = 1e5; % Jerk for the calibration signal
%%%%%%%%%%%%%%%%%%%% End of internal parameters %%%%%%%%%%%%%%%%%%%%
%% Calculation
% Explaination: the signal consists of five parts. In velocity level, you
% will see:
% [Acceleration, Deceleration], [30ms delay], [rampdown],    [cos-signal]   , [rampup], [30ms delay], [Deceleration, Acceleration]
%           "S-Curve"         ,             ,   "ramp"  , "System ID signal",  "ramp" ,             ,          "S-Curve"
% The second line is the name convention we used in this function.

% Generate time vector.
t = (0:ceil(1/sin_frequency*np/Ts))*Ts;
% Get the amplitude in velocity level.
amp_vel = amp_accel./(2*pi*sin_frequency);

% Generate displacement vectors.
% Calculate discretized parameters for ramp signal. 
% To connect the signal seamlessly, we need to connect the signal in
% velocity level, using the ramp.
time_calib_ramp = (0:ceil(abs(amp_vel)/calib_accel/Ts))*Ts;
% 30 ms delay between S-Curve and ramps
time_calib_delay = ceil(0.03/Ts);
% Calculated discretized acceleration for ramp signal.
calib_accel_dis     = amp_vel/time_calib_ramp(end);
displacement_ramp   = 1/2*calib_accel_dis*time_calib_ramp.^2;
displacement_ramp   = -displacement_ramp(1:end-1)+displacement_ramp(end);
displacement_scurve = ScurveTBI(0, displacement_ramp(1),calib_vel,calib_accel,calib_jerk,Ts);
displacement_sine   = -(amp_accel./(2*pi*sin_frequency)^2).*sin(2*pi*sin_frequency*t);
trajectory          = [displacement_scurve, ...
                       repmat(displacement_scurve(end),1,time_calib_delay),...
                       displacement_ramp, ...
                       displacement_sine, ...
                       displacement_sine(end)-flip(displacement_ramp), ...
                       repmat(displacement_sine(end)-displacement_ramp(1),1,time_calib_delay),...
                       ScurveTBI(displacement_sine(end)-displacement_ramp(1),0,calib_vel,calib_accel,calib_jerk,Ts)];
indexes             = cumsum([length(displacement_scurve)+length(displacement_ramp)+time_calib_delay, (length(displacement_sine)-1)])';
end

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