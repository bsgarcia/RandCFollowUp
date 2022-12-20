function lpp = getlpp_learning(params, s, a, cfa, r, cfr, q, ntrials, model, decision_rule,fit_cf)

    addpath './'
    
    model_str = {'QLearning', 'NoFixedQLearning'};
    
    p = -sum(getp(params));
 
    if model == 1
        model = models.(model_str{model})(params, q, 4, 2, ntrials, decision_rule);
        l = model.fit(s, a, cfa, r, cfr, fit_cf);
    elseif model == 2
        noption = 8;
        model = models.(model_str{model})(params, q, noption, ntrials, decision_rule);
        l = model.fit(s, a, [], r, cfr, fit_cf);
    end
    
    lpp = p + l;
    
end


function p = getp(params)
    %% log prior of parameters
            beta1 = params(1); % choice temphiature
            alpha1 = params(2); % policy or factual learning rate
            %% the parameters based on the first optimzation
            pbeta1 = log(gampdf(beta1, 1.2, 5.0));
            palpha1 = log(betapdf(alpha1, 1.1, 1.1));
            p = [pbeta1, palpha1];
      
  
end

function v = rescale1(x, xmin, xmax, vmin, vmax)
    v = (vmax - vmin) * (x - xmin)/(xmax - xmin) + vmin;
end

