% --------------------------------------------------------------------
% This script
% computes correct choice rate then plots the article figs
% --------------------------------------------------------------------
init;

selected_exp = [1, 2, 3, 4];
sessions = [0, 1];
%selected_exp = [8];
displayfig = 'off';

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.15/1.25], 'visible', displayfig)
   
num = 0;
for exp_num = selected_exp
    num = num + 1;
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    
    sess = sessions(uint64(idx1));
    
    exp_name = char(filenames{round(exp_num)});
    
    data = d.(exp_name).data;
    sub_ids = d.(exp_name).sub_ids;
    
    [cho, cfcho, out, cfout, corr1, con1, p1, p2, rew, rtime, ev1, ev2,...
        error_exclude] = ...
        DataExtraction.extract_learning_data(data, sub_ids, idx, sess);
    
    nsub = d.(exp_name).nsub;
    
    if exp_num == 4
        con1(con1 == 2) = 4;        
        
    end
    
    subcorr = nan(length(unique(con1)), nsub);
    for sub = 1:nsub
        for i = 1:4
            subcorr(i, sub) = mean(corr1(sub, con1(sub,:)==i)).*100;
        end
    end
    
%     for i = 1:4
%         mn(i) = mean(subcorr(i, :));
%         err(i) = std(subcorr(i,:))./sqrt((length(subcorr(i,:))));
%     end
    
    % ------------------------------------------------------------------------
    % Plot fig
    % -------------------------------------29-----------------------------------  
    x_lim = [-8, 108];
    y_lim = [-8, 108];
    range = -8:108;
    x_values = [-8:14:108]+5;
    x_values = x_values([2, 4, 6, 8]);
    varargin = x_values;
   
    subplot(1, length(selected_exp), num)
    
    %add_linear_reg(midpoints.*100, ev, color);
    brickplot2(...
        flipud(subcorr),...
        blue_color.*ones(size(subcorr, 2), 1),...
        y_lim, fontsize,...
        '',...
        '',...
        '', varargin, 0, x_lim, x_values, .18*100);
    
    hold on
    
    if num == 1
        ylabel('Correct choice rate (%)')
    end
    
    
    pp = plot([1, 4], [50, 50], 'linestyle', ':', 'color', [0 0 0]);
    hold on
    
    ylim([-8, 108]);

    %ylabel('Correct choice rate');
    %title(sprintf('Exp. %s', num2str(exp_num)));
    
    xticklabels({'60/40', '70/30', '80/20', '90/10'});
    set(gca, 'tickdir', 'out');
    box off
    uistack(pp, 'bottom');
    
   
end
    
mkdir('fig/exp/', 'test_brickplot');
    saveas(gcf, ...
        sprintf('fig/exp/test_brickplot/full.svg'));  
   
  
