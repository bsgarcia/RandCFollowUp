%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [5, 6.2];
displayfig = 'on';
sessions = [0, 1];
nagent = 10;
color = orange_color;
%-------------------------------------------------------------------------

for exp_num = selected_exp
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    
    % load data
    exp_name = char(filenames{round(exp_num)});
    
    data = d.(exp_name).data;
    sub_ids = d.(exp_name).sub_ids;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_sym_post_test(...
        data, sub_ids, idx, sess);        
       
    % ---------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ---------------------------------------------------------------------
    p_lot = unique(p2)';
    p_sym = unique(p1)';
    
    nsub = size(cho, 1);
    
    chose_symbol = zeros(nsub, length(p_lot), length(p_sym));
    for i = 1:nsub
        for j = 1:length(p_lot)
            for k = 1:length(p_sym)
                temp = ...
                    cho(i, logical(...
                    (p2(i, :) == p_lot(j)) .* (p1(i, :) == p_sym(k))));
                if length(temp)
                chose_symbol(i, j, k) = temp == 1;
                end
            end
        end
    end
    
    prop = zeros(length(p_sym), length(p_lot));
    temp1 = cho(:, :);
    for i = 1:length(p_sym)
        for j = 1:length(p_lot)
            temp = temp1(...
                logical((p2(:, :) == p_lot(j)) .* (p1(:, :) == p_sym(i))));
            prop(i, j) = mean(temp == 1);
            err_prop(i, j) = std(temp == 1)./sqrt(length(temp));
            
        end
    end
    
    X = reshape(...
        repmat(p_lot, nsub, 1), [], 1....
        );
    
    pp = zeros(length(p_sym), length(p_lot));
    
    for i = 1:length(p_sym)
        
        Y = reshape(chose_symbol(:, :, i), [], 1);
        
        [logitCoef, dev] = glmfit(X, Y, 'binomial','logit');
        
        pp(i, :) = glmval(logitCoef, p_lot', 'logit');
        
    end
%     
    figure(...
        'Renderer', 'painters',...
        'Position', [961, 1, 900, 600],...
        'visible', displayfig)
%     
%     %alpha = [fli linspace(.5, 1, 2)];
%     
    lin1 = plot(...
        linspace(p_sym(1), p_sym(end), 12), ones(12)*0.5,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
    hold on 
     alpha(1) = 0.5;
     alpha(length(p_sym)) = 0.85;
%     
    for i = 1:length(p_sym)
        if ~ismember(i, [1, length(p_sym)])
            continue
        end
      
%         hold on
%         hv = 'on';
% %         
%         lin3 = plot(...
%             p_lot,  pp(i, :),...
%             'Color', color, 'LineWidth', 4.5);
%         
%         lin3.Color(4) = alpha(i);

        hold on
        
%         
%         hold on
%         
%         if i == 8
%             hv = 'on';
%         else
%             hv = 'off';
%         end
%         
        sc1 = scatter(p_lot, prop(i, :), 180,...
            'MarkerEdgeColor', 'w',...
            'MarkerFaceColor', color, 'MarkerFaceAlpha', alpha(i),...
            'handlevisibility', 'off');
        
        hold on
%         
        er = errorbar(sc1.XData, prop(i, :), err_prop(i, :),...
            'Color', color, 'LineStyle', 'none', 'LineWidth', 1.7,...
            'handlevisibility', 'off');%, 'CapSize', 2);
        if i == 1
            er.Color = light_orange;
        end
            
%         
%         
%         try
%             ind_point = interp1(lin3.YData, lin3.XData, 0.5);
%             sc2 = scatter(ind_point, 0.5, 200, 'MarkerFaceColor', 'k',...
%             'MarkerEdgeColor', 'w', 'handlevisibility', 'off');
%             text(...
%             ind_point + (0.05) * (1 + (-4 * (i == 1))) ,...
%             .55, sprintf('%.2f', ind_point), 'Color', 'k', 'FontSize', 25);
%         catch
%             
%         end
%                 
        
        ylabel('P(choose experienced cue)', 'FontSize', 26);
        xlabel('Described cue win probability', 'FontSize', 26);
        
        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
        
          
        box off
        set(gca, 'Fontsize', 23);
%         
%         plot(p_sym(i) .*  ones(10, 1), linspace(.2, .8, 10), 'Color', 'k',...
%             'LineStyle', ':', 'LineWidth', 2.5, 'handlevisibility', 'off');
        hold on
        
    end
%     
    clear prop cho pp p_sym p_lot err_prop
    
    [cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_EE(exp_name, exp_num, d, idx, sess, 1, 1, nagent);
        % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    p_lot = unique(p2)';
    p_sym = unique(p1)';
    
    nsub = size(cho, 1);
    
    chose_symbol = zeros(nsub, length(p_lot), length(p_sym));
    for i = 1:nsub
        for j = 1:length(p_lot)
            for k = 1:length(p_sym)
                temp = ...
                    cho(i, logical(...
                    (p2(i, :) == p_lot(j)) .* (p1(i, :) == p_sym(k))));
                if length(temp)
                chose_symbol(i, j, k) = temp == 1;
                end
            end
        end
    end
    
    prop = zeros(length(p_sym), length(p_lot));
    temp1 = cho(:, :);
    for i = 1:length(p_sym)
        for j = 1:length(p_lot)
            temp = temp1(...
                logical((p2(:, :) == p_lot(j)) .* (p1(:, :) == p_sym(i))));
            prop(i, j) = mean(temp == 1);
            err_prop(i, j) = std(temp == 1)./sqrt(length(temp));
            
        end
    end
    
    X = reshape(...
        repmat(p_lot, nsub, 1), [], 1....
        );
    
    pp = zeros(length(p_sym), length(p_lot));
    
    for i = 1:length(p_sym)
        
        Y = reshape(chose_symbol(:, :, i), [], 1);
        
        [logitCoef, dev] = glmfit(X, Y, 'binomial','logit');
        
        pp(i, :) = glmval(logitCoef, p_lot', 'logit');
        
    end
   
    for i = 1:length(p_sym)
        if ~ismember(i, [1, length(p_sym)])
            continue
        end
      
        
        hold on
        hv = 'on';
        
        lin3 = plot(...
            p_lot,  pp(i, :),...
            'Color', light_blue, 'LineWidth', 4.5,...% 'LineStyle', '--' ...
            'handlevisibility', hv);
        
        lin3.Color(4) = alpha(i);
        
        hold on
        
        if i == 8
            hv = 'on';
        else
            hv = 'off';
        end
        
     
 

        box off
        set(gca, 'Fontsize', 23);

        
    end
    
    clear prop cho pp p_sym p_lot err_prop
    
      
    [cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_EE(...
        exp_name, exp_num, d, idx, sess, 2, 1, nagent);
        % ----------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ------------------------------------------------------------------------
    p_lot = unique(p2)';
    p_sym = unique(p1)';
    
    nsub = size(cho, 1);
    
    chose_symbol = zeros(nsub, length(p_lot), length(p_sym));
    for i = 1:nsub
        for j = 1:length(p_lot)
            for k = 1:length(p_sym)
                temp = ...
                    cho(i, logical(...
                    (p2(i, :) == p_lot(j)) .* (p1(i, :) == p_sym(k))));
                if length(temp)
                chose_symbol(i, j, k) = temp == 1;
                end
            end
        end
    end
    
    prop = zeros(length(p_sym), length(p_lot));
    temp1 = cho(:, :);
    for i = 1:length(p_sym)
        for j = 1:length(p_lot)
            temp = temp1(...
                logical((p2(:, :) == p_lot(j)) .* (p1(:, :) == p_sym(i))));
            prop(i, j) = mean(temp == 1);
            err_prop(i, j) = std(temp == 1)./sqrt(length(temp));
            
        end
    end
    
    X = reshape(...
        repmat(p_lot, nsub, 1), [], 1....
    );
    
    pp = zeros(length(p_sym), length(p_lot));
    
    for i = 1:length(p_sym)
        
        Y = reshape(chose_symbol(:, :, i), [], 1);
        
        [logitCoef, dev] = glmfit(X, Y, 'binomial','logit');
        
        pp(i, :) = glmval(logitCoef, p_lot', 'logit');
        
    end
   
    for i = 1:length(p_sym)
        if ~ismember(i, [1, length(p_sym)])
            continue
        end
      
        
        hold on
        hv = 'on';
        
        lin3 = plot(...
            p_lot,  pp(i, :),...
            'Color', light_green, 'LineWidth', 4.5,...% 'LineStyle', '--' ...
            'handlevisibility', hv);
        
        lin3.Color(4) = alpha(i);
        
        hold on
        
        if i == 8
            hv = 'on';
        else
            hv = 'off';
        end
          
 

        box off
        set(gca, 'Fontsize', 23);

        
    end
    
    clear prop cho pp p_sym p_lot err_prop

     s1 = title(sprintf('Exp. %s', num2str(exp_num)));
%     set(s1, 'Fontsize', 20)
%     set(gca,'TickDir','out')
%     set(gca, 'FontSize', 23);
    mkdir('fig/exp', 'ind_curves_sym_vs_lot_with_likert');
    saveas(gcf, ...
        sprintf('fig/exp/ind_curves_sym_vs_lot_with_likert/exp_%s_sym_vs_lot.png',...
        num2str(exp_num)));
    
%     %     exp_num = exp_num + 1;
    clear prop cho pp p_sym p_lot err_prop
    
end

