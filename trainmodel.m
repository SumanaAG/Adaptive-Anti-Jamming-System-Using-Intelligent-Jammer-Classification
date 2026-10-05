clc;
clear;
close all;

%% Load Dataset
data = readmatrix('jammerDataset.csv');

% Features
X = data(:,1:5);

% Labels
Y = data(:,6);

%% Train-Test Split
rng(1);   % Same split every time

cv = cvpartition(Y,'HoldOut',0.2);

XTrain = X(training(cv),:);
YTrain = Y(training(cv));

XTest = X(test(cv),:);
YTest = Y(test(cv));

%% Random Forest
numTrees = 100;

RFModel = TreeBagger(numTrees, XTrain, YTrain, ...
    'Method','classification', ...
    'OOBPrediction','On');

%% Prediction
YPred = predict(RFModel,XTest);

% TreeBagger returns labels as strings/cell
YPred = str2double(YPred);

%% Accuracy
accuracy = mean(YPred == YTest) * 100;

fprintf('Random Forest Accuracy = %.2f%%\n',accuracy);

%% Confusion Matrix
figure;
confusionchart(YTest,YPred);

title('Random Forest Confusion Matrix');

% %% ROC Curve - Random Forest (One-vs-Rest)
% 
% % Get class probability scores
% [~, scores] = predict(RFModel, XTest);
% 
% % Convert class names from TreeBagger to numbers
% classNames = str2double(RFModel.ClassNames);
% 
% % Number of classes
% numClasses = numel(classNames);
% 
% figure;
% hold on;
% grid on;
% 
% AUC = zeros(numClasses,1);
% 
% for i = 1:numClasses
% 
%     % True labels for current class
%     YBinary = (YTest == classNames(i));
% 
%     % Probability of current class
%     classScore = scores(:,i);
% 
%     % Calculate ROC
%     [FPR, TPR, ~, AUC(i)] = perfcurve(YBinary, classScore, true);
% 
%     % Plot ROC
%     plot(FPR, TPR, 'LineWidth', 2, ...
%         'DisplayName', sprintf('Class %d (AUC = %.4f)', ...
%         classNames(i), AUC(i)));
% 
% end

% % Random classifier reference line
% plot([0 1], [0 1], '--', ...
%     'DisplayName', 'Random Classifier');
% 
% xlabel('False Positive Rate');
% ylabel('True Positive Rate');
% 
% title('Random Forest - Multiclass ROC Curve');
% 
% legend('Location','southeast');
% 
% xlim([0 1]);
% ylim([0 1]);
% 
% hold off;

% %% Display AUC values
% 
% fprintf('\nROC-AUC Results:\n');
% 
% for i = 1:numClasses
%     fprintf('Class %d AUC = %.4f\n', ...
%         classNames(i), AUC(i));
% end