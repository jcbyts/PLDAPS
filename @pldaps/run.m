function p = run(p)
%run    run a new experiment for a previously created pldaps class
% p = run(p)
% PLDAPS (Plexon Datapixx PsychToolbox) version 4.2
%       run is a wrapper for calling PLDAPS package files
%           It opens the PsychImaging pipeline and initializes datapixx for
%           dual color lookup tables. 

%% Initialize session

% --- clean up PTB
p.initializeSession();

% --- Setup the file
p.setupFileManagement();

% --- setup modules
p.setupExperimentPreOpenScreen();

%% Open PLDAPS windows
% Open PsychToolbox Screen
p = openScreen(p);

%% Basic environment initialization
p.initEnvironment();
    
%% experimentPostOpenScreen
onlyActive = false; % run all modules post open screen routines
[moduleNames,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs] = getModules(p, onlyActive);
runStateforModules(p,'experimentPostOpenScreen',moduleNames,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs);

        
%% Last chance to check variables
if(p.trial.pldaps.pause.type==1 && p.trial.pldaps.pause.preExperiment==true) %0=don't,1 is debugger, 2=pause loop
    disp(p)
    disp('Ready to begin trials. Type "dbcont" to start first trial...')
    keyboard
end
 
    
%% Final preparations before trial loop begins
%%%%start recoding on all controlled components this in not currently done here
% save timing info from all controlled components (datapixx, eyelink, this pc)
p = beginExperiment(p);

    % disable keyboard
    ListenChar(2);
    HideCursor;
    
    p.trial.flagNextTrial  = 0; % flag for ending the trial
    p.trial.iFrame     = 0;  % frame index
    
    % Save defaultParameters as trial 0
    % NOTE: the following line converts p.trial into a struct.
    % ------------------------------------------------
    % !!! Beyond this point, we will no longer use params!!!
    % ------------------------------------------------
    p.trial = mergeToSingleStruct(p.defaultParameters);
    p.defaultParameters = mergeToSingleStruct(p.defaultParameters);
    
    result = saveTempFile(p); 
    if ~isempty(result)
        disp(result.message)
    end
         
    
    %% Main trial loop
    while p.trial.pldaps.iTrial < p.trial.pldaps.finish && p.trial.pldaps.quit~=2
        
        if ~p.trial.pldaps.quit
            
            p.defaultParameters.pldaps.iTrial = p.defaultParameters.pldaps.iTrial + 1;
            
           % --- Conditions
           % If there are conditions for this trial, merge them into the
           % the trial struct
           if ~isempty(p.conditions) && numel(p.conditions) >= p.defaultParameters.pldaps.iTrial && ~isempty(p.conditions{p.defaultParameters.pldaps.iTrial})
               p.trial = mergeStruct(p.defaultParameters, p.conditions{p.defaultParameters.pldaps.iTrial});
           else
               p.trial = p.defaultParameters;
           end
           
           %---------------------------------------------------------------------% 
           % RUN THE TRIAL
           runModularTrial(p);
           
           %save tmp data
           result = saveTempFile(p); 
           if ~isempty(result)
               disp(result.message)
           end
           
           % experimentAfterTrials  (Modular PLDAPS)
           if p.trial.pldaps.useModularStateFunctions && ~isempty(p.trial.pldaps.experimentAfterTrialsFunction)
               [moduleNames,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs] = getModules(p);
               runStateforModules(p,'experimentAfterTrials',moduleNames,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs);
           end
           

           % --- make deep copy of trial so the objects in data are unique
           
           % if a temp file was saved, just load that
           if p.defaultParameters.pldaps.nosave % there are no temp files
               tmpFname = [];
           else
               tmpFname = fullfile(p.trial.session.dir,'TEMP',[p.trial.session.file(1:end-4) num2str(p.trial.pldaps.iTrial) p.trial.session.file(end-3:end)]);
           end
           
            if ~isempty(tmpFname) && exist(tmpFname, 'file')
                clear copytrial
                copytrial = load(tmpFname, '-mat');
                copytrial = copytrial.(sprintf('trial%d', p.trial.pldaps.iTrial));
            else % do new deep copy (save and load)
                copytrial = p.trial; %#ok<NASGU>
                fname = fullfile(p.trial.pldaps.dirs.data,'TEMP', 'deepCopyStruct.mat');
                save(fname, '-v7.3', '-struct', 'copytrial');
                clear copytrial
                copytrial = load(fname);
            end
            
            if p.defaultParameters.pldaps.save.mergedData
                % store the complete trial struct to .data
                dTrialStruct = copytrial;
            else
                % store the difference of the trial struct to .data
                [~, ~, dTrialStruct] = comp_struct(p.defaultParameters, copytrial);
            end

           p.data{p.defaultParameters.pldaps.iTrial} = dTrialStruct;
           
        else
            
            % Pause experiment. should we halt eyelink, datapixx, etc?
            ptype=p.trial.pldaps.pause.type;

            if ptype==1 %0=don't,1 is debugger, 2=pause loop
                ListenChar(0);
                ShowCursor;
                disp('Experiment paused. Type "dbcont" to continue...')
                keyboard %#ok<MCKBD>
                p.trial.pldaps.quit = 0;
                ListenChar(2);
                HideCursor;
            elseif ptype==2
                pauseLoop(p);
            end           
