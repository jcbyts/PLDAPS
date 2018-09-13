function s=pldapsClassDefaultParameters(s)
 if nargin<1
	s=struct;
 end

%s.	.
%s.	behavior.
%s.	behavior.	reward.
 s.	behavior.	reward.	defaultAmount = 0.0500;

%s.	datapixx.
 s.	datapixx.	enablePropixxCeilingMount = false;
 s.	datapixx.	enablePropixxRearProjection = false;
 s. datapixx.   rb3d = 0;
 s.	datapixx.	LogOnsetTimestampLevel = 2;
 s.	datapixx.	use = true;
 s.	datapixx.	useAsEyepos = false;
 s.	datapixx.	useForReward = false;

%s.	datapixx.	adc.
 s.	datapixx.	adc.	bufferAddress = [ ];
 s.	datapixx.	adc.	channelGains = 1;
 s.	datapixx.	adc.	channelMapping = 'datapixx.adc.data';
 s.	datapixx.	adc.	channelModes = 0;
 s.	datapixx.	adc.	channelOffsets = 0;
 s.	datapixx.	adc.	channels = [ ];
 s.	datapixx.	adc.	maxSamples = 0;
 s.	datapixx.	adc.	numBufferFrames = 600000;
 s.	datapixx.	adc.	srate = 1000;
 s.	datapixx.	adc.	startDelay = 0;
 s.	datapixx.	adc.	XEyeposChannel = [ ];
 s.	datapixx.	adc.	YEyeposChannel = [ ];

%s.	datapixx.	GetPreciseTime.
 s.	datapixx.	GetPreciseTime.	maxDuration = [ ];
 s.	datapixx.	GetPreciseTime.	optMinwinThreshold = [ ];
 s.	datapixx.	GetPreciseTime.	syncmode = [ ];

%s.	display.
 s.	display.	bgColor = [ 0.5000    0.5000    0.5000 ];
 s.	display.	colorclamp = 0;
 s.	display.	destinationFactorNew = 'GL_ONE_MINUS_SRC_ALPHA';
 s.	display.	displayName = 'defaultScreenParameters';
 s.	display.	forceLinearGamma = false;
 s.	display.	heightcm = 45;
 s.	display.	normalizeColor = 1;
 s.	display.	screenSize = [ ];
 s.	display.	scrnNum = max(Screen('Screens'));
 s.	display.	sourceFactorNew = 'GL_SRC_ALPHA';
 s.	display.	stereoFlip = [ ];
 s.	display.	stereoMode = 0;
 s. display.    crosstalk = 0;
 s.	display.	switchOverlayCLUTs = false;
 s.	display.	useOverlay = 1;
 s.	display.	viewdist = 57;
 s.	display.	widthcm = 63;
 s. display.    ipd = 6.5;
 s. display.    useGL = false; % flag for custom 3D rendering features

% Movie making moved to pds.pldapsMovie module

%s.	eyelink.
 s.	eyelink.	buffereventlength = 30;
 s.	eyelink.	buffersamplelength = 31;
 s.	eyelink.	calibration_matrix = [ ];
 s.	eyelink.	collectQueue = true;
 s.	eyelink.	custom_calibration = false;
 s.	eyelink.	custom_calibrationScale = 0.2500;
 s.	eyelink.	saveEDF = false;
 s.	eyelink.	use = true;
 s.	eyelink.	useAsEyepos = true;
 s.	eyelink.	useRawData = false;

%s.	git.
 s.	git.	use = false;

%s.	mouse.
 s.	mouse.	initialCoordinates = [];
 s.	mouse.	use = true;
 s.	mouse.	useAsEyepos = false;
 s.	mouse.	useLocalCoordinates = false;
 s.	mouse.	windowPtr = [ ];

