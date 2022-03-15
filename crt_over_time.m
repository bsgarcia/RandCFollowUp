%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [10.1];
displayfig = 'on';

% filenames
filename = 'Fig2A';
figfolder = 'fig';

figname = sprintf('%s/%s.svg', figfolder, filename);
stats_filename = sprintf('data/stats/%s.csv', filename);


num = 0;
for exp_num = selected_exp
    num = num + 1;

    data = de.extract_nofixed_LE(exp_num);
    psym = unique(data.p1);

    dcorrLE = nan(size(data.corr));
    for sub = 1:data.nsub
        t = 0;
        for i = [1, 2]
            for p1 = 1:length(psym)
                for p2 = 1:length(psym)-1
                    t = t + 1;
                    pp1 = data.p1(sub, t);
                    pp2 = data.p2(sub, t);
                    mask = logical((data.p1(sub,:)==pp1).*(data.p2(sub,:)==pp2));
                    d1 = data.corr(sub, mask);
                    d(p2) = d1(i);
                    dp1(p2) = pp1;
                end
                t1 = t - 6;
                order = shuffle(1:7);
                dcorrLE(sub,t1:t) = d(order);
                dp1LE(sub, t1:t) = dp1(order);

            end
        end
    end


    data = de.extract_EE(exp_num);
    psym = unique(data.p1);
    dcorrEE = nan(size(data.corr));

    for sub = 1:data.nsub
        t = 1;
        for p1 = 1:length(psym)
            for p2 = 1:length(psym)-1

                pp1 = data.p1(sub, t);
                pp2 = data.p2(sub, t);


                mask = logical((data.p1(sub,:)==pp1).*(data.p2(sub,:)==pp2));
                d = data.corr(sub, mask);
                dcorrEE(sub, t) = d;
                dp1EE(sub, t) = pp1;
                t = t+1;

            end
        end

    end

    data = de.extract_ED(exp_num);
    psym = unique(data.p1);
    dcorrES = nan(size(data.corr));

    for sub = 1:data.nsub
        t = 1;
        for p1 = 1:length(psym)
            for p2 = 1:11

                pp1 = data.p1(sub, t);
                pp2 = data.p2(sub, t);


                mask = logical((data.p1(sub,:)==pp1).*(data.p2(sub,:)==pp2));
                d = data.corr(sub, mask);
                dcorrES(sub, t) = d;
                dp1ES(sub, t) = pp1;
                t = t+1;

            end
        end

    end

end
dcorrLE(:, 1) = .49;

figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*10, 5.3/1.25*5], ...
    'visible', displayfig)
surfaceplot(dcorrLE', [.5, .5, .5], blue, 1, 0.3, 0, 1, 10, 'LE blocks','trials','accuracy');
hold on

sym_block = 1:7:112;
for i = sym_block
    xline(i, 'linestyle', '--', 'color', 'k')

    text(i+2, .1,sprintf('%.1f', mean(dp1LE(:, i+(i==0)))))
    hold on
end


figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*10, 5.3/1.25*5], ...
    'visible', displayfig)
surfaceplot(dcorrEE', [.5, .5, .5], green, 1, 0.3, 0, 1, 10, 'EE blocks','trials','accuracy');
hold on

sym_block = 1:7:56;
for i = sym_block
    xline(i, 'linestyle', '--', 'color', 'k')
    text(i+2, .1,sprintf('%.1f', mean(dp1EE(:, i+(i==0)))))
    hold on
end


figure('Renderer', 'painters','Units', 'centimeters',...
    'Position', [0,0,5.3*10, 5.3/1.25*5], ...
    'visible', displayfig)
surfaceplot(dcorrES', [.5, .5, .5], orange, 1, 0.3, 0, 1, 10, 'EE blocks','trials','accuracy');
hold on

sym_block = 1:11:88;
for i = sym_block
    xline(i, 'linestyle', '--', 'color', 'k')
    text(i+2, .1,sprintf('%.1f', mean(dp1ES(:, i+(i==0)))))
    hold on
end