%             pds.datapixx.refresh(p);

        end
        
    end
    
    %% Clean up & bookkeeping post-trial execution loop
    
    % return cursor and command-line control
    ShowCursor;
    ListenChar(0);
    Priority(0); % set to normal priority during setup
    
    pds.eyelink.finish(p);  % p =  ; These should be operating on pldaps class handles, thus no need for outputs. --tbc.
    pds.arrington.finish(p);
    pds.behavior.reward.finish(p);

    
    pds.plexon.finish(p);
    if(p.defaultParameters.datapixx.use)
        % stop adc data collection
        pds.datapixx.adc.stop(p);
        
        status = PsychDataPixx('GetStatus');
        if status.timestampLogCount
            p.defaultParameters.datapixx.timestamplog = PsychDataPixx('GetTimestampLog', 1);
        end
    end
    
    if p.defaultParameters.sound.use
        pds.audio.clearBuffer(p);
        % Close the audio device:
        PsychPortAudio('Close', p.defaultParameters.sound.master); 
    end
    
    if p.trial.pldaps.useModularStateFunctions
        [moduleNames,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs] = getModules(p);
        runStateforModules(p,'experimentCleanUp',moduleNames,moduleFunctionHandles,moduleRequestedStates,moduleLocationInputs);
    end
    
    % --- save pldaps
    if ~p.defaultParameters.pldaps.nosave
%         [structs,structNames] = p.defaultParameters.getAllStructs();
        
        PDS = struct;
        PDS.initialParametersMerged = p.defaultParameters;
        PDS.conditions = p.conditions;
        PDS.trial = p.trial;
        PDS.data = p.data;
        PDS.functionHandles = p.functionHandles;
