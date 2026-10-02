function meta = loran_write_iq(filename,iq,format)
%LORAN_WRITE_IQ Write generated IQ as float32 or normalized HackRF signed int8.
% Does not overwrite files. int8 output uses a recorded peak-normalization gain.
if nargin<3, format = 'float32'; end
format = validatestring(format,{'float32','hackrf-int8'});
validateattributes(iq,{'numeric'},{'vector','finite','nonempty'});
assert(~isfile(filename) && ~isfolder(filename),'LoRan:OutputExists','Output already exists.');
iq = iq(:); gain = 1;
if strcmp(format,'hackrf-int8')
    peak = max([abs(real(iq));abs(imag(iq))]);
    assert(peak>0,'LoRan:ZeroIQ','Cannot normalize an all-zero waveform.');
    gain = 127/peak; iq = round(iq*gain); precision = 'int8';
else
    precision = 'single';
end
interleaved = reshape([real(iq).';imag(iq).'],[],1);
fid = fopen(filename,'wb','ieee-le');
assert(fid>=0,'LoRan:OutputFile','Cannot create IQ file.');
cleanup = onCleanup(@() fclose(fid));
written = fwrite(fid,interleaved,precision);
assert(written==numel(interleaved),'LoRan:OutputFile','Incomplete IQ write.');
meta = struct('format',format,'complex_samples',numel(iq),'normalization_gain',gain);
end
