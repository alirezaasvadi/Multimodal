function no_true_fi = fun_cmp(proposals, gt_labels, no_true_fi, bb_overlap_tr)

%% Evaluate Object Proposals
for ie = 1:size(gt_labels, 1) 
    
eval_tr = zeros(size(proposals, 1), 1);

%% compare each of the ground-truth proposal with each of generated proposals
for je = 1:size(proposals, 1)

%% compute overlap    
xbb_gt = [gt_labels(ie, 1), gt_labels(ie, 1), gt_labels(ie, 1) + gt_labels(ie, 3), gt_labels(ie, 1) + gt_labels(ie, 3), gt_labels(ie, 1)];
ybb_gt = [gt_labels(ie, 2), gt_labels(ie, 2) + gt_labels(ie, 4), gt_labels(ie, 2) + gt_labels(ie, 4), gt_labels(ie, 2), gt_labels(ie, 2)];    
xbb = [proposals(je, 1), proposals(je, 1), proposals(je, 1) + proposals(je, 3), proposals(je, 1) + proposals(je, 3), proposals(je, 1)];
ybb = [proposals(je, 2), proposals(je, 2) + proposals(je, 4), proposals(je, 2) + proposals(je, 4), proposals(je, 2), proposals(je, 2)];
[x_un, y_un] = polybool('union', xbb, ybb, xbb_gt, ybb_gt); % get union and overlapping area    
[x_in, y_in] = polybool('intersection', xbb, ybb, xbb_gt, ybb_gt);
union_area = polyarea(x_un', y_un');
isect_area = polyarea(x_in', y_in');
bb_overlap = (isect_area / union_area); % compute overlap

%% increment locally
if bb_overlap >= bb_overlap_tr 
    eval_tr(je) = 1; % considered threshold of 70% for good result
else
    eval_tr(je) = 0; 
end

end

%% increment globally
if sum(eval_tr ~= 0) ~= 0
    no_true_fi = no_true_fi + 1; % add up
end

end

end

