% This script runs the simulations
clear all

addpath './simulation'
addpath './fit'

% ------------------------------------------------------------------------
% load data
% ------------------------------------------------------------------------
conf = 'block';
feedback = 'complete'; 

fit_folder = 'data/fit/';
fit_filename = sprintf('%s_%s', conf, feedback);
sim_folder = 'data/sim/';
sim_filename = fit_filename;


data = load(sprintf('%s%s', fit_folder, fit_filename));
fit_params = data.data('parameters');
whichmodel = [1 2 5 6 7];
% ------------------------------------------------------------------------
% Parameters
% ------------------------------------------------------------------------
conds1 = repelem(1:4, 30);
conds2 = repmat(4:14, [1, 8]);
ev = repmat([-1, -0.8, -0.6, -0.4, -0.2, 0, .2, .4, .6, .8, 1], [1, 8]);
p2 = repmat([0, .1, .2, .3, .4, .5, .6, .7, .8, .9, 1], 1, 8);
p1 = repelem([.9, .1, .8, .2, .7, .3, .6, .4], 1, 11);
conds = horzcat(conds1, conds2);
sym = repelem(1:8, 11);
phase = vertcat(ones(120, 1), ones(length(ev), 1) .* 2);

tmax = length(phase);  
noptions = 2;
nagent = 1; % n agent per subject
ncond = 4;
rewards = cell(ncond, 1, 1);
probs = cell(ncond, 1, 1);

rewards{1} = {[-1, 1], [-1, 1]};
probs{1} = {[0.1, 0.9], [0.9, 0.1]};

rewards{2} = {[-1, 1], [-1, 1]};
probs{2} = {[0.2, 0.8], [0.8, 0.2]};

rewards{3} = {[-1, 1], [-1, 1]};
probs{3} = {[0.3, 0.7], [0.7, 0.3]};

rewards{4} = {[-1, 1], [-1, 1]};
probs{4} = {[0.4, 0.6], [0.6, 0.4]};

r = repelem({{}}, tmax);
p = repelem({{}}, tmax);

for t = 1:120
    r{t} = rewards{conds(t)};
    p{t} = probs{conds(t)};
end

sym_rewards = reshape(vertcat(rewards{:})', [], 1);
sym_probs = reshape(vertcat(probs{:})', [], 1);

for t = 121:tmax
    r{t} = sym_rewards{sym(t-120)};
    p{t} = sym_probs{sym(t-120)};
end
% ------------------------------------------------------------------------
% Parameters
% ------------------------------------------------------------------------
sim_params.noptions = noptions;
sim_params.tmax = tmax;
sim_params.nagent = nagent;
sim_params.ncond = ncond;
sim_params.p = p;
sim_params.r = r;
sim_params.conds = conds;
sim_params.name = fit_filename;
sim_params.show_window = true;
sim_params.models = whichmodel;
sim_params.phase = phase;
sim_params.ev = ev;
sim_params.sym = sym;
sim_params.p1 = p1;
sim_params.p2 = p2;

data = simulation(fit_params, sim_params);
save(sprintf('%s%s', sim_folder, sim_filename), 'data');

