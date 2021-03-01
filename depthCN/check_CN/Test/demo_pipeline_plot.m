%% DepthCN: 1st-attempt
% KITCB (nearest), Train: 92.50%, Test: 86.23%
% Todo: improve convnet accuracy

%% Clear memory & command window
clc
clear
close all

%% setting
st = fun_sett;   % setting
load('seed.mat') % p: randomize indices
load('ConvNet')  % load trained convnet

tic
%% proposal generation
for frame = 3%1:10 % 8
[depthmap, image, points, pixels, ~] = fun_load(st, p(frame) - 1); % load data 
proposals = fun_prop(points, pixels, st); % object proposals

%% object classification
imshow(image)
% imshow(depthmap)

hold on
for i = 1 : size(proposals, 1) 

%% pre-processing
left   = proposals(i,1);
right  = proposals(i,1) + proposals(i,3);
top    = proposals(i,2);
bottom = proposals(i,2) + proposals(i,4);
testIm = imresize(depthmap(top:bottom, left:right), [st.im_r, st.im_c]); 

%% classification
value  = classify(ConvNet, testIm);  

%% plot
if str2double(cellstr(value)) == 1
rectangle('Position',proposals(i, :),'EdgeColor','r','LineWidth',1.5) % [x y w h]
end

end
hold off
pause(0.01)

end
toc

