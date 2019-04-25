% Script for testing the default arguments / trialSetup
sca 

% --- setup pldaps and testing modules
settingsStruct = struct(); % settingsStruct is a structure that modifies pldaps default parameters

settingsStruct.pldaps.nosave = true; % don't save any files

settingsStruct.pldaps.useModularStateFunctions = true;
settingsStruct.pldaps.trialMasterFunction='runModularTrial';

% dot selection requires a fixation behavior
sn = 'calibration';
settingsStruct.(sn).stateFunction.name = 'defaultCalibrationTrial';
settingsStruct.(sn).stateFunction.order = 1;
settingsStruct.(sn).use = true;

settingsStruct.display.normalizeColor = 1;
settingsStruct.pldaps.pause.preExperiment = 0;

settingsStruct.session.subject = 'Mouse';

settingsStruct = loadCalibration(settingsStruct);
p = pldaps(@stimuli.pldapsDefaultTrial, settingsStruct);

p.run

