local _,A=...
-- Targeted, user-started read-only searches. No buying, bidding or AH replication.
local state={open=false,message='Open the auction house to scan.'}
A.scanState=state
local running,internal,hooked
local searches={}
local required={'SendBrowseQuery','GetBrowseResults','HasFullBrowseResults','RequestMoreBrowseResults','GetItemKeyInfo',
 'SendSearchQuery','HasSearchResults','HasFullCommoditySearchResults','HasFullItemSearchResults',
 'RequestMoreCommoditySearchResults','RequestMoreItemSearchResults','GetNumCommoditySearchResults','GetNumItemSearchResults',
 'GetCommoditySearchResultInfo','GetItemSearchResultInfo','IsThrottledMessageSystemReady'}
local function number(n)return type(n)=='number'and n==n and n>=0 and n<math.huge end
local function now()return GetTime()end
local function stamp()return time()end
local function notify(text)
 state.message=text
 if A.ScanChanged then A.ScanChanged()end
end
local function market()
 local realm=(GetNormalizedRealmName and GetNormalizedRealmName())or(GetRealmName and GetRealmName())
 local faction=UnitFactionGroup and UnitFactionGroup('player')
 if type(realm)=='string'and realm~=''and(faction=='Horde'or faction=='Alliance')then return realm..':'..faction end
end
local function snapshot()
 local key=market();local db=WaylaidValueDB
 local saved=key and type(db)=='table'and type(db.scans)=='table'and db.scans[key]
 if type(saved)=='table'and saved.schema==1 and type(saved.prices)=='table'and number(saved.at)and saved.at>0 then return saved end
end
function A.ScanSnapshot()return snapshot()end
function A.ScanPrice(id)
 local saved=snapshot();local p=saved and saved.prices[id]
 if type(p)=='table'and number(p.value)and p.value>0 and number(p.at)and p.at>0 then
  return {value=p.value,source='AH scan · unit estimate',scannedAt=p.at,age=math.max(0,stamp()-p.at)/86400}
 end
end
function A.ScanAvailable()
 if not state.open then return false,'Open the auction house to scan.'end
 if not market()then return false,'Realm or faction is unavailable. Log in fully, then try again.'end
 if not(C_Timer and type(C_Timer.After)=='function'and type(hooksecurefunc)=='function'and GetTime and time)then return false,'Scanning is unavailable on this client.'end
 for _,name in ipairs(required)do if not(C_AuctionHouse and type(C_AuctionHouse[name])=='function')then return false,'Scanning API unavailable: '..name end end
 return true
