function defaultCalibrationTrial(p, state, sn)

if nargin<3
    sn='calibration';
end

switch state
        
    %--------------------------------------------------------------------------
    % --- Before Opening the screen: Setup the random seed and turn on the
    %     default pldaps frame states
    case p.trial.pldaps.trialStates.experimentPreOpenScreen
        
        requestedStates = {...
        'experimentPostOpenScreen',...
        'trialSetup',...
        'frameUpdate',...
        'frameDraw',...
        'trialCleanUpandSave',...
        };
        stimuli.setupDefaultFrameStates(p, sn, requestedStates);
        stimuli.setupRandomSeed(p, sn);
        
    %--------------------------------------------------------------------------
    % --- After screen is open: Setup default parameters
    case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        % --- set up default parameters
        defaultArgs = {...
            'maxFixationsPerTrial', 500, ...
            };
        
        % step through argument pairs and add them to the module
        for iArg = 1:2:numel(defaultArgs)
            
            field = defaultArgs{iArg};
            val   = defaultArgs{iArg+1};
            
            if ~isfield(p.trial.(sn), field)
                p.trial.(sn).(field) = val;
            end
        end
        
        % check which eyetracker is being used
        if p.trial.eyelink.use && p.trial.eyelink.useAsEyepos
            p.trial.(sn).cm0 = p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx);
        elseif p.trial.arrington.use && p.trial.arrington.useAsEyepos
            p.trial.(sn).cm0 = p.trial.arrington.calibration_matrix(:,:,p.trial.arrington.eyeIdx);
        else
            p.trial.(sn).cm0 = [1 0; 0 1; 0 0];
        end
    %--------------------------------------------------------------------------
    % --- Trial Setup: pre-allocate important variables for storage and
    % update the object
    case p.trial.pldaps.trialStates.trialSetup
        
        % targX, targY, eyeX, eyeY, distance
        p.trial.(sn).fixations = nan(4, p.trial.(sn).maxFixationsPerTrial);
        
        [xx, yy] = meshgrid(-10:5:10);
        xy = pds.deg2px([xx(:) yy(:)]', p.trial.display.viewdist, p.trial.display.w2px);
        p.trial.(sn).targets.gridX = xy(1,:)' + p.trial.display.ctr(1);
        p.trial.(sn).targets.gridY = xy(2,:)' + p.trial.display.ctr(2);
        p.trial.(sn).targets.numPossibleTargets = numel(xx);
        p.trial.(sn).targets.numShown = randi(p.trial.(sn).targets.numPossibleTargets);
        p.trial.(sn).targets.targsShown = randsample(p.trial.(sn).targets.numPossibleTargets, p.trial.(sn).targets.numShown, false);
        
        p.trial.(sn).targets.xPx = p.trial.(sn).targets.gridX(p.trial.(sn).targets.targsShown);
        p.trial.(sn).targets.yPx = p.trial.(sn).targets.gridY(p.trial.(sn).targets.targsShown);
        
        p.trial.(sn).targets.sizePhase = rand(p.trial.(sn).targets.numShown, 1) * 2 * pi;
        p.trial.(sn).targets.sizeFreq  = rand(p.trial.(sn).targets.numShown, 1) * 10;
        clutOptions = [p.trial.display.clut.blue(1), ...
            p.trial.display.clut.white(1), ...
            p.trial.display.clut.red(1), ...
            p.trial.display.clut.black(1)];
        p.trial.(sn).targets.color = randsample(clutOptions, p.trial.(sn).targets.numShown, true);
        
        p.trial.(sn).iFixation = 0;
        if ~isfield(p.trial.(sn), 'cm')
            p.trial.(sn).cm = p.trial.(sn).cm0;
        end
        
	%--------------------------------------------------------------------------
    % --- Manage stimulus before frame draw
    case p.trial.pldaps.trialStates.frameUpdate
        
        p.trial.(sn).eyeRaw = p.trial.(sn).cm0 \ [p.trial.eyeX; p.trial.eyeY]';
        
        rnd = randn(p.trial.(sn).targets.numShown,2);
        p.trial.(sn).targets.xPx = p.trial.(sn).targets.xPx + rnd(:,1);
        p.trial.(sn).targets.yPx = p.trial.(sn).targets.yPx + rnd(:,2);
        
        % Some standard PLDAPS key functions
        if any(p.trial.keyboard.firstPressQ)
            
            % [esc] exit calibration
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.escKey)
                
                p.trial.flagNextTrial = true;
                
            % [F] key - log fixation
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.fKey)
                
                % guess which target was fixated
                dist = sqrt((p.trial.eyeX - p.trial.(sn).targets.xPx).^2 + (p.trial.eyeY - p.trial.(sn).targets.yPx).^2);
                [~,fixatedTarget] = min(dist);
                
                p.trial.(sn).iFixation = p.trial.(sn).iFixation + 1;
                
                p.trial.(sn).fixations(:,p.trial.(sn).iFixation) = [p.trial.(sn).targets.xPx(fixatedTarget); p.trial.(sn).targets.yPx(fixatedTarget); ...
                    p.trial.eyeX; p.trial.eyeY];
                
                recursiveLeastSquaresUpdate(p, sn)
            
            % [E] key - remove last fixation
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.eKey)
                
                p.trial.(sn).iFixation = p.trial.(sn).iFixation - 1;
                
                p.trial.(sn).cm = p.trial.(sn).cm0;
                recursiveLeastSquaresUpdate(p, sn)
                
            end
        end
        
    %--------------------------------------------------------------------------
    % --- Draw the frame: Just call the hartley object's drawing method    
    case p.trial.pldaps.trialStates.frameDraw

        sz = abs(25*sin(bsxfun(@times, p.trial.ttime, p.trial.(sn).targets.sizeFreq) + p.trial.(sn).targets.sizePhase))'+1;
        clr = repmat(p.trial.(sn).targets.color(:), 1, 3)'; 
%         clr = rand(p.trial.(sn).targets.numShown, 3);
        Screen('DrawDots', p.trial.display.overlayptr, [p.trial.(sn).targets.xPx p.trial.(sn).targets.yPx]', sz, clr, [], 2);
        
        if p.trial.(sn).iFixation > 0
            Screen('DrawDots', p.trial.display.overlayptr, p.trial.(sn).fixations(3:4,1:p.trial.(sn).iFixation), 5, p.trial.display.clut.cursor, [], 0);
        end
        
        newEye = p.trial.(sn).cm * p.trial.(sn).eyeRaw;
        Screen('DrawDots', p.trial.display.overlayptr, newEye, 5, p.trial.display.clut.greenbg, [], 0);
            
    %--------------------------------------------------------------------------
    % --- After the trial: cleanup workspace for saving
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        p.trial.(sn).fixations = p.trial.(sn).fixations(:, 1:p.trial.(sn).iFixation);
        
        figure(1); clf
        plot(p.trial.calibration.fixations(1,:), p.trial.calibration.fixations(2,:), 'o')
        
end


function recursiveLeastSquaresUpdate(p, sn)

% undo the existing calibration matrix
n = p.trial.(sn).iFixation;
xyRaw = p.trial.(sn).cm \ p.trial.(sn).fixations(3:4,1:n);

yerror = (p.trial.(sn).fixations(1:2,1:n) - p.trial.(sn).fixations(3:4,1:n))';
% use Polyak averaging to approximate Minv
p.trial.(sn).cm = p + (n^-.5/n) * (xyRaw * yerror)';

