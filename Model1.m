% Time series neral network version 1.0 for forcasting port of Rotterdam
% truck generation. 
function model=Model1()
    %% Load Data
    [Tflow,Cflow] = ReadData();

    %% prepare input and out put based on delays

    Delays=0:1;       % list of desired delays
    nDelay=numel(Delays);

    MaxDelay=max(Delays);

    N=numel(Cflow);
    Range=(MaxDelay+1):N;
    % prepare inputs based on delays
    inputs = zeros(nDelay,numel(Range));
    for k=1:nDelay
        d=Delays(k);
        inputs(k,:)=Cflow(Range-d);
    end
    %prepare targets based on delays
    targets = Tflow(Range);
    %% preperacessing

    %inputs(inputs==0)=0.01;
    targets(targets==0)=0.0001;

    %% Create a Fitting Network
    hiddenLayerSize = [4 3];
    TF={'logsig','logsig','purelin'};
    net = newff(inputs,targets,hiddenLayerSize,TF);

    % check if any rwo is constant and remove them
    net.inputs{1}.processFcns = {'removeconstantrows','mapminmax'};
    net.outputs{2}.processFcns = {'removeconstantrows','mapminmax'};

    % cross validation
    net.divideFcn = 'dividerand';  % Divide data randomly
    net.divideMode = 'sample';  % Divide up every sample
    net.divideParam.trainRatio = 70/100;
    net.divideParam.valRatio = 15/100;
    net.divideParam.testRatio = 15/100;

    net.trainFcn = 'trainlm';  % Levenberg-Marquardt

    % cost function
    net.performFcn = 'mse';  % Mean squared error

    % options
    net.trainParam.showWindow=false;
    net.trainParam.showCommandLine=false;
    net.trainParam.show=1;
    net.trainParam.epochs=5000;
    net.trainParam.goal=1e-8;
    net.trainParam.max_fail=1000;

    % Train the Network
    [net,tr] = train(net,inputs,targets);

    % Test the Network
    outputs = net(inputs);
    errors = gsubtract(targets,outputs);
    performance = perform(net,targets,outputs);

    % Recalculate Training, Validation and Test Performance
    trainInd=tr.trainInd;
    trainInputs = inputs(:,trainInd);
    trainTargets = targets(:,trainInd);
    trainOutputs = outputs(:,trainInd);
    trainErrors = trainTargets-trainOutputs;
    trainPerformance = perform(net,trainTargets,trainOutputs);

    valInd=tr.valInd;
    valInputs = inputs(:,valInd);
    valTargets = targets(:,valInd);
    valOutputs = outputs(:,valInd);
    valErrors = valTargets-valOutputs;
    valPerformance = perform(net,valTargets,valOutputs);

    testInd=tr.testInd;
    testInputs = inputs(:,testInd);
    testTargets = targets(:,testInd);
    testOutputs = outputs(:,testInd);
    testError = testTargets-testOutputs;
    testPerformance = perform(net,testTargets,testOutputs);

    %% Models information 
    trainTargets(trainTargets<1)=1;   
    trainOutputs(trainOutputs<1)=1;    
    Train.X=trainInputs;
    Train.Y=trainTargets;
    Train.yhat=trainOutputs;
    Train.e= trainErrors;
    Train.MSE=mean(Train.e.^2,'omitnan');
    Train.MAE=mean(abs(Train.e));
    Train.MAPE=mean(abs(Train.e./trainTargets));
    Train.APE=abs(Train.e./trainTargets);
    Train.PAPE=numel(Train.APE(Train.APE<10))/numel(Train.e);
    Train.RMSE=sqrt(Train.MSE);
    [Train.R, ~]=corr(Train.Y',Train.yhat','rows','complete');

    testTargets(testTargets<1)=1;   
    testOutputs(testOutputs<1)=1;
    Test.X=testInputs;
    Test.Y=testTargets;
    Test.yhat=testOutputs;
    Test.e= testError;
    Test.MSE=mean(Test.e.^2,'omitnan');
    Test.MAE=mean(abs(Test.e));
    Test.MAPE=mean(abs(Test.e./testTargets));
    Test.APE=abs(Test.e./testTargets);
    Test.PAPE=numel(Test.APE(Test.APE<10))/numel(Test.e);
    Test.RMSE=sqrt(Test.MSE);
    [Test.R, ~]=corr(Test.Y',Test.yhat','rows','complete');

    targets(targets<1)=1;   
    outputs(outputs<1)=1;
    All.X=inputs;
    All.Y=targets;
    All.yhat=outputs;
    All.e= errors;
    All.MSE=mean(All.e.^2,'omitnan');
    All.MAE=mean(abs(All.e));
    All.MAPE=mean(abs(All.e./targets));
    All.APE=abs(All.e./targets);
    All.PAPE=numel(All.APE(All.APE<10))/numel(All.e);
    All.RMSE=sqrt(All.MSE);
    [All.R, ~]=corr(All.Y',All.yhat','rows','complete');



    %% Test Model 1 on Nov
    %read Nov data
    load('CflowNov.mat')
    load('TFlowNov.mat')
    TFlowNov=fillmissing(TFlowNov,"linear");
    TFlowNov(TFlowNov==0)=0.0001;
    TFlowNov(TFlowNov<1)=1;


    Delays=0:1;       % list of desired delays
    nDelay=numel(Delays);

    MaxDelay=max(Delays);

    N=numel(CflowNov);
    Range=(MaxDelay+1):N;
    % prepare inputs based on delays
    Novinputs = zeros(nDelay,numel(Range));
    for k=1:nDelay
        d=Delays(k);
        Novinputs(k,:)=CflowNov(Range-d);
    end
    %prepare targets based on delays

    Novtargets = TFlowNov(Range);

    %test network;
    Novoutputs = net(Novinputs);

    Noverrors = gsubtract(Novtargets,Novoutputs);
    
    Novtargets(Novtargets<1)=1;
   
    Novoutputs(Novoutputs<1)=1;
   
    Nov.X=Novinputs;
    Nov.Y=Novtargets;
    Nov.yhat=Novoutputs;
    Nov.e= Noverrors;
    Nov.MSE=mean(Nov.e.^2,'omitnan');
    Nov.MAE=mean(abs(Nov.e));
    Nov.MAPE=mean(abs(Nov.e./Novtargets));
    Nov.APE=abs(Nov.e./Novtargets);
    Nov.PAPE=numel(Nov.APE(Nov.APE<10))/numel(Nov.e);
    Nov.RMSE=sqrt(Nov.MSE);
    [Nov.R, ~]=corr(Nov.Y',Nov.yhat','rows','complete');

    model.test=Test;
    model.traind=Train;
    model.All=All;
    model.Nov=Nov;
end 