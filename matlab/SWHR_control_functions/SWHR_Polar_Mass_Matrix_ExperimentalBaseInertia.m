function Ms = SWHR_Polar_Mass_Matrix_ExperimentalBaseInertia(angles, SWHR_Parameters, Exp_Parameters, with_wafer)

if nargin <= 3
    with_wafer = 0;
end

% global m1 m2 m3 m4 m5 m_wafer I1 I2 I3 I4 I5 I_wafer
m2 = SWHR_Parameters.m2;
m4 = SWHR_Parameters.m4;
m5 = SWHR_Parameters.m5;
I2 = SWHR_Parameters.I2;
I4 = SWHR_Parameters.I4;
I5 = SWHR_Parameters.I5;
m_wafer = SWHR_Parameters.m_wafer;
I_wafer = SWHR_Parameters.I_wafer;

I1_0 = Exp_Parameters.I1;
I3_0 = Exp_Parameters.I3;

%%
mmI2 = diag([m2, m2, I2]);
mmI4 = diag([m4, m4, I4]);
mmI5 = diag([m5, m5, I5]);
mmIw = diag([m_wafer, m_wafer, I_wafer]);
[~, J2s, ~, J4s, J5s, Jws, ~] = SWHR_Polar_Jacobian_links_wafer_and_accelerometer(angles, SWHR_Parameters); % unit: [rad]-->[m]

M1 = [I1_0, I1_0;
      I1_0, I1_0];
M3 = [ I3_0, -I3_0;
      -I3_0,  I3_0];

Ms = nan(2,2,length(angles));

for k = 1:length(angles)
    Ms(:,:,k) = M1 + M3 + ...
                transpose(J2s(:,:,k)) * mmI2 * J2s(:,:,k) + ...
                transpose(J4s(:,:,k)) * mmI4 * J4s(:,:,k) + ...
                transpose(J5s(:,:,k)) * mmI5 * J5s(:,:,k);
    
    if with_wafer == 1
        Ms(:,:,k) = Ms(:,:,k) + transpose(Jws(:,:,k)) * mmIw * Jws(:,:,k);
    end
end
    
end