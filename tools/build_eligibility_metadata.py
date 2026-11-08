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
 if isinstance(v.get('quality'),int):fields+=['quality='+str(v['quality'])]
 # Conservative tooltip-derived affinities. These are roles, never upgrade scores.
 roles=set();lower=plain.lower()
 gear=bool(itemclass and int(itemclass[1])in (2,4))
 healing=bool(re.search(r'increases healing done|healing (?:power|spells)|healing value|healing effects',lower))
 spell=bool(re.search(r'damage and healing done|spell (?:power|damage)|increases? (?:your )?(?:fire|frost|shadow|arcane|nature|holy) damage',lower))
 physical=bool(re.search(r'\+\d+ (?:agility|strength)|attack power|ranged attack|weapon damage|melee damage',lower))
 tank=bool(re.search(r'\+\d+ armor|defense|block (?:chance|value)|parry|dodge',lower))
 if healing:roles.add('healing')
 if spell and not healing:roles.update(['caster','healing'])
 if physical:roles.add('physical')
 if tank and gear:
  roles.add('tank')
  if not re.search(r'\+\d+ agility|attack power',lower):roles.discard('physical')
 if not roles and not gear and not(itemclass and int(itemclass[1])==9):roles.add('general')
 if roles:fields+=['roles={'+','.join(k+'=true'for k in sorted(roles))+'}']
 if itemclass:fields+=['classID='+itemclass[1],'subclassID='+itemclass[2]]
 if classes:fields+=['classes='+json.dumps(classes[1].strip(),ensure_ascii=False)]
 if useprof:fields+=['profession='+json.dumps(useprof[1]),'skill='+useprof[2]]
 lines.append('['+key+']={'+','.join(fields)+'},')
lines.append('}')
Path('addon/WaylaidValue/ItemRequirements.lua').write_text('\n'.join(lines)+'\n')
print('Generated item requirement facts:',len(lines)-4)
