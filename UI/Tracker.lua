-- Small on-screen tracker: current skill, current step, what to do now, top alert.
local _, ns = ...
local C = ns.C

local t

-- Which profession the tracker follows: auto, then each guide in turn.
function ns.CycleTrackerGuide()
  local order = { "auto" }
  for _, k in ipairs(ns.guideOrder) do table.insert(order, k) end
  local cur = ns.char.trackerGuide or "auto"
  local nextKey = order[1]
  for i, k in ipairs(order) do if k == cur then nextKey = order[i % #order + 1] end end
  ns.char.trackerGuide = nextKey
  ns.Print("Tracker shows: " .. (nextKey == "auto" and "auto (the skill you last leveled)" or ns.guides[nextKey].name))
  ns.RequestRefresh()
end

local function build()
  t = CreateFrame("Button", "ForeverCampfireTracker", UIParent, "BackdropTemplate")
  ns.RegisterControllerFrame(t)
  t:SetBackdrop(ns.BACKDROP)
  t:SetBackdropColor(0, 0, 0, 0.7); t:SetBackdropBorderColor(1, 0.82, 0, 0.8)
  t:SetWidth(280)
  t:SetScale(ns.db.trackerScale or 1)
  local pos = ns.db.trackerPos
  if pos then t:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4]) else t:SetPoint("RIGHT", UIParent, "RIGHT", -60, 120) end
  t:SetMovable(true); t:EnableMouse(true); t:SetClampedToScreen(true)
  t:RegisterForDrag("LeftButton")
  t:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  t:SetScript("OnDragStart", function(self) if not ns.db.trackerLocked then self:StartMoving() end end)
  t:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, _, rp, x, y = self:GetPoint(); ns.db.trackerPos = { p, rp, x, y }
  end)
  t:SetScript("OnClick", function(self, btn)
    if btn == "RightButton" then
      ns.CycleTrackerGuide()
    else
      ns.ShowMain()
    end
  end)
  t:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("Forever Campfire")
    GameTooltip:AddLine("Left-click: open the guide", 1, 1, 1)
    GameTooltip:AddLine("Right-click: switch profession (auto/cooking/fishing/both)", 1, 1, 1)
    GameTooltip:AddLine("Drag to move (/fc lock to lock)", 1, 1, 1)
    GameTooltip:Show()
  end)
  t:SetScript("OnLeave", GameTooltip_Hide)

  t.icon = t:CreateTexture(nil, "ARTWORK")
  t.icon:SetSize(20, 20); t.icon:SetPoint("TOPLEFT", 8, -8)
  t.head = t:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  t.head:SetPoint("LEFT", t.icon, "RIGHT", 6, 0); t.head:SetJustifyH("LEFT")
  t.bar = CreateFrame("StatusBar", nil, t)
  t.bar:SetHeight(6)
  t.bar:SetPoint("TOPLEFT", 8, -32); t.bar:SetPoint("TOPRIGHT", -8, -32)
  t.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  t.bar:SetStatusBarColor(0.25, 0.6, 1)
  local bg = t.bar:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(0, 0, 0, 0.6)
  t.step = t:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  t.step:SetPoint("TOPLEFT", 8, -44); t.step:SetWidth(264); t.step:SetJustifyH("LEFT")
  t.now = t:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  t.now:SetPoint("TOPLEFT", t.step, "BOTTOMLEFT", 0, -3); t.now:SetWidth(264); t.now:SetJustifyH("LEFT")
  t.alert = t:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  t.alert:SetPoint("TOPLEFT", t.now, "BOTTOMLEFT", 0, -4); t.alert:SetWidth(264); t.alert:SetJustifyH("LEFT"); t.alert:SetSpacing(5); t.now:SetSpacing(3)
end

function ns.UpdateTracker()
  if not ns.db then return end
  if not ns.db.tracker then if t then t:Hide() end return end
  if not t then build() end
  local key = ns.TrackedGuideKey()
  if not key then
    t.icon:SetTexture("Interface\\Icons\\Spell_Fire_Fire")
    t.head:SetText("Forever Campfire")
    t.bar:Hide()
    t.step:SetText(C.gold .. "No professions learned yet" .. C.r)
    t.now:SetText("Visit a trainer to start. Click here for where to go.")
    t.alert:SetText("")
    t:SetHeight(44 + t.step:GetStringHeight() + 3 + t.now:GetStringHeight() + 10)
    t:Show()
    return
  end
  local g = ns.guides[key]
  local step = ns.CurrentStep(g)
  local sk = ns.Skill(step and step.skill or g.skills[1])
  local skillKey = step and step.skill or g.skills[1]

  t.icon:SetTexture((ns.guides[skillKey] and ns.guides[skillKey].icon) or g.icon)
  if sk.known then
    t.head:SetText(ns.SkillDisplayName(skillKey) .. "  " .. C.white .. sk.rank .. "/" .. sk.max .. C.r
      .. ((#g.skills > 1) and (C.grey .. "  (Fish + Cook)" .. C.r) or ""))
    t.bar:SetMinMaxValues(0, math.max(sk.max, 1)); t.bar:SetValue(sk.rank); t.bar:Show()
  else
    t.head:SetText(ns.SkillDisplayName(skillKey) .. C.grey .. "  not learned" .. C.r)
    t.bar:Hide()
  end
  t.step:SetText(step and (C.gold .. step.title .. C.r) or (C.green .. "Maxed!" .. C.r))
  local nowText = ns.NowText(g)
  local fishing = false
  for _, k in ipairs(g.skills) do if k == "fishing" then fishing = true end end
  local catchLine = fishing and ns.CatchTrackerLine and ns.CatchTrackerLine()
  t.now:SetText(catchLine and (nowText .. "\n" .. catchLine) or nowText)
  local alerts = ns.Alerts(g)
  local a = alerts[1]
  t.alert:SetText(a and ((a.kind == "warn" and C.orange or C.blue) .. a.text .. C.r) or "")
  local h = 44 + t.step:GetStringHeight() + 3 + t.now:GetStringHeight() + 10
  if a then h = h + t.alert:GetStringHeight() + 4 end
  t:SetHeight(h)
  t:Show()
end

ns.OnRefresh(function() ns.UpdateTracker() end)
