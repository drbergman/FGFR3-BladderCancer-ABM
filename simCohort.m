function simCohort(M,cohort_pars)

nsamps_per_condition = cohort_pars.nsamps_per_condition;

% lattice sampling of fields of M
fn = string(fieldnames(M));
cohort.lattice_parameters = struct("path",{},"values",{});
for i = 1:numel(fn)
    if isfield(cohort_pars,"fields_to_ignore_for_grid_and_comparison") && any(fn(i)==cohort_pars.fields_to_ignore_for_grid_and_comparison)
        continue;
    end
    current_struct_path = fn(i);
    cohort.lattice_parameters = grabFields(M.(fn(i)),cohort.lattice_parameters,current_struct_path);
end

cohort.lattice_parameters = cohort_pars.linkingFunction(cohort.lattice_parameters,cohort_pars);

cohort.all_parameters = flattenStruct(M);
all_fn = fieldnames(cohort.all_parameters);

cohort_size = arrayfun(@(i) size(cohort.lattice_parameters(i).values,1),1:numel(cohort.lattice_parameters));
total_sims = prod(cohort_size) * nsamps_per_condition;

colons = repmat({':'},[1,length(cohort_size)]);
vp_ind = cell(1,length(cohort_size));

cohort.ids = repmat("",[cohort_size,nsamps_per_condition,1]); % put the 1 at the end in case cohort_size = []; this way it creates a 1D vector of ids rather than a square array of ids...silly matlab
n_found = 0;


%% check if previous cohorts ran these sims
if isfield(cohort_pars,"previous_cohort_output_pattern")
    previous_cohorts = dir(cohort_pars.previous_cohort_output_pattern);
else
    previous_cohorts = dir("data/cohort_*/output.mat");
