function [J1s, J2s, J3s, J4s, J5s, Jws, Jas] = SWHR_Polar_Jacobian_links_wafer_and_accelerometer(angles, SWHR_Parameters, loc_acc)

if nargin <= 2
    loc_acc = 0.0254 * 4;
end

theta1s = angles;
theta3s = angles;

% global c1r c1u c2r c2u c3r c3u c4r c4u c5r c5u l1 l2 l5 l6
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
l1 = SWHR_Parameters.l1;
l2 = SWHR_Parameters.l2;
l5 = SWHR_Parameters.l5;
l_wafer = SWHR_Parameters.l_wafer;
l_acc = SWHR_Parameters.l_acc;

J1s = nan(3,2,length(theta1s));
J2s = nan(3,2,length(theta1s));
J3s = nan(3,2,length(theta1s));
J4s = nan(3,2,length(theta1s));
J5s = nan(3,2,length(theta1s));
Jws = nan(3,2,length(theta1s));
Jas = nan(3,2,length(theta1s));

T_rt = [1, 1;
        1,-1];

for k = 1:length(theta1s)
    theta1 = theta1s(k);
    theta3 = theta3s(k);
    
    %% links
    theta2 = asin((l1*sin(theta1/2+theta3/2) - l5/2) / l2) + theta1/2+theta3/2;
    theta4 = theta2;
    c50 = sqrt(l1^2 + l2^2 - 2*l1*l2*cos(pi-theta2) - l5^2/4);
    A2 = 1/2 + 1/2 * ((l1*cos(theta1/2+theta3/2)) / (l2 * sqrt(1-(l1*sin(theta1/2+theta3/2) - l5/2)^2/l2^2)));

    J1 = [-c1r*sin(theta1) - c1u*cos(theta1), 0;
           c1r*cos(theta1) - c1u*sin(theta1), 0;
                           1                  0];

    J2 = [-l1*sin(theta1) + c2r*sin(theta2-theta1) - c2u*cos(theta2-theta1), -c2r*sin(theta2-theta1) + c2u*cos(theta2-theta1);
           l1*cos(theta1) + c2r*cos(theta2-theta1) + c2u*sin(theta2-theta1), -c2r*cos(theta2-theta1) - c2u*sin(theta2-theta1);
                                   1                                                                -1                      ];
    J2 = J2 * [1, 0; A2, A2];

    J3 = [0, -c3r*sin(theta3) - c3u*cos(theta3);
          0, -c3r*cos(theta3) + c3u*sin(theta3);
          0,                  1                ];

    J4 = [-l1*sin(theta3) + c4r*sin(theta4-theta3) - c4u*cos(theta4-theta3), -c4r*sin(theta4-theta3) + c4u*cos(theta4-theta3);
          -l1*cos(theta3) - c4r*cos(theta4-theta3) - c4u*sin(theta4-theta3),  c4r*cos(theta4-theta3) + c4u*sin(theta4-theta3);
                                  -1                                                                 1                      ];
    J4 = J4 * [0, 1; A2, A2];

    J5_col1 = [-(c50+c5r)/2*sin(theta1/2-theta3/2) - c5u/2*cos(theta1/2-theta3/2);
                (c50+c5r)/2*cos(theta1/2-theta3/2) - c5u/2*sin(theta1/2-theta3/2);
                                                 1/2                            ];
    J5_col2 = [-l1*l2*sin(theta2)/c50*cos(theta1/2-theta3/2);
               -l1*l2*sin(theta2)/c50*sin(theta1/2-theta3/2);
                                    0                      ];
    J5_col3 = [ (c50+c5r)/2*sin(theta1/2-theta3/2) + c5u/2*cos(theta1/2-theta3/2);
               -(c50+c5r)/2*cos(theta1/2-theta3/2) + c5u/2*sin(theta1/2-theta3/2);
                                                -1/2                            ];
    J5 = [J5_col1, J5_col2, J5_col3] * [1, 0; A2, A2; 0, 1];
    
    %% wafer
    c5r_w = l_wafer;
    
    Jw_col1 = [-(c50+c5r_w)/2*sin(theta1/2-theta3/2);
                (c50+c5r_w)/2*cos(theta1/2-theta3/2);
                                1/2                 ];
    Jw_col2 = [-l1*l2*sin(theta2)/c50*cos(theta1/2-theta3/2);
               -l1*l2*sin(theta2)/c50*sin(theta1/2-theta3/2);
                                     0                      ];
    Jw_col3 = [ (c50+c5r_w)/2*sin(theta1/2-theta3/2);
               -(c50+c5r_w)/2*cos(theta1/2-theta3/2);
                                -1/2                 ];
    Jw = [Jw_col1, Jw_col2, Jw_col3] * [1, 0; A2, A2; 0, 1];
    
    %% accelerometer
    c5r_a = l_wafer - loc_acc;
    
    Ja_col1 = [-(c50+c5r_a)/2*sin(theta1/2-theta3/2);
                (c50+c5r_a)/2*cos(theta1/2-theta3/2);
                                 1/2                 ];
    Ja_col2 = [-l1*l2*sin(theta2)/c50*cos(theta1/2-theta3/2);
               -l1*l2*sin(theta2)/c50*sin(theta1/2-theta3/2);
                                     0                      ];
    Ja_col3 = [ (c50+c5r_a)/2*sin(theta1/2-theta3/2);
               -(c50+c5r_a)/2*cos(theta1/2-theta3/2);
                                -1/2                 ];
    Ja = [Ja_col1, Ja_col2, Ja_col3] * [1, 0; A2, A2; 0, 1];
    
    %%
    J1s(:,:,k) = J1 * T_rt;
    J2s(:,:,k) = J2 * T_rt;
    J3s(:,:,k) = J3 * T_rt;
    J4s(:,:,k) = J4 * T_rt;
    J5s(:,:,k) = J5 * T_rt;
    Jws(:,:,k) = Jw * T_rt;
    Jas(:,:,k) = Ja * T_rt;
end

end