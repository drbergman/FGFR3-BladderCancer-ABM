function M = saveFinalModelData(M)

load(sprintf("data/sims/%s/output_%08d.mat",M.save_pars.sim_identifier,M.save_index-1),"time");
if M.t>time % make new save
    M = saveModelData(M);
end

tracked = M.tracked;
save(sprintf("data/sims/%s/output_final",M.save_pars.sim_identifier),"tracked",'-v7.3')