function p = get(p)
%pds.eyelink.get   get data samples from eyelink


if p.trial.eyelink.use && p.trial.eyelink.useAsEyepos
    
    sample=Eyelink('NewestFloatSample');
    
    eXY = p.trial.eyelink.calibration_matrix(:,:,p.trial.eyelink.eyeIdx)*[sample.px(p.trial.eyelink.eyeIdx); sample.py(p.trial.eyelink.eyeIdx); 1];
    p.trial.eyeX = eXY(1);
    p.trial.eyeY = eXY(2);
end