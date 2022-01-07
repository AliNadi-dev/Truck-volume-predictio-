function model=regression()
%% read data 
[Tflow,Cflow] = ReadData();


%% create delays 
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
    %% train and test data 
    nData=size(inputs,2);
    permutation =randperm(nData);
    x=inputs(:,permutation);
    y=targets(:,permutation);
    Ptrain=0.7;
    nTrain=round(Ptrain*nData);
    Xtrain=x(:,1:nTrain);
    Ytrain=y(:,1:nTrain);
    Xtest=x(:,nTrain+1:end);
    Ytest=y(:,nTrain+1:end);
    
    %% Modeling training
     Input=[ones(1,size(Xtrain,2))
            Xtrain];
     c=Ytrain*pinv(Input);
    %% predict 
    
    % train data 
    train=LSE(Xtrain,Ytrain,c);
    %test data
    test=LSE(Xtest,Ytest,c);
    % all data
    All=LSE(inputs,targets,c);
    
    
        %% test Nov
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
   Nov.targets = Tflow(Range);
   Nov.targets(Nov.targets==0)=0.0001;
   
   Nov.targets(Nov.targets<1)=1;
   
   
   
   Nov=LSE(Nov.inputs,Nov.targets,c);

    
    
    
    
    
    %%export
    model.tain=train;
    model.test=test;
    model.All=All;
    model.Nov=Nov;
    
end
   
