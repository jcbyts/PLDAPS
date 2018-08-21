function [dv] = dvmergefield(dv,defaults,nowarning)
% merge two structs together, where one acts as the defaults and the other
% overrides the default field value if it exits
% [dv] = dvmergefield(dv,defaults,nowarning)
% Input:
%  dv       [struct] - options struct with fields and values
%  default  [struct] - struct with the default argument values
%  nowarning [logical] - don't warn if a field is present in dv that is not present
%                        in defaults
% Output:
%  dv [struct] - the merged options struct

if nargin < 3
	nowarning = false;
end

fn = fieldnames(defaults);
for ii = 1:length(fn)
    if ~isfield(dv,fn{ii}) || isempty(dv.(fn{ii}))
        dv.(fn{ii}) = defaults.(fn{ii});
    end
end

if ~nowarning
    fn = fieldnames(dv);
    for ii = 1:length(fn)
        if ~isfield(defaults,fn{ii});
            warning('dvmergefield:unknownarg','Argument %s is unsupported',fn{ii});
        end
    end
end