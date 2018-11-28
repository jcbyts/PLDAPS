function settingsStruct = pdsGetModuleStructFromConditions(conditions)
% get the module setup struct from a conditions cell array
% settingsStruct = pdsGetModuleStructFromConditions(conditions)
%   Loops over conditions and extracts the module names and their
%   respective stateFunctions. Defaults all to unused state.

nTrials = numel(conditions);

mnames = {};
sfuns  = {};
for iTrial = 1:nTrials
    c = conditions{iTrial};
    
    moduleNames=fieldnames(c);
    moduleNames(cellfun(@(x) ~isstruct(c.(x)),moduleNames))=[]; %remove non struct candidates
    moduleNames(cellfun(@(x) ~isfield(c.(x),'stateFunction'),moduleNames))=[]; %remove candidates without a stateFucntion specified
    
    stateFunctions = cellfun(@(x) c.(x).stateFunction, moduleNames, 'uni', false);
    
    mnames = [mnames; moduleNames(:)];
    sfuns = [sfuns; stateFunctions(:)];
    

end


%% find order
[mnames, iA] = unique(mnames);

sfuns = sfuns(iA);

settingsStruct = struct();
for i = 1:numel(mnames);
    settingsStruct.(mnames{i}).stateFunction = sfuns{i};
    settingsStruct.(mnames{i}).use = false; % initialize to false
end