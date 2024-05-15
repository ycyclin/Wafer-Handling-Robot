function motor_angles = inverse_kinematics(target_distance)
    % parameters
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
    
    angle1=atand(l2./(target_distance-l1));
    angle2=acosd(((target_distance-l1).^2+l2^2+l4^2-l3^2)./(2*sqrt((target_distance-l1).^2+l2^2)*l4));
    motor_angles = angle1 + angle2;
end