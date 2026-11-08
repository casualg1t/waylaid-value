local A={}
assert(loadfile('addon/WaylaidValue/RewardsData.lua'))('WaylaidValue',A)
local function quote(s)return '"'..s:gsub('\\','\\\\'):gsub('"','\\"'):gsub('\n','\\n'):gsub('\r','\\r'):gsub('\t','\\t')..'"'end
local function encode(v)
 if type(v)=='string'then return quote(v)end
 if type(v)=='number'or type(v)=='boolean'then return tostring(v)end
 if type(v)~='table'then return 'null'end
 local result={}
 if next(v)==nil or #v>0 then
  for _,x in ipairs(v)do result[#result+1]=encode(x)end
  return '['..table.concat(result,',')..']'
 end
 for k,x in pairs(v)do result[#result+1]=quote(tostring(k))..':'..encode(x)end
 return '{'..table.concat(result,',')..'}'
end
if arg and(arg[1]=='requirements'or arg[1]=='preview')then
 assert(loadfile('addon/WaylaidValue/ItemRequirements.lua'))('WaylaidValue',A)
 if arg[1]=='preview'then
  assert(loadfile('addon/WaylaidValue/Eligibility.lua'))('WaylaidValue',A)
  local profile={class='HUNTER',level=26,professionsKnown=true,professions={Leatherworking={skill=109},Cooking={skill=2}}}
  for _,reward in ipairs(A.Rewards)do
   local meta=A.ItemRequirements[reward.id]or {};A.ItemRequirements[reward.id]=meta
   meta.usable=A.UseEligibility(reward,profile)==true;meta.skilled=A.SkillEligibility(reward,profile)==true
  end
 end
 print(encode(A.ItemRequirements))
else print(encode(A.Rewards))end
