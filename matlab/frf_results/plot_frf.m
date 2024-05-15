clear;clc;close

load lin.mat
lin = frf;
load rot.mat
rot = frf;

wn_a = zeros(2,19);
zn_a = zeros(2,19);
wn_b = zeros(2,19);
zn_b = zeros(2,19);
dist_lin = zeros(1,19);
dist_rot = zeros(1,19);

for i = 1:1
    data_lin = lin{1,i};
    dist_lin(1,i) = data_lin.dist;
    data_rot = rot{1,i};
    dist_rot(1,i) = data_rot.dist;
    
    f = 4:0.2:20;
    f = 2*pi*f;

    a_lin = frd(data_lin.io1,f);
    sysa_lin = tfest(a_lin,2);
    %a_rot = frd(data_rot.io1,f);
    %sysa_rot = tfest(a_rot,2);
    
    figure(1)
    bode(a_lin)
    hold on
    bode(sysa_lin)
    xlim(2*pi*[4,20])
    %}
    b = frd(data_lin.io2,f);
    sysb = tfest(b,2);

    %[wn_a_lin(:,i),zn_a_lin(:,i)] = damp(sysa_lin);
    %[wn_a_rot(:,i),zn_a_rot(:,i)] = damp(sysa_rot);
    %[wn_b(:,i),zn_b(:,i)] = damp(sysb);

%{
wn_temp = [wn_a; wn_b];
zeta_temp = [zeta_a; zeta_b];
wn = [];
zeta = [];
for i=1:length(wn_temp)
    if ~ismember(wn_temp(i),wn)
        wn(end+1) = wn_temp(i);
    end
    if ~ismember(zeta_temp(i),zeta)
        zeta(end+1) = zeta_temp(i);
    end
end
%}
%save("zeta","zeta");
%save("wn","wn");


figure(2)
bode(b)
hold on
bode(sysb)
xlim(2*pi*[4,20])

%{
%figure(2)
subplot(2,1,1)
semilogx(f,mag2db(abs(data.io2)),'b','lineWidth',2);
hold on
ylabel('mag [db]')
xlabel('freq [Hz]')
xlim([4,20])
subplot(2,1,2)
semilogx(f,180/pi*unwrap(angle(data.io2)),'b','lineWidth',2);
%}
end
%{
figure(1)
plot(dist_lin,wn_a_lin(1,:),'r','LineWidth',2,'DisplayName','r');
hold on
plot(dist_rot,wn_a_rot(1,:),':b','LineWidth',2,'DisplayName','{\theta}');
legend('interpreter','tex');
xlabel('position [mm]');
ylabel('{\omega}_n [Hz]','interpreter','tex','rotation',0);

figure(2)
plot(dist_lin,zn_a_lin(1,:),'r','LineWidth',2,'DisplayName','r');
hold on
plot(dist_rot,zn_a_rot(1,:),':b','LineWidth',2,'DisplayName','{\theta}');
legend('interpreter','tex');
xlabel('position [mm]');
ylabel('{\zeta}','interpreter','tex','rotation',0);
%{
figure(1)
plot(dist,k(1,:))
title("k [Nm]")
xlabel("blade position")
figure(2)
plot(dist,c(1,:))
title("c [Nms]")
xlabel("blade position")
%}
%}