function N0 = Generate_B_Spline_Matrix(x_ref, m, CtrlPntFs, Ts)

if nargin < 4
    Ts = 1e-3;
end
if nargin < 3
    CtrlPntFs = 1/(10*Ts);
end
if nargin < 2
    m = 5;
end

KnotL = round(1/Ts/CtrlPntFs);              % Knot vector spacing: number of timesteps per control point
Eb = ceil((length(x_ref)-1)/KnotL)*KnotL;   % Number of discrete position in B-spline matrix - 1
n = (ceil(Eb/KnotL)-1) + m;                 % Number of control points in B-spline matrix - 1

u = linspace(0,1,Eb+1);                             % Tested time steps
Gp = [zeros(1,m) linspace(0,1,n-m+2) ones(1,m)];    % Knot vector for position

span_p = findspan (n, m, u, Gp);    % knot_span_idx = findspan(num_cp-1, degree, timesteps, knot_vec)  
Bp = basisfun (span_p, u, m, Gp);   % Basisfunc_vec = findspan(knot_span_idx, timesteps, degree, knot_vec)  

% N0 is B-spline basis function matrix
N0 = zeros(length(u),n+1);
ic = span_p(1);
for i = 1:length(u)
    coml = span_p(i)-ic+1;
    N0(i,coml:coml+m) = Bp(i,:);
end

end
