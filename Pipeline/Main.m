%% Setup
clc;
clear;
addpath("Processing\")
addpath("Identification\")
addpath("Algorithms\")

% This variable should follow the structure of: 
% Name of file, blocks(MIP MEP), Before stim of After stim
all_files = {   '20220720_KL-11_RespEMG.mat' [6  7  8  2  3  4] 'Before';    
                '20220601_KL-11_RespEMG.mat' [11 12 13 5  6  7] 'After';    
                
                };


%% Pipeline
tot_files = size(all_files, 1);
for tot = 1:tot_files

    % Load Data
    filepath = (['..\Preprocess\result_data\' all_files{tot, 3} '\' all_files{tot, 1}]);
    savepath = (['Results\' all_files{tot, 3} '\' all_files{tot, 1}]);
    this_file = load(filepath);
    EMG = this_file.EMG;
    ADC = this_file.ADC;
    ROLL = this_file.ROLL;

    Ind_ADC = cell(6,2); % Indices where respiration starts/ends
    abs_ADC = cell(6,1);
    for i = 1:6
        abs_ADC{i} = abs(ADC{i});
    end
    
    % Thresholding to find when ADC starts
    for i = 1:6
        for j = 1:2
            temp = abs_ADC{i}(j,:);
            temp(temp>(max(temp)/10)) = 100;
            temp(temp~=100) = 0;
            abs_ADC{i}(j,:) = temp;
        end
    end
    for i =1:6
        a = abs_ADC{i}(2,:);
        b = diff(a);
        b1 =(find(b==100));
        b2 = (find(b==-100));
        c = b2-b1;
        [d,e]=sort(c);
        Ind = sort(e(end-2:end));
        for t = 1:3
            On(t) = b1(Ind(t));
            Off(t) = b2(Ind(t));
        end
        Ind_ADC{i,1} = On;
        Ind_ADC{i,2} = Off;
    end
    
    % Data Proccesing
    fprintf('Trial %d\n', tot)
    Raw_EMG_ADC(EMG, ROLL, ADC, Ind_ADC, savepath);
    fprintf('\n')

end
