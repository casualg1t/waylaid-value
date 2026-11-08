local _,A=...
local professionIDs={[171]='Alchemy',[164]='Blacksmithing',[165]='Leatherworking',[197]='Tailoring',[202]='Engineering',[333]='Enchanting',[185]='Cooking'}
local professionSpells={Alchemy=2259,Blacksmithing=2018,Leatherworking=2108,Tailoring=3908,Engineering=4036,Enchanting=7411,Cooking=2550}
function A.ReadCharacter()
 local p={professions={},professionsKnown=false}
 if UnitLevel then local ok,v=pcall(UnitLevel,'player');if ok and type(v)=='number'and v>0 then p.level=v end end
 if UnitClass then local ok,_,token=pcall(UnitClass,'player');if ok then p.class=token end end
 local names={}
 for name,id in pairs(professionSpells)do
  names[name]=name
  if C_Spell and C_Spell.GetSpellInfo then local ok,v=pcall(C_Spell.GetSpellInfo,id);if ok and v and v.name then names[v.name]=name end
  elseif GetSpellInfo then local ok,v=pcall(GetSpellInfo,id);if ok and v then names[v]=name end end
 end
 local function add(name,rank,maxRank,id)
  local canonical=professionIDs[id]or names[name]
  if canonical and type(rank)=='number'and rank>0 then
   local previous=p.professions[canonical]
   if not previous or rank>previous.skill then p.professions[canonical]={skill=rank,maxSkill=maxRank or rank}end
  end
 end
 local modernKnown,legacyKnown=false,false
 if GetProfessions and GetProfessionInfo then
  local values={pcall(GetProfessions)}
  if values[1]then
   modernKnown=true
   -- Profession slots contain holes: do not use ipairs or # on this result.
   for i=2,7 do if values[i]then
    local ok,name,_,rank,maxRank,_,_,id=pcall(GetProfessionInfo,values[i])
    if ok and type(name)=='string'and type(rank)=='number'then add(name,rank,maxRank,id)else modernKnown=false end
   end end
  end
 end
 if GetNumSkillLines and GetSkillLineInfo then
  local ok,n=pcall(GetNumSkillLines)
  if ok and type(n)=='number'and n>=0 then
   legacyKnown=true
   for i=1,n do
    local valid,name,header,_,rank,_,_,maxRank=pcall(GetSkillLineInfo,i)
    if not valid or type(name)~='string'then legacyKnown=false
    elseif not header then
     if type(rank)=='number'then add(name,rank,maxRank)else legacyKnown=false end
    end
   end
  end
 end
 p.professionsKnown=modernKnown or legacyKnown
 return p
end
local armorLimit={WARRIOR=4,PALADIN=4,HUNTER=3,SHAMAN=3,ROGUE=2,DRUID=2,PRIEST=1,MAGE=1,WARLOCK=1}
local relicClass={[7]='PALADIN',[8]='DRUID',[9]='SHAMAN'}
-- Class compatibility, not a claim that a weapon proficiency has been trained.
local weaponClasses={
 [0]='WARRIOR PALADIN HUNTER SHAMAN',[1]='WARRIOR PALADIN HUNTER SHAMAN',
 [2]='WARRIOR HUNTER ROGUE',[3]='WARRIOR HUNTER ROGUE',
 [4]='WARRIOR PALADIN PRIEST SHAMAN ROGUE DRUID',[5]='WARRIOR PALADIN SHAMAN DRUID',
 [6]='WARRIOR PALADIN HUNTER',[7]='WARRIOR PALADIN HUNTER ROGUE MAGE WARLOCK',
 [8]='WARRIOR PALADIN HUNTER',[10]='WARRIOR HUNTER PRIEST SHAMAN MAGE WARLOCK DRUID',
 [13]='WARRIOR HUNTER ROGUE SHAMAN DRUID',[15]='WARRIOR HUNTER ROGUE PRIEST SHAMAN MAGE WARLOCK DRUID',
 [16]='WARRIOR HUNTER ROGUE',[18]='WARRIOR HUNTER ROGUE',[19]='PRIEST MAGE WARLOCK',
}
function A.RewardRequirements(reward)
 local source=A.ItemRequirements and A.ItemRequirements[reward.id]
 local meta={}
 for k,v in pairs(source or {})do meta[k]=v end
 local get=C_Item and C_Item.GetItemInfo or GetItemInfo
 if get and reward.id and reward.id>0 then
  local v={pcall(get,reward.id)}
  if v[1]and v[2]then
   if type(v[6])=='number'then meta.level=v[6]end
   if type(v[13])=='number'then meta.classID=v[13]end
   if type(v[14])=='number'then meta.subclassID=v[14]end
  end
 end
 return meta
