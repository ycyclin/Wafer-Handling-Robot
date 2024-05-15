% @input  p_start  [x]   start point
% @input  p_end    [e]   end point
% @input  fs       [mm/s]      desired start feedrate (in final trajectory may differs a little)
% @input  fe       [mm/s]      desired end feedrate (in final trajectory may differs a little)
% @input  feedrate [mm/s]      desired feedrate at constant speed (in final trajectory may differs a little)
% @input  accel    [mm/s^2]    desired acceleration.
% @input  Ts       [sec]       sampling time.
% @return path     [4*N array] interpolated path
%         fe       [mm/s]      end feedrate (for next TBI) 
function [path,fe,L] = linearTBI(p_start,p_end,fs,fe,feedrate,accel,Ts)
    L = (p_end-p_start);
    dir    = L/abs(L);
    L = abs(L);

    T2 = 1/feedrate*(L-1/accel*feedrate^2+(fe^2+fs^2)/2/accel);
    if(T2<0)
        fe = 0;
        feedrate = sqrt(accel*(L+fe^2/2/accel+fs^2/2/accel));
        if(fs>feedrate)
            fs = feedrate;
        end
        if(fe>feedrate)
            fe = feedrate;
        end
        T2 = 1/feedrate*(L-1/accel*feedrate^2+(fe^2+fs^2)/2/accel);
    end
    T1 = (feedrate-fs)/accel;
    T3 = (feedrate-fe)/accel;

    N1 = ceil(T1/Ts);
    N2 = ceil(T2/Ts);
    N3 = ceil(T3/Ts);

    T1_new = N1*Ts;
    T2_new = N2*Ts;
    T3_new = N3*Ts;

    feedrate_new = 1/(T1_new+2*T2_new+T3_new)*(2*L-fs*T1_new-fe*T3_new);
    accel_new = (abs(feedrate_new)-fs)/T1;
    % if T1 == 0; fs == feedrate, calculate accel for fe;
    if(ismember(inf,accel_new)||ismember(-inf,accel_new))
        accel_new = (feedrate_new-fe)/T3_new;
    end
    % if still accel == inf, T3 == 0; whole path constant speed. accel = 0; 
    if(ismember(inf,accel_new)||ismember(-inf,accel_new))
        accel_new = 0*dir;
    end
    if(N1~=0)
        s1 =1/2*accel_new*((0:N1)*Ts).^2+fs*(0:N1)*Ts;
    else
        s1 = [];
    end
    if(N2~=0)
        if(~isempty(s1))
            s2 = s1(end)+feedrate_new*(1:N2)*Ts;
        else
            s2 = feedrate_new*(1:N2)*Ts;
        end
    else
        s2 = [];
    end
    if(N3~=0)
        if(N2==0)
            if(N1==0)
                s3 = feedrate_new*(1:N3)*Ts-1/2*accel_new*((1:N3)*Ts).^2;
            else
                s3 = s1(:,end)+feedrate_new*(1:N3)*Ts-1/2*accel_new*((1:N3)*Ts).^2;
            end
        else
            s3 = s2(:,end)+feedrate_new*(1:N3)*Ts-1/2*accel_new*((1:N3)*Ts).^2;
        end
    else
        s3 = [];
    end
    s =[s1,s2,s3];
    path = p_start + s*dir;
end