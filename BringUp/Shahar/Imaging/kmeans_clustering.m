% function [cluster_allocation, quant_error, cluster_centers] = kmeans_clustering(v, Nclusters, [cluster_weights])
%
% Clustering using K-means (Llyod) algorithm
% 
% Receives a set of vectors (rows of a matrix)
% Divides them into clusters, attempting to minimize
% the MSE between each cluster and its center.
% and return the cluster index of each vector
%the distance of each vector from its associated clusted center  
% (from which the the total MSE, and the MSE per group can be calculated)
%, and the cluster centers.
%
% Algo:
% (1) Pick randomly Nclusters out of the vectors as initial cluster centers
% (2) Repeat (this is Lloyd's algorithm):
%   (a) Allocate vectors to centers by nearest neighbor
%   (b) Set centers to be the mean of their groups
%   Until the allocation is static.
% (3) Repeat the process several times and choose the best outcome 
%     In the sense of the total MSE.
%
% To collect the errors per cluster from quant_error, the 
% matrix hit_matrix, where the (i,j) element is "1" if vector j was
% classified to class i, can be built as follows:
% hit_matrix = ( (1 ./ (1:K))' * cluster_allocation == 1);
% and then hit_matrix * quant_error sums the errors on each
% cluster.
% 
% The optional cluster_weights can be used to 
% change the penalty of distance in each cluster, i.e.
% try to minimize sum[clusters] weight * sum(distances in cluster)
% This is good especially if we want a "trash" cluster that will include 
% all signals that do not pair well. This can be achieved by reducing its weight.
% The cluster_weight affects the allocaiton of points to clusters.
%
% see also
% http://en.wikipedia.org/wiki/K-means_clustering
% matlab's kmeans function (statistical analysis toolbox): http://www.mathworks.com/help/stats/kmeans.html
% 
% in order to make the cluster allocation reproducible, up to the random
% changes (i.e. avoid interchange between (1 1 2 3 2 3) and (3 3 1 2 1 2),
% we sort as follows:
% (1) The biggest group gets the smallest index
% (2) Secondary criterion (ties breaker), is that the group that
% appears first gets the smaller index.
% These criterions are not exact but implemented in a "smooth" way by
% giving a score to each cluster.
%
% Application for Das: 
%  clustering of signals in "Open DAS signals" view (after time shift)
%  After setting break point:
% Nc=5; w=[1 1 1 1 1]; y_norm = data.refl_matrix_shifted ./ repmat(sqrt(mean(abs(data.refl_matrix_shifted).^2, 2)), 1, size(data.refl_matrix_shifted, 2)); cl=kmeans_clustering(y_norm, Nc, w);t=((1:size(y_norm,2))-data.new_das_pos)/data.GeneratedData.FreqToTime.Fs; figure; for k=1:Nc; subplot(Nc,1,k); plot(t, y_norm(cl==k,:)'); set(gca, 'xlim', [-2e-9, 2e-9]); title(sum(cl==k)); end;
function [cluster_allocation, quant_error, cluster_centers] = kmeans_clustering(v, Nclusters, cluster_weights)
Nvectors = size(v,1);
Num_rand_tests = 10;
best_total_error = Inf;
if (~exist('cluster_weights'))
    cluster_weights = ones(Nclusters, 1);
else
    cluster_weights = reshape(cluster_weights, Nclusters, 1);
end;

for nr = 1:Num_rand_tests
    cluster_allocation = zeros(1,Nvectors);
    previous_cluster_allocation = ones(1,Nvectors)*(-1);
    cluster_centers = v(randperm(Nvectors, Nclusters),:);
    while any(cluster_allocation ~= previous_cluster_allocation)
        % Cluster allocation by nearest neighbor
        previous_cluster_allocation = cluster_allocation;
        for n=1:Nvectors
            [~, cluster_allocation(n)] = min(cluster_weights .* sum(abs(repmat(v(n,:),  Nclusters, 1) - cluster_centers).^2, 2));
        end;
        % Cluster centers as mean of their groups
        for n=1:Nclusters
            if (any(cluster_allocation == n))
                cluster_centers(n,:) = mean(v(find(cluster_allocation == n),:), 1);
            else % can this happen?
                cluster_centers(n,:) = v(randperm(Nvectors, 1),:);
            end;
        end;
    end;
    if length(cluster_weights)==1
        total_error = sum(sum(abs(cluster_centers(cluster_allocation,:) - v).^2, 2) .* cluster_weights(cluster_allocation)');

    else
        total_error = sum(sum(abs(cluster_centers(cluster_allocation,:) - v).^2, 2) .* cluster_weights(cluster_allocation));
    end
    if total_error < best_total_error
        best_total_error = total_error;
        best_cluster_allocation = cluster_allocation;
    end;
end;

%cluster_allocation = best_cluster_allocation;
% in order to make the cluster allocation reproducible, up to the random
% changes (i.e. avoid interchange between (1 1 2 3 2 3) and (3 3 1 2 1 2),
% we sort as follows:
% (1) The biggest group gets the smallest index
% (2) Secondary criterion (equality breaker), is that the group that
% appears first gets the smaller index.
sort_key = [];
for n=1:Nclusters
    sort_key(n) = sum((best_cluster_allocation == n) .* (1 - (1:Nvectors)/(4*Nvectors))); % number of elements with bigger weight to first elements
end;
[~, renum] = sort(-sort_key);
cluster_allocation = renum(best_cluster_allocation);
%cluster_allocation = best_cluster_allocation;

for n=1:Nclusters
    cluster_centers(n,:) = mean(v(find(cluster_allocation == n),:), 1);
end;
quant_error = sum(abs(cluster_centers(cluster_allocation,:) - v).^2, 2);




    
