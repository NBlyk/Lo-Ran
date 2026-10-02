"""Audit the public source-only tree without experimental or vendor files."""
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
blocked = {'.mlx','.csv','.mat','.xlsx','.xls','.opju','.opj','.pdf',
           '.cf32','.cs8','.iq','.bin','.hex','.axf','.o','.obj','.log',
           '.c','.h','.s','.uvprojx','.ioc'}
for path in ROOT.rglob('*'):
    if not path.is_file() or '.git' in path.relative_to(ROOT).parts:
        continue
    assert path.suffix.lower() not in blocked,'Non-public artifact: '+str(path)
    assert not any(part.lower() in {'data','raw_iq','results','review'}
                   for part in path.relative_to(ROOT).parts),'Data/output directory: '+str(path)
    if path.suffix.lower() in {'.m','.md','.json','.cff','.py'}:
        content = path.read_text(encoding='utf-8')
        assert not re.search(r'[A-Za-z]:[\\/](?:Desktop|Users|MATLAB)',content),path
matlab = ROOT/'matlab'
names = [p.name.lower() for p in matlab.rglob('*.m')]
assert len(names)==len(set(names)),'Duplicate MATLAB filenames'
assert 'jkadbear' in (matlab/'third_party/LoRaPHY/LICENSE').read_text(encoding='utf-8')
for name in ['LoRanPHY','loran_process_dataset','loran_process_peaks',
             'loran_ctc_project','loran_ctc_modulate','loran_ctc_export',
             'loran_ctc_nonht_payload','loran_ctc_nonht_stream']:
    assert (matlab/'src'/(name+'.m')).is_file(),name
assert not (ROOT/'firmware/original').exists()
print(f'PASS: {len(names)} distinct MATLAB modules/examples/tests; no experiment data or vendor sources.')
