function [no_true_fi] = fun_eval(training_index, p, st)

bb_overlap_tr = 0.7; % threshold 70% overlap 
no_true_fi = 0; % # of correct proposals
for ind = training_index
%% Load and read data (depth_map, image, points and ground-truth data)
[~, ~, points, pixels, gt_labels] = fun_load(st, p(ind) - 1); % labels: [left,top, width, height]
%% Generated object proposals using DBSCAN
proposals = fun_prop(points, pixels, st);
%% Evaluate Object Proposals
no_true_fi = fun_cmp(proposals, gt_labels, no_true_fi, bb_overlap_tr);
end

end