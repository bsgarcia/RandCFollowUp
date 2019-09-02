close all
clear all

addpath './'

%------------------------------------------------------------------------
name = 'interleaved';
folder = 'data/';
data_filename = sprintf('%sfull',name);
fit_folder = 'data/fit/';
fit_filename = name;
quest_filename = sprintf('data/questionnaire_%s', name);

%------------------------------------------------------------------------
[data,sub_ids, exp, sim] = DataExtraction.get_data(...
    sprintf('%s%s', folder, data_filename));

%------------------------------------------------------------------------
% Set parameters
%------------------------------------------------------------------------
catch_threshold = 1;
n_best_sub = 0;
allowed_nb_of_rows = [258, 288, 255, 285];

%------------------------------------------------------------------------
% get parameters
%------------------------------------------------------------------------
ncond = max(data(:, 13));
nsession = max(data(:, 20));
sub_ids = unique(data(:, 1));
%sub_ids = sub_ids(2);
sim = 1;
choice = 2;

%------------------------------------------------------------------------
% Exclude subjects and retrieve data 
%------------------------------------------------------------------------
[sub_ids, corr_catch] = DataExtraction.exclude_subjects(...
    data, sub_ids, exp, catch_threshold, n_best_sub, allowed_nb_of_rows);

fprintf('N = %d \n', length(sub_ids));
fprintf('Catch threshold = %.2f \n', catch_threshold);

[cho1, out1, corr1, con1, rew] = DataExtraction.extract_learning_data(...
    data, sub_ids, exp);

[corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2] = ...
    DataExtraction.extract_elicitation_data(data, sub_ids, exp, 0);

% ------------------------------------------------------------------------
% Split depending on optimism tendency
% -----------------------------------------------------------------------
data2 = load(sprintf('%s%s', fit_folder, fit_filename));
parameters = data2.data('parameters');
delta_alpha = parameters(:, 2, 2) - parameters(:, 3, 2);
[sorted, idx_order] = sort(delta_alpha);
if n_best_sub == 0
    idx_order = idx_order(1:size(cho, 1));
else
    idx_order = idx_order(1:n_best_sub);
end

cho = cho(idx_order, :);
p2 = p2(idx_order, :);
p1 = p1(idx_order, :);

%------------------------------------------------------------------------
% Compute corr choice rate learning
%------------------------------------------------------------------------
corr_rate_learning = zeros(size(corr1, 1), size(corr1, 2)/4, 4);

for sub = 1:size(corr1, 1)
    for t = 1:size(corr1, 2)/4
        for j = 1:4
            d = corr1(sub, con1(sub, :) == j);
            corr_rate_learning(sub, t, j) = mean(d(1:t));
            
            corr_rate(sub, t, j) = d(t);
        end
    end
end


%------------------------------------------------------------------------
% Compute corr choice rate elicitation
%------------------------------------------------------------------------
corr_rate_elicitation = zeros(size(corr, 1), 1);

for sub = 1:size(corr, 1)
    mask_equal_ev = ev1(sub, :) ~= ev2(sub, :);
    d = corr(sub, mask_equal_ev);
    corr_rate_elicitation(sub) = mean(d);
end
% ------------------------------------------------------------------------
% Correlate corr choice rate vs quest
% -----------------------------------------------------------------------
quest_data = load(quest_filename);
if strcmp(quest_filename, 'data/questionnaire_block')
    quest_data = quest_data.questionnaireblock;
else
    quest_data = quest_data.questionnairedatarandc;
end
for i = 1:length(sub_ids)
    sub = sub_ids(i);
    mask_quest = arrayfun(@(x) x==-7, quest_data{:, 'quest'});
    mask_sub = arrayfun(...
        @(x) strcmp(sprintf('%.f', x), sprintf('%.f', sub)),...
        quest_data{:, 'sub_id'});
    crt_scores(i) = sum(...
        quest_data{logical(mask_quest .* mask_sub), 'val'});
end

%------------------------------------------------------------------------
% Plot correlations 
% -----------------------------------------------------------------------
% LEARNING PHASE
% -----------------------------------------------------------------------
figure
scatterCorr(...
    mean(corr_rate_learning, [2, 3])',...
    crt_scores./14,...
    [0.4660    0.6740    0.1880],...
    0.5,...
    2,...
    1);
ylabel('CRT Score');
xlabel('Correct choice rate learning');
saveas(gcf, sprintf('fig/exp/%s/corr_learning_crt.png', name));

%------------------------------------------------------------------------
% ELICITATION PHASE
% -----------------------------------------------------------------------
figure
scatterCorr(...
    corr_rate_elicitation',...
    crt_scores./14,...
    [0.4660    0.6740    0.1880],...
    0.5,...
    2,...
    1);
ylabel('CRT Score');
xlabel('Correct choice rate elicitation');
saveas(gcf, sprintf('fig/exp/%s/corr_elicitation_crt.png', name));

%------------------------------------------------------------------------
% ELICITATION VS LEARNING 
% -----------------------------------------------------------------------
figure
scatterCorr(...
    corr_rate_elicitation',...
    mean(corr_rate_learning, [2, 3])',...
    [0.4660    0.6740    0.1880],...
    0.5,...
    2,...
    1);
ylabel('Correct choice rate learning');
xlabel('Correct choice rate elicitation');
saveas(gcf, sprintf('fig/exp/%s/corr_elicitation_learning.png', name));

