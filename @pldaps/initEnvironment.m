function initEnvironment(p)

% Setup Photodiode stimuli
%-------------------------------------------------------------------------%
if(p.trial.pldaps.draw.photodiode.use)
    makePhotodiodeRect(p);
end

% Tick Marks
%-------------------------------------------------------------------------%
if(p.trial.pldaps.draw.grid.use)
    initTicks(p);
end

% Codebase / version control
%-------------------------------------------------------------------------%
%get and store changes of current code to the git repository
pds.git.setup(p);

% Eye tracking
%-------------------------------------------------------------------------%
pds.eyelink.setup(p);
pds.arrington.setup(p);

% Audio
%-------------------------------------------------------------------------%
pds.audio.setup(p);

% PLEXON
%-------------------------------------------------------------------------%
pds.plexon.spikeserver.connect(p);

% REWARD
%-------------------------------------------------------------------------%
pds.behavior.reward.setup(p);

% Initialize Datapixx including dual CLUTS and timestamp
% logging
pds.datapixx.init(p);

% HID
pds.keyboard.setup(p);

if p.trial.mouse.useLocalCoordinates
    p.trial.mouse.windowPtr=p.trial.display.ptr;
end
if ~isempty(p.trial.mouse.initialCoordinates)
    SetMouse(p.trial.mouse.initialCoordinates(1),p.trial.mouse.initialCoordinates(2),p.trial.mouse.windowPtr);
end