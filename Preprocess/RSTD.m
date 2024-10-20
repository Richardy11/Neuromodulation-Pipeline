function all_roll = RSTD(EMG, channels)

    % Rolling Standard Deviation
    all_roll = [];

    for i = 1:channels

        a = EMG(i, :);
        window = length(a)/100;
        all_roll(i, :) = movstd(a, window);

    end

end