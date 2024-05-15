function ADXL_serial_cb(device,~)
    
    while(uint8(read(device,1,"uint8"))~=255)
        fprintf("trimming data...\n")
    end
    raw_data = uint8(read(device,device.UserData.max_length*12,"uint8"));
    raw_data = reshape(raw_data,[],1);
    frame_divide_idxes = [0;find(raw_data==255)];
    frame_lengths = diff(frame_divide_idxes);
    valid_frame_idxes = frame_divide_idxes(frame_lengths==12);
    data_indexes = repmat(valid_frame_idxes',1,12)+repelem(1:12,1,length(valid_frame_idxes));
    raw_data = reshape(raw_data(data_indexes),[],12)';
    % raw_data = gpuArray(raw_data);
    
    t4 = uint32(bitor(bitshift(raw_data(1,:),4), bitshift(raw_data(2,:),-3)));
    t3 = uint32(bitor(bitshift(raw_data(2,:),5), bitshift(raw_data(3,:),-2)));
    t2 = uint32(bitor(bitshift(raw_data(3,:),6), bitshift(raw_data(4,:),-1)));
    t1 = uint32(bitor(bitshift(raw_data(4,:),7), raw_data(5,:)));
    
    x2 = uint16(bitshift(raw_data(6,:),-2));
    x1 = uint16(bitor(bitshift(raw_data(6,:),6),  raw_data(7,:)));

    y2 = uint16(bitshift(raw_data(8,:),-2));
    y1 = uint16(bitor(bitshift(raw_data(8,:),6),  raw_data(9,:)));

    z2 = uint16(bitshift(raw_data(10,:),-2));
    enable = bitand(uint8(1),bitshift(raw_data(11,:),-6));
    raw_data(11,:) = bitand(raw_data(11,:),uint8(63));
    z1 = uint16(bitor(bitshift(raw_data(10,:),6), raw_data(11,:)));
    
    t = bitshift(t4,24)+bitshift(t3,16)+bitshift(t2,8)+t1;
    x = bitshift(x2,8)+x1;
    y = bitshift(y2,8)+y1;
    z = bitshift(z2,8)+z1;

    t = double(t-t(1));
    t(t<0) = t(t<0)+4294967295;
    
    device.UserData.raw_data = raw_data;
    fprintf("Buffer full.\n")
    configureCallback(device,"off");
    device.UserData.t=t;
    device.UserData.x=x;
    device.UserData.y=y;
    device.UserData.z=z;
    device.UserData.e=enable;
    figure(114514)
    subplot(311)
    plot((device.UserData.t-device.UserData.t(1))/1000,device.UserData.y)
    title("Accel_{stretch}")
    subplot(312)
    plot((device.UserData.t-device.UserData.t(1))/1000,device.UserData.x)
    title("Accel_{rotation}")
    subplot(313)
    plot((device.UserData.t-device.UserData.t(1))/1000,device.UserData.z)
    title("Accel_{z}")

    ADXL_data = device.UserData;
    global ADXL_file_name;
    save(sprintf("%s.mat",ADXL_file_name),"ADXL_data")
    toc
    load train;
    sound(y,Fs);
    global finished;
    finished = true;
end