%% PARAMETERS 
%rng(1)
%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

% figure params
figure('Renderer', 'painters', 'position', [0, 0, 500*4, 350],...
    'visible', 'on')
fontsize = 10;


% Simulations params
%-------------------------------------------------------------------------
% force fitting 
force = true;

% what exp to use to simulate the data
exp_num = 3;

sim_exp_num = 3;

% load data
name = char(filenames{round(exp_num)});
data = d.(name).data;
sub_ids = d.(name).sub_ids;
d.(name).nsub = 10;
nsub = d.(name).nsub;

sess = 0;
model = 1;
decision_rule = 2;
nagent = 1;

options.alpha1 = ones(d.(name).nsub, 2) .* 0.3;
options.beta1 = ones(d.(name).nsub, 2) .* 1;
options.random = false;

options.degradors = ones(d.(name).nsub, 2);

options.degradors(:, 2) = ones(d.(name).nsub, 1) .* 0.2; 

%% COMPUTATION

% Run simulations
% ------------------------------------------------------------------------
[cho, cont1, cont2, p1, p2, ev1, ev2] = sim_exp_ED(...
    name, exp_num, d, idx, sess, model, decision_rule, nagent, options);


% Compute p(choose symbol) for each sub and each symbol
%-------------------------------------------------------------------------
chose_symbol = zeros(nsub, length(p_lot), length(psym));
for i = 1:nsub
    for j = 1:length(p_lot)
        for k = 1:length(psym)
%             temp = cho(i, logical(...
%                         (p2(i, :) == p_lot(j)) .* (p1(i, :) == psym(k))));
             chose_symbol(i, j, k) = randsample([0, 1], 1, true, [p_lot(j), psym(k)]);
        
            %chose_symbol(i, j, k) = temp == 1;
        end
    end
end
 for j = 1:length(p_lot)
    for l = 1:length(psym)
       
        prop(l, j) = mean(chose_symbol(:,  j, l));
        err_prop(l, j) = std(temp == 1)./sqrt(nsub);
        
    end
end
 



% Fit a 2 param logistic function to each symbol choice sequence for each 
% sub
%-------------------------------------------------------------------------
fitted_p_choose_symbol = zeros(nsub, length(psym), length(p_lot));
fitted_p_choose_symbol2 = zeros(nsub, length(psym), length(p_lot));


