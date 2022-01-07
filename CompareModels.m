%% MainCompare models  

close all;
clear;
clc;

%% model historical average
HA =historicalAverage();

%% Linear regression 
Reg=Regression();

%% un optmized model 
MLP=Model1();

%% optimized model 
NSGA2MLP=opti_model();

%% LSTM 
LSTM=LSTM();


%% compare 

cdfplot(0.1.*NSGA2MLP.Test.APE./5);
hold on 
cdfplot(0.1.*LSTM.Nov.APE./5);
cdfplot(0.1.*MLP.test.APE);
cdfplot(Reg.Nov.APE);
cdfplot(HA.APE);
legend('NSGA2-MLP','LSTM','MLP','LR','HA');
