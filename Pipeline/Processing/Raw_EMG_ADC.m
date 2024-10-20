function Raw_EMG_ADC(EMG, roll, ADC, Ind_ADC, savepath)

    labels ={'RTransDia','LTransDia','RIntercostal','LIntercostal','RTrap','LTrap','RAbdominal','LAbdominal','Thoracic'};
    ext = 24414*5;

    %% Superimpose Analysis
    [super_ROLL, super_ADC, super_EMG] = ...
        superimpose(length(EMG), size(EMG{1},1), EMG, roll, ADC, ext, Ind_ADC);

    %% Data Extraction
    extraction(length(EMG), size(EMG{1},1), ...
        EMG, roll, ADC, ext, Ind_ADC, super_ROLL, super_ADC, super_EMG, labels, savepath);

end