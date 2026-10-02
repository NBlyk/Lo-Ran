function groups = loran_chirp_groups(result,nz,cfg)
%LORAN_CHIRP_GROUPS List stable circular-bin runs for capture inspection.
% Candidates are not validated master/response labels. Reference distances never
% select runs; the benchmark retains the original annotated windows.
bins = result.peak_bins(:);
period = 2^cfg.sf*nz;
delta = mod(diff(bins)+period/2,period)-period/2;
edges = [1;find(abs(delta)>nz)+1;numel(bins)+1];
rows = zeros(0,4);
for k = 1:numel(edges)-1
    first = edges(k); last = edges(k+1)-1;
    if last-first+1>=3
        rows(end+1,:) = [first,last,last-first+1, ...
            median(result.peak_amplitudes(first:last))]; %#ok<AGROW>
    end
end
groups = array2table(rows,'VariableNames', ...
    {'FirstWindow','LastWindow','WindowCount','MedianPeakAmplitude'});
end
