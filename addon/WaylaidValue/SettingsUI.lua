local _,A=...
local U=A.UI
-- hors-kit: native WoW settings panel, composed from the addon's existing widgets.
local modes={'shift','compact','always','off'}
local labels={shift='Compact · hold Shift for details',compact='Compact only',always='Always detailed',off='Off'}
local modeHelp='Add Waylaid Value prices to crate tooltips in bags, auction searches and item links. Compact shows the cheapest bundle and net total. Shift adds other filling options when you hold Shift and hover again. Always shows those details every time. Off removes only our extra section. Hovering never scans the AH.'
function A.BuildSettings(parent)
 local p=CreateFrame('Frame','WaylaidValueSettings',parent,'BackdropTemplate')
 p:SetPoint('TOPLEFT',344,-50);p:SetSize(500,280);p:EnableMouse(true)
 if parent.GetFrameLevel then p:SetFrameLevel(parent:GetFrameLevel()+20)end
 U.Skin(p,{.10,.08,.055,1},{.50,.40,.25,1})
 U.Text(p,20,-18,420,'Settings','GameFontNormalLarge',U.gold)
 p.close=U.Button(p,452,-12,28,'×',function()p:Hide()end,'Close settings','Close this panel and continue using the current Crates or Rewards view. Changes are already saved.')
 U.Text(p,20,-54,440,'Crate item tooltips',nil,U.muted)
 local function chooseMode()
  if UIDropDownMenu_Initialize and UIDropDownMenu_CreateInfo and UIDropDownMenu_AddButton and ToggleDropDownMenu then
   if not p.menu then p.menu=CreateFrame('Frame','WaylaidValueTooltipMenu',p,'UIDropDownMenuTemplate')end
   UIDropDownMenu_Initialize(p.menu,function()
    for _,mode in ipairs(modes)do
     local key=mode;local info=UIDropDownMenu_CreateInfo()
     info.text=labels[key];info.checked=WaylaidValueDB.tooltipMode==key
     info.func=function()WaylaidValueDB.tooltipMode=key;p:Refresh()end
     info.tooltipTitle=labels[key];info.tooltipText=modeHelp;info.tooltipOnButton=true;UIDropDownMenu_AddButton(info)
    end
   end,'MENU');ToggleDropDownMenu(1,nil,p.menu,p.mode,0,0)
  else
   local nextMode={shift='compact',compact='always',always='off',off='shift'}
   WaylaidValueDB.tooltipMode=nextMode[WaylaidValueDB.tooltipMode]or 'shift';p:Refresh()
  end
 end
 p.mode=U.Button(p,20,-76,460,'',chooseMode,'Crate item tooltips',modeHelp)
 p.bags=U.Check(p,20,-118,460,'Show owned items in bags','Owned-item reminders','Show muted bag counts for empty crates and filling materials. Counts exclude the bank. This only changes the reminder; market prices, bundle choice and cost-per-Favor ranking stay unchanged.')
 p.bags:SetScript('OnClick',function(self)WaylaidValueDB.bagHints=self:GetChecked()and true or false;A.Refresh()end)
 p.minimap=U.Check(p,20,-154,460,'Show minimap icon','Minimap launcher','Show or hide the draggable crate icon. Left-click opens the addon; right-click opens Settings. If hidden, use /crates settings to restore it.')
 p.minimap:SetScript('OnClick',function(self)A.SetMinimapVisible(self:GetChecked()and true or false)end)
 U.Text(p,20,-204,460,'Changes save immediately.',nil,U.muted)
 U.Text(p,20,-226,460,'Right-click the minimap icon to open Settings.',nil,U.muted)
 function p:Refresh()
  self.mode:SetText(labels[WaylaidValueDB.tooltipMode]or labels.shift)
  self.bags:SetChecked(WaylaidValueDB.bagHints~=false)
  self.minimap:SetChecked(not WaylaidValueDB.minimap.hide)
 end
 p:SetScript('OnShow',p.Refresh);p:Refresh();p:Hide();return p
end
