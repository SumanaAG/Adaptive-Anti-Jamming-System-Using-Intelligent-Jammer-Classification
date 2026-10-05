function predictedLabel = classifier(rxSignal)

% Load trained Decision Tree
load('decisionTreeModel.mat','model');

% Extract features from received signal
features = featureExtraction(rxSignal);

% Predict jammer type
predictedLabel = predict(model,features);

end