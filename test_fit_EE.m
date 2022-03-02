close all
clear all

% data
p_lot = [0:10]./10;


% simulate a rational agent
% 1 = chose symbol
% 0 = chose lottery
% row = n symbol
% col = n choice per sym
p_sym =[.1 .2 .3 .4 .6 .7 .8 .9];
alpha = linspace(.15, .95, length(p_sym));

% for i = 1:length(p_sym)
%     for j = 1:length(p_lot)
%         Y(i, j) = p_sym(i) > p_lot(j);
%     end
% end
rng(1)
nsub = 50;
f = randi([55, 98], nsub)./100;%random('Beta', .9, .3, [nsub,1]);
Y = zeros(nsub, length(p_sym), length(p_sym));

for sub = 1:nsub
for i = 1:length(p_sym)
    count = 0;
    for j = 1:length(p_sym)
        if i ~= j
            count = count + 1;

            Y(sub, i, j) = (p_sym(i).*f(sub)) >p_sym(j);
        end
    end
end
end

green = [61/255, 176/255, 125/255];

X = p_sym;
% considering one symbol p = .1


for sub = 1: nsub
% FIT 
options = optimset(...
    'Algorithm',...
    'interior-point',...
    'Display', 'off',...
    'MaxIter', 10000,...
    'MaxFunEval', 10000);
[params(sub,:), nll(sub)] = fmincon(...
    @(x) tofit_mle2(x, X, reshape(Y(sub,:, :), [8, 8])),...
    [1, ones(1, length(p_sym)) .* .5],...
    [], [], [], [],...
    [0.01, zeros(1, length(p_sym))],...
    [inf, ones(1, length(p_sym))],...
    [],...
    options...
    );
end
% plot behavioral data
figure

for sym = 1:length(p_sym)
    m(sym, :) = mean(Y(:, sym, :));
end
for i = 1:length(p_sym) 
    x = X((1:8)~=i);
    p = plot(x, m(i, (1:8)~=i), 'linewidth', 2, 'Color', green);
    hold on

    p.Color(4) = alpha(i);
end
ylim([-.1, 1.1])
title('Behavior');



% plot fitted curves
figure
for i = 1:length(p_sym)
    p = plot(X, mean(logfun(X, params(:, i+1), params(:,1))), 'linewidth', 2, 'Color', green);
    hold on
    p.Color(4) = alpha(i);

end
ylim([-.1, 1.1])


title('Fit');

%p.Color(4) = .8;


% plot estimates
figure
title('Estimates');
scatter(p_sym, mean(params(:, 2:end)));
xlim([0 1])
ylim([0 1])


% disp temperature and midpoint
disp(params);
        
function nll = tofit_mle2(params, X, Y)

    options = optimset('Display','off');
    temp = params(1);
    midpoints = params(2:end);
    ll = 0;
    for i = 1:size(Y, 1)
        rm = 1:8;
        x = X(rm~=i);
        yhat = logfun(x, midpoints(i), temp);
        y = Y(i, rm~=i);
        ll = ll + (1/numel(yhat)) * nansum(log(yhat) .* y + log(1-yhat).*(1-y)); 
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
        yhat = logfun(X(i,:)', midpoints(i), temp);
        ll = ll + nansum(log(yhat) .* Y(i,:)' + log(1-yhat).*(1-Y(i,:)')); 
    end
    nll = -ll;
end

function p = logfun(x, midpoint, temp)
    p = 1./(1+exp(temp.*(x-midpoint)));
end
