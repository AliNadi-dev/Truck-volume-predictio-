function [z, out]=FeatureSelectionCost(x,Cflow,Tflow,MaxDelay)


    
    wTrain=0.1;
    wTest=1-wTrain;
    M=MaxDelay;
    % Number of Runs
    nRun=10;
    EE=zeros(1,nRun);
    a=min(floor(M*x(1))+1,M);
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
        %% run NNA
        hiddenLayerSize = [HL1 HL2];
        TF={'tansig','tansig','purelin'};
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
        net.trainParam.epochs=100;
        net.trainParam.goal=1e-8;
        net.trainParam.max_fail=10;
        
    for r=1:nRun
       
        
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
        
        EE(r) = wTrain*mean(trainErrors.^2) + wTest*mean(testError.^2);
    end
    %n = nDelay;
    n = length(tr.trainInd);
    p = length(getwb(net));
    E=mean(EE);
    if isinf(E)
       E=100;
    end
    AICc = n * log(E) + (n + p) / (1 - (p + 2) / n);
    BIC = n * log(E) + p * log(n);
    % Calculate Final Cost
    [aic, bic]=aicbic(E,p,n);
    z=[a
       E];

    % Set Outputs
    out.d=a;
    out.nf=n;
    out.HL1=HL1;
    out.HL2=HL2;
    out.E=E;    
    out.z=z;
    out.net=net;
    out.inputs=inputs;
    out.targets=targets;
    out.outputs=outputs;
    out.trainTargets=trainTargets;
    out.trainOutputs=trainOutputs;
    out.valTargets=valTargets;
    out.valOutputs=valOutputs;
    out.testTargets=testTargets;
    out.testOutputs=testOutputs;
    out.AICc= AICc; 
    out.BIC=BIC;
    out.aic=aic;
    out.bic=bic;

    
end