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

    save(sprintf("%s.mat",device.UserData.filename),"ADXL_data")
    load handel;
    sound(y,Fs);
end

function [t,x,y,z] = ADXL_serial_process(raw_data)
    raw_data = raw_data{1};
    t = zeros(1,4);
    t(4) = bitor(bitshift(raw_data(1),4), bitshift(raw_data(2),-3));
    t(3) = bitor(bitshift(raw_data(2),5), bitshift(raw_data(3),-2));
    t(2) = bitor(bitshift(raw_data(3),6), bitshift(raw_data(4),-1));
    t(1) = bitor(bitshift(raw_data(4),7), raw_data(5));
    
    x(2) = bitshift(raw_data(6),-2);
    x(1) = bitor(bitshift(raw_data(6),6),  raw_data(7));

    y(2) = bitshift(raw_data(8),-2);
    y(1) = bitor(bitshift(raw_data(8),6),  raw_data(9));

    z(2) = bitshift(raw_data(10),-2);
    z(1) = bitor(bitshift(raw_data(10),6), raw_data(11));
    
    
    t = typecast(uint8(t),'uint32');
    x = typecast(uint8(x),'uint16');
    y = typecast(uint8(y),'uint16');
    z = typecast(uint8(z),'uint16');
end