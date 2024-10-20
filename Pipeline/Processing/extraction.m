function extraction(blocks, channels, EMG, roll, ADC, ext, ...
    Ind_ADC, super_ROLL, super_ADC, super_EMG, labels, filepath_save)

    EMG_all = super_EMG;
    ADC_all = super_ADC;
    EMG_all_PCA = cell(9, 2);
    index_start_list = zeros(9, 2);
    index_end_list = zeros(9, 2);

    %% Find Min/Max
    y_ran = cell(10,3);
    ymin = zeros(10,1);
    ymax = zeros(10,1);
    y_all_min = zeros(blocks,1);
    y_all_max = zeros(blocks,1);
     
    for j = 1:blocks
        % range for ylim
        for i = 1:channels
            for p = 1:3
                ymin = min(roll{j}(i,Ind_ADC{j,1}(p)-ext:Ind_ADC{j,2}(p)+ext));
                ymax = max(roll{j}(i,Ind_ADC{j,1}(p)-ext:Ind_ADC{j,2}(p)+ext));
                y_ran{i,p} = [ymin ymax];
            end
        end
        for p = 1:3
            y_ran{10,2*p} = [min(ADC{j}(2,Ind_ADC{j,1}(p)-ext:Ind_ADC{j,2}(p)+ext)) max(ADC{j}(2,Ind_ADC{j,1}(p)-ext:Ind_ADC{j,2}(p)+ext))];
        end
        for k = 1:10
            ymin(k,1) = min([y_ran{k,1} y_ran{k,2} y_ran{k,3}]);
            ymax(k,1) = max([y_ran{k,1} y_ran{k,2} y_ran{k,3}]);
        end
        for i = 1:10
            y_all_min(1:9, 1) = min(ymin(1:9, 1));
            y_all_max(1:9, 1) = max(ymax(1:9, 1));
        end
    end


    %% MIP
    disp('MIP Start')
    % Data Variables
    EMG_amp_max = zeros(9, 1);
    raw_ADC_max = zeros(9, 1);
    raw_ADC_area = zeros(9, 1);
    ADC_start = zeros(9, 1);
    ADC_stop = zeros(9, 1);
    ADC_max = zeros(9, 1);
    ADC_area = zeros(9, 1);

    % figure
    for abc = 1:1
        ADC = super_ADC{1, abc};
        for i = 1:channels
            ROLL = super_ROLL{i, abc};
            EMG = super_EMG{i, abc};
            [start_idx, end_idx, all_EMG, mean_ROLL, mean_ADC, high, low] = id_corr(ROLL, ADC, EMG, 3.1, 2, 4, ext);
            EMG_all_PCA{i, abc} = all_EMG;
            index_start_list(i, abc) = start_idx;
            index_end_list(i, abc) = end_idx;
            % s = subplot(10, 3, (i-1)*3+abc);
            % hold on;
            % plot(mean_ROLL, "LineWidth", 1.5);
            if start_idx + end_idx ~= 0
                % scatter(start_idx:end_idx, mean_ROLL(start_idx:end_idx), 10,"red", "filled")
                EMG_high = mean(high(start_idx: end_idx));
                EMG_low = mean(low(start_idx: end_idx));
                EMG_max = max(abs([EMG_high, EMG_low]));
            else
                EMG_max = 0;
            end
            % xs = length(mean_ROLL);
            % axis tight;
            % set(s,'xtick',(0:24414:xs),'xticklabel',(0:1:ceil(xs./24414)),'ylim',([y_all_min(i,1) y_all_max(i,1)]));
            % set(gca,"FontSize", 8)

            mean_ADC = normalize_ADC(mean_ADC);
            [ADC_start_idx, ADC_stop_idx] = id_ADC(mean_ADC, 10);
            EMG_amp_max(i, abc) = EMG_max;
            ADC_start(i, abc) = ADC_start_idx;
            ADC_stop(i, abc) = ADC_stop_idx;
            ADC_max(i, abc) = max(abs(mean_ADC));
            ADC_area(i, abc) = EMG_integrate(mean_ADC, ADC_start, ADC_stop);
            
            fprintf(' - Muscle %d done\n', i)        
        end

        for j = 1:9
            raw_ADC_max(j, abc) = max(abs(ADC(j, :)));
            [ADC_start_idx, ADC_stop_idx] = id_ADC(ADC(j, :), 10);
            raw_ADC_area(j, abc) = EMG_integrate(ADC(j, :), ADC_start_idx, ADC_stop_idx);
        end

        % s = subplot(10, 3, 27+abc);
        % hold on;
        % plot(mean_ADC, "LineWidth", 1.5)
        % xs = length(super_ADC{1, abc}(1, :));
        % axis tight;
        % set(s,'xtick',(0:24414:xs),'xticklabel',(0:1:ceil(xs./24414)));
        % set(gca,"FontSize", 8)
        % hold on;

    end

    % % Annotation
    % ba = ["Before", "After", "Control"];
    % for o = 1:3
    %     a = annotation('textbox',[0.21+0.285*(o-1) 0.92 .05 .05],'String',sprintf(ba{o}),'FitBoxToText','on','EdgeColor','none');
    %     a.FontSize = 14;
    % end
    % for o = 1:9
    %     b = annotation('textbox',[0.01 0.9425-0.0845*o .05 .05],'String',sprintf(labels{o}),'FitBoxToText','on','EdgeColor','none');
    %     b.FontSize = 11;
    % end
    % 
    % % Graph
    % set(gcf,'Units','centimeters','Position',[0 0 40 23])
    % exportgraphics(gcf, [filepath_save '\MIP.png'],"Resolution",600);

    % Data
    mykeys = ["EMG_Amplitude_Max", "raw_ADC_max", "raw_ADC_area" ...
              "ADC_start_point", "ADC_end_point", "ADC_max", "ADC_area"];
    myvalues = {EMG_amp_max, raw_ADC_max, raw_ADC_area, ADC_start, ADC_stop, ADC_max, ADC_area};
    MIP = struct();
    for k = 1:length(mykeys)
        MIP.(mykeys(k)) = myvalues(k);
    end


    %% MEP
    disp('MEP Start')
    EMG_amp_max = zeros(9, 1);
    raw_ADC_max = zeros(9, 1);
    raw_ADC_area = zeros(9, 1);
    ADC_start = zeros(9, 1);
    ADC_stop = zeros(9, 1);
    ADC_max = zeros(9, 1);
    ADC_area = zeros(9, 1);

    % figure
    for abc = 1:1
        ADC = super_ADC{1, abc+1};
        for i = 1:channels
            ROLL = super_ROLL{i, abc+1};
            EMG = super_EMG{i, abc+1};
            [start_idx, end_idx, all_EMG, mean_ROLL, mean_ADC, high, low] = id_corr(ROLL, ADC, EMG, 3.1, 2, 4, ext);
            EMG_all_PCA{i, abc+1} = all_EMG;
            index_start_list(i, abc+1) = start_idx;
            index_end_list(i, abc+1) = end_idx;
            % s = subplot(10, 3, (i-1)*3+abc);
            % hold on;
            % plot(mean_ROLL, "LineWidth", 1.5);
            if start_idx + end_idx ~= 1
                % scatter(start_idx:end_idx, mean_ROLL(start_idx:end_idx), 10,"red", "filled")
                EMG_high = mean(high(start_idx: end_idx));
                EMG_low = mean(low(start_idx: end_idx));
                EMG_max = max(abs([EMG_high, EMG_low]));
            else
                EMG_max = 0;
            end
            % xs = length(mean_ROLL);
            % axis tight;
            % set(s,'xtick',(0:24414:xs),'xticklabel',(0:1:ceil(xs./24414)),'ylim',([y_all_min(i,1) y_all_max(i,1)]));
            % set(gca,"FontSize", 8)
            
            mean_ADC = normalize_ADC(mean_ADC);
            [ADC_start_idx, ADC_stop_idx] = id_ADC(mean_ADC, 10);
            EMG_amp_max(i, abc) = EMG_max;  
            ADC_start(i, abc) = ADC_start_idx;
            ADC_stop(i, abc) = ADC_stop_idx;
            ADC_max(i, abc) = max(abs(mean_ADC));
            ADC_area(i, abc) = EMG_integrate(mean_ADC, ADC_start, ADC_stop);
            fprintf(' - Muscle %d done\n', i)   
        end

        for j = 1:9
            raw_ADC_max(j, abc) = max(abs(ADC(j, :)));
            [ADC_start_idx, ADC_stop_idx] = id_ADC(ADC(j, :), 10);
            raw_ADC_area(j, abc) = EMG_integrate(ADC(j, :), ADC_start_idx, ADC_stop_idx);
        end

        % s = subplot(10, 3, 27+abc);
        % hold on;
        % plot(mean_ADC, "LineWidth", 1.5)
        % xs = length(super_ADC{1, abc}(1, :));
        % axis tight;
        % set(s,'xtick',(0:24414:xs),'xticklabel',(0:1:ceil(xs./24414)));
        % set(gca,"FontSize", 8)
        % hold on;

    end

    % % Annotation
    % ba = ["Before", "After", "Control"];
    % for o = 1:3
    %     a = annotation('textbox',[0.21+0.285*(o-1) 0.92 .05 .05],'String',sprintf(ba{o}),'FitBoxToText','on','EdgeColor','none');
    %     a.FontSize = 14;
    % end
    % for o = 1:9
    %     b = annotation('textbox',[0.01 0.9425-0.0845*o .05 .05],'String',sprintf(labels{o}),'FitBoxToText','on','EdgeColor','none');
    %     b.FontSize = 11;
    % end
    % 
    % % Graph
    % set(gcf,'Units','centimeters','Position',[0 0 40 23])
    % exportgraphics(gcf, [filepath_save '\MEP.png'],"Resolution",600);


    %% Data
    mykeys = ["EMG_Amplitude_Max", "raw_ADC_max", "raw_ADC_area" ...
              "ADC_start_point", "ADC_end_point", "ADC_max", "ADC_area"];
    myvalues = {EMG_amp_max, raw_ADC_max, raw_ADC_area, ADC_start, ADC_stop, ADC_max, ADC_area};
    MEP = struct();
    for k = 1:length(mykeys)
        MEP.(mykeys(k)) = myvalues(k);
    end

    %% Convert Envelope and Get EMG Max For Every Instant of Every Muscle(for scatter plot)
    EMG_all_max = cell(9, 2);
    EMG_all_PCA_max = cell(9, 2);
    for muc = 1:channels
        for abc = 1:2
    
            % All max
            [hi_all, lo_all] = convert_Envelope(EMG_all{muc, abc});
            this_max = zeros(length(hi_all(:, 1)), 1);
            for i = 1:length(hi_all(:, 1))
                start_idx = index_start_list(muc, abc);
                end_idx = index_end_list(muc, abc);
                if start_idx + end_idx ~= 1
                    this_max(i) = max(abs([hi_all(i, start_idx:end_idx), lo_all(i, start_idx:end_idx)]));
                else
                    this_max(i) = 0;
                end
            end
            EMG_all_max{muc, abc} = this_max;
    
            % PCA max
            [hi_PCA, lo_PCA] = convert_Envelope(EMG_all_PCA{muc, abc});
            this_PCA_max = zeros(length(hi_PCA(:, 1)), 1);
            for i = 1:length(hi_PCA(:, 1))
                if index_start_list(muc, abc) + index_end_list(muc, abc) ~= 1
                    this_PCA_max(i) = max(abs([hi_PCA(i, start_idx:end_idx), lo_PCA(i, start_idx:end_idx)]));
                else
                    this_PCA_max(i) = 0;
                end
            end
            EMG_all_PCA_max{muc, abc} = this_PCA_max;       
        end
    end
    
    %% Save Data
    if ~exist(filepath_save, 'dir')
       mkdir(filepath_save)
    end
    save([filepath_save '\results.mat'], 'MIP', 'MEP')
    save([filepath_save '\all.mat'], 'EMG_all', 'EMG_all_PCA', 'ADC_all', 'EMG_all_max', 'EMG_all_PCA_max', 'index_start_list', 'index_end_list')

end 

