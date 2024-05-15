function [link_pos, link_com] = SWHR_link_positions_v2(angle, SWHR_Parameters)

l1 = SWHR_Parameters.l1;
l2 = SWHR_Parameters.l2;
l5 = SWHR_Parameters.l5;
l6 = SWHR_Parameters.l_wafer;
c1r = SWHR_Parameters.c1r;
c1u = SWHR_Parameters.c1u;
c2r = SWHR_Parameters.c2r;
c2u = SWHR_Parameters.c2u;
c3r = SWHR_Parameters.c3r;
c3u = SWHR_Parameters.c3u;
c4r = SWHR_Parameters.c4r;
c4u = SWHR_Parameters.c4u;
c5r = SWHR_Parameters.c5r;
c5u = SWHR_Parameters.c5u;

theta1 = angle;
theta3 = angle;

theta2 = asin((l1*sin(theta1/2+theta3/2) - l5/2) / l2) + theta1/2+theta3/2;
theta4 = theta2;

%% COM positions
x1_com = [c1r*cos(theta1) - c1u*sin(theta1);
          c1r*sin(theta1) + c1u*cos(theta1)];

x2_com = [l1*cos(theta1) + c2r*cos(theta2-theta1) + c2u*sin(theta2-theta1);
          l1*sin(theta1) - c2r*sin(theta2-theta1) + c2u*cos(theta2-theta1)];

x3_com = [  c3r*cos(theta3) - c3u*sin(theta3);
          - c3r*sin(theta3) - c3u*cos(theta3)];

x4_com = [  l1*cos(theta3) + c4r*cos(theta4-theta3) + c4u*sin(theta4-theta3);
          - l1*sin(theta3) + c4r*sin(theta4-theta3) - c4u*cos(theta4-theta3)];      

c50 = sqrt(l1^2 + l2^2 - 2*l1*l2*cos(pi-theta2) - l5^2/4);
x5_com = [ (c50+c5r)*cos(theta1/2-theta3/2) - c5u*sin(theta1/2-theta3/2);
           (c50+c5r)*sin(theta1/2-theta3/2) + c5u*cos(theta1/2-theta3/2)];

%% Link end positions
x1_endpts = [0, l1*cos(theta1);
             0, l1*sin(theta1)];

x2_endpts = x1_endpts(:,end) + [0, l2*cos(theta1-theta2);
                                0, l2*sin(theta1-theta2)];

x3_endpts = [0, l1*cos(-theta3);
             0, l1*sin(-theta3)];

x4_endpts = x3_endpts(:,end) + [0, l2*cos(-theta3+theta4);
                                0, l2*sin(-theta3+theta4)];

c50 = sqrt(l1^2 + l2^2 - 2*l1*l2*cos(pi-theta2) - l5^2/4);
x5_endpts =      c50       * [cos(     theta1/2-theta3/2); sin(     theta1/2-theta3/2)] + ...
            [-l5/2, l5/2] .* [cos(pi/2+theta1/2-theta3/2); sin(pi/2+theta1/2-theta3/2)];

x6_endpts = [c50, c50+l6] .* [cos(     theta1/2-theta3/2); sin(     theta1/2-theta3/2)];

%%
link_pos = {x1_endpts; x2_endpts; x3_endpts; x4_endpts; x5_endpts; x6_endpts};
link_com = {x1_com;    x2_com;    x3_com;    x4_com;    x5_com};

end