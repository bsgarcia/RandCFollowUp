figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3, 5.3/1.25])
rng(1)

x = rand(1000*2,1);
y = rand(1000*2,1);
markersize = 7;

scatter(x, y, markersize-2,...
    'w','filled','marker','o','markerfacealpha', 1,...
    'markeredgecolor', 'w', 'linewidth', 1);
hold on
scatter(x, y, markersize-1,...
    'r','filled','marker','o',...
    'MarkerFaceAlpha',0.2);
%       set(s, 'linewidth', 0.02);
%        s.NodeChildren.Marker.LineWidth = .02;













