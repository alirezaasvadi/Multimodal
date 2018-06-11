%% High-resolution (dense) map generation using 3D-LIDAR data 
% Dense-depth Map (DM) and dense-Reflectance Map (RM) are generated using Delaunay Triangulation.
% Only LIDAR data within the range of 80 m is considered for DM generation using RangeInverse depth encoding.

%% clear memory & command window
clc
clear 
close all

%% settings
st.x_min = 5;   % movement direction
st.x_max = 80;
st.y_min = -80; % right
st.y_max = 80;  % left
st.bias = 1.73; % velodyne elevation 
frame = 1468;

%% demo
[dm, rm, im] = fun_interp(st, frame, 'nearest'); % try 'nearest', 'linear', 'natural'

%% plot
subplot(311); imshow(im)
subplot(312); imshow(dm)
subplot(313); imshow(rm)



