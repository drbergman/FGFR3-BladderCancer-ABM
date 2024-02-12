function LP = lastDoseIsNoDose(LP,cohort_pars)

% non-lattice parameter varying (for dosing schedule, rectangle sizes...and others?)
if cohort_pars.last_dose_is_no_dose
    dose_start_inds = [];
    vals = {};
    paths = {};
    for i = 1:numel(LP)
        if LP(i).path(end)=="start_day"
            dose_start_inds(end+1) = i;
            vals{end+1} = LP(i).values;
            paths{end+1} = LP(i).path;
        end
    end
    if length(dose_start_inds)>1 % only make this change if two dose start times are varying
        LP(end+1).values = allCombos(vals{:},'matlab');
        LP(end).values(end,:) = Inf;
        LP(end).path = paths;
        LP(dose_start_inds) = [];
    end
end