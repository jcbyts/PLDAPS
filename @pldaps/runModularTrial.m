function p = runModularTrial(p)
%runModularTrial    runs a single Trial by calling the functions defined in 
%            their substruct (found by pldaps.getModules) and the function
%            defined in p.trial.pldaps.trialFunction through different states
%




% -- Get Modules
[modules,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs] = getModules(p);

% --- Order Modules
% order the framestates that we will iterate through each trial by their 
% value only positive states are frame states. And they will be called in
% order of the value. Check comments in pldaps.getReorderedFrameStates
% for explanations of the default states negative states are special states
% outside of a frame (trial, experiment, etc)
[stateValue, stateName] = p.getReorderedFrameStates(p.trial.pldaps.trialStates,moduleRequestedStates);
nStates=length(stateValue);

% --- Trial Setup
runStateforModules(p,'trialSetup',modules,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs);


% switch to high priority mode
if p.trial.pldaps.maxPriority
    oldPriority=Priority;
    maxPriority=MaxPriority('GetSecs');
    if IsWin % 1 = High. Priority(2) will return 1.
        maxPriority = 1;
    end
    
    if oldPriority < maxPriority
        Priority(maxPriority);
    end
end

% --- TrialPrepare is a Time Critical state
runStateforModules(p,'trialPrepare',modules,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs);

%%% MAIN WHILE LOOP %%%
%-------------------------------------------------------------------------%
while ~p.trial.flagNextTrial && p.trial.pldaps.quit == 0
    % go through one frame by calling the modules with the different states.
    % Save the times each state is finished.
    
    % advance to next frame, update frame index
    p.trial.iFrame = p.trial.iFrame + 1;
    
    % time of the estimated next flip
    p.trial.nextFrameTime = p.trial.stimulus.timeLastFrame + p.trial.display.ifi;
    
    % iterate through frame states
    for iState=1:nStates
        runStateforModules(p,stateName{iState},modules,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs);
        
        p.trial.ttime = GetSecs - p.trial.trstart;
        
        p.trial.remainingFrameTime = p.trial.nextFrameTime -p.trial.ttime;
        p.trial.timing.frameStateChangeTimes(p.trial.pldaps.trialStates.(stateName{iState}),p.trial.iFrame) = p.trial.ttime-p.trial.nextFrameTime+p.trial.display.ifi;
    end
    
end %while Trial running

% trialItiDraw
%  ** Inherently not a time-critical operation, so no call to setTimeAndFrameState necessary
%   ...also, setTimeAndFrameState uses current state as an index, so using with this would break
runStateforModules(p, 'trialItiDraw', modules, moduleFunctionHandles, moduleRequestedStates, moduleLocationInputs);

% return to pre-trial thread priority
if p.trial.pldaps.maxPriority
    newPriority=Priority;
    if round(oldPriority) ~= round(newPriority)
        Priority(oldPriority);
    end
    if round(newPriority)<maxPriority
        warning('pldaps:runTrial','Thread priority was degraded by operating system during the trial.')
    end
end

% --- Trial Cleanup
runStateforModules(p,'trialCleanUpandSave',modules,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs);
