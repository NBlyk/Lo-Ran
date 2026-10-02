function [frames,summary,chirpPairs] = loran_results_from_peaks(records,selections,cfg)
%LORAN_RESULTS_FROM_PEAKS One shared peak-to-distance path for raw and cached IQ.
% A selection pairs master-tail and response windows, not UART filename numbers.
% Native results and physical lengths are optional; absent references stay NaN.
if nargin<3, cfg = loran_default_config(); end
assert(~isempty(records) && ~isempty(selections),'LoRan:EmptyRecords','No records/selections.');
ids = string({selections.capture_id});
assert(numel(unique(ids))==numel(ids),'LoRan:SelectionIDs','Duplicate selection IDs.');
keys = table(string({records.capture_id}).',[records.nz].', ...
    'VariableNames',{'CaptureID','Nz'});
assert(height(unique(keys))==height(keys),'LoRan:DuplicateRecords', ...
    'Duplicate capture/Nz records would count an exchange more than once.');
rows = cell(numel(records),7); pairRows = cell(0,7);
for k = 1:numel(records)
    record = records(k);
    index = find(ids==string(record.capture_id));
    assert(isscalar(index),'LoRan:Pairing','Missing selection for %s.',record.capture_id);
    chosen = selections(index);
    [distance,perChirp] = loran_estimate_from_peaks(record.peak_bins, ...
        chosen.master_windows,chosen.slave_windows,record.nz,cfg);
    physical = reference_value(chosen,'physical_length_m');
    native = reference_value(chosen,'native_result_m');
    rows(k,:) = {record.capture_id,record.nz,physical,distance,native, ...
        abs(distance-native),numel(perChirp)};
    for j = 1:numel(perChirp)
        m = chosen.master_windows(j); s = chosen.slave_windows(j);
        pairRows(end+1,:) = {record.capture_id,record.nz,m,s, ...
            record.peak_bins(m),record.peak_bins(s),perChirp(j)}; %#ok<AGROW>
    end
end
frames = cell2table(rows,'VariableNames', ...
    {'CaptureID','Nz','PhysicalLengthM','DistanceM','NativeResultM','AbsoluteDifferenceM','ChirpPairs'});
chirpPairs = cell2table(pairRows,'VariableNames', ...
    {'CaptureID','Nz','MasterWindow','SlaveWindow','MasterPeak','SlavePeak','DistanceM'});
summary = loran_summarize(frames);
end

function value = reference_value(selection,field)
value = NaN;
if isfield(selection,field) && ~isempty(selection.(field))
    value = selection.(field);
    validateattributes(value,{'numeric'},{'scalar','finite'});
end
end
