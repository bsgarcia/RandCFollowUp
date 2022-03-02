% data = readtable('block_complete_mixed_2s_nofixed_not_recoded.csv');
% 
% %d = data(:, strcmp(data.EXP, 'NoFixed1'));
% mask_1 = logical(strcmp(data.EXP, 'NoFixed1'));
% mask_2 = logical(ismember(data.SESSION, [0, 1]));
% mask = logical(mask_1.*mask_2);
% data.SESSION(mask) = data.SESSION(mask)==0;
% 
% writetable(data, 'block_complete_mixed_2s_nofixed.csv')

data = readtable('block_complete_mixed_2s_nofixed.csv');
% 
% mask_1 = logical( strcmp(data.EXP, 'NoFixed1'));
% % mask_1 = logical(strcmp(data.EXP, 'NoFixed1'));
% mask_2 = logical(ismember(data.SESSION, [0, 1]));
% mask = logical(mask_1.*mask_2);
% data.SESSION(mask) = data.SESSION(mask)==0;

data.Properties.VariableNames([31]) = {'within_sess'};
data.within_sess = strcmp(data.EXP, 'NoFixed2');
% 
writetable(data, 'block_complete_mixed_2s_nofixed.csv')