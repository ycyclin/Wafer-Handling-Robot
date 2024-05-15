function [t,x,y,z] = ADXL_serial_process(raw_data)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
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

