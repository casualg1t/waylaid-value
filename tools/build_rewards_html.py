import base64,io,json
from pathlib import Path
from PIL import Image
p=Path('outputs');p.mkdir(exist_ok=True);data=json.loads(Path('fixtures/rewards-market-data.json').read_text())
# Store each icon once; small WebP assets keep the report easy to share offline.
for name,uri in data['icons'].items():
 image=Image.open(io.BytesIO(base64.b64decode(uri.split(',')[1]))).convert('RGB').resize((34,34))
 buffer=io.BytesIO();image.save(buffer,format='WEBP',quality=65,method=6)
 data['icons'][name]='data:image/webp;base64,'+base64.b64encode(buffer.getvalue()).decode()
for i,item in data['items'].items():
 data['items'][i]={k:item[k]for k in ('id','name','icon','price')}
template=Path('tools/rewards-report-template.html').read_text()
license=Path('addon/WaylaidValue/THIRD_PARTY_LICENSES.txt').read_text()
import html
result=template.replace('__LICENSE__',html.escape(license)).replace('__DATA__',json.dumps(data,separators=(',',':')).replace('<','\\u003c')).replace('__MODEL__',Path('tools/rewards-model.js').read_text())
result=result.replace('body{background:var(--background)}','').replace('margin:auto;padding:32px 28px','margin:auto;padding:0').replace('main{padding:22px 16px}','main{padding:0}')
(p/'wow-forever-rewards-costs.html').write_text(result)
print('Created self-contained rewards report:',len(result.encode()),'bytes')
