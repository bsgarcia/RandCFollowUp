% --------------------------------------------------------------------
% This script finds the best fitting Values for each exp
% then plots the article figs
% --------------------------------------------------------------------

close all
clear all

addpath './fit'
addpath './plot'
addpath './data'
addpath './'

init;

%------------------------------------------------------------------------
% Plot fig 2.A
%------------------------------------------------------------------------
exp_names = {filenames{1:3}};
plot_fitted_values_desc_vs_exp(d, idx, fit_folder, orange_color, exp_names);

exp_names = {filenames{4:5}};
plot_fitted_values_all(d, idx, fit_folder, orange_color, blue_color, exp_names);


% --------------------------------------------------------------------
% FUNCTIONS USED IN THIS SCRIPT
% --------------------------------------------------------------------
function plot_fitted_values_desc_vs_exp(d, idx, fit_folder, orange_color, exp_names)

    i = 1;
    figure('Position', [1,1,1920,1090]);
    titles = {'Exp. 1', 'Exp. 2', 'Exp. 3'};
    
    for exp_name = exp_names
        
        subplot(2, 3, i);
        exp_name = char(exp_name);
        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, 0);
        
        
        ev = [-0.8, -0.6, -0.4, -0.2, 0.2, 0.4, 0.6, 0.8];
        % set ntrials
        ntrials = size(cho, 2);
        subjecttot = length(d.(exp_name).sub_ids);
        nz = [8, 1];
        cont1(ismember(cont1, [6, 7, 8, 9])) = ...
            cont1(ismember(cont1, [6, 7, 8, 9]))-1;
        cont2 = ev2;

        [parameters, ll] = runfit(...
            subjecttot,...
            cont1,...
            cont2,...
            cho,...
            ntrials,...
            nz,...
            fit_folder,...
            sprintf('%s%s', exp_name, '_desc_vs_exp'));
        
        Y2 = parameters(: , 1:8)';
         
        brickplot(...
            Y2,...
            orange_color.*ones(8, 1),...
            [-1, 1], 11,...
            sprintf('Exp. %d', i),...
            'Symbol Expected Value',...
            'Fitted value', ev, 1);

        hold on
        
        yline(0, 'LineStyle', ':', 'LineWidth', 2);
        hold on
         
        x_lim = get(gca, 'XLim');
        y_lim = get(gca, 'YLim');
        
        x = linspace(x_lim(1), x_lim(2), 10);
        
        y = linspace(y_lim(1), y_lim(2), 10);
        plot(x, y, 'LineStyle', '--', 'Color', 'k');
        hold on
                
        for sub = 1:subjecttot
            X = ev;
            Y = Y2(:, sub);
            [r(i, sub, :), thrw1, thrw2] = glmfit(X, Y);
            b = glmfit(1:length(ev), Y);
            pY2(sub, :) = glmval(b, 1:length(ev), 'identity');
        end
        
        mn2 = mean(pY2, 1);
        err2 = std(pY2, 1)./sqrt(subjecttot);
        
        curveSup2 = (mn2 + err2);
        curveInf2 = (mn2 -err2);
        
        plot(1:length(ev), mn2, 'LineWidth', 1.7, 'Color', orange_color);
        
        hold on
        fill([(1:length(ev))'; flipud((1:length(ev))')],[curveInf2'; flipud(curveSup2')],...
            orange_color, ...
            'lineWidth', 1, ...
            'LineStyle', 'none',...
            'Facecolor', orange_color, ...
            'Facealpha', 0.55); 
        hold on
        i = i + 1;
        
        box off

        
    end
    
    titles2 = {'Intercept', 'Slope'};
    sub_plot = [4, 3];
    for j = 1:2
        subplot(2, 2, sub_plot(j))
        for k = 1:3
            rsize = reshape(r(k, :, j), [size(r, 2), 1]);
            mn(k, :) = mean(rsize);
            err(k, :) = std(rsize)./sqrt(size(r, 2));
        end
        b = bar(mn);
        hold on
        
        b.FaceColor = orange_color;
        b.FaceAlpha = 0.7;
        
        ax1 = gca;
        set(gca, 'XTickLabel', titles);
        ylabel('Value');
        title(titles2{j});
        errorbar(b.XData+b.XOffset, mn(:, 1), err(:, 1), 'LineStyle', 'none',...
            'LineWidth', 2, 'Color', 'k', 'HandleVisibility','off');
        
        box off

    end

    saveas(gcf, 'fig/fit/all/fitted_value_exp_1_2_3.png')        

