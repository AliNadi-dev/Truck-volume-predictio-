function model=LSE(X,Y,c)

    Input=[ones(1,size(X,2))
           X];
    yhat=c*Input;
    yhat(yhat<1)=1;

      %% Error
    e= Y-yhat;
    MSE=mean(e.^2,'omitnan');
    MAE=mean(abs(e));
    MAPE=mean(abs(e./Y));
    APE=abs(e./Y);
    PAPE=numel(APE(APE<10))/numel(e);
    RMSE=sqrt(MSE);
    [R, ~]=corr(Y',yhat','rows','complete');
   %% export
   model.X=X;
   model.c=c;
   model.Y=Y;
   model.yhat=yhat;
   model.e=e;
   model.MSE=MSE;
   model.MAE=MAE;
   model.MAPE=MAPE;
   model.APE=APE;
   model.PAPE=PAPE;
   model.RMSE=RMSE;
   model.R=R;
   
end 