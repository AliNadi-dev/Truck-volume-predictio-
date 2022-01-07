clear;
clc;
[Tflow,Cflow] = ReadData();

j=1;
for i=1:length(Cflow)-1
   if Cflow(i)>0
       if (Cflow(i+1)>1.24*Cflow(i))&&(Cflow(i+1)<1.26*Cflow(i))
       m(j)=i;
       j=j+1;
       end
   end
   
    
    
end
j=1;
for i=m
    C(j)=Tflow(i+1)/Tflow(i);
    j=j+1;
    
    
end
nanmean(C(C~=inf),'all')
nanmedian(C(C~=inf),'all')