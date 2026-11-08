local _,A=...
local U=A.UI
local frame,selectedID
local function short(c)return(A.ItemName(c.id,c.name):gsub('^Waylaid Crate: ',''))end
local function selectRow(row)
 selectedID=row.crate.id;local p=frame.detail
 p.title:SetText(short(row.crate));p.subtitle:SetText('One crate gives '..(row.crate.favor or '?')..' Favor · choose one filling bundle')
 p.cost:SetText(row.price and A.Money(row.price.value)or 'Price missing')
 for i,b in ipairs(p.options)do
  local part=row.options[i]
  if part then
   b:Show();U.SetIcon(b.icon,part.item.id)
   b.name:SetText(part.item.quantity..' × '..A.ItemName(part.item.id,part.item.name)..(part==row.best and ' · best' or ''))
   b.name:SetTextColor((unpack or table.unpack)(part==row.best and U.gold or U.text))
   b.unit:SetText(part.price and A.Money(part.price.value)or '—');b.total:SetText(part.total and A.Money(part.total)or 'Price missing');U.ItemTooltip(b,part.item.id,part.price)
  else b:Hide()end
 end
 p.note:SetText(row.reason or('Upfront '..A.Money(row.gross)..' − silver returned '..A.Money(row.silver)))
 p.net:SetText(row.net and('Net total '..A.Money(row.net))or '')
 if row.missing>0 then p.subtitle:SetText(p.subtitle:GetText()..' · '..row.missing..' unpriced alternative(s)')end
 for _,b in ipairs(frame.listRows)do b.selection:SetShown(b.data and b.data.crate.id==selectedID)end
end
function A.UpdatePriceStatus(stats,errors,context)
 if not frame then return end
 local tsm,atr=A.ProviderStatus();local mode=WaylaidValueDB.source
 if(mode=='TSM'and not tsm)or(mode=='Auctionator'and not atr)or(not tsm and not atr)then frame.status:SetText('No compatible price addon · enable the selected source, then Refresh')
 elseif next(errors or{})then frame.status:SetText('Price source error · let the addon finish loading, then Refresh')
 elseif stats and stats.tsm and stats.auctionator then frame.status:SetText('Mixed TSM / Auctionator cached prices · item sources in tooltips')
 elseif(stats and stats.auctionator)or mode=='Auctionator'or(mode=='Auto'and not tsm and atr)then frame.status:SetText('Auctionator cached prices'..(stats and stats.maxAge and(' · oldest reported age '..stats.maxAge..' day(s)')or ' · age not provided'))
 else frame.status:SetText('TSM cached prices · AH update time not provided')end
 frame.context:SetText(context or '')
