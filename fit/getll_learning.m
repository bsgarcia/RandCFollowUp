function ll = getll_learning(params, s, a, cfa, r, cfr, ntrials, model)
    
    switch model
        case 1
            beta1 = params(1);
            alpha1 = params(2);
        case 2
            beta1 = params(1);
            alpha1 = params(2);
            alpha2 = params(3);
    end

    ll = 0;
    ncond = length(unique(s));
    Q = zeros(ncond, 2)+.5;
    
    for t = 1:ntrials
        
        D(a(t)) = Q(s(t), a(t))*1 + (1-Q(s(t), a(t)))*-1;
        D(3-a(t)) = Q(s(t), 3-a(t))*1 + (1-Q(s(t), 3-a(t)))*-1;
        
        ll = ll + (D(a(t))*beta1) - log(sum(exp(D(:).*beta1)));
        
        deltaI = (r(t)==1) - Q(s(t), a(t));
        
        if cfa(t) ~= -2
            cfdeltaI = (cfr(t)==1) - Q(s(t), cfa(t));
        end
        
        switch model 
            case 1
                Q(s(t), a(t)) = Q(s(t), a(t)) + alpha1 * deltaI;
                if cfa(t) ~= -2
                    Q(s(t), cfa(t)) = Q(s(t), cfa(t)) + alpha1 * cfdeltaI;
                end
            case 2
               Q(s(t), a(t)) = Q(s(t), a(t)) + alpha1 * deltaI * ...
                        (deltaI > 0) + alpha2 * deltaI * (deltaI < 0);
                if cfa(t) ~= -2
                    Q(s(t), cfa(t)) = Q(s(t), cfa(t)) + ...
                        alpha2 * cfdeltaI * (cfdeltaI > 0) + ...
                        alpha1 * cfdeltaI * (cfdeltaI < 0);
                end
        end
        
            
    end

ll = -ll;
end
