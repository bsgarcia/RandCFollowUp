%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
close all

selected_exp = [1];
ntrial = 20;

for exp_num = selected_exp
    
    data = de.extract_LE(exp_num);
    data.out = data.out==1;
    data.cfout = data.cfout==1;
    
    out = nan(data.nsub, 4);
    p = unique(data.p1);
    p = sort([p; unique(data.p2)]);
    for sub = 1:data.nsub
        for i = 1:length(p)
            mask_out = logical(...
            (data.cho(sub, :)==1).*(data.p1(sub,:)==p(i)) + (data.cho(sub, :)==2).*(data.p2(sub,:)==p(i)));
            mask_cfout = logical(...
            (data.cho(sub, :)==2).*(data.p1(sub,:)==p(i)) + (data.cho(sub, :)==1).*(data.p2(sub,:)==p(i)));
            out = data.out(sub, mask_out)';
            cfout = data.cfout(sub, mask_cfout)';
            o = shuffle([out; cfout]);
            o = o(1:ntrial);
            %data.cfout(sub, mask_cfout)'
            ev(sub, i) = mean(o...
                , 'all');
        end
    end

    data = de.extract_ED(exp_num);
    
    cho = compute_cho(data.p1, data.p2, ev, 5, 'soft');
    
    nsub = data.nsub;
    p1 = data.p1;
    p2 = data.p2;
   
    % ---------------------------------------------------------------------
    % Compute for each symbol p of chosing depending on described cue value
    % ---------------------------------------------------------------------
    p_lot = unique(p2)';
    psym = unique(p1)';
   
    prop = zeros(length(psym), length(p_lot));
    for l = 1:length(psym)
        for j = 1:length(p_lot)
            temp = cho(...
                logical((p2 == p_lot(j)) .* (p1== psym(l))));
            prop(l, j) = mean(temp == 1);
            
        end
    end
   
    subplot(1, length(selected_exp), 1);
    colors = orange;
    pwin = psym;
    alpha = linspace(.15, .95, length(psym));
    lin1 = plot(...
        linspace(psym(1)*100, psym(end)*100, 12), ones(12,1)*50,...
        'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
   
    for i = 1:length(pwin)
       
        hold on
       
        lin3 = plot(...
            p_lot.*100,  prop(i, :).*100,...
            'Color', colors(1,:), 'LineWidth', 1.5 ...% 'LineStyle', '--' ...
            );
        
        lin3.Color(4) = alpha(i);
       
        hold on      
       
        [xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
       
        sc2 = scatter(xout, yout, 15, 'MarkerFaceColor', lin3.Color,...
            'MarkerEdgeColor', 'w');
        sc2.MarkerFaceAlpha = alpha(i);
       
         ylabel('P(choose E-option) (%)');
        
        xlabel('S-option p(win) (%)');
       
        ylim([-0.08*100, 1.08*100]);
        xlim([-0.08*100, 1.08*100]);
       
        box off
    end
      
    set(gca,'TickDir','out')
    set(gca, 'FontSize', fontsize);
    xticks([0:20:100])
    xtickangle(0)
    %set(gca,'fontname','monospaced')  % Set it to times

    %axis equal

    clear pp p_lot psym temp err_prop prop
end

brickplot(ev'.*100,blue.*ones(4, 1), [-10, 110], 12, '', 'E-option p(win) (%)','Empirical p(win) (%)', p.*100, 0, [-10, 110], p.*100, 3, 0)
plot(0:10:100, 0:10:100, 'linestyle', '--', 'color', 'k')
yticks(0:10:100)



function cho = compute_cho(p_sym, p_lot, midpoints, beta1, decision_rule)
    sym = unique(p_sym);
    
    for sub = 1:size(p_sym,1)
        for t = 1:size(p_sym,2)
            
            v = midpoints(sub, p_sym(sub, t)==sym);
            
            if strcmp(decision_rule, 'argmax')
                if p_lot(sub,t) >= v
                    prediction = 2;
                else
                    prediction = 1;
                end

                cho(sub, t) = prediction;
            else
                cho(sub, t) = randsample(...
                    [1, 2], 1, true,...
                    smax([v, p_lot(sub, t)], beta1));
            end
        end
    end
end

function p = smax(x, beta1)
    p = exp(beta1 .* x)./sum(exp(beta1 .* x));
end
