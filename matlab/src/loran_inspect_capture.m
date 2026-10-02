function [result,groups] = loran_inspect_capture(filename,nz,cfg)
%LORAN_INSPECT_CAPTURE Inspect master preamble/tail and response chirp regions.
% Window numbers match selection JSON, including the historical strict boundary.
if nargin<3, cfg = loran_default_config(); end
result = loran_extract_peaks(loran_read_iq(filename),nz,cfg);
groups = loran_chirp_groups(result,nz,cfg);
figure('Color','w','Name','Lo-Ran capture inspection');
subplot(2,1,1);
plot(result.peak_bins/nz,'k.-'); grid on;
xlabel('Capture-relative chirp window'); ylabel('Folded peak bin / N_z');
subplot(2,1,2);
plot(result.peak_amplitudes,'k.-'); grid on;
xlabel('Capture-relative chirp window'); ylabel('FFT peak magnitude');
disp(groups);
end
