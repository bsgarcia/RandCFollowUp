close all
clear all

addpath './'

%------------------------------------------------------------------------
data_filename = 'data/interleavedfull';
quest_filename = 'data/questionnaire_interleaved';

%------------------------------------------------------------------------
data = load(data_filename);
if strcmp(data_filename, 'data/blockfull')
    data = data.blockfull;
else
    data = data.full;
end

%------------------------------------------------------------------------
% Set parameters
%------------------------------------------------------------------------
catch_threshold = 1;
n_best_sub = 25;
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
% Define columns idx
%------------------------------------------------------------------------
idx.rtime = 6;
idx.cond = 13;
idx.sess = 20;
idx.trial_idx = 12;
idx.cho = 9;
idx.out = 7;
idx.corr = 10;
idx.rew = 19;
idx.catch = 25;
idx.elic = 3;
idx.sub = 1;
idx.p1 = 4;
idx.p2 = 5;
idx.ev1 = 23;
idx.ev2 = 24;
idx.dist = 28;
idx.plot = 29;
idx.cont1 = 14;
idx.cont2 = 15;
%idx.prolific = 2;

%------------------------------------------------------------------------
% Exclude subjects and retrieve data 
%------------------------------------------------------------------------
[sub_ids, corr_catch] = exclude_subjects(data, sub_ids, idx,...
    catch_threshold, n_best_sub, allowed_nb_of_rows);

fprintf('N = %d \n', length(sub_ids));
fprintf('Catch threshold = %.2f \n', catch_threshold);

[cho1, out1, corr1, con1, rew] = extract_learning_data(...
    data, sub_ids, idx);

[corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2] = extract_elicitation_data(...
    data, sub_ids, idx, 0);

%------------------------------------------------------------------------
% Split depending on optimism tendency
% -----------------------------------------------------------------------
% data = load('data/fit/online_exp');
% parameters = data.data('parameters');
% delta_alpha = parameters(:, 2, 2) - parameters(:, 3, 2);
% [sorted, idx_order] = sort(delta_alpha);
% idx_order = idx_order(1:size(cho, 1));
% cho = cho(idx_order, :);
% p2 = p2(idx_order, :);
% cont1 = cont1(idx_order, :);
% 
% psym = zeros(4, 2);
% for con = 1:4
%     for c = 1:2
%         temp = out1(logical((con1 == con) .* (cho1 == c))) == 1;
%         psym(con , c) = mean(temp);
%     end
% end
% % 
% % % psym = zeros(8);
% % % i = 1;
% % % for cont = numel(unique(cont1))
% % %         temp = out2(cont1 == );
% % %         psym(i) = mean(temp);
% % %         i = i + 1;
% % % end
% % % 
% figure
% bar(psym);
% ylabel('P(outcome=1)')
% xlabel('Conditions')
% legend('Option 1', 'Option 2')
% ylim([0, 1.0]);

%------------------------------------------------------------------------
% Compute corr choice rate learning
%------------------------------------------------------------------------
corr_rate_learning = zeros(size(corr1, 1), size(corr1, 2)/4, 4);

