%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [6, 8];

stats_data = table();

displayfig = 'on';

figure('Units', 'centimeters',...
    'Position', [0,0,5.3, 5.3/1.25], 'visible', displayfig)
num = 0;
sub_count = 0;
for exp_num = selected_exp
    num = num + 1;
    
    dED = de.extract_ED(exp_num);
    dEE = de.extract_EE(exp_num);
    
    corrED = mean(dED.corr,2)';
    corrEE = mean(dEE.corr,2)';
    mean(corrED)
    % add ED exp_%num
    CCR{num, 1} = corrED;
    
    % add EE exp_%num
    CCR{num, 2} = corrEE;
    
    for sub = 1:dED.nsub
        
        modalities = {'ED', 'EE'};
        dd = {corrED, corrEE};
        for mod_num = 1:2
        T1 = table(...
                    sub+sub_count, exp_num, dd{mod_num}(sub),...
                    {modalities{mod_num}}, 'variablenames',...
                    {'subject', 'exp_num', 'C', 'modality'}...
                    );
         stats_data = [stats_data; T1];
        end
    end
    
    sub_count = sub_count + sub;
end

% save stats file
mkdir('data', 'stats');
stats_filename = 'data/stats/Fig4C.csv';
writetable(stats_data, stats_filename);

return
x1 = CCR{1, 2};
x2 = CCR{2, 2};

skylineplot({x1;x2},8,...
    [green; green],...
    0,...
    1,...
    fontsize,...
    '',...
    '',...
    'Correct choice rate',...
    {'Exp. 6', 'Exp. 7'},...
    0);


hold on
scatter([1], [.8], 'markerfacecolor', 'black', 'markeredgecolor', 'w');
box off
hold on
set(gca, 'tickdir', 'out');