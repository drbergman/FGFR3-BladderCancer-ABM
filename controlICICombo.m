function LP = controlICICombo(LP,~)

% set up a cohort to only test these 3 therapy regimens (no anti-FGFR3 monotherapy)

% non-lattice parameter varying (for dosing schedule, rectangle sizes...and others?)
drug = string([]);
dose_start_inds = [];
vals = {};
paths = {};
for i = 1:numel(LP)
    if LP(i).path(end)=="start_day"
        drug(end+1) = LP(i).path(1);
        dose_start_inds(end+1) = i;
        vals{end+1} = LP(i).values;
        paths{end+1} = LP(i).path;
    end
end
if length(dose_start_inds)>1 % only make this change if two dose start times are varying
    LP(end+1).values = allCombos(vals{:},'matlab');
    LP(end).path = paths;
    fgfr3_col = drug=="fgfr3";
    row_to_delete = LP(end).values(:,~fgfr3_col)==Inf & LP(end).values(:,fgfr3_col)~=Inf;
    LP(end).values(row_to_delete,:) = [];
    LP(dose_start_inds) = [];
end
