local _,A=...
-- hors-kit: native WoW Lua widgets; the React kit cannot run in game.
local U={gold={1,0.82,0.40},text={0.90,0.86,0.78},muted={0.71,0.68,0.61},line={0.31,0.25,0.16,0.65},selection={0.21,0.15,0.08,0.95}}
A.UI=U
local unpack=unpack or table.unpack
local qualityColors={[0]={0.62,0.62,0.62},[1]={1,1,1},[2]={0.12,1,0},[3]={0,0.44,0.87},[4]={0.64,0.21,0.93},[5]={1,0.50,0}}
function U.ItemColor(id)
 local quality=A.ItemRequirements and A.ItemRequirements[id]and A.ItemRequirements[id].quality
 local get=C_Item and C_Item.GetItemInfo or GetItemInfo
 if get then local ok,_,_,q=pcall(get,id);if ok and type(q)=='number'then quality=q end end
 local color=ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality]
 if color then return color.r,color.g,color.b end
 return unpack(qualityColors[quality]or U.text)
end
function U.ItemText(f,id,name)f:SetText(name or A.ItemName(id));f:SetTextColor(U.ItemColor(id))end
function U.Money(value)return A.Money(value,true)end
function A.BagCount(id)
 if WaylaidValueDB and WaylaidValueDB.bagHints==false then return nil end
 -- Current character's bags only: bank/charges must not become owned-crate counts.
 local modern=C_Item and C_Item.GetItemCount
 for _,get in ipairs({modern or false,GetItemCount or false})do
  if type(get)=='function'then
   local ok,count=pcall(get,id,false,false)
   if ok and type(count)=='number'and count==count and count>=0 and count<math.huge and count==math.floor(count)then return count end
  end
 end
 return nil -- unavailable, not a confirmed zero
end
function U.BagNote(id,required)
 local count=A.BagCount(id)
 if not count or count==0 then return '',''end
 return 'In bags: '..count..' / '..required,
  '\nIn bags: '..count..' of '..required..' needed. Current character bags only; bank excluded. Ownership is a reminder only: full market costs, cheapest bundle and ranking are unchanged.'
