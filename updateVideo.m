function M = updateVideo(M)


if ~isfield(M,"fig")
    error("No fig generated but make_movie is called???")
end
time_vec = this_timeVec(M.t);
title(M.fig.ax(M.fig.scatter_ind),sprintf("t = %02d days, %02d hours, %02d minutes",time_vec(1),time_vec(2),time_vec(3)))
writeVideo(M.vid,print(M.fig.handle,'-r100','-RGBImage'))

end

function tv = this_timeVec(t)
tv = zeros(3,1);
tv(1) = floor(t/1440); % day
tv(2) = floor(t/60-24*tv(1)); % hour
tv(3) = floor(t - 60*tv(2) - 1440*tv(1)); % minute
end