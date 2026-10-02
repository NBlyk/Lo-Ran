function result = loran_ctc_project(target,cfg)
%LORAN_CTC_PROJECT Map caller-supplied LoRa request IQ onto nearest QAM tones.
% Consolidates repeated FFT/mapping blocks from lora2wifi and lora2chunks.
% Input must be request-only IQ; no slave response is synthesized or transmitted.
if nargin<2, cfg = loran_ctc_config(); end
validateattributes(target,{'numeric'},{'vector','finite','nonempty'});
validateattributes(cfg.input_fft_length,{'numeric'},{'scalar','integer','positive','even'});
validateattributes(cfg.input_block_length,{'numeric'}, ...
    {'scalar','integer','>=',cfg.input_fft_length});
validateattributes(cfg.target_tone_count,{'numeric'}, ...
    {'scalar','integer','positive','<=',cfg.input_fft_length});
validateattributes(cfg.input_fs_hz,{'numeric'},{'scalar','finite','positive'});
validateattributes(cfg.output_fs_hz,{'numeric'},{'scalar','finite','positive'});
normalization = validatestring(cfg.normalization,{'peak','none'});
target = double(target(:));
padding = mod(-numel(target),cfg.input_block_length);
blocks = reshape([target;zeros(padding,1)],cfg.input_block_length,[]);
% The drafts use the first FFT-length samples in each input block.
frequency = fftshift(fft(blocks(1:cfg.input_fft_length,:),[],1),1);
center = cfg.input_fft_length/2+1;
selected = center-floor(cfg.target_tone_count/2)+(0:cfg.target_tone_count-1);
assert(min(selected)>=1 && max(selected)<=cfg.input_fft_length,'LoRan:CTCTones','Invalid target tones.');
desired = frequency(selected,:); scale = 1;
if strcmp(normalization,'peak')
    scale = max(abs(desired(:)));
    assert(scale>0,'LoRan:ZeroTarget','Target has no energy on selected tones.');
end
desired = desired/scale;
% Library demapping implements the nearest constellation point and zero-based IDs.
indices = qamdemod(desired,cfg.qam_order,'UnitAveragePower',true);
mapped = qammod(indices,cfg.qam_order,'UnitAveragePower',true);
dataCount = numel(cfg.output_data_indices);
slots = cfg.output_data_slots(:);
assert(numel(slots)==cfg.target_tone_count && numel(unique(slots))==numel(slots) && ...
    all(slots>=1 & slots<=dataCount),'LoRan:CTCSlots','Invalid/duplicated output data slots.');
validateattributes(cfg.filler_index,{'numeric'}, ...
    {'scalar','integer','>=',0,'<',cfg.qam_order});
dataIndices = repmat(cfg.filler_index,dataCount,size(blocks,2));
dataIndices(slots,:) = indices;
dataSymbols = qammod(dataIndices,cfg.qam_order,'UnitAveragePower',true);
timingRatio = ((cfg.output_fft_length+cfg.output_cp_length)/cfg.output_fs_hz) / ...
    (cfg.input_block_length/cfg.input_fs_hz);
result = struct('cfg',cfg,'qam_indices',dataIndices,'data_symbols',dataSymbols, ...
    'target_fft_indices',selected,'desired_tones',desired,'mapped_tones',mapped, ...
    'fft_scale',scale,'input_padding_samples',padding,'input_sample_count',numel(target), ...
    'symbol_count',size(blocks,2),'output_to_input_duration_ratio',timingRatio, ...
    'selected_tone_quantization_mse',mean(abs(desired(:)-mapped(:)).^2));
end
