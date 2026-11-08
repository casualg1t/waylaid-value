local _,A=...
-- hors-kit: native WoW Lua widgets; the React kit cannot run in game.
local U={gold={0.87,0.76,0.49},text={0.93,0.91,0.86},muted={0.66,0.68,0.65},line={0.24,0.25,0.21,1}}
A.UI=U
local unpack=unpack or table.unpack
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
end
function U.Icon(p,x,y,id,size)
 local t=p:CreateTexture(nil,'ARTWORK');t:SetPoint('TOPLEFT',x,y);t:SetSize(size or 24,size or 24);t:SetTexCoord(0.07,0.93,0.07,0.93);U.SetIcon(t,id);return t
end
local requested={}
function A.ItemName(id,fallback)
 local get=C_Item and C_Item.GetItemInfo or GetItemInfo
 local name=id and id>0 and get and get(id)
 if name then return name end
 if id and id>0 and not requested[id]and C_Item and C_Item.RequestLoadItemDataByID then requested[id]=true;C_Item.RequestLoadItemDataByID(id)end
 return fallback or(A.ItemNames and A.ItemNames[id])or 'Loading item name…'
end
function U.ItemTooltip(b,id,price,extra)
 b:SetScript('OnEnter',function(self)
  GameTooltip:SetOwner(self,'ANCHOR_RIGHT');if GameTooltip.ClearLines then GameTooltip:ClearLines()end;if id and id>0 then GameTooltip:SetItemByID(id)end
  if price then GameTooltip:AddLine(A.Money(price.value)..' each · '..price.source,0.75,0.75,0.70,true);if price.age then GameTooltip:AddLine('Price age: '..price.age..' day(s)',0.75,0.75,0.70)end end
  if extra then GameTooltip:AddLine(extra,0.87,0.76,0.49,true)end;GameTooltip:Show()
 end)
 b:SetScript('OnLeave',function()GameTooltip:Hide()end)
end
function U.RewardTooltip(b,reward)
 b:SetScript('OnEnter',function(self)
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
  if A.ReadCharacter then
   local profile=A.ReadCharacter()
   local usable,why=A.UseEligibility(reward,profile)
   local skilled,skillWhy=A.SkillEligibility(reward,profile)
   if usable~=true then GameTooltip:AddLine(why or 'Usability unverified',0.95,0.55,0.40,true)end
   if not reward.purchase and skilled~=true then GameTooltip:AddLine(skillWhy or 'Profession skill unverified',0.95,0.55,0.40,true)end
  end
  GameTooltip:Show()
 end)
 b:SetScript('OnLeave',function()GameTooltip:Hide()end)
end
function U.Button(p,x,y,w,label,click)
 local b=CreateFrame('Button',nil,p,'BackdropTemplate');b:SetPoint('TOPLEFT',x,y);b:SetSize(w,28)
 b:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});b:SetBackdropColor(0.14,0.16,0.14,1);b:SetBackdropBorderColor(0.39,0.34,0.24,1)
 local f=U.Text(b,5,-7,w-10,label,nil,U.text,'CENTER')
 function b:SetText(v)f:SetText(v)end;function b:GetText()return f:GetText()end
 local hover=b:CreateTexture(nil,'HIGHLIGHT');hover:SetAllPoints();hover:SetColorTexture(0.8,0.7,0.4,0.08)
 b:SetScript('OnClick',click);return b
end
function U.Edit(p,x,y,w,placeholder)
 local b=CreateFrame('EditBox',nil,p,'BackdropTemplate');b:SetPoint('TOPLEFT',x,y);b:SetSize(w,28)
 b:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});b:SetBackdropColor(0.09,0.11,0.12,1);b:SetBackdropBorderColor(0.32,0.32,0.26,1)
 b:SetFontObject('GameFontHighlightSmall');b:SetTextInsets(8,8,0,0);b:SetAutoFocus(false)
 b:SetScript('OnEscapePressed',function(self)self:ClearFocus()end);b:SetScript('OnEnterPressed',function(self)self:ClearFocus()end)
 if placeholder then b.hint=U.Text(b,8,-7,w-16,placeholder,nil,U.muted)end;return b
end
function U.Tab(p,x,label,click)
 local b=CreateFrame('Button',nil,p);b:SetPoint('TOPLEFT',x,-51);b:SetSize(90,40)
 local f=U.Text(b,0,-13,85,label,'GameFontHighlight',U.muted);local line=U.Fill(b,0,-38,70,2,{0.87,0.76,0.49,1},'ARTWORK')
 function b:SetActive(on)line:SetShown(on);f:SetTextColor(unpack(on and U.gold or U.muted))end
 b:SetScript('OnClick',click);return b
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
