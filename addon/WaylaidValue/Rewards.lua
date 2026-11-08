local _, A = ...
-- Minimum net cost for a whole-crate plan reaching the target, with bounded overshoot.
-- Missing prices / level-gated crates have no ratio and cannot enter the plan.
function A.PlanFavor(rows,target)
  target=tonumber(target) or 0
  if target~=target or math.abs(target)==math.huge then return nil,"Enter a finite Favor target" end
  target=math.max(0,math.ceil(target))
  if target==0 then return {net=0,gross=0,silver=0,favor=0,steps={}} end
  if target>10000 then return nil,"Favor target exceeds 10,000" end
  local choices,maxFavor={},0
  for _,row in ipairs(rows) do
    if row.ratio and not row.crate.provisional then
      if row.net<=0 then return nil,"A crate has a zero/negative net quote; verify prices before planning" end
      choices[#choices+1]=row;maxFavor=math.max(maxFavor,row.crate.favor)
    end
  end
  if #choices==0 then return nil,"No eligible crate has complete prices" end
  local cap=target+maxFavor-1
  local costs,previous,picked={[0]=0},{},{}
  for amount=1,cap do
    for _,row in ipairs(choices) do
      local from=amount-row.crate.favor
      if from>=0 and costs[from] then
        local cost=costs[from]+row.net
        if not costs[amount] or cost<costs[amount] then
          costs[amount]=cost;previous[amount]=from;picked[amount]=row
        end
      end
    end
  end
  local best
  for amount=target,cap do
    if costs[amount] and (not best or costs[amount]<costs[best]) then best=amount end
  end
  if not best then return nil,"No priced crate combination reaches this target" end
  local plan={net=costs[best],gross=0,silver=0,favor=best,steps={}}
  local counts,amount={},best
  while amount>0 do
    local row=picked[amount];local key=row.crate.id
    if not counts[key] then counts[key]={row=row,count=0};plan.steps[#plan.steps+1]=counts[key] end
    counts[key].count=counts[key].count+1
    plan.gross=plan.gross+row.gross;plan.silver=plan.silver+row.silver
    amount=previous[amount]
  end
  table.sort(plan.steps,function(a,b)return a.row.crate.id<b.row.crate.id end)
  return plan
end
function A.CostReward(reward,readPrice,crateRows,held,learned)
  local result={reward=reward,reagents={},missing=0,materials=0}
  if not reward.reagents then result.materials=nil;result.missing=1
  else
    for _,item in ipairs(reward.reagents) do
      local price=readPrice(item.id)
      local part={item=item,price=price,total=price and price.value*item.quantity}
      result.reagents[#result.reagents+1]=part
      if part.total then result.materials=result.materials+part.total else result.missing=result.missing+1 end
    end
    if result.missing>0 then result.materials=nil end
  end
  held=tonumber(held) or 0
  if held~=held or math.abs(held)==math.huge then result.reason="Enter a finite Favor balance";return result end
  held=math.max(0,math.floor(held))
  local cost=learned and not reward.purchase and 0 or reward.favor
  if cost then
    result.needed=math.max(0,cost-held)
    result.plan,result.reason=A.PlanFavor(crateRows,result.needed)
  else result.reason="Recipe Favor price not verified" end
  if result.plan then result.leftover=held+result.plan.favor-cost end
  if result.plan and result.materials then
    result.total=result.plan.net+result.materials
    result.upfront=result.plan.gross+result.materials
  end
  if reward.extraGoldUnknown then
    result.total=nil;result.upfront=nil;result.reason="Additional vendor gold charge not verified"
  end
  return result
end
