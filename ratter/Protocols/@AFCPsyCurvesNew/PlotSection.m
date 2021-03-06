function [x, y] = PlotSection(obj, action, x, y)

GetSoloFunctionArgs;

switch action,
    case 'init',
        
        Conc1 = '-1';
        Conc2 = '-2';
        Conc3 = '-3';
        Conc4 = '-4';
        
        Mix1 = '100/0';
        Mix2 = '80/20';
        Mix3 = '68/32';
        Mix4 = '56/44';
        
        
%         gcf;
        SoloParamHandle(obj, 'myfig', 'value', figure, 'saveable', 0);
        name = 'Plot Section'; 
        set(value(myfig), 'Name', name, 'Tag', name, ...
              'closerequestfcn', 'dispatcher(''close_protocol'')', 'MenuBar', 'none');
        set(value(myfig), 'Position', [20   50   1500   980], 'Visible', 'on');
        x = 1; y = 1;
        
        % -------------------- sidePlot ----------------------------------
        SoloParamHandle(obj,'sidePlot', 'saveable', 0, 'value', axes('Position', [0.04 0.04 0.44 0.12]));

        
        SoloParamHandle(obj, 'xAxisLim')
        xAxisLim.value = 40;
        SoloParamHandle(obj, 'i');
        i.value = 0;
        
        set(value(sidePlot),'xlim',[0 value(xAxisLim)],'ylim', [0.5 2.5]); hold on
        xlabel('# Trials')
        set(gca,'YTickLabel',{'--','left','--','right','--'})
        
%         next_row(y,1.3);

        
        % -------------------- biasPlot -----------------------------
        SoloParamHandle(obj,'biasConcPlot', 'saveable', 0, 'value', axes('Position', [0.52 0.04 0.2 0.12]));
        set(value(biasConcPlot),'xlim',[0 value(xAxisLim)],'ylim', [0 1]); hold on
        xlabel('# Trials')
        ylabel('Bias / Prob. left odor');
        
        SoloParamHandle(obj,'biasMixPlot', 'saveable', 0, 'value', axes('Position', [0.76 0.04 0.2 0.12]));
        set(value(biasMixPlot),'xlim',[0 value(xAxisLim)],'ylim', [0 1]); hold on
        xlabel('# Trials')
        ylabel('Bias / Prob. left mix');

        
        
        
        % -------------------- OSTPlot -----------------------------
        SoloParamHandle(obj,'OSTOdor1Plot', 'saveable', 0, 'value', axes('Position', [0.04 0.22 0.20 0.16]));
        set(value(OSTOdor1Plot),'xlim',[-5 0],'ylim', [-0.05 1]); hold on
        ylabel('OST (s)')
        xlabel('Concentration (log scale)')
        set(gca,'XTickLabel',{' ', Conc4, Conc3, Conc2, Conc1, ' '})
        
        SoloParamHandle(obj,'OSTOdor2Plot', 'saveable', 0, 'value', axes('Position', [0.28 0.22 0.20 0.16]));
        set(value(OSTOdor2Plot),'xlim',[-5 0],'ylim', [-0.05 1]); hold on
        ylabel('OST (s)')
        xlabel('Concentration (log scale)')
        set(gca,'XTickLabel',{' ', Conc4, Conc3, Conc2, Conc1, ' '})

        SoloParamHandle(obj,'OSTMix1Plot', 'saveable', 0, 'value', axes('Position', [0.52 0.22 0.20 0.16]));
        set(value(OSTMix1Plot),'xlim',[-5 0],'ylim', [-0.05 1]); hold on
        ylabel('OST (s)')
        xlabel('Mixture ratio')
        set(gca,'XTickLabel',{' ', Mix4, Mix3, Mix2, Mix1, ' '})
        
        SoloParamHandle(obj,'OSTMix2Plot', 'saveable', 0, 'value', axes('Position', [0.76 0.22 0.20 0.16]));
        set(value(OSTMix2Plot),'xlim',[-5 0],'ylim', [-0.05 1]); hold on
        ylabel('OST (s)')
        xlabel('Mixture ratio')
        set(gca,'XTickLabel',{' ', Mix4 , Mix3, Mix2, Mix1, ' '})
        
                
       % -------------------- performancePlot -----------------------------
        SoloParamHandle(obj,'perfOdor1Plot', 'saveable', 0, 'value', axes('Position', [0.04 0.41 0.20 0.16]));
        set(value(perfOdor1Plot),'xlim',[-5 0],'ylim', [-0.05 1.05]); hold on
        ylabel('Performance (%)')
        set(gca,'XTickLabel',{' ', Conc4, Conc3, Conc2, Conc1, ' '})
