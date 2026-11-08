"""Build a labelled implementation preview from public fixtures and Lua item facts."""
import base64,io,json,os,subprocess
from pathlib import Path
from PIL import Image

d=json.loads(Path('fixtures/rewards-market-data.json').read_text())
d['metadata']=json.loads(subprocess.check_output([os.environ.get('LUA','lua'),'tools/export_catalog.lua','preview']))
for key,item in d['items'].items():d['items'][key]={k:item[k]for k in ['id','name','icon','price']}
for name,uri in d['icons'].items():
 image=Image.open(io.BytesIO(base64.b64decode(uri.split(',')[1]))).convert('RGB').resize((24,24))
 out=io.BytesIO();image.save(out,format='WEBP',quality=35,method=6)
 d['icons'][name]='data:image/webp;base64,'+base64.b64encode(out.getvalue()).decode()
template=Path('tools/ui-preview-template.html').read_text()
html=template.replace('__DATA__',json.dumps(d,separators=(',',':')).replace('<','\\u003c')).replace('__MODEL__',Path('tools/rewards-model.js').read_text())
Path('outputs').mkdir(exist_ok=True);Path('outputs/ui-preview.html').write_text(html)
print('Built implementation preview:',len(html.encode()),'bytes')
