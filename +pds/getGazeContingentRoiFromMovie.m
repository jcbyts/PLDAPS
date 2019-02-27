function [I, frameTimes] = getGazeContingentRoiFromMovie(PDS, ROI)
% I = getGazeContingentRoiFromMovie(PDS, ROI)

trial = pds.getPdsTrialData(PDS);

sn = 'HDmovies';
hasField = find(arrayfun(@(x) ~isempty(x.(sn)), trial));

validTrials = hasField(arrayfun(@(x) x.(sn).use==1, trial(hasField)));

movieFileTrial = arrayfun(@(x) x.(sn).moviefilename, trial(validTrials), 'uni', 0);
moviefiles     = unique(movieFileTrial);

nMov = numel(moviefiles);

fprintf('Found %d unique movies\n', nMov)

nTrials = numel(validTrials);
I = cell(nTrials,1);
frameTimes = cell(nTrials,1);

mem = memory;
memav = mem.MemAvailableAllArrays/1024/1024/1024;
useSlowVersion = memav < 50;

for iMov = 1:nMov
    
    idxMovie = find(strcmp(movieFileTrial, moviefiles{iMov}));
    thisMovieTrials = validTrials(idxMovie);
    
    fname = fullfile(getpref('pep', trial(thisMovieTrials(1)).(sn).moviedatabase), trial(thisMovieTrials(1)).(sn).moviefilename);
    obj = VideoReader(fname);
    
    if ~useSlowVersion
        % memory intensive version
        fprintf('Reading Movie...')
        tic
        nMaxFrames = max(arrayfun(@(x) numel(x.behavior.eyeAtFrame(1,:)), trial(thisMovieTrials)));
        nMaxFrames = min(round(obj.Duration*obj.FrameRate), nMaxFrames);
        Itrial = squeeze(mean(read(obj, [1 nMaxFrames]), 3));
        fprintf('[%02.2f]\n', toc)
    end
    
    nMovieTrial = numel(idxMovie);
    for iTrial = 1:nMovieTrial
        
        fprintf('%d/%d trials\n', iTrial, nMovieTrial)
        thisTrial = thisMovieTrials(iTrial);
        
        eyex = trial(thisTrial).behavior.eyeAtFrame(1,:);
        eyey = trial(thisTrial).behavior.eyeAtFrame(2,:);
        
        nFrames = numel(eyex);
        
        
        if ~useSlowVersion
            xx = ROI(1):ROI(3); yy = ROI(2):ROI(4);
            dims = [numel(xx) numel(yy)];
            I{idxMovie(iTrial)} = zeros(dims(2), dims(1), nFrames);
            frameTimes{idxMovie(iTrial)} = PDS{1}.PTB2OE(trial(thisTrial).timing.flipTimes(1,:));
            
            fprintf('Looping over frames, clipping gaze contingent ROI...')
            tic
            for iFrame = 1:nFrames
                if trial(thisTrial).HDmovies.frameShown(iFrame) >= 0
                    thisFrame = round(trial(thisTrial).HDmovies.frameShown(iFrame)*obj.FrameRate);
                    thisFrame = max(thisFrame, 1); % greater than 0
                end
                
                x0 = round(eyex(iFrame));
                y0 = round(eyey(iFrame));
                
                if thisFrame > nMaxFrames
                    I_ = zeros(size(Itrial,1), size(Itrial,2));
                else
                    I_ = squeeze(Itrial(:,:,thisFrame));
                end
                xi = x0+xx;
                yi = y0+yy;
                validx = ~ (( xi <= 0 ) | (xi > size(I_,2)));
                validy = ~ (( yi <= 0 ) | (yi > size(I_,1)));
                I{idxMovie(iTrial)}(validy,validx,iFrame) = I_(yi(validy), xi(validx));
                
                % debugging
