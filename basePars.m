function pars = basePars()

pars.max_dt = 540; % number of minutes per step
pars.max_dt_Imm = 10; % number of minutes per immune step

pars.cell_width = 20; % in micrometers; cell is about 20micrometers in diameter
pars.min_prolif_wait = 540; % number of minutes all cells must wait at minimum between proliferations
pars.max_tumor_size = Inf; % if tumor exceeds this, stop simulation

%% neighbor parameters
pars.occmax = 20; % below this threshold, a tumor/immune cell can divide; at and above, too many neighbors and so doesn't proliferate

%% tumor parameters

pars.prolif_rate = (1.5/(1-1.5*9/24)) / 1440; % proliferation rate of tumor cells (per min)
pars.apop_rate = .05 / 1440; % max death rate of tumor cells (per day)
