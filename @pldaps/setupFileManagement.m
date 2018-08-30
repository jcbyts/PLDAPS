function setupFileManagement(p)

if ~p.defaultParameters.pldaps.nosave
    p.defaultParameters.session.dir = p.defaultParameters.pldaps.dirs.data;
    
    if isfield(p.defaultParameters.session, 'experimentName')
        p.defaultParameters.session.file = sprintf('%s%s%s%s.PDS',...
            p.defaultParameters.session.subject,...
            datestr(p.defaultParameters.session.initTime, 'yyyymmdd'),...
            p.defaultParameters.session.experimentName, ...
            datestr(p.defaultParameters.session.initTime, 'HHMM'));
    else
        p.defaultParameters.session.file = sprintf('%s%s%s%s.PDS',...
            p.defaultParameters.session.subject,...
            datestr(p.defaultParameters.session.initTime, 'yyyymmdd'),...
            p.defaultParameters.session.experimentSetupFile, ...
            datestr(p.defaultParameters.session.initTime, 'HHMM'));
    end
    
    if p.defaultParameters.pldaps.useFileGUI
        [cfile, cdir] = uiputfile('.PDS', 'specify data storage file', fullfile( p.defaultParameters.session.dir,  p.defaultParameters.session.file));
        if(isnumeric(cfile)) %got canceled
            error('pldaps:run','file selection canceled. Not sure what the correct default bevaior would be, so stopping the experiment.')
        end
        p.defaultParameters.session.dir = cdir;
        p.defaultParameters.session.file = cfile;
    end
    
    if ~exist(p.trial.session.dir, 'dir')
        warning('pldaps:run','Data directory specified in .pldaps.dirs.data does not exist.\n');
        ans = input(sprintf('\tShould I create Data & TEMP dirs in: %s? (...if not, will quit PLDAPS)\n\t\t(y/n): ',p.trial.pldaps.dirs.data), 's');
        if ~isempty(ans) && lower(ans(1))=='y'
            mkdir(fullfile(p.trial.pldaps.dirs.data));
            mkdir(fullfile(p.trial.pldaps.dirs.data, 'TEMP'));
        else
            fprintf(2, '\n\tQuitting PLDAPS. Please run createRigPrefs to update your data dirs,\n\tor create directory %s, containing a subdirectory called ''TEMP''\n\n', p.trial.pldaps.dirs.data)
            return;
        end
    end
else
    p.defaultParameters.session.file='';
    p.defaultParameters.session.dir='';
end