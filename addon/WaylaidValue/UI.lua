local _,A=...
local U=A.UI
local frame,selectedID
local upfrontHelp='Gold to buy one empty crate and the selected filling bundle, before collecting turn-in money. Quoted quantities and stock are not guaranteed.'
local netHelp='Upfront gold minus turn-in money. The model assumes 50 copper per base Favor (20 Favor = 10 silver). First-turn-in and random bonuses are excluded.'
local expertHelp='Expert is a level-20+ crate tier. Enable this to show Expert crates using unconfirmed estimates of 15 or 30 Favor per turn-in. Their ranking may be wrong if the actual reward differs.\n\nOff by default. This does not affect confirmed lower-tier crates; Rewards shopping plans still use documented tiers only.'
local function short(c)return(A.ItemName(c.id,c.name):gsub('^Waylaid Crate: ',''))end
local function selectRow(row)
 selectedID=row.crate.id;local p=frame.detail
 U.ItemText(p.title,row.crate.id,short(row.crate));p.subtitle:SetText('One crate gives '..(row.crate.favor or '?')..' Favor · choose one filling bundle'..((row.bagCount or 0)>0 and(' · In bags: '..row.bagCount)or ''))
 p.cost:SetText(row.price and U.Money(row.price.value)or 'Price missing')
 for i,b in ipairs(p.options)do
  local part=row.options[i]
  if part then
   b:Show();U.SetIcon(b.icon,part.item.id)
   local bagNote,bagHelp=U.BagNote(part.item.id,part.item.quantity)
   U.ItemText(b.name,part.item.id,part.item.quantity..' × '..A.ItemName(part.item.id,part.item.name)..(part==row.best and ' · best' or '')..(bagNote~=''and(' |cffb5ad9c· '..bagNote..'|r')or ''))
   b.unit:SetText(part.price and U.Money(part.price.value)or '—');b.total:SetText(part.total and U.Money(part.total)or 'Price missing');U.ItemTooltip(b,part.item.id,part.price,'One filling option: '..part.item.quantity..' items, '..(part.total and U.Money(part.total)or 'price missing')..' for the bundle. Choose one option per crate.'..bagHelp)
  else b:Hide()end
 end
 p.note:SetText(row.reason or('Upfront '..U.Money(row.gross)..' − turn-in money '..U.Money(row.silver)))
 p.net:SetText(row.net and('Net total '..U.Money(row.net))or '')
 U.ItemTooltip(p.inspect,row.crate.id,row.price,'Choose one filling bundle below. '..(row.crate.provisional and 'Expert Favor reward is unverified.'or 'Net cost subtracts turn-in money.'))
 if row.missing>0 then p.subtitle:SetText(p.subtitle:GetText()..' · '..row.missing..' unpriced alternative(s)')end
 for _,b in ipairs(frame.listRows)do b.selection:SetShown(b.data and b.data.crate.id==selectedID)end
end
function A.UpdatePriceStatus(stats,errors,context)
 if not frame then return end
 local tsm,atr=A.ProviderStatus();local mode=WaylaidValueDB.source
 local saved=A.ScanSnapshot and A.ScanSnapshot()
 if A.scanState and A.scanState.running then frame.status:SetText(A.scanState.message)
 elseif mode=='Scan'then frame.status:SetText(saved and('AH scan · '..date('%d %b %H:%M',saved.at)..' · unit estimates; stock may change')or 'No AH scan for this realm / faction · open the AH and scan')
 elseif stats and stats.scan then frame.status:SetText((stats.tsm or stats.auctionator)and 'Mixed addon / AH scan unit estimates · sources in item tooltips'or('AH scan · '..date('%d %b %H:%M',stats.scanAt)..' · unit estimates'))
 elseif(mode=='TSM'and not tsm)or(mode=='Auctionator'and not atr)or(not tsm and not atr)then frame.status:SetText('No compatible price addon · enable the selected source, then Refresh')
 elseif next(errors or{})then frame.status:SetText('Price source error · let the addon finish loading, then Refresh')
 elseif stats and stats.tsm and stats.auctionator then frame.status:SetText('Mixed TSM / Auctionator cached prices · item sources in tooltips')
 elseif(stats and stats.auctionator)or mode=='Auctionator'or(mode=='Auto'and not tsm and atr)then frame.status:SetText('Auctionator cached prices'..(stats and stats.maxAge and(' · oldest reported age '..stats.maxAge..' day(s)')or ' · age not provided'))
 else frame.status:SetText('TSM · cached minimum-buyout prices')end
 frame.context:SetText(context or '')