end
for i = 1:numel(previous_cohorts)

    PC = load([previous_cohorts(i).folder,'/',previous_cohorts(i).name]);
    if ~isfield(PC,"all_parameters") || ~isequal(sort(string(all_fn)),sort(string(fieldnames(PC.all_parameters))))
        % these did not have the same parameters coming in, so move on
        continue;
    end

    skip_this_cohort = false;
    D = cell(length(cohort_size),length(PC.lattice_parameters)); % tracks which indices in each dim pair should be mapped
    current_fixed = cell(length(cohort_size),1); % the possible indices in each dimension that have been found in current
    previous_fixed = cell(length(PC.lattice_parameters),1); % the possible indices in each dimension that have been found in previous

    for j = 1:numel(all_fn)

        if isfield(cohort_pars,"fields_to_ignore_for_grid_and_comparison") && any(startsWith(all_fn{j},cohort_pars.fields_to_ignore_for_grid_and_comparison))
            continue;
        end

        current_val = cohort.all_parameters.(all_fn{j});
        previous_val = PC.all_parameters.(all_fn{j});
        if size(current_val,1)==1 % then this parameter is not currently being varied, check that at least one of previous used it
            if size(previous_val,1)==1 % then this was also not varied previously
                if ~isequal(current_val,previous_val)
                    skip_this_cohort = true;
                    break;
                end
            else % then need this was varied previously, need to see if the current val matches any of the previous, and then record where those are
                prev_dim = NaN; % clear any value from here
                [used_prev,~] = ismember(current_val,previous_val,"rows");
                if ~used_prev % make sure the current value was one of the previously used
                    skip_this_cohort = true;
                    break;
                end
                for k = 1:numel(PC.lattice_parameters)
                    if iscell(PC.lattice_parameters(k).path) % then this lattice parameter was a combination of parameters
                        lattice_par_found = false;
                        for l = 1:numel(PC.lattice_parameters(k).path)
                            if strcmp(all_fn{j},[PC.lattice_parameters(k).path{l}{1},'_DOT_',PC.lattice_parameters(k).path{l}{2}])
                                prev_dim = k;
                                prev_ind = find(PC.lattice_parameters(k).values(:,l)==current_val);
                                lattice_par_found = true;
                                break;
                            end
                        end
                        if lattice_par_found
                            break; % stop looping through PC lattice parameters
                        end
                    else
                        if strcmp(all_fn{j},[PC.lattice_parameters(k).path{1},'_DOT_',PC.lattice_parameters(k).path{2}])
                            prev_dim = k;
                            prev_ind = find(PC.lattice_parameters(k).values==current_val);
                            break;
                        end
                    end
                end
                [previous_fixed,lost_inds] = updateFixed(previous_fixed,prev_dim,prev_ind);
                if isempty(previous_fixed)
                    break;
                end
                fix_previous_dim = true;
                for k = 1:length(lost_inds)
                    [D,current_fixed,previous_fixed] = scanForDeletions(D,current_fixed,previous_fixed,fix_previous_dim,prev_dim,lost_inds(k));
                end
            end

        else % then this parameter is currently being varied

            current_dim = NaN; % clear any value from here
            if size(previous_val,1)==1 % then this was not varied previously
                [re_use,~] = ismember(previous_val,current_val,"rows");
                if ~re_use % then none of these were used before, move on
                    skip_this_cohort = true;
                    break;
                end
                for k = 1:numel(cohort.lattice_parameters)
                    if iscell(cohort.lattice_parameters(k).path) % then this lattice parameter was a combination of parameters
                        lattice_par_found = false;
                        for l = 1:numel(cohort.lattice_parameters(k).path)
                            if strcmp(all_fn{j},[cohort.lattice_parameters(k).path{l}{1},'_DOT_',cohort.lattice_parameters(k).path{l}{2}])
                                current_dim = k;
                                current_val = cohort.lattice_parameters(k).values(:,l);
                                lattice_par_found = true;
                                break;
                            end
                        end
                        if lattice_par_found
                            break; % stop looping through cohort lattice parameters
                        end
                    else
                        if strcmp(all_fn{j},[cohort.lattice_parameters(k).path{1},'_DOT_',cohort.lattice_parameters(k).path{2}])
                            current_dim = k;
                            current_val = cohort.lattice_parameters(k).values;
                            break;
                        end
                    end
                end
                current_ind = find(all(previous_val==current_val,2));
                [current_fixed,lost_inds] = updateFixed(current_fixed,current_dim,current_ind);
                if isempty(current_fixed)
                    break;
                end
                fix_previous_dim = false;
                for k = 1:length(lost_inds)
                    [D,current_fixed,previous_fixed] = scanForDeletions(D,current_fixed,previous_fixed,fix_previous_dim,current_dim,lost_inds(k));
                end

            else % it was varied previously as well

                prev_dim = NaN; % clear any value from here
                for k = 1:numel(PC.lattice_parameters)
                    if iscell(PC.lattice_parameters(k).path) % then this lattice parameter was a combination of parameters
                        lattice_par_found = false;
                        for l = 1:numel(PC.lattice_parameters(k).path)
                            if strcmp(all_fn{j},[PC.lattice_parameters(k).path{l}{1},'_DOT_',PC.lattice_parameters(k).path{l}{2}])
                                prev_dim = k;
                                previous_val = PC.lattice_parameters(k).values(:,l);
                                lattice_par_found = true;
                                break;
                            end
                        end
                        if lattice_par_found
                            break; % stop looping through PC lattice parameters
                        end
                    else
                        if strcmp(all_fn{j},[PC.lattice_parameters(k).path{1},'_DOT_',PC.lattice_parameters(k).path{2}])
                            prev_dim = k;
                            previous_val = PC.lattice_parameters(k).values;
                            break;
                        end
                    end
                end

                for k = 1:numel(cohort.lattice_parameters)
                    if iscell(cohort.lattice_parameters(k).path) % then this lattice parameter was a combination of parameters
                        lattice_par_found = false;
                        for l = 1:numel(cohort.lattice_parameters(k).path)
                            if strcmp(all_fn{j},[cohort.lattice_parameters(k).path{l}{1},'_DOT_',cohort.lattice_parameters(k).path{l}{2}])
                                current_dim = k;
                                current_val = cohort.lattice_parameters(k).values(:,l);
                                lattice_par_found = true;
                                break;
                            end
                        end
                        if lattice_par_found
                            break; % stop looping through cohort lattice parameters
                        end
                    else
                        if strcmp(all_fn{j},[cohort.lattice_parameters(k).path{1},'_DOT_',cohort.lattice_parameters(k).path{2}])
                            current_dim = k;
                            current_val = cohort.lattice_parameters(k).values;
                            break;
                        end
                    end
                end

                match_found = false;
                current_already_fixed = ~isempty(current_fixed{current_dim});
                previous_already_fixed = ~isempty(previous_fixed{prev_dim});
                already_mapped = ~isempty(D{current_dim,prev_dim});
                if previous_already_fixed
                    prev_iter = reshape(previous_fixed{prev_dim},1,[]); % needs to be a row vector for iterations (who knew!)
                else
                    prev_iter = 1:size(previous_val,1);
                end
                for k = prev_iter
                    [re_use,~] = ismember(previous_val(k,:),current_val,"rows");
                    if re_use
                        current_ind = find(all(previous_val(k,:)==current_val,2));
                        if already_mapped
                            found_this_ind = false(length(current_ind),1); 
                        end
                        for l = 1:length(current_ind)
                            if (~current_already_fixed || ismember(current_ind(l),current_fixed{current_dim})) && (~already_mapped || ismember([current_ind(l),k],D{current_dim,prev_dim},"rows"))
                                match_found = true;
                                if ~already_mapped
                                    D{current_dim,prev_dim}(end+1,:) = [current_ind(l),k];
                                else % it is possible that this previous ind is already mapped to a different current ind, too
                                    found_this_ind(l) = true;
                                end
                                if ~current_already_fixed && ~ismember(current_ind(l),current_fixed{current_dim})
                                    current_fixed{current_dim}(end+1,1) = current_ind(l);
                                end
                                if ~previous_already_fixed && ~ismember(k,previous_fixed{prev_dim})
                                    previous_fixed{prev_dim}(end+1,1) = k;
                                end
                            end
                        end
                        if already_mapped
                            D_ind_with_k = D{current_dim,prev_dim}(:,2) == k;
                            initial_pairs_with_k = D{current_dim,prev_dim}(D_ind_with_k,:);
                            final_pairs_with_k = intersect(initial_pairs_with_k,[current_ind(found_this_ind),repmat(k,[sum(found_this_ind),1])],"rows");
                            if size(final_pairs_with_k,1) < size(initial_pairs_with_k,1) % then we lost some pairings, make updates
                                D{current_dim,prev_dim} = setdiff(D{current_dim,prev_dim},initial_pairs_with_k,"rows"); % just throw them all out
                                D{current_dim,prev_dim} = cat(1,D{current_dim,prev_dim},final_pairs_with_k); % put these back in
                                deleted_current_inds = setdiff(current_fixed{current_dim},D{current_dim,prev_dim}(:,1));
                                if ~isempty(deleted_current_inds) % then we need to scan for further deletions
                                    current_fixed{current_dim} = unique(D{current_dim,prev_dim}(:,1));
                                    fix_previous_dim = false;
                                    for l = 1:length(deleted_current_inds)
                                        [D,current_fixed,previous_fixed] = scanForDeletions(D,current_fixed,previous_fixed,fix_previous_dim,current_dim,deleted_current_inds(l));
                                    end
                                end
                            end
                        end
                    elseif previous_already_fixed % if this ind cannot be found, make sure to remove it from previous_fixed
                        previous_fixed{prev_dim} = setdiff(previous_fixed{prev_dim},k);
                        fix_previous_dim = true;
                        [D,current_fixed,previous_fixed] = scanForDeletions(D,current_fixed,previous_fixed,fix_previous_dim,prev_dim,k);
                    end
                end
                if ~match_found
                    skip_this_cohort = true;
                    break;
                end
            end
        end
    end

    if skip_this_cohort
        continue;
    end

    target_sz = cellfun(@numel,current_fixed);

    target_inds = cell(length(target_sz),1);
    ti = cell(length(target_sz),1);
    for j = 1:prod(target_sz)
        [target_inds{:}] = ind2sub(target_sz,j);
        for k = 1:length(target_sz)
            ti{k} = current_fixed{k}(target_inds{k});
        end
        ci = matchToCopy(ti,D,previous_fixed);
        if isempty(ci)
            continue;
        end
        temp_ids = cohort.ids(ti{:},:);
        blank_log = temp_ids=="";
        n_blank = sum(blank_log);
        if n_blank==0 % then all have been found, move on
            continue;
        end
        new_ids_temp = PC.ids(ci{:},:);
        new_ids_temp = setdiff(new_ids_temp,temp_ids);
        blanks_to_fill = find(blank_log);
        if numel(new_ids_temp) > n_blank
            new_ids_temp = new_ids_temp(randperm(numel(new_ids_temp),n_blank)); % select random ids from before
        elseif numel(new_ids_temp) < n_blank
            blanks_to_fill = blanks_to_fill(1:numel(new_ids_temp));
        end
        temp_ids(blanks_to_fill) = new_ids_temp;
        cohort.ids(ti{:},:) = sort(temp_ids);
        n_found = n_found + numel(blanks_to_fill);
    end

    if n_found == total_sims
        break;
    end

