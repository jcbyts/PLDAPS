function data = getPdsTrialData(PDS)
% getPdsTrialData merges the conditions and data and outputs the parameters
% and data for each trial. 
% The hierarchy of parameters is like this:
% data -> conditions -> initialParameters 

if iscell(PDS)
    nPds = numel(PDS);
    data = cell(nPds,1);
    for k = 1:nPds
        data{k} = pds.getPdsTrialData(PDS{k});
    end
    
    fnames = {};
    for k = 1:nPds
        fnames = union(fnames, fieldnames(data{k}));
    end
    
    n = numel(fnames);
    sargs = [fnames cell(n, 1)]';
    nTrials = cellfun(@numel, data);
    tr0 = [0; cumsum(nTrials(1:end-1))];
    tmp = repmat(struct(sargs{:}), sum(nTrials), 1);
    
    for k = 1:nPds
        for j = 1:nTrials(k)
            for f = 1:n
                if isfield(data{k}(j), fnames{f})
                    tmp(tr0(k)+j).(fnames{f}) = data{k}(j).(fnames{f});
                end
            end
        end
    end
    
    data = tmp;
    
else
    if ~isempty(PDS.conditions)
        if any(cellfun(@isempty, PDS.conditions))
            for ii = 1:numel(PDS.data)
                PDS.conditions{ii}.Nr = ii;
            end
        end
        
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
    
    % overload broken things
    for iTrial = 1:nTrials
        data(iTrial).pldaps.iTrial = iTrial;
    end
    
end


tstarts = arrayfun(@(x) x.timing.flipTimes(1), data);
[~, ind] = sort(tstarts);
data = data(ind);

% data = cellfun(@(x,y) mergeStruct(x, y), A, PDS.data, 'uni', 0);