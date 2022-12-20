%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

% ------------------------------------------------------------------------
% customizable parameters
% ------------------------------------------------------------------------
selected_exp = [1.1, 1.2];
modality = 'LE';
color = blue;
displayfig = 'on';
filename = 'accuracy';

% ------------------------------------------------------------------------
% fixed parameters
% ------------------------------------------------------------------------
T_exp = table();
T_con = table();

% filenames

figfolder = 'fig';

figname = sprintf('%s/%s.png', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);
stats_filename2 = sprintf('data/stats/exp_%s.csv', filename);


figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], ...
    'visible', displayfig)


sub_count = 0;
num = 0;
for exp_num = selected_exp
    clear dd
    num = num + 1;

    if exp_num == 1.1
        data = de.extract_LE(exp_num);
        data_ed = de.extract_ES(exp_num);

        ncon = length(unique(data.con));

        dd = NaN(ncon, data.nsub);
        cons = flip(unique(data.con));

        for i = 1:ncon
            for sub = 1:data.nsub

                dd(i, sub) = mean(...
                    data.corr(sub, data.con(sub,:)==cons(i)));


                T3 = table(...
                    sub+sub_count, exp_num,  dd(i, sub), -1, cons(i), ...
                    'variablenames',...
                    {'subject', 'exp_num', 'score','psym', 'cond'}...
                    );

                T_con = [T_con; T3];
                % end
            end
        end
    elseif exp_num == 1.2
        data = de.extract_nofixed_LE(exp_num);
        data_ed = de.extract_ES(exp_num);

        nsym = unique(data.p1);

        dd = NaN(length(nsym), data.nsub);

        for i = 1:length(nsym)
            for sub = 1:data.nsub

                dd(i, sub) = mean(...
                    data.corr(sub, data.p1(sub,:)==nsym(i)));
                %if ismember(cons(i), [1, 4])


                T3 = table(...
                    sub+sub_count, exp_num,   dd(i, sub), nsym(i), -1, ...
                    'variablenames',...
                    {'subject', 'exp_num', 'score', 'psym', 'cond'}...
                    );

                T_con = [T_con; T3];
                % end
            end

        end
    end


    %sub_count = sub_count + sub;
    if exp_num == 1.1
        subplot(1, length(selected_exp), num)

        if num == 1
            labely = 'Correct choice rate (%)';
        else
            labely = '';
        end

        plot([10, 85], [50, 50], 'color', 'k', 'linestyle', ':')

        if exp_num == 4
            xvalues = [10, 85];
            varargin = {'60/40', '90/10'};
        else
            xvalues = [10, 35, 60, 85];
            varargin = {'60/40','70/30', '80/20', '90/10'};
        end
        brickplot(...
            dd.*100,...                             %data
            color.*ones(4, 3),...                   %color
            [-0.08*100, 1.08*100], fontsize,...     %ylim     % fontsize
            '',...                                  %title
            '',...                                  %xlabel
            '',...                                  %ylabel
            varargin,...                            %varargin
            0,...                                   %noscatter
            [-10, 105],...                          %xlim
            xvalues,...                    %xvalues
            5, ...                                  %barwidth
            0 ...                                   %median
            );

        plot([10, 85], [50, 50], 'color', 'k', 'linestyle', ':')
        xlabel('E-options pairs');
        ylabel(labely);

        box off
        hold on

        %set(gca, 'ytick', [0:10]./10);
        set(gca,'TickDir','out')
        set(gca, 'fontsize', fontsize);
    elseif exp_num == 1.2
        subplot(1, length(selected_exp), num)

        labely = 'Correct choice rate (%)';
        labelx = 'E-option p(win) (%)';

        plot([10, 85], [50, 50], 'color', 'k', 'linestyle', ':')

        xvalues = 10:10:80;
        varargin = {'10', '20', '30', '40','60', '70', '80', '90'};
        
        brickplot(...
            dd.*100,...                             %data
            color.*ones(8, 3),...                   %color
            [-0.08*100, 1.08*100], fontsize,...     %ylim     % fontsize
            '',...                                  %title
            '',...                                  %xlabel
            '',...                                  %ylabel
            varargin,...                            %varargin
            0,...                                   %noscatter
            [-10, 105],...                          %xlim
            xvalues,...                    %xvalues
            5, ...                                  %barwidth
            0 ...                                   %median
            );

        plot([10, 85], [50, 50], 'color', 'k', 'linestyle', ':')
        xlabel(labelx);
        ylabel(labely);

        box off
        hold on

        %set(gca, 'ytick', [0:10]./10);
        set(gca,'TickDir','out')
        set(gca, 'fontsize', fontsize);
    end

end
saveas(gcf, figname);

writetable(T_con, stats_filename);
writetable(T_exp, stats_filename2);
f = gcf;
exportgraphics(f, figname,'Resolution',1000)
%saveas(gcf, figname);

