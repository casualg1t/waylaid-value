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
 for k,x in pairs(v)do result[#result+1]=quote(k)..':'..encode(x)end
 return '{'..table.concat(result,',')..'}'
end
print(encode(A.Rewards))
