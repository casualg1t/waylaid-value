local _, A = ...
-- Native launcher: no mandatory broker library and no dependency on OneForAll.
function A.CreateMinimapButton()
  if A.minimapButton or not Minimap then return end
  local db=WaylaidValueDB.minimap
  local b=CreateFrame("Button","WaylaidValueMinimapButton",Minimap)
  b:SetSize(32,32);b:SetFrameStrata("MEDIUM");b:SetFrameLevel(8)
  b:RegisterForClicks("LeftButtonUp");b:RegisterForDrag("LeftButton")
  local background=b:CreateTexture(nil,"BACKGROUND")
  background:SetSize(24,24);background:SetPoint("CENTER")
  background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
  local icon=b:CreateTexture(nil,"ARTWORK")
  icon:SetSize(20,20);icon:SetPoint("CENTER",0,1)
  icon:SetTexture("Interface\\Icons\\INV_Crate_07");icon:SetTexCoord(0.07,0.93,0.07,0.93)
  local border=b:CreateTexture(nil,"OVERLAY")
  border:SetSize(54,54);border:SetPoint("TOPLEFT")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  b:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight","ADD")
  local function place()
    local angle=math.rad(db.angle)
    local radius=Minimap:GetWidth()/2+10
    b:ClearAllPoints();b:SetPoint("CENTER",Minimap,"CENTER",math.cos(angle)*radius,math.sin(angle)*radius)
  end
  local function stopDrag(self)
    self:SetScript("OnUpdate",nil)
  end
  b:SetScript("OnDragStart",function(self)
    self:SetScript("OnUpdate",function()
      local x,y=GetCursorPosition();local scale=Minimap:GetEffectiveScale()
      local cx,cy=Minimap:GetCenter()
      if not cx or not cy then return end
      local dx,dy=x/scale-cx,y/scale-cy
      if dx~=0 or dy~=0 then
        -- Lua 5.1's math.atan accepts only one argument; preserve every quadrant.
        local angle
        if dx==0 then angle=dy>0 and math.pi/2 or -math.pi/2
        else angle=math.atan(dy/dx);if dx<0 then angle=angle+(dy>=0 and math.pi or -math.pi)end end
        db.angle=math.deg(angle);place()
      end
    end)
  end)
  b:SetScript("OnDragStop",stopDrag);b:SetScript("OnHide",stopDrag)
  b:SetScript("OnClick",function() A.Toggle() end)
  A.UI.Help(b,'Waylaid Value',{'Left-click to open or close Crates and Rewards.','Drag to move this icon around the minimap. Its position is saved.','You can also open the window with /crates or /waylaid.'})
  A.minimapButton=b;place();b:Show()
end
