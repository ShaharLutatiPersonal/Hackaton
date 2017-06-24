function [cluster_centers] = AdaKmeans(points)
if size(points,2) == 3 
    cor = corrcoef(points(:,1),points(:,2));
    cor =cor + corrcoef(points(:,2),points(:,3));
    cor =cor + corrcoef(points(:,3),points(:,1));

elseif size(points,2) == 2
        cor = corrcoef(points(:,1),points(:,2));
elseif size(points,2) == 1
        cor = [0 0];
else
    error ('higher dimension isn''t allowed');
end
correlationfactor = abs(cor(1,2));
Y = -size(points,2)/2 + correlationfactor;
maxK = min(max(size(points,1)-1,1),20);
cluster_centers_tmp = cell(maxK,1);
quant_error_tmp = zeros(maxK,1);
for ii = 1 : maxK
    [~, quant_error, cluster_centers_tmp{ii}] = kmeans_clustering(points, ii);
    quant_error_tmp(ii) = mean(abs(quant_error));
end
if 1
    debug =0;
end
quant_error_tmp = quant_error_tmp.^Y;
[res_x] = knee_pt(quant_error_tmp);
cluster_centers = cluster_centers_tmp{res_x};