end


function plot_fitted_values_all(d, idx, fit_folder, orange_color, blue_color, exp_names)

    i = 1;
    
    figure('Position', [1,1,1920,1090]);
    titles = {'Exp. 4', 'Exp. 5 Sess. 1', 'Exp. 5 Sess. 2'};
    
    for exp_name = {exp_names{:} exp_names{end}}
        if i == 3
            session = 1;
            to_add = '_sess_2';
        else
            session = 0;
            to_add = '_sess_1';
        end
        subplot(2, 3, i);
        exp_name = char(exp_name);
        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);

        % set ntrials
        ntrials = size(cho, 2);
        subjecttot = length(d.(exp_name).sub_ids);
        nz = [8, 1];
        cont1(ismember(cont1, [6, 7, 8, 9])) = ...
            cont1(ismember(cont1, [6, 7, 8, 9]))-1;
       cont2(ismember(cont2, [6, 7, 8, 9])) = ...
            cont2(ismember(cont2, [6, 7, 8, 9]))-1;

        [parameters, ll] = runfit(...
            subjecttot,...
            cont1,...
            cont2,...
            cho,...
            ntrials,...
            nz,...
            fit_folder,...
            sprintf('%s%s%s', exp_name, '_exp_vs_exp', to_add));
        
        ev = [-0.8, -0.6, -0.4, -0.2, 0.2, 0.4, 0.6, 0.8];
        
        Y1 = parameters(:, 1:8)';
        
        [corr1, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
            DataExtraction.extract_sym_vs_lot_post_test(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, session);

        % set ntrials
        ntrials = size(cho, 2);
        subjecttot = length(d.(exp_name).sub_ids);
        nz = [8, 1];
        cont1(ismember(cont1, [6, 7, 8, 9])) = ...
            cont1(ismember(cont1, [6, 7, 8, 9]))-1;
        cont2 = ev2;

        [parameters, ll] = runfit(...
            subjecttot,...
            cont1,...
            cont2,...
            cho,...
            ntrials,...
            nz,...
            fit_folder,...
            sprintf('%s%s%s', exp_name, '_desc_vs_exp', to_add));     
       
        Y2 = parameters(: , 1:8)';
         
        %x = linspace(min(xlim), max(yl), 10);
        brick_comparison_plot(...
            Y1,...
            Y2,...
            blue_color,...
            orange_color,...
            [-1, 1], 11,...
            titles{i},...
            'Symbol Expected Value',...
            'Fitted value', ev, 1);

        hold on
        
        yline(0, 'LineStyle', ':', 'LineWidth', 2);
        hold on
         
        x_lim = get(gca, 'XLim');
        y_lim = get(gca, 'YLim');
        
        x = linspace(x_lim(1), x_lim(2), 10);
        
        y = linspace(y_lim(1), y_lim(2), 10);
        plot(x, y, 'LineStyle', '--', 'Color', 'k');
        hold on
        
        
        for sub = 1:subjecttot
            X = ev;
            Y = Y1(:, sub);
            [r(1, i, sub, :), thrw1, thrw2] = glmfit(X, Y);
            b = glmfit(1:length(ev), Y);
            pY1(sub, :) = glmval(b, 1:length(ev), 'identity');
            X = ev;
            Y = Y2(:, sub);
            [r(2, i, sub, :), thrw1, thrw2] = glmfit(X, Y);
            b = glmfit(1:length(ev), Y);
            pY2(sub, :) = glmval(b, 1:length(ev), 'identity');
        end
        
        mn1 = mean(pY1, 1);
        mn2 = mean(pY2, 1);
        err1 = std(pY1, 1)./sqrt(subjecttot);
        err2 = std(pY2, 1)./sqrt(subjecttot);
        
        curveSup1 = (mn1 + err1);
        curveSup2 = (mn2 + err2);
        curveInf1 = (mn1 - err1);
        curveInf2 = (mn2 -err2);
        
        plot(1:length(ev), mn1, 'LineWidth', 1.7, 'Color', blue_color);
        hold on
        plot(1:length(ev), mn2, 'LineWidth', 1.7, 'Color', orange_color);
        hold on
        fill([(1:length(ev))'; flipud((1:length(ev))')], [curveInf1'; flipud(curveSup1')],...
            blue_color, ...
            'lineWidth', 1, ...
            'LineStyle', 'none',...
            'Facecolor', blue_color, ...
            'Facealpha', 0.55);     
        hold on
        fill([(1:length(ev))'; flipud((1:length(ev))')],[curveInf2'; flipud(curveSup2')],...
            orange_color, ...
            'lineWidth', 1, ...
            'LineStyle', 'none',...
            'Facecolor', orange_color, ...
            'Facealpha', 0.55); 
        hold on
        i = i + 1;
        box off

        
    end
    
    titles2 = {'Intercept', 'Slope'};
    sub_plot = [4, 3];
    for j = 1:2
        subplot(2, 2, sub_plot(j))
        for k = 1:3
            rsize = reshape(r(:, k, :, j), [size(r, 3), 2]);
            mn(k, :) = mean(rsize);
            err(k, :) = std(rsize)./sqrt(size(r, 3));
        end
        b = bar(mn);% 'EdgeColor', 'w', 'FaceAlpha', 0.6, 'FaceColor', 'flat');
        hold on
        
        b(1).FaceColor = orange_color;
        b(2).FaceColor = blue_color;
        b(1).FaceAlpha = 0.7;
        b(2).FaceAlpha = 0.7;
        
        ax1 = gca;
        set(gca, 'XTickLabel', titles);
        ylabel('Value');
        title(titles2{j});
        legend('post-test ED', 'post-test EE',  'Location', 'southeast');
        errorbar(b(1).XData+b(1).XOffset, mn(:, 1), err(:, 1), 'LineStyle', 'none',...
            'LineWidth', 2, 'Color', 'k', 'HandleVisibility','off');
        hold on
        errorbar(b(2).XData+b(2).XOffset, mn(:, 2), err(:, 2), 'LineStyle', 'none',...
            'LineWidth', 2, 'Color', 'k', 'HandleVisibility','off');
                box off

    end
    saveas(gcf, 'fig/fit/all/fitted_value_exp_4_5.png')        
           
