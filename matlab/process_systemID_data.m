clear;clc;close all;
%% Parameters
dir = "ext"; % System ID for rotational or extensional.
freq_range = 4:0.2:20; % Check the frequency range, if it matches the frequency range when doing the system ID trajectories.

%% Generate parameters for running the analysis.
% Arduino time ratio. Each arduino has different clock so the time ratios
% are different.
time_correction_ratio_arduino_with_case = 300/(299427120/1000000);
time_correction_ratio_arduino_black = 300/(297901264/1000000);
time_correction_ratio_arduino_green = 300/(297901264/1000000);
% Filename
if(dir == "rot")
    ADXL_filename = "systemID_data_rot/ADXL_sine_rot_bladedist=%.4f,freq_range=[4.0000,20.0000].mat";
    TwinCAT_filename =  "systemID_data_rot/sine_rot_bladedist=%.4f,freq_range=[4.0000,20.0000].mat";
elseif(dir == "ext")
    ADXL_filename = "systemID_data_lin/ADXL_sine_lin_bladedist=%.4f,freq_range=[4.0000,20.0000].mat";
    TwinCAT_filename =   "systemID_data_lin/sine_lin_bladedist=%.4f,freq_range=[4.0000,20.0000].mat";
end
%% Include libraries
addpath("SystemIDLib")
addpath("BaseLib")
frf = cell(0,0);
tic
%% Extract FRF
for dist = 220:20:580
    % load system ID data
    load(sprintf(ADXL_filename,dist));
    load(sprintf(TwinCAT_filename,dist));
    t = double(ADXL_data.t);
    % Correct the time bias due to arduino clock
    time_correction_ratio = time_correction_ratio_arduino_with_case;
    change_idx = find(abs(diff(t)) > (4294967295/2))+1;
    
    if ~isempty(change_idx)
        t (change_idx:end) = t(change_idx:end) + 4294967295;
    end
    % Correct the time
    t = (t-t(1))/1000*time_correction_ratio;
    x = (double(ADXL_data.x) - round(mean(ADXL_data.x)))/1024*5*9.8/0.36;
    y = (double(ADXL_data.y) - round(mean(ADXL_data.y)))/1024*5*9.8/0.36;
    z = (double(ADXL_data.z) - round(mean(ADXL_data.z)))/1024*5*9.8/0.36;
    
    % Digital filt the measurements.
    x = digital_filt_stage(x,6);
    y = digital_filt_stage(y,6);
    z = digital_filt_stage(z,6);
    t_end = floor(t(end));
    resampled_t = 1:t_end;
    % Due to incorrect wiring, x and z are labeled reversely. I.E. x is z, z is
    % x.
    timese_x = timeseries(z,t,'Name',"X");
    timese_y = timeseries(y,t,'Name',"Y");
    timese_z = timeseries(x,t,'Name',"Z");

    time_x_resample = resample(timese_x,resampled_t);
    time_y_resample = resample(timese_y,resampled_t);
    time_z_resample = resample(timese_z,resampled_t);
    
    % Extract FRF
    INPUT = diff(diff(double(pathd)))*1e6; % reference acceleration [mm/s^2]
    % TODO: Please double check here
    if(dir == "rot")
        OUTPUT1 = squeeze(time_y_resample.Data)*1e3/(dist-104.9)/pi*180; % [deg/s^2]
        OUTPUT2 = -squeeze(time_x_resample.Data)*1e3; % [mm/s^2]
    else
        OUTPUT1 = -squeeze(time_y_resample.Data)*1e3; % [deg/s^2]
        OUTPUT2 = squeeze(time_x_resample.Data)*1e3/(dist-104.9)/pi*180; % [mm/s^2]
    end
    % Invoke the extract_FRF function to get the FRF from data.
    [H_X1,H_X2] = extract_FRF(INPUT,OUTPUT1,OUTPUT2,0.001,freq_range,0.003);
    frf_obj.dist = dist;
    frf_obj.io1 = H_X1;
    frf_obj.io2 = H_X2;
    frf{end+1} = frf_obj;
    dist
end
toc
if(dir == "ext")
    save("frf_results\lin_frf.mat","frf")
elseif(dir == "rot")
    save("frf_results\rot_frf.mat","frf")
end