local _,A=...
function A.BuildRewardsView(window)
 local U=A.UI
 local p=CreateFrame('Frame',nil,window);p:SetPoint('TOPLEFT',20,-106);p:SetSize(860,590)
 local selected=A.Rewards[1];local read,errors,stats;local listRows,detailRows={},{}
 local lastSelection,profile,filter,nav
 p.options={profession='mine',usable=true,skill=true,role='auto'};p.navButtons={}
 local order={'Alchemy','Blacksmithing','Cooking','Enchanting','Engineering','Leatherworking','Tailoring'}
 local icons={Alchemy='Trade_Alchemy',Blacksmithing='Trade_BlackSmithing',Cooking='INV_Misc_Food_15',Enchanting='Trade_Engraving',Engineering='Trade_Engineering',Leatherworking='Trade_LeatherWorking',Tailoring='Trade_Tailoring'}
 local others=false
 U.Fill(p,140,0,1,590,U.line,'BORDER')
 p.search=U.Edit(p,156,0,200,'Find a reward','Find a reward','Search item names and professions in the selected group. Search combines with the armor, role and requirement filters. Clear the text to restore other matches.')
 p.armor=U.Button(p,368,0,126,'All armor types',function()end,'Armor type','Restrict the list to cloth, leather, mail or plate. All armor types removes this restriction and includes non-armor rewards. My level / class still checks whether your character can use the item.')
 p.role=U.Button(p,506,0,172,'For my class',function()end)
 local function check(x,w,label,reason)
  local b=U.Check(p,x,-34,w,label,label,reason);b:SetChecked(true);return b
 end
 p.usable=check(156,150,'My level / class','Checks whether your character can use the item. Role relevance is a separate filter. Weapon training and reputation are not checked. Unverified requirements are hidden while this filter is on.')
 p.skill=check(320,180,'Within my skill','Match your learned profession and current crafting skill. Recipe ownership is not checked. Unverified skill requirements are hidden while this filter is on.')
 local count=U.Text(p,156,-74,132,'',nil,U.muted);p.count=count
 local craftHeader=U.Text(p,296,-74,84,'Craft',nil,U.muted,'RIGHT')
 U.HintText(p,craftHeader,'Craft cost','Material cost for one craft, excluding the recipe unlock. Some crafts produce several items; this is not a per-output-item price. Price missing means a reagent quote or crafting fact is unavailable. A dash marks a direct reward that is not crafted.')
 p.hiddenCount=U.Text(p,426,-74,434,'',nil,U.muted,'RIGHT')
 U.HintText(p,count,'Matching rewards','Number of rewards matching the selected profession, search and filters. Prices do not decide whether an item is shown. Sorted by required character level, lowest first, then name; unknown levels appear last. Row labels show level and Favor (F), separate from profession skill.')
 U.HintText(p,p.hiddenCount,'Hidden by filters','Items excluded by armor, role, level/class or crafting skill. Unverified means a required item/skill fact is missing. Broaden the filters or Browse all recipes to inspect more rewards; search and armor still apply.')
 local list,child=U.Scroll(p,156,-98,224,488)
 U.Fill(p,394,-98,1,492,U.line,'BORDER')
 local d=CreateFrame('Frame',nil,p);d:SetPoint('TOPLEFT',410,-98);d:SetSize(450,492);p.detail=d
 d.icon=U.Icon(d,0,0,0,32);d.title=U.Text(d,44,0,406,'','GameFontNormalLarge',nil,nil,16)
 d.inspect=CreateFrame('Button',nil,d);d.inspect:SetPoint('TOPLEFT',0,0);d.inspect:SetSize(450,44)
 d.meta=U.Text(d,44,-25,406,'',nil,U.muted)
 U.Text(d,0,-55,450,'Total net cost',nil,U.muted);d.total=U.Text(d,0,-74,450,'','GameFontNormalLarge',U.text,nil,24)
 d.unlockLabel=U.Text(d,0,-112,140,'Recipe unlock',nil,U.muted);d.unlock=U.Text(d,0,-131,140,'')
 U.Text(d,150,-112,280,'Materials · one craft',nil,U.muted);d.materials=U.Text(d,150,-131,280,'')
 U.Fill(d,0,-155,450,1,U.line,'BORDER')
 local heldHelp='Enter the Merchant\'s Favor you already have. It reduces the Favor still needed for the selected recipe or purchase. This amount is entered manually.'
 local function heldBody()return p.current and heldHelp or 'Select a reward before entering your current Favor balance.'end
 local function learnedBody()
  if not p.current then return 'Select a recipe first.'end
  if p.current.reward.purchase then return 'This is a direct Favor purchase, not a recipe. There is no learned-recipe unlock to remove.'end
  return 'Check this if you already know the selected recipe. Its one-time Favor unlock becomes zero; the cost of one craft\'s materials remains. Changing to another recipe clears this choice.'
 end
 local heldLabel=U.Text(d,0,-175,66,'Favor held',nil,U.muted);U.HintText(d,heldLabel,'Favor held',heldBody)
 p.held=U.Edit(d,66,-167,50,nil,'Favor held',heldBody);p.held:SetNumeric(true);p.held:SetText('0')
 p.learned=U.Check(d,270,-167,180,'Recipe already learned','Recipe already learned',learnedBody)
 -- Disabled widgets do not deliver hover on every client; show help-only hit areas then.
 p.heldDisabledHelp=U.Hint(d,66,-167,50,28,'Favor held',heldBody);p.heldDisabledHelp:Hide()
 p.learnedDisabledHelp=U.Hint(d,270,-167,180,28,'Recipe already learned',learnedBody);p.learnedDisabledHelp:Hide()
 d.totalHelp=U.Hint(d,0,-55,450,45,'Total net cost',function()
  if not p.current then return 'Select a reward to see its estimated recipe unlock and one-craft cost.'end
  local r=p.current
  return 'Remaining one-time Favor unlock, minus crate turn-in money, plus materials for one craft. Held Favor and Recipe already learned change the unlock only.\n\n'..(r.total and ('Estimated total: '..U.Money(r.total)..'.')or('Incomplete: '..(r.reason or 'A material quote or crafting fact is missing.')..' Check the details and update your price addon, then Refresh.'))
 end)
 U.Hint(d,0,-112,140,38,'Favor unlock cost','Estimated net gold to earn the remaining Favor with whole crates. It subtracts turn-in money and accounts for Favor held / Recipe already learned. Only documented crate tiers enter this plan. A direct reward uses its purchase Favor cost instead.')
 U.Hint(d,150,-112,280,38,'Materials for one craft','Required reagent quantities × cached unit buyout prices. Recipe unlock is separate. This is per craft, not necessarily per output item; owned materials and vendor alternatives are not deducted.')
 local scroll,detail=U.Scroll(d,0,-207,430,275)
 p.listRows=listRows;p.detailRows=detailRows;p.detailScroll=scroll
 local function draw(lines,reset)
  local y=0
  for i,line in ipairs(lines)do
   local b=detailRows[i]
   if not b then
    b=CreateFrame('Button',nil,detail);b:SetSize(430,34)
    b.qty=U.Text(b,0,-9,56,'',nil,U.muted,'RIGHT');b.icon=U.Icon(b,62,-5,0)
    b.name=U.Text(b,94,-9,223,'');b.amount=U.Text(b,322,-9,108,'',nil,U.text,'RIGHT')
    b.label=U.Text(b,0,-5,430,'',nil,U.muted);b.info=U.Text(b,200,-5,230,'',nil,U.muted,'RIGHT')
    b.line=U.Fill(b,0,-27,430,1,U.line,'BORDER');detailRows[i]=b
   end
   b:SetPoint('TOPLEFT',0,-y);b:Show();b:SetScript('OnEnter',nil);b:SetScript('OnLeave',nil)
   for _,widget in ipairs({b.qty,b.icon,b.name,b.amount,b.label,b.info,b.line})do widget:Hide()end
   local height=24
   if line.kind=='item'then
    height=34;b.qty:Show();b.icon:Show();b.name:Show();b.amount:Show()
    b.qty:SetText(line.quantity..' ×');U.SetIcon(b.icon,line.id);U.ItemText(b.name,line.id,A.ItemName(line.id,line.name));b.amount:SetText(line.total and U.Money(line.total)or 'Price missing')
    U.ItemTooltip(b,line.id,line.price)
   elseif line.kind=='section'then
    height=32;b.label:Show();b.label:SetWidth(195);b.label:SetTextColor((unpack or table.unpack)(U.gold));b.label:SetText(line.text)
    b.info:Show();b.info:SetText(line.info or '');b.line:Show()
    U.Help(b,line.text,line.text=='Crafting materials'and 'Materials needed for one craft. Quantities are priced at cached buyouts; owned inventory and output yields are not applied.'or 'An exact whole-crate plan for the remaining Favor. Buy each listed crate and its filling bundle, then turn them in manually. Extra Favor from whole crates is shown as left over. Quotes do not guarantee stock.')
   elseif line.kind=='total'then
    height=34;b.label:Show();b.label:SetWidth(310);b.label:SetTextColor((unpack or table.unpack)(U.muted));b.label:SetText(line.text)
    b.amount:Show();b.amount:SetText(line.total and U.Money(line.total)or 'Incomplete');b.line:Show()
    U.Help(b,'Gold needed upfront','Total gold needed to buy the crate plan and crafting materials before collecting turn-in money. This is higher than net cost because the turn-in money is received later.')
   else
    b.label:Show();b.label:SetWidth(430);b.label:SetTextColor((unpack or table.unpack)(U.muted));b.label:SetText(line.text)
    b.label:SetWordWrap(true);b.label:SetHeight(36);height=42
    U.Help(b,line.kind=='message'and 'Why this estimate is incomplete'or 'Estimate details',line.text)
   end
   if line.kind~='note'and line.kind~='message'then b.label:SetWordWrap(false);b.label:SetHeight(16)end
   b:SetHeight(height);y=y+height
  end
  for i=#lines+1,#detailRows do detailRows[i]:Hide()end
  detail:SetHeight(math.max(1,y));if reset then scroll:SetVerticalScroll(0)else U.ClampScroll(scroll,y,275)end
 end
 local function show()
  for _,b in ipairs(listRows)do b.selection:SetShown(b.reward==selected)end
  if not selected then
   p.current=nil;d.inspect:Hide();d.icon:Hide();d.title:SetText('No matching rewards');d.title:SetTextColor((unpack or table.unpack)(U.text));d.meta:SetText('Change the role, filters or profession.');d.unlockLabel:SetText('Recipe unlock')
   d.unlock:SetText('—');d.materials:SetText('—');d.total:SetText('—');p.learned:Disable();p.held:Disable();p.learnedDisabledHelp:Show();p.heldDisabledHelp:Show();draw({},true);return
  end
  d.icon:Show();U.SetIcon(d.icon,selected.id);p.learned:SetEnabled(not selected.purchase);p.held:Enable();p.learnedDisabledHelp:SetShown(selected.purchase==true);p.heldDisabledHelp:Hide()
  d.inspect:Show();U.RewardTooltip(d.inspect,selected)
  local r=A.CostReward(selected,read,p.crateRows,p.held:GetText(),p.learned:GetChecked())
  d.unlockLabel:SetText(selected.purchase and 'Favor purchase'or 'Recipe unlock')
  U.ItemText(d.title,selected.id,selected.name)
  local requirements=A.RewardRequirements(selected)
  local _,roleLabel=A.RewardRoles(selected)
  d.meta:SetText(selected.profession..(selected.skill and(' '..selected.skill)or '')..((requirements.level or 0)>0 and(' · level '..requirements.level..'+')or '')..' · '..roleLabel)
  d.unlock:SetText(r.plan and U.Money(r.plan.net)or 'Unverified')
  d.materials:SetText(selected.purchase and 'Not needed'or(r.materials and U.Money(r.materials)or 'Price missing'))
  d.total:SetText(r.total and U.Money(r.total)or 'Incomplete')
  local lines={}
  local function add(line)lines[#lines+1]=line end
  local usable,useReason=A.UseEligibility(selected,profile)
  local skilled,skillReason=A.SkillEligibility(selected,profile)
  if usable~=true then add({kind='message',text=useReason or 'Item requirements unverified.'})end
  if skilled~=true and not selected.purchase then add({kind='message',text=skillReason or 'Crafting skill unverified.'})end
  local crates=0;if r.plan then for _,step in ipairs(r.plan.steps)do crates=crates+step.count end end
  add({kind='section',text='Earn '..(r.needed or '?')..' Favor',info=r.plan and(crates..' crates · '..(r.leftover or 0)..' Favor left over')or 'Plan unavailable'})
  if r.plan then
   if #r.plan.steps==0 then add({kind='note',text=p.learned:GetChecked()and not selected.purchase and 'Recipe already learned. No crates needed.'or 'Your existing Favor covers this purchase. No crates needed.'})end
   for _,step in ipairs(r.plan.steps)do
    local row=step.row;local item=row.best.item
    add({kind='item',id=row.crate.id,name=row.crate.name,quantity=step.count,total=step.count*row.price.value,price=row.price})
    add({kind='item',id=item.id,name=item.name,quantity=item.quantity*step.count,total=step.count*row.best.total,price=row.best.price})
   end
   if crates>0 then add({kind='note',text=U.Money(r.plan.gross)..' upfront − '..U.Money(r.plan.silver)..' turn-in money'})end
  else add({kind='message',text=r.reason or 'No complete crate prices. Check the selected price addon, then Refresh.'})end
  if not selected.purchase then
   add({kind='section',text='Crafting materials',info='One craft'})
   if not selected.reagents then add({kind='message',text='Crafting data missing for this recipe.'})end
   for _,part in ipairs(r.reagents)do add({kind='item',id=part.item.id,quantity=part.item.quantity,total=part.total,price=part.price})end
  end
  add({kind='total',text='Gold needed upfront',total=r.upfront})
  add({kind='note',text='Recipe requirements: '..(selected.requirement or 'unverified')..' · level '..(selected.level or '?')..'+.'})
  if r.reason and r.plan then add({kind='message',text=r.reason})
  elseif r.missing>0 then add({kind='message',text='Complete material prices are needed before a total can be shown.'})
  elseif not selected.purchase then add({kind='note',text='One-time unlock + one craft. Further crafts: '..U.Money(r.materials)..' in materials.'})end
  draw(lines,lastSelection~=selected);lastSelection=selected
  p.current=r;A.UpdatePriceStatus(stats,errors,p.visibleCount..' / '..#A.Rewards..' rewards')
 end
 filter=function(reset)
  local query=p.search:GetText()or '';p.search.hint:SetShown(query=='');p.options.search=query
  local visible,summary=A.FilterRewards(A.Rewards,profile,p.options);p.visible=visible;p.summary=summary
  local found=false;for _,entry in ipairs(visible)do if entry.reward==selected then found=true end end
  if not found then selected=visible[1]and visible[1].reward;p.learned:SetChecked(false)end
  for i,entry in ipairs(visible)do
   local r=entry.reward
   local b=listRows[i]
   if not b then
    b=CreateFrame('Button',nil,child);b:SetSize(224,32);U.Row(b);b.selection=U.Fill(b,2,-2,220,28,U.selection)
    local hover=b:CreateTexture(nil,'HIGHLIGHT');hover:SetAllPoints();hover:SetColorTexture(0.85,0.74,0.45,0.06)
    b.icon=U.Icon(b,4,-4,0);b.name=U.Text(b,36,-2,184,'')
    b.favor=U.Text(b,36,-18,88,'',nil,U.muted)
    b.profession=U.Text(b,124,-18,6,'',nil,U.gold)
    b.craft=U.Text(b,130,-18,90,'',nil,U.text,'RIGHT')
    b:SetScript('OnClick',function(self)if selected~=self.reward then p.learned:SetChecked(false)end;selected=self.reward;show()end);listRows[i]=b
   end
   local reason=entry.usable~=true and entry.useReason or entry.skilled~=true and entry.skillReason
   b.reward=r;b:SetPoint('TOPLEFT',0,-(i-1)*34);b:Show();U.SetIcon(b.icon,r.id);U.ItemText(b.name,r.id,r.name)
   b.profession:SetText(reason and '!'or '')
   b.favor:SetText((entry.requiredLevel==0 and 'Lv —'or entry.requiredLevel and('Lv '..entry.requiredLevel)or 'Lv ?')..' · '..(r.favor or '?')..' F')
   b.craftCost=not r.purchase and A.CraftCost(r,read)or nil
   b.craft:SetText(r.purchase and '—'or(b.craftCost.materials and U.Money(b.craftCost.materials)or 'Price missing'))
   U.RewardTooltip(b,r,b.craftCost)
  end
  for i=#visible+1,#listRows do listRows[i]:Hide()end
  p.visibleCount=#visible;child:SetHeight(math.max(1,#visible*34));if reset then list:SetVerticalScroll(0)else U.ClampScroll(list,#visible*34,488)end
  count:SetText(#visible..' rewards')
  p.hiddenCount:SetText(summary.hidden>0 and(summary.hidden..' hidden by filters'..(summary.unknown>0 and(' · '..summary.unknown..' unverified')or ''))or '')
  show();A.UpdatePriceStatus(stats,errors,#visible..' / '..#A.Rewards..' rewards')
 end
 function p:ChooseProfession(group)
  self.options.profession=group
  if group=='all'then self.options.usable=false;self.options.skill=false;self.options.role='all';self.role:SetText('All roles')
  elseif group=='mine'then self.options.usable=true;self.options.skill=true;self.options.role='auto';self.role:SetText('For my class')
  elseif not profile.professions[group]then self.options.skill=false end
  self.usable:SetChecked(self.options.usable);self.skill:SetChecked(self.options.skill)
  nav();filter(true)
 end
 nav=function()
  for _,b in pairs(p.navButtons)do b:Hide()end
  local y=0
  local function button(key,label,small,icon,click)
   local b=p.navButtons[key]
   if not b then
    b=CreateFrame('Button',nil,p);b:SetSize(128,38)
    b.selection=U.Fill(b,0,0,128,38,U.selection)
    b.active=U.Fill(b,0,-6,2,26,{0.80,0.60,0.25,1},'ARTWORK')
    b.icon=U.Icon(b,4,-9,0,20);b.label=U.Text(b,4,-5,120,'');b.small=U.Text(b,30,-22,98,'',nil,U.muted)
    p.navButtons[key]=b
   end
   b:SetPoint('TOPLEFT',0,-y);b:Show();b.selection:SetShown(p.options.profession==key);b.active:SetShown(p.options.profession==key)
   b.label:SetText(label);b.label:ClearAllPoints();b.label:SetPoint('TOPLEFT',icon and 30 or 4,small and -5 or -12);b.label:SetWidth(icon and 98 or 120)
   b.small:SetText(small or '');b.small:SetShown(small~=nil);b.icon:SetShown(icon~=nil)
   if icon then b.icon:SetTexture('Interface\\Icons\\'..icon)end
   b:SetScript('OnClick',click or function()p:ChooseProfession(key)end);y=y+38
   U.Help(b,label,function()
    if key=='mine'then return 'Show your learned professions. Enables My level / class, Within my skill and For my class. Existing search and armor filters still apply.'
    elseif key=='all'then return 'Browse the whole reward catalogue, including direct purchases. Turns off level/class, skill and role restrictions. Existing search and armor filters still apply.'
    elseif key=='others'then return (others and 'Collapse'or 'Expand')..' professions outside Your professions. Selecting an unlearned profession turns off Within my skill so its recipes can be inspected.'
    elseif key=='Other rewards'then return 'Direct Favor purchases, certificates and other non-recipe rewards. Direct purchases have no crafting material quote.'
    elseif key=='Unverified craft data'then return 'Rewards with incomplete crafting data. You can inspect them, but unavailable material facts are not guessed and a complete total may be impossible.'end
    local rank=profile.professions[key]
    return 'Show '..key..' rewards. '..(rank and ('Your skill: '..rank.skill..'.')or(profile.professionsKnown and 'Profession not learned; selecting it turns off Within my skill.'or 'Your profession status is unverified.'))..' Search, armor and role filters still apply.'
   end)
  end
  button('mine','My professions')
  if not p.professionLabel then p.professionLabel=U.Text(p,4,-52,128,'',nil,U.muted)end
  if not p.professionLabel.wvHelpHit then U.HintText(p,p.professionLabel,'Your professions',function()return profile.professionsKnown and 'Crafting professions detected on your current character. Each entry shows its current skill rank.'or 'Your professions could not be read completely yet. Try Refresh, or use Browse all recipes while the character data becomes available.'end)end
  p.professionLabel:SetText(profile.professionsKnown and 'Your professions'or 'Professions unavailable');y=72
  local own=0
  for _,name in ipairs(order)do local rank=profile.professions[name];if rank then own=own+1;button(name,name,'Skill '..rank.skill,icons[name])end end
  if not p.noProfessions then p.noProfessions=U.Text(p,4,-76,124,'No professions learned',nil,U.muted)end
  if not p.noProfessions.wvHelpHit then U.HintText(p,p.noProfessions,'No crafting profession detected','No supported crafting profession is currently detected. Browse all recipes to inspect other professions, or Refresh after learning one.')end
  p.noProfessions:SetShown(own==0 and profile.professionsKnown);p.noProfessions.wvHelpHit:SetShown(own==0 and profile.professionsKnown);if own==0 then y=y+26 end
  y=y+8
  button('others',(others and '− 'or '+ ')..'Other professions',nil,nil,function()others=not others;nav()end)
  if others then for _,name in ipairs(order)do if not profile.professions[name]then button(name,name,profile.professionsKnown and 'Not learned'or 'Unverified',icons[name])end end end
  button('Other rewards','Other rewards');button('Unverified craft data','Unverified recipes');y=y+10
  button('all','Browse all recipes')
 end
 local roleKeys={'auto','all','physical','caster','healing','tank','general'}
 local roleLabels={'For my class','All roles','Physical DPS','Spell DPS','Healing','Tank','General'}
 local roleHelp={
  auto='Use class relevance. Hunters keep physical DPS, general supplies and unclassified items. Hybrid classes can choose a role manually.',
  all='Remove the role restriction, including unclassified items. Profession, armor and requirement filters still apply.',
  physical='Items with physical attack stats. This is a role affinity, not a talent-weighted upgrade score.',
  caster='Items with spell-damage stats. Shared damage/healing gear can appear under both Spell DPS and Healing.',
  healing='Items with healing-power stats. Self-healing supplies are general use, not healer equipment.',
  tank='Items with explicit defensive stats or bonus armor. This is not an upgrade ranking.',
  general='General supplies, utility items and other classified non-specialist rewards, including usable engineering bombs.'}
 U.Help(p.role,'Role relevance',function()return (roleHelp[p.options.role]or '')..'\n\nSeparate from whether you can equip/use an item. Choose All roles to browse more items; exact role filters need a classified match.'end)
 p.role:SetScript('OnClick',function(self)
  local function choose(i)p.options.role=roleKeys[i];self:SetText(roleLabels[i]);filter(true)end
  if UIDropDownMenu_Initialize and UIDropDownMenu_CreateInfo and UIDropDownMenu_AddButton and ToggleDropDownMenu then
   if not p.roleMenu then p.roleMenu=CreateFrame('Frame',nil,p,'UIDropDownMenuTemplate')end
   UIDropDownMenu_Initialize(p.roleMenu,function()for i,label in ipairs(roleLabels)do
    local index=i;local info=UIDropDownMenu_CreateInfo();info.text=label;info.checked=p.options.role==roleKeys[i];info.func=function()choose(index)end;info.tooltipTitle=label;info.tooltipText=roleHelp[roleKeys[i]];info.tooltipOnButton=true;UIDropDownMenu_AddButton(info)
   end end);ToggleDropDownMenu(1,nil,p.roleMenu,self,0,0)
  else
   local index=1;for i,key in ipairs(roleKeys)do if p.options.role==key then index=i;break end end
   choose(index%#roleKeys+1)
  end
 end)
 p.armor:SetScript('OnClick',function(self)
  local labels={'All armor types','Cloth','Leather','Mail','Plate'}
  local function choose(i)if i==1 then p.options.armor=nil else p.options.armor=i-1 end;self:SetText(labels[i]);filter(true)end
  if UIDropDownMenu_Initialize and UIDropDownMenu_CreateInfo and UIDropDownMenu_AddButton and ToggleDropDownMenu then
   if not p.armorMenu then p.armorMenu=CreateFrame('Frame',nil,p,'UIDropDownMenuTemplate')end
   UIDropDownMenu_Initialize(p.armorMenu,function()for i,label in ipairs(labels)do
    local index=i;local info=UIDropDownMenu_CreateInfo();info.text=label;info.checked=(p.options.armor or 0)==i-1;info.func=function()choose(index)end
    info.tooltipTitle=label;info.tooltipText=i==1 and 'Show all armor types and non-armor rewards, subject to the other filters.'or('Show '..string.lower(label)..' items only. Level/class and role filters still apply.');info.tooltipOnButton=true;UIDropDownMenu_AddButton(info)
   end end);ToggleDropDownMenu(1,nil,p.armorMenu,self,0,0)
  else choose(((p.options.armor or 0)+1)%5+1)end
 end)
 p.usable:SetScript('OnClick',function(self)p.options.usable=self:GetChecked()==true;filter(true)end)
 p.skill:SetScript('OnClick',function(self)p.options.skill=self:GetChecked()==true;filter(true)end)
 function p:Refresh()
  profile=A.ReadCharacter();self.profile=profile
  read,errors,stats=A.PriceReader(WaylaidValueDB.source);self.crateRows=A.Rank(A.Crates,read,false,UnitLevel('player'));nav();filter(false)
 end
 p.search:SetScript('OnTextChanged',function()if read then filter(true)end end)
 p.held:SetScript('OnTextChanged',function()if read then show()end end)
 p.learned:SetScript('OnClick',function()if read then show()end end)
 return p
end
