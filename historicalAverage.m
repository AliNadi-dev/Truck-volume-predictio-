function model =historicalAverage()

%% read data 
[Tflow,Cflow] = ReadData();

%% delay
    Delays= [0 1 2 3 4 5 6 7 8 9];
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
    targets(targets==0)=0.0001;
    
    targets(targets<1)=1;
    
    %% model 
    yhat=mean(inputs);
    yhat(yhat<1)=1;
    
    
     %% Error
    e= targets-yhat;
    MSE=mean(e.^2,'omitnan');
    MAE=mean(abs(e));
    MAPE=mean(abs(e./targets));
    APE=abs(e./targets);
    PAPE=numel(APE(APE<10))/numel(e);
    RMSE=sqrt(MSE);
    [R, ~]=corr(targets',yhat','rows','complete');
    %% Nov
   load('CflowNov.mat')
   load('TFlowNov.mat')
   TFlowNov=fillmissing(TFlowNov,"linear");
   TFlowNov(TFlowNov==0)=0.0001;    
   TFlowNov(TFlowNov<1)=1;
   Delays= [0 1 2 3 4 5 6 7 8 9];

   nDelay=numel(Delays);

   MaxDelay=max(Delays);
   
   N=numel(CflowNov);
   Range=(MaxDelay+1):N;
   % prepare inputs based on delays
   Nov.inputs = zeros(nDelay,numel(Range));
   for k=1:nDelay
       d=Delays(k);
       Nov.inputs(k,:)=CflowNov(Range-d);
   end
   %prepare targets based on delays
   Nov.targets = TFlowNov(Range);
   Nov.targets(Nov.targets==0)=0.0001;
   
   Nov.targets(Nov.targets<1)=1;  
   Nov.yhat=mean(Nov.inputs,'omitnan');
   Nov.yhat(Nov.yhat<1)=1;
   
   Nov.e= Nov.targets-Nov.yhat;
   Nov.MSE=mean(Nov.e.^2,'omitnan');
   Nov.MAE=mean(abs(Nov.e));
   Nov.MAPE=mean(abs(Nov.e./ Nov.targets));
   Nov.APE=abs(Nov.e./ Nov.targets);
   Nov.PAPE=numel(Nov.APE(Nov.APE<10))/numel(e);
   Nov.RMSE=sqrt(Nov.MSE);
   [Nov.R, ~]=corr(Nov.targets',Nov.yhat','rows','complete');
     %% export
    model.X=inputs;
    model.Y=targets;
    model.yhat=yhat;
    model.e=e;
    model.MSE=MSE;
    model.MAE=MAE;
    model.MAPE=MAPE;
    model.APE=APE;
    model.PAPE=PAPE;
    model.RMSE=RMSE;
    model.R=R;
    model.Nov=Nov;
     
end
    