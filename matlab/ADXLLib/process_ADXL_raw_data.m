function [t,x,y,z,enable]=process_ADXL_raw_data(raw_data)
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

    t = t-t(1);
    t(t<0) = t(t<0)+4294967295;
end