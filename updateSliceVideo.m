function M = updateSliceVideo(M)


if ~isfield(M,"slice_fig")
    M.slice_fig.handle = figure;
    M.slice_fig.ax = gca;
    M.slice_fig.ax.Colormap = M.fig.ax(M.fig.cell_slice_ind).Colormap;
    axis square
    M.slice_fig.ax.XLim = [1,M.grid.size(1)];
    M.slice_fig.ax.YLim = [1,M.grid.size(2)];
else
    delete(M.slice_fig.ax.Children)
end
copyobj(M.fig.cell_slice_plot,M.slice_fig.ax);
time_vec = this_timeVec(M.t);
title(M.slice_fig.ax,sprintf("t = %02d days, %02d hours, %02d minutes",time_vec(1),time_vec(2),time_vec(3)))
writeVideo(M.slice_vid,getframe(M.slice_fig.handle))

end

function tv = this_timeVec(t)
tv = zeros(3,1);
tv(1) = floor(t/1440); % day
tv(2) = floor(t/60-24*tv(1)); % hour
tv(3) = floor(t - 60*tv(2) - 1440*tv(1)); % minute
end