% https://www.mathworks.com/help/stats/fitgmdist.html
y = ones(size(X,1),1);
y(strcmp(species,'setosa')) = 2;
y(strcmp(species,'virginica')) = 3;
GMModel2 = fitgmdist(X,3,'Start',y);