function summary = loran_benchmark_latency(inputFiles,outputRoot,cfg)
%LORAN_BENCHMARK_LATENCY Repeat timing of every selected capture at each Nz.
% Extraction timing excludes filtering, kernel setup, IQ conversion, and IO.
% Total DSP timing includes filtering, setup, and extraction, but excludes IO.
% These timing scopes are explicit and need not match historical detector timings.
if nargin<3, cfg = loran_default_config(); end
validateattributes(cfg.latency_repeats,{'numeric'},{'scalar','integer','positive'});
validateattributes(cfg.latency_warmups,{'numeric'},{'scalar','integer','nonnegative'});
inputFiles = string(inputFiles(:));
assert(~isempty(inputFiles),'LoRan:LatencyInputs','Select at least one IQ file.');
assert(~isfolder(outputRoot) && ~isfile(outputRoot), ...
    'LoRan:OutputExists','Choose a new output directory.');
iq = cell(numel(inputFiles),1); filtered = iq;
for k = 1:numel(inputFiles)
    iq{k} = loran_read_iq(inputFiles(k));
    filtered{k} = loran_prepare_signal(iq{k},cfg);
end
rows = zeros(numel(cfg.nz_values)*numel(inputFiles)*cfg.latency_repeats,5);
row = 0;
for nz = cfg.nz_values(:).'
    phy = LoRanPHY(nz,cfg);
    for k = 1:numel(iq)
        for warmup = 1:cfg.latency_warmups
            phy.extract(filtered{k},cfg);
            loran_extract_peaks(iq{k},nz,cfg);
        end
        for repeat = 1:cfg.latency_repeats
            timer = tic; phy.extract(filtered{k},cfg); extractionMs = toc(timer)*1000;
            timer = tic; loran_extract_peaks(iq{k},nz,cfg); totalMs = toc(timer)*1000;
            row = row+1;
            rows(row,:) = [nz,k,repeat,extractionMs,totalMs];
        end
    end
end
runs = array2table(rows,'VariableNames', ...
    {'Nz','CaptureIndex','Repeat','ExtractionMs','TotalDSPMs'});
values = unique(runs.Nz); stats = zeros(numel(values),6);
for k = 1:numel(values)
    selected = runs(runs.Nz==values(k),:);
    stats(k,:) = [values(k),height(selected),mean(selected.ExtractionMs), ...
        std(selected.ExtractionMs),mean(selected.TotalDSPMs),std(selected.TotalDSPMs)];
end
summary = array2table(stats,'VariableNames', ...
    {'Nz','Runs','MeanExtractionMs','StdExtractionMs','MeanTotalDSPMs','StdTotalDSPMs'});
mkdir(outputRoot);
writetable(runs,fullfile(outputRoot,'loran_latency_runs.csv'));
writetable(summary,fullfile(outputRoot,'loran_latency_summary.csv'));
save(fullfile(outputRoot,'loran_latency_runs.mat'),'runs','summary','cfg','inputFiles');
disp(summary);
end