end
local function sliced(f,asset,layer)
 local pieces={}
 local points={'TOPLEFT','TOP','TOPRIGHT','LEFT','CENTER','RIGHT','BOTTOMLEFT','BOTTOM','BOTTOMRIGHT'}
 local cuts={0,0.125,0.875,1}
 for row=1,3 do for col=1,3 do
  local t=f:CreateTexture(nil,layer);t:SetTexture('Interface\\AddOns\\WaylaidValue\\'..asset)
  t:SetTexCoord(cuts[col],cuts[col+1],cuts[row],cuts[row+1])
  if row==2 and col==2 then t:SetPoint('TOPLEFT',4,-4);t:SetPoint('BOTTOMRIGHT',-4,4)
  elseif col==2 then
   local side=row==1 and 'TOP'or 'BOTTOM';t:SetPoint(side..'LEFT',4,0);t:SetPoint(side..'RIGHT',-4,0);t:SetHeight(4)
  elseif row==2 then
   local side=col==1 and 'LEFT'or 'RIGHT';t:SetPoint('TOP'..side,0,-4);t:SetPoint('BOTTOM'..side,0,4);t:SetWidth(4)
  else t:SetSize(4,4);t:SetPoint(points[(row-1)*3+col])end
  pieces[#pieces+1]=t
 end end
 return pieces
end
function U.Skin(f,fill,edge)
 if not f.wvSkin then f.wvSkin={fill=sliced(f,'SkinFill','BACKGROUND'),edge=sliced(f,'SkinRing','BORDER')}end
 for _,t in ipairs(f.wvSkin.fill)do t:SetVertexColor(unpack(fill or {0.075,0.068,0.058,1}))end
 for _,t in ipairs(f.wvSkin.edge)do t:SetVertexColor(unpack(edge or {0.50,0.39,0.22,0.95}))end
end
function U.Row(b)
 U.Skin(b,{0.055,0.052,0.048,1},{0.28,0.25,0.20,0.65})
end
function U.Text(p,x,y,w,value,font,color,align,size)
 local f=p:CreateFontString(nil,'OVERLAY',font or 'GameFontHighlightSmall')
 f:SetPoint('TOPLEFT',x,y);f:SetWidth(w);f:SetJustifyH(align or 'LEFT');f:SetWordWrap(false)
 f:SetTextColor(unpack(color or U.text));f:SetText(value or '')
 if size then local path,_,flags=f:GetFont();if path then f:SetFont(path,size,flags)end end
 return f
end
function U.Fill(p,x,y,w,h,color,layer)
 local t=p:CreateTexture(nil,layer or 'BACKGROUND');t:SetPoint('TOPLEFT',x,y);t:SetSize(w,h);t:SetColorTexture(unpack(color));return t
end
function U.SetIcon(t,id)
 local get=C_Item and C_Item.GetItemIconByID or GetItemIcon
 t:SetTexture((get and id and id>0 and get(id))or(A.ItemIcons and A.ItemIcons[id])or 'Interface\\Icons\\INV_Misc_QuestionMark')
 if t.holder then t.holder:SetBackdropBorderColor(U.ItemColor(id))end
end
function U.Icon(p,x,y,id,size)
 local holder=CreateFrame('Frame',nil,p,'BackdropTemplate');holder:SetPoint('TOPLEFT',x,y);holder:SetSize(size or 24,size or 24)
 holder:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});holder:SetBackdropColor(0.02,0.02,0.02,1)
 local t=holder:CreateTexture(nil,'ARTWORK');t:SetPoint('TOPLEFT',1,-1);t:SetSize((size or 24)-2,(size or 24)-2);t:SetTexCoord(0.07,0.93,0.07,0.93);t.holder=holder;U.SetIcon(t,id)
 local show,hide=t.Show,t.Hide
 function t:Show()show(self);holder:Show()end
 function t:Hide()hide(self);holder:Hide()end
 function t:SetShown(on)if on then self:Show()else self:Hide()end end
 return t
end
local requested={}
function A.ItemName(id,fallback)
 local get=C_Item and C_Item.GetItemInfo or GetItemInfo
 local name=id and id>0 and get and get(id)
 if name then return name end
 if id and id>0 and not requested[id]and C_Item and C_Item.RequestLoadItemDataByID then requested[id]=true;C_Item.RequestLoadItemDataByID(id)end
 return fallback or(A.ItemNames and A.ItemNames[id])or 'Loading item name…'
end
local function hideHelp(self)
 if not GameTooltip.IsOwned or GameTooltip:IsOwned(self)then GameTooltip:Hide()end
end
local function tooltipEvents(b,enter)
 b:SetScript('OnEnter',enter);b:SetScript('OnLeave',hideHelp)
 if b.SetMotionScriptsWhileDisabled then b:SetMotionScriptsWhileDisabled(true)end
 if b.HookScript and not b.wvHelpHideHook then b:HookScript('OnHide',hideHelp);b.wvHelpHideHook=true end
end
function U.ShowHelp(self)
 local title,body=self.wvHelpTitle,self.wvHelpBody
 if type(title)=='function'then title=title(self)end
 if type(body)=='function'then body=body(self)end
 GameTooltip:SetOwner(self,'ANCHOR_RIGHT');if GameTooltip.ClearLines then GameTooltip:ClearLines()end
 GameTooltip:AddLine(title or '',unpack(U.gold))
 if type(body)=='table'then for _,line in ipairs(body)do GameTooltip:AddLine(line,U.text[1],U.text[2],U.text[3],true)end
 elseif body then GameTooltip:AddLine(body,U.text[1],U.text[2],U.text[3],true)end
 GameTooltip:Show()
end
function U.Help(b,title,body)
 b.wvHelpTitle=title;b.wvHelpBody=body;b.wvTooltipKind='help';tooltipEvents(b,U.ShowHelp);return b
