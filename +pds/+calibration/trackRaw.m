function p = trackRaw(p)
% undo calibration matrix for whatever input is used as the eye position
% and track it

if p.trial.eyelink.use && p.trial.eyelink.useAsEyepos && p.trial.eyelink.useRawData
    if ~isfield(p.trial.eyelink, 'eyeIdx')
        eyeIdx = 1;
    else
        eyeIdx=p.trial.eyelink.eyeIdx;
    end
    C = p.trial.eyelink.calibration_matrix(:,:,eyeIdx)';
    raw =  p.trial.behavior.eyeAtFrame(:,p.trial.iFrame);
    % undo offset
    raw(1) = raw(1) - C(3,1);
    raw(2) = raw(2) - C(3,2);
    % undo gains / rotation
    raw = C(1:2,1:2)\raw;
    raw = raw';
    
    % store raw
    p.trial.calibration.adjustment.raw(p.trial.iFrame,:) = [raw 1];
end

if p.trial.arrington.use && p.trial.arrington.useAsEyepos
    error('Not implemented')
end

if p.trial.ddpi.use && p.trial.arrington.useAsEyepos
    error('Not implemented')
end

% re-apply calibration
if p.trial.iFrame > 1
    p.trial.calibration.adjustment.xy = p.trial.calibration.adjustment.raw(1:p.trial.iFrame-1,:)*p.trial.calibration.adjustment.C;
end
    
return
% %% debug
% 
% if ~isfield(p.trial.eyelink, 'eyeIdx')
%     eyeIdx = 1;
% else
%     eyeIdx=p.trial.eyelink.eyeIdx;
% end
% C = p.trial.eyelink.calibration_matrix(:,:,eyeIdx)';
% raw =  p.trial.behavior.eyeAtFrame(:,1:p.trial.iFrame);
% raw(1,:) = raw(1,:) - C(3,1);
% raw(2,:) = raw(2,:) - C(3,2);
% raw = C(1:2,1:2)\raw;
% raw = raw';
% % raw = raw'*inv(C(1:2,1:2));
% xy = [raw ones(p.trial.iFrame,1)]*p.trial.calibration.adjustment.C;
%     
% figure(1); clf
% plot(p.trial.behavior.eyeAtFrame'); hold on
% % plot(raw)
% % plot(xy, '.')
% plot(p.trial.calibration.adjustment.xy, 'o')
