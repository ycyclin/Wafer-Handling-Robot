try
    delete(scom)
catch
    fprintf('scom not init.')
end
tic

% ADXL_file_name = "test"
scom = serialport("COM3",115200);
configureTerminator(scom,255)
ADXL_read_length = ceil(length(traj_ext)*8*1.1) + 1000;
% ADXL_read_length = 5000;
scom.UserData = struct("raw_data",zeros(12,ADXL_read_length),"x",zeros(1,ADXL_read_length),"y",zeros(1,ADXL_read_length),"z",zeros(1,ADXL_read_length),"e",zeros(1,ADXL_read_length),"t",zeros(1,ADXL_read_length),"count",1,"max_length",ADXL_read_length);
flush(scom)
configureCallback(scom,"byte",ADXL_read_length*12,@ADXL_serial_cb);
toc
