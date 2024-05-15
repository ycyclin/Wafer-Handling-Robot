try
    delete(scom)
catch
    fprintf('scom not init.')
end
tic
scom = serialport("COM1",115200);
configureTerminator(scom,255)
ADXL_read_length = ceil(pathlen*1.1) + 1000;
scom.UserData = struct("raw_data",zeros(12,ADXL_read_length),"x",zeros(1,ADXL_read_length),"y",zeros(1,ceil(pathlen*1.1)),"z",zeros(1,ADXL_read_length),"count",1,"max_length",ADXL_read_length);
flush(scom)
configureCallback(scom,"byte",ADXL_read_length*12,@ADXL_serial_cb);