function immune_pars = baseImmunePars()

%% event parameters
immune_pars.prolif_rate = 0.5 / 1440; % immune proliferation rate per min
immune_pars.occmax = 22; % threshold number of occupied neighbors for immune proliferating
immune_pars.apop_rate = 0.05 / 1440; % immune apoptosis rate per min
immune_pars.apop_rate_exhausted = 0.05 / 1440; % exhausted ctl apoptosis rate per min (added 2023-09-04, I'll probably start shifting to ctl nomenclature)

immune_pars.move_rate_microns = 2; % immune movement rate in microns / min
immune_pars.steps_per_move = 10; % number of moves an immune cell will attempt whenever it decides to move (basically a persistence time)
immune_pars.occmax_move = 25; % max number of occupied neighbors for an immune cell that can still move

immune_pars.conjugation_rate = 0.02; % rate at which immune cells attempt to attack nearby tumor cell (per min)
% immune_pars.deactivation_rate_isf = 2; % max deactivation rate of CTLs at saturation of ISF
immune_pars.deactivation_rate_pd1 = 1 / (8 * 60); % max deactivation rate of CTLs at saturation of PD1 (assume that a CTL kills around 8 tumor cells at a rate roughly equal to 1 per hour, so it will succumb to overstimulation at about this rate)

%% killing parameters
immune_pars.slow_kill_rate = 1 / (2*60); % rate of slow kill in min^-1 (should be once per 2 hours)
immune_pars.fast_kill_rate = 1 / (.5*60); % rate of fast kill in min^-1 (should be once per half hour)

%% aicd pars
immune_pars.time_to_seek = 120; % time for an immune cell to seek before beginning to undergo AICD (activation-induced cell death)
immune_pars.extra_seek_time_on_arrival = Inf * 60; % time for an immune cell to seek before beginning to undergo AICD (activation-induced cell death)
immune_pars.aicd_rate = 1/60; % chosen such that it happens on the order of hours

%% recruitment parameters
immune_pars.immune_recruit_rate = 0.1 / 1440; % immune cells recruited per tumor cell per min
immune_pars.min_imm_recruit_prop = 0.1; % reduction of immune recruitment rate at saturation of phiD
immune_pars.min_imm_recruit_prop_ec50 = 1/6; % ec50 of hill function for phiD decreasing immune recruitment

%% immune stimulatory factor parameters
immune_pars.isf_prolif_ec50 = 1;
immune_pars.isf_prolif_hill_coefficient = 2;
immune_pars.isf_prolif_saturation_factor = 2.5;

immune_pars.isf_gradient_hill_coefficient = 2;

immune_pars.deactivation_ec50_isf = 50;
immune_pars.deactivation_hill_coefficient_isf = 4;

immune_pars.low_antigen_isf_factor = 0.5;

%% pd1 parameters
immune_pars.deactivation_ec50_pd1_num_tum_neighbors = 1; % number of tumor neighbors w/o therapy at which the deactivation is at half the saturation rate
immune_pars.deactivation_ec50_pd1_proportion = 0.5; % proportion of equilibrium concentration of pd1-pdl1 complexes in absence of apd1 at which the deactivation rate for ctls is cut in half
immune_pars.deactivation_hill_coefficient_pd1 = 2;

%% deactivation function
immune_pars.deactivation_function_type = "pd1_hill";

