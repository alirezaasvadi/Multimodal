%% DepthCN
% CN-W
% 

%% Clear memory & command window
clc
clear
close all

%% setting
st = fun_sett;   % setting
load('seed.mat') % p: randomize indices
load('ConvNet')

%% proposal generation
tic
for frame = 3
    
[depthmap, image, points, pixels, ~] = fun_load(st, p(frame) - 1); % load data 
proposals = fun_prop(points, pixels, st);   % object proposals

%% object classification [vehicle: 51, 52], [pole: 55], [truck: 39]
%% pre-processing: batch inputing
im_batch = zeros(st.im_r, st.im_c, 1, size(proposals, 1), 'uint8');  
for i = 1: size(proposals, 1) % convnet input image
left   = proposals(i,1);
right  = proposals(i,1) + proposals(i,3);
top    = proposals(i,2);
bottom = proposals(i,2) + proposals(i,4);
im_batch(:, :, 1, i) = imresize(depthmap(top:bottom, left:right), [st.im_r, st.im_c]); 
end

%% classification
value  = classify(ConvNet, im_batch);
end
toc

%% plot
imshow(image)
% imshow(depthmap)
hold on
for i = 1 : size(proposals, 1)  
if str2double(cellstr(value(i))) == 1
rectangle('Position',proposals(i, :),'EdgeColor','r','LineWidth',1.5) % [x y w h]
end
end
hold off