%------------------------------------------------------------------------
% PLOT
%------------------------------------------------------------------------
%i = 1;
titles = {'0.9 vs 0.1', '0.8 vs 0.2', '0.7 vs 0.3', '0.6 vs 0.4'};
figure('Renderer', 'painters', 'Position', [42,124,2320,900])

for cond = 1:4
    subplot(1, 4, cond)

    surfaceplot(...
        corr_rate(:, :, cond)',...
        ones(3) * 0.5,...
        [0.4660    0.6740    0.1880],...
        1,...
        0.38,...
        -0.01,...
        1.01,...
        15,...
        titles{cond},...
        'trials',...
        'correct choice rate' ...
    );

    i = i + 1;
end
saveas(gcf, sprintf('fig/exp/%s/learning_curve.png', name));

% ----------------------------------------------------------------------
% Compute for each symbol p of chosing depending on described cue value
% ------------------------------------------------------------------------
pcue = [0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1];
psym = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];
plearn = zeros(size(cho, 1), length(pcue), length(psym));
for i = 1:size(cho, 1)
    for j = 1:length(pcue)
        for k = 1:length(psym)
            temp = cho(i, logical((p2(i, :) == pcue(j)) .* (p1(i, :) == psym(k))));           
            plearn(i, j, k) = temp == 1;
        end
    end
end

titles = {'Low \Delta\alpha', 'High \Delta\alpha', 'All'};
tt = 0;
nsub = size(cho, 1);
nsub_divided = ceil(nsub/2);
% ----------------------------------------------------------------------
% PLOT P(learnt value) vs Described Cue
% ------------------------------------------------------------------------
% for k = {1:ceil(size(cho, 1)/2), ceil(size(cho, 1)/2)+1:size(cho, 1)}
for k = {1:nsub_divided, nsub_divided:nsub, 1:nsub}
    k = k{:};
    tt = tt + 1;
    prop = zeros(length(psym), length(pcue));
    for j = 1:length(pcue)
        for l = 1:length(psym)
           temp1 = cho(k, :);
           temp = temp1(logical((p2(k, :) == pcue(j)) .* (p1(k, :) == psym(l))));
           prop(l, j) = mean(temp == 1);
       end
    end
   
    X = repmat(pcue, size(k, 2), 1);
    pp = zeros(length(psym), length(pcue));
    for i = 1:length(psym)
        Y = plearn(k, :, i);
        %     [B,dev,stats] = mnrfit(X, Y);
        %     pp(i, :) = mnrval(B, plearn(:, :, i));
        [logitCoef, dev] = glmfit(...
            reshape(X, [], 1), reshape(plearn(k, :, i), [], 1), 'binomial','logit');
        pp(i, :) = glmval(logitCoef, pcue', 'logit');
    end

    figure('Renderer', 'painters', 'Position', [961, 1, 960, 1090])
    suptitle(titles{tt});
    pwin = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];

    for i = 1:length(psym)
        
        subplot(4, 2, i)
        lin1 = plot(...
            linspace(0, 1, 12), ones(12)*0.5, 'LineStyle', ':', 'Color', [0, 0, 0]);
        
        hold on
        lin2 = plot(...
            ones(10)*pwin(i),...
            linspace(0.1, 0.9, 10),...
            'LineStyle', '--', 'Color', [0, 0, 0], 'LineWidth', 0.6);
        
        hold on
        lin3 = plot(...
            pcue,  pp(i, :),... %'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
            'Color', [0.4660    0.6740    0.1880] ...
            );
        
        hold on
        sc1 = scatter(pcue, prop(i, :),...
            'MarkerEdgeColor', 'w',...
            'MarkerFaceColor', [0.4660    0.6740    0.1880]);
        s.MarkerFaceAlpha = 0.7;
        
        hold on 
        ind_point = interp1(lin3.YData, lin3.XData, 0.5);
        sc2 = scatter(ind_point, 0.5, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'w');
       
        if mod(i, 2) ~= 0
            ylabel('P(choose learnt value)');
        end
        if ismember(i, [7, 8])
            xlabel('Described cue win probability');
        end
       
        if i < 6
            text(pwin(i)+0.03, 0.8, sprintf('P(win) = %0.1f', pwin(i)), 'FontSize', 7);
        else

            text(pwin(i)-0.30, 0.8, sprintf('P(win) = %0.1f', pwin(i)), 'FontSize', 7);
        end

        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);
       
        text(ind_point + 0.05, .55, sprintf('%.2f', ind_point), 'Color', 'r');

    end
    saveas(gcf, sprintf('fig/exp/%s/explicite_implicite.png', name));

end


% ----------------------------------------------------------------------
% Plot violins
% % --------------------------------------------------------------------
[corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2] = ...
    DataExtraction.extract_elicitation_data(data, sub_ids, exp, 2);

i = 1;
for p = pwin
    mn(i, :) = cho(p1(:, :) == p)./100;
    i = i + 1;
end

colors = [0.3963    0.2461    0.3405;...
    1 0 0;...
    0.7875    0.1482    0.8380;...
    0.4417    0.4798    0.7708;...
    0.5992    0.6598    0.1701;...
    0.7089    0.3476    0.0876;...
    0.2952    0.3013    0.3569;...
    0.1533    0.4964    0.2730];
figure('Renderer', 'painters', 'Position', [326,296,1064,691])
skylineplot(...
    mn, colors,...
    -0.08, 1.08, 20, 'Slider choices' , 'P(win of learnt value)',...
    'Estimated probability', pwin...
);

%ylim([-0.005, 1.08]);
%xlim([-0.08, 1.08]);
saveas(gcf, sprintf('fig/exp/%s/slider.png', name));
