close all;
All.t=F1(8).Out.targets;
All.y=F1(8).Out.outputs;
All.name='All Data';

Val.t=F1(8).Out.valTargets; 
Val.y=F1(8).Out.valOutputs;
Val.name='Validation Data';

Train.t=F1(8).Out.trainTargets;
Train.y=F1(8).Out.trainOutputs;
Train.name='Train Data';

Test.t=F1(8).Out.testTargets;
Test.y=F1(8).Out.testOutputs;
Test.name='Test Data';

PlotResults2(Train,Test,Val,All);
