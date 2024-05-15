clear;clc;close all;
load("lin_frf.mat")

freq = 4:0.2:20;
dist = zeros(1,length((frf)));
mag = zeros(1,length((frf)));
wd = zeros(1,length((frf)));
for i = 1:length(frf)
    dist(i) = frf{i}.dist;
    [mag_i,idx] = max(abs(frf{i}.io1));
    mag(i) = mag_i;
    wd(i) = freq(idx);
end
plot(dist,wd,"k-",LineWidth=2)
load("lin_frf.mat")

freq = 4:0.2:20;
dist = zeros(1,length((frf)));
mag = zeros(1,length((frf)));
wd = zeros(1,length((frf)));
for i = 1:length(frf)
    dist(i) = frf{i}.dist;
    [mag_i,idx] = max(abs(frf{i}.io1));
    mag(i) = mag_i;
    wd(i) = freq(idx);
end
hold on;
plot(dist,wd,"k--",LineWidth=2)
title("Resonance Frequency in Different Directions",Interpreter="latex")
legend("$\theta$","radial",Interpreter="latex",Location="best")
xlabel("x [mm]",Interpreter="latex")
ylabel("$\omega_d$ [Hz]",Interpreter="latex")
saveas(gcf,"wd.svg")