%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [6.1, 6.2, 7.1, 7.2];
modalities = {'ED_e','ED_d', 'ED', 'EE'};
displayfig = 'on';
colors = [orange_color;orange_color;orange_color;green_color;magenta_color];

%-------------------------------------------------------------------------%
% prepare data                                                            %
%-------------------------------------------------------------------------%
% stats_data is table that is used to compute stats later
stats_data = table();

% filenames
% name = modality1_modality2_modalityN
filename = [cell2mat(strcat(modalities(1:end-1), '_')), modalities{end}];
figfolder = 'violinplot';

figname = sprintf('fig/exp/%s/RT_%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/RT_%s.csv', filename);

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)

num = 0;
sub_count = 0;
for exp_num = selected_exp
    num = num + 1;
    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
%     
    for mod_num = 1:length(modalities)
        
        % get data depending on chosen modality
        switch (modalities{mod_num})
            
            case 'LE'
                data = de.extract_LE(exp_num);
                le = mean(data.rtime, 2);
                dd = le;
                
            case 'EE'
                data = de.extract_EE(exp_num);
                ee = mean(data.rtime,2);
                dd = ee;
                
            case 'ED'
                data = de.extract_ED(exp_num);
                ed = mean(data.rtime,2);
                
                dd = ed;
            case 'ED_e'
                data = de.extract_ED(exp_num);
                for i = 1:nsub                 
                    e(i) = mean(data.rtime(i,data.cho(i,:) == 1),2);
                end
                dd = e;
                
             case 'ED_d'
                data = de.extract_ED(exp_num);
                for i = 1:nsub                 
                    d(i) = mean(data.rtime(i,data.cho(i,:) == 2),2);
                end
                dd = d;

            case 'PM'
                data = de.extract_PM(exp_num);
                if size(data.rtime, 2) == 0
                    pm = zeros(size(data.rtime, 1), 1)';
                else
                    pm = mean(data.rtime, 2);
                end

        end
        
        for sub = 1:nsub
            T1 = table(...
                sub+sub_count, num, dd(sub),...
                {modalities{mod_num}}, 'variablenames',...
                {'subject', 'exp_num', 'slope', 'modality'}...
                );
            stats_data = [stats_data; T1];
        end
    end
    sub_count = sub_count+sub;
    
    %---------------------------------------------------------------------%
    % Plot                                                                %
    % --------------------------------------------------------------------%
    subplot(1, length(selected_exp), num)
    
    skylineplot([e; d; ed';ee'], 4.5,...
        colors,...
        -.08,...
        8000,...
        fontsize,...
        '',...
        '',...
        '',...
        modalities,...
        0);
    
    if num == 1; ylabel('milliseconds'); end
    
    set(gca, 'tickdir', 'out');
    box off
    
end
%-------------------------------------------------------------------------%
% Save fig and stats                                                      %
% ------------------------------------------------------------------------%
% save fig
mkdir('fig/exp', figfolder);
saveas(gcf, figname);

% save stats file
mkdir('data', 'stats');
writetable(stats_data, stats_filename);

function arr = normalize(arr)
    arr = (arr - min(arr(:)))./(max(arr(:))-min(arr(:)));
end