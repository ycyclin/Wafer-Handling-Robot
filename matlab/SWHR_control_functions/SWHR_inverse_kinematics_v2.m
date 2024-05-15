function motor_angles = SWHR_inverse_kinematics_v2(target_distance, SWHR_Parameters)
%     r_disk = 102;
%     l_link = 100/sind(43);
% 
%     l1 = sqrt( r_disk^2 + l_link^2 - 2*r_disk*l_link*cosd(180-43) );
%     l2 = 217;
%     l3 = l1;
%     l4 = l2;
%     l5 = 25.42 * 2;
% 
%     theta1_home_deg = 180 - 30 - 23.5 - asind(100/l1);
%     theta3_home_deg = acosd( (l1*sind(theta1_home_deg) - l5/2) / l2 );
%     offset_home = - l1 * cosd(180-theta1_home_deg) + l2 * sind(theta3_home_deg);
%     l6 = 199.5 - offset_home;

    %%
    l1 = SWHR_Parameters.l1;
    l2 = SWHR_Parameters.l2;
    l5 = SWHR_Parameters.l5;
    l6 = SWHR_Parameters.l_wafer;
    
    angle1 = atan( (l5/2)./(target_distance-l6) );
    angle2 = acos( ((target_distance-l6).^2 + (l5/2)^2 + l1^2 - l2^2) ./...
                   (2 * sqrt((target_distance-l6).^2 + (l5/2)^2) * l1));
    motor_angles = angle1 + angle2;
end