end

inds_to_run = find(cohort.ids=="");
total_runs = numel(inds_to_run);

%% now fill out the rest of the sim array/grab the sim data identified above
cohort_start_time = string(datetime("now","Format","yyMMddHHmm"));
if isfield(cohort_pars,"this_cohort_folder_pattern")
    this_cohort_folder_pattern = cohort_pars.this_cohort_folder_pattern;
else
    this_cohort_folder_pattern = "data/cohort_%s";
end
if ~isfield(cohort_pars,"cohort_identifier")
    cohort_pars.cohort_identifier = cohort_start_time; % default to this for determining an id if none given
    while exist(sprintf(this_cohort_folder_pattern,cohort_pars.cohort_identifier),"dir") % just in case this directory already exists somehow (not sure how to processes could start at the same time to the millisecond and then one create this folder before the other looks for it)
        cohort_pars.cohort_identifier = string(datetime("now","Format","yyMMddHHmmss")); % default to this for determining an id if none given
    end
end

% start timer stuff
cohort_pars.mu_n = 0;
cohort_pars.start = tic;
cohort_pars.batch_start = tic;
cohort_pars.total_runs = total_runs; % set this for calculating time remaining

if total_runs>=cohort_pars.min_parfor_num
    if isempty(gcp('nocreate')) && isfield(cohort_pars,"parpool_options")
        ppool = parpool(cohort_pars.parpool_options.resources);
    else
        ppool = gcp;
    end
    F(1:total_runs) = parallel.FevalFuture;
    cohort_pars.num_workers = ppool.NumWorkers;
    for ri = 1:total_runs % run index
        if mod(ri,round(.1*total_runs))==0
            fprintf("Setting up simulation %d of %d...\n",ri,total_runs)
        end
        [vp_ind{colons{:}},~] = ind2sub([cohort_size,nsamps_per_condition],inds_to_run(ri));
        for vpi = 1:numel(cohort.lattice_parameters)
            M = setField(M,cohort.lattice_parameters(vpi).path,cohort.lattice_parameters(vpi).values(vp_ind{vpi},:));
        end
        M.save_pars.sim_identifier = sprintf("%s_%d",cohort_pars.cohort_identifier,ri);
        F(ri) = parfeval(ppool,cohort_pars.sim_function,1,M);
    end
