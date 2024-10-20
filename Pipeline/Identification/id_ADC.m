function [start, stop] = id_ADC(ADC, cutoff)

    temp = abs(ADC);
    temp(temp>(max(temp)/cutoff)) = 100;
    temp(temp~=100) = 0;
    b = diff(temp);
    start = (find(b==100));
    if length(start) > 1
        start = start(1);
    end
    
    stop = (find(b==-100));
    if length(stop) > 1
        stop = stop(end);
    end

end

