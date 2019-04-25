function p = updateCalibrationMatrixFromGains(p)
% [gainX, gainY, offsetX, offsetY, theta] = calibrationMatrixToGains(C)
% Convert a calibration matrix to gains and offsets


s = p.trial.calibration.adjustment;

sinTh = sind(s.theta);
cosTh = cosd(s.theta);

R = [cosTh -sinTh; sinTh cosTh; 0 0] .* [s.gainX s.gainX; s.gainY s.gainY; 0 0];
S = [0 0; 0 0; s.offsetX s.offsetY];
C = R + S;

p.trial.calibration.adjustment.R = R;
p.trial.calibration.adjustment.S = S;
p.trial.calibration.adjustment.C = C;

p.trial.calibration.adjustment.xy = p.trial.calibration.adjustment.raw*p.trial.calibration.adjustment.C;

if p.trial.eyelink.use && p.trial.eyelink.useAsEyepos && p.trial.eyelink.useRawData
    if ~isfield(p.trial.eyelink, 'eyeIdx')
        eyeIdx = 1;
    else
        eyeIdx=p.trial.eyelink.eyeIdx;
    end
    
    p.trial.eyelink.calibration_matrix(:,:,eyeIdx) = C';
end

if p.trial.arrington.use && p.trial.arrington.useAsEyepos
    error('Not implemented')
end

if p.trial.ddpi.use && p.trial.arrington.useAsEyepos
    error('Not implemented')
end