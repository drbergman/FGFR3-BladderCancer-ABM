function LP = staggeredDosing(LP,cohort_pars)

% this will produce dosing schedules identical to what we did with the ODE modeling paper
%% remove dose start days and n_doses from lattice parameters

for i = numel(LP):-1:1
    if LP(i).path(end)=="start_day" || LP(i).path(end)=="n_doses"
        LP(i) = [];
    end
end

%% setup monotherapies and both staggered therapies
paths = {["fgfr3","start_day"],["fgfr3","n_doses"],["checkpoint","start_day"],["checkpoint","n_doses"]};
values = [6,15,Inf,0;...
          Inf,0,6,6;...
          6,10,13,4;...
          13,10,6,4];

if ~isfield(cohort_pars,"include_control") || cohort_pars.include_control
    values = [Inf,10,Inf,4;values];
end

LP(end+1).path = paths;
LP(end).values = values;
