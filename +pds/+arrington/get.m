function p = get(p)
%pds.arrington.get    get data samples from arrington
%
% p = pds.arrington.get(p)
% pds.a.getQueue pulls the values from the current Eyelink queue and
% puts them into the p.trial.eyelink struct
%
% 12/2013 jly   wrote it
% 2014    jk    adapted it for version 4.1
if p.trial.arrington.use && p.trial.arrington.useAsEyepos
    
    [p.trial.eyeX,p.trial.eyeY] = vpx_GetGazePoint;
    
    % 	if (p.trial.arrington.useAsEyepos)
    eyeIdx=p.trial.arrington.eyeIdx;
    
    eXY= p.trial.arrington.calibration_matrix(:,:,eyeIdx)*[p.trial.eyeX;p.trial.eyeY;1];
    p.trial.eyeX = eXY(1);
    p.trial.eyeY = eXY(2);
    % 	end
end