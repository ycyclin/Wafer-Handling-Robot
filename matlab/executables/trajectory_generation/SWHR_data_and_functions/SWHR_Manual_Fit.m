function Params_Fitted = SWHR_Manual_Fit(G, freq, M, distance)    
    omega_range = 2*pi*freq;
    
    [Mag_pk, idx_pk] = max(abs(G));
    omega_pk = omega_range(idx_pk);
    
    a1_11 = sqrt( omega_pk(1)^2 / (Mag_pk(1)^2 - 1) );
    b11 = a1_11 * M(1,1);
    k11 = omega_pk(1)^2 * M(1,1);
    
    a1_22 = sqrt( omega_pk(4)^2 / (Mag_pk(4)^2 - 1) );
    b22 = a1_22 * M(2,2);
    k22 = omega_pk(4)^2 * M(2,2);
    
    b_avg = mean([b11, b22]);
    k_avg = mean([k11, k22]);
    
    %% Return Values
    distance = distance * 1e3;
    Params_Fitted = table(distance, k_avg, b_avg, k11, b11, k22, b22);
    
    %% Reconstruct TF and plot to check
    %{
    TF_11b = [   0,   b11, k11];
    TF_11a = [M(1,1), b11, k11];    
    TF_11 = tf(TF_11b, TF_11a);
        
    TF_22b = [   0,   b22, k22];
    TF_22a = [M(2,2), b22, k22];    
    TF_22 = tf(TF_22b, TF_22a);
    
    TF_avg_11b = [   0,   b_avg, k_avg];
    TF_avg_11a = [M(1,1), b_avg, k_avg];    
    TF_avg_11 = tf(TF_avg_11b, TF_avg_11a);
        
    TF_avg_22b = [   0,   b_avg, k_avg];
    TF_avg_22a = [M(2,2), b_avg, k_avg];    
    TF_avg_22 = tf(TF_avg_22b, TF_avg_22a);
    
    % Plot to check
    [H_fit_11,~] = freqresp(TF_11, omega_range);
    [H_fit_22,~] = freqresp(TF_22, omega_range);
    [H_avg_11,~] = freqresp(TF_avg_11, omega_range);
    [H_avg_22,~] = freqresp(TF_avg_22, omega_range);
    H_fit_11 = squeeze(H_fit_11);
    H_fit_22 = squeeze(H_fit_22);
    H_avg_11 = squeeze(H_avg_11);
    H_avg_22 = squeeze(H_avg_22);
    
    figure(500);
    subplot(211)
    semilogx(freq, mag2db(abs(G(:,1))),'-','linewidth',2); hold on;
    semilogx(freq, mag2db(abs(H_fit_11)),':','linewidth',2);
    semilogx(freq, mag2db(abs(H_avg_11)),'--','linewidth',2); hold off;
    subplot(212)
    semilogx(freq, mag2db(abs(G(:,4))),'-','linewidth',2); hold on;
    semilogx(freq, mag2db(abs(H_fit_22)),':','linewidth',2);
    semilogx(freq, mag2db(abs(H_avg_22)),'--','linewidth',2); hold off;
    %}
    
end