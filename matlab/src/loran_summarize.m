function summary = loran_summarize(frames)
%LORAN_SUMMARIZE Report native agreement only for supplied finite references.
values = unique(frames.Nz); rows = NaN(numel(values),10);
for k = 1:numel(values)
    group = frames(frames.Nz==values(k),:);
    paired = isfinite(group.DistanceM) & isfinite(group.NativeResultM);
    delta = abs(group.DistanceM(paired)-group.NativeResultM(paired));
    r = NaN;
    if sum(paired)>=2 && std(group.DistanceM(paired))>0 && std(group.NativeResultM(paired))>0
        coefficient = corrcoef(group.DistanceM(paired),group.NativeResultM(paired));
        r = coefficient(1,2);
    end
    physical = isfinite(group.DistanceM) & isfinite(group.PhysicalLengthM);
    cableDelta = abs(group.DistanceM(physical)-group.PhysicalLengthM(physical));
    below = NaN;
    if ~isempty(delta), below = sum(delta<10); end
    rows(k,:) = [values(k),height(group),sum(paired),safe_stat(delta,'median'), ...
        safe_stat(delta,'mean'),below,r,safe_stat(cableDelta,'median'), ...
        safe_stat(cableDelta,'mean'),sqrt(safe_stat(cableDelta.^2,'mean'))];
end
summary = array2table(rows,'VariableNames', ...
    {'Nz','FrameCount','PairedFrames','MedianAbsoluteDifferenceM', ...
     'MeanAbsoluteDifferenceM','Below10M','PearsonR','MedianAbsoluteCableDifferenceM', ...
     'MeanAbsoluteCableDifferenceM','CableRMSEM'});
end

function value = safe_stat(values,operation)
value = NaN;
if ~isempty(values)
    if strcmp(operation,'median'), value = median(values); else, value = mean(values); end
end
end
