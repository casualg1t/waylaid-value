local _, A = ...
local event = CreateFrame("Frame")
event:RegisterEvent("ADDON_LOADED")
event:RegisterEvent("GET_ITEM_INFO_RECEIVED")
event:RegisterEvent("SKILL_LINES_CHANGED")
event:RegisterEvent("PLAYER_LEVEL_UP")
event:RegisterEvent("BAG_UPDATE_DELAYED")
local pending=false
event:SetScript("OnEvent",function(_,kind,name)
  if kind=="GET_ITEM_INFO_RECEIVED" or kind=="SKILL_LINES_CHANGED" or kind=="PLAYER_LEVEL_UP" or kind=="BAG_UPDATE_DELAYED" then
    if not A.IsShown() or pending then return end
    pending=true
    if C_Timer and C_Timer.After then C_Timer.After(0.1,function()pending=false;if A.IsShown()then A.Refresh()end end)
    else pending=false;A.Refresh()end
    return
  end
  if name ~= "WaylaidValue" then return end
  if type(WaylaidValueDB) ~= "table" then WaylaidValueDB={} end
  if WaylaidValueDB.source ~= "TSM" and WaylaidValueDB.source ~= "Auctionator" and WaylaidValueDB.source ~= "Scan" then WaylaidValueDB.source="Auto" end
  local mode=WaylaidValueDB.tooltipMode
  if mode~='off'and mode~='compact'and mode~='always'then WaylaidValueDB.tooltipMode='shift'end
  WaylaidValueDB.bagHints=WaylaidValueDB.bagHints~=false
  WaylaidValueDB.expert=WaylaidValueDB.expert==true
  if type(WaylaidValueDB.minimap)~="table" then WaylaidValueDB.minimap={} end
  WaylaidValueDB.minimap.hide=WaylaidValueDB.minimap.hide==true
  local angle=tonumber(WaylaidValueDB.minimap.angle)
  WaylaidValueDB.minimap.angle=angle and angle==angle and math.abs(angle)<math.huge and angle%360 or 225
  SLASH_WAYLAIDVALUE1="/crates"
  SLASH_WAYLAIDVALUE2="/waylaid"
  SlashCmdList.WAYLAIDVALUE=function(args)
    local command=(args or ''):lower():match('^%s*(.-)%s*$')
    if command=='scan'then
      if A.scanState.running then A.CancelScan()else A.StartScan(A.SelectedReward and A.SelectedReward())end
    elseif command=='stop'then A.CancelScan()
    elseif command=='settings'or command=='config'then A.ToggleSettings()
    elseif command:match('^tooltip ')then
      local mode=command:match('^tooltip (%a+)$')
      if mode=='off'or mode=='compact'or mode=='shift'or mode=='always'then WaylaidValueDB.tooltipMode=mode;if A.RefreshSettings then A.RefreshSettings()end
      elseif print then print('Waylaid Value: /crates tooltip off | compact | shift | always')end
    else A.Toggle()end
  end
  A.CreateMinimapButton()
  if A.InitItemTooltips then A.InitItemTooltips()end
end)
