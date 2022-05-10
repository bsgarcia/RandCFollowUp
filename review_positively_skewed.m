% %-------------------------------------------------------------------------%

init
%-------------------------------------------------------------------------%
factor = 1;
%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5];
displayfig = 'on';
colors = [orange];
% filenames
filename = 'review_positively_skewed';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);

num = 0;

alpha1 = [2.7, .3] ;
beta1 = [.9, .6];

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*2, 5.3/1.25].*factor, 'visible', displayfig)

for exp_num = selected_exp

    LE = de.extract_LE(exp_num);
    ES = de.extract_ES(exp_num);
    
    sim_params.exp_num = exp_num;
    sim_params.de = de;
    sim_params.sess = LE.sess;
    sim_params.exp_name = LE.name;
    sim_params.nsub = LE.nsub;
                    
    sim_params.model = 1;
    [midpoints, throw] = get_qvalues(sim_params);
    
    p_lot = unique(ES.p2);
    p_sym = unique(ES.p1);

    for sub = 1:ES.nsub
        for t = 1:length(ES.cho(1,:))
            %v1 = midpoints(sub, (ES.p1(sub,t)==p_sym));
            v1 = prelec(ES.p1(sub,t), alpha1(2), beta1(2));
            v2 = prelec(ES.p2(sub,t), alpha1(1), beta1(1));
            
            ev1 = (v1*1) + (1-v1*-1);
            ev2 = (v2*1) + (1-v2*-1);
            v = [ev1, ev2];
            
            pp = exp(v.*5)./exp(sum(v.*5));
            %[throw, choice] = max([v1, v2]);
            choice = randsample(2, 1, true, pp);

            cho(sub, t) = choice;
        end
    end

end

prop = zeros(length(p_sym), length(p_lot));
for i = 1:length(p_sym)
    for j = 1:length(p_lot)
        temp = cho(...
            logical((ES.p2 == p_lot(j)) .* (ES.p1== p_sym(i))));
        prop(i, j) = mean(temp == 1);

    end
end

subplot(1, 2, 1)

alpha = linspace(.15, .95, length(p_sym));
lin1 = plot(...
    linspace(p_sym(1)*100, p_sym(end)*100, 12), ones(12,1)*50,...
    'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');

for i = 1:length(p_sym)

    hold on

    lin3 = plot(...
        p_lot.*100,  prop(i, :).*100,...
        'Color', colors(1,:), 'LineWidth', 1.5*factor ...% 'LineStyle', '--' ...
        );

    lin3.Color(4) = alpha(i);

    hold on

    [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);

    sc2 = scatter(xout, yout, 15, 'MarkerFaceColor', lin3.Color,...
        'MarkerEdgeColor', 'w');
    sc2.MarkerFaceAlpha = alpha(i);

    ylabel('P(choose E-option) (%)');
    
    xlabel('S-option p(win) (%)');

    ylim([-0.08*100, 1.08*100]);
    xlim([-0.08*100, 1.08*100]);

    box off
end

set(gca,'TickDir','out')
set(gca, 'FontSize', fontsize.*factor);
xticks([0:20:100])
xtickangle(0)
%set(gca,'fontname','monospaced')  % Set it to times

%axis equal





subplot(1, 2, 2)
x = 0:.01:1;

p = prelec(x, alpha1(1), beta1(1));

plot(x.*100, x.*100, 'LineStyle','--', 'color', 'k')
hold on
plot(x.*100,p.*100,'linewidth', 1.5)
hold on
% 
p = prelec(x, alpha1(2), beta1(2));
plot(x.*100,p.*100,'linewidth', 1.5)

ylabel('w(p(win)) (%)')
xlabel('p(win) (%)')

set(gca, 'FontSize', fontsize.*factor);
box off
set(gca, 'tickdir', 'out')
xticks([0:20:100])
yticks([0:20:100])
    ylim([-0.08*100, 1.08*100]);
    xlim([-0.08*100, 1.08*100]);
saveas(gcf, figname);

% ------------------------------------------------------------------------%
%  side func
% -----------------------------------------------------------------------%
function p = prelec(x, alpha1, beta1)
% prelec PWF
p = exp(...
    -beta1 .* (-log(x)).^alpha1...
);
% if (x <= .5)
%     p = x;
% end

end