%         xlabel('Concentration')
        
        SoloParamHandle(obj,'perfOdor2Plot', 'saveable', 0, 'value', axes('Position', [0.28 0.41 0.20 0.16]));
        set(value(perfOdor2Plot),'xlim',[-5 0],'ylim', [-0.05 1.05]); hold on
        ylabel('Performance (%)')
        set(gca,'XTickLabel',{' ', Conc4, Conc3, Conc2, Conc1, ' '})
%         xlabel('Concentration')

        SoloParamHandle(obj,'perfMix1Plot', 'saveable', 0, 'value', axes('Position', [0.52 0.41 0.20 0.16]));
        set(value(perfMix1Plot),'xlim',[-5 0],'ylim', [-0.05 1.05]); hold on
        ylabel('Performance (%)')
%         xlabel('Concentration')
        set(gca,'XTickLabel',{' ', Mix4, Mix3, Mix2, Mix1, ' '})
        
        SoloParamHandle(obj,'perfMix2Plot', 'saveable', 0, 'value', axes('Position', [0.76 0.41 0.20 0.16]));
        set(value(perfMix2Plot),'xlim',[-5 0],'ylim', [-0.05 1.05]); hold on
        ylabel('Performance (%)')
%         xlabel('Concentration')
        set(gca,'XTickLabel',{' ', Mix4, Mix3, Mix2, Mix1, ' '})
        

        
        % -------------------- MTPlot -----------------------------
        SoloParamHandle(obj,'MTOdor1Plot', 'saveable', 0, 'value', axes('Position', [0.04 0.6 0.20 0.16]));
        set(value(MTOdor1Plot),'xlim',[-5 0],'ylim', [-0.05 1]); hold on
        ylabel('MT (s)')
%         xlabel('Concentration')
        set(gca,'XTickLabel',{' ', Conc4, Conc3, Conc2, Conc1, ' '})
%         title('Odor 1')
        
        SoloParamHandle(obj,'MTOdor2Plot', 'saveable', 0, 'value', axes('Position', [0.28 0.6 0.20 0.16]));
        set(value(MTOdor2Plot),'xlim',[-5 0],'ylim', [-0.05 1]); hold on
        ylabel('MT (s)')
%         xlabel('Concentration')
        set(gca,'XTickLabel',{' ', Conc4, Conc3, Conc2, Conc1, ' '})
%         title('Odor 2')

        SoloParamHandle(obj,'MTMix1Plot', 'saveable', 0, 'value', axes('Position', [0.52 0.6 0.20 0.16]));
        set(value(MTMix1Plot),'xlim',[-5 0],'ylim', [-0.05 1]); hold on
        ylabel('MT (s)')
%         xlabel('Concentration')
%         title('Mix 1')
        set(gca,'XTickLabel',{' ', Mix4, Mix3, Mix2, Mix1, ' '})
        
        SoloParamHandle(obj,'MTMix2Plot', 'saveable', 0, 'value', axes('Position', [0.76 0.6 0.20 0.16]));
        set(value(MTMix2Plot),'xlim',[-5 0],'ylim', [-0.05 1]); hold on
        ylabel('MT (s)')
