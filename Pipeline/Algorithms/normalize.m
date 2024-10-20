function normalized = normalize(EMG)
% This is for Correlation. Normalize the data based on start/end points

start = EMG(:, 1);
stop = EMG(:, length(EMG(1, :)));

line = zeros(length(EMG(:, 1)), length(EMG(1, :)));
for i = 1:length(EMG(:, 1))
    line(i, :) = linspace(start(i), stop(i), length(EMG(1, :)));
end

normalized = EMG - line;

end

