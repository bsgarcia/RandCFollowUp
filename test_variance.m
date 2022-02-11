%-------------------------------------------------------------------------
init;
%-------------------------------------------------------------------------

selected_exp = [2];

for exp_num = selected_exp
    
    data = de.extract_LE(exp_num);
    data.out = data.out==1;
    data.cfout = data.cfout==1;
    
    p = unique(data.p1);
    for sub = 1:data.nsub
        for i = 1:length(p)
            
        out(sub, i) = mean([...
            data.out(sub, logical((data.cho(sub, :)==1).*(data.p1(sub,:)==p(i))))...
            data.cfout(sub, logical((data.cho(sub, :)==2).*(data.p1(sub,:)==p(i))))], 'all');
    end
    end
end