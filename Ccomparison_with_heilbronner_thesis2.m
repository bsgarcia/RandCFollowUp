%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [1,2,3,5,6,7];
displayfig = 'on';

%figure('Renderer', 'painters','Units', 'centimeters',...
%    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)
num = 0;
m = {};
% filenames
filename = 'Heil';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);
T = table();
sub_count = 0;
dED = [];
dEE = [];
for exp_num = selected_exp
    num = num + 1;

    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    data = de.extract_ED(exp_num);
    psym = unique(data.p1);
    a = [];
    for sub = 1:nsub
        for i = 1:length(psym)
            a(sub, i) = mean(data.cho(sub, data.p1(sub,:)==psym(i))==1);
        end
    end
    dED = [dED; a];

    
    data = de.extract_EE(exp_num);
    psym = unique(data.p1);
    a = [];
    for sub = 1:nsub
        for i = 1:length(psym)
            a(sub, i) = mean(data.cho(sub, data.p1(sub,:)==psym(i))==1);
        end
    end
    dEE = [dEE; a];

    %     for sub = 1:nsub
%         sub_count = sub_count + 1;
%         a = mean(data.cho(sub, :)==1, 'all');
%         
%         
%         m{num}(sub) = a;
%         T1 = table(...
%                 sub_count, exp_num, a, 'variablenames',...
%                 {'subject', 'exp_num', 'score'}...
%          );
%          T = [T; T1];    
%     end 
%         x_scatter{num} = ones(nsub,1)' .* num;
end

a = dED;
x = [10, 20, 30, 40, 60, 70, 80, 90];
err = std(a)./sqrt(size(a, 1));

er = errorbar(x,mean(a)*100,err.*100,err.*100,  'capsize', 0, 'linewidth', 1.5);    
er.Color = orange; 
er.LineStyle = 'none';
hold on
plot(x, mean(a).*100, 'color', set_alpha(orange, .8), 'markerfacecolor', set_alpha(orange, .4),'markeredgecolor', set_alpha(orange, .8), 'marker', 'o');
plot(x, x, 'color', 'k', 'LineStyle','--');

a = dEE;
er = errorbar(x,mean(a)*100,err.*100,err.*100,  'capsize', 0, 'linewidth', 1.5);    
er.Color = green; 
er.LineStyle = 'none';
hold on
plot(x, mean(a).*100, 'color', set_alpha(green, .8), 'markerfacecolor', set_alpha(green, .4),'markeredgecolor', set_alpha(green, .8), 'marker', 'o');

box off
ylim([0, 100])
xlim([0, 100])
set(gca, 'tickdir', 'out')
xticks(0:10:100)

% x = 1:8;
% for i = x
%     avg(i) = mean(m{i}, 'all');
%     err(i) = std(m{i})%./sqrt(length(m{i}));
% end
% 
% bar(x,avg.*100, 'facecolor', set_alpha(orange, .4), 'edgecolor', 'w');    
% 
% hold on 
% x_scat=horzcat(x_scatter{:});
% 
% deviation = (randi([-2, 2], numel(x_scat),1))./10;
% x_scat=x_scat'+deviation;
% y_scat=horzcat(m{:});
% 
% scatter(x_scat', y_scat.*100, 'markerfacecolor', orange, 'markerfacealpha', .6, 'markeredgecolor', 'w');
% 
% hold on
% 
% er = errorbar(x,avg*100,err./2.*100,err./2.*100, 'capsize', 0, 'linewidth', 1.5);    
% er.Color = [0, 0, 0]; 
% er.LineStyle = 'none';
% box off
% hold off
% ylim([0, 102]);
% set(gca, 'tickdir', 'out');
% % save stats file
% mkdir('data', 'stats');
% writetable(T, stats_filename);
% ylabel('Correct choice rate (%)');
% xlabel('Exp.');

