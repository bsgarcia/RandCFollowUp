% -------------------------------------------------------------------%
% This script finds the best fitting Values for each exp             %
% then plots the figs                                                %
% -------------------------------------------------------------------%
init;
% -------------------------------------------------------------------%

selected_exp = [4, 5.2, 6.2];

sessions = [0, 1];

starting = 1;

for exp_num = selected_exp
    
    % -------------------------------------------------------------------%
    % LEARNING
    % -------------------------------------------------------------------%
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    
    % load data
    exp_name = char(filenames{round(exp_num)});
    
    if exist('ending')
        ending = ending + d.(exp_name).nsub;
    else
        ending = d.(exp_name).nsub;
    end
    
    [a, cont1, cont2, p1, p2, ev1, ev2, ll(1, 1, starting:ending)] = ...
        sim_exp_ED(exp_name, exp_num, d, idx, sess, 6);
    
    [a, cont1, cont2, p1, p2, ev1, ev2, ll(1, 2, starting:ending)] = ...
        sim_exp_ED(exp_name, exp_num, d, idx, sess,  4);
%     
%     [a, cont1, cont2, p1, p2, ev1, ev2, ll(2, 1, starting:ending)] = ...
%         sim_exp_EE(exp_name, exp_num, d, idx, sess, 1);
%     
%     [a, cont1, cont2, p1, p2, ev1, ev2, ll(2, 2, starting:ending)] = ...
%         sim_exp_EE(exp_name, exp_num, d, idx, sess,  4);
    
    nsub = d.(exp_name).nsub;
    
    starting = starting + nsub;
    % -------------------------------------------------------------------%

end

m1(1, :) = ll(1, 1, :);
m2(1, :) = ll(1, 2, :);

figure('Position', [354,399,891,692]);
skyline_comparison_plot(...
    m1, m2,...
    [orange_color;magenta_color;orange_color;magenta_color],...
    0,...
    1.08,...
    20, '', '',...
    'Correctly predicted choices', ...
    [], 0);

legend('Heuristic', 'PM', 'location', 'southwest');
box off
set(gca, 'XTickLabel', {'ED', 'EE'});
set(gca, 'Fontsize', 20);
set(gca,'TickDir','out'); 