function [depth_map, image, points, pixels, lbl] = fun_load(st, frame)
% [depth_map, obstacle_points] = fun_load(st, frame)

%% Load and read data (depth_map, image, points and ground-truth data)

%% read rgb, depth and velodyne points
% data.dmap = imread(sprintf('%s/%06d.png', st.dr.depth, frame)); % load depth map 
[depth_map, ~] = fun_interp(st, frame);
data.dmap = depth_map;
data.im = imread(sprintf('%s/%06d.png', st.dr.img, frame)); % load image
fid = fopen(sprintf('%s/%06d.bin', st.dr.pts, frame), 'rb'); % load velodyne points
data.pt = fread(fid, [4 inf], 'single')'; fclose(fid); % velodyne points [x, y, z, r] 

%% calibration data
clb = dlmread(sprintf('%s/%06d.txt', st.dr.clb, frame), ' ', 0, 1); % [read data, delimiter, row offset, column offset]
st.t.p1    = reshape(clb(st.dr.cam, 1 : 12), [4, 3])'; st.t.p1(4, :) = [0 0 0 1];
st.t.p2    = reshape(clb(st.dr.cam + 1, 1 : 12), [4, 3])'; st.t.p2(4, :) = [0 0 0 1];        % load 3x4 P2 camera calibration matrix
st.t.rct   = reshape(clb(5, 1 : 9), [3, 3])'; st.t.rct(:, 4) = 0; st.t.rct(4,:) = [0 0 0 1]; % load 3x3 image calibration matrix
st.t.v2c   = reshape(clb(6, 1 : 12), [4, 3])'; st.t.v2c(4,:) = [0 0 0 1];                    % load 3x4 velodyne to camera matrix (R|t)
st.t.clb   = st.t.p2 * st.t.rct * st.t.v2c;                                                  % project velodyne points to image plane

%% obstacle points
% Remove points outside x-y local grid
data.pt((data.pt(:, 1) < st.x_min) | (data.pt(:, 1) > st.x_max), :) = [];
data.pt((data.pt(:, 2) < st.y_min) | (data.pt(:, 2) > st.y_max), :) = [];

% Outlier detection: Gaussian distribution
[mu, sigma] = estimateGaussian(data.pt(:, 1:3)); % estimate mu and sigma
p = multivariateGaussian(data.pt(:, 1:3), mu, sigma); % the density of the multivariate normal at each data point
data.pt(p <= eps, :) = []; % find the inliers/outliers

% Grid-based ground removal
q_xy = st.vx*floor(data.pt(:, 1:2)/st.vx); % quantize 
i_xy = ceil([q_xy(:, 1) - st.x_min, q_xy(:, 2) - st.y_min] / st.vx + 1); % integer
grd_xy = accumarray(i_xy(:, 1:2), data.pt(:, 3), [], @var); % variance grid
data.pt(grd_xy(sub2ind(max(i_xy), i_xy(:, 1), i_xy(:, 2))) < st.var_tr, :) = [];

%% Project point-cloud to image
% incorporate image data
pixel           = (st.t.clb * data.pt')';                                      % velodyne points on image plane
pixel(:, 1)     = pixel(:, 1)./pixel(:, 3); pixel(:, 2) = pixel(:, 2)./pixel(:, 3); % point's x & y are cor. to image's c & nr - r (nr: nnumber of raws)
pixel(:, 1:2)   = round([pixel(:, 2) pixel(:, 1)]);                                 % correction [r c]
ins             = (pixel(:, 1) >= 1) & (pixel(:, 1) <= size(data.im, 1)) & ...      % index of pixels inside the image
                  (pixel(:, 2) >= 1) & (pixel(:, 2) <= size(data.im, 2));
data.pt         = data.pt(ins, :);                                             % velodyne points in the image
data.px         = pixel(ins, 1:3);                                                             % [r c depth]
ind             = sub2ind([size(data.im, 1), size(data.im, 2)], data.px(:, 1), data.px(:, 2)); % [r, c] to linear index
data.dm         = zeros(size(data.im, 1), size(data.im, 2));                                   % depth map
data.dm(ind)    = data.px(:, 3);

%% read label
fid         = fopen(sprintf('%s/%06d.txt', st.dr.lbl, frame)); % read raw calibration text
lbl_txt     = textscan(fid,'%s %f %d %f %f %f %f %f %f %f %f %f %f %f %f','delimiter', ' '); % parse input file
lbl_txt     = lbl_txt{1};  
fclose(fid);                        
% extract 2D-BB
lbl_dgt     = dlmread(sprintf('%s/%06d.txt', st.dr.lbl, frame), ' ', 0, 1); % load calibration text (digit)
lbl         = zeros(size(lbl_dgt, 1), 5); 
                                           % object type: 'Car', 'Van', 'Truck', 'Pedestrian', ...
for i       = 1 : size(lbl_dgt, 1)         % 'Person_sitting', 'Cyclist', 'Tram', 'Misc' or 'DontCare' 
bb          = lbl_dgt(i, 4:7);             % left, top, right, bottom pixel coordinates 
lbl(i, 1:4) = [bb(1), bb(2), bb(3) - bb(1), bb(4) - bb(2)];
% lbl(i, 1:4) = [bb(1), bb(2), bb(3), bb(4)];
if strcmp(lbl_txt{i},     'Pedestrian')
lbl(i, 5)   = 1; 
elseif strcmp(lbl_txt{i}, 'Car')
lbl(i, 5)   = 2; 
elseif strcmp(lbl_txt{i}, 'Cyclist')
lbl(i, 5)   = 3; 
elseif strcmp(lbl_txt{i}, 'Van')
lbl(i, 5)   = 4; 
elseif strcmp(lbl_txt{i}, 'Truck')
lbl(i, 5)   = 5; 
elseif strcmp(lbl_txt{i}, 'Person_sitting')
lbl(i, 5)   = 6; 
elseif strcmp(lbl_txt{i}, 'Tram')
lbl(i, 5)   = 7; 
elseif strcmp(lbl_txt{i}, 'Misc')
lbl(i, 5)   = 8; 
elseif strcmp(lbl_txt{i}, 'DontCare')
lbl(i, 5)   = 9; 
end
end
% post-process
lbl(lbl(:, 1:4) < 1) = 1;
lbl(lbl(:, 5) ~= 2, :) = []; % keep only car label info

%% outputs
depth_map = data.dmap;
image = data.im;
pixels = data.px;
points = data.pt;

end