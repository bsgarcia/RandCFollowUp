%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [6.2];
sessions = [0, 1];

displayfig = 'on';

figure('Renderer', 'painters',...
    'Position', [145,157,900,600], 'visible', 'on')

num = 0;
for exp_num = selected_exp
    num = num + 1;
    
    clear qvalues b pY2 ind_point Y
    
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
    % load data
    name = char(filenames{round(exp_num)});
    
    data = d.(name).data;
    sub_ids = d.(name).sub_ids;
    nsub = d.(name).nsub;
       
    param = load(...
        sprintf('data/post_test_fitparam_ED_exp_6_2', num2str(exp_num)));
    shift1 = param.shift;
    
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        data, sub_ids, idx, sess);
    
    ev = unique(p1);
    varargin = ev;
    x_values = ev;
    x_lim = [0, 1];
    
    
    [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
        DataExtraction.extract_estimated_probability_post_test...
        (data, sub_ids, idx, sess);
    
    for sub = 1:nsub
        i = 1;
        
        for p = unique(p1)'
            shift2(sub, i) = cho(sub, (p1(sub, :) == p))./100;
            i = i + 1;
        end
    end
    
   
    figure('Renderer', 'painters',...
    'Position', [145,157,700,650], 'visible', 'on')

    
    brick_comparison_plot2(...
        shift1',shift2',...
        orange_color, magenta_color, ...
        [0, 1], 11,...
        '',...
        '',...
        '', varargin, 1, x_lim, x_values);
    
    ylabel('Indifference point')
    
    slope1 = add_linear_reg(shift1, ev, orange_color);
    slope2 = add_linear_reg(shift2, ev, magenta_color);
        
   
    xlabel('Experienced cue win probability');
    box off
    hold on
    
    set(gca, 'fontsize', fontsize);
    
    %set(gca, 'ytick', [0:10]./10);
    set(gca,'TickDir','out')
    
    title('Exp. 6.2');
    
    
    figure('Renderer', 'painters',...
    'Position', [145,157,700,650], 'visible', 'on')
    
    dd(1, :) = slope1(:, 2)';
    dd(2, :) = slope2(:, 2)';
    skylineplot(dd,...
        [orange_color; magenta_color],...
        min(dd,[],'all')-.08,...
        max(dd,[],'all')+.08,...
        20,...
        '',...
        '',...
        '',...
        {'ED', 'PM'},...
        0);
    ylabel('Slope');
    set(gca, 'tickdir', 'out');
    box off
    
    title('Exp. 6.2');
    
%    figure('Renderer', 'painters',...
%     'Position', [145,157,700,650], 'visible', 'on')
%     dd(1, :) = beta1';
%     dd(2, :) = beta2';
%     skylineplot(log(dd),...
%         [orange_color; magenta_color],...
%         min(log(dd),[],'all')-.08,...
%         max(log(dd),[],'all')+.08,...
%         20,...
%         '',...
%         '',...
%         '',...
%         {'ED','PM'},...
%         0);
%     
%     ylabel('Stochasticity');
%     set(gca, 'tickdir', 'out');
%     box off
%     
%     title('Exp. 6.2');
  
end