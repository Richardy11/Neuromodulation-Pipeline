clear

% Which file you want to plot
this_file = {'20220720_KL-11_RespEMG.mat' [6  7  8  2  3  4] 'Before'};

file_name = ['..\Results\' this_file{1, 3} '\' this_file{1, 1} '\all.mat'];
load(file_name)

%% MIP
MIP = EMG_all(:, 1);
figure
for i = 1:9
    for j = 1:9
        this_MIP = MIP{i, 1};
        subplot(9, 9, 9*(i-1)+j)
        plot(this_MIP(j, :))
    end
end