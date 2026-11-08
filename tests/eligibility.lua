local A={}
for _,name in ipairs({'RewardsData','ItemRequirements','Eligibility'})do assert(loadfile('addon/WaylaidValue/'..name..'.lua'))('WaylaidValue',A)end
UnitClass=function()return 'Hunter','HUNTER'end;UnitLevel=function()return 20 end
GetProfessions=function()return 2,nil,nil,4 end
GetProfessionInfo=function(i)if i==2 then return 'Localized Engineering',nil,109,150,nil,nil,202 else return 'Localized Cooking',nil,2,75,nil,nil,185 end end
local p=A.ReadCharacter();assert(p.class=='HUNTER'and p.level==20 and p.professions.Engineering.skill==109 and p.professions.Cooking.skill==2)
assert(not p.professions.Alchemy)
-- Legacy path and localized profession-name lookup; headers never count.
GetProfessions=nil;GetProfessionInfo=nil
GetSpellInfo=function(id)if id==2259 then return 'Alchimie'end end
GetNumSkillLines=function()return 2 end
GetSkillLineInfo=function(i)if i==1 then return 'Professions',true else return 'Alchimie',false,nil,75,nil,nil,150 end end
p=A.ReadCharacter();assert(p.professions.Alchemy.skill==75 and not p.professions.Professions)
GetNumSkillLines=nil;GetSkillLineInfo=nil;assert(not A.ReadCharacter().professionsKnown)
local function reward(name)for _,r in ipairs(A.Rewards)do if r.name==name then return r end end;error(name)end
local hunter={class='HUNTER',level=20,professionsKnown=true,professions={Leatherworking={skill=100},Engineering={skill=109}}}
local hood,mail,cloth=reward("Brawler's Leather Hood"),reward("Acolyte's Silvered Chain Helm"),reward('Pristine Circlet')
assert(A.UseEligibility(hood,hunter)==true)
assert(A.UseEligibility(mail,hunter)==false)
assert(A.SkillEligibility(hood,hunter)==true)
assert(A.SkillEligibility(cloth,hunter)==false)
hunter.level=40;assert(A.UseEligibility(mail,hunter)==true);hunter.level=19;assert(A.UseEligibility(hood,hunter)==false)
hunter.level=20;hunter.professions.Leatherworking.skill=99;assert(A.SkillEligibility(hood,hunter)==false)
local priest={class='PRIEST',level=60,professionsKnown=true,professions={Tailoring={skill=300}}}
assert(A.UseEligibility(cloth,priest)==true and A.UseEligibility(hood,priest)==false)
local warrior={class='WARRIOR',level=39,professionsKnown=true,professions={}}
local plate
for _,r in ipairs(A.Rewards)do local m=A.ItemRequirements[r.id];if m and m.classID==4 and m.subclassID==4 and m.level<=40 then plate=r;break end end
-- Isolate the armor threshold from an item's own level requirement.
A.ItemRequirements[99991]={known=true,level=1,classID=4,subclassID=4};local lowPlate={id=99991,name='Plate',profession='Blacksmithing'}
assert(A.UseEligibility(lowPlate,warrior)==false);warrior.level=40;assert(A.UseEligibility(lowPlate,warrior)==true)
local unknown={id=0,name='Unknown',profession='Unknown'};assert(A.UseEligibility(unknown,hunter)==nil)
local opts={profession='Leatherworking',usable=true,skill=false}
local rows,summary=A.FilterRewards(A.Rewards,hunter,opts);assert(#rows>0)
for _,r in ipairs(rows)do assert(r.reward.profession=='Leatherworking'and r.usable==true)end
opts.skill=true;rows=A.FilterRewards(A.Rewards,hunter,opts)
for _,r in ipairs(rows)do assert(r.skilled and r.usable)end
opts={profession='all',usable=false,skill=false};rows=A.FilterRewards(A.Rewards,hunter,opts);assert(#rows==#A.Rewards)
opts={profession='mine',usable=false,skill=false};rows=A.FilterRewards(A.Rewards,hunter,opts)
for _,r in ipairs(rows)do assert(hunter.professions[r.reward.profession])end
opts={profession='all',usable=true,skill=false,armor=1};rows=A.FilterRewards(A.Rewards,priest,opts)
for _,r in ipairs(rows)do assert(A.ItemRequirements[r.reward.id].subclassID==1)end
opts.search='no such item';assert(#A.FilterRewards(A.Rewards,hunter,opts)==0)
local noData={professions={},professionsKnown=false};assert(A.SkillEligibility(hood,noData)==nil)
print('PASS: modern profession holes, localized legacy skills, missing APIs, class/level armor rules, skill gates, unknown data, mine/all/profession + armor + text filters.')
-- A partially failing provider is unknown, not proof a profession is unlearned.
GetProfessions=function()return 1,2 end
GetProfessionInfo=function(i)if i==1 then return 'Engineering',nil,109,150,nil,nil,202 end;error('not ready')end
p=A.ReadCharacter();assert(not p.professionsKnown and p.professions.Engineering.skill==109)
assert(A.SkillEligibility(hood,p)==nil)
GetProfessionInfo=function()return nil end
assert(not A.ReadCharacter().professionsKnown)
GetNumSkillLines=function()return 1 end
GetSkillLineInfo=function()error('not ready')end
assert(not A.ReadCharacter().professionsKnown)
GetSkillLineInfo=function()return 'Alchimie',false,nil,75,nil,nil,150 end
assert(A.ReadCharacter().professionsKnown and A.ReadCharacter().professions.Alchemy.skill==75)
print('PASS: partial and nil profession responses remain unverified; complete legacy fallback recovers.')