%  S.newera = true;                    % use the New Era syringe pump to deliver liquid rewards
% S.pumpCom = 'COM4';                 % COM port the New Era syringe pump
% S.pumpDiameter = 19.05;             % internal diameter of the juice syringe (mm)
% S.pumpRate = 10.0;                  % rate to deliver juice (ml/minute)
% S.pumpDefVol = 0.005;               % default dispensing volume (ml)

 s. newEraSyringePump.  use      = true;
 s.	newEraSyringePump.	port     = '/dev/cu.usbserial';
 s.	newEraSyringePump.	diameter = 19.05;
 s.	newEraSyringePump.  rate     = 10;
 s.	newEraSyringePump.  vol      = 0.005;
 
 % jake's rig
%       alarmMode: 1
%     allowNewDiameter: 1
%             diameter: 38
%         lowNoiseMode: 0
%                 port: '/dev/ttyUSB0'
%                 rate: 2900
%          triggerMode: 'T2'
%                  use: 1
%          volumeUnits: 'ML'
 
% %s.	newEraSyringePump.
%  s.	newEraSyringePump.	alarmMode = 1;
%  s.	newEraSyringePump.	allowNewDiameter = false;
%  s.	newEraSyringePump.	diameter = 38;
%  s.	newEraSyringePump.	lowNoiseMode = 0;
%  s.	newEraSyringePump.	port = '/dev/cu.usbserial';
%  s.	newEraSyringePump.	rate = 2900;
%  s.	newEraSyringePump.	triggerMode = 'T2';
%  s.	newEraSyringePump.	use = false;
%  s.	newEraSyringePump.	volumeUnits = 'ML';

%s.	pldaps.
 s.	pldaps.	experimentAfterTrialsFunction = [ ];
 s.	pldaps.	eyeposMovAv = 1;
 s. pldaps. lastBgColor = s.display.bgColor;
 s.	pldaps.	finish = Inf;
 s.	pldaps.	goodtrial = 0; % This is old; now in p.trial.good. Marking for future deletion. --TBC 2017
 s.	pldaps.	iTrial = 0;
 s.	pldaps.	maxPriority = true;
 s.	pldaps.	maxTrialLength = 300;
 s.	pldaps.	nosave = false;
 s.	pldaps.	pass = false;
 s.	pldaps.	quit = 0;
 s.	pldaps.	trialMasterFunction = 'runTrial';
 s.	pldaps.	useFileGUI = false;
 s.	pldaps.	useModularStateFunctions = false;

%s.	pldaps.	dirs.
 s.	pldaps.	dirs.	data = '/Data';
 s. pldaps. dirs.   proot = fileparts(fileparts(mfilename('fullpath'))); % proot == PLDAPS root directory
 s.	pldaps.	dirs.	wavfiles = fullfile( s.pldaps.dirs.proot, 'beepsounds'); %'[proot]/beepsounds';

%s.	pldaps.	draw.
%s.	pldaps.	draw.	cursor.
 s.	pldaps.	draw.	cursor.	use = false;

%s.	pldaps.	draw.	eyepos.
 s.	pldaps.	draw.	eyepos.	use = true;

%s.	pldaps.	draw.	framerate.
 s.	pldaps.	draw.	framerate.	location = [ -30   -10 ];
 s.	pldaps.	draw.	framerate.	nSeconds = 3;
 s.	pldaps.	draw.	framerate.	show = false;
 s.	pldaps.	draw.	framerate.	size = [ 20     5 ];
 s.	pldaps.	draw.	framerate.	use = false;

%s.	pldaps.	draw.	grid.
 s.	pldaps.	draw.	grid.	use = true;

%s.	pldaps.	draw.	photodiode.
 s.	pldaps.	draw.	photodiode.	everyXFrames = 17;
 s.	pldaps.	draw.	photodiode.	location = 1;
 s.	pldaps.	draw.	photodiode.	use = 0;

%s.	pldaps.	pause.
 s.	pldaps.	pause.	preExperiment = true;
 s.	pldaps.	pause.	type = 1;

%s.	pldaps.	save.
 s.	pldaps.	save.	initialParametersMerged = 1;
 s.	pldaps.	save.	mergedData = 0;
 s.	pldaps.	save.	trialTempfiles = 1;
 s.	pldaps.	save.	v73 = 0;

