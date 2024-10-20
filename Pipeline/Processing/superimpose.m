function [super_ROLL, super_ADC, super_EMG] = superimpose(blocks, channels, EMG, roll, ADC, ext, Ind_ADC)

    super_EMG = cell(channels, 2);
    super_ROLL = cell(channels, 2);
    super_ADC = cell(1, 2);
 

    %% MIP
    for i = 1:channels
        super_EMG_channel = zeros(9, 2*ext+1);
        super_channel = zeros(9, 2*ext+1);
        super_ADC_channel = zeros(9, 2*ext+1);
        disp_idx= fix((Ind_ADC{1,1}(1)+Ind_ADC{1,2}(1)) / 2) - Ind_ADC{1,1}(1);

        % Loop Through 9 sections with similar MIP on one channel
        for j = 1:blocks/2
            for p = 1:3
                mid = Ind_ADC{j,1}(p) + disp_idx;
                this_EMG = EMG{j}(i, mid-ext:mid+ext); % EMG
                super_EMG_channel((j-1)*3+p, :) = this_EMG;
                this_roll = roll{j}(i, mid-ext:mid+ext);% Rolling
                super_channel((j-1)*3+p, :) = this_roll;
                this_ADC = ADC{j}(2, mid-ext:mid+ext); % ADC
                super_ADC_channel((j-1)*3+p, :) = this_ADC;
            end
        end

        super_EMG{i, 1}         = super_EMG_channel;
        super_ROLL{i, 1}        = super_channel;
        super_ADC{1, 1}         = super_ADC_channel;

    end


    %% MEP
    for i = 1:channels
        super_EMG_channel = zeros(9, 2*ext+1);
        super_channel = zeros(9, 2*ext+1);
        super_ADC_channel = zeros(9, 2*ext+1);
        disp_idx= fix((Ind_ADC{4,1}(1)+Ind_ADC{4,2}(1)) / 2) - Ind_ADC{4,1}(1);

        % Loop Through 9 sections with similar MIP on one channel
        for j = 1:blocks/2
            for p = 1:3
                mid = Ind_ADC{j+3,1}(p) + disp_idx;
                this_EMG = EMG{j+3}(i, mid-ext:mid+ext); % EMG
                super_EMG_channel((j-1)*3+p, :) = this_EMG;
                this_roll = roll{j+3}(i, mid-ext:mid+ext);% Rolling
                super_channel((j-1)*3+p, :) = this_roll;
                this_ADC = ADC{j+3}(2, mid-ext:mid+ext); % ADC
                super_ADC_channel((j-1)*3+p, :) = this_ADC;

            end
        end

        super_EMG{i, 2}         = super_EMG_channel;
        super_ROLL{i, 2}        = super_channel;
        super_ADC{1, 2}         = super_ADC_channel;

    end

end

