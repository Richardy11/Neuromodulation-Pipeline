function identity = ADC2_identify(signal, Ind_1, Ind_2, type)
    % Case when input is EMG, calculate energy
    if type == 1
        total = trapz(power(signal, 2));
        high = trapz(power(signal(Ind_1:Ind_2), 2));
        
    % Case when input is ADC, calculate area
    elseif type == 2
        total = trapz(signal, 2);
        high = trapz(signal(Ind_1:Ind_2));
    end
    percentage = round(high/total*100);
identity = percentage;
end

