clear all


figure

x = [0:5:100];
y =  [0:5:100]

plot(x, y, 'color', 'k', 'linestyle', '--', 'linewidth', 2.5);

set(gca, 'fontsize', 7);

ylabel('p(win)')
set(gca, 'tickdir', 'out');
yticks(x);