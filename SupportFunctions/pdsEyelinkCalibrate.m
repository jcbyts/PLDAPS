function dv=pdsEyelinkCalibrate(dv)

% USAGE: result=EyelinkDoTrackerSetup(el [, sendkey])
%
%		el: Eyelink default values
%		sendkey: set to go directly into a particular mode
% 				'v', start validation
% 				'c', start calibration
% 				'd', start driftcorrection
% 				13, or dv.el.ENTER_KEY, show 'eye' setup image

%
% 02-06-01	fwc removed use of global el, as suggest by John Palmer.
%				el is now passed as a variable, we also initialize Tracker state bit
%				and Eyelink key values in 'initeyelinkdefaults.m'
% 15-10-02	fwc	added sendkey variable that allows to go directly into a particular mode
% 22-06-06	fwc OSX-ed
% 15-06-10	fwc added code for new callback version
commandwindow
Beeper
disp('*************************************')
disp('Beginning Eyelink Toolbox Calibration')
disp('*************************************')

disp('Checking if Eyelink is recording')


if Eyelink('CheckRecording')==0
    disp('Eyelink is currently recording');
else
    disp('Eyelink is not recording. Is it supposed to be');
end

mytext = 'Control Keys are:\rc\tcalibrate mode\rv\tvalidate\rd\tdrift correction\resc\texit\r'; 
fprintf(mytext)

% [nx, ny, textbounds] = DrawFormattedText(dv.disp.pter, mytext, dv.disp.ctr(1), dv.disp.ctr(2));


if nargin < 1
    error( 'USAGE: result=EyelinkDoTrackerSetup(el [,sendkey])' );
end
ListenChar(2)

% if ~isempty(dv.el.callback)
%     if Eyelink('IsConnected') ~= dv.el.notconnected
%         if ~isempty(dv.el.window)            
%             rect=Screen(dv.el.window,'Rect');
%             % make sure we use the correct screen coordinates
%             Eyelink('Command', 'screen_pixel_coords = %d %d %d %d',rect(1),rect(2),rect(3)-1,rect(4)-1);
%         end
%     else
%         return
%     end
%     result = Eyelink( 'StartSetup', 1 );
%     
%     return;
% end


Eyelink('Command', 'heuristic_filter = ON');
Eyelink( 'StartSetup' );		% start setup mode
Eyelink( 'WaitForModeReady', dv.trial.eyelink.setup.waitformodereadytime );  % time for mode change


key=1;
while key~= 0
    key=EyelinkGetKey(dv.trial.eyelink.setup);		% dump old keys
end

% go directly into a particular mode

if nargin==2
    if dv.trial.eyelink.setup.allowlocalcontrol==1
        switch lower(sendkey)
            case{ 'c', 'v', 'd', dv.trial.eyelink.setup.ENTER_KEY}
                %forcedkey=BITAND(sendkey(1,1),255);
                forcedkey=double(sendkey(1,1));
                Eyelink('SendKeyButton', forcedkey, 0, dv.trial.eyelink.setup.KB_PRESS );
        end
    end
end

tstart=GetSecs;
stop=0;
while stop==0 && bitand(Eyelink( 'CurrentMode'), dv.trial.eyelink.setup.IN_SETUP_MODE)
    
    i=Eyelink( 'CurrentMode');
    
    if ~Eyelink( 'IsConnected' ), stop=1; end;
    
    if bitand(i, dv.trial.eyelink.setup.IN_TARGET_MODE)			% calibrate, validate, etc: show targets
        fprintf ('%s\n', 'dotrackersetup: in targetmodedisplay' );
        pdsEyelinkTargetModeDisplay(dv);
    elseif bitand(i, dv.trial.eyelink.setup.IN_IMAGE_MODE)		% display image until we're back
        fprintf ('%s\n', 'EyelinkDoTrackerSetup: in ''ImageModeDisplay''' );
        pdsEyelinkClearCalDisplay(dv);	% setup_cal_display()
        
    end
    
    [key, dv.trial.eyelink.setup]=EyelinkGetKey(dv.trial.eyelink.setup);		% getkey() HANDLE LOCAL KEY PRESS
    if 1 && key~=0 
        if key~=dv.trial.eyelink.setup.JUNK_KEY    % print pressed key codes and chars
            fprintf('%d\t%s\n', key, char(key) );
        end
    end
    
    switch key
        case dv.trial.eyelink.setup.TERMINATE_KEY,				% breakout key code
            return;
        case { 0, dv.trial.eyelink.setup.JUNK_KEY }          % No or uninterpretable key
        case dv.trial.eyelink.setup.ESC_KEY,
            % 			if Eyelink('IsConnected') == dv.el.dummyconnected
            % 				stop=1; % instead of 'goto exit'
            % 			end
            % 		    if dv.el.allowlocalcontrol==1
            % 	       		Eyelink('SendKeyButton', key, 0, dv.el.KB_PRESS );
            %             end
            stop = 1;
            
        otherwise, 		% Echo to tracker for remote control
            if dv.trial.eyelink.setup.allowlocalcontrol==1
                Eyelink('SendKeyButton', double(key), 0, dv.trial.eyelink.setup.KB_PRESS );
            end
            if key == dv.trial.eyelink.setup.SPACE_BAR
                pds.datapixx.analogOut(.1)
            end
            if strcmp(char(key), 'm')
                pds.datapixx.analogOut(.1)
            end
    end
end % while IN_SETUP_MODE

pdsEyelinkClearCalDisplay(dv);	% exit_cal_display()
dv = pds.eyelink.setup(dv);
ListenChar(0)
ShowCursor
return;
