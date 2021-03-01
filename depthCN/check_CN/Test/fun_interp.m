function [depth_map, im] = fun_interp(st, frame)

%% Load data

% calibration data
clb = dlmread(sprintf('%s/%06d.txt', st.dr.clb, frame), ' ', 0, 1); % [read data, delimiter, row offset, column offset]
st.t.p1    = reshape(clb(st.dr.cam, 1 : 12), [4, 3])'; st.t.p1(4, :) = [0 0 0 1];
st.t.p2    = reshape(clb(st.dr.cam + 1, 1 : 12), [4, 3])'; st.t.p2(4, :) = [0 0 0 1];        % load 3x4 P2 camera calibration matrix
st.t.rct   = reshape(clb(5, 1 : 9), [3, 3])'; st.t.rct(:, 4) = 0; st.t.rct(4,:) = [0 0 0 1]; % load 3x3 image calibration matrix
st.t.v2c   = reshape(clb(6, 1 : 12), [4, 3])'; st.t.v2c(4,:) = [0 0 0 1];                    % load 3x4 velodyne to camera matrix (R|t)
st.t.clb   = st.t.p2 * st.t.rct * st.t.v2c;                                                  % project velodyne points to image plane

% read rgb and velodyne points
im = imread(sprintf('%s/%06d.png', st.dr.img, frame)); % load image
fid = fopen(sprintf('%s/%06d.bin', st.dr.pts, frame), 'rb'); % load velodyne points
velodyne = fread(fid, [4 inf], 'single')'; % velodyne points [x, y, z, r] 
fclose(fid); % close fid
velodyne(velodyne(:, 1) < st.x_min, :) = [];

% incorporate image data
pixel           = (st.t.clb * velodyne')';                                          % velodyne points on image plane
pixel(:, 1)     = pixel(:, 1)./pixel(:, 3); pixel(:, 2) = pixel(:, 2)./pixel(:, 3); % point's x & y are cor. to image's c & nr - r (nr: nnumber of raws)
pixel(:, 1:2)   = round([pixel(:, 2) pixel(:, 1)]);                                 % correction [r c]
ins             = (pixel(:, 1) >= 1) & (pixel(:, 1) <= size(im, 1)) & ...           % index of pixels inside the image
                  (pixel(:, 2) >= 1) & (pixel(:, 2) <= size(im, 2));
pixel           = pixel(ins, 1:3);                                                  % [r c depth reflectance]
linearind       = sub2ind([size(im, 1), size(im, 2)], pixel(:, 1), pixel(:, 2));    % [r, c] to linear index
sparse_depthmap = zeros(size(im, 1), size(im, 2));                                  % depth map
sparse_depthmap(linearind) = pixel(:, 3);

%% Interpolation: linear
% unique pixel with closest distances
[v, i]     = sort(pixel(:, 3));                               % sort based on depth
A          = [pixel(i, 1:2) v];                               % sorted px [r c depth]
[C, ia, ~] = unique(A(:, 1:2), 'rows');                       % unique value (keeps closest points)
pixel      = [C, A(ia, 3)];                                   % C = A(ia,:) and A = C(ic,:)

% interpolation, mtd: 'linear' 'nearest' 'natural'
InterpFun  = scatteredInterpolant(pixel(:, 1), pixel(:, 2), pixel(:, 3), 'nearest');  % build interpolation function
[r, c]     = size(sparse_depthmap);                           % build indeces for interpolation
[row, col] = meshgrid(1:r, 1:c);                              % ... continue
data       = InterpFun(row, col);                             % compute interpolated indices
ind        = sub2ind([r, c], row, col);                       % [r, c] to linear index
dense_depthmap = zeros(size(sparse_depthmap));
dense_depthmap(ind) = data;                                   % dense depth map

% depth-map encoding: RangeInverse
depth_norm = (st.x_max*(dense_depthmap-st.x_min))./(dense_depthmap*(st.x_max-st.x_min));
depth_norm = (depth_norm >= 0) .* (depth_norm <= 1) .* depth_norm;

% mask the result to the ROI
mask       = zeros(size(sparse_depthmap));                    % initialize mask
for i      = 1:c                                              % build the mask
vc         = sparse_depthmap(:, i) ~= 0;
[~, lo]    = max(vc);
mask(lo:end, i) = 1;
end
he         = strel('rectangle', [2, 8]);                      % horizontal extension
mask       = imdilate(mask, he);                              % by Dilation
depth_map  = uint8((255 * depth_norm) .* mask);               % mask the depth map

end
