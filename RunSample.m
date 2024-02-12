clearvars;

%%
M = allBaseParameters();

%%
M.save_pars.dt = 360; % set to Inf to not save anything; otherwise dt is in minutes
M.save_pars.track_drug_concentrations = true;

M.flags.fgfr3_affects_cytotoxicity = false;
M.flags.fgfr3_affects_immune_recruit = true;

M.setup.start_day_of_week = 1; % start on a Monday and start therapy after one week
M.setup.grid_size_microns_x = 1000;
M.setup.grid_size_microns_y = 1000;
M.setup.grid_size_microns_z = 1000;

M.setup.prop_ha0 = 0.5;
M.setup.prop_mut0 = 0.5;
M.setup.N0 = 100;
M.setup.censor_time = 1 * 1440;

M.pars.max_dt = 15; % number of minutes per step
M.pars.max_tumor_size = Inf;
M.pars.prolif_rate = 2 / 1440;

M.fgfr3.tum_prolif_up = 0.5 / 1440;
M.fgfr3.start_day = 6;
M.fgfr3.n_doses = 10;
M.fgfr3.dose_val = 1e3; % initial concentration of circulating inhibitor in nM (based on Grunewald and the max plasma concentration with 75mg/kg given to a mouse; I have eyeballed the number, extrapolating back to t=0)

M.checkpoint.diffusivity_apd1 = 0.1 * 60;
M.checkpoint.n_doses = 4; % two weeks of doses
M.checkpoint.dose_val = 100;
M.checkpoint.start_day = 6;

M.plot_pars.plot_fig = false;
M.plot_pars.plot_start = 0;
M.plot_pars.plot_location = true;
M.plot_pars.use_carveout = true;
M.plot_pars.make_slice_movie = false;
M.plot_pars.slice_vid_days_per_second = 1/24;

la_color = [0 0 1];
ha_color = [0.2,1,0.5];
M.plot_pars.tumor_colors = repelem([la_color;ha_color],2,1);

M.immune_stimulatory_factor_pars.reach = 5;
M.immune_stimulatory_factor_pars.length_scale = 20;

M.immune_pars.immune_recruit_rate = 0.025 / 1440;
M.immune_pars.apop_rate = 0.2 / 1440;
M.immune_pars.apop_rate_exhausted = 0.2 / 1440;
M.immune_pars.aicd_rate = 0.7 / 1440;
M.immune_pars.move_rate_microns = 2;
M.immune_pars.steps_per_move = 4;

M = simPatient(M);

if isfield(M.save_pars,"sim_identifier")
    fprintf("Finished simulation %s.\n",M.save_pars.sim_identifier)
else
    fprintf("Finished simulation without saving anything.\n")
end
