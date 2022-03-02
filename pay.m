% %------------------------------------------------------------------------
% filenames = {
%     'interleaved_incomplete', 'block_incomplete', 'block_complete', 'block_complete_simple',...
%     'block_complete_mixed',  'block_complete_mixed_2s',...
%     'block_complete_mixed_2s_amb_heuristic', 'block_complete_mixed_2s_amb_final'};%------------------------------------------------------------------------
% dd = [];
% 
% for name = filenames
%     name = name{:};
%     
%     data = readtable(sprintf('data/demographics/%s.csv', name));
%     
%     d = data(strcmp(data.status, {'APPROVED'}), :).bonus;
%     dd = [dd; d];
%     i = 1;
% 
% end
%dd = dd(~isnan(dd))

data = readtable('nofixed_complete_feedback.csv');

%d = data(:, strcmp(data.EXP, 'NoFixed1'));
mask_1 = logical(strcmp(data.EXP, 'Feedback2'));
data = data(mask_1,:);
%mask_2 = logical(ismember(data.SESSION, [0, 1]));
%mask = logical(mask_1.*mask_2);
%data.SESSION(mask_1) = data.SESSION(mask_1)==0;
sub_ids = unique(data.ID);

for i = 1:length(sub_ids)
    
    mask_sub = strcmp(data.ID, sub_ids(i));
    mask_sess = ismember(data.SESSION, [0,1]);
    mask_eli = ismember(data.ELIC, [0, -1]);
    mask_t = ismember(data.TRIAL, [151]);
    mask_corr = data.CORRECT_CHOICE == 1;
    
    a = sum(data(mask_eli&mask_sess&mask_sub, :).OUT);
    r = max(data(mask_sess&mask_sub, :).REW);
    if size(data(mask_sub, :),1) > 500
        fprintf('%s,%.2f\n',sub_ids{i}, a.*0.0122+2.5);
    end
    b = a.*0.0132+2.5;
    dd(i) = b;
    %b = mean(data(mask_eli&mask_sess&mask_sub,:).CORRECT_CHOICE);
   
end
