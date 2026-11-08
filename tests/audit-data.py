"""Cross-check catalog/tooltip facts, Lua versus JS arithmetic, and the release payload."""
import json, os, re, subprocess, tempfile, zipfile
from pathlib import Path
lua=os.environ.get('LUA','lua')
def run_lua(code):return subprocess.check_output([lua,'-e',code],text=True)
data=json.loads(Path('fixtures/rewards-market-data.json').read_text())
metadata=json.loads(Path('fixtures/item-metadata.json').read_text())
catalog=json.loads(subprocess.check_output([lua,'tools/export_catalog.lua']))
assert len(catalog)==321
for a,b in zip(catalog,data['catalog']):
 for key,value in a.items():assert b[key]==value,(a['name'],key)
code='''local A={};assert(loadfile('addon/WaylaidValue/Data.lua'))('',A)
for _,c in ipairs(A.Crates)do for _,o in ipairs(c.options)do print(c.id,o.id,o.quantity,c.level,c.favor or 0,c.provisional and 1 or 0)end end'''
crates={c['id']:c for c in data['crates']};bundles=0
for line in run_lua(code).splitlines():
 cid,i,q,level,favor,provisional=map(int,line.split());c=crates[cid];bundles+=1
 assert c['level']==level and (c['favor'] or 0)==favor
 assert (c['rewardStatus']=='Provisional')==bool(provisional)
 o=next(o for o in c['options']if o['id']==i);assert o['qty']==q
 # The source item tooltip, rather than another copy of the catalog, confirms quantities.
 assert (str(q),o['name']) in re.findall(r'- (\d+) ([^<]+)',metadata[str(cid)]['tooltip'])
assert bundles==96
for r in catalog:
 if r['id']>0:assert str(r['id'])in metadata
 for p in r.get('reagents',[]):assert str(p['id'])in data['items'] and str(p['id'])in metadata
# Feed the same frozen market through both independent implementations.
with tempfile.TemporaryDirectory(prefix='waylaid-audit-') as tmp:
 prices=Path(tmp)/'prices.lua'
 prices.write_text('return {'+','.join('['+k+']='+str(v['price']) for k,v in data['items'].items() if v.get('price'))+'}')
 for level,held,learned in [(20,0,False),(60,30,False),(20,10000,True)]:
  code='''local A={};for _,n in ipairs({'Data','Ranking','RewardsData','Rewards'})do assert(loadfile('addon/WaylaidValue/'..n..'.lua'))('',A)end
local prices=dofile(%s);local function read(id)return prices[id]and{value=prices[id]}end
local rows=A.Rank(A.Crates,read,false,%d)
for _,r in ipairs(A.Rewards)do local c=A.CostReward(r,read,rows,%d,%s);print(c.total or 'nil',c.upfront or 'nil',c.plan and c.plan.favor or 'nil')end'''%(json.dumps(str(prices)),level,held,str(learned).lower())
  actual=[line.split() for line in run_lua(code).splitlines()]
  js="const M=require('./tools/rewards-model.js'),d=require('./fixtures/rewards-market-data.json');console.log(JSON.stringify(M.build(d,"+json.dumps(dict(level=level,held=held,learned=learned))+ ").map(r=>[r.total,r.upfront,r.route.favor])));"
  expected=json.loads(subprocess.check_output(['node','-e',js]))
  assert len(actual)==len(expected)==321
  for a,b in zip(actual,expected):assert [None if x=='nil' else float(x) for x in a]==b,(a,b)
folder=Path('addon/WaylaidValue');toc=(folder/'WaylaidValue.toc').read_text();version=re.search(r'^## Version: (.+)$',toc,re.M)[1]
expected={line.strip() for line in toc.splitlines() if line.strip()and not line.startswith('#')}|{'WaylaidValue.toc','README.md','THIRD_PARTY_LICENSES.txt','LICENSE'}
with zipfile.ZipFile(f'outputs/WaylaidValue-{version}.zip')as z:
 assert z.testzip()is None
 assert set(z.namelist())=={'WaylaidValue/'+p for p in expected}
 for name in expected:
  content=Path(name).read_bytes()if name in {'README.md','LICENSE'}else(folder/name).read_bytes()
  assert z.read('WaylaidValue/'+name)==content
  assert (Path('outputs/WaylaidValue')/name).read_bytes()==content
print('PASS: 321 catalog entries, 96 tooltip-verified bundles, 963 Lua/JS cost comparisons, exact ZIP/TOC/source/staging parity.')
