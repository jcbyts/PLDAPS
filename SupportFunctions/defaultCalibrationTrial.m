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
        'trialSetup',...
        'frameUpdate',...
        'frameDraw',...
        'trialCleanUpandSave',...
        };
        stimuli.setupDefaultFrameStates(p, sn, requestedStates);
        stimuli.setupRandomSeed(p, sn);
        
        
%     %--------------------------------------------------------------------------
%     % --- After screen is open: Setup default parameters
%     case p.trial.pldaps.trialStates.experimentPostOpenScreen
        
        
    %--------------------------------------------------------------------------
    % --- Trial Setup: pre-allocate important variables for storage and
    % update the object
    case p.trial.pldaps.trialStates.trialSetup
        
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
        
        if ~isfield(p.trial.(sn), 'cm0') || isempty(p.trial.(sn).cm0)
            % check which eyetracker is being used
            if p.trial.eyelink.use && p.trial.eyelink.useAsEyepos
                p.trial.(sn).cm0 = p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx);
            elseif p.trial.arrington.use && p.trial.arrington.useAsEyepos
                p.trial.(sn).cm0 = p.trial.arrington.calibration_matrix(:,:,p.trial.arrington.eyeIdx);
            else
                p.trial.(sn).cm0 = [1 0; 0 1; 0 0];
            end
        end
        
        if isempty(p.trial.(sn).cm0)
            p.trial.(sn).cm0 = [1 0; 0 1; 0 0];
        end
        
        % targX, targY, eyeX, eyeY, distance
        p.trial.(sn).fixations = nan(4, p.trial.(sn).maxFixationsPerTrial);
        
        p.trial.(sn).iTarget = 1;
        p.trial.(sn).targets(p.trial.(sn).iTarget) = sampleTargets(p);
        
        p.trial.(sn).iFixation = 0;
        if ~isfield(p.trial.(sn), 'cm')
            p.trial.(sn).cm = p.trial.(sn).cm0;
        end
        
        disp('Running Calibration Trial')
        fprintf('f \tlabel fixation\n')
        fprintf('e \terase last fixation\n')
        fprintf('u \tupdate regression\n')
        fprintf('s \tsave calibration matrix to parameters\n')
        fprintf('t \trefresh targets\n')
        fprintf('esc \texit calibration and return to previoulsy scheduled trials\n')
	%--------------------------------------------------------------------------
    % --- Manage stimulus before frame draw
    case p.trial.pldaps.trialStates.frameUpdate
        
        p.trial.(sn).eyeRaw = p.trial.(sn).cm0 \ [p.trial.eyeX; p.trial.eyeY];
        
        rnd = randn(p.trial.(sn).targets(p.trial.(sn).iTarget).numShown,2);
        p.trial.(sn).targets(p.trial.(sn).iTarget).xPx = p.trial.(sn).targets(p.trial.(sn).iTarget).xPx + rnd(:,1);
        p.trial.(sn).targets(p.trial.(sn).iTarget).yPx = p.trial.(sn).targets(p.trial.(sn).iTarget).yPx + rnd(:,2);
        
        % Some standard PLDAPS key functions
        if any(p.trial.keyboard.firstPressQ)
            
            % [esc] exit calibration
            if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.escKey)
                
                p.trial.flagNextTrial = true;
                
            % [F] key - log fixation
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.fKey)
                
                % guess which target was fixated
                dist = sqrt((p.trial.eyeX - p.trial.(sn).targets(p.trial.(sn).iTarget).xPx).^2 + (p.trial.eyeY - p.trial.(sn).targets(p.trial.(sn).iTarget).yPx).^2);
                [~,fixatedTarget] = min(dist);
                
                p.trial.(sn).iFixation = p.trial.(sn).iFixation + 1;
                
                p.trial.(sn).fixations(:,p.trial.(sn).iFixation) = [p.trial.(sn).targets(p.trial.(sn).iTarget).xPx(fixatedTarget); p.trial.(sn).targets(p.trial.(sn).iTarget).yPx(fixatedTarget); ...
                    p.trial.eyeX; p.trial.eyeY];
                
                % give reward
                pds.behavior.reward.give(p)
                
                
            % [U] key - update calibration matrix
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.uKey)
                
                recursiveLeastSquaresUpdate(p, sn)
                
            % [T] key - update targets
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.tKey)
                
                p.trial.(sn).iTarget = p.trial.(sn).iTarget + 1;
                p.trial.(sn).targets(p.trial.(sn).iTarget) = sampleTargets(p);
                
            % [E] key - remove last fixation
            elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.eKey)
                
                p.trial.(sn).iFixation = p.trial.(sn).iFixation - 1;
                
                p.trial.(sn).cm = p.trial.(sn).cm0;
                
            end
        end
        
    %--------------------------------------------------------------------------
    % --- Draw the frame: Just call the hartley object's drawing method    
    case p.trial.pldaps.trialStates.frameDraw

        sz = abs(25*sin(bsxfun(@times, p.trial.ttime, p.trial.(sn).targets(p.trial.(sn).iTarget).sizeFreq) + p.trial.(sn).targets(p.trial.(sn).iTarget).sizePhase))'+1;
        clr = repmat(p.trial.(sn).targets(p.trial.(sn).iTarget).color(:), 1, 3)'; 
