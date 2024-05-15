function [output_signal] = remove_glitch(input_signal,magnitude_threshold,duation_theshold)
potential_glitch_idx = abs(input_signal)<magnitude_threshold;
find(diff(potential_glitch_idx)==1)
end

