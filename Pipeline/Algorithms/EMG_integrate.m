function avg = EMG_integrate(EMG_all, start_idx, end_idx)

    inte_list = zeros(length(EMG_all(:, 1)), 1);
    % ramp_up_list = zeros(9, 1);
    % ramp_down_list = zeros(9, 1);
    for i = 1:length(EMG_all(:, 1))
        EMG = abs(EMG_all(i, :));
        % EMG = EMG_all(i, :);
        inte = trapz(EMG(start_idx:end_idx));
        inte_list(i) = inte;
        % ramp_up_list(i) = (EMG(round((start_idx + end_idx)/2)) - EMG(start_idx)) / (end_idx-start_idx);
        % ramp_down_list(i) = (EMG(end_idx) - EMG(round((start_idx + end_idx)/2))) / (end_idx-start_idx);
    end
    avg = mean(inte_list);

end