%s.	pldaps.	trialStates.
	tsNeg = -1; tsPos = 1;
 s.	pldaps.	trialStates.        trialSetup = tsNeg;             tsNeg = tsNeg-1;
 s.	pldaps.	trialStates.        trialPrepare = tsNeg;           tsNeg = tsNeg-1;
 s.	pldaps.	trialStates.	frameUpdate = tsPos;            tsPos = tsPos+1;
 s.	pldaps.	trialStates.	framePrepareDrawing = tsPos;    tsPos = tsPos+1;
 s.	pldaps.	trialStates.	frameDraw = tsPos;              tsPos = tsPos+1;
 s.	pldaps.	trialStates.	frameGLDrawLeft = tsPos;        tsPos = tsPos+1;
 s.	pldaps.	trialStates.	frameGLDrawRight = tsPos;       tsPos = tsPos+1;
 s.	pldaps.	trialStates.	frameDrawingFinished = tsPos;   tsPos = tsPos+1;
 s.	pldaps.	trialStates.	frameFlip = tsPos;              tsPos = tsPos+1;
 s. pldaps. trialStates.        trialItiDraw = tsNeg;           tsNeg = tsNeg-1;
 s.	pldaps.	trialStates.        trialCleanUpandSave = tsNeg;    tsNeg = tsNeg-1;
 s.	pldaps.	trialStates.	experimentPreOpenScreen = tsNeg;    tsNeg = tsNeg-1;
 s.	pldaps.	trialStates.	experimentPostOpenScreen = tsNeg;   tsNeg = tsNeg-1;
 s.	pldaps.	trialStates.	experimentAfterTrials = tsNeg;      tsNeg = tsNeg-1;
 s.	pldaps.	trialStates.	experimentCleanUp = tsNeg;          tsNeg = tsNeg-1;
 

%s.	plexon.
%s.	plexon.	spikeserver.
 s.	plexon.	spikeserver.	continuous = false;
 s.	plexon.	spikeserver.	eventsonly = false;
 s.	plexon.	spikeserver.	remoteip = 'xx.xx.xx.xx';
 s.	plexon.	spikeserver.	remoteport = 3333;
 s.	plexon.	spikeserver.	selfip = 'xx.xx.xx.xx';
 s.	plexon.	spikeserver.	selfport = 3332;
 s.	plexon.	spikeserver.	use = 0;
 s. plexon. spikeserver.    spikeCount = 0;
 
 % arrington eyetracker
 s. arrington. use          = false;
 s. arrington. useAsEyepos  = false;
 s. arrington. calibration_matrix = [];
 s. arrington. eyeIdx       = 1;

%s.	session.
 s.	session.	experimentSetupFile = [ ];

%s.	sound.
 s.	sound.	deviceid = [ ];
 s.	sound.	use = true;
 s.	sound.	useForReward = true;
 
 % default trial function
 s. stimulus. stateFunction. name = '@pldapsDefaultTrial';
 s. stimulus. stateFunction. order = 0;
 s. stimulus. use   = 1;
 s. stimulus. stateFunction. acceptsLocationInput = true;
 s. stimulus. stateFunction. requestedStates = struct(...
	'experimentPostOpenScreen', true, ...
	'frameUpdate',  true, ...
    'frameDrawingFinished', true, ...
	'frameDraw',    true, ...
	'frameFlip',    true, ...
    'trialSetup',   true, ...
	'trialPrepare', true, ...
	'trialItiDraw', true, ...
	'trialCleanUpandSave', true);

 s. calibration. stateFunction. name = '@defaultCalibrationTrial';
 s. calibration. stateFunction. order = 1;
 s. calibration. use   = 0;
 s. calibration. stateFunction. acceptsLocationInput = true;
 s. calibration. stateFunction. requestedStates = struct(...
	'experimentPostOpenScreen', true, ...
	'frameUpdate',  true, ...
	'frameDraw',    true, ...
	'frameFlip',    true, ...
    'trialSetup',   true, ...
	'trialPrepare', true, ...
	'trialItiDraw', true, ...
	'trialCleanUpandSave', true);

end