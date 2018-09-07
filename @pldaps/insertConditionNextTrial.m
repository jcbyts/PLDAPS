function insertConditionNextTrial(p, conditionStruct, nextTrial)
% insert a struct to overwrite the next condition. Push subsequent
% conditions down one trial.
% 
% Inputs:
%   p@pldaps
%   conditionStruct@struct
%   nextTrial@numeric [1 x 1] (trial # to insert into)
% 
% Example Calls
%
%   % Turn off the dotmotion module next trial (it will return to it's
%   previous state for all subsequent trials)
%   s.use = false;
%   conditionStruct = struct('dotmotion', s);
%   p.insertConditionNextTrial(conditionStruct);
%
%   % re-insert the current condition in a future trial
%   thisCondition = p.conditions{p.trial.pldaps.iTrial};
%   trialToInsert = randi(p.defaultParameters.pldaps.finish - p.trial.pldaps.iTrial) ... +
%                   p.trial.pldaps.iTrial;
%   p.insertConditionNextTrial(thisCondition, trialToInsert)

if nargin < 3
    nextTrial = p.trial.pldaps.iTrial + 1;
end

if nargin < 2
    conditionStruct = [];
end

if isempty(p.conditions)
    p.conditions{nextTrial} = conditionStruct;
else
    old_conds = p.conditions(nextTrial:end);
    p.conditions(nextTrial:end+1) = [{conditionStruct} old_conds];
end

p.defaultParameters.pldaps.finish = p.defaultParameters.pldaps.finish + 1;


