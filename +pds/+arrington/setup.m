function p = setup(p)
%pds.arrington.setup    setup arrington at the beginning of an experiment
%
% p = pds.arrington.setup(p)
% Setup PLDAPS to use VPX toolbox
%
% 2018-08-09  JLY   wrote it

if p.trial.arrington.use
    
    fprintLineBreak;
    fprintf('\tSetting up ARRINGTON Toolbox for eyetrace. \n');
    fprintLineBreak;
    
    
    vpx_Initialize(); % load the ViewPoint libray
    vpx_SendCommandString('datafile_AsynchStringData Yes');
    vpx_SendCommandString('dataFile_UnPauseUponClose True');
    
    [~, fname, ~] = fileparts(p.trial.session.file);
    p.trial.arrington.vpxFile = sprintf('%s.vpx', fname);
    
    filename = fullfile(p.trial.session.dir, p.trial.arrington.vpxFile);
    vpx_SendCommandString(sprintf('dataFile_NewName "%s"',filename));
    vpx_SendCommandString('dataFile_Pause Yes'); % pause
    
    vpx_SendCommandString('dataFile_Pause No'); % start recording
    
    p.trial.arrington.setup.eyeimgsize=50;
    
    % some default values (used in calibration; relieves dependency on other pldaps modules/subfields
    if ~isfield(p.trial.arrington, 'fixdotW')
        p.trial.arrington.fixdotW = ceil(0.2 * p.trial.display.ppd);
    end
    
    if isempty(p.trial.arrington.calibration_matrix)
        c=[1 0; 0 1; 0 0]'; % assume default calibration
        % initialize a calibration matrix
        cm = c;
        cm(:,:,2)=c;
        p.trial.arrington.calibration_matrix = cm;
    end
    
    
end