else
    cohort_pars.num_workers = 1;
end

if ~isfield(cohort_pars,"update_timer_every")
    cohort_pars.update_timer_every = cohort_pars.num_workers;
end
%%

for ri = total_runs:-1:1
    if total_runs>=cohort_pars.min_parfor_num
        [temp,out_temp] = fetchNext(F);
        idx = inds_to_run(temp);
    else
        idx = inds_to_run(ri);
        [vp_ind{colons{:}},~] = ind2sub([cohort_size,nsamps_per_condition],idx);
        for vpi = 1:numel(cohort.lattice_parameters)
            M = setField(M,cohort.lattice_parameters(vpi).path,cohort.lattice_parameters(vpi).values(vp_ind{vpi},:));
        end
        M.save_pars.sim_identifier = sprintf("%s_%d",cohort_pars.cohort_identifier,ri);
        out_temp = cohort_pars.sim_function(M);
    end
    cohort_pars = updateCohortTimer(cohort_pars,total_runs-ri+1);
    if isfield(out_temp.save_pars,"sim_identifier")
        cohort.ids(idx) = out_temp.save_pars.sim_identifier;
    else
        error("No sim identifier generated.")
    end
    close all
end

this_cohort_folder = sprintf(this_cohort_folder_pattern,cohort_pars.cohort_identifier);
mkdir(this_cohort_folder)

