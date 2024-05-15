clear;clc;close all;
addpath("ADXLLib")
addpath("BaseLib")
files = struct2cell(dir("data/ADXL_blade_linear_accel=1500.0000,vel=300.0000_REP_*"));

filenames = [files(1,:)];
total_time = [];
stop_threshold = 0.14;
% filename = filenames(9);
for filename = filenames
    load("data\\"+filename{1});
    load("data\\"+erase(filename{1},"ADXL_"));
    if(isempty(find(ADXL_data.raw_data(:,1)==255, 1)) || (find(ADXL_data.raw_data(:,1)==255)~=12))
        raw_data = reshape(ADXL_data.raw_data,[1,12*length(ADXL_data.raw_data)]);
        raw_data(1:find(ADXL_data.raw_data(:,1)==255))=[];
        raw_data((floor(length(raw_data)/12)*12+1):end) = [];
        while(find(raw_data==255,1)~=12)
            raw_data(1:find(raw_data==255,1))=[];
            raw_data((floor(length(raw_data)/12)*12+1):end) = [];
        end
        raw_data = reshape(raw_data,12,length(raw_data)/12)';
        cell_raw_data = num2cell(raw_data',1);
        [ADXL_data.t,ADXL_data.x,ADXL_data.y,ADXL_data.z] = arrayfun(@ADXL_serial_process,cell_raw_data);
    end
    t = double(ADXL_data.t);
    change_idx = find(abs(diff(t)) > (4294967295/2))+1;
    if ~isempty(change_idx)
        t (change_idx:end) = t(change_idx:end) + 4294967295;
    end
    t = (t-t(1))/1000;
    
    x = (double(ADXL_data.x) - 403)/1024*5*9.8/0.36;
    y = (double(ADXL_data.y) - 328)/1024*5*9.8/0.36;
    z = (double(ADXL_data.z) - 330)/1024*5*9.8/0.36;
    
    % x = lowpass(x,0.01);
    % y = lowpass(y,0.01);
    % z = lowpass(z,0.01);

    max_time = length(x)-min([find(abs(flip(x))>stop_threshold,1),find(abs(flip(y))>stop_threshold,1),find(abs(flip(z))>stop_threshold,1)]);
    total_time(end+1) = max_time;
    ta1 = gradient(gradient(forward_kinematics(tpos1 + get_home_angle())',0.001),0.001);
    cmd_time = find(ta1~=0,1,'last') - find(ta1~=0,1);
    cmd_time = cmd_time + find(y>stop_threshold,1);
    subplot(311)
    plot(t,z)
    hold on
    title("Rotational Acceleration [m/s^2]")
    plot([cmd_time,cmd_time],[min(z),max(z)],'r--');

    hold off
    subplot(312)
    plot(t,y)
    hold on
    title("Extensional Acceleration [m/s^2]")
    plot([cmd_time,cmd_time],[min(y),max(y)],'r--');
    hold off
    subplot(313)
    plot(t,x)
    hold on
    title("Z Acceleration [m/s^2]")
    plot([cmd_time,cmd_time],[min(x),max(x)],'r--');
    hold off
    drawnow
end