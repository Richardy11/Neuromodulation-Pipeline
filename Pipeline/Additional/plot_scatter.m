%% Initial
clear
load("data\all.mat")

%% Get Max
EMG_all_max = cell(9, 6);
EMG_all_PCA_max = cell(9, 6);

for muc = 1:9
    for abc = 1:6

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

%% Plotting
labels ={'RTransDia','LTransDia','RIntercostal','LIntercostal','RTrap','LTrap','RAbdominal','LAbdominal','Thoracic'};

% Muscles 1-4
figure;
for muc = 1:4
    max_list = [];
    for l = 1:6
        max_list = [max_list EMG_all_max{muc, l}' EMG_all_PCA_max{muc, l}'];
    end
    y_max = max(max_list) * 1.1;
    subplot(4, 4, 1+4*(muc-1));
    this_scatter(EMG_all_max{muc, 1}, EMG_all_max{muc, 2},EMG_all_max{muc, 3}, y_max)
    subplot(4, 4, 2+4*(muc-1));
    this_scatter(EMG_all_PCA_max{muc, 1}, EMG_all_PCA_max{muc, 2},EMG_all_PCA_max{muc, 3}, y_max)
    subplot(4, 4, 3+4*(muc-1));
    this_scatter(EMG_all_max{muc, 4}, EMG_all_max{muc, 5},EMG_all_max{muc, 6}, y_max)
    subplot(4, 4, 4+4*(muc-1));
    this_scatter(EMG_all_PCA_max{muc, 4}, EMG_all_PCA_max{muc, 5},EMG_all_PCA_max{muc, 6}, y_max)
end
a = annotation('textbox',[0.17 0.92 .05 .05],'String', 'MIP Before PCA','FitBoxToText','on','EdgeColor','none', 'FontWeight', 'bold');
a.FontSize = 14;
a = annotation('textbox',[0.375 0.92 .05 .05],'String', 'MIP After PCA','FitBoxToText','on','EdgeColor','none', 'FontWeight', 'bold');
a.FontSize = 14;
a = annotation('textbox',[0.575 0.92 .05 .05],'String', 'MEP Before PCA','FitBoxToText','on','EdgeColor','none', 'FontWeight', 'bold');
a.FontSize = 14;
a = annotation('textbox',[0.78 0.92 .05 .05],'String', 'MEP After PCA','FitBoxToText','on','EdgeColor','none', 'FontWeight', 'bold');
a.FontSize = 14;
for o = 1:4
    b = annotation('textbox',[0.03 0.82-0.22*(o-1) .05 .05],'String',sprintf(labels{o}),'FitBoxToText','on','EdgeColor','none');
    b.FontSize = 12;
end
set(gcf,'Units','centimeters','Position',[2 0 35 24])
exportgraphics(gcf, 'plot\Scatter_1.png',"Resolution",600);
close gcf

% Muscles 5-9
figure;
for muc = 5:9
    for l = 1:6
        max_list = [max_list EMG_all_max{muc, l}' EMG_all_PCA_max{muc, l}'];
    end
    y_max = max(max_list) * 1.1;
    subplot(5, 4, 1+4*(muc-5));
    this_scatter(EMG_all_max{muc, 1}, EMG_all_max{muc, 2},EMG_all_max{muc, 3}, y_max)
    subplot(5, 4, 2+4*(muc-5));
    this_scatter(EMG_all_PCA_max{muc, 1}, EMG_all_PCA_max{muc, 2},EMG_all_PCA_max{muc, 3}, y_max)
    subplot(5, 4, 3+4*(muc-5));
    this_scatter(EMG_all_max{muc, 4}, EMG_all_max{muc, 5},EMG_all_max{muc, 6}, y_max)
    subplot(5, 4, 4+4*(muc-5));
    this_scatter(EMG_all_PCA_max{muc, 4}, EMG_all_PCA_max{muc, 5},EMG_all_PCA_max{muc, 6}, y_max)
end
a = annotation('textbox',[0.17 0.92 .05 .05],'String', 'MIP Before PCA','FitBoxToText','on','EdgeColor','none', 'FontWeight', 'bold');
a.FontSize = 14;
a = annotation('textbox',[0.375 0.92 .05 .05],'String', 'MIP After PCA','FitBoxToText','on','EdgeColor','none', 'FontWeight', 'bold');
a.FontSize = 14;
a = annotation('textbox',[0.575 0.92 .05 .05],'String', 'MEP Before PCA','FitBoxToText','on','EdgeColor','none', 'FontWeight', 'bold');
a.FontSize = 14;
a = annotation('textbox',[0.78 0.92 .05 .05],'String', 'MEP After PCA','FitBoxToText','on','EdgeColor','none', 'FontWeight', 'bold');
a.FontSize = 14;
for o = 5:9
    b = annotation('textbox',[0.03 0.84-0.17*(o-5) .05 .05],'String',sprintf(labels{o}),'FitBoxToText','on','EdgeColor','none');
    b.FontSize = 12;
end
set(gcf,'Units','centimeters','Position',[2 0 35 24])
exportgraphics(gcf, 'plot\Scatter_2.png',"Resolution",600);
close gcf