end
function A.Refresh()
 if not frame then return end
 local tsm,atr=A.ProviderStatus()
 frame.source:SetText(WaylaidValueDB.source=='Auto'and(tsm and 'Auto · TSM'or atr and 'Auto · Auctionator'or 'Auto')or WaylaidValueDB.source)
 if frame.rewards:IsShown()then frame.rewards:Refresh();return end
 local read,errors,stats=A.PriceReader(WaylaidValueDB.source)
 local rows=A.Rank(A.Crates,read,WaylaidValueDB.expert,UnitLevel('player'));local rank,selected=0
 for i,row in ipairs(rows)do
  local b=frame.listRows[i]
  if not b then
   b=CreateFrame('Button',nil,frame.child);b:SetSize(840,36);b.selection=U.Fill(b,0,0,840,36,{0.20,0.20,0.17,1})
   local hover=b:CreateTexture(nil,'HIGHLIGHT');hover:SetAllPoints();hover:SetColorTexture(0.85,0.74,0.45,0.06);U.Fill(b,0,-35,840,1,{0.19,0.21,0.19,1},'BORDER')
   b.rank=U.Text(b,4,-11,22,'',nil,U.muted);b.crateIcon=U.Icon(b,30,-6,0);b.crate=U.Text(b,62,-11,210,'');b.sub=U.Text(b,62,-22,210,'',nil,U.muted)
   b.itemIcon=U.Icon(b,284,-6,0);b.bundle=U.Text(b,316,-11,224,'');b.favor=U.Text(b,548,-11,42,'',nil,U.text,'RIGHT');b.upfront=U.Text(b,606,-11,100,'',nil,U.text,'RIGHT')
   b.net=U.Text(b,726,-3,114,'','GameFontNormal',U.gold,'RIGHT');b.ratio=U.Text(b,726,-21,114,'',nil,U.muted,'RIGHT')
   b:SetScript('OnClick',function(self)selectRow(self.data)end);frame.listRows[i]=b
  end
  b.data=row;b:SetPoint('TOPLEFT',0,-(i-1)*36);b:Show()
  if row.ratio then rank=rank+1;b.rank:SetText(rank)else b.rank:SetText('—')end
  U.SetIcon(b.crateIcon,row.crate.id);b.crate:SetText(short(row.crate));b.crate:ClearAllPoints()
  if row.reason or row.crate.provisional then b.crate:SetPoint('TOPLEFT',62,-3);b.sub:SetText(row.reason or 'Expert reward provisional');b.sub:Show()
  else b.crate:SetPoint('TOPLEFT',62,-11);b.sub:Hide()end
  if row.best then U.SetIcon(b.itemIcon,row.best.item.id);b.itemIcon:Show();b.bundle:SetText(row.best.item.quantity..' × '..A.ItemName(row.best.item.id,row.best.item.name))
  else b.itemIcon:Hide();b.bundle:SetText('No priced filling bundle')end
  b.favor:SetText(row.crate.favor or '?');b.upfront:SetText(A.Money(row.gross));b.net:SetText(row.net and A.Money(row.net)or '—')
  b.ratio:SetText(row.ratio and string.format('%.1fc per Favor',math.floor(row.ratio*10+0.5)/10)or 'Not ranked')
  U.ItemTooltip(b,row.crate.id,row.price,row.reason or 'Click to compare filling options')
  if selectedID==row.crate.id then selected=row end
 end
 for i=#rows+1,#frame.listRows do frame.listRows[i]:Hide()end
 frame.child:SetHeight(math.max(1,#rows*36));U.ClampScroll(frame.scroll,#rows*36,288)
 if selected or rows[1]then selectRow(selected or rows[1])end
 A.UpdatePriceStatus(stats,errors,rank..' ranked / '..#rows..' crates')
end
local function create()
 frame=CreateFrame('Frame','WaylaidValueFrame',UIParent,'BackdropTemplate');frame:SetSize(900,730);frame:SetPoint('CENTER');frame:SetFrameStrata('DIALOG');frame:SetClampedToScreen(true)
 frame:SetMovable(true);frame:EnableMouse(true);frame:RegisterForDrag('LeftButton');frame:SetScript('OnDragStart',frame.StartMoving);frame:SetScript('OnDragStop',frame.StopMovingOrSizing)
 frame:SetBackdrop({bgFile='Interface\\Buttons\\WHITE8X8',edgeFile='Interface\\Buttons\\WHITE8X8',edgeSize=1});frame:SetBackdropColor(0.106,0.129,0.145,1);frame:SetBackdropBorderColor(0.46,0.38,0.25,1)
 frame:SetScale(math.min(1,(UIParent:GetWidth()-24)/900,(UIParent:GetHeight()-24)/730))
 U.Icon(frame,20,-15,248682);U.Text(frame,52,-17,430,'Waylaid Value','GameFontNormalLarge',U.gold);U.Text(frame,540,-22,42,'Prices',nil,U.muted)
 local function chooseSource()
  if UIDropDownMenu_Initialize and UIDropDownMenu_CreateInfo and UIDropDownMenu_AddButton and ToggleDropDownMenu then
   if not frame.sourceMenu then frame.sourceMenu=CreateFrame('Frame','WaylaidValueSourceMenu',frame,'UIDropDownMenuTemplate')end
   UIDropDownMenu_Initialize(frame.sourceMenu,function()
    for _,value in ipairs({'Auto','TSM','Auctionator'})do local key=value;local info=UIDropDownMenu_CreateInfo();info.text=key;info.checked=WaylaidValueDB.source==key;info.func=function()WaylaidValueDB.source=key;A.Refresh()end;UIDropDownMenu_AddButton(info)end
   end,'MENU');ToggleDropDownMenu(1,nil,frame.sourceMenu,frame.source,0,0)
  else local modes={Auto='TSM',TSM='Auctionator',Auctionator='Auto'};WaylaidValueDB.source=modes[WaylaidValueDB.source]or 'Auto';A.Refresh()end
 end
 frame.source=U.Button(frame,584,-12,140,'',chooseSource);U.Button(frame,734,-12,88,'Refresh',A.Refresh);U.Button(frame,848,-12,28,'×',function()frame:Hide()end)
 U.Fill(frame,0,-92,900,1,U.line,'BORDER')
 frame.cratesPanel=CreateFrame('Frame',nil,frame);frame.cratesPanel:SetPoint('TOPLEFT',20,-106);frame.cratesPanel:SetSize(860,590)
 frame.rewards=A.BuildRewardsView(frame);frame.rewards:Hide()
 local crateTab,rewardTab
 local function tab(rewards)frame.rewards:SetShown(rewards);frame.cratesPanel:SetShown(not rewards);crateTab:SetActive(not rewards);rewardTab:SetActive(rewards);A.Refresh()end
 crateTab=U.Tab(frame,20,'Crates',function()tab(false)end);rewardTab=U.Tab(frame,112,'Rewards',function()tab(true)end);frame.crateTab=crateTab;frame.rewardTab=rewardTab;crateTab:SetActive(true);rewardTab:SetActive(false)
 frame.context=U.Text(frame,610,-65,266,'',nil,U.muted,'RIGHT')
 local p=frame.cratesPanel;U.Text(p,0,0,440,'Compare the cost of earning Favor','GameFontHighlight')
 local expert=CreateFrame('CheckButton',nil,p,'UICheckButtonTemplate');expert:SetPoint('TOPLEFT',606,4);expert:SetSize(22,22);expert:SetChecked(WaylaidValueDB.expert)
 U.Text(p,632,-2,220,'Expert rewards (unverified)',nil,U.muted);expert:SetScript('OnClick',function(self)WaylaidValueDB.expert=self:GetChecked()and true or false;A.Refresh()end)
 for _,h in ipairs({{0,25,'#'},{30,240,'Crate'},{284,256,'Fill with'},{548,42,'Favor','RIGHT'},{606,100,'Upfront','RIGHT'},{726,114,'Net total','RIGHT'}})do U.Text(p,h[1],-34,h[2],h[3],nil,U.muted,h[4])end
 frame.scroll,frame.child=U.Scroll(p,0,-58,840,288);frame.listRows={};U.Fill(p,0,-360,860,1,{0.40,0.33,0.22,1},'BORDER')
 local d=CreateFrame('Frame',nil,p);d:SetPoint('TOPLEFT',0,-374);d:SetSize(860,216);frame.detail=d
 d.title=U.Text(d,0,0,640,'','GameFontNormal',U.gold);d.subtitle=U.Text(d,0,-22,720,'',nil,U.muted);d.cost=U.Text(d,726,0,114,'',nil,U.text,'RIGHT');U.Text(d,726,-22,114,'empty crate',nil,U.muted,'RIGHT')
 U.Text(d,0,-45,570,'Filling options',nil,U.muted);U.Text(d,610,-45,96,'Each',nil,U.muted,'RIGHT');U.Text(d,726,-45,114,'Bundle total',nil,U.muted,'RIGHT');d.options={}
 for i=1,5 do local b=CreateFrame('Button',nil,d);b:SetPoint('TOPLEFT',0,-66-(i-1)*24);b:SetSize(840,24);b.icon=U.Icon(b,0,-1,0,22);b.name=U.Text(b,30,-4,560,'');b.unit=U.Text(b,610,-4,96,'',nil,U.text,'RIGHT');b.total=U.Text(b,726,-4,114,'',nil,U.text,'RIGHT');d.options[i]=b end
 U.Fill(d,0,-190,840,1,U.line,'BORDER');d.note=U.Text(d,0,-200,610,'',nil,U.muted);d.net=U.Text(d,620,-200,220,'',nil,U.text,'RIGHT')
 U.Fill(frame,0,-702,900,1,U.line,'BORDER');frame.status=U.Text(frame,20,-713,670,'',nil,U.muted)
 local about=CreateFrame('Button',nil,frame);about:SetPoint('TOPLEFT',720,-705);about:SetSize(156,24);U.Text(about,0,-7,156,'About these prices',nil,U.muted,'RIGHT')
 about:SetScript('OnEnter',function(self)
  GameTooltip:SetOwner(self,'ANCHOR_TOP');GameTooltip:AddLine('Cached auction prices',0.87,0.76,0.49)
  GameTooltip:AddLine("Refresh recalculates the selected addon's cache, not a new AH scan. TSM's public price API does not expose the AH timestamp.",1,1,1,true)
  GameTooltip:AddLine('Auto uses TSM first and Auctionator for missing items. Item tooltips identify their price source.',1,1,1,true)
  GameTooltip:AddLine('Unit price × quantity is an estimate; stock and stack costs are unverified. Net subtracts documented turn-in silver. No first-turn-in or random bonus.',1,1,1,true);GameTooltip:Show()
 end);about:SetScript('OnLeave',function()GameTooltip:Hide()end)
 UISpecialFrames[#UISpecialFrames+1]='WaylaidValueFrame';frame:SetScript('OnShow',A.Refresh);frame:Hide()
end
function A.Toggle()if not frame then create()end;frame:SetShown(not frame:IsShown())end
function A.IsShown()return frame and frame:IsShown()end