for sub = 1:size(corr1, 1)
    for t = 1:size(corr1, 2)/4
        for j = 1:4
            d = corr1(sub, con1(sub, :) == j);
            corr_rate_learning(sub, t, j) = mean(d(1:t));
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
%------------------------------------------------------------------------
% PLOT
%------------------------------------------------------------------------
%i = 1;
titles = {'0.9 vs 0.1', '0.8 vs 0.2', '0.7 vs 0.3', '0.6 vs 0.4'};
figure;
for cond = 1:4
    subplot(1, 4, cond)

    reversalplot(...
        corr_rate_learning(:, :, cond)',...
        [],...
        [],...
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

% titles = {'Low \Delta\alpha', 'High \Delta\alpha'};
% tt = 0;
% ----------------------------------------------------------------------
% PLOT P(learnt value) vs Described Cue
% ------------------------------------------------------------------------
for k = {1:size(cho, 1)}
    %tt = tt + 1;
    k = k{:};
    prop = zeros(length(psym), length(pcue));
    for j = 1:length(pcue)
        for l = 1:length(psym)
           temp1 = cho(k, :);
           temp = temp1(logical((p2(k, :) == pcue(j)) .* (p1(k, :) == psym(l))));
           prop(l, j) = mean(temp == 1);
       end
    end
   
    X = repmat(pcue, size(cho, 1), 1);
    pp = zeros(length(psym), length(pcue));
    for i = 1:length(psym)
        Y = plearn(k, :, i);
        %     [B,dev,stats] = mnrfit(X, Y);
        %     pp(i, :) = mnrval(B, plearn(:, :, i));
        [logitCoef, dev] = glmfit(...
            reshape(X, [], 1), reshape(plearn(k, :, i), [], 1), 'binomial','logit');
        pp(i, :) = glmval(logitCoef, pcue', 'logit');
    end


    figure
    pwin = [0.1, 0.2, 0.3, 0.4, 0.6, 0.7, 0.8, 0.9];

    for i = 1:length(psym)
        subplot(4, 2, i)
        lin = plot(...
            pcue,  pp(i, :),... %'bs', pcue, pp(i, :),  'b-', 'MarkerEdgeColor',...
            'Color', [0.4660    0.6740    0.1880] ...
            );
        try
            ind_point = interp1(lin.YData, lin.XData, 0.5);
            hold on
            scatter(ind_point, 0.5, 'MarkerFaceColor', 'r', 'MarkerEdgeColor', 'w');

        catch
            disp('Problem when representing intersection point');
        end
        if mod(i, 2) ~= 0
            ylabel('P(choose learnt value)');
        end
        if ismember(i, [7, 8])
            xlabel('Described cue win probability');
        end
        hold on
        scatter(pcue, prop(i, :),...
            'MarkerEdgeColor', 'w',...
            'MarkerFaceColor', [0.4660    0.6740    0.1880]);
%             'MarkerFaceAlpĥa', 0.8);

        plot(...
            ones(10)*pwin(i),...
            linspace(0.1, 0.9, 10),...
            'LineStyle', '--', 'Color', [0, 0, 0], 'LineWidth', 0.6);
       
        if i < 6
            text(pwin(i)+0.03, 0.8, sprintf('P(win) = %0.1f', pwin(i)), 'FontSize', 7);
        else

            text(pwin(i)-0.30, 0.8, sprintf('P(win) = %0.1f', pwin(i)), 'FontSize', 7);
        end

        plot(linspace(0, 1, 12), ones(12)*0.5, 'LineStyle', ':', 'Color', [0, 0, 0]);
        ylim([-0.08, 1.08]);
        xlim([-0.08, 1.08]);   
    end
end


% ----------------------------------------------------------------------
% Plot violins
% % --------------------------------------------------------------------
[corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2] = extract_elicitation_data(...
    data, sub_ids, idx, 2, corr);

i = 1;
for p = pwin
    mn(i, :) = cho(p1(:, :) == p)./100;
    i = i + 1;
end

figure
pirateplot(...
    mn, rand(8, 3),...
    -0.1, 1.1, 20, 'Slider choices' , 'P(win of learnt value)',...
    'Estimated probability', pwin...
);


% ----------------------------------------------------------------------
% FUNCTION SECTION
% ------------------------------------------------------------------------
% 
% function [cho, out, corr, con, rew] = extract_learning_data(data, sub_ids, idx)
% i = 1;
% for id = 1:length(sub_ids)
%     sub = sub_ids(id);
%     mask_sub = data(:, idx.sub) == sub;
%     mask_sess = ismember(data(:, idx.sess), [0]);
%     mask_eli = data(:, idx.elic) == -1;
%     mask = logical(mask_sub .* mask_sess .* mask_eli);
%     
%     [noneed, trialorder] = sort(data(mask, idx.trial_idx));
%     
%     tempcho = data(mask, idx.cho);
%     cho(i, :) = tempcho(trialorder);
%     
%     tempout = data(mask, idx.out);
%     out(i, :) = tempout(trialorder);
%     tempcorr = data(mask, idx.corr);
%     
%     corr(i, :) = tempcorr(trialorder);
%     temprew = data(mask, idx.rew);
%     
%     rew(i, :) = temprew(trialorder);
%     
%     tempcon = data(mask, idx.cond);
%     con(i, :) = tempcon(trialorder) + 1;
%     
%     i = i + 1;
% end
% end
% 
% function [to_keep, corr_catch] = exclude_subjects(data, sub_ids, idx,...
%     catch_threshold, n_best_sub, allowed_nb_of_rows)
% to_keep = [];
% i = 1;
% for id = 1:length(sub_ids)
%     sub = sub_ids(id);
%     if ismember(sum(data(:, idx.sub) == sub), allowed_nb_of_rows) %255, 285, 
%         for eli = [0, 2]          
%             mask_eli = data(:, idx.elic) == eli;
%             if eli == 0
%                 eli = 1;
%             end
%             mask_sub = data(:, idx.sub) == sub;
%             mask_catch = data(:, idx.catch) == 1;
%             mask_no_catch = data(:, idx.catch) == 0;
%             mask_sess = ismember(data(:, idx.sess), [0]);
%             mask = logical(mask_sub .* mask_sess .* mask_catch .* mask_eli);
%             [noneed, trialorder] = sort(data(mask, idx.trial_idx));
%             temp_corr = data(mask, idx.corr);
%             corr_catch{i, eli} = temp_corr(trialorder);
%         end
%         
%         if mean(corr_catch{i}) >= catch_threshold
%             to_keep(length(to_keep) + 1) = sub;
%             
%         end
%         i = i + 1;
%         
%     end
%     
% end
% for j = 1:length(to_keep)
%     mask_sub = data(:, idx.sub) == to_keep(j);
%     mask_eli = data(:, idx.elic) == 0;
%     mask_corr = logical(mask_sub .* mask_sess .* mask_eli .* mask_no_catch);
%     corr(j) = mean(data(mask_corr, idx.corr));
% end
% [throw, sorted_idx] = sort(corr);
% to_keep = to_keep(sorted_idx);
% to_keep = to_keep(end-n_best_sub+1:end);
% end
% 
% 
% % function [to_exclude] = exclude_from_catch_trials(corr_catch, catch_threshold)
% % to_exclude = [];
% % for i = 1:size([corr_catch{:, 1}], 1)
% %     if mean(corr_catch{i}, 'all') < catch_threshold
% %         to_exclude(length(to_exclude) + 1) = i;
% %     end
% % end
% % end
% % 
% % 
% % function [to_exclude] = exclude_from_number_of_rows(data, sub_ids, idx, allowed_nb_of_rows)
% % to_exclude = [];
% % for id = 1:length(sub_ids)
% %     sub = sub_ids(id);
% %     if ismember(sum(data(:, idx.sub) == sub), allowed_nb_of_rows)
% %         to_exclude(length(to_exclude) + 1) = 
% % 
% 
% function [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2] = ...
%     extract_elicitation_data(data, sub_ids, idx, eli)
% i = 1;
% for id = 1:length(sub_ids)
%     sub = sub_ids(id);
%     
%     mask_eli = data(:, idx.elic) == eli;
%     mask_sub = data(:, idx.sub) == sub;
%     mask_catch = data(:, idx.catch) == 0;
%     mask_sess = ismember(data(:, idx.sess), [0]);
%     mask = logical(mask_sub .* mask_sess .* mask_eli .* mask_catch);
%     
%     [noneed, trialorder] = sort(data(mask, idx.trial_idx));
%     
%     temp_corr = data(mask, idx.corr);
%     corr(i, :) = temp_corr(trialorder);
%     
%     temp_cho = data(mask, idx.cho);
%     cho(i, :) = temp_cho(trialorder);
%     
%     temp_out = data(mask, idx.out);
%     out(i, :) = temp_out(trialorder);
%     
%     temp_ev1 = data(mask, idx.ev1);
%     ev1(i, :) = temp_ev1(trialorder);
%     
%     temp_catch = data(mask, idx.catch);
%     ctch(i, :) = temp_catch(trialorder);
%     
%     temp_cont1 = data(mask, idx.cont1);
%     cont1(i, :) = temp_cont1(trialorder);
%     
%     temp_ev2 = data(mask, idx.ev2);
%     ev2(i, :) = temp_ev2(trialorder);
%     
%     temp_cont2 = data(mask, idx.cont2);
%     cont2(i, :) = temp_cont2(trialorder);
%     
%     temp_p1 = data(mask, idx.p1);
%     p1(i, :) = temp_p1(trialorder);
%     
%     temp_p2 = data(mask, idx.p2);
%     p2(i, :) = temp_p2(trialorder);
%       
%     i = i + 1;
% end
% end
% 
