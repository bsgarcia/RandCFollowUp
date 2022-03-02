%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [1.2];
modality = 'LE';
color = blue;

displayfig = 'on';

stats_data = table();
T_con = table();

% filenames
filename = 'Fig2A';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);


figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], ...
    'visible', displayfig)


sub_count = 0;
num = 0;
for exp_num = selected_exp
    clear dd
    num = num + 1;
    
    data = de.extract_nofixed_LE(exp_num);
    %data_ed = de.extract_ED(exp_num);
    
    if exp_num == 4
        data.con(data.con == 2) = 4;
    end
    ncon = length(unique(data.p1));
    
    dd = NaN(ncon, data.nsub);
    cons = unique(data.p1);
    
    for i = 1:ncon
        for sub = 1:data.nsub
            
            dd(i, sub) = mean(...
                data.cho(sub, data.p1(sub,:)==cons(i))==1);
            %if ismember(cons(i), [1, 4])
            complete = ismember(exp_num, [3, 4]);
            block = ismember(exp_num, [2, 3, 4]);
            less_cues = exp_num == 4;

            
                T3 = table(...
            sub+sub_count, exp_num,  complete,  block, less_cues, dd(i, sub), cons(i), ...
            'variablenames',...
            {'subject', 'exp_num', 'complete', 'block','less_cues', 'score', 'cond'}...
            );
            
            T_con = [T_con; T3]; 
           % end
        end
    end

    disp(mean(dd, 'all'));

%     
%     for sub = 1:data.nsub
%         s1 = mean(data.corr(sub, :));
%         s2 = mean(data_ed.corr(sub, :));
%         complete = int32(ismember(exp_num, [3, 4]));
%         block = int32(ismember(exp_num, [2, 3, 4]));
%         less_cues = int32(exp_num == 4);
%         T1 = table(...
%             sub+sub_count, exp_num, complete,  block, less_cues, s1, {'LE'}, ...
%             'variablenames',...
%             {'subject', 'exp_num', 'complete', 'block','less_cues', 'score', 'modality'}...
%             );
% %         T2 = table(sub+sub_count, exp_num, s2, {'ED'}, ...
% %             'variablenames',...
% %             {'subject', 'exp_num', 'score', 'modality'}...
% %             );
% %         
%         stats_data = [stats_data; T1];
%     end
    
    %sub_count = sub_count + sub;
    
    subplot(1, length(selected_exp), num)
    
    if num == 1
        labely = 'Choice rate (%)';
    else
        labely = '';
    end
    
    plot([10, 85], [50, 50], 'color', 'k', 'linestyle', ':')
    
    if exp_num == 4
        xvalues = [10, 85];
        varargin = {'60/40', '90/10'};
    else
        xvalues = [10, 20, 30, 40, 60, 70, 80, 90];
        varargin = xvalues;
    end
    brickplot(...
        dd.*100,...                             %data
        color.*ones(8, 3),...                   %color
        [-0.08*100, 1.08*100], fontsize,...     %ylim     % fontsize
        '',...                                  %title
        '',...                                  %xlabel
        '',...                                  %ylabel
        varargin,...                            %varargin
        0,...                                   %noscatter
        [-10, 105],...                          %xlim
        xvalues,...                    %xvalues
        5, ...                                  %barwidth
        0 ...                                   %median
        );
    
    plot([10, 85], [50, 50], 'color', 'k', 'linestyle', ':')
    xlabel('E-options');
    ylabel(labely);
    
    box off
    hold on
    
    %set(gca, 'ytick', [0:10]./10);
    set(gca,'TickDir','out')
    set(gca, 'fontsize', fontsize);
    
end
saveas(gcf, figname);

writetable(T_con, stats_filename);


T = stats_data;
%cond_ED = strcmp(T.modality, 'ED');
%cond_LE = strcmp(T.modality, 'LE');
% for i = 1:4
%     exp(i,:) = T.exp_num == i;
%     cond(i,:) = T.cond == i;
% end
% 
% for i = 1:4
%     x = T(logical(exp(i,:).*cond(i,:)), :).score;
%     y = ones(size(x)).*.5;
%     [p,h] = ttest(x, y);
%     disp(p)
%     disp(h)
%     disp('******************************');
% end
%T.score = T.score(shuffle(1:length(T.score)));

disp('FULL');
fitlm(T, 'score ~ complete*block', 'CategoricalVar', {'exp_num', 'less_cues', 'complete', 'block'})
disp('********************************************');
disp('LE');
disp('********************************************');
return
fitlm(T(cond_LE,:), 'score ~ exp_num ')
% % figure
% scatterCorr(T(cond_LE, :).exp_num, T(cond_LE, :).score, blue, .5, 1,...
%     10, 'w', 0);
% disp('********************************************');
% 
disp('********************************************');
disp('ED');
disp('********************************************');

% figure
fitlm(T(cond_ED,:), 'score ~ exp_num')
% scatterCorr(T(cond_ED, :).exp_num, T(cond_ED, :).score, orange, .5, 1,...
%     10, 'w', 0);
% disp('********************************************');