%         xlabel('Concentration')
%         title('Mix 2')
        set(gca,'XTickLabel',{' ', Mix4, Mix3, Mix2, Mix1, ' '})
        
        
        
        % -------------------- concProportionPlot -----------------------------
        SoloParamHandle(obj,'odor1PropPlot', 'saveable', 0, 'value', axes('Position', [0.04 0.79 0.20 0.16]));
        set(value(odor1PropPlot),'xlim', [-5 0],'ylim', [0 100]); hold on
        ylabel('Number of trials')
%         xlabel('Concentration')
        title('Concentration task -- Odor 1')
        set(gca,'XTickLabel',{' ',Conc4, Conc3, Conc2, Conc1,' '})
        
        SoloParamHandle(obj,'odor2PropPlot', 'saveable', 0, 'value', axes('Position', [0.28 0.79 0.20 0.16]));
        set(value(odor2PropPlot),'xlim', [-5 0],'ylim', [0 100]); hold on
        ylabel('Number of trials')
%         xlabel('Concentration')
        title('Concentration task -- Odor 2')
        set(gca,'XTickLabel',{' ',Conc4, Conc3, Conc2, Conc1,' '})
        
        % -------------------- mixProportionPlot -----------------------------
        SoloParamHandle(obj,'mix1PropPlot', 'saveable', 0, 'value', axes('Position', [0.52 0.79 0.2 0.16]));
        set(value(mix1PropPlot),'xlim',[-5 0],'ylim', [0 100]); hold on
        ylabel('Number of trials')
%         xlabel('Concentration')
        title('Mixture task -- Mix 1')
        set(gca,'XTickLabel',{' ', Mix4, Mix3, Mix2, Mix1,' '})
        
        SoloParamHandle(obj,'mix2PropPlot', 'saveable', 0, 'value', axes('Position', [0.76 0.79 0.2 0.16]));
        set(value(mix2PropPlot),'xlim',[-5 0],'ylim', [0 100]); hold on
        ylabel('Number of trials')