%         clr = rand(p.trial.(sn).targets(p.trial.(sn).iTarget).numShown, 3);
        Screen('DrawDots', p.trial.display.overlayptr, [p.trial.(sn).targets(p.trial.(sn).iTarget).xPx p.trial.(sn).targets(p.trial.(sn).iTarget).yPx]', sz, clr, [], 2);
        
        if p.trial.(sn).iFixation > 0
            Screen('DrawDots', p.trial.display.overlayptr, p.trial.(sn).fixations(3:4,1:p.trial.(sn).iFixation), 5, p.trial.display.clut.cursor, [], 0);
        end
        
        newEye = p.trial.(sn).cm * p.trial.(sn).eyeRaw;
        Screen('DrawDots', p.trial.display.overlayptr, newEye, 5, p.trial.display.clut.greenbg, [], 0);
            
    %--------------------------------------------------------------------------
    % --- After the trial: cleanup workspace for saving
    case p.trial.pldaps.trialStates.trialCleanUpandSave
        
        p.trial.(sn).fixations = p.trial.(sn).fixations(:, 1:p.trial.(sn).iFixation);
        
        p.trial.(sn).cm0 = p.trial.(sn).cm;
        
        figure(1); clf
        plot(p.trial.calibration.fixations(1,:), p.trial.calibration.fixations(2,:), 'o')
        
end


function recursiveLeastSquaresUpdate(p, sn)

% undo the existing calibration matrix
n = p.trial.(sn).iFixation;
xyRaw = p.trial.(sn).cm0 \ p.trial.(sn).fixations(3:4,1:n);
targXY = p.trial.(sn).fixations(1:2,1:n);

% yerror = (p.trial.(sn).fixations(1:2,1:n) - p.trial.(sn).fixations(3:4,1:n))';
% use Polyak averaging to approximate Minv


fun=@(c) sum(sqrt(sum((c*xyRaw - targXY).^2)));
opts=optimset('maxIter', 50, 'display', 'off');
p.trial.(sn).cm=fmincon(fun, p.trial.(sn).cm0,[],[],[],[],[],[],[],opts);

% p.trial.(sn).cm = rlsup(p.trial.(sn).cm0, targXY, xyRaw);

function cm = rlsup(cm, target, raw)
% try recursive least squares update instead of fmincon
learningRate = .1^size(raw,2);
yerr = (target - cm*raw);
cm = cm + learningRate*yerr*raw';


function targets = sampleTargets(p)
% sample target positions
targets = struct();

[xx, yy] = meshgrid(-10:5:10);
xy = pds.deg2px([xx(:) yy(:)]', p.trial.display.viewdist, p.trial.display.w2px);
targets.timeUpdated = GetSecs;
targets.gridX = xy(1,:)' + p.trial.display.ctr(1);
targets.gridY = xy(2,:)' + p.trial.display.ctr(2);
targets.numPossibleTargets = numel(xx);
targets.numShown = randi(targets.numPossibleTargets);
targets.targsShown = randsample(targets.numPossibleTargets, targets.numShown, false);

targets.xPx = targets.gridX(targets.targsShown);
targets.yPx = targets.gridY(targets.targsShown);

targets.sizePhase = rand(targets.numShown, 1) * 2 * pi;
targets.sizeFreq  = rand(targets.numShown, 1) * 10;
clutOptions = [p.trial.display.clut.blue(1), ...
    p.trial.display.clut.white(1), ...
    p.trial.display.clut.red(1), ...
    p.trial.display.clut.black(1)];
targets.color = randsample(clutOptions, targets.numShown, true);


