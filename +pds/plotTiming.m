function tdat = plotTiming(p, plotStateTimes)

if nargin<2
    plotStateTimes = false;
end

if nargin<1
    fprintf(2, 'Functionified! %s needs pldaps ''p'' struct or PDS struct input; returns handle to histo. Try:\n\t h = plotTiming(p)\n',mfilename);
    evalin('caller', 'h = plotTiming(p)');
    return
end

% Deal with inconsistencies btwn pldaps obj/structs and PDS structures.
renderTimesToo = isfield(p.data{1},'frameRenderTime');
if isfield(p, 'trial')
    ifi = p.trial.display.ifi;    
elseif isfield(p, 'initialParametersMerged')
    % From a saved PDS (...vomit worthy fieldname)
    p.trial = p.initialParametersMerged;
    ifi = p.trial.display.ifi;
else
    % crash probably coming, but try anyway
    ifi = 1/120; % assume 120 hz
end
ifi = ifi*1000; % msec
dropThresh = 1.1*ifi;

% Skip over incomplete trials
try
    goodtr = cellfun(@(x) logical(x.pldaps.goodtrial), p.data);
catch
    goodtr = true(size(p.data));
end
trData = p.data(goodtr);

% Max common frame count
minf = min(cellfun(@(x) x.iFrame, trData));

% fliptimes btwn frames (msec)
ftd = 1000* cell2mat(cellfun(@(x) diff(x.timing.flipTimes(3,1:minf)), trData, 'uni',0)');
drops = sum(ftd(:) >= dropThresh);

%% Plot fliptimes
% Figure layout
spy = 2; spx = 1+renderTimesToo;
cl = ifi*[.75,4.25]; % clim
cm = [.85*[1 1 1]; 1 1 1; 0 0 0; 1 0 0]; % missed frame colormap
pbaspect = [2,1,1];

figure;%(1),clf,
% Plot fliptimes & drops
subplot(spy, spx, 1);
imagesc(ftd);
title( {p.trial.session.file, sprintf('FlipTimes;  %d/%d dropped (%2.3f%%)', drops, numel(ftd), drops/numel(ftd)*100)} );
xlabel('frame #'), ylabel('trial')
set(gca,'plotboxaspectratio',pbaspect, 'clim',cl, 'tickdir','out');  box off
colormap(gca, cm); cb = colorbar; ylabel(cb, 'msec')

subplot(spy, spx, spx+1)
[~,didx] = find(ftd >= dropThresh);
histogram( didx, floor(minf/10)+1, 'BinLimits',[1,size(ftd,2)], 'Normalization','probability')
title('Dropped frames by time');
xlabel('frame #'), ylabel('prop. total drops')
set(gca,'plotboxaspectratio',pbaspect); box off; grid on;

% Outputs
if nargout>0
    % avoid accidentally dumping all outputs into command window
    tdat.goodtr = goodtr;
    tdat.ftd = ftd;
end


%% Plot frame rendertime (if available)
if renderTimesToo
    % render time/frame (msec)
    fr = 1000* cell2mat(cellfun(@(x) x.frameRenderTime(1:minf), trData, 'uni',0)');
    
    % Plot render times
    subplot(spy, spx, 2);
    imagesc(fr);
    title('RenderTimes')
    xlabel('frame #'), ylabel('trial')
    set(gca,'plotboxaspectratio',pbaspect, 'clim',prctile(fr(:),[10, 99.9]), 'tickdir','out'); box off
    colormap(gca, flipud(hot)); cb = colorbar; ylabel(cb, 'msec')
    
    subplot(spy, spx, 4);
    h = histogram(diff(fr,[],2), 'BinLimits',.5*[-1,1], 'Normalization','probability');
    title('inter-frame rendering deltas'); xlabel('msec');
    set(gca,'plotboxaspectratio',pbaspect); box off; grid on;

    % outputs
    if nargout>0
        tdat.fr = fr;
    end
end

%% plot individual trial state transition time
if plotStateTimes
    figure;
    
    nTrials = numel(trData);
    for k = 1:nTrials
        subplot(2,1,1)
        plot(trData{k}.timing.frameStateChangeTimes(p.trial.pldaps.trialStates.frameFlip,:)*1000, '-'); hold on
        
        
        subplot(2,1,2)
        plot(trData{k}.timing.frameStateChangeTimes(1,:)*1000, '-'); hold on
        xlabel('Frame #')
        ylabel('milliseconds')
    end
end

subplot(2,1,1)
plot(xlim, p.trial.display.ifi*1e3*[1 1], 'k--')
axis tight
yd = ylim;
ylim([0 yd(2)])
xlabel('Frame #')
ylabel('milliseconds')
title('Flip Time')

subplot(2,1,2)
plot(xlim, p.trial.display.ifi*1e3*[1 1], 'k--')
axis tight
yd = ylim;
ylim([0 yd(2)])
xlabel('Frame #')
ylabel('milliseconds')
title('Minimum Non Drawing Time (Large values here reflect OS or drawing failures)')


