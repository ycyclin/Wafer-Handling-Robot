function [t_ref, x_ref, v_ref, a_ref, j_ref] = linear_motion(dist, v_lim, a_lim, j_lim, Ts, plot_result)

if nargin < 6
    plot_result = 0;
end
if nargin < 5
    Ts = 1e-3;
end

S = dist;
V = v_lim;
A = a_lim;
J = j_lim;

%% Modify the kinematic limits to satisfy (V/A >= A/J) && (S/V >= V/A + A/J)
if (V/A < A/J)
    A = sqrt(V*J);
end

if (S/V < V/A + A/J)
    V = 1/2 * (-A^2/J + sqrt(A^4/J^2 + 4*A*S));
    if (V/A < A/J)
        A = (S*J^2/2)^(1/3);
        V = A^2/J;
    end
end

if V ~= v_lim
    disp(['Velocity reduced from ',num2str(v_lim),' to ',num2str(V),'.']);
end
if A ~= a_lim
    disp(['Acceleration reduced from ',num2str(a_lim),' to ',num2str(A),'.']);
end

% Slightly reduce V, A, and J to ensure end position is reached
T_total = S/V + V/A + A/J;
T_adj = (T_total/Ts) / ceil(T_total/Ts);
V = V * T_adj;
A = A * T_adj^2;
J = J * T_adj^3;

%% Time stamps / spans for each segment
T1 = A/J;
T2 = V/A;
T3 = V/A + A/J;
T4 = S/V;
T5 = S/V + A/J;
T6 = S/V + V/A;
T7 = S/V + V/A + A/J;

T01 = T1;
T12 = T2 - T1;
T23 = T3 - T2;
T34 = T4 - T3;
T45 = T5 - T4;
T56 = T6 - T5;
T67 = T7 - T6;

time = 0:Ts:T7;

%% Position, velocity, and accleration at end time of the segement
J1 =     J;
A1 =     J1*T01;
V1 = 1/2*J1*T01^2;
S1 = 1/6*J1*T01^3;

J2 =     0;
A2 =     J2*T12   +     A1;
V2 = 1/2*J2*T12^2 +     A1*T12   + V1;
S2 = 1/6*J2*T12^3 + 1/2*A1*T12^2 + V1*T12 + S1;

J3 =    -J;
A3 =     J3*T23   +     A2;
V3 = 1/2*J3*T23^2 +     A2*T23   + V2;
S3 = 1/6*J3*T23^3 + 1/2*A2*T23^2 + V2*T23 + S2;

J4 =     0;
A4 =     J4*T34   +     A3;
V4 = 1/2*J4*T34^2 +     A3*T34   + V3;
S4 = 1/6*J4*T34^3 + 1/2*A3*T34^2 + V3*T34 + S3;

J5 =    -J;
A5 =     J5*T45   +     A4;
V5 = 1/2*J5*T45^2 +     A4*T45   + V4;
S5 = 1/6*J5*T45^3 + 1/2*A4*T45^2 + V4*T45 + S4;

J6 =     0;
A6 =     J6*T56   +     A5;
V6 = 1/2*J6*T56^2 +     A5*T56   + V5;
S6 = 1/6*J6*T56^3 + 1/2*A5*T56^2 + V5*T56 + S5;

J7 =     J;
A7 =     J7*T67   +     A6;
V7 = 1/2*J7*T67^2 +     A6*T67   + V6;
S7 = 1/6*J7*T67^3 + 1/2*A6*T67^2 + V6*T67 + S6;

%% discret positino of each time step
time1 = time( find((time <= T1)) );
J01 =     J * ones(size(time1));
A01 =     J1*time1;
V01 = 1/2*J1*time1.^2;
S01 = 1/6*J1*time1.^3;

