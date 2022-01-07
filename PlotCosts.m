function PlotCosts(pop)

    Costs=[pop.Cost];
%     subplot(1,2,1);
    plot(Costs(1,:),Costs(2,:),'r*','MarkerSize',8);
    hold on;
%     x = [1 2 3 4 5 7 9 13];
%     y = [3694 3285 3147 2974 2948 2818 2739 2674];
% %     x = [1  2 3 6 11 22];
% %     y = [ 3600 3300 3163 2785 2668 2641];
%     xx = 1:.5:22;
%     yy = spline(x,y,xx);
%     plot(x,y,'bo',xx,yy,'color','b');
    xlabel('n_d');
    ylabel('E');
    grid on;
    
    

%     subplot(1,2,2)
%     scatter3(Costs(1,:),Costs(2,:),Costs(3,:),40,Costs(4,:),'filled')    % draw the scatter plot
%     ax = gca;
%     ax.XDir = 'reverse';
%     view(-31,14)
%     xlabel('N_F')
%     ylabel('N_H1')
%     zlabel('N_H2')
%     
%     cb = colorbar;                                     % create and label the colorbar
%     cb.Label.String = 'Preformance of the model (MSE)';
    
    
      
end