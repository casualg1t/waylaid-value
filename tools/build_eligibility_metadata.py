import html,json,re
from pathlib import Path
metadata=json.loads(Path('fixtures/item-metadata.json').read_text())
lines=['local _, A = ...','-- Item tooltip facts from Wowhead Forever, checked 2026-11-08.','A.ItemRequirements = {']
for key,v in sorted(metadata.items(),key=lambda kv:int(kv[0])):
 if not v.get('name'):continue
 tip=v.get('tooltip','');plain=html.unescape(re.sub('<[^>]+>',' ',tip));plain=re.sub(r'\s+',' ',plain)
 itemclass=re.search(r'<!--scstart(\d+):(\d+)-->',tip)
 level=re.search(r'Requires Level\s*(\d+)',plain)
 classes=re.search(r'Classes:\s*(.*?)(?:Requires|Equip:|Use:|Durability|$)',plain)
 useprof=re.search(r'Requires (Alchemy|Blacksmithing|Cooking|Enchanting|Engineering|Leatherworking|Tailoring)\s*\((\d+)\)',plain)
 fields=['level='+str(int(level[1])if level else 0),'known=true']
 if itemclass:fields+=['classID='+itemclass[1],'subclassID='+itemclass[2]]
 if classes:fields+=['classes='+json.dumps(classes[1].strip(),ensure_ascii=False)]
 if useprof:fields+=['profession='+json.dumps(useprof[1]),'skill='+useprof[2]]
 lines.append('['+key+']={'+','.join(fields)+'},')
lines.append('}')
Path('addon/WaylaidValue/ItemRequirements.lua').write_text('\n'.join(lines)+'\n')
print('Generated item requirement facts:',len(lines)-4)
