%-------------------------------------------------------------------------
init;
show_current_script_name(mfilename('fullpath'));
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5];
modalities = {'LE', 'ED', 'EE', 'SP'};
displayfig = 'on';
colors = [blue;orange;green;magenta];
% filenames
filename = 'Fig3D';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);


%-------------------------------------------------------------------------%
% prepare data                                                            %
%-------------------------------------------------------------------------%
% stats_data is table that is used to compute stats later
stats_data = table();


figure('Units', 'centimeters',...
    'Position', [0,0,5.3, 5.3/1.25], 'visible', displayfig)

num = 0;
sub_count = 0;
for exp_num = selected_exp
    num = num + 1;
    
    %---------------------------------------------------------------------%
    % get data parameters                                                           %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    throw = de.extract_ED(exp_num);
    nsym = length(unique(throw.p1));
    p1 = unique(throw.p1)'.*100;
    
    % prepare data structure
    midpoints = nan(length(modalities), nsub, nsym);
    slope = nan(length(modalities), nsub, 2);
    reshape_midpoints = nan(nsub, nsym);
    
    sim_params.exp_num = exp_num;
    sim_params.de = de;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.nsub = nsub;
    
    for mod_num = 1:length(modalities)

        disp(sub_count:sub_count+nsub);
        disp(mod_num)
        
        % get data depending on chosen modality
        switch (modalities{mod_num})
            
            case 'LE'
                sim_params.model = 1;
                [midpoints(mod_num, :, :), throw] = get_qvalues(sim_params);
                
            case {'EE', 'ED'}
                param = load(...
                    sprintf('data/midpoints_%s_exp_%d_%d_mle',...
                    modalities{mod_num}, round(exp_num), sess));
                
                midpoints(mod_num, :, :) = param.midpoints;
                
            case 'SP'
                sim_params.model = 2;
                [midpoints(mod_num, :, :), throw] = get_qvalues(sim_params);
        end
        
        % fill data
        reshape_midpoints(:, :) = midpoints(mod_num, :, :);
        slope(mod_num,:,:) = add_linear_reg(...
            reshape_midpoints.*100, p1, colors(mod_num, :));
       
        
        % fill data for stats
        for sub = 1:nsub
            T1 = table(...
                sub+sub_count, slope(mod_num, sub, 2),...
                {modalities{mod_num}}, 'variablenames',...
                {'subject', 'slope', 'modality'}...
                );
            stats_data = [stats_data; T1];
        end
    end
    sub_count = sub_count+sub;
    
end


% Default heading for the columns will be A1, A2 and so on. 
% You can assign the specific headings to your table in the following manner
%T.Properties.VariableNames(1:4) = {'LE','ES','EE','SP'};

writetable(stats_data, 'python/corr_table.csv')
%---------------------------------------------------------------------%
    % Plot                                                                %
%     % --------------------------------------------------------------------%
%     subplot(1, length(selected_exp), num)
%     skylineplot(slope(:, :, 2), 8,...
%         colors,...
%         -1.2,...
%         1.5,...
%         fontsize,...
%         '',...
%         '',...
%         '',...
%         modalities);
%         
%     
%     
%     if num == 1; ylabel('Slope'); end
%     
%     %title(sprintf('Exp. %s', num2str(exp_num)));w
%     set(gca, 'tickdir', 'out');
%     box off

function h = raincloud_plot(X,cl)

[a,b] = ksdensity(X);

wdth = 0.8; % width of boxplot
% TODO, should probably be some percentage of max.height of kernel density plot

% density plot
h{1} = area(b,a); hold on
set(h{1}, 'FaceColor', cl);
set(h{1}, 'EdgeColor', [0.1 0.1 0.1]);
set(h{1}, 'LineWidth', 2);

% make some space under the density plot for the boxplot
yl = get(gca,'YLim');
set(gca,'YLim',[-2 yl(2)]);

% jitter for raindrops
jit = (rand(size(X)) - 0.5) * wdth;

% info for making boxplot
Y = quantile(X,[0.25 0.75 0.5 0.02 0.98]);

% 'box' of 'boxplot'
h{2} = rectangle('Position',[Y(1) -1-(wdth*0.5) Y(2)-Y(1) wdth]);
set(h{2},'EdgeColor','k')
set(h{2},'LineWidth',2);
% could also set 'FaceColor' here as Micah does, but I prefer without

% mean line
h{3} = line([Y(3) Y(3)],[-1.2 -0.8],'col','k','LineWidth',2);

% whiskers
h{4} = line([Y(2) Y(5)], [-1 -1],'col','k','LineWidth',2);
h{5} = line([Y(1) Y(4)],[-1 -1],'col','k','LineWidth',2);

% raindrops
h{3} = scatter(X,jit - 1);
h{3}.SizeData = 5;
h{3}.MarkerFaceColor = cl;
h{3}.MarkerEdgeColor = 'none';
end


    