% -------------------------------------------------------------------%
% This script finds the best fitting Values for each exp             %
% then plots the option value                                        %
% -------------------------------------------------------------------%
init;
% -------------------------------------------------------------------%
selected_exp = [1, 2, 3, 4, 5, 6.1, 6.2, 7.1, 7.2, 8.1, 8.2];
sessions = [0, 1];

learning_model = [1];
post_test_model = [1, 2];

fit_folder = 'data/fit/';


nfpm = [2, 4];

force = 0;

num = 0;

for exp_num = selected_exp
    num = num + 1;
    fprintf('Fitting exp. %s \n', num2str(exp_num));
    
    % -------------------------------------------------------------------%
    % LEARNING
    % -------------------------------------------------------------------%
    idx1 = (exp_num - round(exp_num)) * 10;
    idx1 = idx1 + (idx1==0);
    sess = sessions(uint64(idx1));
        
    % load data
    exp_name = char(filenames{round(exp_num)});

    [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    % set parameters
    fit_params.cho = cho;
    fit_params.cfcho = cfcho;
    fit_params.out = out==1;
    fit_params.cfout = cfout==1;
    fit_params.con = con;
    fit_params.fit_cf = (exp_num > 2);
    fit_params.ntrials = size(cho, 2);
    fit_params.models = learning_model;
    fit_params.nsub = d.(exp_name).nsub;
    fit_params.sess = sess;
    fit_params.exp_num = num2str(exp_num);
    fit_params.decision_rule = 1;
    fit_params.q = 0.5;
    fit_params.noptions = 2;
    fit_params.ncond = length(unique(con));
    
    save_params.fit_file = sprintf(...
        '%s%s%s%d', fit_folder, exp_name,  '_learning_', sess);
    
    % fmincon params
    fmincon_params.init_value = {[1, .5], [0, .5, .5],[0, .5]};
    fmincon_params.lb = {[0.001, 0.001], [0, 0, 0], [0, 0]};
    fmincon_params.ub = {[100, 1], [100, 1, 1], [100, 1]};
    
    try
        data = load(save_params.fit_file);
        
        %lpp = data.data('lpp');
        fit_params.params = data.data('parameters');  %% Optimization parameters
        ll = data.data('ll');
        %hessian = data.data('hessian');
        if force
            error('Force = True');
        end
    catch
        [fit_params.params, ll] = runfit_learning(...
            fit_params, save_params, fmincon_params);
        
    end
    
    options = struct();
    
    [a1, cont1, cont2, p1, p2, ev1, ev2, ll1] = sim_exp_ED(...
    exp_name, exp_num, d, idx, sess, 1, 2, 1, options);
    
    
    [a2, cont1, cont2, p1, p2, ev1, ev2, ll2] = sim_exp_ED(...
    exp_name, exp_num, d, idx, sess, 1, 4, 1, options);

    score1{num, 1} = mean(ll2' == ll1');
    
    ll_cop1 = ll1;
    ll_cop2 = ll2;
    
    ll1(ll_cop1 == ll_cop2) = 0;
    ll2(ll_cop1 == ll_cop2) = 0;
    
    score2{num, 1} = mean(ll1');
    score3{num, 1} = mean(ll2');
end

for i = 1:length(selected_exp)
    final(i, :) = [...
        mean(score1{i}, 2), mean(score2{i}, 2), mean(score3{i}, 2)];
end

% ----------------------------------------------------------------------- %
% Plot
% ----------------------------------------------------------------------- %
c1 = [202, 207, 214]./255;
c2 = [166, 177, 225]./255;
c3 = [220, 214, 247]./255;

figure

b = bar(1:length(selected_exp), final,...
    'stacked', 'edgecolor', 'w', 'facecolor', 'flat');% ...

ylim([-.08, 1.08])

b(1).CData = c1;
b(2).CData = c2;
b(3).CData = c3;

box off
xticklabels(selected_exp)

set(gca, 'tickdir', 'out');
