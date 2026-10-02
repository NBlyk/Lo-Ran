function iq = loran_read_iq(path)
%LORAN_READ_IQ Read little-endian interleaved float32 I,Q as MATLAB doubles.
fid = fopen(path, 'rb', 'ieee-le');
assert(fid >= 0, 'LoRan:InputFile', 'Cannot open IQ file: %s', path);
cleanup = onCleanup(@() fclose(fid));
raw = fread(fid, Inf, 'single');
assert(~isempty(raw) && mod(numel(raw),2) == 0 && all(isfinite(raw)), ...
    'LoRan:IQFormat', 'IQ must contain finite float32 I,Q pairs.');
iq = complex(raw(1:2:end), raw(2:2:end));
end