%         xlabel('Concentration')
        title('Mixture task -- Mix 2')
        set(gca,'XTickLabel',{' ', Mix4, Mix3, Mix2, Mix1,' '})
        
       
    %%% sidePlot %%%
        SoloParamHandle(obj,'sideListPlot','value',plot(value(sidePlot),-1,0, ...
                        'LineStyle','none','MarkerSize',5,'Marker','o','Color','k',...
                        'MarkerFaceColor','k')); hold on
        SoloParamHandle(obj,'concListPlot','value',plot(value(sidePlot),-1,0, ...
                        'LineStyle','none','MarkerSize',10,'Marker','+','Color','k',...
                        'MarkerFaceColor','k')); hold on
        SoloParamHandle(obj,'mixListPlot','value',plot(value(sidePlot),-1,0, ...
                        'LineStyle','none','MarkerSize',10,'Marker','x','Color','k',...
                        'MarkerFaceColor','k')); hold on
        SoloParamHandle(obj,'incorrectPlot','value',plot(value(sidePlot),-1,0, ...
                        'LineStyle','none','MarkerSize',10,'Marker','o','Color','r',...
                        'MarkerFaceColor','None')); hold on
        SoloParamHandle(obj,'correctPlot','value',plot(value(sidePlot),-1,1, ...
                        'LineStyle','none','MarkerSize',10,'Marker','o','Color','g',...
                        'MarkerFaceColor','none')); hold on
        SoloParamHandle(obj,'choicePlot','value',plot(value(sidePlot),-1,1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','o','Color','b',...
                        'MarkerFaceColor','b')); hold on
        SoloParamHandle(obj,'too_latePlot','value',plot(value(sidePlot),-1,1, ...
                        'LineStyle','none','MarkerSize',10,'Marker','o','Color','k',...
                        'MarkerFaceColor','none')); hold on
        SoloParamHandle(obj,'premature_coutPlot','value',plot(value(sidePlot),-1,1, ...
                        'LineStyle','none','MarkerSize',10,'Marker','o','Color','y',...
                        'MarkerFaceColor','none'));hold on
        SoloParamHandle(obj,'premature_cout_go_signalPlot','value',plot(value(sidePlot),-1,1, ...
                        'LineStyle','none','MarkerSize',10,'Marker','o','Color','m',...
                        'MarkerFaceColor','none'));hold on
                    
        
        %%% biasConcPlot %%%
        SoloParamHandle(obj,'weightedBiasConcSessionPlot','value',plot(value(biasConcPlot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','m',...
                        'MarkerFaceColor','m')); hold on
                    
        SoloParamHandle(obj,'probOdor1SessionPlot','value',plot(value(biasConcPlot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','c',...
                        'MarkerFaceColor','c')); hold on
                    
        %%% biasMixPlot %%%
        SoloParamHandle(obj,'weightedBiasMixSessionPlot','value',plot(value(biasMixPlot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','m',...
                        'MarkerFaceColor','m')); hold on
                    
        SoloParamHandle(obj,'probMix1SessionPlot','value',plot(value(biasMixPlot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','c',...
                        'MarkerFaceColor','c')); hold on
                    
             
        %%% OSTOdor1Plot %%%
        SoloParamHandle(obj,'odorSampTimeOdor1Plot','value',plot(value(OSTOdor1Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','c',...
                        'MarkerFaceColor','c')); hold on
                    
        %%% OSTOdor2Plot %%%
        SoloParamHandle(obj,'odorSampTimeOdor2Plot','value',plot(value(OSTOdor2Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','m',...
                        'MarkerFaceColor','m')); hold on
                    
        %%% OSTMix1Plot %%%
        SoloParamHandle(obj,'odorSampTimeMix1Plot','value',plot(value(OSTMix1Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','c',...
                        'MarkerFaceColor','c')); hold on
                    
        %%% OSTMix2Plot %%%
        SoloParamHandle(obj,'odorSampTimeMix2Plot','value',plot(value(OSTMix2Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','m',...
                        'MarkerFaceColor','m')); hold on
                    
                    
                    
        %%% perfOdor1Plot %%%
        SoloParamHandle(obj,'performanceOdor1Plot','value',plot(value(perfOdor1Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','o','Color','c',...
                        'MarkerFaceColor','c')); hold on
                    
        %%% perfOdor2Plot %%%
        SoloParamHandle(obj,'performanceOdor2Plot','value',plot(value(perfOdor2Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','o','Color','m',...
                        'MarkerFaceColor','m')); hold on
                    
        %%% perfMix1Plot %%%
        SoloParamHandle(obj,'performanceMix1Plot','value',plot(value(perfMix1Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','o','Color','c',...
                        'MarkerFaceColor','c')); hold on
                    
        %%% perfMix2Plot %%%
        SoloParamHandle(obj,'performanceMix2Plot','value',plot(value(perfMix2Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','o','Color','m',...
                        'MarkerFaceColor','m')); hold on
                    
                    
        %%% MTOdor1Plot %%%
        SoloParamHandle(obj,'movTimeOdor1Plot','value',plot(value(MTOdor1Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','c',...
                        'MarkerFaceColor','c')); hold on
                    
        %%% MTOdor2Plot %%%
        SoloParamHandle(obj,'movTimeOdor2Plot','value',plot(value(MTOdor2Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','m',...
                        'MarkerFaceColor','m')); hold on
                    
        %%% MTMix1Plot %%%
        SoloParamHandle(obj,'movTimeMix1Plot','value',plot(value(MTMix1Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','c',...
                        'MarkerFaceColor','c')); hold on
                    
        %%% MTMix2Plot %%%
        SoloParamHandle(obj,'movTimeMix2Plot','value',plot(value(MTMix2Plot),-1,-1, ...
                        'LineStyle','none','MarkerSize',5,'Marker','.','Color','m',...
                        'MarkerFaceColor','m')); hold on
                    
                    
        %%% concPropPlot %%%
        SoloParamHandle(obj,'odor1ProportionPlot','value',bar(value(odor1PropPlot),0, 'group', 'c')); hold on
        
        SoloParamHandle(obj,'odor2ProportionPlot','value',bar(value(odor2PropPlot),0, 'group', 'm')); hold on
                        
        %%% mixPropPlot %%%
        SoloParamHandle(obj,'mix1ProportionPlot','value',bar(value(mix1PropPlot),0, 'group', 'c')); hold on
        
        SoloParamHandle(obj,'mix2ProportionPlot','value',bar(value(mix2PropPlot),0, 'group', 'm')); hold on

        
        
    case 'startPlot'
       
    %%% side plot
%         disp(value(sideList))
%         disp(length(value(sideList)))
        set(value(sideListPlot),'XData',1:length(value(sideList)),'YData',value(sideList));
        set(value(concListPlot),'XData',value(concList(:,1)),'YData',value(concList(:,2)));
        set(value(mixListPlot),'XData',value(mixList(:,1)),'YData',value(mixList(:,2)));

        set(value(probOdor1SessionPlot),'XData',value(probOdor1Session(:,1)),...
            'YData',value(probOdor1Session(:,2)));
        set(value(probMix1SessionPlot),'XData',value(probMix1Session(:,1)),...
            'YData',value(probMix1Session(:,2)));
 
        
        
    case 'next_trial'
        
    %%% side plot
        set(value(sideListPlot),'XData',1:length(value(sideList)),'YData',value(sideList));
        set(value(concListPlot),'XData',value(concList(:,1)),'YData',value(concList(:,2)));
        set(value(mixListPlot),'XData',value(mixList(:,1)),'YData',value(mixList(:,2)));
        set(value(premature_coutPlot),'XData',value(premature_cout(:,1)),'YData',value(premature_cout(:,2)));
        set(value(premature_cout_go_signalPlot),'XData',...
            value(premature_cout_go_signal(:,1)),'YData',value(premature_cout_go_signal(:,2)));
        set(value(too_latePlot),'XData',value(too_late(:,1)),'YData',value(too_late(:,2)));
        set(value(choicePlot),'XData',value(choice(:,1)),'YData',value(choice(:,2)));
        set(value(correctPlot),'XData',value(correct(:,1)),'YData',value(choice(:,2)));
        set(value(incorrectPlot),'XData',value(incorrect(:,1)),'YData',value(incorrect(:,2)));
        
        
    %%% biasConcPlot
        set(value(probOdor1SessionPlot),'XData',value(probOdor1Session(:,1)),...
            'YData',value(probOdor1Session(:,2)));
        set(value(weightedBiasConcSessionPlot),'XData',value(weightedBiasConcSession(:,1)),...
            'YData',value(weightedBiasConcSession(:,2)));
        
    %%% biasMixPlot
        set(value(probMix1SessionPlot),'XData',value(probMix1Session(:,1)),...
            'YData',value(probMix1Session(:,2)));
        set(value(weightedBiasMixSessionPlot),'XData',value(weightedBiasMixSession(:,1)),...
            'YData',value(weightedBiasMixSession(:,2)));
        
        
    %%% perfOdor1 plot
%     disp(value(stimVector)
%     disp(value(performance1))
        set(value(performanceOdor1Plot),'XData',value(stimVector),'YData',value(performanceOdor1));
        
    %%% perfOdor2 plot
        set(value(performanceOdor2Plot),'XData',value(stimVector),'YData',value(performanceOdor2));
        
    %%% perfMix1 plot
        set(value(performanceMix1Plot),'XData',value(stimVector),'YData',value(performanceMix1));
        
    %%% perfMix2 plot
        set(value(performanceMix2Plot),'XData',value(stimVector),'YData',value(performanceMix2));
        
        
        if n_started_trials < 1
            %%% OSTOdor1 plot
            set(value(odorSampTimeOdor1Plot),'XData',0,'YData',0);
            %%% OSTOdor2 plot
            set(value(odorSampTimeOdor2Plot),'XData',0,'YData',0);
            %%% OSTMix1 plot
            set(value(odorSampTimeMix1Plot),'XData',0,'YData',0);
            %%% OSTMix2 plot
            set(value(odorSampTimeMix2Plot),'XData',0,'YData',0);
            
            %%% MTOdor1 plot
            set(value(movTimeOdor1Plot),'XData',0,'YData',0);
            %%% MTOdor2 plot
            set(value(movTimeOdor2Plot),'XData',0,'YData',0);
            %%% MTMix1 plot
            set(value(movTimeMix1Plot),'XData',0,'YData',0);
            %%% MTMix2 plot
            set(value(movTimeMix2Plot),'XData',0,'YData',0);
            
            %%% concProportion plot
            set(value(odor1ProportionPlot),'YData',0);
            set(value(odor2ProportionPlot),'YData',0);
            %%% mixProportion plot
            set(value(mix1ProportionPlot),'YData',0);
            set(value(mix2ProportionPlot),'YData',0);
        else
            %%% OSTOdor1 plot
            set(value(odorSampTimeOdor1Plot),'XData',value(currentStimOdor1(1:n_started_trials, 2)), ...
                'YData',value(odorSamplingTimeOdor1Vector(1:n_started_trials)));
            %%% OSTOdor2 plot
            set(value(odorSampTimeOdor2Plot),'XData',value(currentStimOdor2(1:n_started_trials, 2)), ...
                'YData',value(odorSamplingTimeOdor2Vector(1:n_started_trials)));
            %%% OSTMix1 plot
            set(value(odorSampTimeMix1Plot),'XData',value(currentStimMix1(1:n_started_trials, 2)), ...
                'YData',value(odorSamplingTimeMix1Vector(1:n_started_trials)));
            %%% OSTMix2 plot
            set(value(odorSampTimeMix2Plot),'XData',value(currentStimMix2(1:n_started_trials, 2)), ...
                'YData',value(odorSamplingTimeMix2Vector(1:n_started_trials)));
            
            %%% MTOdor1 plot
            set(value(movTimeOdor1Plot),'XData',value(currentStimOdor1(1:n_started_trials, 2)), ...
                'YData',value(movementTimeOdor1Vector(1:n_started_trials)));
            %%% OSTOdor2 plot
            set(value(movTimeOdor2Plot),'XData',value(currentStimOdor2(1:n_started_trials, 2)), ...
                'YData',value(movementTimeOdor2Vector(1:n_started_trials)));
            %%% OSTMix1 plot
            set(value(movTimeMix1Plot),'XData',value(currentStimMix1(1:n_started_trials, 2)), ...
                'YData',value(movementTimeMix1Vector(1:n_started_trials)));
            %%% OSTMix2 plot
            set(value(movTimeMix2Plot),'XData',value(currentStimMix2(1:n_started_trials, 2)), ...
                'YData',value(movementTimeMix2Vector(1:n_started_trials)));
            
            %%% concProportion Plot
            set(value(odor1ProportionPlot),'XData', value(stimsTrialNOdor1), 'YData',value(stimProportionOdor1));
            set(value(odor2ProportionPlot),'XData', value(stimsTrialNOdor2), 'YData',value(stimProportionOdor2));
        
            %%% mixProportion Plot
            set(value(mix1ProportionPlot), 'XData', value(stimsTrialNMix1), 'YData',value(stimProportionMix1));
            set(value(mix2ProportionPlot), 'XData', value(stimsTrialNMix2), 'YData',value(stimProportionMix2));
        end
        

        if n_started_trials + 1 >= value(xAxisLim)
            i.value = value(i) + 1;
            set(value(sidePlot),'xlim',[value(i) n_started_trials + 2]); %hold on
            set(value(biasConcPlot),'xlim',[value(i) n_started_trials + 2]); %hold on
            set(value(biasMixPlot),'xlim',[value(i) n_started_trials + 2]); %hold on
        end

end;