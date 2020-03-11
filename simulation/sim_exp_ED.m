function [a, cont1, cont2, p1, p2, ev1, ev2, ll] = sim_exp_ED(exp_name, exp_num, d, idx, sess, model)

    if model == 4
       [corr, cho, out, p1, p2, ev1, ev2, ctch, cont1, cont2, dist, rtime] = ...
                DataExtraction.extract_estimated_probability_post_test(...
                d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);

        for sub = 1:size(cho, 1)
            i = 1;      

            for p = unique(p1)'
                Q(sub, i) = cho(sub, (p1(sub, :) == p))./100;
                i = i + 1;          
            end
        end
        
        
        
    elseif model == 5
        
        [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
        
        for sub = 1:size(cho, 1)
            i = 1;      
            icon = [1, 2, 3, 4, 4, 3, 2, 1];
            for p = [unique(p2)',  unique(p1)']
                if i < 5
                    Q(sub, i) = mean(cho(sub, con(sub, :)==icon(i))==2);
                else
                    Q(sub, i) = mean(cho(sub, con(sub, :)==icon(i))==1);
                end
                i = i + 1;          
            end
        end
        
    elseif model == 6
               
        [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
        
        Q = zeros(size(cho, 1), 8);
    
    else
        
         [cho, cfcho, out, cfout, corr, con, p1, p2, rew, rtime, ev1, ev2] = ...
        DataExtraction.extract_learning_data(...
            d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
        
        params.cho = cho;
        params.cfcho = cfcho;
        params.con = con;
        params.out = out==1;
        params.cfout = cfout==1;
        params.ntrials = size(cho, 2);
        params.fit_cf = (exp_num>2);
        params.model = model;
        params.ncond = length(unique(con));
        params.noptions = 2;
        params.nsub = size(cho, 1);
        params.q = 0.5;
        
        [Q, params] = get_qvalues(...
            exp_name, sess, params, model);
        Q = sort_Q(Q);
    end
    
    
    clear cho cfcho out cfout corr con p1 p2 rew rtime ev1 ev2 i
  
    [corr, cho, out2, p1, p2, ev1, ev2, ctch, cont1, cont2, dist] = ...
        DataExtraction.extract_sym_vs_lot_post_test(...
        d.(exp_name).data, d.(exp_name).sub_ids, idx, sess);
    
    nsub = d.(exp_name).nsub;
    ntrials = size(cho, 2);
    
    ll = zeros(1, nsub);
    
    i = 1;  

    for sub = 1:nsub

        flatQ = 1.*Q(sub, :)+ -1.*(1-Q(sub,:));

        s2 = ev2(sub, :);
        p_range = 1:length(unique(p1));

        for t = 1:ntrials
            
            if model == 6
                
                a(sub, t) = (ev2(sub, t) > 0) + 1;
            
            else
                
                what_sym = p_range(...
                    p1(sub, t)==unique(p1));
                
                v = [flatQ(what_sym), s2(t)];
                
                [throw, a(sub, t)] = max(v);
            
            end
            p = a(sub, t) == cho(sub, t);

            ll(sub) = ll(sub) + p;

            %
            %                  pp = softmaxfn(v, beta1);
            % %
            %                 a(sub, t) = randsample(...
            %                     [1, 2],... % randomly drawn action 1 or 2
            %                     1,... % number of element picked
            %                     true,...% replacement
            %                     pp... % probabilities
            %                 );
            %

        end
        i = i + 1;
    end
    ll = ll./ntrials;
end

