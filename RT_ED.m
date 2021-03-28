%-------------------------------------------------------------------------%
init;
show_current_script_name(mfilename('fullpath'));

%-------------------------------------------------------------------------%
% parameters of the script                                                %
%-------------------------------------------------------------------------%
selected_exp = [5, 6];%, 6.2, 7.1, 7.2];
displayfig = 'on';
colors = [orange; orange];
zscored = 0;

stats_data = table();
%d = cell(11, 1);
%e = cell(8, 1);

num = 0;

lotp = [0, .1, .2, .3, .4, .5,.6, .7, .8, .9, 1];
symp = [.1, .2, .3, .4,.6, .7, .8, .9];

sub_count = 0;
for exp_num = selected_exp
    
    num = num + 1;
    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    data_ed = de.extract_ED(exp_num);
    data_ee = de.extract_EE(exp_num);
%     
%         
%     for p = 1:length(lotp)
%         mask_lot = (data_ed.p2==lotp(p));
%         %mask_cho = (data_ed.cho==2);
%         d{p} = [d{p} data_ed.rtime(logical(mask_lot))'];
%     end
%     
%     for p = 1:length(symp)
%         mask_sym = (data_ed.p1==symp(p));
%         %mask_cho = (data_ed.cho==1);
%         e{p} = [e{p} data_ed.rtime(logical(mask_sym))'];
%     end
    
    
    for sub = 1:nsub
        
        for p = 1:length(lotp)
           % mask_lot = (data_ed.cho(sub,:)==2);
            %mask_cho1 = (data_ed.cho(sub,:)==1);
            mask_lot = (data_ed.p2(sub,:)==lotp(p));
           % mask_cho2 = (data_ed.cho(sub,:)==2);
          %  if sum(mask_lot.*mask_cho2, 'all') > 0
                d(sub+sub_count,p) = median(...
                data_ed.rtime(sub, logical(mask_lot)));   
             
           % else
          
          %      d(sub+sub_count,p) = NaN;
          %  end
           
        end
        
        for p = 1:length(symp)
             mask_lot = (data_ed.p1(sub,:)==symp(p));
             mask_cho1 = data_ee.cho(sub,:) == 1;
             mask_cho2 = data_ee.cho(sub,:) == 2;
             mask_p1 = data_ee.p1(sub,:) == symp(p);
             mask_p2 = data_ee.p2(sub,:) == symp(p);
             e(sub+sub_count,p) = median(...
                data_ed.rtime(sub, logical(mask_lot)));  
            ee(sub+sub_count,p) = median(data_ee.rtime(sub, logical((mask_p1.*mask_cho1) + (mask_p2.*mask_cho2))));
        end
    end
%         for mod_num = 1:3
%             T1 = table(...
%                 sub+sub_count, exp_num, dd{mod_num},...
%                 {modalities{mod_num}}, 'variablenames',...
%                 {'subject', 'exp_num', 'RT', 'modality'}...
%                 );
%             stats_data = [stats_data; T1];
%         end
    %end
    
    sub_count = sub_count + sub;

end
figure('Units', 'centimeters',...
    'Position', [0,0,5.3*2.7, 5.3/1.25*2.7], 'visible', displayfig)
% 
% if zscored
%     y1 = -3;
%     y2 = 1;
% else
%     y1 = 0;
%     y2 = 6500;
% end
% 
% 
% x1 = e';
% x2 = d';
% x3 = ee';

labely = 'Median reaction time per subject (ms)';
x_lim = [0,100];
x_values = 5:100/11:100;
%brickplot(data,colors,y_lim,fontsize,mytitle, ... 
 %   x_label,y_label,varargin, noscatter, x_lim, x_values, width1, median)
subplot(1, 3, 1)
brickplot(d',...
    orange.*ones(11, 3),...
    [1000, 2500],...
    fontsize,...
    '',...
    '',...
    labely,...
    lotp.*100,1,[0,100], x_values, .18,0);

set(gca, 'tickdir', 'out');
box off;

x_lim = [0,100];
x_values = 5:100/8:100;
%brickplot(data,colors,y_lim,fontsize,mytitle, ... 
 %   x_label,y_label,varargin, noscatter, x_lim, x_values, width1, median)
subplot(1, 3, 2)
    
brickplot(e',...
    orange.*ones(8, 3),...
    [1000, 2500],...
    fontsize,...
    '',...
    '',...
    '',...
    symp.*100,1,[0,100], x_values, .18,0);

set(gca, 'tickdir', 'out');
box off;

subplot(1, 3, 3)

x_lim = [0,100];
x_values = 5:100/8:100;
%brickplot(data,colors,y_lim,fontsize,mytitle, ... 
 %   x_label,y_label,varargin, noscatter, x_lim, x_values, width1, median)
    
brickplot(ee',...
    green.*ones(8, 3),...
    [1000, 2500],...
    fontsize,...
    '',...
    '',...
    '',...
    symp.*100,1,[0,100], x_values, .18,0);

set(gca, 'tickdir', 'out');
box off;



mkdir('fig', 'violinplot');
mkdir('fig/violinplot/', 'RT');
saveas(gcf, 'fig/violinplot/RT/RT.svg');

% save stats file
mkdir('data', 'stats');
stats_filename = 'data/stats/RT_E_D_EE.csv';
writetable(stats_data, stats_filename);

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




        