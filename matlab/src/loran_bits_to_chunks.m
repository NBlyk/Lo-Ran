function chunks = loran_bits_to_chunks(bits,bitsPerChunk,order)
%LORAN_BITS_TO_CHUNKS Invert the shared chunk codec without padding hidden bits.
if nargin<3, order = 'lsb'; end
order = validatestring(order,{'lsb','msb'});
validateattributes(bitsPerChunk,{'numeric'},{'scalar','integer','>=',1,'<=',16});
validateattributes(bits,{'numeric','logical'},{'vector','binary'});
assert(mod(numel(bits),bitsPerChunk)==0,'LoRan:ChunkLength','Incomplete chunk bit group.');
weights = 2.^(0:bitsPerChunk-1);
if strcmp(order,'msb'), weights = fliplr(weights); end
chunks = reshape(double(bits),bitsPerChunk,[]).'*weights(:);
if bitsPerChunk<=8, chunks = uint8(chunks); else, chunks = uint16(chunks); end
end
