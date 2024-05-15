clear;clc;close

load downweight.mat
f = 4:0.2:20;
f = 2*pi*f;
wn = zeros(4,3);
zn = zeros(4,3);
for i = 1:3
   sys = frd(frf{i}.io1,f);  
   bode(sys)
   hold on
   sys_est = tfest(sys,4);
   [wn(:,i),zn(:,i)] = damp(sys_est);
end
xlim([4 20]*2*pi)
legend(string(frf{1}.angle),string(frf{2}.angle),string(frf{3}.angle))