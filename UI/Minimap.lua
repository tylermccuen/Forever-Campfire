-- Fish minimap button (drag around the minimap edge) + addon compartment entry.
local _, ns = ...

local ICON = "Interface\\Icons\\INV_Misc_Fish_02"
local btn

local function place()
  local angle = math.rad(ns.db.minimap.angle or 200)
  local r = (Minimap:GetWidth() / 2) + 5
  btn:ClearAllPoints()
  btn:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * r, math.sin(angle) * r)
end

local function tooltip(owner)
  GameTooltip:SetOwner(owner, "ANCHOR_LEFT")
  GameTooltip:SetText("|T" .. ICON .. ":16|t Forever Profession Guide")
  for _, key in ipairs(ns.guideOrder) do
    local g = ns.guides[key]
    if #g.skills == 1 then
      local sk = ns.Skill(key)
      local step = ns.CurrentStep(g)
      if sk.known then
        GameTooltip:AddDoubleLine("|T" .. g.icon .. ":14|t " .. ns.SkillDisplayName(key), sk.rank .. "/" .. sk.max, 1, 0.82, 0, 1, 1, 1)
        if step then GameTooltip:AddLine("     " .. step.title, 0.8, 0.8, 0.8) end
      end
    end
  end
  if not ns.TrackedGuideKey() then GameTooltip:AddLine("No professions learned yet. Visit a trainer!", 0.8, 0.8, 0.8) end
  GameTooltip:AddLine(" ")
  GameTooltip:AddLine("Left-click: open guide", 1, 1, 1)
  GameTooltip:AddLine("Right-click: show/hide tracker", 1, 1, 1)
  GameTooltip:AddLine("Drag: move button", 1, 1, 1)
  GameTooltip:Show()
end

local function click(button)
  if button == "RightButton" then
    ns.db.tracker = not ns.db.tracker
    ns.RequestRefresh()
  else
    ns.ToggleMain()
  end
end

function ns.InitMinimap()
  btn = CreateFrame("Button", "ForeverProfGuideMinimapButton", Minimap)
  btn:SetSize(31, 31)
  btn:SetFrameStrata("MEDIUM"); btn:SetFrameLevel(8)
  btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  btn:RegisterForDrag("LeftButton")
  btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  local icon = btn:CreateTexture(nil, "BACKGROUND")
  icon:SetTexture(ICON)
  icon:SetSize(20, 20); icon:SetPoint("TOPLEFT", 7, -5)
  icon:SetTexCoord(0.06, 0.94, 0.06, 0.94)
  btn.icon = icon
  local border = btn:CreateTexture(nil, "OVERLAY")
  border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  border:SetSize(53, 53); border:SetPoint("TOPLEFT")

  btn:SetScript("OnClick", function(_, b) click(b) end)
  btn:SetScript("OnEnter", tooltip)
  btn:SetScript("OnLeave", GameTooltip_Hide)
  btn:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function()
      local mx, my = Minimap:GetCenter()
      local cx, cy = GetCursorPosition()
      local s = Minimap:GetEffectiveScale()
      ns.db.minimap.angle = math.deg((math.atan2 or math.atan)(cy / s - my, cx / s - mx))
      place()
    end)
  end)
  btn:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
  ns.UpdateMinimap()
end

function ns.UpdateMinimap()
  if not btn then return end
  if ns.db.minimap.hide then btn:Hide() else place(); btn:Show() end
end

-- Addon compartment (the dropdown under the minimap); names come from the TOC.
function ForeverProfGuide_OnCompartmentClick(_, button) click(button) end
function ForeverProfGuide_OnCompartmentEnter(_, frame) tooltip(frame) end
function ForeverProfGuide_OnCompartmentLeave() GameTooltip:Hide() end
