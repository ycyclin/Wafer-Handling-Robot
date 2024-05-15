%% Mass
m1 = 0.4991;
m2 = 0.4991;
m3 = 0.1279924048;
m4 = 0.1279924048;
m5 = 0.0643528568;
m6 = 0.69992+0.71458+0.32232+0.217675+0.3835264;
m7 = 0.69992+0.71458+0.32232+0.217675+0.3835264;
m_joint = 0.02794;
m_wafer = 0.052;
m_blade = 0.122;

%% Length
l2 = 25.42;
l3 = 217;
v1 = 102*[cosd(45),sind(45)];
v2 = 100/sind(43)*[cosd(2),sind(2)];
v3 = v1 + v2;
l4 = norm(v3);
home_angle_deg = 81.5+rad2deg(angle(v3(1)+1j*v3(2)));
a3_rad = acos((l4*sind(home_angle_deg)-l2)/l3);
center_offset=l3*sin(a3_rad)-l4*cosd(180-home_angle_deg);
l1=199.5-center_offset;
l6 = sqrt(125.86^2+73.52^2);
l7 = sqrt((218.66-125.86)^2+(77.24-73.52)^2);

angle1=atand(l2./(target_distance-l1));
angle2=acosd(((target_distance-l1).^2+l2^2+l4^2-l3^2)./(2*sqrt((target_distance-l1).^2+l2^2)*l4));
angle3=acosd((l6^2+l4^2-l7^2)/(2*l6*l4));
motor_angles = angle1 + angle2;


%center of mass
com = (0.052*target_distance+... % 8 inch wafer
2*0.4991*l6*cosd(motor_angles+angle3)+... % upper arm
2*0.02794*l4*cosd(motor_angles)+... % joint
2*0.1279924048*(target_distance-l1-(l3-61.91)*l3/(target_distance-l1-l4*cosd(motor_angles)))+... % lower arm
0.0643528568*(target_distance-l1+16.72)+... % blade holder
0.122*(target_distance-22.62))... % blade
/(1000*M); % m

iner = M*abs(com^2); %kgm^2
disp(com*1000)