function distance = forward_kinematics(angles)
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

    distance = sqrt(l3^2-(sind(angles)*l4-l2).^2)+l1+l4*cosd(angles);
end