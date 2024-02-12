function M = initializeFGFR3(M)

M.fgfr3.circ = 0;

M = initializeSubstrateRegions(M,"fgfr3");

M.fgfr3.concentration = zeros(M.fgfr3.n_regions,1);
