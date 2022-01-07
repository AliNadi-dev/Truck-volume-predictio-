function model=opti_model()
    Model_2=load('finalmodel.mat');
    Model_2=Model_2.Model;
    
    Model_2.trainOutputs(Model_2.trainOutputs<1)=1;
    Model_2.trainTargets(Model_2.trainTargets<1)=1;
    Model_2.testOutputs(Model_2.testOutputs<1)=1;
    Model_2.testTargets(Model_2.testTargets<1)=1;
    Model_2.outputs(Model_2.outputs<1)=1;
    Model_2.targets(Model_2.targets<1)=1;
    
    Model_2.Train.Y=Model_2.trainTargets;
    Model_2.Train.yhat=Model_2.trainOutputs;
    Model_2.Train.e= Model_2.Train.Y - Model_2.Train.yhat;
    Model_2.Train.MSE=mean(Model_2.Train.e.^2,'omitnan');
    Model_2.Train.MAE=mean(abs(Model_2.Train.e));
    Model_2.Train.MAPE=mean(abs(Model_2.Train.e./Model_2.trainTargets));
    Model_2.Train.APE=abs(Model_2.Train.e./Model_2.trainTargets);
    Model_2.Train.PAPE=numel(Model_2.Train.APE(Model_2.Train.APE<10))/numel(Model_2.Train.e);
    Model_2.Train.RMSE=sqrt(Model_2.Train.MSE);
    [Model_2.Train.R, ~]=corr(Model_2.Train.Y',Model_2.Train.yhat','rows','complete');
    
    Model_2.Test.Y=Model_2.testTargets;
    Model_2.Test.yhat=Model_2.testOutputs;
    Model_2.Test.e= Model_2.Test.Y - Model_2.Test.yhat;
    Model_2.Test.MSE=mean(Model_2.Test.e.^2,'omitnan');
    Model_2.Test.MAE=mean(abs(Model_2.Test.e));
    Model_2.Test.MAPE=mean(abs(Model_2.Test.e./Model_2.testTargets));
    Model_2.Test.APE=abs(Model_2.Test.e./Model_2.testTargets);
    Model_2.Test.PAPE=numel(Model_2.Test.APE(Model_2.Test.APE<10))/numel(Model_2.Test.e);
    Model_2.Test.RMSE=sqrt(Model_2.Test.MSE);
    [Model_2.Test.R, ~]=corr(Model_2.Test.Y',Model_2.Test.yhat','rows','complete');
    
    Model_2.All.X=Model_2.inputs;
    Model_2.All.Y=Model_2.targets;
    Model_2.All.yhat=Model_2.outputs;
    Model_2.All.e= Model_2.targets - Model_2.outputs;
    Model_2.All.MSE=mean(Model_2.All.e.^2,'omitnan');
    Model_2.All.MAE=mean(abs(Model_2.All.e));
    Model_2.All.MAPE=mean(abs(Model_2.All.e./Model_2.targets));
    Model_2.All.APE=abs(Model_2.All.e./Model_2.targets);
    Model_2.All.PAPE=numel(Model_2.All.APE(Model_2.All.APE<10))/numel(Model_2.All.e);
    Model_2.All.RMSE=sqrt(Model_2.All.MSE);
    [Model_2.All.R, ~]=corr(Model_2.All.Y',Model_2.All.yhat','rows','complete');
    
    %Nov
    load('CflowNov.mat');
    load('TFlowNov.mat');
    TFlowNov=fillmissing(TFlowNov,'previous');
    TFlowNov(TFlowNov==0)=0.0001;
    TFlowNov(TFlowNov<1)=1;
    Delays= [0 1 2 3 4 5 6 7 8 9];
    
    nDelay=numel(Delays);
    
    MaxDelay=max(Delays);
    
    N=numel(CflowNov);
    Range=(MaxDelay+1):N;
    % prepare inputs based on delays
    Model_2.Nov.inputs = zeros(nDelay,numel(Range));
    for k=1:nDelay
        d=Delays(k);
        Model_2.Nov.inputs(k,:)=CflowNov(Range-d);
    end
    %prepare targets based on delays
    Model_2.Nov.targets = TFlowNov(Range);
    Model_2.Nov.targets(Model_2.Nov.targets==0)=0.0001;
    
    Model_2.Nov.targets(Model_2.Nov.targets<1)=1;
    
    Model_2.Nov.yhat = Model_2.net(Model_2.Nov.inputs);
    Model_2.Nov.yhat(Model_2.Nov.yhat<1)=1;
    
    Model_2.Nov.e= Model_2.Nov.targets-Model_2.Nov.yhat;
    Model_2.Nov.MSE=mean(Model_2.Nov.e.^2,'omitnan');
    Model_2.Nov.MAE=mean(abs(Model_2.Nov.e));
    Model_2.Nov.MAPE=mean(abs(Model_2.Nov.e./ Model_2.Nov.targets));
    Model_2.Nov.APE=abs(Model_2.Nov.e./ Model_2.Nov.targets);
    Model_2.Nov.PAPE=numel(Model_2.Nov.APE(Model_2.Nov.APE<10))/numel(Model_2.Nov.e);
    Model_2.Nov.RMSE=sqrt(Model_2.Nov.MSE);
    [Model_2.Nov.R, ~]=corr( Model_2.Nov.targets',Model_2.Nov.yhat','rows','complete');

    model=Model_2;


end 