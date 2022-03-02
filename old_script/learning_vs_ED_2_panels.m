% -------------------------------------------------------------------%
% This script finds the best fitting Values for each exp             %
% then plots the figs                                                %
% -------------------------------------------------------------------%
init;
% -------------------------------------------------------------------%

selected_exp = [1, 2, 3, 8];
sessions = [0, 1];

i = 1;

for exp_num = selected_exp
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    clear corr2
    % load data
    exp_name = char(filenames{round(exp_num)});
    
    [cho, cfcho, out, cfout, corr1, con1, p1, p2, rew, rtime, ev1, ev2,...
        error_exclude] = ...
        DataExtraction.extract_learning_data(d.(exp_name).data,...
        d.(exp_name).sub_ids, idx, sess);
    
    [corr3, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    for sub = 1:d.(exp_name).nsub      
        if ismember(exp_num, [1, 2, 3, 4, 8])
            corr2(sub, :) = ...
                corr3(sub, ...
                logical(~ismember(p2(sub,:), [0, .5, 1])));
        else
            corr2 = corr3;
        end           
    end
    
    for j = 1:d.(exp_name).nsub
        mn1{i,j} = mean(corr1(j, :));
        if mean(corr1(j, :)) < .1
            mn1{i,j} = .5;
        end
    end
    
    for j = 1:d.(exp_name).nsub
        mn2{i,j} = mean(corr2(j, :));
    end
    i = i + 1;
    
end
% id = [1, 2];
% m1(id, :) = ll(id, 1, :);
% m2(id, :) = ll(id, 2, :);
%
% figure('Position', [354,399,891,692]);
% skyline_comparison_plot(...
%     mn1, mn2,...
%     repmat([blue_color; orange_color], length(selected_exp), 1),...
%     0,...
%     1.08,...
%     20, '', 'Exp.',...
%     'Correct choice rate', ...
%     selected_exp, 0);
%
% legend('Learning', 'ED', 'location', 'southwest');
% box off
% %set(gca, 'XTickLabel', {'ED', 'EE'});
% set(gca, 'Fontsize', 20);


for i = 1:size(mn1, 1)
    mn(1, i) = mean([mn1{i, :}]);
    mn(2, i) = mean([mn2{i, :}]);
    
    err(1, i) = std([mn1{i, :}])./sqrt(length([mn1{i, :}]));
    err(2, i) = std([mn2{i, :}])./sqrt(length([mn2{i, :}]));
end

y_line = [0.5, 0.79];

for i = 1:2
    
    if i == 1
        dd = mn1;
    else
        dd = mn2;
    end
    
        cc = [0    0.4470    0.7410;
        0.8500    0.3250    0.0980;
        0.9290    0.6940    0.1250];

    
    figure('Renderer', 'painters',...
    'Position', [927,131,1300,1000], 'visible', 'on')
    
    b = bar(mn(i, :), ...
        'EdgeColor', 'w', 'FaceAlpha', 0.55, 'FaceColor', 'Flat');
    hold on

    x_lim = get(gca, 'xlim');
    
    plot(x_lim, ones(size(x_lim)).* y_line(i),...
        'linestyle', '--', 'color', cc(i, :), 'linewidth', 1.5);
    hold on 
    
    ngroups = length(mn(i, :));
    nbars = 1;
    %    Calculating the width for each bar group
    groupwidth = min(0.8, ngroups/(ngroups + 1.5));

    set(b,'FaceColor', cc(i, :))
    count = 0;

    for gr = 1:ngroups

        for ba = 1:nbars

            nsub = length([dd{gr,:}]);

            s = scatter(...
                gr*ones(1, nsub)-...
                Shuffle(linspace(-0.18, 0.18, nsub)),...
                [dd{gr, :}], 100,...
                'MarkerFaceAlpha', 0.65, 'MarkerEdgeAlpha', 1,...
                'MarkerFaceColor', cc(i, :),...
                'MarkerEdgeColor', 'w', 'HandleVisibility','off');
            box off

            hold on
            errorbar(gr, ...
                mn(i, gr), err(i, gr), 'LineStyle', 'none', 'LineWidth',...
                3, 'Color', 'k', 'HandleVisibility','off', 'capsize', 10);
            box off
        end

    end
    hold off
    ylim([0, 1.08]);
    %xticklabels({'Exp. 1', 'Exp. 2', 'Exp. 3', 'Exp. 8'});
    %ylabel('Correct choice rate');
    %title(sprintf('Exp. %s', num2str(exp_num)));
    %set(gca,'xtick',[])
    h = gca; h.XAxis.Visible = 'off';
    box off
    set(gca,'XTick',[])
    set(gca, 'fontsize', 24);
    set(gca,'TickDir','out');
end
