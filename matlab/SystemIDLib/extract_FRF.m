function [HX1,HX2] = extract_FRF(cmd_signal,measure_signal_main,measure_signal_para,Ts,freq_range,noise_threshold)
% ==========================Start=of=Documentation=========================
% Author    Chen Qian chq@umich.edu
% Last rev  Jul.18,2023
% @brief                Get the FRF signals with input signal and measured
%                       signal. (!!!!!Warning!!!!!) The signal should in
%                       same unit!!! Don't provide input signal in position
%                       and then measured signals in acceleration!!!
%                       Instead, digital differentiate it and then
%                       proceed.
% @input    cmd_signal           Command signal (input signal)
% @input    measure_signal_main  Main measured signal with obvious amplitude.
% @input    measure_signal_para  Parasite measured signal (on another direction).
%                       The unit should be same to measure_signal_main.
% @input    Ts                   Sampling time, in seconds.
% @input    freq_range           System ID frequency range.
% @input    noise_threshold      Threshold for aligning the input and outuput data.
% @output   HX1,HX2              Response function in two directions.
% ===========================End=of=Documentation==========================

%%%%%%%%%%%% Begin of internal parameters %%%%%%%%%%%%
% Plot the cropped signals for each frequency
enable_crop_plot = false;
% Plot the input and output signal to check if they are aligned
enable_align_plot = false;
%%%%%%%%%%%%% End of internal parameters %%%%%%%%%%%%%
% align and crop the data
start_idx = strfind([0;abs(measure_signal_main)>noise_threshold]',[1 1 1 1 1 1 1 1]);
start_idx = start_idx(1);
measure_signal_main = measure_signal_main(start_idx:end);
% Searching for the start index

% Trim parasite signal to the same length
measure_signal_para = measure_signal_para((length(measure_signal_para)-length(measure_signal_main)):end);

% Trim command signal to the start.
% Since command signal does not have noise, we simply trim it with
% threshold.
delay_input= find(abs(cmd_signal)>noise_threshold,1);
cmd_signal = cmd_signal(delay_input:end);

% Trim all three signals to the same length.
min_length = min([length(measure_signal_main),length(cmd_signal),length(measure_signal_para)]);
measure_signal_main = measure_signal_main(1:min_length);
measure_signal_para = measure_signal_para(1:min_length);
cmd_signal = cmd_signal(1:min_length);

% Sign of the signal. 1 for x>0;0 for x=0; -1 for x<0. Used for extract the
% sine portion.
sign_indicator = ((cmd_signal'>0)*3+(cmd_signal'<0)*1+(cmd_signal'==0)*2-2);
% Digital filter, filt the glitch of the signs indicator.
sign_indicator = digital_filter_hollow(sign_indicator,8);

rise_idx = strfind(sign_indicator,[-1 -1 -1 -1 1 1 1 1])+4;

% Extract the cyclical sine signal.
sine_end_idx = [rise_idx(diff(diff(rise_idx))>10) rise_idx(end)]+1;
sine_start_idx = [rise_idx(1) rise_idx(find(diff(diff(rise_idx))<-10)+1)]+1;

if(enable_align_plot)
    if(enable_crop_plot)
        subplot(211)
    end
    plot(cmd_signal)
    hold on
    plot(measure_signal_main)
    plot(measure_signal_para)
    hold off
    if(enable_crop_plot)
        subplot(212)
    end
end

if(enable_crop_plot)
    for i = 1:length(sine_start_idx)
        plot(cmd_signal(sine_start_idx(i):sine_end_idx(i)))
        hold on
        plot(measure_signal_main(sine_start_idx(i):sine_end_idx(i)))
        plot(measure_signal_para(sine_start_idx(i):sine_end_idx(i)))
        xlim([0,sine_end_idx(i)-sine_start_idx(i)])
        ylim([min(measure_signal_main),max(measure_signal_main)])
        hold off
        pause(0.1)
        drawnow
    end
end

% The start and end of sine signal has been extracted. Now we need to do
% dft. We use arrayfun for faster speed.
% Reshape the indexes to column
sine_start_idx = reshape(sine_start_idx,[],1);
sine_end_idx = reshape(sine_end_idx,[],1);
freq_range = reshape(freq_range,[],1);

% Wrap indexes into cells for arrayfun. First array is start indexes,
% second is end, third is frequency.
dft_data = num2cell([sine_start_idx sine_end_idx freq_range],2);
HX1 = arrayfun(@(dft_data_cell) dft(cmd_signal(dft_data_cell{1}(1):dft_data_cell{1}(2)), ...
                              measure_signal_main(dft_data_cell{1}(1):dft_data_cell{1}(2)),...
                              dft_data_cell{1}(3),Ts), dft_data);
HX2 = arrayfun(@(dft_data_cell) dft(cmd_signal(dft_data_cell{1}(1):dft_data_cell{1}(2)), ...
                              measure_signal_para(dft_data_cell{1}(1):dft_data_cell{1}(2)),...
                              dft_data_cell{1}(3),Ts), dft_data);
end

function response = dft(input,output,freq,Ts)
% ==========================Start=of=Documentation=========================
% @brief  Encapsuled version of DFT
% @input  input     Input signal u.
% @input  output    Output signal y.
% @input  freq      The sine signal frequency.
% @input  Ts        Sampling time of signal.
% @output response  The complex number, indicate the magnitude and phase
%                   delay of the system at the given frequency.
% ===========================End=of=Documentation==========================
    fs = 1/Ts;
    L = length(input);
    NFFT = L;
    in_fft = fft(input,NFFT)/length(output); % input
    in_fft = in_fft(1:floor(NFFT/2+1));

    out_fft = fft(output,NFFT)/length(output); % output
    out_fft = out_fft(1:floor(NFFT/2+1));
    
    f_fft = fs/2*linspace(0,1,NFFT/2+1);
    f_fft = f_fft';
    fPt = find(abs(freq - f_fft) == min(abs(freq - f_fft)));
    response = out_fft(fPt)/in_fft(fPt);
end

function signal = digital_filter_hollow(signal, hollow_length)
% ==========================Start=of=Documentation=========================
% @brief    For a signal, remove the digital glitch (like hollow) near 
%           1 or -1, for example:
%
%           [1 0 1 ], [-1 0 0 1], [-1 0 -1 ], etc.
%
%           [__  __]  [      _ ], [        ]
%           [  \/  ], [   __/  ], [        ], etc.
%           [      ]  [ _/     ], [___/\___]
%
% @input    signal          Digital signal need to be filtered.
% @input    glitch_length   The max length of glitch, for example, 
%                           [1 0 1 ], [1 0 0 1 ],
%                           [--\/--], [-\___/- ],
%                           len = 1 , len = 2   
%                           The digital filter will remove all of 
%                           these glitches.
% @output   signal          Filtered signal.
% ===========================End=of=Documentation==========================
    for i = 1:hollow_length
        features = [0 ones(1,i) 0];
        stage_idx = strfind(signal, features);
        for j = 1:i
            signal(stage_idx+j)=0;
        end
        features = features - 1; % [-1 0 ... 0 -1]
        stage_idx = strfind(signal, features);
        for j = 1:i
            signal(stage_idx+j)=-1;
        end
        features = -features; % [1 0 ... 0 1]
        stage_idx = strfind(signal, features);
        for j = 1:i
            signal(stage_idx+j)=1;
        end

        features = 2*features-1; % [1 -1 ... -1 1]
        stage_idx = strfind(signal, features);
        for j = 1:i
            signal(stage_idx+j)=1;
        end
        
        features = -features; % [-1 1 ... 1 -1]
        stage_idx = strfind(signal, features);
        for j = 1:i
            signal(stage_idx+j)=-1;
        end

        features = [-1 zeros(1,i) 1]; %[-1 0 ... 0 1]
        stage_idx = strfind(signal, features);
        for j = 1:floor(i/2)
            signal(stage_idx+j)=-1;
        end
        for j = ceil(i/2):i
            signal(stage_idx+j)=1;
        end

        features = -features; %[1 0 ... 0 -1]
        stage_idx = strfind(signal, features);
        for j = 1:floor(i/2)
            signal(stage_idx+j)=1;
        end
        for j = ceil(i/2):i
            signal(stage_idx+j)=-1;
        end
    end
end