function [signal] = digital_filt_stage(signal,glitch_length)
% ==========================Start=of=Documentation=========================
% Author    Chen Qian chq@umich.edu
% Last rev  Jul.24,2023
% @brief    For a signal, remove the digital glitch (like stages) near 
%           zero, for example:
%
%           [0 1 0 ], [0 1 1 0], [0 1 -1 0], etc.
%           [__/\__], [_/---\_], [__/\  __].
%                                     \/ 
%
% @input    signal          Digital signal need to be filtered.
% @input    glitch_length   The max length of glitch, for example, 
%                           [0 1 0 ], [0 1 1 0 ], [0 1 -1 0 ], ...
%                           [__/\__], [_/---\_ ], [__/\  __ ], ...
%                                                      \/ 
%                           len = 1 , len = 2   , len = 2
%                           The digital filter will remove all of 
%                           these glitches.
% @output   signal          Filtered signal.
% ===========================End=of=Documentation==========================
    for i = 1:glitch_length
        features = [0 ones(1,i) 0];
        stage_idx = strfind(signal~=0, features);
        for j = 1:i
            signal(stage_idx+j)=0;
        end
    end
end

