function ADXL_serial_cb(device,~)
    
    while(uint8(read(device,1,"uint8"))~=255)
        fprintf("trimming data...\n")
    end
    raw_data = uint8(read(device,device.UserData.max_length*12,"uint8"));
    raw_data = reshape(raw_data,12,length(raw_data)/12)';
    device.UserData.raw_data = raw_data';
    fprintf("Buffer full.\n")
    configureCallback(device,"off");
    cell_raw_data = num2cell(device.UserData.raw_data,1);
    [device.UserData.t,device.UserData.x,device.UserData.y,device.UserData.z] = arrayfun(@ADXL_serial_process,cell_raw_data);
    figure(114514)
    subplot(311)
    plot((device.UserData.t-device.UserData.t(1))/1000,device.UserData.y)
    title("Accel_{stretch}")
    subplot(312)
    plot((device.UserData.t-device.UserData.t(1))/1000,device.UserData.z)
    title("Accel_{rotation}")
    subplot(313)
    plot((device.UserData.t-device.UserData.t(1))/1000,device.UserData.x)
    title("Accel_{z}")

    ADXL_data = device.UserData;
    global ADXL_file_name;
    save(sprintf("%s.mat",ADXL_file_name),"ADXL_data")
    toc
    load handel;
    sound(y,Fs);
end