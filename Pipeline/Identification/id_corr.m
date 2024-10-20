function [start_ind, stop_ind, PCA_all_EMG, PCA_roll, PCA_adc, high, low] = id_corr(ROLL, ADC, EMG, threshold, principles, num_clusters, ext)

    % Run PCA and mean over the accepted channels
    outliers = PCA(ROLL, threshold, principles, num_clusters);
    PCA_all_EMG = EMG(outliers==0, :);
    PCA_roll = mean(ROLL(outliers==0, :), 1);
    PCA_adc = mean(ADC(outliers==0, :), 1);
    
    % Convert Envelope
    [hi, lo] = convert_Envelope(EMG(outliers==0, :));
    high = mean(hi, 1);
    low = mean(lo, 1);

    % Noramlize rolling std and ADC, find ADC start and stop index
    standard_roll = normalize(PCA_roll);
    standard_adc = normalize(PCA_adc);
    [start, stop] = id_ADC(standard_adc, 10);
    this_adc = abs(standard_adc(start-20000:stop+20000)); % I introduced some head and tail cause it works better after testing
    
    %% Run Rolling Correlation
    scalar = 0.8:0.02:1.2; % Stretching of the ADC
    maxCorr_list = zeros(1, length(scalar)); % List to store all maximum corr
    maxCorrStep_list = zeros(1, length(scalar)); % List to store all maximum corr index
    stretch_adc_list = cell(1, length(scalar));
    
    for j = 1:length(scalar)
        % Stretch the ADC
        original_id = 1:length(this_adc);
        new_id = linspace(1, length(this_adc), scalar(j)*length(this_adc));
        stretch_adc = interp1(original_id, this_adc, new_id);
        % Slide the window in steps of 100, calculate number of steps
        windowLength = length(stretch_adc);
        numSteps = floor((length(standard_roll) - windowLength) / 100) + 1;
        % Initialize an array to store the correlation coefficients
        correlations = zeros(1, numSteps);
    
        % Calculate the correlations
        for i = 1:numSteps
            index_1 = 1 + (i-1)*100;
            index_2 = index_1 + windowLength - 1;
    
            % Ensure the endIndex does not exceed the length of roll
            if index_2 > length(standard_roll)
                break;
            end
    
            segment = standard_roll(index_1:index_2);
            correlations(i) = corr(segment', stretch_adc');
        end
    
        % Find the index of maximum correlation
        [maxCorr, maxCorrStep] = max(correlations);
        maxCorr_list(j) = maxCorr;
        maxCorrStep_list(j) = maxCorrStep;
        stretch_adc_list{j} = stretch_adc;
    end
    
    % Find the scaling with the largest absolute correlation
    [max_scale_size, max_scale_id] = max(maxCorr_list);
    maxCorrStep = maxCorrStep_list(max_scale_id);
    stretch_adc = stretch_adc_list{max_scale_id};
    % Calculate the start and end indices
    [start, stop] = id_ADC(stretch_adc, 10);
    start_ind = 1 + (maxCorrStep-1)*100 + start;
    stop_ind = 1 + (maxCorrStep-1)*100 + stop;
    mid_ind = (start_ind + stop_ind) / 2;
    if max_scale_size < 0.8 || (mid_ind < ext*3/5) || (mid_ind > ext*7/5)
        start_ind = 0;
        stop_ind = 0;
    end
    
    % Adjust indices if they fall outside the bounds of roll
    start_ind = max(start_ind, 1);
    stop_ind = min(stop_ind, length(standard_roll));

end