%                 hold off
%                 imagesc(I_); colormap gray
%                 hold on
%                 plot(x0, y0, 'ro')
%                 imagesc(I{idxMovie(iTrial)}(validy,validx,iFrame))
%                 drawnow
            end
            fprintf('[%02.2f]\n', toc)
            
        else
            %much slower version
            xx = ROI(1):ROI(3); yy = ROI(2):ROI(4);
            dims = [numel(xx) numel(yy)];
            I{idxMovie(iTrial)} = zeros(dims(2), dims(1), nFrames);
            frameTimes{idxMovie(iTrial)} = PDS{1}.PTB2OE(trial(thisTrial).timing.flipTimes(1,:));
            
            for iFrame = 1:nFrames
                
                fprintf('%d/%d\n', iFrame, nFrames)
                if trial(thisTrial).HDmovies.frameShown(iFrame) >= 0
                    obj.CurrentTime = trial(thisTrial).HDmovies.frameShown(iFrame);
                    frame = obj.readFrame();
                    continue
                end
                
                I_ = mean(frame,3);
                
                x0 = round(eyex(iFrame));
                y0 = round(eyey(iFrame));
                
                xi = x0+xx;
                yi = y0+yy;
                validx = ~ (( xi <= 0 ) | (xi > size(I_,2)));
                validy = ~ (( yi <= 0 ) | (yi > size(I_,1)));
                I{idxMovie(iTrial)}(validy,validx,iFrame) = I_(yi(validy), xi(validx));
            end
        end
    end
    
    
end

return
%% Make Movie Demos
for iMovie = 3:-1:1
thisMovieIdx = validTrials(strcmp(movieFileTrial, moviefiles{iMovie}));

nTrials = numel(thisMovieIdx);

% load the movie object into memory
thisTrial = thisMovieIdx(1); % get the first trial this movie plays
fname = fullfile(getpref('pep', trial(thisTrial).(sn).moviedatabase), trial(thisTrial).(sn).moviefilename);
obj = VideoReader(fname);

[eyedata, timestamps] = io.getEyeData(thisSession, PDS);



ppd = trial(1).display.ppd;
ctr = trial(1).display.ctr(1:2);
eyex = arrayfun(@(x) x.behavior.eyeAtFrame(1,:), trial(thisMovieIdx), 'uni', 0);
eyey = arrayfun(@(x) x.behavior.eyeAtFrame(2,:), trial(thisMovieIdx), 'uni', 0);
idx = cellfun(@numel, eyex) ~= mode(cellfun(@numel, eyex));
eyex(idx) = [];
eyey(idx) = [];


tmpstr = strrep(moviefiles{iMovie}(1:5), ' ', '_');
fname = ['eyepos_' tmpstr];
if exist(fname, 'file')
    delete(fname)
end

vidObj = VideoWriter(fullfile(pwd, fname));
vidObj.Quality = 100;
vidObj.FrameRate=120;
open(vidObj);

f = figure(1); clf
f.Position = [0 0 1920 1080];
for iFrame = 1:numel(eyex{1})
    
    thisTrial = thisMovieIdx(iTrial);
    trial(thisTrial);
    
    if trial(thisTrial).HDmovies.frameShown(iFrame) <= 0
        continue
    end
    obj.CurrentTime = trial(thisTrial).HDmovies.frameShown(iFrame);
    frame = obj.readFrame();
    hold off
    imagesc(frame); hold on
    plot(cellfun(@(x) x(iFrame), eyex), cellfun(@(x) x(iFrame), eyey), '.', 'MarkerSize', 10, 'Color', 'c')
    
    currFrame = getframe(gca);
    
    writeVideo(vidObj,currFrame);
end

close(vidObj)
close all
end
%%





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

    
end

% Close the file.
close(vidObj);

%%
iFrame = 0;

iFrame = iFrame + 1;
obj.CurrentTime = trial(thisTrial).HDmovies.frameShown(iFrame);
frame = obj.readFrame();

imagesc(mean(frame,3)); colormap gray