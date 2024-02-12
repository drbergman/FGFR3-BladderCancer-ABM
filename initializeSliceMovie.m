function M = initializeSliceMovie(M)

if ~isfield(M.save_pars,"sim_identifier")
    M.save_pars.sim_identifier = setSimIdentifier("data/sims");
    mkdir(sprintf("data/sims/%s",M.save_pars.sim_identifier))
end

if ~exist(sprintf("data/sims/%s/movie",M.save_pars.sim_identifier),"dir")
    mkdir(sprintf("data/sims/%s/movie",M.save_pars.sim_identifier))
end

M.slice_vid = VideoWriter(sprintf("data/sims/%s/movie/slice_vid.mp4",M.save_pars.sim_identifier),'MPEG-4');
M.slice_vid.FrameRate = 1440 * M.plot_pars.slice_vid_days_per_second/(M.pars.max_dt*M.plot_pars.plot_every); % sim_min/sim_day * sim_days/sec / (sim_min/frame) = frame/sec
open(M.slice_vid)