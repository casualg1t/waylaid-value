-- Narrow WoW frame API double: callback wiring only, never a visual renderer.
local A, objects = {}, {}
local methods={}
for name in ("SetPoint SetWidth SetSize SetJustifyH SetTextColor SetColorTexture SetTexture SetTexCoord SetAllPoints SetBackdrop SetBackdropColor SetBackdropBorderColor SetScale SetFrameStrata SetClampedToScreen SetMovable EnableMouse RegisterForDrag RegisterEvent SetWordWrap StartMoving StopMovingOrSizing SetOwner SetItemByID AddLine SetAutoFocus SetNumeric ClearFocus SetFontObject SetTextInsets SetAlpha SetFont"):gmatch("%S+") do methods[name]=function()end end
for name in ("SetFrameLevel RegisterForClicks SetHighlightTexture ClearAllPoints SetVertexColor"):gmatch("%S+") do methods[name]=function()end end
local new
new=function(kind,name,parent)
  local o={kind=kind,name=name,parent=parent,shown=true,scripts={},height=258,scroll=0}
  setmetatable(o,{__index=methods})
  objects[#objects+1]=o
  return o
end
function methods:SetScript(event,fn)self.scripts[event]=fn end
function methods:HookScript(event,fn)local prior=self.scripts[event];self.scripts[event]=function(self,...)if prior then prior(self,...)end;fn(self,...)end end
function methods:SetMotionScriptsWhileDisabled(on)self.motionWhileDisabled=on end
function methods:SetOwner(owner)self.owner=owner end
function methods:IsOwned(owner)return self.owner==owner end
function methods:CreateFontString()return new("FontString",nil,self)end
function methods:CreateTexture()return new("Texture",nil,self)end
function methods:SetText(value)self.value=tostring(value or "")end
function methods:SetTextColor(r,g,b)self.textColor={r,g,b}end
function methods:GetText()return self.value end
function methods:SetHeight(value)self.height=value end
function methods:GetHeight()return self.height end
function methods:GetWidth()return self.width or 1280 end
function methods:SetSize(w,h)self.width=w;self.height=h end
function methods:SetPoint(...)self.point={...} end
function methods:SetWidth(w)self.width=w end
function methods:GetFont()return "Fonts/FRIZQT__.TTF",12,"" end
function methods:SetEnabled(v)self.enabled=v end
function methods:Enable()self.enabled=true end
function methods:Disable()self.enabled=false end
function methods:SetVerticalScroll(value)self.scroll=value end
function methods:GetVerticalScroll()return self.scroll end
function methods:SetScrollChild(child)self.child=child end
function methods:IsShown()return self.shown end
function methods:Hide()local before=self.shown;self.shown=false;if before and self.scripts.OnHide then self.scripts.OnHide(self)end end
function methods:Show()
  local before=self.shown;self.shown=true
  if not before and self.scripts.OnShow then self.scripts.OnShow(self) end
end
function methods:SetShown(value)if value then self:Show() else self:Hide() end end
function methods:SetChecked(value)self.checked=value end
function methods:GetChecked()return self.checked end
function methods:SetAlpha(v)self.alpha=v end
function methods:EnableMouse(v)self.mouse=v end
CreateFrame=function(kind,name,parent,template)
 local o=new(kind,name,parent)
 if template=='UIPanelScrollFrameTemplate' then
  local bar=new('Slider',nil,o);o.ScrollBar=bar
  bar.ScrollUpButton=new('Button',nil,bar);bar.ScrollDownButton=new('Button',nil,bar)
  local thumb,background=new('Texture',nil,bar),new('Texture',nil,bar)
  bar.GetThumbTexture=function()return thumb end
  bar.GetRegions=function()return thumb,background end
 end
 return o
end
UIParent=new("Frame");UIParent.width=1280;UIParent.height=900;GameTooltip=new("Tooltip");UISpecialFrames={};SlashCmdList={}
UnitLevel=function()return 60 end;date=function()return "12:00"end
local fixture=dofile("tests/snapshot.lua")
TSM_API={GetCustomPriceValue=function(_,item)return fixture[tonumber(item:match("i:(%d+)"))]end}
for _,name in ipairs({"Data","Scan","Prices","Ranking","RewardsData","Rewards","ItemNames","ItemRequirements","Eligibility","Widgets","ItemTooltips","RewardsUI","UI","Minimap","Core"}) do assert(loadfile("addon/WaylaidValue/"..name..".lua"))("WaylaidValue",A) end
for _,o in ipairs(objects) do if o.scripts.OnEvent then o.scripts.OnEvent(o,"ADDON_LOADED","WaylaidValue") end end
assert(type(SlashCmdList.WAYLAIDVALUE)=="function")
SlashCmdList.WAYLAIDVALUE()
local frame
for _,o in ipairs(objects) do if o.name=="WaylaidValueFrame" then frame=o end end
assert(frame and frame:IsShown() and #frame.listRows==22)
assert(frame.listRows[1].data.crate.id==248705)
assert(frame:GetWidth()==900 and frame:GetHeight()==730)
assert(frame.scroll:GetHeight()==288)
assert(frame.listRows[1].net:GetText()==A.Money(1303,true))
assert(frame.listRows[1].ratio:GetText()=="65.2|cffeda55fc|r per Favor")
assert(frame.listRows[1].net.point[2]+frame.listRows[1].net:GetWidth()<=840)
assert(frame.detail.options[5].point[3]-frame.detail.options[5]:GetHeight()>=-190)
frame.listRows[2].scripts.OnClick(frame.listRows[2])
assert(frame.detail.title:GetText():match("Journeyman Parts"))
local initial=#objects
A.Refresh();assert(#objects==initial) -- repeated refresh does not leak frames
frame.source.scripts.OnClick(frame.source);assert(WaylaidValueDB.source=="TSM")
WaylaidValueDB.expert=true;A.Refresh();assert(#frame.listRows==30)
TSM_API=nil;A.Refresh();assert(frame.status:GetText():match("No compatible price addon"))
SlashCmdList.WAYLAIDVALUE();assert(not frame:IsShown())
SlashCmdList.WAYLAIDVALUE();assert(frame:IsShown())
frame.rewards:Show();frame.cratesPanel:Hide();frame.rewards:Refresh()
assert(frame.rewards.visibleCount==0 and frame.rewards.profile.professionsKnown==false)
frame.rewards.navButtons.all.scripts.OnClick()
frame.rewards.search:SetText("helm");frame.rewards.search.scripts.OnTextChanged()
frame.rewards.held:SetText("30");frame.rewards.held.scripts.OnTextChanged()
frame.rewards.learned:SetChecked(true);frame.rewards.learned.scripts.OnClick()
frame.rewards.search:SetText("no such reward test");frame.rewards.search.scripts.OnTextChanged()
frame.rewards.search:SetText("");frame.rewards.search.scripts.OnTextChanged()
fixture[3369]=633;fixture[8845]=7000;fixture[8925]=500
TSM_API={GetCustomPriceValue=function(_,item)return fixture[tonumber(item:match("i:(%d+)"))]end}
WaylaidValueDB.source="TSM"
frame.rewards.search:SetText("Caustic Smog Potion");frame.rewards.search.scripts.OnTextChanged()
frame.rewards.held:SetText("0");frame.rewards.learned:SetChecked(false)
frame.rewards:Refresh()
assert(frame.rewards.current.reward.name=="Caustic Smog Potion")
assert(frame.rewards.current.materials==15766)
assert(frame.rewards.detail.total:GetText()==A.Money(frame.rewards.current.plan.net+15766,true))
frame.rewards.learned:SetChecked(true);frame.rewards.learned.scripts.OnClick()
assert(frame.rewards.detail.total:GetText()==A.Money(15766,true) and frame.rewards.current.plan.net==0)
frame.rewards.learned:SetChecked(false);frame.rewards.held:SetText("180");frame.rewards.held.scripts.OnTextChanged()
assert(frame.rewards.current.needed==0 and frame.rewards.current.total==15766)
frame.rewards.search:SetText("no such reward test");frame.rewards.search.scripts.OnTextChanged()
assert(frame.rewards.current==nil and frame.rewards.detail.total:GetText()=="—")
frame.rewards.search:SetText("");frame.rewards.search.scripts.OnTextChanged()
-- Actual view controls preserve navigation, show complete names and update totals.
frame.crateTab.scripts.OnClick(frame.crateTab);assert(frame.cratesPanel:IsShown()and not frame.rewards:IsShown())
frame.rewardTab.scripts.OnClick(frame.rewardTab);assert(frame.rewards:IsShown()and not frame.cratesPanel:IsShown())
-- Native result/effect tooltips, with the character's crafting blocker appended.
local tooltipItem,tooltipSpell,tooltipLines
GameTooltip.SetItemByID=function(_,id)tooltipItem=id end
GameTooltip.SetSpellByID=function(_,id)tooltipSpell=id end
GameTooltip.AddLine=function(_,s)tooltipLines[#tooltipLines+1]=s end
tooltipLines={};frame.rewards.detail.inspect.scripts.OnEnter(frame.rewards.detail.inspect)
assert(tooltipItem==frame.rewards.current.reward.id)
local effect
for _,r in ipairs(A.Rewards)do if r.profession=='Enchanting'and r.spell and r.recipe==r.id then effect=r;break end end
assert(effect);local trigger=new('Button');A.UI.RewardTooltip(trigger,effect)
tooltipLines={};tooltipItem=nil;trigger.scripts.OnEnter(trigger)
assert(tooltipSpell==effect.spell and tooltipItem==nil)
assert(table.concat(tooltipLines,' '):match('Profession data unavailable'))
GameTooltip.SetSpellByID=nil;GameTooltip.SetHyperlink=function(_,link)tooltipSpell=link end
trigger.scripts.OnEnter(trigger);assert(tooltipSpell=='spell:'..effect.spell)
GameTooltip.AddLine=function()end
print('PASS: crafted-output and enchant-effect tooltips, spell-link fallback and character requirement explanations.')
-- Exercise the approved navigation using actual buttons and filter callbacks.
local rewards=frame.rewards
UnitClass=function()return 'Hunter','HUNTER'end;UnitLevel=function()return 20 end
local skill=109
GetProfessions=function()return 1,nil,nil,4 end
GetProfessionInfo=function(i)if i==1 then return 'Engineering',nil,skill,150,nil,nil,202 else return 'Cooking',nil,2,75,nil,nil,185 end end
rewards:Refresh();rewards.navButtons.mine.scripts.OnClick()
assert(rewards.options.usable and rewards.options.skill and rewards.visibleCount==5)
assert(not rewards.noProfessions.wvHelpHit:IsShown())
for _,entry in ipairs(rewards.visible)do assert(entry.skilled and entry.usable and rewards.profile.professions[entry.reward.profession])end
assert(rewards.navButtons.Engineering:IsShown()and (not rewards.navButtons.Alchemy or not rewards.navButtons.Alchemy:IsShown()))
rewards.navButtons.others.scripts.OnClick();assert(rewards.navButtons.Alchemy:IsShown())
rewards.navButtons.Alchemy.scripts.OnClick();assert(not rewards.skill:GetChecked()and rewards.options.profession=='Alchemy'and rewards.visibleCount==0)
rewards.usable:SetChecked(false);rewards.usable.scripts.OnClick(rewards.usable);assert(rewards.visibleCount>0 and rewards.visibleCount<29)
rewards.role.scripts.OnClick(rewards.role);assert(rewards.options.role=='all'and rewards.visibleCount==29)
for _,entry in ipairs(rewards.visible)do assert(entry.reward.profession=='Alchemy'and entry.usable==false)end
rewards.navButtons.all.scripts.OnClick();assert(rewards.visibleCount==#A.Rewards and not rewards.usable:GetChecked()and not rewards.skill:GetChecked())
rewards.usable:SetChecked(true);rewards.usable.scripts.OnClick(rewards.usable)
rewards.armor.scripts.OnClick(rewards.armor);assert(rewards.options.armor==1)
for _,entry in ipairs(rewards.visible)do assert(A.RewardRequirements(entry.reward).subclassID==1 and entry.usable)end
rewards.search:SetText('no such item');rewards.search.scripts.OnTextChanged();assert(rewards.current==nil and not rewards.detail.inspect:IsShown())
rewards.search:SetText('');rewards.search.scripts.OnTextChanged()
-- Cycle the fallback armor selector back to All, then select our profession.
for i=1,4 do rewards.armor.scripts.OnClick(rewards.armor)end
rewards.navButtons.mine.scripts.OnClick();assert(rewards.visibleCount==5)
local objectCount=#objects;rewards:Refresh();assert(#objects==objectCount)
skill=1
for _,o in ipairs(objects)do if o.scripts.OnEvent then o.scripts.OnEvent(o,'SKILL_LINES_CHANGED')end end
assert(rewards.visibleCount==0 and rewards.current==nil)
skill=109;rewards:Refresh();assert(rewards.visibleCount==5)
-- Measure all three columns and their fixed controls within the original frame.
assert(rewards:GetWidth()==860 and rewards:GetHeight()==590)
assert(rewards.detail.point[2]+rewards.detail:GetWidth()==860)
assert(rewards.skill.point[2]+rewards.skill:GetWidth()<=860)
assert(-rewards.detail.point[3]+rewards.detail:GetHeight()==590)
for _,b in pairs(rewards.navButtons)do if b:IsShown()then assert(-b.point[3]+b:GetHeight()<=590)end end
for _,b in ipairs(rewards.detailRows)do assert(b.amount.point[2]+b.amount:GetWidth()<=430 and b.name.point[2]+b.name:GetWidth()<b.amount.point[2])end
assert(-rewards.detailScroll.point[3]+rewards.detailScroll:GetHeight()<=492)
GetProfessions=function()return nil end;rewards:Refresh();rewards.navButtons.mine.scripts.OnClick()
assert(rewards.noProfessions:IsShown()and rewards.visibleCount==0)
rewards.navButtons.all.scripts.OnClick();assert(rewards.visibleCount==#A.Rewards)
GetProfessions=nil;GetProfessionInfo=nil;UnitClass=nil;UnitLevel=function()return 60 end
rewards:Refresh()
print('PASS: native own/other/all navigation, combined filters, empty recovery, live skill refresh, frame reuse and three-column/control bounds.')
assert(A.ItemName(3369)=="Grave Moss" and A.ItemName(8925)=="Crystal Vial")
local menuItems={}
UIDropDownMenu_Initialize=function(_,fn)menuItems={};fn()end
UIDropDownMenu_CreateInfo=function()return {}end
UIDropDownMenu_AddButton=function(info)menuItems[#menuItems+1]=info end
ToggleDropDownMenu=function()end
frame.source.scripts.OnClick(frame.source);assert(#menuItems==4)
menuItems[3].func();assert(WaylaidValueDB.source=="Auctionator")
menuItems[1].func();assert(WaylaidValueDB.source=="Auto")
frame.rewards.armor.scripts.OnClick(frame.rewards.armor);assert(#menuItems==5)
menuItems[2].func();assert(frame.rewards.options.armor==1)
menuItems[1].func();assert(frame.rewards.options.armor==nil and frame.rewards.visibleCount==#A.Rewards)
frame.rewards.role.scripts.OnClick(frame.rewards.role);assert(#menuItems==7)
menuItems[5].func();assert(frame.rewards.options.role=='healing')
for _,entry in ipairs(frame.rewards.visible)do assert(A.RoleMatch(entry.reward,frame.rewards.profile,'healing'))end
menuItems[2].func();assert(frame.rewards.options.role=='all'and frame.rewards.visibleCount==#A.Rewards)
local row=frame.rewards.listRows[2];row.scripts.OnClick(row)
assert(frame.rewards.current.reward==row.reward and frame.rewards.detail.title:GetText()==row.reward.name)
UIDropDownMenu_Initialize=nil;ToggleDropDownMenu=nil
local requests,callbacks=0,{}
C_Item={GetItemInfo=function()return nil end,RequestLoadItemDataByID=function()requests=requests+1 end}
C_Timer={After=function(_,fn)callbacks[#callbacks+1]=fn end}
assert(A.ItemName(3369)=="Grave Moss");assert(A.ItemName(3369)=="Grave Moss");assert(requests==1)
local event
for _,o in ipairs(objects)do if o.scripts.OnEvent then event=o end end
event.scripts.OnEvent(event,"GET_ITEM_INFO_RECEIVED",3369)
event.scripts.OnEvent(event,"GET_ITEM_INFO_RECEIVED",8925)
assert(#callbacks==1);C_Item.GetItemInfo=function(id)return id==3369 and "Localized Grave Moss"or nil end
callbacks[1]();assert(A.ItemName(3369)=="Localized Grave Moss")
C_Item=nil;C_Timer=nil
Minimap=new("Frame");Minimap.GetWidth=function()return 160 end
Minimap.GetEffectiveScale=function()return 1 end;Minimap.GetCenter=function()return 200,200 end
GetCursorPosition=function()return 200,300 end
A.CreateMinimapButton();assert(A.minimapButton and A.minimapButton:IsShown())
local count=#objects;A.CreateMinimapButton();assert(#objects==count)
local launch=A.minimapButton;launch.scripts.OnClick(launch);assert(not frame:IsShown())
launch.scripts.OnClick(launch);assert(frame:IsShown())
launch.scripts.OnDragStart(launch);assert(launch.scripts.OnUpdate)
launch.scripts.OnUpdate();assert(math.abs(WaylaidValueDB.minimap.angle-90)<0.01)
launch.scripts.OnDragStop(launch);assert(not launch.scripts.OnUpdate)
print("PASS: minimap crate launcher creates once, opens/closes, saves drag angle, stops drag updates.")
print("PASS: native layout bounds, net total/per-Favor hierarchy, Rewards displayed totals, held/learned inputs, dropdown choices, fallback/localized names and debounced item data updates.")
print("PASS: actual UI callback wiring, slash launcher, selection, refresh reuse, source switch, Expert toggle data, no-provider state, close/reopen. Rendering unverified.")
-- Same selection preserves the manual learned flag; another selection clears it.
local r=frame.rewards
r:ChooseProfession('all');r.search:SetText('');r.search.scripts.OnTextChanged()
local first=r.listRows[1];first.scripts.OnClick(first)
r.learned:SetChecked(true);first.scripts.OnClick(first);assert(r.learned:GetChecked())
r.listRows[2].scripts.OnClick(r.listRows[2]);assert(not r.learned:GetChecked())
-- Recipe-less entries must not inherit the previous tooltip's item lines.
local clears=0;GameTooltip.ClearLines=function()clears=clears+1 end
local unknown=new('Button');A.UI.RewardTooltip(unknown,{id=0,name='Unknown',profession='Unknown'})
unknown.scripts.OnEnter(unknown);assert(clears==1)
-- Emulate Lua 5.1 math.atan: it ignores a second argument. Test all quadrants.
local atan,atan2=math.atan,math.atan2
math.atan=function(y)return atan(y)end;math.atan2=nil
for _,v in ipairs({{300,200,0},{300,300,45},{200,300,90},{100,300,135},{100,200,180},{100,100,225},{200,100,270},{300,100,315}})do
 GetCursorPosition=function()return v[1],v[2]end
 launch.scripts.OnDragStart(launch);launch.scripts.OnUpdate()
 assert(math.abs(WaylaidValueDB.minimap.angle%360-v[3])<0.001)
 launch.scripts.OnDragStop(launch)
end
math.atan,math.atan2=atan,atan2
-- Real large plans need room for five-digit quantities, not the old 32px field.
for _,b in ipairs(r.detailRows)do assert(b.qty:GetWidth()==56 and b.icon.holder.point[2]>b.qty:GetWidth())end
print('PASS: selection ownership preservation, tooltip clearing, Lua 5.1 minimap quadrants and shopping quantity bounds.')
launch.scripts.OnDragStart(launch);launch:Hide();assert(not launch.scripts.OnUpdate);launch:Show()
local saved=WaylaidValueDB
for _,bad in ipairs({false,'broken',17})do
 WaylaidValueDB=bad;event.scripts.OnEvent(event,'ADDON_LOADED','WaylaidValue')
 assert(WaylaidValueDB.source=='Auto' and WaylaidValueDB.expert==false and WaylaidValueDB.minimap.angle==225)
end
WaylaidValueDB={source='Auctionator',expert=true,minimap={angle=-45}}
event.scripts.OnEvent(event,'ADDON_LOADED','WaylaidValue')
assert(WaylaidValueDB.source=='Auctionator'and WaylaidValueDB.expert and WaylaidValueDB.minimap.angle==315)
WaylaidValueDB={source='invalid',minimap={angle=0/0}};event.scripts.OnEvent(event,'ADDON_LOADED','WaylaidValue')
assert(WaylaidValueDB.source=='Auto'and WaylaidValueDB.minimap.angle==225)
WaylaidValueDB=saved
print('PASS: OnHide stops dragging; corrupt settings recover; valid source/Expert/minimap settings survive.')

assert(frame.scroll.ScrollBar.ScrollUpButton.alpha==0 and frame.scroll.ScrollBar.ScrollUpButton.mouse==false)
assert(frame.scroll.ScrollBar:GetThumbTexture():GetWidth()==4)
print('PASS: scrollbar template styling branch exercised with explicit template children (not native rendering).')
local v=frame.rewards
v.navButtons.all.scripts.OnClick();v.search:SetText("Brawler's Leather Belt");v.search.scripts.OnTextChanged()
assert(v.current.reward.id==252428 and v.detail.title.textColor[3]==0.87)
assert(v.listRows[1].name.textColor[1]==0 and v.listRows[1].name.textColor[3]==0.87)
assert(v.listRows[1].icon.holder and #frame.wvSkin.edge==9 and #frame.wvSkin.fill==9)
GetItemInfo=function()return 'Live name','link',4 end
local red,green,blue=A.UI.ItemColor(252428);assert(red==0.64 and blue==0.93)
GetItemInfo=nil
v.search:SetText('not an item');v.search.scripts.OnTextChanged();assert(not v.detail.icon.holder:IsShown())
assert(v.role.point[2]+v.role:GetWidth()<=860)
print('PASS: role dropdown callbacks, actual rarity-colored list/title, live rarity override, icon-frame hiding and reusable rounded skin.')
WaylaidValueDB.source='TSM'
v.search:SetText('Caustic Smog Potion');v:Refresh()
local priced=v.listRows[1]
assert(priced.reward.name=='Caustic Smog Potion'and priced.craft:GetText()==A.Money(15766,true))
assert(priced.craftCost.materials==v.current.materials and priced:GetHeight()==32)
assert(priced.name:GetWidth()==184 and priced.craft.point[2]+priced.craft:GetWidth()<=224)
v.held:SetText('180');v.held.scripts.OnTextChanged();v.learned:SetChecked(true);v.learned.scripts.OnClick()
assert(priced.craft:GetText()==A.Money(15766,true))
fixture[8845]=7100;v:Refresh();assert(priced.craft:GetText()==A.Money(15966,true)and v.current.materials==15966)
fixture[8845]=nil;v:Refresh();assert(priced.craft:GetText()=='Price missing'and v.current.materials==nil)
fixture[8845]=7000
local purchase;for _,reward in ipairs(A.Rewards)do if reward.purchase then purchase=reward;break end end
v.search:SetText(purchase.name);v:Refresh();assert(v.listRows[1].craft:GetText()=='—')
print('PASS: compact row craft quotes, refresh updates, held/learned independence, missing prices and direct rewards.')
-- Every clickable addon control and every menu choice supplies explanatory help.
local function inWindow(o)while o do if o==frame or o==A.minimapButton then return true end;o=o.parent end end
local buttons=0
for _,o in ipairs(objects)do
 if (o.kind=='Button'or o.kind=='CheckButton')and o.scripts.OnClick and inWindow(o)then
  assert(o.scripts.OnEnter and o.scripts.OnLeave and o.wvTooltipKind,'Clickable control without tooltip');buttons=buttons+1
 end
end
assert(buttons>20)
local lines={};GameTooltip.AddLine=function(_,line)lines[#lines+1]=line end
local function helpText(control)lines={};control.scripts.OnEnter(control);return table.concat(lines,' ')end
for _,o in ipairs(objects)do if o.wvTooltipKind=='help'and inWindow(o)then assert(#helpText(o)>10,'Empty explanatory tooltip')end end
local expertText=helpText(frame.expert)
assert(expertText:find('level%-20%+')and expertText:find('15 or 30')and expertText:find('unconfirmed')and expertText:find('documented tiers only'))
assert(frame.expert:GetWidth()==248 and frame.expert.motionWhileDisabled)
assert(v.noProfessions:IsShown()==v.noProfessions.wvHelpHit:IsShown())
assert(helpText(frame.refresh):find('does not scan')and helpText(frame.source):find('TSM'))
assert(helpText(v.learnedDisabledHelp):find('direct Favor purchase'))
assert(v.learnedDisabledHelp:IsShown()and v.learned.enabled==false)
v.search:SetText('not a real reward');v.search.scripts.OnTextChanged()
assert(helpText(v.heldDisabledHelp):find('Select a reward')and helpText(v.learnedDisabledHelp):find('Select a recipe'))
assert(v.heldDisabledHelp:IsShown()and v.learnedDisabledHelp:IsShown())
v.search:SetText('Caustic Smog Potion');v:Refresh()
assert(not v.learnedDisabledHelp:IsShown()and not v.heldDisabledHelp:IsShown())
local menu={};UIDropDownMenu_Initialize=function(_,fn)menu={};fn()end
UIDropDownMenu_CreateInfo=function()return{}end;UIDropDownMenu_AddButton=function(info)menu[#menu+1]=info end;ToggleDropDownMenu=function()end
for _,control in ipairs({frame.source,v.role,v.armor})do
 control.scripts.OnClick(control);assert(#menu>2)
 for _,info in ipairs(menu)do assert(info.tooltipTitle and #info.tooltipText>20 and info.tooltipOnButton)end
end
-- Header help does not turn clicking a row price into a dead area.
local priceHelp=frame.listRows[2].upfront.wvHelpHit
priceHelp.scripts.OnClick(priceHelp);assert(frame.detail.title:GetText():match('Journeyman Parts'))
-- Refreshes reuse help frames; an unrelated tooltip is not hidden by another control.
local objectCount=#objects;v:Refresh();v:Refresh();assert(#objects==objectCount)
helpText(frame.refresh);frame.source:Hide();assert(GameTooltip:IsShown())
frame.refresh:Hide();assert(not GameTooltip:IsShown());frame.refresh:Show();frame.source:Show()
assert(A.minimapButton.scripts.OnHide) -- help hooks preserve the drag-stop handler tested above
print('PASS: all clickable addon controls and menu choices have help; Expert meaning, disabled reasons, row click forwarding, reuse and tooltip ownership.')

-- Bag ownership is an annotation, never a free-price or ranking input.
local oldModern,oldLegacy=C_Item,GetItemCount
C_Item=nil;GetItemCount=nil;assert(A.BagCount(1)==nil)
GetItemCount=function(id,bank,charges)assert(bank==false and charges==false);return 0 end
assert(A.BagCount(1)==0)
C_Item={GetItemCount=function()error('not ready')end}
GetItemCount=function()return 3 end;assert(A.BagCount(1)==3)
for _,bad in ipairs({-1,0/0,math.huge,1.5,'3'})do
 C_Item.GetItemCount=function()return bad end;GetItemCount=nil;assert(A.BagCount(1)==nil)
end
C_Item=nil;GetItemCount=nil
frame.crateTab.scripts.OnClick(frame.crateTab)
local before={}
for i,b in ipairs(frame.listRows)do if b:IsShown()then before[i]={id=b.data.crate.id,net=b.data.net,rank=b.rank:GetText()}end end
local ownedID=before[2].id;local count=4
GetItemCount=function(id,bank,charges)assert(bank==false and charges==false);return id==ownedID and count or 0 end
local selectedTitle=frame.detail.title:GetText()
A.Refresh()
for i,prior in ipairs(before)do local b=frame.listRows[i];assert(b.data.crate.id==prior.id and b.data.net==prior.net and b.rank:GetText()==prior.rank)end
assert(frame.detail.title:GetText()==selectedTitle)
assert(frame.listRows[2].sub:GetText():find('In bags: 4'))
frame.listRows[2].scripts.OnClick(frame.listRows[2]);assert(frame.detail.subtitle:GetText():find('In bags: 4'))
C_Timer=nil;count=2;event.scripts.OnEvent(event,'BAG_UPDATE_DELAYED')
assert(frame.listRows[2].sub:GetText():find('In bags: 2')and frame.detail.subtitle:GetText():find('In bags: 2'))
count=0;event.scripts.OnEvent(event,'BAG_UPDATE_DELAYED');assert(not frame.listRows[2].sub:IsShown()and not frame.detail.subtitle:GetText():find('In bags:'))
C_Item,GetItemCount=oldModern,oldLegacy
print('PASS: guarded bag-only API counts and live bag changes; market ordering, costs and selection unchanged.')

-- Owned filling materials are visible for every option, without changing the best bundle.
local selected=frame.listRows[2]
local bestID=selected.data.best.item.id
local alternate=selected.data.options[#selected.data.options].item
local totals={};for i,b in ipairs(frame.listRows)do totals[i]={b.data.crate.id,b.data.net,b.data.best and b.data.best.item.id}end
local materialCount=2
GetItemCount=function(id)return id==bestID and materialCount or id==alternate.id and 999 or 0 end
A.Refresh()
for i,prior in ipairs(totals)do local row=frame.listRows[i].data;assert(row.crate.id==prior[1]and row.net==prior[2]and(row.best and row.best.item.id)==prior[3])end
assert(selected.bundleOwned:GetText():find('In bags: 2 /')and selected.bundleOwned:IsShown())
assert(frame.detail.options[1].name:GetText():find('In bags:')or frame.detail.options[2].name:GetText():find('In bags:'))
local foundAlternate=false
for i,part in ipairs(selected.data.options)do
 if part.item.id==alternate.id then assert(frame.detail.options[i].name:GetText():find('In bags: 999 /'));foundAlternate=true end
end
assert(foundAlternate)
local label,explanation=A.UI.BagNote(bestID,7);assert(label=='In bags: 2 / 7'and explanation:find('full market costs'))
materialCount=0;event.scripts.OnEvent(event,'BAG_UPDATE_DELAYED');assert(not selected.bundleOwned:IsShown())
GetItemCount=nil;assert(A.UI.BagNote(bestID,7)=='')
C_Item,GetItemCount=oldModern,oldLegacy
print('PASS: partial/full owned filling-material reminders, alternatives, bag refresh and unchanged best bundles/market totals.')
SlashCmdList.WAYLAIDVALUE('tooltip off');assert(WaylaidValueDB.tooltipMode=='off')
SlashCmdList.WAYLAIDVALUE('tooltip compact');assert(WaylaidValueDB.tooltipMode=='compact')
SlashCmdList.WAYLAIDVALUE('tooltip shift');assert(WaylaidValueDB.tooltipMode=='shift')
local started,stopped,chosen=0,0,nil
local oldStart,oldStop=A.StartScan,A.CancelScan
A.StartScan=function(reward)started=started+1;chosen=reward end
A.CancelScan=function()stopped=stopped+1 end
frame.rewardTab.scripts.OnClick(frame.rewardTab);frame.rewards.search:SetText('Caustic Smog Potion');frame.rewards:Refresh()
SlashCmdList.WAYLAIDVALUE('scan');assert(started==1 and chosen.id==frame.rewards.current.reward.id)
A.scanState.running=true;SlashCmdList.WAYLAIDVALUE('scan');assert(stopped==1)
SlashCmdList.WAYLAIDVALUE('stop');assert(stopped==2);A.scanState.running=false
A.StartScan,A.CancelScan=oldStart,oldStop
WaylaidValueDB.bagHints=false;GetItemCount=function()return 50 end;assert(A.BagCount(1)==nil)
WaylaidValueDB.bagHints=true;assert(A.BagCount(1)==50);GetItemCount=nil
print('PASS: slash scan/stop targets the selected reward; tooltip mode commands and bag-hint setting apply immediately.')
