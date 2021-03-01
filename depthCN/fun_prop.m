function proposals = fun_prop(points, pixels, st)

%% Generated object proposals
[proposal_inds, ~] = dbscan(points(:, 1:2), st.epsn, st.mpts); % DBSCAN clustring Eps = 0.6; MinPts = 10;
proposals = zeros(max(proposal_inds(:)), 4);
% for ip = 1 : max(proposal_inds(:))
% pts = pixels(proposal_inds == ip, :); % find each cluster points 
% 
% proposals(ip, :) = [min(pts(:,2)),min(pts(:,1)),max(pts(:,2))-min(pts(:,2)),max(pts(:,1))-min(pts(:,1))];
% end
for ip = 1 : max(proposal_inds(:))
pts = pixels(proposal_inds == ip, :); % find each cluster points    
left   = min(pts(:,2));
right  = max(pts(:,2));
top    = max(min(pts(:,1))-5, 1); 
bottom = max(pts(:,1));
width  = right - left;
height = bottom - top;
proposals(ip, :) = [left, top, width, height];
end

end