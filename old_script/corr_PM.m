% -------------------------------------------------------------------%
% This script finds the best fitting Values for each exp             %
% then plots the figs                                                %
% -------------------------------------------------------------------%
init;
% -------------------------------------------------------------------%

selected_exp = [1, 2, 3, 8];

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
    
    
    %
    if exp_num == 8
        [corrx, cho(starting:ending, 1:44), out2, p1_ED(starting:ending, 1:44), p2_ED(starting:ending, 1:44), ev1, ev2, ctch, cont1, cont2, dist] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
        p1_ED(starting:ending, 45:end) = -1;
        p2_ED(starting:ending, 45:end) = -1;
        cho(starting:ending, 45:end) = -1;
        
        [corrx, choxx, out, p1_PM(starting:ending, 1:4), p21, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_estimated_probability_post_test(d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
        p1_PM(starting:ending, 5:end) = -1;
    else
        [corrx, cho(starting:ending, :), out2, p1_ED(starting:ending, :), p2_ED(starting:ending, :), ev1, ev2, ctch, cont1, cont2, dist] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
        [corrx, choxx, out, p1_PM(starting:ending, :), p21, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_estimated_probability_post_test(d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    end
    
    
    arr = starting:ending ;
    for sub = 1:size(choxx, 1)
        i = 1;
        
        for p = unique(p1_PM(arr(sub), :), 'stable')
            if p ~= -1
                cho_PM(arr(sub), i) = choxx(sub, (p1_PM(arr(sub), :) == p))./100;
                i = i + 1;
            end
        end
    end
    
    if exp_num == 8
        cho_PM(arr, 5:end) = -1;
    end
    nsub = d.(exp_name).nsub;
    
    starting = starting + nsub;
    % -------------------------------------------------------------------%
end

scatterCorr(...
        p1_PM(p1_PM~=-1),....
        cho_PM(cho_PM~=-1),...
        magenta_color,...
        0.3,...
        1,...
        1,...
        'w',...
        0 ...
        );
    
    set(gca,'TickDir','out')

    ylabel('PM estimation');
    xlabel('p');
    
    return 
%d.(name).nsub = size(cho, 1);
% ----------------------------------------------------------------------
% Compute for each symbol p of chosing depending on described cue value
% ------------------------------------------------------------------------
p_lot = unique(p2_ED)';
p_sym = unique(p1_ED)';
p_sym(p_sym == 0) = [];
p_sym(p_sym == -1) = [];
p_lot(p_lot == -1) = [];


%     cho = cho(1:60, :);
%     p1 = p1(1:60, :);
%     p2 = p2(1:60, :);
nsub = size(cho, 1);
p1_ = p1_ED;
p2_ = p2_ED;

chose_symbol = zeros(nsub, length(p_lot), length(p_sym));
for i = 1:nsub
    for j = 1:length(p_lot)
        for k = 1:length(p_sym)
            try
                temp = ...
                    cho(i, logical(...
                    (cho(i, :) ~= -1) .* (p2_(i, :) == p_lot(j)) .* (p1_(i, :) == p_sym(k))));
                chose_symbol(i, j, k) = temp == 1;
            catch
                
            end
        end
    end
end

prop = zeros(length(p_sym), length(p_lot));
temp1 = cho(:, :);
for i = 1:length(p_sym)
    for j = 1:length(p_lot)
        temp = temp1(...
            logical((cho(:, :) ~= -1) .* (p2_(:, :) == p_lot(j)) .* (p1_(:, :) == p_sym(i))));
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
    %
    
    
    hold on
    hv = 'on';
    
    figure('visible', 'off');
    
    lin3 = plot(...
        p_lot,  pp(i, :),...
        'handlevisibility', 'off', 'visible', 'off');
    %
    ind_point(i)  = interp1(lin3.XData, lin3.YData, 0.5);
    clear lin3
    
    
end


