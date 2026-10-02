function report = run_loran_tests()
%RUN_LORAN_TESTS Deterministic unit tests; no experiment data are needed or stored.
cfg = loran_default_config();
coefficient = cfg.c_m_per_s/(2*100*cfg.bw_hz);
assert(abs(loran_estimate_from_peaks([12 2],1,2,100,cfg)-10*coefficient)<1e-10);
assert(loran_estimate_from_peaks([2 12],1,2,100,cfg)<0);
period = 2^cfg.sf*100;
assert(abs(loran_estimate_from_peaks([2 period-2],1,2,100,cfg)-4*coefficient)<1e-10);
loran_assert_throws(@() loran_estimate_from_peaks([1 2],3,2,100,cfg));
loran_assert_throws(@() loran_estimate_from_peaks([1 2],1,[1 2],100,cfg));
loran_assert_throws(@() loran_estimate_from_peaks([NaN 2],1,2,100,cfg));
loran_assert_throws(@() LoRanPHY(0,cfg));
invalid = cfg; invalid.fs_hz = cfg.bw_hz;
loran_assert_throws(@() LoRanPHY(100,invalid));
phy = LoRanPHY(10,cfg);
signal = [repmat(conj(phy.Downchirp),4,1);0];
raw = phy.extract(signal,cfg);
assert(numel(raw.peak_bins)==3 && all(raw.peak_bins==1));
modern = cfg; modern.legacy_window_boundary = false;
complete = phy.extract(signal,modern); assert(numel(complete.peak_bins)==4);
groups = loran_chirp_groups(raw,10,cfg);
assert(height(groups)==1 && groups.FirstWindow==1 && groups.LastWindow==3);
% Synthetic records validate the shared converter, including absent references.
records = struct('capture_id','unit','nz',100,'peak_bins',[12 2]);
selection = struct('capture_id','unit','master_windows',1,'slave_windows',2);
[frames,summary,pairs] = loran_results_from_peaks(records,selection,cfg);
assert(height(frames)==1 && height(pairs)==1 && summary.FrameCount==1);
assert(isnan(frames.NativeResultM) && summary.PairedFrames==0 && isnan(summary.Below10M));
loran_assert_throws(@() loran_results_from_peaks([records records],selection,cfg));
selection.native_result_m = frames.DistanceM;
selection.physical_length_m = frames.DistanceM;
[~,summary] = loran_results_from_peaks(records,selection,cfg);
assert(summary.PairedFrames==1 && summary.MedianAbsoluteDifferenceM==0);
% Generated IO fixtures live in a temporary directory, never in the release tree.
folder = tempname; mkdir(folder);
filename = fullfile(folder,'unit.cf32');
loran_write_iq(filename,signal,'float32');
assert(max(abs(loran_read_iq(filename)-signal))<1e-6);
loran_assert_throws(@() loran_write_iq(filename,signal,'float32'));
selection = struct('capture_id','unit','relative_iq_file','unit.cf32', ...
    'master_windows',1,'slave_windows',2);
selectionFile = fullfile(folder,'unit_selection.json');
fid = fopen(selectionFile,'w'); assert(fid>=0);
fprintf(fid,'%s',jsonencode(selection)); fclose(fid);
cfg.apply_lowpass = false; cfg.nz_values = [10 50];
[computed,stats] = loran_process_dataset(folder,fullfile(folder,'output'),selectionFile,cfg);
assert(height(computed)==2 && all(computed.DistanceM==0) && all(stats.PairedFrames==0));
loran_assert_throws(@() loran_process_dataset(folder,fullfile(folder,'output'),selectionFile,cfg));
% No-reference plotting must not manufacture a comparison plot or fit.
plotFolder = fullfile(folder,'plots'); mkdir(plotFolder);
cfg.plot_nz = 10;
fits = loran_plot_results(computed,stats,plotFolder,cfg);
assert(isempty(fits) && isempty(dir(fullfile(plotFolder,'*.pdf'))));
report = struct('passed',true,'uses_experiment_data',false,'matlab_version',version);
disp(report);
end
