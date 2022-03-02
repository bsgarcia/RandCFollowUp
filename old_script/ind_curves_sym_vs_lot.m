%-------------------------------------------------------------------------
close all 
clear all
%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

   
selected_exp = [4.1];
displayfig = 

for exp_num = selected_exp
    

    idx1 = (exp_num - round(exp_num)) * 10;
    sess = sessions(uint64(idx1));
   
    % load data
    name = char(filenames{round(exp_num)});
    %subplot(2, 3, exp_num);
    name = char(f);
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
            data, sub_ids, idx, session);
    
    d.(name).nsub = size(cho, 1);
    % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    %pcue = [0.1, 0.2, 0.3, 0.4, .5, 0.6, 0.7, 0.8, 0.9];
    %psym = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];
    pcue = unique(p2)';
    psym = unique(p1)';
    
    chose_symbol = zeros(d.(name).nsub, length(pcue), length(psym), length(session));
    for i = 1:d.(name).nsub
        for j = 1:length(pcue)
            for k = 1:length(psym)
                temp = ...
                    cho(i, logical((p2(i, :) == pcue(j)) .* (p1(i, :) == psym(k))));
                for l = 1:length(temp)
                    chose_symbol(i, j, k, l) = temp(l) == 1;
                end
            end
        end
    end
       
    nsub = size(cho, 1);  
    k = 1:nsub;
     
    prop = zeros(length(psym), length(pcue));
    temp1 = cho(k, :);
    for j = 1:length(pcue)
        for l = 1:length(psym)
            temp = temp1(...
                logical((p2(k, :) == pcue(j)) .* (p1(k, :) == psym(l))));
            prop(l, j) = mean(temp == 1);
        end
    end
    
    X = reshape(...
        repmat(pcue, size(k, 2), size(chose_symbol, 4)), [], 1....
    );

    pp = zeros(length(psym), length(pcue));
    
    for i = 1:length(psym)
        Y = reshape(chose_symbol(k, :, i, :), [], 1);
        [logitCoef, dev] = glmfit(...
            X, Y, 'binomial','logit');
        pp(i, :) = glmval(logitCoef, pcue', 'logit');
    end
    
    figure(...
        'Renderer', 'painters',...
        'Position', [961, 1, 900, 550],...
        'visible', displayfig)
    
    pwin = psym;
    alpha = [fliplr(linspace(.5, 1, 4)), linspace(.5, 1, 4)];
    
    lin1 = plot(...
        linspace(0, 1, 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    
    for i = 1:length(pwin)
        
        if pwin(i) < .5
            color = red_color;
        else
            color = blue_color;
        end
        
        hold on
        %         lin2 = plot(...
        %             ones(10)*pwin(i),...
        %             linspace(0.1, 0.9, 10),...
        %             'LineStyle', '--', 'Color', [0, 0, 0], 'LineWidth', 2);
        
        % [0.4660    0.6740    0.1880]
        if ismember(i, [1, 8])
            lin3 = plot(...
                pcue,  pp(i, :),... %'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
                'Color', color, 'LineWidth', 4.5 ...
            );
        else
            lin3 = plot(...
                pcue,  pp(i, :),... %'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
                'Color', color, 'LineWidth', 3.5 ...
            );
        end
        
        lin3.Color(4) = alpha(i);
        hold on
        %         if ismember(i, [1, 8])
        %             sc1 = scatter(pcue, prop(i, :), 180,...
        %                 'MarkerEdgeColor', 'w',...
        %                 'MarkerFaceColor', orange_color, 'MarkerFaceAlpha', alpha(i));
        %         end
        %s.MarkerFaceAlpha = alpha(i);
        
        hold on
        ind_point = interp1(lin3.YData, lin3.XData, 0.5);
        
        if ismember(i, [1, 8])
            sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
                'MarkerEdgeColor', 'w');
        end
        
        %sc2.MarkerFaceAlpha = alpha(i);
        
        %if mod(i, 2) ~= 0 || ismember(i, [1, 2])
            ylabel('P(choose experienced cue)', 'FontSize', 26);
        %end
        %if ismember(i, [7, 8]) || ismember(i, [2])
            xlabel('Described cue win probability', 'FontSize', 26);
       % end
        
        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
        if ismember(i, [1, 8])
            text(...
                ind_point + (0.05) * (1 + (-4 * (i == 1))) ,...
                .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
        end
        box off
        set(gca, 'Fontsize', 23);
        
    end
    
    %legend({'Logit reg. p(win experienced cue) = 0.1',...
    %       'Data p(win experience cue) = 0.1',...
    %       'Indifference point',...
    %       'Logit reg. p(win experienced cue) = 0.9',...
    %       'Data p(win experience cue) = 0.9'}, 'FontSize', 25, 'BigMarker');
    
    s1 = title(titles{exp_num});
    set(s1, 'Fontsize', 20)
    set(gca,'TickDir','out')

    mkdir('fig/exp', 'ind_curves');
    saveas(gcf, ...
        sprintf('fig/exp/ind_curves/ind_curve_exp_%d_sym_vs_lot.png',...
        exp_num));
    
    exp_num = exp_num + 1;
    
    set(gca,'TickDir','out')
    
end

