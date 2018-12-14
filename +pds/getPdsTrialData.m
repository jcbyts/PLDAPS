function data = getPdsTrialData(PDS)
% getPdsTrialData merges the conditions and data and outputs the parameters
% and data for each trial. 
% The hierarchy of parameters is like this:
% data -> conditions -> initialParameters 

if ~isempty(PDS.conditions)    
    A = cellfun(@(x) mergeStruct(PDS.initialParametersMerged, x), PDS.conditions, 'uni', 0);
else
    A = repmat({PDS.initialParametersMerged}, 1, numel(PDS.data));
end
fields = fieldnames(PDS.initialParametersMerged);
nTrials = numel(PDS.data);

for iTrial = 1:nTrials
    fields = union(fields, fieldnames(A{iTrial}));
    fields = union(fields, fieldnames(PDS.data{iTrial}));
end

sargs = [fields cell(numel(fields), 1)]';
data = repmat(struct(sargs{:}), nTrials, 1);

for iTrial = 1:nTrials
    data(iTrial) = mergeStruct(data(iTrial), A{iTrial});
    data(iTrial) = mergeStruct(data(iTrial), PDS.data{iTrial});
end

% data = cellfun(@(x,y) mergeStruct(x, y), A, PDS.data, 'uni', 0);