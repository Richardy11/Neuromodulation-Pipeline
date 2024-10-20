function [high, low] = convert_Envelope(EMG)
    row = length(EMG(1, :));
    col = length(EMG(:, 1));
    high = zeros(col, row);
    low = zeros(col, row);
    for i = 1:col
      [hi, lo] = envelope(EMG(i, :), 1000, 'peak');
      high(i, :) = hi;
      low(i, :) = lo;
    end
end

