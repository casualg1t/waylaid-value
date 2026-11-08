local _, A = ...
local event = CreateFrame("Frame")
event:RegisterEvent("ADDON_LOADED")
event:RegisterEvent("GET_ITEM_INFO_RECEIVED")
event:RegisterEvent("SKILL_LINES_CHANGED")
event:RegisterEvent("PLAYER_LEVEL_UP")
local pending=false
event:SetScript("OnEvent",function(_,kind,name)
  if kind=="GET_ITEM_INFO_RECEIVED" or kind=="SKILL_LINES_CHANGED" or kind=="PLAYER_LEVEL_UP" then
    if not A.IsShown() or pending then return end
    pending=true
    if C_Timer and C_Timer.After then C_Timer.After(0.1,function()pending=false;if A.IsShown()then A.Refresh()end end)
    else pending=false;A.Refresh()end
    return
  end
  if name ~= "WaylaidValue" then return end
  if type(WaylaidValueDB) ~= "table" then WaylaidValueDB={} end
  if WaylaidValueDB.source ~= "TSM" and WaylaidValueDB.source ~= "Auctionator" then WaylaidValueDB.source="Auto" end
  WaylaidValueDB.expert=WaylaidValueDB.expert==true
  if type(WaylaidValueDB.minimap)~="table" then WaylaidValueDB.minimap={} end
  local angle=tonumber(WaylaidValueDB.minimap.angle)
  WaylaidValueDB.minimap.angle=angle and angle==angle and math.abs(angle)<math.huge and angle%360 or 225
  SLASH_WAYLAIDVALUE1="/crates"
  SLASH_WAYLAIDVALUE2="/waylaid"
  SlashCmdList.WAYLAIDVALUE=A.Toggle
  A.CreateMinimapButton()
end)
