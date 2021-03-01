function st = fun_sett % setting [directory, number of frames]

addpath(genpath([pwd, '/funs'])) % add to path the related functions

%% directories
st.dr.cam = 2; % left/right camera
st.dr.dst = 'testing'; % training/testing dataset 
st.dr.mdr = '/media/deeplearning/6D7C1C3E7AAEE02A/Datasets/kitti_dataset/dataset_object'; % main directoy of dataset
% st.dr.mdr = 
st.dr.depth = fullfile(st.dr.mdr, 'data_object_depth_nearest', st.dr.dst); % directory of depth images
st.dr.lbl = fullfile(st.dr.mdr, 'data_object_label_2', st.dr.dst, 'label_2'); % directory of labels
st.dr.img = fullfile(st.dr.mdr, 'data_object_image_2', st.dr.dst, sprintf('image_%01d/', st.dr.cam)); % directory of color images
st.dr.pts = fullfile(st.dr.mdr, 'data_object_velodyne', st.dr.dst, 'velodyne'); % directory of velodyne points
st.dr.clb = fullfile(st.dr.mdr, 'data_object_calib', st.dr.dst, 'calib'); % directory of calibration

%% start and end frames
st.st.st = 1; % start frames
st.st.tn = size(dir(sprintf('%s/*.png', st.dr.img)), 1); % number of frames

%% settings
st.x_min = 5;   % movement direction
st.x_max = 80;
st.y_min = -80; % right
st.y_max = 80;  % left
st.bias = 1.73; % velodyne elevation 

st.vx = 0.5;      % grid cell size
st.var_tr = 0.01; % variance threshold
st.epsn = 0.5;    % epsilon
st.mpts = 5;      % minimum # points

st.im_r = 66;  % # rows: vehicle height
st.im_c = 112; % # columns: vehicle width

end
