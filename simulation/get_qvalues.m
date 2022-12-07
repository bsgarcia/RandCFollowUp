function [Q, params] = get_qvalues(sim_params)

% ----------------------------------------------------------%
% Parameters                                                %
% ----------------------------------------------------------%

sim_params.show_window = true;

switch sim_params.model
    case 1
        
        data = sim_params.de.extract_LE(sim_params.exp_num);
        
        params.cho = data.cho;
        params.cfcho = data.cfcho;
        params.con = data.con;
        params.out = data.out==1;
        params.cfout = data.cfout==1;
        params.ntrials = size(data.cho, 2);
        params.fit_cf = true;
        params.model = sim_params.model;
        params.ncond = length(unique(data.con));
        params.noptions = 2;
        params.decision_rule = 1;
        params.nsub = sim_params.nsub;
        params.q = 0.5;
        if isfield(params, 'random')
            params.random = sim_params.random;
        else
            params.random = false;
        end
        if isfield(sim_params, 'nagent')
            params.nagent = sim_params.nagent;
        else
            params.nagent = 1;
        end
        
        if ~isfield(sim_params, 'alpha1')
            data = load(sprintf('data/fit/%s_learning_%d', ...
                sim_params.exp_name, sim_params.sess));
            parameters = data.data('parameters');
            
            params.alpha1 = parameters{1}(:, 2);
            params.beta1 = parameters{1}(:, 1);
        else
            params.alpha1 = sim_params.alpha1;
            params.beta1 = sim_params.beta1;
        end
        
        Q = sort_Q(simulation(params));
        
    case 2
        data = sim_params.de.extract_SP(sim_params.exp_num);
        %             dd = load(sprintf('data/fit/%s_learning_%d', ...
        %                 sim_params.exp_name, sim_params.sess));
        %             parameters = dd.data('parameters');
        %
        %             params.alpha1 = parameters{1}(:, 2);
        %             params.beta1 = parameters{1}(:, 1);
        %
        
        params = struct();
        
        for sub = 1:size(data.cho, 1)
            i = 1;
            
            for p = unique(data.p1)'
                mask = logical((data.p1(sub, :) == p));
                Q(sub, i) = mean(data.cho(sub, mask)./100);
                %                     params.corr(sub, i) = abs(Q(sub, i) -  p) <= .1;
                i = i + 1;
            end
            
        end
        
    case 3
        
        data = sim_params.de.extract_nofixed_LE(sim_params.exp_num);
        % set parameters
        for i = 1:data.nsub
            data.cont1(i, ismember(data.cont1(i,:), [6, 7, 8, 9])) = data.cont1(i, ismember(data.cont1(i,:), [6, 7, 8, 9])) - 1;
            data.cont2(i, ismember(data.cont2(i,:), [6, 7, 8, 9])) = data.cont2(i, ismember(data.cont2(i,:), [6, 7, 8, 9])) - 1;
            
            cont1 = data.cont1(i, data.cho(i,:)==1);
            cont2 = data.cont2(i,data.cho(i,:)==2);
            con1 = data.cont2(i, data.cho(i,:)==1);
            con2 = data.cont1(i, data.cho(i,:)==2);
            out1 = data.out(i, data.cho(i,:)==1);
            out2 = data.out(i,data.cho(i,:)==2);
            cfout1 = data.cfout(i,data.cho(i,:)==1);
            cfout2 = data.cfout(i,data.cho(i,:)==2);
            cho(i,:) = [cont1 cont2];
            out(i,:) = [out1 out2];
            cfout(i,:) = [cfout1 cfout2];
            con(i,:) = [con1 con2];
        end
        params.c = cho;
        params.cfcho =[];
        params.out = out==1;
        params.cfout = cfout==1;
        params.u = con;
        params.fit_cf = true;
        params.ntrials = size(data.cho, 2);
        params.models = 1;
        params.model = 1;
        params.nsub = data.nsub;
        params.sess = data.sess;
        params.decision_rule = 1;
        params.q = 0.5;
        params.noptions = 8;
        params.nagent = 1;
        params.ncond = length(unique(data.con));
         if ~isfield(sim_params, 'alpha1')
            data = load(sprintf('data/fit/%s_learning_%d', ...
                sim_params.exp_name, sim_params.sess));
            parameters = data.data('parameters');
            
            params.alpha1 = parameters{1}(:, 2);
            params.beta1 = parameters{1}(:, 1);
        else
            params.alpha1 = sim_params.alpha1;
            params.beta1 = sim_params.beta1;
        end
        Q = simulation_nofixed(params);
        disp(mean(Q));
        
        
        
end
end
% ---------------------------------------------------------%


function Q = simulation(sim_params)

Q = ones(sim_params.nsub*sim_params.nagent, sim_params.ncond, sim_params.noptions)...
    .*sim_params.q;
i = 0;

for agent = 1:sim_params.nagent
    for sub = 1:sim_params.nsub
        i = i + 1;
        s = sim_params.con(sub, :);
        cfr = sim_params.cfout(sub, :);
        r = sim_params.out(sub, :);
        a = sim_params.cho(sub, :);
        cfa = sim_params.cfcho(sub, :);
        
        if sim_params.random
            order = randperm(length(a));
            s = s(order);
            cfr = cfr(order);
            r = r(order);
            a = a(order);
            cfa = cfa(order);
        end
        fit_cf = sim_params.fit_cf;
        
        qlearner = models.QLearning([NaN, sim_params.alpha1(sub)], sim_params.q,...
            sim_params.ncond, sim_params.noptions,...
            sim_params.ntrials, sim_params.decision_rule);
        
        for t = 1:sim_params.ntrials
            qlearner.learn(s(t), a(t), r(t));
            if fit_cf
                qlearner.learn(s(t), cfa(t), cfr(t));
            end
        end
        
        Q(i, :, :) = qlearner.Q(:, :);
        
    end
end

end

function Q = simulation_nofixed(sim_params)

Q = ones(sim_params.nsub*sim_params.nagent, sim_params.noptions)...
    .*sim_params.q;
i = 0;

for agent = 1:sim_params.nagent
    for sub = 1:sim_params.nsub
        i = i + 1;
        u = sim_params.u(sub, :);
        cfr = sim_params.cfout(sub, :);
        r = sim_params.out(sub, :);
        c = sim_params.c(sub, :);
    
        fit_cf = sim_params.fit_cf;
        
        qlearner = models.NoFixedQLearning([NaN, sim_params.alpha1(sub)], sim_params.q,...
            sim_params.noptions,...
            sim_params.ntrials, sim_params.decision_rule);
        
        for t = 1:sim_params.ntrials
            qlearner.learn(c(t), r(t));
            if fit_cf
                qlearner.learn(u(t), cfr(t));
            end
        end
        
        Q(i, :, :) = qlearner.Q(:, :);
        
    end
end

end


