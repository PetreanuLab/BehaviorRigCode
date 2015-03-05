function sweeps = createSweeps(dp)
% note sweeps is almost identical do dp and should work as dp in most cases
% creat sweeps struct out of dp struct
sweeps = dp;

if isfield(sweeps,'stats')
    fieldsToRemove = {'stats','analysis','RawData'};
    fld = fieldnames(sweeps);
    ind = ismember(fieldsToRemove,fld);
    sweeps = rmfield(sweeps,fieldsToRemove(ind));
end
% sweeps.IntervalSet{1} = dp.IntervalSet;
fldnames = fieldnames(sweeps);

for ifld = 1:length(fldnames)
    thisfld = fldnames{ifld};
    if isa(sweeps.(thisfld),'double')
        sweeps.(thisfld) = single(sweeps.(thisfld));
    end
end