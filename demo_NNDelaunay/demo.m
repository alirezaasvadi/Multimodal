%% Delaunay Triangulation
% 
% 

%% clear memory & command window
clc
clear 
close all

%% directories
% st.dr.clb = ''; % directory of calibration
% st.dr.pts = ''; % directory of velodyne points
% st.dr.img = ''; % directory of color images

%% setting
st.bias  = 1.73;    % velodyne elevation
st.x_min = 5;       % movement direction 5
st.x_max = 80;
st.y_min = -80; % right
st.y_max = 80;  % left
st.bias = 1.73; % velodyne elevation 

%% frame # 
frame = 1468;

%% load pcd 
fid = fopen(sprintf('%06d.bin', frame), 'rb'); % load velodyne points
velodyne = fread(fid, [4 inf], 'single')'; % velodyne points [x, y, z, r] 
fclose(fid); 
velodyne(velodyne(:, 1) < st.x_min, :) = [];

%% calibration data
clb = dlmread(sprintf('%06d.txt', frame), ' ', 0, 1); % [read data, delimiter, row offset, column offset]
st.t.p1    = reshape(clb(2, 1 : 12), [4, 3])'; st.t.p1(4, :) = [0 0 0 1];
st.t.p2    = reshape(clb(2 + 1, 1 : 12), [4, 3])'; st.t.p2(4, :) = [0 0 0 1];        % load 3x4 P2 camera calibration matrix
st.t.rct   = reshape(clb(5, 1 : 9), [3, 3])'; st.t.rct(:, 4) = 0; st.t.rct(4,:) = [0 0 0 1]; % load 3x3 image calibration matrix
st.t.v2c   = reshape(clb(6, 1 : 12), [4, 3])'; st.t.v2c(4,:) = [0 0 0 1];                    % load 3x4 velodyne to camera matrix (R|t)
st.t.clb   = st.t.p2 * st.t.rct * st.t.v2c;                                                  % project velodyne points to image plane

%% pcd in image
pixel           = (st.t.clb * velodyne')';                                           % velodyne points on image plane
pixel(:, 1)     = pixel(:, 1)./pixel(:, 3); pixel(:, 2) = pixel(:, 2)./pixel(:, 3);  % point's x & y are cor. to image's c & nr - r (nr: nnumber of raws)
pixel(:, 1:2)   = [pixel(:, 2) pixel(:, 1)];                                         % correction [r c]
im              = imread(sprintf('%06d.png', frame));                  % load image 
ins             = (pixel(:, 1) >= 1) & (pixel(:, 1) <= size(im, 1)) & ...            % index of pixels inside the image
                  (pixel(:, 2) >= 1) & (pixel(:, 2) <= size(im, 2));
velodyne(~ins, :) = [];
pixel(~ins, :) = [];   

%% delaunay triangulation
tri = delaunay(pixel(:, 1), pixel(:, 2)); % tri-set
x = [pixel(tri(:, 1), 1) pixel(tri(:, 2), 1) pixel(tri(:, 3), 1)];
y = [pixel(tri(:, 1), 2) pixel(tri(:, 2), 2) pixel(tri(:, 3), 2)];

%% plot
 figure
 imshow(im)
%DT = delaunayTriangulation([pixel(:, 2), pixel(:, 1)]);

  c_px = floor(min(pixel(:,1)));
  i_size = size(im(c_px:end,:,1));
  Ima3D = zeros( size(im(:,:,1)) );
     
    % Simply type: mex fun_dense3D.cpp
    
    pixeld=pixel;
    pixeld(:,2)=pixel(:,1);
        pixeld(:,1)=pixel(:,2);
  %[Ima3D(c_px:end,:),tri] = applyMethodDel(pixeld,[c_px i_size 0 0 0 0 1]); % MEX-file

  tic;
  Ima3D(c_px:end,:) = applyMethodDel(pixeld,[c_px i_size 0 0 0 0 1]); % MEX-file
  toc;
  [r, c] = size(Ima3D);                                           % build indeces for interpolation

dmn = (st.x_max*(Ima3D-st.x_min))./(Ima3D*(st.x_max-st.x_min));   % depth-map encoding: RangeInverse
dmn(dmn < 0) = 0; dmn(dmn > 1) = 1; 

mask   = zeros(size(Ima3D));                                % initialize mask
for i  = 1:c                                              % build the mask
vc     = Ima3D(:, i) ~= 0;
[~, l] = max(vc);
mask(l:end, i) = 1;
end
he     = strel('rectangle', [2, 10]);                     % horizontal extension
mask   = imdilate(mask, he);                              % by Dilation
 
dm  = uint8(mask.*(255*dmn));                             % mask the depth map
  
%hold on
%triplot(DT, 'LineStyle', '-', 'LineWidth', 0.01, 'Color', 'cyan') % green, cyan, magenta
%hold off
%   imshow(dm)
%   hold on;
%   for(i=1:3:length(tri))
%      
%       line([tri(i,1),tri(i+1,1)],[tri(i,2)+c_px tri(i+1,2)+c_px]);
%       line([tri(i+2,1),tri(i+1,1)],[tri(i+2,2)+c_px tri(i+1,2)+c_px]);
%             line([tri(i+2,1),tri(i,1)],[tri(i+2,2)+c_px tri(i,2)+c_px]);
% 
% 
%   end
%   
%  hold off;
  
  



