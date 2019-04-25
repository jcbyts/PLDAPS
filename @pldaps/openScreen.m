function p = openScreen(p)
%openScreen    opens PsychImaging Window with preferences set for special
%              decives like datapixx.
%
% required fields
% p.trial.display.
%   stereoMode      [double] -  0 is no stereo
%   normalizeColor  [boolean] - 1 normalized color range on PTB screen
%   useOverlay      [double]  - 0,1,2 opens different overlay windows
%                             - 0=no overlay, 1=datapixx, 2=software
%   stereoFlip      [string]  - 'left', 'right', or [] flips one stereo
%                               image for the planar screen
%   colorclamp      [boolean] - 1 clamps color between 0 and 1
%   scrnNum         [double]  - number of screen to open
%   sourceFactorNew [string]  - see Screen Blendfunction?
%   destinationFactorNew      - see Screen Blendfunction?
%   widthcm
%   heightcm
%   viewdist
%   bgColor

% 12/12/2013 jly wrote it   Mostly taken from Init_StereoDispPI without any
%                           of the switch-case in the front for each rig.
%                           This assumes you have set up your display
%                           struct before calling.
% 01/20/2014 jly update     Updated help text and added default arguments.
%                           Created a distinct variable to separate
%                           colorclamp and normalize color.
% 05/2015    jk  update     changed for use with version 4.1
%                           moved default parameters to the
%                           pldapsClassDefaultParameters


% prevent splash screen
Screen('Preference','VisualDebugLevel',3);
InitializeMatlabOpenGL(0, 0); %second 0: debug level =0 for speed, debug level=3 == "very verbose" (slow, but incl. error msgs from w/in OpenGL/mogl functions)

% Initiate Psych Imaging screen configs
PsychImaging('PrepareConfiguration');

%% Setup Psych Imaging
% Add appropriate tasks to psych imaging pipeline

if p.trial.display.normalizeColor == 1
    disp('****************************************************************')
    disp('Turning on Normalized High res Color Range')
    disp('Sets all displays to use color range from 0-1 (e.g. NOT 0-255),')
    disp('while also setting color range to ''unclamped''.')
    disp('****************************************************************')
    PsychImaging('AddTask', 'General', 'NormalizedHighresColorRange', 1);
end


PsychImaging('AddTask', 'General', 'FloatingPoint16Bit', 'disableDithering',p.trial.display.disableDithering);

% Gamma correction
PsychImaging('AddTask', 'FinalFormatting', 'DisplayColorCorrection', 'LookupTable');

% Open Screen
[ptr, winRect]=PsychImaging('OpenWindow', p.trial.display.scrnNum, p.trial.display.bgColor, p.trial.display.screenSize, [], [], p.trial.display.stereoMode, 0);

% Keep track of pointers
p.trial.display.ptr = ptr;
p.trial.display.winRect = winRect;

% Software overlay is half-width; adjust winRect accordingly
if p.trial.display.useOverlay==2
    p.trial.display.winRect(3)=p.trial.display.winRect(3)/2;
end

%% Set some basic variables about the display
p.trial.display.width = 2*atand(p.trial.display.widthcm/2/p.trial.display.viewdist);

p.trial.display.ppd = p.trial.display.winRect(3)/p.trial.display.width; % calculate pixels per degree

p.trial.display.frate = round(1 / Screen('GetFlipInterval', p.trial.display.ptr));   % frame rate (in Frames / sec)
p.trial.display.ifi   =Screen('GetFlipInterval', p.trial.display.ptr);               % Inter-frame interval (frame rate in seconds)
p.trial.display.ctr   = [p.trial.display.winRect(3:4), p.trial.display.winRect(3:4)]./2 - 0.5;          % Rect defining screen center
p.trial.display.info  = Screen('GetWindowInfo', p.trial.display.ptr);              % Record a bunch of general display settings
[~, ~, p.trial.display.info.realBitDepth] = Screen('ReadNormalizedGammaTable', p.trial.display.ptr); % Actual bitdepth of display hardware (not merely frame buffer bpc)