end
function A.Refresh()
 if not frame then return end
 if A.UpdateScanControls then A.UpdateScanControls()end
 local tsm,atr=A.ProviderStatus()
 frame.source:SetText(WaylaidValueDB.source=='Scan'and 'AH scan'or WaylaidValueDB.source=='Auto'and(tsm and 'Auto · TSM'or atr and 'Auto · Auctionator'or 'Auto')or WaylaidValueDB.source)
 if frame.rewards:IsShown()then frame.rewards:Refresh();return end
 local read,errors,stats=A.PriceReader(WaylaidValueDB.source)
 local rows=A.Rank(A.Crates,read,WaylaidValueDB.expert,UnitLevel('player'));local rank,selected=0
 for i,row in ipairs(rows)do
  local b=frame.listRows[i]
  if not b then
   b=CreateFrame('Button',nil,frame.child);b:SetSize(840,36);b.selection=U.Fill(b,0,0,840,36,U.selection)
   local hover=b:CreateTexture(nil,'HIGHLIGHT');hover:SetAllPoints();hover:SetColorTexture(0.85,0.74,0.45,0.06);U.Fill(b,0,-35,840,1,{0.19,0.21,0.19,1},'BORDER')
   b.rank=U.Text(b,4,-11,22,'',nil,U.muted);b.crateIcon=U.Icon(b,30,-6,0);b.crate=U.Text(b,62,-11,210,'');b.sub=U.Text(b,62,-22,210,'',nil,U.muted)
   b.itemIcon=U.Icon(b,284,-6,0);b.bundle=U.Text(b,316,-11,224,'');b.bundleOwned=U.Text(b,316,-22,224,'',nil,U.muted);b.favor=U.Text(b,548,-11,42,'',nil,U.text,'RIGHT');b.upfront=U.Text(b,606,-11,100,'',nil,U.text,'RIGHT')
   b.net=U.Text(b,726,-3,114,'','GameFontNormal',U.text,'RIGHT');b.ratio=U.Text(b,726,-21,114,'',nil,U.muted,'RIGHT')
   local function choose()selectRow(b.data)end
   U.HintText(b,b.upfront,'Upfront gold',upfrontHelp,choose)
   U.HintText(b,b.net,'Net total',netHelp,choose)
   U.HintText(b,b.ratio,'Net cost per Favor','Net total divided by the crate\'s base Favor reward. Lower is cheaper. Unknown rewards or prices stay unranked.',choose)
   U.HintText(b,b.favor,"Merchant's Favor",'Base Favor earned by filling and turning in one crate. First-turn-in and random bonuses are not counted.',choose)
   b.bundleHelp=U.Hint(b,284,-4,256,28,'Filling bundle',function()
    local row=b.data
    if not row.best then return 'No filling option has a usable price. Update your price addon, then Refresh.'end
    return row.best.item.quantity..' × '..A.ItemName(row.best.item.id,row.best.item.name)..' = '..U.Money(row.best.total)..'. Choose only one accepted bundle per crate. Other options are shown below.'
   end,choose)
   b:SetScript('OnClick',function(self)selectRow(self.data)end);frame.listRows[i]=b
  end
  row.bagCount=A.BagCount(row.crate.id)
  b.data=row;b:SetPoint('TOPLEFT',0,-(i-1)*36);b:Show()
  if row.ratio then rank=rank+1;b.rank:SetText(rank)else b.rank:SetText('—')end
  U.SetIcon(b.crateIcon,row.crate.id);U.ItemText(b.crate,row.crate.id,short(row.crate));b.crate:ClearAllPoints()
  local notes={}
  if row.reason or row.crate.provisional then notes[#notes+1]=row.reason or 'Expert reward provisional'end
  if (row.bagCount or 0)>0 then notes[#notes+1]='In bags: '..row.bagCount end
  if #notes>0 then b.crate:SetPoint('TOPLEFT',62,-3);b.sub:SetText(table.concat(notes,' · '));b.sub:Show()
  else b.crate:SetPoint('TOPLEFT',62,-11);b.sub:Hide()end
  if row.best then U.SetIcon(b.itemIcon,row.best.item.id);b.itemIcon:Show();U.ItemText(b.bundle,row.best.item.id,row.best.item.quantity..' × '..A.ItemName(row.best.item.id,row.best.item.name))
   local bagNote,bagHelp=U.BagNote(row.best.item.id,row.best.item.quantity)
   b.bundle:ClearAllPoints();b.bundle:SetPoint('TOPLEFT',316,bagNote~=''and -3 or -11)
   b.bundleOwned:SetText(bagNote);b.bundleOwned:SetShown(bagNote~='')
   U.ItemTooltip(b.bundleHelp,row.best.item.id,row.best.price,row.best.item.quantity..' items = '..U.Money(row.best.total)..'. Choose one bundle per crate; click to compare other filling options.'..bagHelp)
  else b.itemIcon:Hide();b.bundleOwned:Hide();b.bundle:ClearAllPoints();b.bundle:SetPoint('TOPLEFT',316,-11);b.bundle:SetText('No priced filling bundle');U.Help(b.bundleHelp,'Filling prices missing','No accepted filling option has a usable quote. Update your price addon, then Refresh. Click to inspect every filling option.')end
  b.favor:SetText(row.crate.favor or '?');b.upfront:SetText(U.Money(row.gross));b.net:SetText(row.net and U.Money(row.net)or '—')
  b.ratio:SetText(row.ratio and string.format('%.1f|cffeda55fc|r per Favor',math.floor(row.ratio*10+0.5)/10)or 'Not ranked')
  local explanation=row.reason or(row.crate.provisional and 'Expert Favor reward is unverified; treat this ranking as provisional.'or 'Click to compare filling options')
  if (row.bagCount or 0)>0 then explanation=explanation..'\nIn bags: '..row.bagCount..'. This is only a reminder. Ranking and shopping plans still use market prices; owned crates are not treated as free or given priority.'end
  U.ItemTooltip(b,row.crate.id,row.price,explanation)
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
 U.Skin(frame,{0.065,0.058,0.048,0.98},{0.50,0.40,0.25,0.95})
 U.Fill(frame,4,-4,892,46,{0.10,0.078,0.045,1})
 frame:SetScale(math.min(1,(UIParent:GetWidth()-24)/900,(UIParent:GetHeight()-24)/730))
 U.Icon(frame,20,-10,248682,32);U.Text(frame,62,-17,260,'Waylaid Value','GameFontNormalLarge',U.gold,nil,18);U.Text(frame,540,-22,42,'Prices',nil,U.muted)
 frame.settingsButton=U.Button(frame,344,-12,86,'Settings',function()A.ToggleSettings()end,'Settings','Choose crate item-tooltip detail, bag reminders and minimap visibility. Changes are saved immediately; Crates and Rewards keep their current filters and selection.')
 local function scanHelp()
  if A.scanState.running then return A.scanState.message..'\n\nStop this scan and keep the previous complete snapshot. No purchases are made.'end
  local ready,reason=A.ScanAvailable()
  return (not ready and(reason..'\n\n')or '')..'Scan catalogue crates and their filling materials, plus reagents for the reward currently selected in Rewards. Searches run only after your click, at the AH. Another search or closing the AH interrupts the scan. A complete scan selects AH scan as the price source. Results are dated unit-price estimates; stock and whole-stack costs are not guaranteed.'
 end
 frame.scan=U.Button(frame,440,-12,88,'Scan AH',function()
  if A.scanState.running then A.CancelScan()else A.StartScan(A.SelectedReward())end
 end,'Scan auction prices',scanHelp)
 frame.scanDisabledHelp=U.Hint(frame,440,-12,88,28,'Scan unavailable',scanHelp)
 frame.settingsPanel=A.BuildSettings(frame)
 local function chooseSource()
  if UIDropDownMenu_Initialize and UIDropDownMenu_CreateInfo and UIDropDownMenu_AddButton and ToggleDropDownMenu then
   if not frame.sourceMenu then frame.sourceMenu=CreateFrame('Frame','WaylaidValueSourceMenu',frame,'UIDropDownMenuTemplate')end
   UIDropDownMenu_Initialize(frame.sourceMenu,function()
    for _,value in ipairs({'Auto','TSM','Auctionator','Scan'})do local key=value;local info=UIDropDownMenu_CreateInfo();info.text=key=='Scan'and 'AH scan'or key;info.checked=WaylaidValueDB.source==key;info.func=function()WaylaidValueDB.source=key;A.Refresh()end
     info.tooltipTitle=info.text;info.tooltipText=key=='Auto'and 'Use TSM, then Auctionator, then your saved AH scan when quotes are missing.'or key=='Scan'and 'Use only the last complete AH scan for this realm and faction. Quotes are unit estimates; missing items stay unavailable.'or('Use only '..key..' cached quotes. Missing quotes stay unavailable.');info.tooltipOnButton=true;UIDropDownMenu_AddButton(info)end
   end,'MENU');ToggleDropDownMenu(1,nil,frame.sourceMenu,frame.source,0,0)
  else local modes={Auto='TSM',TSM='Auctionator',Auctionator='Scan',Scan='Auto'};WaylaidValueDB.source=modes[WaylaidValueDB.source]or 'Auto';A.Refresh()end
 end
 frame.source=U.Button(frame,584,-12,140,'',chooseSource,'Price source',function()
  local tsm,auctionator=A.ProviderStatus()
  return 'Choose cached unit buyout prices from TSM, Auctionator or your own AH scan. Auto tries them in that order for missing items.\n\nTSM: '..(tsm and 'available'or 'not available')..'. Auctionator: '..(auctionator and 'available'or 'not available')..'. A scan is used only after it completes; stock is not guaranteed.'
 end)
 frame.refresh=U.Button(frame,734,-12,88,'Refresh',A.Refresh,'Refresh prices','Re-read your price addons and recalculate costs using the current character. This does not scan the auction house. Update or scan with your price addon first to collect newer quotes.')
 frame.close=U.Button(frame,848,-12,28,'×',function()frame:Hide()end,'Close window','Close Waylaid Value. Open it again with /crates or the minimap crate icon. Escape also closes it.')
 U.Fill(frame,0,-92,900,1,U.line,'BORDER')
 frame.cratesPanel=CreateFrame('Frame',nil,frame);frame.cratesPanel:SetPoint('TOPLEFT',20,-106);frame.cratesPanel:SetSize(860,590)
 frame.rewards=A.BuildRewardsView(frame);frame.rewards:Hide()
 local crateTab,rewardTab
 local function tab(rewards)frame.settingsPanel:Hide();frame.rewards:SetShown(rewards);frame.cratesPanel:SetShown(not rewards);crateTab:SetActive(not rewards);rewardTab:SetActive(rewards);A.Refresh()end
 crateTab=U.Tab(frame,20,'Crates',function()tab(false)end,'Compare the cost of earning Favor with each crate and filling bundle. Select a row to see every accepted filling option.')
 rewardTab=U.Tab(frame,112,'Rewards',function()tab(true)end,'Browse profession rewards and compare crafting costs. Select an item for its recipe unlock, exact crate shopping plan and materials.');frame.crateTab=crateTab;frame.rewardTab=rewardTab;crateTab:SetActive(true);rewardTab:SetActive(false)
 frame.context=U.Text(frame,610,-65,266,'',nil,U.muted,'RIGHT')
 U.HintText(frame,frame.context,'List coverage',function()return frame.rewards:IsShown()and 'Matching rewards / total assembled catalogue. Search, profession, armor, role and requirement filters decide what is shown.'or 'Ranked crates / visible crates. A crate needs known prices, a known Favor reward and the required character level to be ranked. Expert crates are hidden unless enabled.'end)
 local p=frame.cratesPanel;U.Text(p,0,0,440,'Compare the cost of earning Favor','GameFontHighlight')
 local expert=U.Check(p,606,6,248,'Expert rewards (unverified)','Expert rewards (unverified)',expertHelp);frame.expert=expert;expert:SetChecked(WaylaidValueDB.expert)
 expert:SetScript('OnClick',function(self)WaylaidValueDB.expert=self:GetChecked()and true or false;A.Refresh()end)
 local headerHelp={['#']='Ranked from lowest net gold per Favor. Missing prices, unknown rewards and level-gated crates remain visible without a rank.',Crate='The empty crate you buy before choosing one filling bundle. Select a row to compare its options.',['Fill with']='Cheapest bundle with a known price. Choose one bundle, not all the listed alternatives. An unpriced alternative might be cheaper.',Favor='Base Merchant\'s Favor for one filled crate. Bonus rewards are excluded.',Upfront=upfrontHelp,['Net total']=netHelp..' The smaller number below is net cost per Favor.'}
 for _,h in ipairs({{0,25,'#'},{30,240,'Crate'},{284,256,'Fill with'},{548,42,'Favor','RIGHT'},{606,100,'Upfront','RIGHT'},{726,114,'Net total','RIGHT'}})do local text=U.Text(p,h[1],-34,h[2],h[3],nil,U.muted,h[4]);U.HintText(p,text,h[3],headerHelp[h[3]])end
 frame.scroll,frame.child=U.Scroll(p,0,-58,840,288);frame.listRows={};U.Fill(p,0,-360,860,1,{0.40,0.33,0.22,1},'BORDER')
 local d=CreateFrame('Frame',nil,p);d:SetPoint('TOPLEFT',0,-374);d:SetSize(860,216);frame.detail=d
 d.title=U.Text(d,0,0,640,'','GameFontNormal',U.gold);d.subtitle=U.Text(d,0,-22,720,'',nil,U.muted);d.cost=U.Text(d,726,0,114,'',nil,U.text,'RIGHT');U.Text(d,726,-22,114,'empty crate',nil,U.muted,'RIGHT')
 d.inspect=U.HintText(d,d.title,'Selected crate','Inspect the empty crate and its accepted filling options.')
 local filling=U.Text(d,0,-45,570,'Filling options',nil,U.muted);local each=U.Text(d,610,-45,96,'Each',nil,U.muted,'RIGHT');local bundle=U.Text(d,726,-45,114,'Bundle total',nil,U.muted,'RIGHT');d.options={}
 U.HintText(d,filling,'Filling options','Choose exactly one of these accepted bundles for each crate. The best label marks the cheapest option with a known quote; a missing quote may hide a cheaper alternative.')
 U.HintText(d,each,'Each','Cached buyout price for one unit of the filling material.')
 U.HintText(d,bundle,'Bundle total','Required quantity × unit price for one filling bundle. The empty crate price is separate.')
 for i=1,5 do local b=CreateFrame('Button',nil,d);b:SetPoint('TOPLEFT',0,-66-(i-1)*24);b:SetSize(840,24);b.icon=U.Icon(b,0,-1,0,22);b.name=U.Text(b,30,-4,560,'');b.unit=U.Text(b,610,-4,96,'',nil,U.text,'RIGHT');b.total=U.Text(b,726,-4,114,'',nil,U.text,'RIGHT');d.options[i]=b end
 U.Fill(d,0,-190,840,1,U.line,'BORDER');d.note=U.Text(d,0,-200,610,'',nil,U.muted);d.net=U.Text(d,620,-200,220,'',nil,U.text,'RIGHT')
 U.HintText(d,d.cost,'Empty crate price','Price of one empty crate only. Filling materials are added to the upfront cost.')
 U.HintText(d,d.note,'Upfront and turn-in money',netHelp)
 U.HintText(d,d.net,'Net total',netHelp)
 U.Fill(frame,0,-702,900,1,U.line,'BORDER');frame.status=U.Text(frame,20,-713,670,'',nil,U.muted)
 U.HintText(frame,frame.status,'Price source status',function()return frame.status:GetText()..'\n\nRefresh re-reads cached quotes, not a new AH scan. If a provider is missing or fails, enable/configure it and try Refresh again.'end)
 local about=CreateFrame('Button',nil,frame);about:SetPoint('TOPLEFT',720,-705);about:SetSize(156,24);U.Text(about,0,-7,156,'About these prices',nil,U.muted,'RIGHT');frame.about=about
 U.Help(about,'About these prices',{'Cached unit buyout × quantity is an estimate; stock and full-stack costs are unverified.',"Refresh recalculates existing quotes. Scan AH collects new prices only at the AH. TSM does not share an age for its quote; your own scan uses its actual timestamp.",netHelp..' Other tiers still need field confirmation.'})
 about:SetScript('OnClick',U.ShowHelp)
 UISpecialFrames[#UISpecialFrames+1]='WaylaidValueFrame';frame:SetScript('OnShow',A.Refresh)
 frame:HookScript('OnHide',function()frame.settingsPanel:Hide()end);frame:Hide()
end
function A.Toggle()if not frame then create()end;frame:SetShown(not frame:IsShown())end
function A.IsShown()return frame and frame:IsShown()end
function A.SelectedReward()return frame and frame.rewards:IsShown()and frame.rewards.current and frame.rewards.current.reward or nil end
function A.UpdateScanControls()
 if not frame then return end
 local enabled=A.scanState.running or A.ScanAvailable()
 frame.scan:SetEnabled(enabled and true or false)
 frame.scan:SetText(A.scanState.running and 'Stop scan'or 'Scan AH')
 frame.scanDisabledHelp:SetShown(not enabled)
end
function A.ScanChanged()if frame then A.UpdateScanControls();if frame:IsShown()then frame.status:SetText(A.scanState.message)end end end
function A.ToggleSettings()
 if not frame then create()end
 local wasOpen=frame:IsShown()and frame.settingsPanel:IsShown()
 frame:Show();frame.settingsPanel:SetShown(not wasOpen)
end
function A.RefreshSettings()if frame then frame.settingsPanel:Refresh()end end
