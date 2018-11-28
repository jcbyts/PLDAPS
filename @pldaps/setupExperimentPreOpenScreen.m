function setupExperimentPreOpenScreen(p)


% Establish list of all module names
p.trial.pldaps.modNames.all = getModules(p, 0);

%experimentSetup before openScreen to allow modifyiers
onlyActive = false; % use all modules
[moduleNames, moduleFunctionHandles, moduleRequestedStates, moduleLocationInputs] = getModules(p, onlyActive);

% run all modules state experimentPreOpenScreen
moduleRequestedStates.experimentPreOpenScreen = 1:numel(moduleNames);

runStateforModules(p,'experimentPreOpenScreen', moduleNames, moduleFunctionHandles, moduleRequestedStates, moduleLocationInputs);
