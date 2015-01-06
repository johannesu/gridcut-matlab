clear all;
clc;
addpath([fileparts(mfilename('fullpath')) filesep '..']);

%% Settings
settings = GridCutSettings;
settings.connectivity = 8;
settings.resolution = [1 1];

% Regularization cost is w*regularization_strength
% where w is determined via the resolution, see
% Computing geodesics and minimal surfaces via graph cuts, ICCV 2013.
settings.regularization_strength = 0.1;

%% Data term
I = single(imread('cameraman.tif'))/255;
data_term = 0.5 -I;

%% Solve
segmentation = GridCutSolver(data_term, settings);

%% Display
subplot(1,2,1)
imagesc(data_term < 0)
title('Threshold');
axis equal; colormap(gray); axis off;

subplot(1,2,2)
imagesc(segmentation);
title('Segmentation');
axis equal; colormap(gray); axis off;
