%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [1,2,3,4,5,6.1,6.2];%, 6.2, 7.1, 7.2];
displayfig = 'off';
colors = [orange_color; blue_color; grey_color;black_color;];


num = 0;
%
ed = cell(length(selected_exp),1);
pm = cell(length(selected_exp), 1);
mean_heur = cell(length(selected_exp), 1);


for exp_num = selected_exp
    
    num = num + 1;
    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    throw = de.extract_ED(exp_num);
    symp = unique(throw.p1);
    lotp = unique(throw.p2);
    
    heur = heuristic(throw, symp, lotp);
    mean_heur{num} = mean(heur, 2);
   
    data = de.extract_ED(exp_num);
    
    for sub = 1:nsub
            ed{num}(sub,1) = -median(data.rtime(sub,:))';          
    end
    
    sim_params.de = de;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.exp_num = exp_num;
    sim_params.nsub = nsub;
    sim_params.model = 1;
    
    [Q, tt] = get_qvalues(sim_params);
    dd1 = argmax_estimate(data, symp, lotp, Q);
%    
%              
%     sim_params.model = 2;
%     [Q, tt] = get_qvalues(sim_params);
% 
%     dd2 = argmax_estimate(data, symp, lotp, Q);
    
%     for sub = 1:nsub
%         o_heur{num,1}(sub,1) = data.rtime(data.cho== heur) .* (data.cho~=dd1) .* (data.cho~=dd2));
%         o_le{num,1}(sub,1) = mean((data.cho(sub,:) ~= heur(sub,:)) .* (data.cho(sub, :)==dd1(sub,:)) .* (data.cho(sub, :)~=dd2(sub,:)));
%         o_pm{num,1}(sub,1) = mean((data.cho(sub,:) ~= heur(sub,:)) .* (data.cho(sub, :)~=dd1(sub,:)) .* (data.cho(sub, :)==dd2(sub,:)));
%         other1(sub) = mean((data.cho(sub,:) ~= heur(sub,:)) .* (data.cho(sub, :)~=dd1(sub,:)) .* (data.cho(sub, :)~=dd2(sub,:)));
%         other2(sub) = mean((data.cho(sub,:) == heur(sub,:)) .* (data.cho(sub, :)==dd1(sub,:)) .* (data.cho(sub, :)==dd2(sub,:)));
%         other3(sub) = mean((data.cho(sub,:) == heur(sub,:)) .* (data.cho(sub, :)~=dd1(sub,:)) .* (data.cho(sub, :)==dd2(sub,:)));
%         other4(sub) = mean((data.cho(sub,:) ~= heur(sub,:)) .* (data.cho(sub, :)==dd1(sub,:)) .* (data.cho(sub, :)==dd2(sub,:)));
%         other5(sub) = mean((data.cho(sub,:) == heur(sub,:)) .* (data.cho(sub, :)==dd1(sub,:)) .* (data.cho(sub, :)~=dd2(sub,:)));
% 
%     end
%      for sub = 1:nsub
        o_heur{num,1} = -data.rtime(logical((data.cho== heur) .* (data.cho~=dd1)));
        o_le{num,1} = -data.rtime(logical((data.cho~= heur) .* (data.cho==dd1)));
        none{num,1} = -data.rtime(logical((data.cho~=heur).*(data.cho~=dd1)));
        both{num,1} = -data.rtime(logical((data.cho==heur).*(data.cho==dd1)));

    
%     param = load(...
%         sprintf('data/post_test_fitparam_EE_exp_%d_%s',...
%         round(exp_num), num2str(sess)));
%     Q = param.midpoints;
% 
%     ee{num,1} = mean(argmax_estimate(data, symp, lotp, Q),2); 



end

%-------------------------------------------------------------------------%
% plot                                                                    %
% ------------------------------------------------------------------------%

x1 = reshape(vertcat(o_heur{:}), [], 1);
x2 = reshape(vertcat(o_le{:}), [], 1);
x4 = reshape(vertcat(none{:}), [], 1);
x3 = reshape(vertcat(both{:}), [], 1);

y = reshape(vertcat(ed{:}), [],1);

figure('Position', [0, 0, 1000, 800], 'visible', 'on');


 skylineplot({x1'; x2'; x3'; x4'}, 10,...
        colors,...
        -5000,...
        -200,...
        fontsize+5,...
        '',...
        '',...
        '-RT (ms)',...
        {'Heur', 'LE estimates', 'Both', 'None'},...
        0);
% subplot(1,3, 1)
% 
% scatterCorr(x1, y, orange_color, .5, 1, 50, 'w', 0);
% xlabel('Heuristic-explained score');
% %xlim([.2, 1.08])
% ylabel('-RT (ms)');
% box off
% set(gca, 'tickdir', 'out');
% 
% subplot(1,3, 2)
% 
% scatterCorr(x2, y, blue_color, .5, 1, 50, 'w', 0);
% xlabel('LE estimates-explained score');
% ylabel('-RT (ms)');
% %xlim([.2, 1.08])
% 
% box off
% set(gca, 'tickdir', 'out');
% 
% subplot(1,3, 3)
% 
% scatterCorr(x3, y, magenta_color, .5, 1, 50, 'w', 0);
% xlabel('PM estimates-explained score');
% ylabel('-RT (ms)');
% %xlim([.2, 1.08])
% 
% box off
% set(gca, 'tickdir', 'out');

% subplot(1,4, 4)
% 
% scatterCorr(x4, y, green_color, .5, 1, 50, 'white', 0);
% xlabel('EE estimates-explained score');
% ylabel('-RT (ms)');
% xlim([0, 1.08])
% 
% box off
% set(gca, 'tickdir', 'out');


suptitle('ED choices RT / Pooled Exp. 1,2,3,4,5,6.1,6.2');

saveas(gcf, 'fig/score_RT_1234.svg');


% ------------------------------------------------------------------------%

function score = heuristic(data, symp,lotp)

for sub = 1:size(data.cho,1)
    count = 0;
    
    for t = 1:size(data.cho,2)
        
        count = count + 1;
        
        if data.p2(sub,t) >= .5
            prediction = 2;
        else
            prediction = 1;
        end
        
        score(sub, count) = prediction;
        
    end
end
end


function score = argmax_estimate(data, symp, lotp, values)
for sub = 1:size(data.cho,1)
    count = 0;
    
    for t = 1:size(data.cho,2)
        
        count = count + 1;
        
        if data.p2(sub,t) >= values(sub, symp==data.p1(sub,t))
            prediction = 2;
        else
            prediction = 1;
        end
        
        score(sub, count) = prediction;
        
    end
end
end




        