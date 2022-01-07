function [Tflow,Cflow] = ReadData()
parts = strsplit(pwd, '\');
root= [];
for i=1:length(parts)-1
    root= [root parts{i} '/']; 
end
Address=[root 'feature selection/Data/'];
Cflow=load([Address 'Cflow.mat']);
Tflow=load([Address 'Tflow.mat']);
Cflow=Cflow.Cflow;
Tflow=Tflow.Tflow;
end