end
function U.Hint(p,x,y,w,h,title,body,click)
 local f=CreateFrame(click and 'Button'or 'Frame',nil,p);f:SetPoint('TOPLEFT',x,y);f:SetSize(w,h);f:EnableMouse(true)
 if click then f:SetScript('OnClick',click)end
 return U.Help(f,title,body)
end
function U.HintText(p,text,title,body,click)
 local f=CreateFrame(click and 'Button'or 'Frame',nil,p);f:SetAllPoints(text);f:EnableMouse(true)
 if click then f:SetScript('OnClick',click)end
 text.wvHelpHit=U.Help(f,title,body);return f
end
function U.Check(p,x,y,w,label,title,body)
 local b=CreateFrame('CheckButton',nil,p,'UICheckButtonTemplate');b:SetPoint('TOPLEFT',x,y);b:SetSize(w,28)
 for _,get in ipairs({'GetNormalTexture','GetPushedTexture','GetHighlightTexture','GetCheckedTexture','GetDisabledCheckedTexture'})do
  if b[get]then local t=b[get](b);if t then t:ClearAllPoints();t:SetPoint('LEFT',0,0);t:SetSize(22,22)end end
 end
 U.Text(b,26,-8,w-26,label,nil,U.muted);return U.Help(b,title or label,body)
end
function U.ItemTooltip(b,id,price,extra)
 b.wvTooltipKind='item';tooltipEvents(b,function(self)
  GameTooltip:SetOwner(self,'ANCHOR_RIGHT');if GameTooltip.ClearLines then GameTooltip:ClearLines()end;if id and id>0 then GameTooltip:SetItemByID(id)end
  if price then GameTooltip:AddLine(U.Money(price.value)..' each · '..price.source,0.75,0.75,0.70,true)
   if price.scannedAt and date then GameTooltip:AddLine('Scanned '..date('%d %b %H:%M',price.scannedAt)..' · stock may have changed',.75,.75,.70,true)
   elseif price.age then GameTooltip:AddLine('Price age: '..price.age..' day(s)',0.75,0.75,0.70)end
  end
  if extra then GameTooltip:AddLine(extra,0.87,0.76,0.49,true)end;GameTooltip:Show()
 end)
end
function U.RewardTooltip(b,reward,craftCost)
 b.wvTooltipKind='reward';tooltipEvents(b,function(self)
  GameTooltip:SetOwner(self,'ANCHOR_RIGHT')
  if GameTooltip.ClearLines then GameTooltip:ClearLines()end
  local effect=reward.spell and reward.recipe==reward.id and reward.profession=='Enchanting'
  if effect and GameTooltip.SetSpellByID then GameTooltip:SetSpellByID(reward.spell)
  elseif effect and GameTooltip.SetHyperlink then GameTooltip:SetHyperlink('spell:'..reward.spell)
  elseif reward.id and reward.id>0 then GameTooltip:SetItemByID(reward.id)
  else GameTooltip:AddLine(reward.name,0.87,0.76,0.49)end
  GameTooltip:AddLine(' ')
  GameTooltip:AddLine(reward.profession..(reward.skill and(' · skill '..reward.skill)or ''),0.87,0.76,0.49)
  if reward.favor then GameTooltip:AddLine((reward.purchase and 'Price: 'or 'Recipe price: ')..reward.favor..' Favor',0.75,0.75,0.70)end
  if craftCost then
   GameTooltip:AddLine('One craft: '..(craftCost.materials and U.Money(craftCost.materials)or 'Material prices missing'),0.90,0.86,0.78,true)
   GameTooltip:AddLine('Materials only. Recipe unlock is separate; cost is per craft, not per output item.',0.75,0.75,0.70,true)
  elseif reward.purchase then GameTooltip:AddLine('Direct reward; no crafting materials.',0.75,0.75,0.70)end
  local _,role=A.RewardRoles(reward);GameTooltip:AddLine(role,0.75,0.75,0.70,true)
  if A.ReadCharacter then
   local profile=A.ReadCharacter()
   local usable,why=A.UseEligibility(reward,profile)
   local skilled,skillWhy=A.SkillEligibility(reward,profile)
   if usable~=true then GameTooltip:AddLine(why or 'Usability unverified',0.95,0.55,0.40,true)end
   if not reward.purchase and skilled~=true then GameTooltip:AddLine(skillWhy or 'Profession skill unverified',0.95,0.55,0.40,true)end
  end
  GameTooltip:Show()
 end)
