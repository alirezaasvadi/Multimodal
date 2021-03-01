%% DepthCN: CN-W

%% Clear memory & command window
clc
clear
close all

%% setting
st = fun_sett;   % setting
load('ConvNet')  % load trained convnet
path = fullfile(pwd, 'result');

tic
%% proposal generation [3, 8, 24, 35]
for frame = st.st.st : st.st.tn

%% proposal generation   
[depthmap, image, points, pixels, ~] = fun_load(st, frame-1); % load data 
proposals = fun_prop(points, pixels, st); % object proposals [x, y, w, h]

%% batch inputing
im_batch = zeros(st.im_r, st.im_c, 1, size(proposals, 1), 'uint8');  
for i = 1: size(proposals, 1) % convnet input image
left   = proposals(i,1);
right  = proposals(i,1) + proposals(i,3);
top    = proposals(i,2);
bottom = proposals(i,2) + proposals(i,4);
im_batch(:, :, 1, i) = imresize(depthmap(top:bottom, left:right), [st.im_r, st.im_c]); 
end

%% classification
[val, err]  = classify(ConvNet, im_batch); % str2double(cellstr(val)) <= double(err(:, 2))
proposals(str2double(cellstr(val)) ~= 1, :) = [];
scores_all = double(err(:, 2));
score = scores_all(str2double(cellstr(val)) > 0);

%% plotting
% imshow(image)
% % imshow(depthmap)
% hold on
% for i = 1 : size(proposals, 1) 
% rectangle('Position',proposals(i, :),'EdgeColor','r','LineWidth',1.5) % [x y w h]
% end
% hold off
% pause(0.01)

%% write to labels
labelname = sprintf('%06d.txt', frame-1);

if isempty(proposals)  % no proposal, create empty file  
fid = fopen(fullfile(path, labelname), 'w');
fclose(fid);
else
    fid = fopen(fullfile(path, labelname), 'w'); % create and open a file
    for i = 1 : size(proposals, 1)
    % kitti format [x y x+w y+h]
    fprintf(fid,'%s ', 'Car'); % set label
    fprintf(fid,'-1 ');  % set truncation
    fprintf(fid,'-1 ');  % set occlusion
    fprintf(fid,'-10 '); % set alpha
    % set 2D bounding box in 0-based C++ coordinates
    fprintf(fid,'%.2f ',proposals(i,1)); % x1
    fprintf(fid,'%.2f ',proposals(i,2)); % y1
    fprintf(fid,'%.2f ',proposals(i,1)+proposals(i,3)); % x2
    fprintf(fid,'%.2f ',proposals(i,2)+proposals(i,4)); % y2
    % set 3D bounding box
    fprintf(fid,'-1 ');  % default
    fprintf(fid,'-1 ');  % default
    fprintf(fid,'-1 ');  % default
    fprintf(fid,'-1000 -1000 -1000 '); % default
    fprintf(fid,'-10 '); % default
    % set score 
    fprintf(fid,'%.2f ',2*(score(i)-0.5));
    % next line
    fprintf(fid,'\n');   
    end  
    fclose(fid);
end

disp(['Proc: ', num2str(100 * (frame / st.st.tn))])

end
toc

% x=proposals(1, 1);
% y=proposals(1, 2);
% width=proposals(1, 3);
% height= proposals(1, 4);
% 
% fd = fopen(fullfile(path, labelname), 'w+'); %create and open a file
% data_to_file = sprintf('%s %f %f %f %f', 'Car',x,y,width,height);
% fprintf(fd,'%s', data_to_file); 
% fprintf(fd,'\n'); %new line 
% fclose(fd);

