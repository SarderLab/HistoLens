%% Generating a Minimum Spanning Tree from nuclear centroid coordinates

function [M,G] = OS_minSpanTreeFromCoordinates(coordinates)

P = coordinates;
D = zeros(length(P));
for a = 1:length(P)
    for b = 1:length(P)
        D(a, b) = ((P(1,a) - P(1,b))^2 + (P(2,a) - P(2,b))^2)^1/2;
    end
end

G = graph(D);
M = minspantree(G);

M_adj=adjacency(M);
G_adj=adjacency(G); 



% % Plotting MST
% figure, imshow(glom_imgs{z})
% hold on
% 
% G_m = graph(M_adj);
% p = plot(G_m,'layout','force')
% p.XData = P(1,:);
% p.YData = P(2,:);
% p.LineWidth = 8;
% p.EdgeColor = 'yellow';
% p.NodeColor = [1 1 1];
% p.NodeLabel = {};
% p.MarkerSize = 12;
% saveas(gcf, strcat('C:\Users\spborder\Desktop\BN_Project\Gloms\MSTs\Glom_MST_',string(z),'.png'))
% hold off
% %close all
% %mplot = plot(M);
% mplot.XData = P(:, 2);
% mplot.YData = 576-P(:, 1);
% A = M.Edges;
% sum(A.Weight)
% mean(A.Weight)
% %figure, histogram(M.Edges.Weight); title('Histogram of 2D MST Edge Lengths')
% %figure, histogram(degree(M)); title('Histogram of 2D MST Node Degrees')