end
function U.Button(p,x,y,w,label,click,title,body)
 local b=CreateFrame('Button',nil,p,'BackdropTemplate');b:SetPoint('TOPLEFT',x,y);b:SetSize(w,28)
 U.Skin(b)
 local f=U.Text(b,5,-7,w-10,label,'GameFontNormal',U.text,'CENTER',12)
 function b:SetText(v)f:SetText(v)end;function b:GetText()return f:GetText()end
 local hover=b:CreateTexture(nil,'HIGHLIGHT');hover:SetAllPoints();hover:SetColorTexture(0.8,0.7,0.4,0.08)
 b:SetScript('OnClick',click);if body then U.Help(b,title or label,body)end;return b
end
function U.Edit(p,x,y,w,placeholder,title,body)
 local b=CreateFrame('EditBox',nil,p,'BackdropTemplate');b:SetPoint('TOPLEFT',x,y);b:SetSize(w,28)
 U.Skin(b,{0.045,0.040,0.035,1},{0.39,0.32,0.22,0.85})
 b:SetFontObject('GameFontHighlightSmall');b:SetTextInsets(8,8,0,0);b:SetAutoFocus(false)
 b:SetScript('OnEscapePressed',function(self)self:ClearFocus()end);b:SetScript('OnEnterPressed',function(self)self:ClearFocus()end)
 if placeholder then b.hint=U.Text(b,8,-7,w-16,placeholder,nil,U.muted)end;if body then U.Help(b,title or placeholder,body)end;return b
end
function U.Tab(p,x,label,click,body)
 local b=CreateFrame('Button',nil,p);b:SetPoint('TOPLEFT',x,-57);b:SetSize(90,32)
 local f=U.Text(b,0,-9,90,label,'GameFontNormal',U.muted,'CENTER',12)
 function b:SetActive(on)
  U.Skin(b,on and {0.20,0.14,0.06,1}or {0.065,0.058,0.048,1},on and {0.80,0.60,0.25,1}or {0.36,0.29,0.19,0.8})
  f:SetTextColor(unpack(on and U.gold or U.muted))
 end
 b:SetScript('OnClick',click);if body then U.Help(b,label,body)end;return b
end
function U.Scroll(p,x,y,w,h)
 local s=CreateFrame('ScrollFrame',nil,p,'UIPanelScrollFrameTemplate');s:SetPoint('TOPLEFT',x,y);s:SetSize(w,h)
 local child=CreateFrame('Frame',nil,s);child:SetSize(w,1);s:SetScrollChild(child)
 local bar=s.ScrollBar
 if bar then
  for _,key in ipairs({'ScrollUpButton','ScrollDownButton'})do local b=bar[key];if b then b:SetAlpha(0);b:EnableMouse(false)end end
  local thumb=bar.GetThumbTexture and bar:GetThumbTexture()
  if bar.GetRegions then for _,r in ipairs({bar:GetRegions()})do if r~=thumb and r.SetAlpha then r:SetAlpha(0)end end end
  local track=bar:CreateTexture(nil,'BACKGROUND');track:SetColorTexture(0.09,0.11,0.12,1);track:SetPoint('TOP',0,0);track:SetPoint('BOTTOM',0,0);track:SetWidth(4)
  if thumb and thumb.SetColorTexture then thumb:SetColorTexture(0.43,0.36,0.23,1);thumb:SetWidth(4)end
 end
 return s,child
end
function U.ClampScroll(s,content,height)s:SetVerticalScroll(math.min(s:GetVerticalScroll(),math.max(0,content-height)))end
