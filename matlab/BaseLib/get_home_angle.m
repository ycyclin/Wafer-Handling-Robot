function home_angle_deg = get_home_angle()
    l2 = 25.42;
    l3 = 217;
    v1 = 102*[cosd(45),sind(45)];
    v2 = 100/sind(43)*[cosd(2),sind(2)];
    v3 = v1 + v2;
    l4 = norm(v3);
    home_angle_deg = 81.5+rad2deg(angle(v3(1)+1j*v3(2)));
end