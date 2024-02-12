function neighbor_inds = getNeighbors_VN_OffToCenter(M,ind,subs)

% neighbors that are off the grid get replaced with the center ind

neighbor_inds = ind'+M.rel_pos_ind_VN;

cells_on_left = subs(:,1)==1;
neighbor_inds(M.pars.left_neighbors_VN_ind,cells_on_left) = ind(cells_on_left);
cells_on_right = subs(:,1)==M.grid.size(1);
neighbor_inds(M.pars.right_neighbors_VN_ind,cells_on_right) = ind(cells_on_right);
cells_on_front = subs(:,2)==1;
neighbor_inds(M.pars.front_neighbors_VN_ind,cells_on_front) = ind(cells_on_front);
cells_on_back = subs(:,2)==M.grid.size(2);
neighbor_inds(M.pars.back_neighbors_VN_ind,cells_on_back) = ind(cells_on_back);
cells_on_bottom = subs(:,3)==1;
neighbor_inds(M.pars.bottom_neighbors_VN_ind,cells_on_bottom) = ind(cells_on_bottom);
cells_on_top = subs(:,3)==M.grid.size(3);
neighbor_inds(M.pars.top_neighbors_VN_ind,cells_on_top) = ind(cells_on_top);
