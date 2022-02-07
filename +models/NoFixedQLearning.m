classdef NoFixedQLearning < handle
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
        which_decision_rule
    end
    
    methods
        function obj = NoFixedQLearning(params, q, noption, ntrial, name)
            % constructor
            if exist('name', 'var')
                obj.name = name;
            else
                obj.name = 'NoFixedQLearning';
            end
            obj.Q = ones(noption,1) .* q;
            obj.alpha = params(2);
           
            obj.beta = params(1);
            obj.ntrial = ntrial;
            %obj.psoftmax = zeros(nstate, naction, ntrial);
            %obj.ac = zeros(1, ntrial);
            %obj.r = zeros(1, ntrial);
            obj.which_decision_rule = 1;
            obj.ll = 0;
        end
        
       
        function choice = make_choice(obj, c, u, t)
            p = obj.decision_rule(c(t), u(t));
            obj.a(t) = randsample(...
                1:length(p),... % randomly drawn action
                1,... % number of element picked
                true,...% replacement
                p... % probabilities
                );
            
            choice = obj.a(t);
        end
%         
        function learn(obj, c, r)
            pe = r - obj.Q(c);
            
            obj.Q(c) = ...
                obj.Q(c) + obj.alpha * pe;
           
        end
        
        function psoftmax = decision_rule(obj, c, u)
           v1 = obj.Q(c);
           v2 = obj.Q(u);
          
           ev1 = v1.*1 + -1.*(1-v1);
           ev2 = v2.*1 + -1.*(1-v2);
           psoftmax = exp(obj.beta .* ev1) ./ ...
                sum(exp(obj.beta .* [ev1, ev2]));
            
        end
             
        function nll = fit(obj, c, u, throw, r, cfr, fit_cf)
            for t = 1:obj.ntrial
                
                obj.ll = obj.ll + obj.fit_decision_rule(...
                    c(t), u(t)...
                );
                
                obj.learn(c(t), r(t));
                
                if fit_cf
                     obj.learn(u(t), cfr(t));
                end
                             
            end
            nll = -obj.ll;
        end
        
        function p = fit_decision_rule(obj, c, u)
            v1 = obj.Q(c);
            v2 = obj.Q(u);
            switch (obj.which_decision_rule)
                case 1
                    ev1 = v1.*1 + -1.*(1-v1);
                    ev2 = v2.*1 + -1.*(1-v2);

                    %ev = obj.Q(s,:);
                    % logLL softmax
                    p = (obj.beta .* ev1) ...
                    - log(sum(exp(obj.beta .* [ev1, ev2])));
                 case 2
                     disp('not implemented');
%                     ev = obj.Q(s, :).*1 + -1.*(1-obj.Q(s,:));
%                     % LL softmax
%                     p = exp(obj.beta * ev(a)) ...
%                     ./sum(exp(obj.beta .* ev));
                case 3
%                     % LL argmax
%                     if obj.Q(s, 1) ~= obj.Q(s, 2)
%                         [throw, am] = max(obj.Q(s, :));
%                         p = (am == a);
%                     else
%                         p = 0.5;
%                     end
                     disp('not implemented');

                otherwise
                    error('not recognized decision rule');
            end
        end               
        
       
        
  
        
    end
end