%         
%         PDS.initialParameters = structs(baseParamsLevels);
%         PDS.initialParameterNames = structNames(baseParamsLevels);
%         PDS.initialParameterIndices = baseParamsLevels;
%         % Include a less user-hostile output struct
%         if p.defaultParameters.pldaps.save.initialParametersMerged
%             % Should be noted that baseParamsLevels may have been changed throughout
%             % course of experiment, so this merged struct could be misleading.
%             % ...activeLevels now documented for every trial though:    data{}.pldaps.activeLevels
%             PDS.initialParametersMerged = mergeToSingleStruct(p.defaultParameters);
%         end
%         
%         levelsCondition = 1:length(structs);
%         levelsCondition(ismember(levelsCondition,baseParamsLevels)) = [];
%         PDS.conditions = structs(levelsCondition);
%         PDS.conditionNames = structNames(levelsCondition);
%         PDS.data = p.data; 
%         PDS.functionHandles = p.functionHandles; %#ok<STRNU>
        savedFileName = fullfile(p.defaultParameters.session.dir, p.defaultParameters.session.file);
        if p.defaultParameters.pldaps.save.v73
            save(savedFileName,'PDS','-mat','-v7.3')
        else
            save(savedFileName,'PDS','-mat')
        end
        disp('****************************************************************')
        fprintf('\tPLDAPS data file saved as:\n\t\t%s\n', savedFileName)
        disp('****************************************************************')

        % Detect & report dropped frames
        frameDrops = cell2mat(cellfun(@(x) [sum(diff(x.timing.flipTimes(1,:))>(1.1*p.trial.display.ifi)), x.iFrame], p.data, 'uni',0)');
        ifiMu = mean(cell2mat(cellfun(@(x) diff(x.timing.flipTimes(1,:)), p.data, 'uni',0)));
        if 1%sum(frameDrops(:,1))>0
            fprintf(2, '\t**********\n');
            fprintf(2,'\t%d (of %d) ', sum(frameDrops,1)); fprintf('trial frames exceeded 110%% of expected ifi\n');
            fprintf('\tAverage ifi = %3.2f ms (%2.2f Hz)', ifiMu*1000, 1/ifiMu);
            if isfield(p.data{1},'frameRenderTime')
                fprintf(',\t  median frameRenderTime = %3.2f ms\n', 1000*median(cell2mat(cellfun(@(x) x.frameRenderTime', p.data, 'uni',0)')));
            end
            fprintf(2, '\t**********\n');
        end

    end
    
    if p.defaultParameters.display.useOverlay==2
        glDeleteTextures(2,p.trial.display.lookupstexs(1));
    end
    
    % Clean up stray glBuffers (...else crash likely on subsequent runs)
    if isfield(p.trial.display, 'useGL') && p.trial.display.useGL
        global glB GL %#ok<TLEV>
        if isstruct(glB)
            fn1 = fieldnames(glB);
            for i = 1:length(fn1)
                if isstruct(glB.(fn1{i})) && isfield(glB.(fn1{i}),'h')
                    % contains buffer handle
                    glDeleteBuffers(1, glB.(fn1{i}).h);
                    % fprintf('\tDeleted glBuffer glB.%s\n', fn1{i});
                    glB = rmfield(glB, fn1{i});
                    
                elseif glIsProgram(glB.(fn1{i}))
                    % is a GLSL program
                    glDeleteProgram(glB.(fn1{i}))
                end
            end
            clearvars -global glB
        end
    end
    
    % Make sure enough time passes for any pending async flips to occur
    Screen('WaitBlanking', p.trial.display.ptr);
    
    % close up shop
    Screen('CloseAll');
    IOPort('CloseAll');

    sca;

end


% % % % % % % % % % % % 
% % Sub-Functions
% % % % % % % % % % % % 

%we are pausing, will create a new defaultParaneters Level where changes
%would go.
function pauseLoop(p)
        ShowCursor;
%         ListenChar(1); % is this necessary
        KbQueueRelease();
        KbQueueCreate();
        KbQueueStart();
%         altLastPressed=0;
%         ctrlLastPressed=0;
%         ctrlPressed=false;
%         altPressed=false;
        
        while p.trial.pldaps.quit==1
            %the keyboard chechking we only capture ctrl+alt key presses.
            [p.trial.keyboard.pressedQ,  p.trial.keyboard.firstPressQ]=KbQueueCheck(); % fast
            if p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Lctrl)&&p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.Lalt)
                %D: Debugger
                if  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.dKey) 
                    disp('stepped into debugger. Type "dbcont" to start first trial...')
                    keyboard %#ok<MCKBD>

                %E: Eyetracker Setup
                elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.eKey)
                    try
                       if(p.trial.eyelink.use) 
                           pds.eyelink.calibrate(p);
                       end
                    catch ME
                        display(ME);
                    end

                %M: Manual reward
                elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.mKey)
                    pds.behavior.reward.give(p);

                %P: PAUSE (end the pause) 
                elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.pKey)
                    p.trial.pldaps.quit = 0;
                    ListenChar(2);
                    HideCursor;
                    break;

                %Q: QUIT
                elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.qKey)
                    p.trial.pldaps.quit = 2;
                    break;
                
                %X: Execute text selected in Matlab editor
                elseif  p.trial.keyboard.firstPressQ(p.trial.keyboard.codes.xKey)
                    activeEditor=matlab.desktop.editor.getActive; 
                    if isempty(activeEditor)
                        fprintf(2, 'No Matlab editor open -> Nothing to execute\n');
                    else
                        if isempty(activeEditor.SelectedText)
                            fprintf(2, 'Nothing selected in the active editor Widnow -> Nothing to execute\n');
                        else
                            try
                                eval(activeEditor.SelectedText)
                            catch ME
                                display(ME);
                            end
                        end
                    end
                    
                    
                end %IF CTRL+ALT PRESSED
            end
            pause(0.1);
        end

end
