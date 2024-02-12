clearvars;

%% cohort structure
cohort_pars.nsamps_per_condition = 1;
cohort_pars.min_parfor_num = 4e4;
cohort_pars.last_dose_is_no_dose = false;
cohort_pars.fields_to_ignore_for_grid_and_comparison = "plot_pars";
cohort_pars.linkingFunction = @staggeredDosing;
cohort_pars.include_control = true;
cohort_pars.previous_cohort_search_pattern = "data/cohort_*";
cohort_pars.sim_function = @simPatient;
cohort_pars.update_timer_every = 8;
cohort_pars.parpool_options.resources = "Processes";

%%
M = allBaseParameters();
%%
M.save_pars.dt = 2880; % how many minutes between saving model location data

M.flags.fgfr3_affects_cytotoxicity = false;
M.flags.fgfr3_affects_immune_recruit = true;

M.setup.grid_size_microns_x = 1000;
M.setup.grid_size_microns_y = 1000;
M.setup.grid_size_microns_z = 1000;

M.setup.prop_ha0 = .5;
M.setup.prop_mut0 = 1;
M.setup.N0 = 100;

M.setup.censor_time = 1 * 1440;
M.setup.start_day_of_week = 1; % 0 = start on a Monday

M.pars.max_dt = 15; % number of minutes per step
M.pars.max_tumor_size = Inf;
M.pars.prolif_rate = 2 / 1440;


M.fgfr3.tum_prolif_up = (0.8571428571 * logspace(-2,2,2)')/1440;
M.fgfr3.gammaT = 1/6 * logspace(-2,2,2)';

M.fgfr3.n_doses = [10;15]; % two weeks of doses
M.fgfr3.dose_val = 1e3; % initial concentration of circulating inhibitor in nM (based on Grunewald and the max plasma concentration with 75mg/kg given to a mouse; I have eyeballed the number, extrapolating back to t=0)
M.fgfr3.start_day = [Inf;6;13];

M.checkpoint.diffusivity_apd1 = 0.1 * 60;
M.checkpoint.n_doses = [4;6]; % two weeks of doses
M.checkpoint.dose_val = 100;
M.checkpoint.start_day = [Inf;6;13];

M.immune_stimulatory_factor_pars.reach = 5;
M.immune_stimulatory_factor_pars.length_scale = 20;

M.immune_pars.immune_recruit_rate = 0.025 / 1440;
M.immune_pars.apop_rate = 0.2 / 1440;
M.immune_pars.apop_rate_exhausted = 0.2 / 1440;
M.immune_pars.aicd_rate = 0.7 / 1440;
M.immune_pars.move_rate_microns = 2;
M.immune_pars.steps_per_move = 4;


%%
simCohort(M,cohort_pars);

load gong.mat
sound(y,10*8192)