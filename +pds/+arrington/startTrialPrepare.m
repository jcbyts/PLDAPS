function p = startTrialPrepare(p)
%pds.eyelink.startTrialPrepare   prepare the next trial
%
% gets and eylink time estimate and send a TRIALSTART message to eyelink
%
% p = startTrialPrepare(p)

if p.trial.arrington.use
    p.trial.timing.arringtonStartTime = vpx_GetDataTime(0);
    vpx_SendCommandString(sprintf('dataFile_InsertString "TRIALSTART:TRIALNO:%i"',p.trial.pldaps.iTrial));
end
 