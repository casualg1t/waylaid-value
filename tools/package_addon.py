"""Package the TOC manifest, attribution and instructions; refresh the local unpacked copy."""
import re, zipfile
from pathlib import Path
folder=Path('addon/WaylaidValue')
toc=(folder/'WaylaidValue.toc').read_text()
version=re.search(r'^## Version: (.+)$',toc,re.M)[1]
assert re.fullmatch(r'\d+\.\d+\.\d+',version)
files={line.strip() for line in toc.splitlines() if line.strip() and not line.startswith('#')}
files.update({'WaylaidValue.toc','THIRD_PARTY_LICENSES.txt'})
assert all(Path(name).name==name and (folder/name).is_file() for name in files)
payload={name:(folder/name).read_bytes() for name in files}
payload['README.md']=Path('README.md').read_bytes()
payload['LICENSE']=Path('LICENSE').read_bytes()
Path('outputs').mkdir(exist_ok=True)
target=Path('outputs')/f'WaylaidValue-{version}.zip'
with zipfile.ZipFile(target,'w',zipfile.ZIP_DEFLATED) as z:
 for name,content in sorted(payload.items()):z.writestr('WaylaidValue/'+name,content)
with zipfile.ZipFile(target) as z:
 assert z.testzip() is None
 assert set(z.namelist())=={'WaylaidValue/'+name for name in payload}
 for name,content in payload.items():assert z.read('WaylaidValue/'+name)==content
stage=Path('outputs/WaylaidValue');stage.mkdir(exist_ok=True)
# Never silently keep an obsolete file in the suggested unpacked installation.
assert not (set(p.name for p in stage.iterdir())-set(payload)), 'Unexpected staging files: inspect before packaging'
for name,content in payload.items():(stage/name).write_bytes(content)
print('Verified',target,len(payload),'files;',target.stat().st_size,'bytes')
