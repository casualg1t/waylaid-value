local A={};for _,name in ipairs({'Data','Ranking','ItemTooltips'})do assert(loadfile('addon/WaylaidValue/'..name..'.lua'))('',A)end
A.ItemName=function(_,name)return name end
local prices=dofile('tests/snapshot.lua')
A.PriceReader=function()return function(id)return prices[id]and{value=prices[id],source='TSM minimum buyout'}end end
WaylaidValueDB={source='TSM',tooltipMode='shift'}
local shift=false;IsShiftKeyDown=function()return shift end
local t={lines={},scripts={}}
function t:AddLine(line)self.lines[#self.lines+1]=line end
function t:AddDoubleLine(a,b)self:AddLine(a..' = '..b)end
function t:ClearLines()self.lines={};self.wvCrateSection=nil end
function t:GetItem()return 'Any name','item:248686:0'end
function t:IsForbidden()return self.forbidden end
function t:GetOwner()return self.owner end
function t:HookScript(name,fn)self.scripts[name]=fn end
function t:HasScript(name)return name=='OnTooltipSetItem'end
GameTooltip=t
hooksecurefunc=function(table,key,fn)local prior=table[key];table[key]=function(...)prior(...);fn(...)end end
A.InitItemTooltips();assert(t.scripts.OnTooltipSetItem and t.scripts.OnTooltipCleared)
local function text()return table.concat(t.lines,'\n')end
t.scripts.OnTooltipSetItem(t)
assert(text():find('10 Favor')and text():find('Buy crate %+ fill')and text():find('Hold Shift'))
local n=#t.lines;t.scripts.OnTooltipSetItem(t);assert(#t.lines==n)
t:ClearLines();shift=true;t.scripts.OnTooltipSetItem(t)
assert(text():find('Kingsblood')and text():find('bonuses excluded'))
t:ClearLines();WaylaidValueDB.tooltipMode='compact';t.scripts.OnTooltipSetItem(t);assert(not text():find('Kingsblood')and not text():find('Hold Shift'))
t:ClearLines();WaylaidValueDB.tooltipMode='off';t.scripts.OnTooltipSetItem(t);assert(#t.lines==0)
WaylaidValueDB.tooltipMode='always';t.forbidden=true;t.scripts.OnTooltipSetItem(t);assert(#t.lines==0);t.forbidden=false
t.owner={wvTooltipKind='item'};t.scripts.OnTooltipSetItem(t);assert(#t.lines==0);t.owner=nil
local callback;TooltipDataProcessor={AddTooltipPostCall=function(_,fn)callback=fn end};Enum={TooltipDataType={Item=0}}
A.itemTooltipsReady=false;A.InitItemTooltips();callback(t,{id=248686});assert(text():find('Kingsblood'))
t:ClearLines();callback(t,{id=1});assert(#t.lines==0) -- exact IDs only, never names shared by crate rarities
local stranger={};callback(stranger,{id=248686});assert(not stranger.wvCrateSection)
t:ClearLines();A.PriceReader=function()return function()end end;callback(t,{id=248686})
assert(text():find('prices missing')and text():find('net total unavailable'))
print('PASS: crate item tooltip modes, exact item IDs, modern/legacy hooks, deduplication, owner suppression and missing prices; hovering never scans.')
