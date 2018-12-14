function runStateforModules(p, state, modules, moduleFunctionHandles, moduleRequestedStates, moduleLocationInputs)

%using cellfun might be slower than a for loop and does not guaranty
%execution in order of the arrays. Not sure if save. Ideally it would be
%     cellfun(@(x) x(p, p.trial.pldaps.trialStates.(state)), modules(moduleRequestedStates.(state)));

% tmpModules = moduleRequestedStates.(state);
% for iModule = find(tmpModules(:))'
for iModule = moduleRequestedStates.(state)
%     t0 = GetSecs;
%     fprintf('%s %s\n', modules{iModule}, state);
%     p.trial.spatialSquares.hSquares.stimValue
    if moduleLocationInputs(iModule)
        moduleFunctionHandles{iModule}(p, p.trial.pldaps.trialStates.(state), modules{iModule});
    else
        moduleFunctionHandles{iModule}(p, p.trial.pldaps.trialStates.(state));
    end
%     p.trial.spatialSquares.hSquares.stimValue
%     t1 = GetSecs;
%     fprintf('%s %s took %02.2f seconds\n', modules{iModule}, state, t1-t0)
end