end
function A.ScanTargets(reward)
 local ids,seen={},{}
 local function add(id)if type(id)=='number'and id>0 and not seen[id]then seen[id]=true;ids[#ids+1]=id end end
 for _,crate in ipairs(A.Crates)do add(crate.id);for _,item in ipairs(crate.options)do add(item.id)end end
 for _,item in ipairs(reward and reward.reagents or{})do add(item.id)end
 table.sort(ids);return ids
end
local function finish(s,reason)
 if running~=s then return end
 running=nil;state.running=false
 if reason then notify(reason..' Previous scan kept.');return end
 WaylaidValueDB.scans=type(WaylaidValueDB.scans)=='table'and WaylaidValueDB.scans or{}
 WaylaidValueDB.scans[s.market]={schema=1,at=stamp(),prices=s.prices,items=#s.ids}
 WaylaidValueDB.source='Scan'
 notify('Scan complete · '..#s.ids..' items checked. Unit-price estimates; stock is not guaranteed.')
 if A.IsShown and A.IsShown()then A.Refresh()end
end
function A.CancelScan(reason)if running then finish(running,reason or 'Scan stopped.')end end
local function later(s,delay,fn)
 C_Timer.After(delay,function()
  if running~=s then return end
  if market()~=s.market then finish(s,'Market changed.');return end
  local ok=pcall(fn)
  if not ok then finish(s,'Auction data could not be read. Try again.')end
 end)
end
local function phase(s,name)
 s.phase=name;s.operation=(s.operation or 0)+1;s.deadline=now()+45;s.waiting=false
 local op=s.operation
 local function watchdog()
  if s.operation~=op then return end
  if now()>=s.deadline then finish(s,'Auction response timed out.');return end
  later(s,1,watchdog)
 end
 later(s,1,watchdog)
end
local function send(s,method,...)
 local args={...};local op=s.operation
 local function request()
  if s.operation~=op then return end
  while searches[1]and now()-searches[1]>=61 do table.remove(searches,1)end
  local delay=method=='SendSearchQuery'and #searches>=90 and math.max(0.1,61-(now()-searches[1]))or 0
  if delay>0 or not C_AuctionHouse.IsThrottledMessageSystemReady()then
   if delay>0 then s.deadline=now()+delay+45;notify('Scan paused for AH search limit · resumes in '..math.ceil(delay)..'s.')end
   later(s,math.max(.2,delay),request);return
  end
  s.waiting=true;s.deadline=now()+45
  if method=='SendSearchQuery'then searches[#searches+1]=now()end
  internal=true
  local ok=pcall(C_AuctionHouse[method],(unpack or table.unpack)(args))
  internal=false
  if not ok then finish(s,'Auction house rejected the search.')end
 end
 later(s,.05,request)
end
local nextItem,nextKey,readSearch,resolveKeys
nextItem=function(s)
 s.index=s.index+1
 if not s.ids[s.index]then finish(s);return end
 s.id=s.ids[s.index];s.minimum=nil;s.itemStamp=nil;s.keys={};s.seen={};s.keyIndex=0
 state.completed=s.index-1;state.total=#s.ids
 phase(s,'name')
 local function loadName()
  local get=C_Item and C_Item.GetItemInfo or GetItemInfo
  local name=get and get(s.id)
  if type(name)~='string'or name==''then
   if not s.requested[s.id]and C_Item and C_Item.RequestLoadItemDataByID then s.requested[s.id]=true;C_Item.RequestLoadItemDataByID(s.id)end
   notify('Loading item data · '..s.index..' / '..#s.ids)
   later(s,.2,loadName);return
  end
  notify('Scanning '..s.index..' / '..#s.ids..' · '..name)
  phase(s,'browse')
  send(s,'SendBrowseQuery',{searchString=name,sorts={},filters={},itemClassFilters={}})
 end
 loadName()
end
resolveKeys=function(s)
 for _,key in ipairs(s.keys)do
  local info=C_AuctionHouse.GetItemKeyInfo(key)
  if not info or type(info.isCommodity)~='boolean'then later(s,.2,function()resolveKeys(s)end);return end
  key.wvCommodity=info.isCommodity
 end
 nextKey(s)
end
nextKey=function(s)
 s.keyIndex=s.keyIndex+1;s.key=s.keys[s.keyIndex]
 if not s.key then
  s.prices[s.id]=s.minimum and{value=s.minimum,at=s.itemStamp}or false
  nextItem(s);return
 end
 s.commodity=s.key.wvCommodity;s.key.wvCommodity=nil
 phase(s,'search');send(s,'SendSearchQuery',s.key,{},true)
end
readSearch=function(s)
 local api,key=C_AuctionHouse,s.key
 if not api.HasSearchResults(key)then return end
 s.waiting=false
 local commodity=s.commodity
 local full
 if commodity then full=api.HasFullCommoditySearchResults(s.id)else full=api.HasFullItemSearchResults(key)end
 if not full then send(s,commodity and 'RequestMoreCommoditySearchResults'or 'RequestMoreItemSearchResults',commodity and s.id or key);return end
 local count=commodity and api.GetNumCommoditySearchResults(s.id)or api.GetNumItemSearchResults(key)
 if not number(count)or count%1~=0 then finish(s,'Incomplete auction results.');return end
 for i=1,count do
  local result=commodity and api.GetCommoditySearchResultInfo(s.id,i)or api.GetItemSearchResultInfo(key,i)
  if type(result)~='table'or not number(result.quantity)or result.quantity<=0 or result.quantity%1~=0 then finish(s,'Incomplete auction results.');return end
  local own=result.containsOwnerItem or result.containsAccountItem
  local value
  if commodity then
   -- Aggregated own-only levels cannot be bought; mixed own/account levels are conservatively excluded.
   local ownCount=result.numOwnerItems or 0
   if not number(ownCount)or ownCount>result.quantity then finish(s,'Incomplete ownership data.');return end
   if not result.containsAccountItem and(not own or(ownCount>0 and ownCount<result.quantity))then
    if not number(result.unitPrice)then finish(s,'Incomplete commodity price.');return end
    value=result.unitPrice
   end
  elseif not own then
   if not number(result.buyoutAmount or 0)then finish(s,'Incomplete buyout data.');return end
   value=(result.buyoutAmount or 0)/result.quantity
  end
  if value~=nil and not number(value)then finish(s,'Invalid auction price.');return end
  if value and value>0 then s.minimum=math.min(s.minimum or value,value);s.itemStamp=s.itemStamp or stamp()end
 end
 nextKey(s)
end
local function keyID(key)
 if type(key)~='table'then return end
 return table.concat({key.itemID or 0,key.itemLevel or 0,key.itemSuffix or 0,key.battlePetSpeciesID or 0},':')
end
local function onEvent(event,payload)
 if event=='AUCTION_HOUSE_SHOW'then state.open=true;notify('Ready to scan at the auction house.');return end
 if event=='AUCTION_HOUSE_CLOSED'then state.open=false;A.CancelScan('Auction house closed.');if not running then notify('Auction house closed. Previous scan kept.')end;return end
 local s=running
 if not s or not s.waiting then return end
 if market()~=s.market then finish(s,'Market changed.');return end
 if event=='AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED'or event=='AUCTION_HOUSE_BROWSE_FAILURE'then finish(s,'Auction search was interrupted.');return end
 if s.phase=='browse'and(event=='AUCTION_HOUSE_BROWSE_RESULTS_UPDATED'or event=='AUCTION_HOUSE_BROWSE_RESULTS_ADDED')then
  local rows=event=='AUCTION_HOUSE_BROWSE_RESULTS_ADDED'and payload or C_AuctionHouse.GetBrowseResults()
  if type(rows)~='table'then finish(s,'Incomplete browse results.');return end
  for _,row in ipairs(rows)do
   local key=row.itemKey
   if key and key.itemID==s.id then
    local id=keyID(key)
    if not s.seen[id]then s.seen[id]=true;s.keys[#s.keys+1]={itemID=key.itemID,itemLevel=key.itemLevel,itemSuffix=key.itemSuffix,battlePetSpeciesID=key.battlePetSpeciesID}end
   end
  end
  s.waiting=false
  if C_AuctionHouse.HasFullBrowseResults()then phase(s,'metadata');resolveKeys(s)else send(s,'RequestMoreBrowseResults')end
 elseif s.phase=='search'and((s.commodity and(event=='COMMODITY_SEARCH_RESULTS_UPDATED'or event=='COMMODITY_SEARCH_RESULTS_ADDED')and payload==s.id)
  or(not s.commodity and(event=='ITEM_SEARCH_RESULTS_UPDATED'or event=='ITEM_SEARCH_RESULTS_ADDED')and keyID(payload)==keyID(s.key)))then readSearch(s)end
end
local events=CreateFrame('Frame')
for _,event in ipairs({'AUCTION_HOUSE_SHOW','AUCTION_HOUSE_CLOSED','AUCTION_HOUSE_BROWSE_RESULTS_UPDATED','AUCTION_HOUSE_BROWSE_RESULTS_ADDED',
 'AUCTION_HOUSE_BROWSE_FAILURE','COMMODITY_SEARCH_RESULTS_UPDATED','COMMODITY_SEARCH_RESULTS_ADDED','ITEM_SEARCH_RESULTS_UPDATED','ITEM_SEARCH_RESULTS_ADDED',
 'AUCTION_HOUSE_THROTTLED_MESSAGE_DROPPED'})do events:RegisterEvent(event)end
events:SetScript('OnEvent',function(_,event,payload)
 local ok=pcall(onEvent,event,payload)
 if not ok and running then finish(running,'Auction data could not be read. Try again.')end
end)
function A.StartScan(reward)
 if running then return false,'A scan is already running.'end
 local ready,reason=A.ScanAvailable();if not ready then notify(reason);return false,reason end
 if not hooked then
  for _,method in ipairs({'SendBrowseQuery','SendSearchQuery','SendSellSearchQuery','RequestMoreBrowseResults','RequestMoreCommoditySearchResults',
   'RequestMoreItemSearchResults','RefreshCommoditySearchResults','RefreshItemSearchResults','SearchForItemKeys','SearchForFavorites','ReplicateItems'})do
   if type(C_AuctionHouse[method])=='function'then
    local name=method
    hooksecurefunc(C_AuctionHouse,name,function()
     if not internal then
      if name=='SendSearchQuery'or name=='SendSellSearchQuery'then
       while searches[1]and now()-searches[1]>=61 do table.remove(searches,1)end
       searches[#searches+1]=now()
      end
      A.CancelScan('Another AH search took over.')
     end
    end)
   end
  end
  hooked=true
 end
 local s={market=market(),ids=A.ScanTargets(reward),index=0,prices={},requested={}}
 running=s;state.running=true;state.completed=0;state.total=#s.ids
 later(s,0,function()nextItem(s)end);return true
end
