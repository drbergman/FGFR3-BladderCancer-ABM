function M = recruitImmune(M)

if M.flags.fgfr3_affects_immune_recruit
    rate = M.dt*M.immune_pars.immune_recruit_rate*M.NT*(M.immune_pars.min_imm_recruit_prop+(1-M.immune_pars.min_imm_recruit_prop)/(1+mean(M.phiD)/M.immune_pars.min_imm_recruit_prop_ec50));
else
    rate = M.dt*M.immune_pars.immune_recruit_rate*M.NT;
end
n_newI = poissrnd(rate);
if n_newI>0
    M = placeImmune(M,n_newI);
end
