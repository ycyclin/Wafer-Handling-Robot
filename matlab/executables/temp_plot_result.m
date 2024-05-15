%clear;clc;close
Ts = 1e-3;
path = "../../Measurement_Data/Input_Shaping";
file = "y_baseline";
data = readtable(path+"/"+file,'VariableNamingRule','preserve');
y = table2array(data(:,3));
t = 1:1:size(y,1);

for j = 0:size(t,2)-1
       if y(end-j,1) ~= -1000
          continue 
       else
           break
       end
end

%figure(1)
plot((t(1,end-j+1:end)-t(1,end-j+1))*Ts,y(end-j+1:end,1));