time2 = time( find((time > T1) .* (time <= T2)) ) - T1;
J12 =     0 * ones(size(time2));
A12 =     J2*time2    +     A1;
V12 = 1/2*J2*time2.^2 +     A1*time2    + V1;
S12 = 1/6*J2*time2.^3 + 1/2*A1*time2.^2 + V1*time2 + S1;

time3 = time( find((time > T2) .* (time <= T3)) ) - T2;
J23 =    -J * ones(size(time3));
A23 =     J3*time3    +     A2;
V23 = 1/2*J3*time3.^2 +     A2*time3    + V2;
S23 = 1/6*J3*time3.^3 + 1/2*A2*time3.^2 + V2*time3 + S2;

time4 = time( find((time > T3) .* (time <= T4)) ) - T3;
J34 =     0 * ones(size(time4));
A34 =     J4*time4    +     A3;
V34 = 1/2*J4*time4.^2 +     A3*time4    + V3;
S34 = 1/6*J4*time4.^3 + 1/2*A3*time4.^2 + V3*time4 + S3;

time5 = time( find((time > T4) .* (time <= T5)) ) - T4;
J45 =    -J * ones(size(time5));
A45 =     J5*time5    +     A4;
V45 = 1/2*J5*time5.^2 +     A4*time5    + V4;
S45 = 1/6*J5*time5.^3 + 1/2*A4*time5.^2 + V4*time5 + S4;

time6 = time( find((time > T5) .* (time <= T6)) ) - T5;
J56 =     0 * ones(size(time6));
A56 =     J6*time6    +     A5;
V56 = 1/2*J6*time6.^2 +     A5*time6    + V5;
S56 = 1/6*J6*time6.^3 + 1/2*A5*time6.^2 + V5*time6 + S5;

time7 = time( find((time > T6)) ) - T6;
J67 =     J * ones(size(time7));
A67 =     J7*time7    +     A6;
V67 = 1/2*J7*time7.^2 +     A6*time7    + V6;
S67 = 1/6*J7*time7.^3 + 1/2*A6*time7.^2 + V6*time7 + S6;


%% Combine and return sequences
t_ref = time;
x_ref = [S01, S12, S23, S34, S45, S56, S67];
v_ref = gradient(x_ref, Ts);
a_ref = gradient(v_ref, Ts);
j_ref = gradient(a_ref, Ts);

v_nom = [V01, V12, V23, V34, V45, V56, V67];
a_nom = [A01, A12, A23, A34, A45, A56, A67];
j_nom = [J01, J12, J23, J34, J45, J56, J67];

%% Plot to check
if plot_result == 1
    figure;
    set(gcf,'unit','normalized','position',[0.3,0.1,0.4,0.7])
    tiledlayout(4,1,'tilespacing','compact','padding','compact');
    nexttile(1);
    plot(t_ref, x_ref, '-', 'linewidth',2);
    grid on; grid minor; ylabel('Position','fontsize',12);
    nexttile(2);
    plot(t_ref, v_ref, '-', 'linewidth',2); hold on;
    plot(t_ref, v_nom, '--', 'linewidth',2);
    plot(t_ref,  v_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', "#EDB120");
    plot(t_ref, -v_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', "#EDB120");
    grid on; grid minor; ylabel('Velocity','fontsize',12);
    nexttile(3);
    plot(t_ref, a_ref, '-', 'linewidth',2); hold on;
    plot(t_ref, a_nom, '--', 'linewidth',2);
    plot(t_ref,  a_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', "#EDB120");
    plot(t_ref, -a_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', "#EDB120");
    grid on; grid minor; ylabel('Acceleration','fontsize',12);
    nexttile(4);
    plot(t_ref, j_ref, '-', 'linewidth',2); hold on;
    plot(t_ref, j_nom, '--', 'linewidth',2);
    plot(t_ref,  j_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', "#EDB120");
    plot(t_ref, -j_lim * ones(size(t_ref)), ':', 'linewidth',2, 'color', "#EDB120");
    grid on; grid minor; ylabel('Jerk','fontsize',12);
end

end
