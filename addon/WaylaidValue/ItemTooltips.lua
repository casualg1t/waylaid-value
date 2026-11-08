local _,A=...
local crates={}
for _,crate in ipairs(A.Crates)do crates[crate.id]=crate end
local function add(t,label,value)
 if t.AddDoubleLine then t:AddDoubleLine(label,value,.90,.86,.78,.90,.86,.78)
 else t:AddLine(label..': '..value,.90,.86,.78,true)end
end
function A.AppendCrateTooltip(t,data)
 local db=WaylaidValueDB
 if not db or db.tooltipMode=='off'or not t or(t.IsForbidden and t:IsForbidden())then return end
 local owner=t.GetOwner and t:GetOwner()
 if owner and owner.wvTooltipKind then return end -- addon window already owns its cost breakdown
 local id=data and data.id
 if not id and t.GetItem then local _,link=t:GetItem();id=type(link)=='string'and tonumber(link:match('item:(%d+)'))end
 local crate=crates[id]
 if not crate or t.wvCrateSection then return end
 t.wvCrateSection=true
 local detailed=db.tooltipMode=='always'or(db.tooltipMode~='compact'and IsShiftKeyDown and IsShiftKeyDown())
 local read=A.PriceReader(db.source)
 local row=A.Rank({crate},read,true)[1]
 t:AddLine(' ');t:AddLine('Waylaid Value · '..(crate.favor and(crate.favor..' Favor')or 'Favor unknown'),1,.82,.40)
 if crate.provisional then t:AddLine('Expert reward is unverified.',1,.7,.4,true)end
 if row.best then
  add(t,'Fill: '..row.best.item.quantity..' × '..A.ItemName(row.best.item.id,row.best.item.name),A.Money(row.best.total,true))
 else t:AddLine('Filling prices missing. Update your price source or scan at the AH.',.75,.72,.65,true)end
 if row.net then add(t,'Buy crate + fill · net',A.Money(row.net,true))
 elseif not row.price then t:AddLine('Empty-crate price missing; net total unavailable.',.75,.72,.65,true)end
 if detailed then
  if row.price then add(t,'Empty crate',A.Money(row.price.value,true))end
  for _,part in ipairs(row.options)do
   if part~=row.best then add(t,part.item.quantity..' × '..A.ItemName(part.item.id,part.item.name),part.total and A.Money(part.total,true)or 'Price missing')end
  end
  if row.gross then add(t,'Upfront / turn-in money',A.Money(row.gross,true)..' / '..A.Money(row.silver,true))end
  t:AddLine('Choose one bundle. Full market costs include owned items. Turn-in money assumes 50 copper per base Favor; bonuses excluded.',.71,.68,.61,true)
 elseif db.tooltipMode~='compact'then t:AddLine('Hold Shift and hover again for all filling options.',.71,.68,.61,true)end
 local sources,seen,oldest={},{},nil
 local function source(p)
  if p and not seen[p.source]then seen[p.source]=true;sources[#sources+1]=p.source end
  if p and p.scannedAt then oldest=math.min(oldest or p.scannedAt,p.scannedAt)end
 end
 source(row.price);source(row.best and row.best.price)
 if #sources>0 then t:AddLine(table.concat(sources,' + '),.71,.68,.61,true)end
 if oldest and date then t:AddLine('Scan: '..date('%d %b %H:%M',oldest)..' · stock may have changed.',.71,.68,.61,true)
 elseif #sources>0 then t:AddLine('Cached unit-price estimates; stock is unverified.',.71,.68,.61,true)end
end
function A.InitItemTooltips()
 if A.itemTooltipsReady then return end
 local function append(t,data)
  if t~=GameTooltip and t~=ItemRefTooltip then return end
  pcall(A.AppendCrateTooltip,t,data)
 end
 local function clear(t)t.wvCrateSection=nil end
 for _,t in ipairs({GameTooltip or false,ItemRefTooltip or false})do
  if t and t.HookScript then
   t:HookScript('OnTooltipCleared',clear)
   if hooksecurefunc and t.ClearLines then hooksecurefunc(t,'ClearLines',clear)end
  end
 end
 if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
  TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item,append);A.itemTooltipsReady=true
 else
  for _,t in ipairs({GameTooltip or false,ItemRefTooltip or false})do
   if t and t.HasScript and t:HasScript('OnTooltipSetItem')then t:HookScript('OnTooltipSetItem',append);A.itemTooltipsReady=true end
  end
 end
end
