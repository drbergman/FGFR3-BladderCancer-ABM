function M = simForward(M)

if M.Nsteps == 0 || isempty(M.tumors) % nothing to simulate here
    return;
end

%% prepare new tracked values
names = fieldnames(M.tracked);
for i = 1:length(names)
    M.tracked.(names{i}) = cat(1,M.tracked.(names{i}),...
        zeros([M.Nsteps,size(M.tracked.(names{i}),2:ndims(M.tracked.(names{i})))]));
end

%% iterations
for i = 1:M.Nsteps

    if M.NT > M.pars.max_tumor_size
        names = fieldnames(M.tracked);
        for ni = 1:length(names)
            colons = repmat({':'},1,ndims(M.tracked.(names{ni}))-1);
            M.tracked.(names{ni})(M.i+1:end,colons{:}) = NaN;
        end
        break
    end

    M.t = M.t + M.dt;
    M.i = M.i+1;

    M = updateFGFR3(M);

    M = updateTumor(M);

    M = updateImmune(M);

    %% clean up tumor stuff
    M = removeApoptotic(M);

    %% advance tumor proliferation timers
    M.tumors(:,M.I.proliferation_timer) = max(0,M.tumors(:,M.I.proliferation_timer)-M.dt); % update time until tumor cells can proliferate for all that did not proliferate (1) or were just created (0) because those timers were updated in updateTumor

    %% recruit immune cells
    M = recruitImmune(M);

    %% update these vals
    M.NT = size(M.tumors,1);
    M.mut_log = M.tumors(:,M.I.tumor_mut)==1;
    M.ha_log = M.tumors(:,M.I.type)==1;
    M.NI = size(M.immunes,1);

    %% update tracked values
    M = updateTracked(M);

    %% plot
    if M.plot_pars.plot_fig && M.t > M.plot_pars.plot_start && mod(M.i,M.plot_pars.plot_every)==M.plot_pars.plot_offset
        plotFunction_EndStep(M)

        %% movie
        if M.plot_pars.make_movie
            M = updateVideo(M);
        end

        %% slice movie
        if M.plot_pars.make_slice_movie
            M = updateSliceVideo(M);
        end
    end

    %% save any "big" data
    if M.t >= M.next_save_time - 0.5 * M.dt % then it appears that this is the closest time to the desired save time
        M = saveModelData(M);
    end

end %%end of for