save(sprintf("%s/output",this_cohort_folder),"nsamps_per_condition","total_sims","cohort_size")
save(sprintf("%s/output",this_cohort_folder),'-struct',"cohort","-append")

fprintf("Finished cohort with a total run time of %s.\nFolder is: %s\n",duration(0,0,toc(cohort_pars.start)),this_cohort_folder)

if isfield(cohort_pars,"check_cohort_grab") && cohort_pars.check_cohort_grab && total_sims > cohort_pars.total_runs
    checkCohortGrab(cohort_pars.cohort_identifier)
end

end

function lattice_parameters = grabFields(S,lattice_parameters,incoming_struct_path)

fn = string(fieldnames(S));
for i = 1:numel(fn)
    current_struct_path = [incoming_struct_path,fn(i)];
    if isstruct(S.(fn(i)))
        lattice_parameters = grabFields(S.(fn(i)),lattice_parameters,current_struct_path);
    elseif size(S.(fn(i)),1)>1 % then vary over these parameters
        lattice_parameters(end+1) = struct("path",current_struct_path,"values",S.(fn(i)));
    end
end

end

function [fixed,lost_inds] = updateFixed(fixed,dim,ind)

if isempty(fixed{dim})
    fixed{dim} = ind;
    lost_inds = [];
else
    lost_inds = fixed{dim};
    fixed{dim} = intersect(fixed{dim},ind);
    lost_inds = setdiff(lost_inds,fixed{dim});
end
end

function copy_inds = matchToCopy(ti,D,previous_fixed)

n = length(previous_fixed);
copy_inds = cell(n,1);
for k = 1:n
    if numel(previous_fixed{k})==1
        copy_inds{k} = previous_fixed{k}; % only one to grab here, so just grab it
    else
        ind = NaN;
        for ri = 1:size(D,1) % loop over target dims to find the ones that match with dim k in previous
            if ~isempty(D{ri,k})
                if isnan(ind)
                    ind = D{ri,k}((D{ri,k}(:,1)==ti{ri}),2);
                    assert(numel(ind)==1) % should only find a single match here
                elseif ~isequal(ind,D{ri,k}((D{ri,k}(:,1)==ti{ri}),2)) % should match the previous index found; skip this one
                    copy_inds = [];
                    return;
                end
            end
        end
        if isnan(ind) % could not find the proper previous indices to match the target indices; I don't think this should ever happen
            error("No index found???")
        end
        copy_inds{k} = ind;
    end
end
end

function [D_full,current_fixed,previous_fixed] = scanForDeletions(D_full,current_fixed,previous_fixed,fix_previous,dim,I)

if fix_previous
    D = D_full(:,dim);
    col_ind = 2;
    other_ind = 1;
else
    D = D_full(dim,:);
    col_ind = 1;
    other_ind = 2;
end

for i = 1:length(D) % find where it was previously matched and remove those
    if ~isempty(D{i})
        ind = D{i}(:,col_ind) == I;
        if ~any(ind)
            continue;
        end
        other_to_remove = D{i}(ind,other_ind);
        if fix_previous
            D_full{i,dim}(ind,:) = [];
            other_to_remove = setdiff(other_to_remove,D_full{i,dim}(:,other_ind));
            if isempty(other_to_remove)
                continue;
            end
            current_fixed{i} = setdiff(current_fixed{i},other_to_remove);
            fix_previous_dim = false;
            [D_full,current_fixed,previous_fixed] = scanForDeletions(D_full,current_fixed,previous_fixed,fix_previous_dim,i,other_to_remove);
        else
            D_full{dim,i}(ind,:) = [];
            other_to_remove = setdiff(other_to_remove,D_full{dim,i}(:,other_ind));
            if isempty(other_to_remove)
                continue;
            end
            previous_fixed{i} = setdiff(previous_fixed{i},other_to_remove);
            fix_previous_dim = true;
            [D_full,current_fixed,previous_fixed] = scanForDeletions(D_full,current_fixed,previous_fixed,fix_previous_dim,i,other_to_remove);
        end
    end
end


end
