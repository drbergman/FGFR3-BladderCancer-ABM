function M = updateTracked(M)

M.tracked.t(M.i) = M.t;

M.tracked.NT(M.i) = M.NT;
M.tracked.tumor_types(M.i,:,:) = sum(M.mut_log==[0,1] & M.ha_log==reshape([0,1],1,1,2),1); % [time,mutation status (WT, Mut),antigenicity (LA, HA)]

M.tracked.NI(M.i) = M.NI;

M.tracked.tum_num_targeting(M.i,:) = histcounts(M.tumors(:,M.I.tumor_num_targeting),[0:3,Inf]); % count number of tumor cells being targeted by [0,1,2,3+] immune cells

if M.save_pars.track_drug_concentrations
    M.tracked.fgfr3_region_concentrations(M.i,:) = M.fgfr3.concentration;
    M.tracked.fgfr3_circulation_concentration(M.i) = M.fgfr3.circ;
    M.tracked.apd1_region_concentrations(M.i,:) = M.checkpoint.aPD1;
    M.tracked.apd1_circulation_concentration(M.i) = M.checkpoint.aPD1_circulation;
end