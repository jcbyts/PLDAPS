function setup(p)

global GL
% Create additional shader for overlay texel fetch:
% Our gpu panel scaler might be active, so the size of the
% virtual window - and thereby our overlay window - can be
% different from the output framebuffer size. As the sampling
% 'pos'ition for the overlay is always provided in framebuffer
% coordinates, we need to subsample in the overlay fetch.
% Calculate proper scaling factor, based on virtual and real
% framebuffer size:
[wC, hC] = Screen('WindowSize', p.trial.display.ptr);
[wF, hF] = Screen('WindowSize', p.trial.display.ptr, 1);
sampleX =  wC / wF;
sampleY = hC / hF;

% String definition of overlay panel-filter index shader
% (...for dealing with retina resolution displays; solution carried over from BitsPlusPlus.m)
shSrc = sprintf('uniform sampler2DRect overlayImage; float getMonoOverlayIndex(vec2 pos) { return(texture2DRect(overlayImage, pos * vec2(%f, %f)).r); }', sampleX, sampleY);

% if using a software overlay, the window size needs to [already] be halved.
disp('****************************************************************')
disp('Using software overlay window')
disp('****************************************************************')
oldColRange = Screen('ColorRange', p.trial.display.ptr, 255);
p.trial.display.overlayptr=Screen('OpenOffscreenWindow', p.trial.display.ptr, 0, [0 0 p.trial.display.pWidth p.trial.display.pHeight], 8, 32);
% Put stimulus color range back how it was
Screen('ColorRange', p.trial.display.ptr, oldColRange);

% Retrieve low-level OpenGl texture handle to the window:
p.trial.display.overlaytex = Screen('GetOpenGLTexture', p.trial.display.ptr, p.trial.display.overlayptr);

% Disable bilinear filtering on this texture - always use
% nearest neighbour sampling to avoid interpolation artifacts
% in color index image for clut indexing:
glBindTexture(GL.TEXTURE_RECTANGLE_EXT, p.trial.display.overlaytex);
glTexParameteri(GL.TEXTURE_RECTANGLE_EXT, GL.TEXTURE_MAG_FILTER, GL.NEAREST);
glTexParameteri(GL.TEXTURE_RECTANGLE_EXT, GL.TEXTURE_MIN_FILTER, GL.NEAREST);
glBindTexture(GL.TEXTURE_RECTANGLE_EXT, 0);

%% get information of current processing chain
debuglevel = 1;
[icmShaders, icmIdString, icmConfig] = PsychColorCorrection('GetCompiledShaders', p.trial.display.ptr, debuglevel);

% Build panel-filter compatible shader from source:
overlayShader = glCreateShader(GL.FRAGMENT_SHADER);
glShaderSource(overlayShader, shSrc);
glCompileShader(overlayShader);

% Attach to list of shaders:
icmShaders(end+1) = overlayShader;

p.trial.display.shader = LoadGLSLProgramFromFiles(fullfile(p.trial.pldaps.dirs.proot, 'SupportFunctions', 'Utils', 'overlay_shader.frag'), debuglevel, icmShaders);

if p.trial.display.info.GLSupportsTexturesUpToBpc >= 32
    % Full 32 bits single precision float:
    p.trial.display.internalFormat = GL.LUMINANCE_FLOAT32_APPLE;
elseif p.trial.display.info.GLSupportsTexturesUpToBpc >= 16
    % No float32 textures:
    % Choose 16 bpc float textures:
    p.trial.display.internalFormat = GL.LUMINANCE_FLOAT16_APPLE;
else
    % No support for > 8 bpc textures at all and/or no need for
    % more than 8 bpc precision or range. Choose 8 bpc texture:
    p.trial.display.internalFormat = GL.LUMINANCE;
end

%create look up textures
p.trial.display.lookupstexs=glGenTextures(2);
%% set variables in the shader
glUseProgram(p.trial.display.shader);
glUniform1i(glGetUniformLocation(p.trial.display.shader,'lookup1'),3);
glUniform1i(glGetUniformLocation(p.trial.display.shader,'lookup2'),4);

glUniform2f(glGetUniformLocation(p.trial.display.shader, 'res'), p.trial.display.pWidth*(1/sampleX), p.trial.display.pHeight);  % [partially] corrects overaly width & position on retina displays
bgColor=p.trial.display.bgColor;
glUniform3f(glGetUniformLocation(p.trial.display.shader, 'transparencycolor'), bgColor(1), bgColor(2), bgColor(3));
glUniform1i(glGetUniformLocation(p.trial.display.shader, 'overlayImage'), 1);
glUniform1i(glGetUniformLocation(p.trial.display.shader, 'Image'), 0);
glUseProgram(0);

%% assign the overlay texture as the input 1 (which mapps to 'overlayImage' as set above)
% It gets passed to the HookFunction call.
% Input 0 is the main pointer by default.
pString = sprintf('TEXTURERECT2D(1)=%i ', p.trial.display.overlaytex);
pString = [pString sprintf('TEXTURERECT2D(3)=%i ', p.trial.display.lookupstexs(1))];
pString = [pString sprintf('TEXTURERECT2D(4)=%i ', p.trial.display.lookupstexs(2))];

%add information to the current processing chain
idString = sprintf('Overlay Shader : %s', icmIdString);
pString  = [ pString icmConfig ];
Screen('HookFunction', p.trial.display.ptr, 'Reset', 'FinalOutputFormattingBlit');
Screen('HookFunction', p.trial.display.ptr, 'AppendShader', 'FinalOutputFormattingBlit', idString, p.trial.display.shader, pString);
PsychColorCorrection('ApplyPostGLSLLinkSetup', p.trial.display.ptr, 'FinalFormatting');