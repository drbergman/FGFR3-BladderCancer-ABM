function setup = baseSetup()

setup.start_day_of_week = -1; % start on Sunday (0 = Monday, 1 = Tuesday, etc.)

setup.grid_size_microns_x = 400;
setup.grid_size_microns_y = 400;
setup.grid_size_microns_z = 400;

setup.censor_time = 25 * 1440;
setup.N0 = 5000;
setup.NI0 = 0;

setup.c = -3.603357085551339;
setup.e = 2.986939791722032;

setup.prop_ha0 = .5; % initial proportion HA
setup.prop_mut0 = 0.5; % initial proportion with FGFR3 mutation

%% blood vessels
setup.blood_vessel_locations = "outside";