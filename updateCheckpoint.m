function M = updateCheckpoint(M)

ic = [M.checkpoint.PD1;... % col 1
      M.checkpoint.aPD1;... % col 2
      M.checkpoint.PD1aPD1]; % col 3
ic = [ic(:);M.checkpoint.aPD1_circulation];

assert(all(ic>=0))

M.checkpoint.pd1_proportion = M.checkpoint.volumes.pd1./M.checkpoint.volumes.regions;

sol = ode15s(@(t,x) globalCheckpointODE(x,M),[0,M.dt_Imm],ic(:));
Y = sol.y(:,end);

assert(all(Y>=0,'all'))

M.checkpoint.aPD1_circulation = Y(end);

Y = reshape(Y(1:end-1),M.checkpoint.sz);

M.checkpoint.PD1 = Y(:,1);
M.checkpoint.aPD1 = Y(:,2);
M.checkpoint.PD1aPD1 = Y(:,3);

M.pd1_pdl1_equilibrium = 0.5*((M.checkpoint.PD1+M.checkpoint.pdl1_on_tumor) + ...
    M.checkpoint.Kd_pd1_pdl1 - ...
    sqrt((M.checkpoint.PD1+M.checkpoint.pdl1_on_tumor+M.checkpoint.Kd_pd1_pdl1).^2-4*M.checkpoint.PD1*M.checkpoint.pdl1_on_tumor));
