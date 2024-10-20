%% Setup
clear
warning('off')
addpath("ECG_rm_algo\")

% This variable should follow the structure of: 
% Name of file, blocks(MIP MEP), Before stim or After stim or Control
all_files = {   '20220720_KL-11_RespEMG.mat' [6  7  8  2  3  4] 'Before';    
                '20220601_KL-11_RespEMG.mat' [11 12 13 5  6  7] 'After';    
                
                };

tot_channels = 9; % Total number of muscles
fs = 24414; % Sampling frequency for data 
fpl = 50;  % fpl is powerline frequency (typically 50Hz or 60Hz)


%% Processing
% Loop through all files
tot_files = size(all_files, 1);
for t = 1:tot_files

    blockNum = all_files{t, 2};
    [ADC, EMG, ROLL] = deal(cell(length(blockNum), 1));
    filepath = (['raw_data\' all_files{t, 1}]);
    savepath = (['result_data\' all_files{t, 3} '\' all_files{t, 1}]);
    this_file = load(filepath);

    for i = 1:length(blockNum)
        % Convert to correct format
        block_name = sprintf('this_file.Block%d', blockNum(i));
        data = eval(block_name);
        str = data.streams;
        adc = str.ADC_.data;
        emg = str.Cont.data;
        Muscle_sampling_rate = data.streams.HnGr.fs;

        % Normalize first second EMG to 0 to remove artifact
        emg(:, 1:fs) = 0;
        
        % Do ECG removal
        emg_no_ecg_1 = ECG_rm(emg(1:tot_channels, :), tot_channels, fs, fpl);
        emg_no_ecg_2 = ECG_rm(emg_no_ecg_1, tot_channels, fs, fpl);
    
        % Find Rolling STD
        roll = RSTD(emg_no_ecg_2, tot_channels);

        ADC{i} = adc;
        EMG{i} = emg_no_ecg_2;
        ROLL{i} = roll;
    end
    
    % Saving
    save(savepath, "ADC", "EMG", "ROLL")

end



