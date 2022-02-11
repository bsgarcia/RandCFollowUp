%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------
selected_exp = [1.1, 1.2];
displayfig = 'on';

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*length(selected_exp), 5.3/1.25], 'visible', displayfig)
num = 0;

filename = 'Fig2C';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);

for exp_num = selected_exp
    num = num + 1;

    
    %---------------------------------------------------------------------%
    % get data parameters                                                 %
    % --------------------------------------------------------------------%
    sess = de.get_sess_from_exp_num(exp_num);
    name = de.get_name_from_exp_num(exp_num);
    nsub = de.get_nsub_from_exp_num(exp_num);
    
    throw = de.extract_PM(exp_num);

    nsym = length(unique(throw.p1(throw.op1==0)));
    disp(nsym)
    p1 = unique(throw.p1(throw.op1==0))'.*100;
 
    
    sim_params.exp_num = exp_num;
    sim_params.de = de;
    sim_params.sess = sess;
    sim_params.exp_name = name;
    sim_params.nsub = nsub;
    sim_params.op=0;
   
                    
    sim_params.model = 2;
    [midpoints3, throw] = get_qvalues(sim_params);
    
    
    ev = p1;
    varargin = ev;
    x_values = ev;
    x_lim = [0, 100];
   
    subplot(1, length(selected_exp), num)

    slope3 = add_linear_reg(midpoints3.*100, ev, magenta);
    hold on
    
    brickplot(...
        midpoints3'.*100,...
        magenta.*(ones(nsym, 3)), ...
        [-8, 108], fontsize,...x_va
        '',...
        '',...
        '', varargin,1, x_lim, x_values, 3, 0);
    %brickplot()
    xtickangle(0)
    if num == 1
        ylabel('Estimated p(win) (%)')
    end
   
    xlabel('E-option p(win) (%)');
    box off
    hold on
    
    set(gca,'tickdir','out')

end

saveas(gcf, figname);

