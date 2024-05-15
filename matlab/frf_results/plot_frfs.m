load("rot_frf.mat")
figure(114514)
freq_range = [4:0.2:20];
for i = 1:length(frf)
    subplot(2,1,1)
    semilogx(freq_range, mag2db(abs(frf{i}.io1)),'b','LineWidth',2)
    hold on
    semilogx(freq_range, mag2db(abs(frf{i}.io2)),'r','LineWidth',2)
    hold off
    xlabel('Frequency (Hz)')
    ylabel('Mag [dB]')
    legend("cmd_{lin} to meas_{lin}","cmd_{lin} to meas_{rot}")
    grid on
    title('Input = x_{ref} acceleration, Output = x direction acceleration')
    xlim([min(freq_range) max(freq_range)])
    subplot(2,1,2)
    semilogx(freq_range,unwrap(angle(frf{i}.io1))*180/pi,'b','LineWidth',2)
    hold on
    semilogx(freq_range,unwrap(angle(frf{i}.io2))*180/pi,'r','LineWidth',2)
    hold off
    xlabel('Frequency (Hz)')
    ylabel('Phase [deg]')
    grid on
    xlim([min(freq_range) max(freq_range)])
    drawnow
    pause(0.001)
end