%% some more
% [p]ixel dimensions
p.trial.display.pWidth  = p.trial.display.winRect(3) - p.trial.display.winRect(1);
p.trial.display.pHeight = p.trial.display.winRect(4) - p.trial.display.winRect(2);

p.trial.display.wWidth=p.trial.display.widthcm;

p.trial.display.wHeight=p.trial.display.heightcm;
% visual [d]egrees          % updated to ensure this param reflects ppd (i.e. not an independent/redundant calculation)
p.trial.display.dWidth =  p.trial.display.pWidth/p.trial.display.ppd;   
p.trial.display.dHeight = p.trial.display.pHeight/p.trial.display.ppd;
% space conversions
p.trial.display.w2px = [p.trial.display.pWidth / p.trial.display.wWidth; p.trial.display.pHeight / p.trial.display.wHeight];
p.trial.display.px2w = [p.trial.display.wWidth / p.trial.display.pWidth; p.trial.display.wHeight / p.trial.display.pHeight];                                  

% Make text clean
Screen('TextFont',  p.trial.display.ptr,'Helvetica'); % TODO: do we have Helvetica on linux
Screen('TextSize',  p.trial.display.ptr,16);
Screen('TextStyle', p.trial.display.ptr,1);


%% Assign overlay pointer
if p.trial.display.useOverlay==1
    if p.trial.datapixx.use
        % Standard PLDAPS overlay mode.
        % Overlay infrastructure has already been created by PsychImaging, just retrieve the pointer
        p.trial.display.overlayptr = PsychImaging('GetOverlayWindow', p.trial.display.ptr); % , dv.params.bgColor);
    else
        warning('pldaps:openScreen', 'Datapixx Overlay requested but datapixx disabled. No Dual head overlay availiable!')
        p.trial.display.overlayptr = p.trial.display.ptr;
        
    end
    
elseif p.trial.display.useOverlay==2  % use software overlay (requires Xscreen that spans two monitors)
   
    pds.softwareOverlay.setup(p);
    
else
    
    p.trial.display.overlayptr = p.trial.display.ptr;
    
end

% % Set gamma lookup table
if isField(p.trial, 'display.gamma')
    disp('****************************************************************')
    disp('Loading gamma correction')
    disp('****************************************************************')
    if isfield(p.trial.display.gamma, 'table')
        PsychColorCorrection('SetLookupTable', p.trial.display.ptr, p.trial.display.gamma.table, 'FinalFormatting');
    end
else
    %set a linear gamma
    PsychColorCorrection('SetLookupTable', ptr, linspace(0,1,p.trial.display.info.realBitDepth)'*[1, 1, 1], 'FinalFormatting');
end

% % This seems redundant. Is it necessary?
if p.trial.display.colorclamp == 1
    disp('****************************************************************')
    disp('clamping color range')
    disp('****************************************************************')
    Screen('ColorRange', p.trial.display.ptr, 1, 0);
end


%% Set up alpha-blending for smooth (anti-aliased) drawing
disp('****************************************************************')
fprintf('Setting Blend Function to %s,%s\r', p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);
disp('****************************************************************')
Screen('BlendFunction', p.trial.display.ptr, p.trial.display.sourceFactorNew, p.trial.display.destinationFactorNew);  % alpha blending for anti-aliased dots

if p.trial.display.forceLinearGamma
    LoadIdentityClut(p.trial.display.ptr);
end

%% Setup cluts & basic colors
p=defaultColors(p); % load the default CLUTs -- this is useful for opening overlay window in pds.datapixx.init
p.trial.display.white = WhiteIndex(p.trial.display.ptr);
p.trial.display.black = BlackIndex(p.trial.display.ptr);

%% Flip screen to get initial timestamp & finish
p.trial.display.t0 = Screen('Flip', p.trial.display.ptr);

% Setup PLDAPS experiment condition
p.trial.pldaps.maxFrames = p.trial.pldaps.maxTrialLength * p.trial.display.frate;
