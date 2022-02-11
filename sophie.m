


%%%%%%%%  Main program %%%%%%%%%%%%%%%%%% 

% With a model you can average over as many subject as you want :-)
Nsubj = 1;

%Values for the symbolic object
prs=[0.2:0.1:0.8]; Ns = length(prs);


%Values for the experiential object
prx = [0.2:0.1:0.8]; Nx = length(prx);


%Discretization of the prob axis (for vizualization).  
pri = [0.01:0.01:0.99];

figure


for Nsample = 1:2:9  


    pchoicesym = zeros(Nsubj,Nx,Ns);

    for subj=1: Nsubj
        for k=1:Nx
            preal = prx(k);
            px = postp(preal,Nsample);
            Npx = length(px);
            for l = 1:Ns
                psym = prs(l);
                pchoicesym(subj,k,l) = sum(px(1:round(psym*Npx))); % probability that the symbolic object value is larger than the experential object value.
            end
        end
    end
   
    subplot(2,5,5+5-round(Nsample-1)/2)
    plot(prs,squeeze(mean(1-pchoicesym,1))')
    xlabel('value for symbolic cue')
    ylabel('p choose non-symbolic cue')
    title(['N=',num2str(Nsample)])


    %This is last part is just to plot the mean posteriors over experiential values:

   
    postall = zeros(Nx,length(px));

    for subj=1:Nsubj
       for k = 1:Nx
            preal = prx(k);
            px = postp(preal,Nsample);
            postall(k,:) = postall(k,:)+1/Nsubj * px;
       end
    end
   
    subplot(2,5,5-round(Nsample-1)/2)
    plot(pri,postall')
    xlabel('value')
    ylabel('prob(value)')
    title(['N=',num2str(Nsample)])
    if Nsample == 9
        legend('realvalue = 0.8','realvalue = 0.7','realvalue = 0.6','realvalue = 0.5','realvalue = 0.4','realvalue = 0.3','realvalue = 0.2')

    end

end

%%%%%%%% Function "postp" %%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The function computes a discretized probability distribution over values from Nsample
% binary samples (0 = no reward, 1 = reward), generated with probability preal.  

function px = postp(preal,Nsample, X)

%Generate N random samples with p(X_n = 1) = preal

%Compute the discretized posterior probability distribution (discretization
%step = 0.01). Here we assume that the prior over value is flat:

prop = [0.01:0.01:0.99];

logpx = sum(X*log(prop) + (1-X) * log(1-prop),1);

px = exp(logpx)/(sum(exp(logpx)));
end