for sub = 1:nsub
    
    fprintf('Fitting sub %d \n', sub);
    
    for i = 1:length(psym)
        Y(i, :) = reshape(chose_symbol(sub, :, i), [], 1);
        X(i, :) = p_lot;
    end
    
    try
        if force
            error('fitting');
        end
        param = load(sprintf('data/method_xp_%d_2.mat', sim_exp_num));
        beta1 = param.beta1;
        midpoint = param.midpoint;
        tosave = false;
    catch
        tosave = true;
        options = optimset(...
            'Algorithm',...
            'interior-point',...
            'Display', 'off',...
            'MaxIter', 10000,...
            'MaxFunEval', 10000);
        
        [params(sub,:), res(sub)] = fmincon(...
            @(x) tofit2(x, X, Y),...
            [1, .5, .5, .5, .5, .5, .5, .5, .5],...
            [], [], [], [],...
            [0.01, 0, 0, 0, 0, 0, 0, 0 ,0],...
            [inf, 1, 1, 1, 1, 1, 1, 1, 1],...
            [],...
            options...
        );
    
        [beta2(sub), res(sub)] = fmincon(...
            @(x) tofit(x, X, Y),...
            [1],...
            [], [], [], [],...
            [0.01],...
            [inf],...
            [],...
            options...
        );
        beta1(sub) = params(sub, 1);
        midpoint(sub, :) = params(sub, 2:9);
        options = optimset('Display','off');
        
        for i = 1:length(psym)
            midpoint2(sub, i) = lsqcurvefit(...
                @(midpoint2, x) (logfun(x, midpoint2, beta2(sub))),...
                [0], X(i, :)', Y(i, :)', [0], [1], options);
        end
        
    end
    
    for i = 1:length(psym)
        fitted_p_choose_symbol(sub, i, :) = ...
            logfun(X(i, :)', midpoint(sub, i), beta1(sub));
        fitted_p_choose_symbol2(sub, i, :) = ...
            logfun(X(i, :)', midpoint2(sub, i), beta2(sub));
    end
    
end

if tosave
    param.midpoint = midpoint;
    param.beta1 = beta1;
    param.res = res;
    
    save(sprintf('data/method_xp_%d_2.mat', sim_exp_num),...
        '-struct', 'param');
end


%% PLOTS

% Brickplot midpoint based on fit
% ------------------------------------------------------------------- %
subplot(2, 3, 1)
ev = unique(p1);
varargin = ev;
x_values = ev;
x_lim = [0, 1];

slope1 = add_linear_reg(midpoint, ev, orange_color);
hold on

brickplot2(...
    midpoint', 0.02,...
    orange_color.*ones(3, 8)', ...
    [0, 1], fontsize,...
    '',...
    '',...
    '', varargin, 1, x_lim, x_values);
box off

title('Fitted midpoints');

% Brickplot midpoint based on fit 2
% ------------------------------------------------------------------- %
subplot(2, 3, 2)
ev = unique(p1);
varargin = ev;
x_values = ev;
x_lim = [0, 1];

slope1 = add_linear_reg(midpoint2, ev, orange_color);
hold on


brickplot2(...
    midpoint2', 0.02,...
    orange_color.*ones(3, 8)', ...
    [0, 1], fontsize,...
    '',...
    '',...
    '', varargin, 1, x_lim, x_values);
box off

title('Fitted midpoints 2');
%Brickplot midpoint based on actual intersections 
%-----------------------  ------------------------------------- %
subplot(2, 3, 3)

y1 = ones(1, 11).* .5;
x = linspace(0, 1, 11);

hold on

for sub = 1:nsub
    for i = 1:length(psym)
        
        y2 = reshape(fitted_p_choose_symbol2(sub, i, :), [], 1);
        [xout(sub, i), yout] = intersections(x, y2, x, y1);

        box off
    end
end

slope1 = add_linear_reg(xout, ev, orange_color);


brickplot2(...
    xout',  0.02,...
    orange_color.*ones(3, 8)', ...
    [0, 1], fontsize,...
    '',...
    '',...
    '', varargin, 1, x_lim, x_values);
box off
title('Intersection midpoints');


% Indifference curves aggregation of fits
% -----------------------  ------------------------------------- %
subplot(2, 3, 4)

alpha = linspace(.15, .95, length(psym));

lin1 = plot(...
    linspace(0, 1, 10), ones(10,1).*.5,...
    'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
hold on

for i = 1:length(psym)
    
    Y = reshape(mean(fitted_p_choose_symbol(:, i, :), 1), [], 1);
    
    lin3 = plot(...
        p_lot, Y,...
        'Color', orange_color, 'LineWidth', 4.5);
    
    lin3.Color(4) = alpha(i);
    
    hold on
    
    [xout2(i), yout] = intersections(lin3.XData, lin3.YData,...
        lin1.XData, lin1.YData);
    
    sc2 = scatter(xout2(i), yout, 80, 'MarkerFaceColor', lin3.Color,...
        'MarkerEdgeColor', 'w');
    sc2.MarkerFaceAlpha = alpha(i);
    
     
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    
    box off
end

title('Averaged fitted curves');
% Indifference curves aggregation of fits
% -----------------------  ------------------------------------- %
subplot(2, 3, 5)

alpha = linspace(.15, .95, length(psym));

lin1 = plot(...
    linspace(0, 1, 10), ones(10,1).*.5,...
    'LineStyle', ':', 'Color', [0, 0, 0], 'HandleVisibility', 'off');
hold on

for i = 1:length(psym)
        
    lin3 = plot(...
        p_lot, prop(i,:),...
        'Color', orange_color, 'LineWidth', 4.5);
    
    lin3.Color(4) = alpha(i);
    
    hold on
    
    [xout3, yout] = intersections(lin3.XData, lin3.YData,...
        lin1.XData, lin1.YData);
    
    sc2 = scatter(xout3, yout, 80, 'MarkerFaceColor', lin3.Color,...
        'MarkerEdgeColor', 'w');
    sc2.MarkerFaceAlpha = alpha(i);
    
     
    ylim([-0.08, 1.08]);
    xlim([-0.08, 1.08]);
    
    box off
end

title('Averaged bhv curves');


% comparison
% -----------------------  ------------------------------------- %
subplot(2, 3, 6)

plot(mean(xout), xout2, 'color', orange_color,...
    'markerfacecolor', orange_color, 'linestyle', '--', 'marker', 'o');
title('comparison of ind and agg. intersections')



%% side functions
% fit functions
% ------------------------------------------------------------------------
function err = tofit(params, X, Y)
    options = optimset('Display','off');
    temp = params(1);
    midpoints = params(2:end);
    for i = 1:size(Y, 1)
        residuals(i,:) = logfun(X(i,:)', midpoints(i), temp) - Y(i,:)';
    end
    err = sum(residuals.^2, 'all');
end

function sumres = tofit(temp, X, Y)
    options = optimset('Display','off');
    for i = 1:size(Y, 1)
        [throw, throw2, residuals(i, :)] = lsqcurvefit(...
            @(midpoint, x) (logfun(x, midpoint, temp)),...
            [0], X(i, :)', Y(i, :)', [0], [1], options);

    end
    sumres = sum(residuals.^2, 'all');
end

function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(temp.*(x-midpoint(1))));
end