end
function A.UseEligibility(reward,profile)
 -- Enchant effects do not require the recipient to learn Enchanting.
 if reward.spell and reward.recipe==reward.id and reward.profession=='Enchanting'then return true end
 local meta=A.RewardRequirements(reward)
 if not meta or not meta.known then return nil,'Item requirements unverified'end
 local level=meta.level or 0
 if level>0 and not profile.level then return nil,'Character level unavailable'end
 if level>(profile.level or 0)then return false,'Requires level '..level end
 if meta.profession then
  if not profile.professionsKnown then return nil,'Profession data unavailable'end
  local own=profile.professions[meta.profession]
  if not own or own.skill<(meta.skill or 1)then return false,'Requires '..meta.profession..' '..(meta.skill or 1)end
 end
 if meta.classes then
  if not profile.class then return nil,'Character class unavailable'end
  if not string.find(string.upper(meta.classes),profile.class,1,true)then return false,'Class restriction: '..meta.classes end
 end
 if meta.classID==4 or meta.classID==2 then
  if not profile.class then return nil,'Character class unavailable'end
  local sub=meta.subclassID
  if meta.classID==4 then
   if sub==0 then return true end
   if sub==6 then return profile.class=='WARRIOR'or profile.class=='PALADIN'or profile.class=='SHAMAN','Shield proficiency required'end
   if relicClass[sub]then return profile.class==relicClass[sub],relicClass[sub]..' only'end
   if sub and sub>=1 and sub<=4 then
    local maximum=armorLimit[profile.class]
    if not maximum or not profile.level then return nil,'Armor compatibility unverified'end
    if maximum>=3 and profile.level<40 then maximum=maximum-1 end
    if sub>maximum then return false,'Armor not available for your class / level'end
    return true
   end
   return nil,'Armor type unverified'
  end
  local allowed=weaponClasses[sub]
  if not allowed then return nil,'Weapon compatibility unverified'end
  if not string.find(allowed,profile.class,1,true)then return false,'Weapon not available to your class'end
 end
 return true
end
function A.SkillEligibility(reward,profile)
 if reward.purchase then return true end
 if not professionSpells[reward.profession]then return nil,'Crafting profession unverified'end
 if not profile.professionsKnown then return nil,'Profession data unavailable'end
 local own=profile.professions[reward.profession]
 if not own then return false,reward.profession..' not learned'end
 if not reward.skill then return nil,'Required skill unverified'end
 if own.skill<reward.skill then return false,'Requires '..reward.profession..' '..reward.skill..' (you: '..own.skill..')'end
 return true
end
local roleNames={physical='Physical DPS',caster='Spell DPS',healing='Healing',tank='Tank',general='General'}
local roleOrder={'physical','caster','healing','tank','general'}
local classRoles={HUNTER={physical=true},ROGUE={physical=true},WARRIOR={physical=true,tank=true},MAGE={caster=true},WARLOCK={caster=true},PRIEST={caster=true,healing=true}}
function A.RewardRoles(reward)
 local meta=A.ItemRequirements and A.ItemRequirements[reward.id]
 local roles=meta and meta.roles
 local names={}
 for _,key in ipairs(roleOrder)do if roles and roles[key]then names[#names+1]=roleNames[key]end end
 return roles,#names>0 and table.concat(names,' / ')or 'Role unclassified'
end
function A.RoleMatch(reward,profile,role)
 if not role or role=='all'then return true end
 local roles=A.RewardRoles(reward)
 -- Keep unclassified items visible rather than inventing a suitability score.
 if not roles then return role=='auto'end
 if role=='auto'then
  if roles.general then return true end
  local wanted=classRoles[profile.class]
  if not wanted then return true end -- hybrids need an explicit role choice
  for key in pairs(wanted)do if roles[key]then return true end end
  return false
 end
 return roles[role]==true
end
function A.FilterRewards(rewards,profile,options)
 local rows,summary={},{total=0,hidden=0,unknown=0}
 local query=string.lower(options.search or '')
 for _,reward in ipairs(rewards)do
  local inGroup=not options.profession or options.profession=='all'or(options.profession=='mine'and profile.professions[reward.profession])or reward.profession==options.profession
  if inGroup and string.find(string.lower(reward.name..' '..reward.profession),query,1,true)then
   summary.total=summary.total+1
   local usable,useReason=A.UseEligibility(reward,profile)
   local skilled,skillReason=A.SkillEligibility(reward,profile)
   local unknown=(options.usable and usable==nil)or(options.skill and skilled==nil)
   local meta=A.RewardRequirements(reward)
   local armorOK=not options.armor or options.armor==''or(meta and meta.classID==4 and meta.subclassID==options.armor)
   if unknown then summary.unknown=summary.unknown+1 end
   if armorOK and A.RoleMatch(reward,profile,options.role)and(not options.usable or usable==true)and(not options.skill or skilled==true)then
    rows[#rows+1]={reward=reward,usable=usable,useReason=useReason,skilled=skilled,skillReason=skillReason}
   else summary.hidden=summary.hidden+1 end
  end
 end
 table.sort(rows,function(a,b)return a.reward.name<b.reward.name end)
 return rows,summary
end
