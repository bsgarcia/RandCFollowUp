close all
clear all

% data
p_lot = [0:10]./10;

orange = [0.8500, 0.3250, 0.0980];


% simulate a rational agent
% 1 = chose symbol
% 0 = chose lottery
% row = n symbol
% col = n choice per sym
p_sym = [.7];

for i = 1:length(p_sym)
    for j = 1:length(p_lot)
        
        Y(i, j) = p_sym(i) > p_lot(j);
%         if p_lot(j) == .3
%            Y(i, j) = p_sym(i) < p_lot(j);
% 
%         end
    end
end
% 
% for i = 1:length(p_sym)
%     count = 0;
%     for j = 1:length(p_sym)
%         if i ~= j
%             count = count + 1;
% 
%             Y(i, count) = p_sym(i) > p_sym(j);
%         end
%     end
% end


X = p_lot;
% considering one symbol p = .1


% FIT 
options = optimset(...
    'Algorithm',...
    'interior-point',...
    'Display', 'off',...
    'MaxIter', 10000,...
    'MaxFunEval', 10000);
[params, nll] = fmincon(...
    @(x) tofit_mle2(x, X, Y),...
    [1, ones(1, length(p_sym)) .* .5],...
    [], [], [], [],...
    [0.01, zeros(1, length(p_sym))],...
    [100, ones(1, length(p_sym))],...
    [],...
    options...
    );

% % plot behavioral data
% figure
% plot(X, Y, 'linewidth', 2);
% title('Behavior');
% 

% plot fitted curves
figure
for i = 1:length(p_sym)
    lin3 = plot(X.*100, logfun(X, params(i+1), params(1)).*100, 'linewidth', 2, 'color', orange);
    hold on
    %scatter(X.*100, Y.*100, 80, 'markerfacecolor', orange, 'markeredgecolor', 'w', 'markerfacealpha', .7)

    xlim([-10, 110])
    ylim([-10, 110])
    hold on
end
%title('Fit');
xlabel('S-option p(win) (%)');
ylabel('P(choose E-option) (%)');

lin1 = plot([10, 90], [50, 50], 'color', 'k', 'linestyle', ':');

disp(params)

[xout, yout] = intersections(lin3.XData, lin3.YData, lin1.XData, lin1.YData);
scatter(xout, yout, 80, 'markerfacecolor', orange, 'markeredgecolor', 'w')
set(gca, 'tickdir', 'out');
set(gca, 'fontsize', 15);
box off
%p.Color(4) = .8;
H=gca;
H.LineWidth=1.3
saveas(gcf, 't1.png');

% plot estimates
figure
title('Estimates');
scatter(p_sym, params(2:end));
xlim([0 1])
ylim([0 1])


        
function nll = tofit_mle2(params, X, Y)

    options = optimset('Display','off');
    temp = params(1);
    midpoints = params(2:end);
    ll = 0;
    for i = 1:size(Y, 1)
        yhat = logfun(X, midpoints(i), temp);
        ll = ll + (1/numel(yhat)) * nansum(log(yhat) .* Y(i,:) + log(1-yhat).*(1-Y(i,:))); 
    end
    if isnan(ll)
        error('is nan')
    end
    nll = -ll;
end



function nll = tofit(params, X, Y)
    options = optimset('Display','off');
    temp = params(1);
    midpoints = params(2:end);
    ll = 0;
    for i = 1:size(Y, 1)
        yhat = logfun(X, midpoints(i), temp);
        ll = ll + nansum(log(yhat) .* Y(i,:) + log(1-yhat).*(1-Y(i,:))); 
    end
    nll = -ll;
end

function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(temp.*(x-midpoint)));
end
