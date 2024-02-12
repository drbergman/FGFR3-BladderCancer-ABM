function drug = initializeDosingSchedule(drug,start_day_of_week,censor_time)

drug.dose_index = 1; % indexes which dose is given next
days = drug.start_day + drug.days_between*(0:drug.n_doses-1)'; % days on which the dose is given

weekend_dose_ind = find(mod(start_day_of_week + days,7) >= 5,1); % earliest therapy scheduled for a weekend

while ~isempty(weekend_dose_ind)
    change = mod(-start_day_of_week-days(weekend_dose_ind,1),7); % 1 or 2 
    days(weekend_dose_ind:end) = days(weekend_dose_ind:end) + change;
    
    weekend_dose_ind = find(mod(start_day_of_week + days,7) >= 5,1); % earliest therapy scheduled for a weekend
end

drug.dose_vals = drug.dose_val * ones(drug.n_doses,1);

%% remove doses after censor date
delete_ind = days * 1440 >= censor_time;
days(delete_ind,:) = [];
drug.times = days * 1440; % record drug dose times in minutes
drug.dose_vals(delete_ind,:) = [];