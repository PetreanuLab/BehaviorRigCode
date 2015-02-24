%% % fisher exact test

% plot fraction of Go/Wait/NoGo
s = {'Go','Wait','No Go'};
clear cond
icond = 1;
cond(icond).fsweep = { 'stimulation', 0};
cond(icond).Label = 'Control';
icond = 2;
cond(icond).fsweep = { 'stimulationCoordX',XY{1}(1),'stimulationCoordY',XY{1}(2),'stimulation', 1};
cond(icond).Label = num2str(XY{1});
icond = 3;
cond(icond).fsweep = { 'stimulationCoordX',XY{2}(1),'stimulationCoordY',XY{2}(2),'stimulation', 1};
cond(icond).Label = num2str(XY{2});

for icond = 1:length(cond)
    sw = licksFiltered.sweeps;
sw_ThisStimCoord =  filtbdata(sw,[],cond(icond).fsweep ); 
% probabilty of error
Ntrials(1,icond,:) = [sum(ismember(sw_ThisStimCoord.ChoiceCorrectGo,[0])) sum(sw_ThisStimCoord.ChoiceCorrectGo==1)];
Ntrials(2,icond,:) = [sum(ismember(sw_ThisStimCoord.ChoiceCorrectWait,[0])) sum(sw_ThisStimCoord.ChoiceCorrectWait==1)];
Ntrials(3,icond,:) = [sum(ismember(sw_ThisStimCoord.ChoiceCorrectNoGo,[0])) sum(sw_ThisStimCoord.ChoiceCorrectNoGo==1)];

end
perf = squeeze(Ntrials(:,2,:)./Ntrials(:,1,:)); % unstimulated, stimulated.


for icond = 2:length(cond) % for all none control compare to control
    cond(icond).Label
    for i=1:3 % each trialType
        s{i}
        a = Ntrials(i,1,1); % NoStim NoWait
        b = Ntrials(i,icond,1); % Stim NoWait
        c = Ntrials(i,1,1)+  Ntrials(i,1,2); % NoStim Wait
        d = Ntrials(i,icond,2)+  Ntrials(i,icond,2); % Stim Wait
        
        [~,Pneg(icond-1,i)] =         fisherextest(a,b,c,d);
%         s{i} = [s{i} ' pNeg ='  num2str(Pneg(i),'%1.1f')];
    end
end
% % PLOTTING

h = plotBarStackGroups(Ntrials,s );
 text( .8 *max(xlim), .9*max(ylim) ,num2str(Pneg,' %1.2f'));
 
title('Fisher Exact Test')
legend({'error','correct'},'Location','Best')
defaultAxes(gca)
ylabel('Trials')
% [Ppos,Pneg,Pboth]=fisherextest(a,b,c,d)
sAnn = sprintf('%s_%s_%s',licks.sweeps.Animal,'StimEffectOnPerformance', licks.sweeps.Date);
set(gcf,'Name','Fraction Correct')

fig = gcf;


plotAnn(sAnn, gcf );

 if bsave
%     r = brigdefs;
    sAnimal = licks.sweeps.Animal;
    savepath = fullfile('C:\Users\Bassam\Dropbox (Mainen Lab)\Bassam\BVA_MainenLab\Behavior\Data\HF_GoNoGoWait',sAnimal,'Licks');
    parentfolder(savepath,1);
%         export_fig(fig,fullfile(savepath,sAnn),'-pdf','-transparent')
    plot2svg(fullfile(savepath,[sAnn '.svg']),fig)
%     saveas(fig,fullfile(savepath,sAnn))
    disp([ 'saved to ' fullfile(savepath,sAnn)])
 end

 %Hazard rate?? change