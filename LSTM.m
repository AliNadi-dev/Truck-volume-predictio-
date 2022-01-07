%% LSTM sequence to sequence pridiction of Truck flow 
function Model=LSTM()
%% Load flow Data
[T,C] = ReadData();
load('TFlowNov.mat');
load('CflowNov.mat');
TFlowNov=fillmissing(TFlowNov,'linear');
Cflow=[C CflowNov];
Tflow=[T TFlowNov];
% figure
% plot(Cflow,'-b');
% hold on;
% plot(Tflow,'-r');
% xlabel("Hour")
% ylabel("Flow")
% legend('Countainer flow','Truck flow');
% title("Hourly flow of truck and containers")
% xlim([0 length(Tflow)])
%% partitioning data to train and test
CTrainTimeSteps = numel(Cflow)-720;
TTrainTimeSteps = numel(Tflow)-720;
% prepare train and test Cflow data
CflowdataTrain = Cflow(1:CTrainTimeSteps);
CflowdataTest = Cflow(CTrainTimeSteps+1:end);
% prepare Train and test Tflow data
TflowdataTrain = Tflow(1:TTrainTimeSteps);
TflowdataTest = Tflow(TTrainTimeSteps+1:end);

%% Standardize train data

%standardize Cflow tarin data
Cmu = mean(CflowdataTrain);
Csig = std(CflowdataTrain);
CflowTrainDataStandardized = (CflowdataTrain - Cmu) / Csig;
% standardize Tflow train data 
Tmu = mean(TflowdataTrain);
Tsig = std(TflowdataTrain);
TflowTrainDataStandardized = (TflowdataTrain - Tmu) / Tsig;
%% Prepare Predictors and Responses
Delays=[0 1 2 3 4 5 6 7 8 9];       % list of desired delays 
nDelay=numel(Delays);

MaxDelay=max(Delays);

N=numel(CflowTrainDataStandardized);
Range=(MaxDelay+1):N;
% prepare inputs based on delays 
XTrain = zeros(nDelay,numel(Range));
for k=1:nDelay
    d=Delays(k);
    XTrain(k,:)=CflowTrainDataStandardized(Range-d);
end
%prepare targets based on delays
YTrain = TflowTrainDataStandardized(Range);
%% validation data


%% Define LSTM Network Architecture
% numFeatures = numel(Delays);
% numResponses = 1;
% numHiddenUnits = 200;
% 
% layers = [ ...
%     sequenceInputLayer(numFeatures)
%     lstmLayer(numHiddenUnits)
%     fullyConnectedLayer(numResponses)
%     regressionLayer];
% options = trainingOptions('adam', ...
%     'MaxEpochs',100, ...
%     'GradientThreshold',1, ...
%      'ValidationData',{XValidation,YValidation}, ...
%     'InitialLearnRate',0.005, ...
%     'LearnRateSchedule','piecewise', ...
%     'LearnRateDropPeriod',125, ...
%     'LearnRateDropFactor',0.2, ...
%     'Verbose',0, ...
%     'Plots','training-progress');
%% Train LSTM Network
% net = trainNetwork(XTrain,YTrain,layers,options);
%% Standardize test data 
CflowTestDataStandardized = (CflowdataTest - Cmu) / Csig;
TflowTestDataStandardized = (TflowdataTest - Tmu) / Tsig;

N=numel(CflowTestDataStandardized);
Range=(MaxDelay+1):N;
% prepare inputs based on delays 
XTest = zeros(nDelay,numel(Range));
for k=1:nDelay
    d=Delays(k);
    XTest(k,:)=CflowTestDataStandardized(Range-d);
end
%prepare targets based on delays
YTest = TflowTestDataStandardized(Range);
%% predict test data sequence using previous predictions 
load('LSTM_model.mat');
net = predictAndUpdateState(net,XTrain);
%% prediction based on obser values 
YPred = [];
numTimeStepsTest = size(XTest,2);
for i = 1:numTimeStepsTest
    [net,YPred(:,i)] = predictAndUpdateState(net,XTest(:,i),'ExecutionEnvironment','cpu');
end
YPred = Tsig*YPred + Tmu;
YTest= Tsig*YTest + Tmu;
rmse = sqrt(mean((YPred-YTest).^2));

%% Plot 
figure
subplot(2,1,1)
plot(YTest)
hold on
plot(YPred,'.-')
hold off
legend(["Observed" "Predicted"])
ylabel("Cases")
title("Forecast with Updates")

subplot(2,1,2)
stem(YPred - YTest)
xlabel("Month")
ylabel("Error")
title("RMSE = " + rmse)

YPred(YPred<1)=1;
YTest(YTest<1)=1;

Model.Nov.Y=YTest;
Model.Nov.YPred=YPred;
Model.Nov.e= YPred-YTest;
Model.Nov.MSE=mean(Model.Nov.e.^2,'omitnan');
Model.Nov.MAE=mean(abs(Model.Nov.e));
Model.Nov.MAPE=mean(abs(Model.Nov.e./ YTest));
Model.Nov.APE=abs(Model.Nov.e./ YTest);
Model.Nov.PAPE=numel(Model.Nov.APE(Model.Nov.APE<10))/numel(Model.Nov.e);
Model.Nov.RMSE=sqrt(Model.Nov.MSE);
[Model.Nov.R, ~]=corr( YTest',YPred','rows','complete');


end