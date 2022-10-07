init
t = table();
for exp = [1,2,3,4,5,6,7,8,9,10]
    dd = de.extract_LE(exp);
    sub_ids = unique(dd.sub_ids);
    for id = sub_ids
        T1 = table(...
                 id,exp, {dd.name}....
                , 'variablenames',...
                {'id', 'exp_num', 'exp_name'}...
                );
            t = [t; T1];
    end
end
writetable(t, 'sub_ids.csv')