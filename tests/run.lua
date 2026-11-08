local A={}
local function load(name) assert(loadfile("addon/WaylaidValue/"..name..".lua"))("WaylaidValue",A) end
load("Data");load("Prices");load("Ranking")
local prices=dofile("tests/snapshot.lua")
TSM_API={GetCustomPriceValue=function(source,item)
  assert(source=="dbminbuyout");return prices[tonumber(item:match("i:(%d+)"))]
end}
local read=A.PriceReader("Auto")
local rows=A.Rank(A.Crates,read,false,60)
assert(#A.Crates==30 and #rows==22)
assert(rows[1].crate.id==248705 and rows[1].best.item.id==4233)
assert(rows[1].best.item.quantity==2 and rows[1].gross==2303)
assert(rows[1].net==1303 and math.abs(rows[1].ratio-65.15)<0.00001)
local included=A.Rank(A.Crates,A.PriceReader("TSM"),true,60)
assert(#included==30)
local underlevel=A.Rank(A.Crates,A.PriceReader("TSM"),true,10)
for _,r in ipairs(underlevel) do if r.crate.level>10 then assert(not r.ratio and r.reason:match("Requires level")) end end
for _,r in ipairs(rows) do
  if r.best then for _,o in ipairs(r.options) do assert(not o.total or o.total>=r.best.total) end end
end
-- A fresh price read must change the winning combination.
prices[248705]=100000
assert(A.Rank(A.Crates,A.PriceReader("TSM"),false,60)[1].crate.id==248707)
prices[248705]=1055
-- Missing, zero, NaN, infinity and failing providers never become free purchases.
for _,bad in ipairs({0,-1,math.huge,0/0,"123"}) do
  TSM_API.GetCustomPriceValue=function()return bad end
  assert(A.PriceReader("TSM")(248705)==nil)
end
TSM_API.GetCustomPriceValue=function()error("not ready")end
Auctionator={API={v1={GetAuctionPriceByItemID=function(caller,id)
  assert(caller=="WaylaidValue" and type(id)=="number");return prices[id]
end,GetAuctionAgeByItemID=function()return 2 end}}}
local fallback,errors=A.PriceReader("Auto")
assert(fallback(248705).source=="Auctionator last scan" and fallback(248705).age==2 and errors.TSM)
assert(A.PriceReader("TSM")(248705)==nil) -- explicit source never silently falls back
TSM_API=nil;Auctionator=nil
local empty=A.Rank(A.Crates,A.PriceReader("Auto"),true,60)
for _,r in ipairs(empty) do assert(r.ratio==nil and r.reason) end
-- Ties are deterministic and an unpriced alternative remains visible.
local custom={{id=1,name="test",level=10,favor=5,options={{id=3,quantity=2},{id=2,quantity=2},{id=4,quantity=1}}}}
local tie=A.Rank(custom,function(id) if id~=4 then return {value=100} end end,false,60)[1]
assert(tie.best.item.id==2 and tie.missing==1 and #tie.options==3)
assert(A.Money(2303)=="23s 3c" and A.Money(nil)=="--")
assert(A.Money(12345,true)=='1|cffffd166g|r 23|cffc7c7cfs|r 45|cffeda55fc|r')
assert(A.Money(14,true)=='14|cffeda55fc|r'and A.Money(0,true)=='0|cffeda55fc|r')
assert(A.Money(-1000,true)=='-10|cffc7c7cfs|r')
-- Observed 20-Favor turn-in awards 10 silver; it must reduce net cost.
local checkedTurnIn=false
for _,r in ipairs(rows)do if r.crate.favor==20 and r.net then assert(r.silver==1000 and r.net==r.gross-1000);checkedTurnIn=true end end
assert(checkedTurnIn)
print("PASS: real snapshot integration, cheapest bundle, rewards, ordering, changed prices, levels, missing data, invalid prices, provider failure/fallback, explicit source, ties.")
local calls=0
TSM_API={GetCustomPriceValue=function()calls=calls+1;return nil end}
local cached=A.PriceReader('TSM');cached(1);cached(1);assert(calls==1)
A.PriceReader('TSM')(1);assert(calls==2)
for _,bad in ipairs({-1,0/0,math.huge,'2'})do
 Auctionator={API={v1={GetAuctionPriceByItemID=function()return 123 end,GetAuctionAgeByItemID=function()return bad end}}}
 assert(A.PriceReader('Auctionator')(1).age==nil)
end
print('PASS: missing prices cache once per refresh; malformed optional Auctionator ages remain unknown.')
