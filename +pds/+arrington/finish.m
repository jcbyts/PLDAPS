function p = finish(p)
%pds.arrington.finish    stop recording on arrington eye tracker
%
% p = pds.arrington.Finish(p)
% pds.arrington.finish stops recording and closes the currently open vpx file.

if nargin < 1
    help pds.arrington.finish
    return;
end

if p.trial.arrington.use
    
    %     vpxFile = p.trial.arrington.vpxFile;
    %     file = p.trial.session.file;
    %     dirs = p.trial.session.dir;
    
    try
        vpx_SendCommandString('dataFile_Close');
    catch me
        error('pldaps:arrington error closing vpx file')
    end
    
end

