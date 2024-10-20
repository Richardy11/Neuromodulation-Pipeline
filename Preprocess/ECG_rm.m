function all_ats = ECG_rm(EMG, channels, fs, fpl)

    addpath('ECG_rm_algo/filters/'); 
    addpath('ECG_rm_algo/ecg_utils'); 
    addpath('ECG_rm_algo/template_subtraction');
    use_filtfilt = true;
    all_ats = zeros(channels, length(EMG(1, :)));
    
    % range for ylim
    for i = 1:channels

        signal = EMG(i, :);
    
        % power line interference removal
        signal = butter_filt_stabilized(signal, [fpl-1 fpl+1], fs, 'stop', use_filtfilt, 2);
    
        % mild high-pass filtering (two versions, one for R peak detection and one for cardiac artifact removal) 
        % to remove baseline wander and some ECG interference (especially in the 20Hz version)
        signalhp05 = butter_filt_stabilized(signal, 5, fs, 'high', use_filtfilt, 6);
        signalhp20 = butter_filt_stabilized(signal, 20, fs, 'high', use_filtfilt, 6);
    
        % R peak detection, slightly modified version of Pan-Tompkins
        rpeaks = peak_detection(signalhp05, fs);
    
        % This is the actual cardiac artifact removal step
        cleaned_ats = adaptive_template_subtraction(signalhp20, rpeaks, fs);
        all_ats(i, :) = cleaned_ats;
    
    end

end