end


function [parameters, ll] = ...
    runfit(subjecttot, cont1, cont2, cho, ntrials, nz, folder, fit_filename)
    
    try
        disp(sprintf('%s%s', folder, fit_filename));
        data = load(sprintf('%s%s', folder, fit_filename));
        parameters = data.data('parameters');  %% Optimization parameters 
        ll = data.data('ll');
        answer = question(...
            'There is already a fit file, would you like to use it or to rerun analyses (the old file will be replaced)',...
             'Use existent fit file', 'Rerun and erase');
        if strcmp(answer, 'Use existent fit file')
            return 
        end
    catch
    end
    parameters = zeros(subjecttot, 8);
    ll = zeros(subjecttot, 1);
    
    options = optimset(...
        'Algorithm',...
        'interior-point',...
        'Display', 'off',...
        'MaxIter', 10000,...
        'MaxFunEval', 10000);

    w = waitbar(0, 'Fitting subject');
    for sub = 1:subjecttot
        
        waitbar(...
            sub/subjecttot,...  % Compute progression
            w,...
            sprintf('%s%d', 'Fitting subject ', sub)...
            );
           
            [
                p,...
                l,...
                rep,...
                output,...
                lmbda,...
                grad,...
                hess,...
            ] = fmincon(...
                @(x) qvalues(...
                    x,...
                    cont1(sub, :),...
                    cont2(sub, :),...
                    cho(sub, :),...
                    nz,...
                   ntrials),...
                zeros(8, 1),...
                [], [], [], [],...
                ones(8, 1) .* -1,...
                ones(8, 1),...
                [],...
                options...
                );
            parameters(sub, :) = p;
            ll(sub) = l;

    end
    %% Save the data
    data = containers.Map({'parameters', 'll'},...
        {parameters, ll});
    save(sprintf('%s%s', folder, fit_filename), 'data');
    close(w);
    
end

