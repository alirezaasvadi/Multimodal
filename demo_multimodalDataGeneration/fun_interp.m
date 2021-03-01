function [dm, rm, im] = fun_interp(st, frame, interp_method)

%% calibration data
clb = dlmread(sprintf('%06d.txt', frame), ' ', 0, 1); % [read data, delimiter, row offset, column offset]
st.t.p1  = reshape(clb(2, 1 : 12), [4, 3])'; st.t.p1(4, :) = [0 0 0 1];
st.t.p2  = reshape(clb(3, 1 : 12), [4, 3])'; st.t.p2(4, :) = [0 0 0 1];        % load 3x4 P2 camera calibration matrix
st.t.rct = reshape(clb(5, 1 : 9), [3, 3])'; st.t.rct(:, 4) = 0; st.t.rct(4,:) = [0 0 0 1]; % load 3x3 image calibration matrix
st.t.v2c = reshape(clb(6, 1 : 12), [4, 3])'; st.t.v2c(4,:) = [0 0 0 1];                    % load 3x4 velodyne to camera matrix (R|t)
st.t.clb = st.t.p2 * st.t.rct * st.t.v2c;                                                  % project velodyne points to image plane

%% read rgb and velodyne points
im = imread(sprintf('%06d.png', frame)); % load image
fid = fopen(sprintf('%06d.bin', frame), 'rb'); % load velodyne points
velodyne = fread(fid, [4 inf], 'single')'; % velodyne points [x, y, z, r] 
fclose(fid); % close fid
velodyne(velodyne(:, 1) < st.x_min, :) = [];

%% post process: project & filter pcd to the image field of view
pixel         = (st.t.clb * velodyne')';                                          % velodyne points on image plane
pixel(:, 1)   = pixel(:, 1)./pixel(:, 3); pixel(:, 2) = pixel(:, 2)./pixel(:, 3); % point's x & y are cor. to image's c & nr - r (nr: nnumber of raws)
pixel(:, 1:2) = round([pixel(:, 2) pixel(:, 1)]);                                 % correction [r c]
ins           = (pixel(:, 1) >= 1) & (pixel(:, 1) <= size(im, 1)) & ...           % index of pixels inside the image
                (pixel(:, 2) >= 1) & (pixel(:, 2) <= size(im, 2));
pixel         = pixel(ins, :);                                                    % [r c depth reflectance]

%% post process: unique pixel with closest distances
[v, i]     = sort(pixel(:, 3));                               % sort based on depth
A          = [pixel(i, 1:2), v, pixel(i, 4)];                 % sorted px [r c depth reflectance]
[C, ia, ~] = unique(A(:, 1:2), 'rows');                       % unique value (keeps closest points)
pixel      = [C, A(ia, 3), A(ia, 4)];                         % [r c depth reflectance], C = A(ia,:) and A = C(ic,:)

%% sparse maps
l_ind      = sub2ind([size(im, 1), size(im, 2)], pixel(:, 1), pixel(:, 2));    % [r, c] to linear index
dms = zeros(size(im, 1), size(im, 2));                        % depth map
dms(l_ind) = pixel(:, 3);
rms = zeros(size(im, 1), size(im, 2));                        % reflectance map
rms(l_ind) = pixel(:, 4);

%% build indeces for interpolation
[r, c] = size(rms);                                           % build indeces for interpolation
[row, col] = meshgrid(1:r, 1:c); 
ind = sub2ind([r, c], row, col);                              % [r, c] to linear index

%% interpolation reflectance-map 
IFR = scatteredInterpolant(pixel(:, 1), pixel(:, 2), pixel(:, 4), interp_method); % build reflectance interpolation function
reflectance_data = IFR(row, col);                             % compute interpolated indices
rmd = zeros(size(rms));
rmd(ind) = reflectance_data;                                  % dense reflectancemap map

%% interpolation depth-map
IFD = scatteredInterpolant(pixel(:, 1), pixel(:, 2), pixel(:, 3), interp_method);  % build depth interpolation function
depth_data = IFD(row, col);                                   % compute interpolated indices
dmd = zeros(size(dms));
dmd(ind) = depth_data;                                        % dense depth map

%% normalize depth-map
dmn = (st.x_max*(dmd-st.x_min))./(dmd*(st.x_max-st.x_min));   % depth-map encoding: RangeInverse
dmn(dmn < 0) = 0; dmn(dmn > 1) = 1; 

%% mask the result to the ROI
mask   = zeros(size(dms));                                % initialize mask
for i  = 1:c                                              % build the mask
vc     = dms(:, i) ~= 0;
[~, l] = max(vc);
mask(l:end, i) = 1;
end
he     = strel('rectangle', [2, 10]);                     % horizontal extension
mask   = imdilate(mask, he);                              % by Dilation
 
dm  = uint8(mask.*(255*dmn));                             % mask the depth map
rm  = uint8(mask.*(255*rmd));                             % mask the reflectance map

end
