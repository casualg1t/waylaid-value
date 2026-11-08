local A={}
for _,name in ipairs({"Data","Prices","Ranking","RewardsData","Rewards"}) do assert(loadfile("addon/WaylaidValue/"..name..".lua"))("WaylaidValue",A)end
local fixture=dofile("tests/snapshot.lua")
local function read(id)return fixture[id] and {value=fixture[id],source="test snapshot"} end
local rows=A.Rank(A.Crates,read,false,60)
local plan=A.PlanFavor(rows,30)
assert(plan.favor==30 and plan.net==2099 and plan.gross==3599)
assert(#plan.steps==2) -- 1x 20-Favor fabrics + 2x 5-Favor herbs, not 2x fabrics
local p35=A.PlanFavor(rows,31);assert(p35.favor>=31)
local learned=A.CostReward({favor=30,reagents={{id=765,quantity=2}}},read,rows,0,true)
assert(learned.plan.net==0 and learned.total==36 and learned.needed==0)
local held=A.CostReward({favor=30,reagents={{id=765,quantity=2}}},read,rows,25,false)
assert(held.needed==5 and held.plan.favor==5 and held.total==434)
local missing=A.CostReward({favor=30,reagents={{id=999999,quantity=1}}},read,rows,0,false)
assert(missing.total==nil and missing.materials==nil and missing.missing==1)
local noCost=A.CostReward({reagents={}},read,rows,0,false)
assert(noCost.total==nil and noCost.reason)
local enough=A.CostReward({favor=30,reagents={}},read,{},35,false)
assert(enough.total==0 and enough.leftover==5)
local unknown=A.CostReward({favor=30},read,rows,0,false);assert(unknown.total==nil)
-- Direct rewards cannot bypass their currency price with the recipe checkbox.
local mount=A.CostReward({favor=6000,reagents={},purchase=true},read,rows,0,true)
assert(mount.needed==6000 and mount.plan.favor>=6000)
-- Verify the exact optimizer against brute-force combinations with awkward overshoot.
local synthetic={
 {ratio=1,net=11,gross=21,silver=10,crate={id=1,favor=6}},
 {ratio=1,net=15,gross=25,silver=10,crate={id=2,favor=10}},
}
for target=1,45 do
 local best=math.huge
 for a=0,10 do for b=0,10 do if a*6+b*10>=target then best=math.min(best,a*11+b*15)end end end
 assert(A.PlanFavor(synthetic,target).net==best)
end
assert(A.PlanFavor({},30)==nil)
assert(A.PlanFavor({{ratio=1,net=-1,crate={favor=5}}},30)==nil)
assert(A.PlanFavor(rows,10001)==nil)
local helmet=A.CostReward({favor=30,reagents={{id=765,quantity=2},{id=2447,quantity=3}}},read,rows,0,false)
assert(helmet.materials==111 and helmet.total==2210 and helmet.upfront==3710)
local fee=A.CostReward({favor=200,reagents={},purchase=true,extraGoldUnknown=true},read,rows,0,false)
assert(fee.plan and fee.total==nil and fee.reason)
local seen={}
for _,r in ipairs(A.Rewards)do
 assert(r.name and r.profession)
 if r.spell then assert(not seen[r.spell]);seen[r.spell]=true end
 for _,part in ipairs(r.reagents or {})do assert(part.id>0 and part.quantity>0)end
end
print("PASS: exact 30-Favor mixed plan, overshoot vs brute force, held Favor, learned recipe, missing data, direct reward, 6000-Favor plan, catalog consistency.")
for _,bad in ipairs({math.huge,-math.huge,0/0,'1e999'})do
 local plan,why=A.PlanFavor(rows,bad);assert(not plan and why)
 local result=A.CostReward({favor=30,reagents={}},read,rows,bad,false)
 assert(not result.total and not result.plan and result.reason)
end
print('PASS: non-finite Favor inputs cannot produce free rewards or an invalid planner loop.')
local craft={reagents={{id=1,quantity=2},{id=2,quantity=3}}}
local craftQuote=A.CraftCost(craft,function(id)return {value=id==1 and 123 or 25}end)
assert(craftQuote.materials==321 and craftQuote.missing==0 and not craftQuote.plan)
craftQuote=A.CraftCost(craft,function(id)if id==1 then return{value=123}end end)
assert(craftQuote.materials==nil and craftQuote.missing==1)
assert(A.CraftCost({},function()error('No reagent to price')end).materials==nil)
print('PASS: craft-only material totals and missing quotes are independent of recipe unlocks.')
