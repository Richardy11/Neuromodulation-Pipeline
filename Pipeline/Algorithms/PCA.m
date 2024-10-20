function outliers = PCA(EMG, threshold, principles, num_clusters)

    % Preprocess
    standardizedData = (EMG - mean(EMG, 1)) ./ std(EMG, 0, 1);
    
    % PCA and output
    [~, score] = pca(standardizedData);
    
    % Find Biggest Cluster
    idx = kmeans(score(:, 1:principles), num_clusters, 'Start', zeros(num_clusters, 2)); % There is some randomness here
    cluster_counts = histcounts(idx, 1:num_clusters+1);
    [~, biggest_cluster_idx] = max(cluster_counts);
    indices_in_biggest_cluster = find(idx == biggest_cluster_idx);
    
    % Calculate the mean of the two principal components for the biggest cluster
    mean_pc1 = mean(score(indices_in_biggest_cluster, 1));
    mean_pc2 = mean(score(indices_in_biggest_cluster, 2));
    std_pc1 = std(score(indices_in_biggest_cluster, 1));
    std_pc2 = std(score(indices_in_biggest_cluster, 2));
    
    % Subtract the means from their corresponding scores for the biggest
    % cluster, centering the largest cluster
    adjusted_scores = score;
    adjusted_scores(:, 1) = adjusted_scores(:, 1) - mean_pc1;
    adjusted_scores(:, 2) = adjusted_scores(:, 2) - mean_pc2;
    
    %% Find Outliers
    stdScores = [std_pc1 std_pc2];
    outliers = any(abs(adjusted_scores(:, 1:principles)) > threshold*stdScores, 2);

end