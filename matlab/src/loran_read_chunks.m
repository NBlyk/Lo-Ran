function chunks = loran_read_chunks(filename,bitsPerChunk,format)
%LORAN_READ_CHUNKS Read caller-owned QAM index bytes/words or decimal text.
if nargin<3, format = 'binary'; end
format = validatestring(format,{'binary','text'});
validateattributes(bitsPerChunk,{'numeric'},{'scalar','integer','>=',1,'<=',16});
fid = fopen(filename,'rb','ieee-le');
assert(fid>=0,'LoRan:ChunkFile','Cannot open chunks file.');
cleanup = onCleanup(@() fclose(fid));
if strcmp(format,'text')
    chunks = fscanf(fid,'%f');
    remaining = fread(fid,Inf,'*char').';
    assert(isempty(strtrim(remaining)),'LoRan:ChunkFile','Non-numeric text in chunks file.');
else
    if bitsPerChunk<=8
        chunks = fread(fid,Inf,'uint8=>double');
    else
        fseek(fid,0,'eof'); bytes = ftell(fid); fseek(fid,0,'bof');
        assert(mod(bytes,2)==0,'LoRan:ChunkFile','Incomplete uint16 chunk.');
        chunks = fread(fid,Inf,'uint16=>double');
    end
end
validateattributes(chunks,{'numeric'},{'vector','nonempty','integer','>=',0,'<',2^bitsPerChunk});
end
