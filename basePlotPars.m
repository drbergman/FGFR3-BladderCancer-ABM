function plot_pars = basePlotPars()

%% Plotting properties

plot_pars.plot_fig = false;
plot_pars.plot_location = false; % don't bother plotting where all the cells are. it takes a long time
plot_pars.make_movie = false;
plot_pars.plot_every = 1; % update plots once every this many tumor steps
plot_pars.plot_offset = 0; % modulus from above at which to plot
plot_pars.use_carveout = false; % whether or not to carveout part of the sphere
plot_pars.plot_start = 0 * 1440; % time to start plotting
plot_pars.make_slice_movie = false; % whether or not to make a movie of the mid slice
plot_pars.vid_days_per_second = 1; % simulated days per second of movie time
plot_pars.slice_vid_days_per_second = 1; % simulated days per second of movie time

%% colors
plot_pars.tumor_colors = winter(4); % colors for [LA,HA;LA Mut,HA Mut] but put the type on 1st dim and colors on rows
plot_pars.immune_colors = autumn(2); % colors for [slow-killing,fast-killing]
plot_pars.unengaged_color = [1 1 1];
plot_pars.deactivated_color = [0 0 0];

