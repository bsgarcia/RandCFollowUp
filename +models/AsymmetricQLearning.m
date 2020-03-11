classdef AsymmetricQLearning < handle
    %QLEARNING Agent with 2 alphas
    properties (SetAccess = public)
        Q
        alpha
        beta
        ntrial
        psoftmax
        ll
        name
        a
        r
    end
    
    methods
        function obj = QLearning(params, q, nstate, naction, ntrial, name)
            % constructor
            if exist('name', 'var')
                obj.name = name;
            else
                obj.name = 'QLearning';
            end
            obj.Q = ones(nstate, naction) .* q;
            obj.alpha1 = params(2);
            obj.alpha2 = params(1);
            
            obj.beta = params(1);
            obj.ntrial = ntrial;
            obj.psoftmax = zeros(nstate, naction, ntrial);
            obj.a = zeros(1, ntrial);
            obj.r = zeros(1, ntrial);
            obj.ll = 0;
        end
        
        function nll = fit(obj, s, a, r, cfr, fit_cf)
            for t = 1:obj.ntrial
                obj.ll = obj.ll + (obj.beta * obj.Q(s(t), a(t))) ...
                    - log(sum(exp(obj.beta .* obj.Q(s(t), :))));
                
                pe = r(t) - obj.Q(s(t), a(t));
                
                obj.Q(s(t), a(t)) = ...
                    obj.Q(s(t), a(t)) + obj.alpha1 * pe * (pe>0) + ...
                    obj.alpha2 * pe * (pe<0);
                
                if fit_cf
                    pe = cfr(t) - obj.Q(s(t), 3-a(t));
                    
                    obj.Q(s(t), 3-a(t)) = ...
                        obj.Q(s(t), 3-a(t)) + obj.alpha1 * pe * (pe<0) + ...
                        obj.alpha2 * pe * (pe>0);
                end
                
                
            end
            nll = -obj.ll;
        end
        
        function choice = make_choice(obj, s, t)
            p = obj.get_p(s);
            obj.a(t) = randsample(...
                1:length(p),... % randomly drawn action
                1,... % number of element picked
                true,...% replacement
                p... % probabilities
                );
            
            choice = obj.a(t);
        end
        
        function learn(obj, s, a, r, cfr, fit_cf)
            pe = r(t) - obj.Q(s(t), a(t));
            
            obj.Q(s(t), a(t)) = ...
                obj.Q(s(t), a(t)) + obj.alpha1 * pe * (pe>0) + ...
                obj.alpha2 * pe * (pe<0);
            
            if fit_cf
                pe = cfr(t) - obj.Q(s(t), 3-a(t));
                
                obj.Q(s(t), 3-a(t)) = ...
                    obj.Q(s(t), 3-a(t)) + obj.alpha1 * pe * (pe<0) + ...
                    obj.alpha2 * pe * (pe>0);
            end
            
        end
        
        function psoftmax = get_p(obj, s)
            psoftmax = exp(obj.beta .* obj.Q(s, :)) ./ ...
                sum(exp(obj.beta .* obj.Q(s, :)));
            
        end
        
    end
end
