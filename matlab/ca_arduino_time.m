addpath("ADXLLib")
try
    delete(scom)
catch
    fprintf('scom not init.')
end
scom = serialport("COM3",115200);
flush(scom)
scom.NumBytesAvailable
pause(300)
raw_data = uint8(read(scom,scom.NumBytesAvailable,"uint8"));
while(find(raw_data==255,1)~=12)
    raw_data(1:find(raw_data==255,1))=[];
    raw_data((floor(length(raw_data)/12)*12+1):end) = [];
end

raw_data = reshape(raw_data,12,length(raw_data)/12)';
cell_raw_data = num2cell(raw_data',1);
[t,x,y,z] = arrayfun(@ADXL_serial_process,cell_raw_data);

change_idx = find(abs(diff(t)) > (4294967295/2))+1;
if ~isempty(change_idx)
    t (change_idx:end) = t(change_idx:end) + 4294967295;
end

t = double(t-t(1));
plot(t/1000000)
hold on
plot((1:length(t))/length(t)*300)
