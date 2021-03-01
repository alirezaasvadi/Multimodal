%% ConvNet with DA
% ConvNet  WO-DA   0.9283 0.8669
% ConvNet  W-DA    0.9645 0.9193

%% Clear memory & command window
clc
clear
close all
addpath(genpath('/media/deeplearning/6D7C1C3E7AAEE02A/Dropbox/Code/data'))
% addpath(genpath('D:\Dropbox\Code\data'))

%% Load data - options: mnist, cifar, kit20, kit50, kitca, kitcb, kitcc, kit16 [my pref. kitcb, kit16]
[trainIm, trainLb, testIm, testLb, numImCat] = load_data('kitcb');

%% Create the image input layer
[height, width, numChannels, ~] = size(trainIm);
imageSize = [height width numChannels];
inputLayer = imageInputLayer(imageSize); 

%% Convolutional layer 
filterSize = [5 5];
numFilters = 32;

middleLayers = [
convolution2dLayer(filterSize, numFilters, 'Padding', 2)
reluLayer()
maxPooling2dLayer(3, 'Stride', 2)
convolution2dLayer(filterSize, 2*numFilters, 'Padding', 2)
reluLayer()
maxPooling2dLayer(3, 'Stride',2)
];

%% Fully connected layer
finalLayers = [
fullyConnectedLayer(64)
reluLayer
fullyConnectedLayer(numImCat)
softmaxLayer
classificationLayer
];

%% Concatenate layers and build the network
layers = [
    inputLayer
    middleLayers
    finalLayers
    ];

layers(2).Weights = 0.0001 * randn([filterSize numChannels numFilters]);

%% Train the network
opts = trainingOptions('sgdm', 'Momentum', 0.9, 'InitialLearnRate', 0.001, 'LearnRateSchedule', 'piecewise', ...
    'LearnRateDropFactor', 0.1, 'LearnRateDropPeriod', 8, 'L2Regularization', 0.004, 'MaxEpochs', 40, ...
    'MiniBatchSize', 128, 'Verbose', true);

doTraining = false;   % false/true   % options: false, true
tic
if doTraining
    % Train a network.
    ConvNet = trainNetwork(trainIm, trainLb, layers, opts);
else
    % Load pre-trained detector for the example.
    load('ConvNet_WO');
end
t_cnn = toc;

%% Extract the first convolutional layer weights
% w = ConvNet.Layers(2).Weights;
% figure, montage(imresize(mat2gray(w), [100 100]))

%% Accuracy on the training/test set
Yval = classify(ConvNet, trainIm);
accuracy = sum(Yval == trainLb) / numel(trainLb);
disp(accuracy)

Yval = classify(ConvNet, testIm);
accuracy = sum(Yval == testLb) / numel(testLb);
disp(accuracy)

% im_test = testIm(:,:,1,1);
% Ytest = classify(ConvNet, im_test);



