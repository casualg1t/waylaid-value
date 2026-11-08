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
for _,name in ipairs({"Data","Prices","Ranking","RewardsData","Rewards","ItemNames","ItemRequirements","Eligibility","Widgets","RewardsUI","UI","Minimap","Core"}) do assert(loadfile("addon/WaylaidValue/"..name..".lua"))("WaylaidValue",A) end
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
frame.source.scripts.OnClick(frame.source);assert(#menuItems==3)
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
