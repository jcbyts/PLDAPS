function initializeSession(p)
% initializeSession cleans up PTB, sets the screen verbosity, checks if
% this pldaps has already been run, saves the time

% --- clean IOPort handles
%     no PTB method to retrieve previously opened IOPort handles, so might
%     as well clean slate
IOPort('CloseAll');
if ~isfield(p.trial.pldaps,'verbosity')
    p.trial.pldaps.verbosity = 3;
end
Screen('Preference','Verbosity', p.trial.pldaps.verbosity);
IOPort('Verbosity', p.trial.pldaps.verbosity-1); % quieter
PsychPortAudio('Verbosity', p.trial.pldaps.verbosity-1); % quieter

% Each PLDAPS instance can only be run once. Abort if it appears this has already occurred
if isField(p.defaultParameters, 'session.initTime')
    warning('pldaps:run', 'pldaps objects appears to have been run before. A new pldaps object is needed for each run');
    return
end

p.defaultParameters.session.initTime=now;
p.defaultParameters.pldaps.iTrial = 0; % necessary here to place iTrial counter in SessionParameters level of params hierarchy