function normalized = normalize_ADC(ADC)
    % Assume ADC is your data vector
    n = length(ADC); % Get the number of data points
    
    % Calculate the slope of the line
    slope = (ADC(end) - ADC(1)) / (n - 1);
    
    % Create the adjustment line
    adjustment_line = ADC(1) + slope * (0:(n-1));
    
    % Normalize the data by subtracting the adjustment line
    normalized = ADC - adjustment_line;
    
    % Optionally, ensure the start and end points are exactly zero
    normalized(1) = 0;
    normalized(end) = 0;

end