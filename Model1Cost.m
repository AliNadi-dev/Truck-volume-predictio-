function [z sol]=Model1Cost(x,Cflow,Tflow,MaxDelay)

    global NFE;
    if isempty(NFE)
        NFE=0;
    end
    
    NFE=NFE+1;
    
    M=MaxDelay;           
    a=min(floor(M*x(1)),M);
    HL1=min(floor(7*x(2))+4,8);
    HL2=min(floor(7*x(3))+4,8);
    Delays= 0:a;
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
    hiddenLayerSize = [HL1 HL2];
    TF={'tansig','poslin','purelin'};
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
    
    MSE=mean(testError.^2);
    [R,~]=corr(testTargets',testOutputs','rows','complete');
    SSE = sse(net,testTargets,testOutputs); 
    n = length(tr.trainInd); 
    p = length(getwb(net)); 
    % Schwarz's Bayesian criterion (or BIC) 
    BIC = n * log(SSE/n) + 1.5*p * log(n)-1000*R;
    % Akaike's information criterion 
    AIC = n * log(SSE/n) + 2 * p;
    % Corrected AIC 
    AICc = n * log(SSE/n) + (n + p) / (1 - (p + 2) / n);
    z=min(BIC);
    
    sol.Delays=Delays;
    sol.nDelay=nDelay;
    sol.MaxDelay=MaxDelay;
    sol.net=net;
    sol.z=z;
    sol.inputs=inputs;
    sol.targets=targets;
    sol.outputs=outputs;
    sol.trainTargets=trainTargets;
    sol.trainOutputs=trainOutputs;
    sol.valTargets=valTargets;
    sol.valOutputs=valOutputs;
    sol.testTargets=testTargets;
    sol.testOutputs=testOutputs;
    sol.AIC=AICc;
    sol.BIC=BIC;
    sol.SSE=SSE;
    sol.HL1=HL1;
    sol.HL2=HL2;

end