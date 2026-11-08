-- Real scanner callbacks with a deterministic AH/timer double; never contacts a game server.
local A={Crates={{id=101,options={{id=201,quantity=7}}}}}
local clock,epoch,queue=0,1800000000,{}
GetTime=function()return clock end;time=function()return epoch+math.floor(clock)end
GetRealmName=function()return 'TestRealm'end;UnitFactionGroup=function()return 'Horde'end
WaylaidValueDB={source='TSM'}
C_Timer={After=function(delay,fn)queue[#queue+1]={at=clock+delay,fn=fn}end}
local function tick(untilTime)
 while true do
  table.sort(queue,function(a,b)return a.at<b.at end)
  if not queue[1]or queue[1].at>untilTime then clock=untilTime;return end
  local q=table.remove(queue,1);clock=q.at;q.fn()
 end
end
local events={};CreateFrame=function()return{RegisterEvent=function()end,SetScript=function(_,_,fn)events[#events+1]=fn end}end
local function event(name,payload)for _,fn in ipairs(events)do fn(nil,name,payload)end end
hooksecurefunc=function(t,k,fn)local original=t[k];t[k]=function(...)local r={original(...)};fn(...);return(unpack or table.unpack)(r)end end
local calls,query,key,ready,full={},nil,nil,true,true
local browse,items,commodities={}, {}, {}
local commodity={ [101]=false,[201]=true,[301]=true }
C_Item={GetItemInfo=function(id)return 'Local name '..id end}
C_AuctionHouse={
 SendBrowseQuery=function(q)query=q;calls[#calls+1]='browse'end,
 GetBrowseResults=function()return browse end,HasFullBrowseResults=function()return full end,
 RequestMoreBrowseResults=function()calls[#calls+1]='more browse'end,
 GetItemKeyInfo=function(k)return{isCommodity=commodity[k.itemID]}end,
 SendSearchQuery=function(k)key=k;calls[#calls+1]='search'end,
 HasSearchResults=function()return true end,
 HasFullCommoditySearchResults=function()return full end,HasFullItemSearchResults=function()return full end,
 RequestMoreCommoditySearchResults=function()calls[#calls+1]='more commodity'end,
 RequestMoreItemSearchResults=function()calls[#calls+1]='more item'end,
 GetNumCommoditySearchResults=function()return #commodities end,GetNumItemSearchResults=function()return #items end,
 GetCommoditySearchResultInfo=function(_,i)return commodities[i]end,GetItemSearchResultInfo=function(_,i)return items[i]end,
 IsThrottledMessageSystemReady=function()return ready end,
}
assert(loadfile('addon/WaylaidValue/Scan.lua'))('',A)
local function advance()tick(clock+.1)end
local function begin()
 assert(A.StartScan());advance();assert(query.searchString=='Local name 101')
end
local function respondBrowse(id)
 browse={{itemKey={itemID=id,itemLevel=0}},{itemKey={itemID=999,itemLevel=0}}}
 event('AUCTION_HOUSE_BROWSE_RESULTS_UPDATED');advance()
end
local function complete()
 respondBrowse(101)
 -- Item auctions: exclude owned listings and bids, divide whole-stack buyout only for a unit estimate.
 items={{quantity=2,buyoutAmount=40},{quantity=1,buyoutAmount=1,containsOwnerItem=true},{quantity=2}}
 event('ITEM_SEARCH_RESULTS_UPDATED',{itemID=999,itemLevel=0});assert(A.scanState.completed==0)
 event('ITEM_SEARCH_RESULTS_UPDATED',{itemID=101,itemLevel=0});advance()
 respondBrowse(201)
 commodities={{quantity=5,unitPrice=3,numOwnerItems=2,containsOwnerItem=true},{quantity=2,unitPrice=1,numOwnerItems=2,containsOwnerItem=true},{quantity=2,unitPrice=2,containsAccountItem=true}}
 event('COMMODITY_SEARCH_RESULTS_UPDATED',201)
end
assert(not A.ScanAvailable()and not A.StartScan())
event('AUCTION_HOUSE_SHOW');assert(A.ScanAvailable())
assert(#A.ScanTargets({reagents={{id=201},{id=301},{id=301}}})==3)
begin();complete()
assert(not A.scanState.running and WaylaidValueDB.source=='Scan')
assert(A.ScanPrice(101).value==20 and A.ScanPrice(201).value==3)
assert(A.ScanPrice(201).scannedAt==epoch and A.ScanSnapshot().items==2)
local saved=A.ScanSnapshot()
begin();A.CancelScan();tick(clock+50);assert(A.ScanSnapshot()==saved and not A.scanState.running)
begin();C_AuctionHouse.SendBrowseQuery({searchString='external'});assert(not A.scanState.running and A.ScanSnapshot()==saved)
begin();event('AUCTION_HOUSE_CLOSED');assert(not A.scanState.running and A.ScanSnapshot()==saved)
event('AUCTION_HOUSE_SHOW');begin();tick(clock+46);assert(not A.scanState.running and A.scanState.message:find('timed out'))
begin();respondBrowse(101);items={{quantity=0,buyoutAmount=1}};event('ITEM_SEARCH_RESULTS_UPDATED',{itemID=101,itemLevel=0});assert(A.ScanSnapshot()==saved and not A.scanState.running)
-- A fully resolved empty search records absence, without inheriting an old quote.
begin();browse={};event('AUCTION_HOUSE_BROWSE_RESULTS_UPDATED');advance();browse={};event('AUCTION_HOUSE_BROWSE_RESULTS_UPDATED')
assert(not A.ScanPrice(101)and A.ScanSnapshot()~=saved)
-- Market isolation and conservative commit on failure.
UnitFactionGroup=function()return 'Alliance'end;assert(not A.ScanPrice(201)and not A.ScanSnapshot())
local previous=WaylaidValueDB.scans
begin();UnitFactionGroup=function()return 'Horde'end;tick(clock+1.1);assert(not A.scanState.running and WaylaidValueDB.scans==previous)
ready=false;begin();local count=#calls;tick(clock+1);assert(#calls==count);A.CancelScan();ready=true
-- Complete browse/search pages are required before publishing a new quote.
begin();full=false;respondBrowse(101);assert(calls[#calls]=='more browse')
full=true;event('AUCTION_HOUSE_BROWSE_RESULTS_ADDED',{});advance();full=false
event('ITEM_SEARCH_RESULTS_UPDATED',{itemID=101,itemLevel=0});advance();assert(calls[#calls]=='more item');A.CancelScan();full=true
-- Never use a partial commodity response or an unloaded price as confirmed absence.
begin();respondBrowse(101);items={{quantity=1,buyoutAmount=20}};event('ITEM_SEARCH_RESULTS_UPDATED',{itemID=101,itemLevel=0});advance();respondBrowse(201)
commodities={{quantity=3}};local before=A.ScanSnapshot();event('COMMODITY_SEARCH_RESULTS_UPDATED',201)
assert(A.ScanSnapshot()==before and not A.scanState.running)
-- Search limits include other addons' requests and pause instead of dropping the scan.
for i=1,95 do C_AuctionHouse.SendSearchQuery({itemID=999},{},true)end
begin();respondBrowse(101);local searchCount=#calls;tick(clock+1)
assert(#calls==searchCount and A.scanState.running and A.scanState.message:find('search limit'))
A.CancelScan()
print('PASS: targeted AH scanner; ownership, pagination, guarded callbacks, cancellation/timeout, no partial commits, missing items and market isolation.')
