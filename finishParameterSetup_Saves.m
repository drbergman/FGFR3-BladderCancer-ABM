function M = finishParameterSetup_Saves(M)

M.next_save_time = 0;
M.save_index = 0;

if ~isfield(M.save_pars,"sim_identifier")
    M.save_pars.sim_identifier = setIdentifier("data/sims");
end


mkdir(sprintf("data/sims/%s",M.save_pars.sim_identifier))

max_grid_sub = max(M.grid.size);
max_grid_sub_log2 = ceil(log2(max_grid_sub+1));
if max_grid_sub_log2 <= 8
    M.save_pars.integrify = @uint8;
elseif max_grid_sub_log2 <= 16
    M.save_pars.integrify = @uint16;
elseif max_grid_sub_log2 <= 32
    M.save_pars.integrify = @uint32;
elseif max_grid_sub_log2 <= 64
    M.save_pars.integrify = @uint64;
else
    error("grid too large to store!")
end
