function I = replayTrial(PDS, trialIdx, varargin)
%% setup parameters

ip = inputParser();
ip.addParameter('ROI', [])
ip.addParameter('gazeContingent', false)
ip.addParameter('frameIndex', [])
ip.addParameter('showOverlay', true)
ip.addParameter('writeToFile', false)
ip.parse(varargin{:});

sca

args = ip.Results;

if nargin < 2
    trialIdx = 1;
end

if numel(PDS) > 1
    trial = PDS;
else
    trial = pds.getPdsTrialData(PDS);
end

% --- create params object to initialize with
defaults{1}=trial(1);
defaultsNames{1}=sprintf('defaults');

pa=params(defaults,defaultsNames);

% modify display parameters so the screen opens on this machine
pa.display.scrnNum    = max(Screen('Screens'));

% move the screen off screen
pa.display.screenSize = pa.display.winRect + [1e3 0 1e3 0];
pa.datapixx.use               = false;
pa.display.useOverlay         = 0;

% show overlay
if args.showOverlay
    pa.display.switchOverlayCLUTs = 1;
else
    pa.display.switchOverlayCLUTs = 0;
end

% setup pldaps object
p = pldaps;
p.defaultParameters=pa;
p.trial=pa;

% open screen
p.openScreen

% experimentPostOpenScreen
onlyActive = false; % run all modules post open screen routines
[moduleNames,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs] = getModules(p, onlyActive);
runStateforModules(p,'experimentPostOpenScreen',moduleNames,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs);

% turn off all devices -- we're not using them
paS = struct();
paS.eyelink.use = false;
paS.sound.use = false;
paS.newEraSyringePump.use = false;

paS.display.scrnNum = max(Screen('Screens'));
paS.display.useOverlay = 0;
paS.display.switchOverlayCLUTs = 1;
paS.display.overlayptr = pa.display.ptr;
paS.pldaps.draw.framerate.use = 0; % turn off framerate
paS.datapixx.use = false;

paS.reward = marmoview.dbgreward(1);

%%

if isempty(args.ROI)
    args.ROI = pa.display.winRect;
end
    
nTrials = numel(trialIdx);

I = cell(nTrials,1);

for ii = 1:nTrials
    iTrial = trialIdx(ii);

    p.trial = mergeStruct(trial(iTrial), paS);

    p.data=arrayfun(@(x) x, trial, 'uni', false); %PDS.data;
    p.trial.sound.use=0;
    p.trial.iFrame=1;
    p.trial.pldaps.draw.grid.use=0;
    p.trial.pldaps.draw.cursor.use=0;
    p.trial.pldaps.iTrial = iTrial;

    % fix colors
    fn = fieldnames(p.trial.display.clut);
    p.trial.display.clut = trial(iTrial).display.clut; % take what was shown
    for i = 1:numel(fn)
        p.trial.display.clut.(fn{i}) = p.trial.display.humanCLUT(p.trial.display.clut.(fn{i})(1)+1,:);
    end

    showWin = false;
%     if ~args.showOverlay
%         p.trial.stimulus.stateFunction.requestedStates.frameDraw = false;
%     end
    if ~isempty(ip.Results.frameIndex)
        if ip.Results.writeToFile
            fname = strrep(p.trial.session.file, '.PDS', sprintf('_trial%d', iTrial));
            replayModularTrialRoi(p,args.ROI, args.gazeContingent, showWin, ip.Results.frameIndex, false, fname);
            I2 = [];
        else
            I2=replayModularTrialRoi(p,args.ROI, args.gazeContingent, showWin, ip.Results.frameIndex);
        end
    else
        if ip.Results.writeToFile
            fname = strrep(p.trial.session.file, '.PDS', sprintf('_trial%d', iTrial));
            replayModularTrialRoi(p,args.ROI, args.gazeContingent, showWin, [], false, fname);
            I2 = [];
        else
            I2=replayModularTrialRoi(p,args.ROI, args.gazeContingent, showWin);
        end
    end

    I{ii} = I2;
end

sca

return
% [I,I2]=replayModularTrial(p,[0 0 200 200], true, showWin, [100 1100]);

% sca
%
% figure(1); clf
% for k=1:size(I,4)
% imagesc(I2(:,:,:,k)); drawnow; pause(.015)
% end


%% draw full screen

fname='hartley_mov1.mp4';

% Prepare the new file.
if exist(fname, 'file')
    delete(fname)
end

vidObj = VideoWriter(fname, 'MPEG-4'); %'Uncompressed AVI');   
vidObj.Quality = 100;
vidObj.FrameRate=60;

open(vidObj);

% delayTime = 1/60; %Screen refresh rate of 60Hz
for i = 1:size(I,4)
    % Gifs can't take RBG matrices: they have to be specified with the
    % pixels as indices into a colormap
    % See the help for imwrite for more details
%     [y, newmap] = cmunique(imageArray{i});
    
    %Creates a .gif animation - makes first frame, then appends the rest
%     if i==1
%         imwrite(y, newmap, 'Zero Phase.gif');
%     else
%         imwrite(y, newmap, 'Zero Phase.gif', 'DelayTime', delayTime, 'WriteMode', 'append');
%     end

    currFrame = struct('cdata', squeeze(I2(:,:,:,i)), 'colormap', []);
    writeVideo(vidObj,currFrame);
end

% Close the file.
close(vidObj);

return
%%


%% draw clipped
fname='mov2.mp4';

% Prepare the new file.
if exist(fname, 'file')
    delete(fname)
end

vidObj = VideoWriter(fname, 'MPEG-4'); %'Uncompressed AVI');   
vidObj.Quality = 100;
vidObj.FrameRate=60;

open(vidObj);

% delayTime = 1/60; %Screen refresh rate of 60Hz
for i = 1:size(I,4)
    % Gifs can't take RBG matrices: they have to be specified with the
    % pixels as indices into a colormap
    % See the help for imwrite for more details
%     [y, newmap] = cmunique(imageArray{i});
    
    %Creates a .gif animation - makes first frame, then appends the rest
%     if i==1
%         imwrite(y, newmap, 'Zero Phase.gif');
%     else
%         imwrite(y, newmap, 'Zero Phase.gif', 'DelayTime', delayTime, 'WriteMode', 'append');
%     end

    currFrame = struct('cdata', squeeze(I2(:,:,:,i)), 'colormap', []);
    writeVideo(vidObj,currFrame);
end

% Close the file.
close(vidObj);
