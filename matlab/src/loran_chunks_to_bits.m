function bits = loran_chunks_to_bits(chunks,bitsPerChunk,order)
%LORAN_CHUNKS_TO_BITS Decode unsigned zero-based QAM chunks with explicit order.
% Replaces getchunks and repeated string/bit-flip loops. 1024-QAM needs uint16.
if nargin<3, order = 'lsb'; end
order = validatestring(order,{'lsb','msb'});
validateattributes(bitsPerChunk,{'numeric'},{'scalar','integer','>=',1,'<=',16});
validateattributes(chunks,{'numeric'},{'vector','integer','>=',0,'<',2^bitsPerChunk});
positions = 1:bitsPerChunk;
if strcmp(order,'msb'), positions = fliplr(positions); end
matrix = bitget(repmat(uint16(chunks(:)),1,bitsPerChunk), ...
    repmat(positions,numel(chunks),1));
bits = double(reshape(matrix.',[],1));
end
