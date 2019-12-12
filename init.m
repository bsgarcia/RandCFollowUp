% --------------------------------------------------------------------
% This script is ran by other main scripts at init 
% --------------------------------------------------------------------

close all
clear all

addpath './fit'
addpath './plot'
addpath './data'
addpath './'

%------------------------------------------------------------------------
% Set parameters
%------------------------------------------------------------------------

% filenames and folders
filenames = {
    'interleaved_incomplete', 'block_incomplete', 'block_complete',...
    'block_complete_mixed', 'block_complete_mixed_2s'};

folder = 'data';

% exclusion criteria
rtime_threshold = 100000;
catch_threshold = 1;
n_best_sub = 0;
allowed_nb_of_rows = [258, 288, 255, 285, 376, 470, 648, 742];

% colors
colors = [0.3963    0.2461    0.3405;...
    1 0 0;...
    0.7875    0.1482    0.8380;...
    0.4417    0.4798    0.7708;...
    0.5992    0.6598    0.1701;...
    0.7089    0.3476    0.0876;...
    0.2952    0.3013    0.3569;...
    0.1533    0.4964    0.2730];
blue_color = [0.0274 0.427 0.494];
blue_color_min = [0 0.686 0.8];
% create a default color map ranging from blue to dark blue
len = 8;
blue_color_gradient = zeros(len, 3);
blue_color_gradient(:, 1) = linspace(blue_color_min(1),blue_color(1),len)';
blue_color_gradient(:, 2) = linspace(blue_color_min(2),blue_color(2),len)';
blue_color_gradient(:, 3) = linspace(blue_color_min(3),blue_color(3),len)';

orange_color = [0.8500, 0.3250, 0.0980];

% display figures
displayfig = 'on';

fit_folder = 'data/fit/qvalues/';

%-------------------------------------------------------------------------
% Load Data (do cleaning stuff)
%-------------------------------------------------------------------------
[d, idx] = load_data(filenames, folder, rtime_threshold, catch_threshold, ...
    n_best_sub, allowed_nb_of_rows);
show_loaded_data(d);
show_parameter_values(rtime_threshold, catch_threshold, allowed_nb_of_rows);

function [d, idx] = load_data(filenames, folder,  rtime_threshold,...
    catch_threshold, n_best_sub, allowed_nb_of_rows)

    d = struct();
    i = 1;
    for f = filenames
        [dd{i}, sub_ids{i}, idx] = DataExtraction.get_data(...
            sprintf('%s/%s', folder, char(f)));
        i = i + 1;
    end
    
    i = 1;
    for f = filenames
        d = setfield(d, char(f), struct());
        new_d = getfield(d, char(f));
        new_d.sub_ids = ...
            DataExtraction.exclude_subjects(...
            dd{i}, sub_ids{i}, idx, catch_threshold, rtime_threshold,...
            n_best_sub, allowed_nb_of_rows);
        new_d.data = dd{i};
        new_d.nsub = length(new_d.sub_ids);
        d = setfield(d, char(f), new_d);

        i = i + 1;
    end
    
end

function show_loaded_data(d)
    disp('Loaded struct with fields: ');
    filenames = fieldnames(d);
    disp(filenames);
    disp('N sub:');
    for f = filenames'
        f = f{:};
        if ~strcmp(f, 'idx')
            fprintf('%s: N=%d \n', f, d.(f).nsub);
        end
    end
end

function show_parameter_values(rtime_threshold, catch_threshold, allowed_number_of_rows)
fprintf('\nParameter values:\n');
fprintf('Response time threshold=%d seconds\n', rtime_threshold/1000);
fprintf('Correct catch trials threshold=%d  \n', catch_threshold.*100);
fprintf(['Number of trials allowed and retrieved per subject=' ...
    repmat('%d ', 1, length(allowed_number_of_rows))], allowed_number_of_rows);
fprintf('\n');
end