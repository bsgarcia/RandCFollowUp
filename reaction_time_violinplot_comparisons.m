%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------%

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5, 6.1, 6.2, 7.1, 7.2];
modalities = {'ED', 'EE'};
displayfig = 'on';
colors = [orange_color;orange_color;orange_color;green_color];

%-------------------------------------------------------------------------%
% prepare data                                                            %
%-------------------------------------------------------------------------%
% stats_data is table that is used to compute stats later
stats_data = table();

% filenames
% name = modality1_modality2_modalityN
filename = [cell2mat(strcat(modalities(1:end-1), '_')), modalities{end}];
figfolder = 'violinplot';

figname = sprintf('fig/exp/%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);

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
%     throw = de.extract_ED(exp_num);
%     nsym = length(unique(throw.p1));
%     p1 = unique(throw.p1)'.*100;
%     
%     prepare data structure
%     midpoints = nan(length(modalities), nsub, nsym);
%     slope = nan(length(modalities), nsub, 2);
%     reshape_midpoints = nan(nsub, nsym);
%     
%     sim_params.exp_num = exp_num;
%     sim_params.de = de;
%     sim_params.sess = sess;
%     sim_params.exp_name = name;
%     
    for mod_num = 1:length(modalities)
        
        % get data depending on chosen modality
        switch (modalities{mod_num})
            
            case 'LE'
                data = de.extract_LE(exp_num);
                
            case 'EE'
                data = de.extract_EE(exp_num);
                ee = mean(data.rtime,2);
                
            case 'ED'
                data = de.extract_ED(exp_num);
                ed = mean(data.rtime,2);
                for i = 1:nsub                  
                    e(i) = mean(data.rtime(i,data.cho(i,:) == 1),2);
                    d(i) = mean(data.rtime(i,data.cho(i,:) == 2),2);                 
                end

            case 'PM'
                data = de.extract_PM(exp_num);

        end
        
%         % fill data
%         reshape_midpoints(:, :) = midpoints(mod_num, :, :);
%         slope(mod_num,:,:) = add_linear_reg(...
%             reshape_midpoints.*100, p1, colors(mod_num, :));
        
        % fill data for stats
%         for sub = 1:nsub
%             T1 = table(...
%                 sub+sub_count, num, slope(mod_num, sub, 2),...
%                 {modalities{mod_num}}, 'variablenames',...
%                 {'subject', 'exp_num', 'slope', 'modality'}...
%                 );
%             stats_data = [stats_data; T1];
%         end
    end
    %sub_count = sub_count+sub;
    
    %---------------------------------------------------------------------%
    % Plot                                                                %
    % --------------------------------------------------------------------%
    subplot(1, length(selected_exp), num)
    
    skylineplot({ed';e;d;ee'}, 4.5,...
        colors,...
        0,...
        5000,...
        fontsize,...
        '',...
        '',...
        '',...
        {'ED','E', 'D', 'EE'},...
        0);
    
    if num == 1; ylabel('Slope'); end
    
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