function PlotResults(t,y,name)
    y(y<1)=1;
    t(t<1)=1;
    figure;
    
    % t and y
    h1=subplot(2,2,1);
    y(y<0)=0;
    plot(y,'.-','color',[0.8 0 0],'LineWidth',1);
       
    hold on;
    plot(t,'-','LineWidth',.1,'color',[0.1 0.1 0.1]);
    legend('Outputs','Targets');
    title(name);
    xlabel('Hour');
    ylabel('Truck flow');
    xlim(h1,[0 length(t)]);
    hold off;
    % Correlation Plot
    h2=subplot(2,2,2);
    plot(t,y,'k.');
    hold on;
    xmin=min(min(t),min(y));
    xmax=max(max(t),max(y));
    plot([0 xmax],[0 xmax],'b--','LineWidth',1);
    G = polyfit(t,y,1);
    yfit = G(1)*t+G(2);
    plot(t,yfit,'-','color',[1 0 1],'LineWidth',2);
    [R P]=corr(t',y','rows','complete');
    title({['R = ' num2str(R) '   P-Value = ' num2str(P)],['Output~=' num2str(round(G(1),2)) ' * target +' num2str(round(G(2),2))]});
    xlabel('Actual Truck');
    ylabel('Predicted truck' );
    xlim(h2,[xmin xmax]);
    ylim(h2,[xmin xmax])
    legend(' Data',' Y=T',' fit', 'location','northwest');
    hold off;
    % e
    h3=subplot(2,2,3);
    e=t-y;
    plot(e,'b');
    legend('Error');
     MSE=mean(e.^2,'omitnan');
    MAE=mean(abs(e));
    MAPE=mean(abs(e./t));
    APE=abs(e./t);
    PAPE=numel(APE(APE<10))/numel(e);
    RMSE=sqrt(MSE);
    title({[ 'MSE = ' num2str(MSE) ',  RMSE=' num2str(RMSE) ',  MAE = ' num2str(MAE) ',  MAPE = ' num2str(MAPE) ',  PAPE = ' num2str(PAPE)]});
    xlim(h3,[0,length(e)]);
    xlabel('Hour');
    ylabel('residuals');
    subplot(2,2,4);
    histfit(e,50);
    eMean=mean(e,'omitnan');
    eStd=std(e,'omitnan');
    title(['\mu = ' num2str(eMean) ', \sigma = ' num2str(eStd)]);
    %annotation('textbox', [0.171875,0.012829787234043,0.05859375,0.039893617021277], 'String', ['BIC=' num2str(sol.BIC)])
end