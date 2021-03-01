% AA - Update: Mar 30
clear; clc; close all

path = fullfile(pwd, 'result');
for i = 0%:100
    
%% name
labelname = sprintf('%06d.txt', i)

x=5
y=6
width=7
height= 8

%% read from source
fd = fopen(fullfile(path, labelname), 'w+'); %create and open a file
data_to_file = sprintf('%s %f %f %f %f', 'Car',x,y,width,height);
fprintf(fd,'%s', data_to_file); 
fprintf(fd,'\n'); %new line 
fclose(fd);

% %% format
% % <object-class> <x> <y> <width> <height>

end



