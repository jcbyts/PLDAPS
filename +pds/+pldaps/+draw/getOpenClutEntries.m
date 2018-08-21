function openClutEntries = getOpenClutEntries(p, num)
% openClutEntries = getOpenClutEntries(p, [num])

if ~p.trial.display.useOverlay
    openClutEntries = nan;
    return
end

clutFields = fieldnames(p.trial.display.clut);
nEntries = numel(clutFields);

index = nan(nEntries, 1);

for iField = 1:nEntries
    thisEntry = p.trial.display.clut.(clutFields{iField});
	index(iField) = thisEntry(1);
end

nPossible = size(p.trial.display.humanCLUT, 1);
openClutEntries = setdiff( (1:nPossible) , index);

if nargin < 2
    return
else
    openClutEntries = openClutEntries(1:num);
end