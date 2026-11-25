-- Main guide window: skill bars on top, the skill tree on the left, the step
-- detail panel ("NOW") on the right, profession tabs along the bottom.
local _, ns = ...
local C = ns.C

local BACKDROP = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  tile = true, tileSize = 16, edgeSize = 14,
  insets = { left = 3, right = 3, top = 3, bottom = 3 },
}
ns.BACKDROP = BACKDROP

local f, tabs, bars, treePanel, treeScroll, treeContent, listContent, viewBar, detail, shop, welcome
local selected
local lastGuideShown
ns.selectedStep = nil
ns.detailInfo = nil
ns.views = {}   -- [guideKey] = "route" / "recipes"

local CAMP_ICON = "Interface\\Icons\\Spell_Fire_Fire"

-- The collection (if any) for a guide: Cooking and Fish + Cook have the Cooking recipes.
local function collectionFor(key)
  local g = ns.guides[key]
  if not g or not ns.Collections then return nil end
  for _, s in ipairs(g.skills) do if ns.Collections[s] then return ns.Collections[s] end end
  return nil
end

local function currentView()
  if selected == "camp" then return "camp" end
  local v = ns.views[selected] or "route"
  if v == "recipes" and not collectionFor(selected) then v = "route" end
  return v
end

-- Tabs: the guides you can see, plus Camp once you know any profession.
local function tabKeys()
  local keys = ns.VisibleGuides()
  if #keys > 0 then table.insert(keys, "camp") end
  return keys
end

function ns.ShowInfo(info)
  ns.detailInfo = info
  ns.UpdateMain()
end

local function savePos(frame, key)
  local p, _, rp, x, y = frame:GetPoint()
  ns.db[key] = { p, rp, x, y }
end

local function makeBar(parent)
  local b = CreateFrame("StatusBar", nil, parent)
  b:SetHeight(18)
  b:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  b:SetStatusBarColor(0.23, 0.48, 0.84)
  local bg = b:CreateTexture(nil, "BACKGROUND")
  bg:SetAllPoints(); bg:SetColorTexture(0, 0, 0, 0.5)
  b.icon = b:CreateTexture(nil, "OVERLAY")
  b.icon:SetSize(18, 18); b.icon:SetPoint("RIGHT", b, "LEFT", -4, 0)
  b.text = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  b.text:SetPoint("CENTER")
  return b
end

local function checkbox(parent, label, key, onChange)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetSize(22, 22)
  local t = cb:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  t:SetPoint("LEFT", cb, "RIGHT", 0, 1); t:SetText(label)
  cb.label = t
  cb:SetScript("OnShow", function(self) self:SetChecked(ns.db[key]) end)
  cb:SetScript("OnClick", function(self)
    ns.db[key] = self:GetChecked() and true or false
    if onChange then onChange() end
    ns.RequestRefresh()
  end)
  return cb
end

local function tip(frame, title, text)
  frame:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(title)
    GameTooltip:AddLine(text, 1, 1, 1, true)
    GameTooltip:Show()
  end)
  frame:SetScript("OnLeave", GameTooltip_Hide)
end

function ns.SelectStep(step)
  ns.selectedStep = step
  ns.UpdateMain()
end

---------------------------------------------------------------------------
-- Header (skill bars)
---------------------------------------------------------------------------
local function updateBars()
  local g = ns.guides[selected] or { skills = { "cooking" }, icon = CAMP_ICON }
  for i = 1, 2 do
    local key = g.skills[i]
    local b = bars[i]
    if key then
      local sk = ns.Skill(key)
      b:Show()
      local info = ns.guides[key]
      b.icon:SetTexture(info and info.icon or g.icon)
      if sk.known then
        b:SetMinMaxValues(0, math.max(sk.max, 1)); b:SetValue(sk.rank)
        b.text:SetText(ns.SkillDisplayName(key) .. "  " .. sk.rank .. " / " .. sk.max .. "  (" .. ns.RankName(sk.max) .. ")")
      else
        b:SetMinMaxValues(0, 1); b:SetValue(0)
        b.text:SetText(ns.SkillDisplayName(key) .. ": not learned")
      end
    else
      b:Hide()
    end
  end
  local lastBar = g.skills[2] and bars[2] or bars[1]
  treePanel:ClearAllPoints()
  treePanel:SetPoint("TOPLEFT", lastBar, "BOTTOMLEFT", -26, -10)
  treePanel:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 16, 44)
  treePanel:SetWidth(math.floor((f:GetWidth() - 42) * 0.58))

  -- Route / Recipes switch for guides with a collection
  local col = (selected ~= "camp") and collectionFor(selected) or nil
  viewBar:SetShown(col ~= nil)
  treeScroll:ClearAllPoints()
  treeScroll:SetPoint("TOPLEFT", treePanel, "TOPLEFT", 6, col and -36 or -6)
  treeScroll:SetPoint("BOTTOMRIGHT", treePanel, "BOTTOMRIGHT", -28, 6)
  if col then
    local v = currentView()
    local have, total = ns.CollectionCounts(col)
    local scanned = ns.char.known and ns.char.known[col.skill]
    viewBar.route:SetText(v == "route" and (C.gold .. "Route" .. C.r) or "Route")
    local rl = "Recipes " .. (scanned and (have .. "/" .. total) or ("(" .. total .. ")"))
    viewBar.recipes:SetText(v == "recipes" and (C.gold .. rl .. C.r) or rl)
    if v == "route" then viewBar.route:LockHighlight(); viewBar.recipes:UnlockHighlight() else viewBar.recipes:LockHighlight(); viewBar.route:UnlockHighlight() end
  end
end

---------------------------------------------------------------------------
-- Tree
---------------------------------------------------------------------------
local function updateTree()
  local v = currentView()
  local W = treeScroll:GetWidth()
  local key = selected .. "/" .. v
  if v == "route" then
    listContent:Hide(); treeContent:Show()
    if treeScroll:GetScrollChild() ~= treeContent then treeScroll:SetScrollChild(treeContent) end
    treeContent:SetWidth(W)
    treeContent:SetHeight(ns.LayoutTree(ns.guides[selected], W))
  else
    treeContent:Hide(); listContent:Show()
    if treeScroll:GetScrollChild() ~= listContent then treeScroll:SetScrollChild(listContent) end
    listContent:SetWidth(W)
    local h = (v == "camp") and ns.LayoutCamp(listContent, W) or ns.LayoutRecipes(listContent, W, collectionFor(selected))
    listContent:SetHeight(h)
  end
  if lastGuideShown ~= key then
    lastGuideShown = key
    local target = (v == "route") and math.max(0, (ns.treeCurrentY or 0) - 80) or 0
    if treeScroll.SetVerticalScroll then pcall(treeScroll.SetVerticalScroll, treeScroll, target) end
  end
end

---------------------------------------------------------------------------
-- Detail panel
---------------------------------------------------------------------------
local function updateDetail()
  local d = detail
  local v = currentView()
  if v ~= "route" then
    local info = ns.detailInfo
    if not info then
      if v == "camp" then info = ns.CampRulesInfo()
      else
        local col = collectionFor(selected)
        info = { label = "RECIPES", title = col.title, now = C.grey .. "Pick a recipe on the left to see where it comes from." .. C.r,
                 body = C.green .. "Green" .. C.r .. ": you know it.\n" .. C.gold .. "Gold" .. C.r .. ": your skill is high enough, go get it.\n" .. C.grey .. "Grey" .. C.r .. ": needs more skill.\n \nThe guide reads your known recipes whenever you open your profession window." }
      end
    end
    d.label:SetText(C.gold .. info.label .. C.r)
    d.title:SetText(info.title)
    d.now:SetText(info.now or "")
    d.alerts:SetText("")
    d.body:SetText(info.body or "")
    local w = d.scroll:GetWidth() - 8
    for _, fs in ipairs({ d.label, d.title, d.now, d.alerts, d.body, d.catchTitle, d.catch }) do fs:SetWidth(w) end
    d.catchTitle:Hide(); d.catch:Hide(); d.catchBg:Hide()
    d.inner:SetWidth(w)
    d.inner:SetHeight(d.label:GetStringHeight() + d.title:GetStringHeight() + d.now:GetStringHeight() + d.body:GetStringHeight() + 60)
    d.mapBtn:Hide(); d.backBtn:Hide(); d.autoBtn:Hide()
    d.shopBtn:SetShown(v ~= "camp")
    if d.shopBtn:IsShown() then d.shopBtn:ClearAllPoints(); d.shopBtn:SetPoint("BOTTOMLEFT", d, "BOTTOMLEFT", 10, 10) end
    return
  end
  d.shopBtn:Show()
  local g = ns.guides[selected]
  local current = ns.CurrentStep(g)
  local step = ns.selectedStep
  if not step or step.guide ~= g then step = current; ns.selectedStep = nil end
  local isCurrent = (step == current)

  if not step then
    d.label:SetText(C.green .. "ROUTE COMPLETE" .. C.r)
    d.title:SetText(g.name .. " is maxed!")
    d.now:SetText(""); d.alerts:SetText(""); d.body:SetText("")
  else
    local state = ns.StepState(step)
    d.label:SetText(isCurrent and (C.gold .. "NOW" .. C.r) or (C.grey .. (state == "done" and "DONE" or "LATER") .. C.r))
    local prefix = (#g.skills > 1) and (ns.SkillDisplayName(step.skill) .. ": ") or ""
    d.title:SetText(prefix .. step.title)
    d.now:SetText(isCurrent and ns.NowText(g) or (C.grey .. ns.RangeText(step) .. C.r))
    local al = {}
    if isCurrent then
      for _, a in ipairs(ns.Alerts(g)) do
        table.insert(al, (a.kind == "warn" and (C.orange .. "! ") or (C.blue .. "i ")) .. C.r .. a.text)
      end
    end
    d.alerts:SetText(table.concat(al, "\n"))
    d.body:SetText(ns.StepBody(step))
  end

  local w = d.scroll:GetWidth() - 8
  for _, fs in ipairs({ d.label, d.title, d.now, d.alerts, d.body, d.catchTitle, d.catch }) do fs:SetWidth(w) end

  -- Catch Log card for fishing guides
  local fishing = false
  for _, k in ipairs(g.skills) do if k == "fishing" then fishing = true end end
  if fishing and ns.CatchLines then
    d.catchTitle:SetText("|TInterface\\Icons\\INV_Misc_Fish_02:14|t Catch Log")
    d.catch:SetText(table.concat(ns.CatchLines(), "\n"))
    d.catchTitle:Show(); d.catch:Show(); d.catchBg:Show()
  else
    d.catchTitle:Hide(); d.catch:Hide(); d.catchBg:Hide()
  end

  local h = d.label:GetStringHeight() + 6 + d.title:GetStringHeight() + 6 + d.now:GetStringHeight() + 10
  if d.alerts:GetText() ~= "" then h = h + d.alerts:GetStringHeight() + 10 end
  h = h + d.body:GetStringHeight() + 16
  if d.catch:IsShown() then h = h + d.catchTitle:GetStringHeight() + d.catch:GetStringHeight() + 34 end
  d.inner:SetWidth(w); d.inner:SetHeight(h)

  -- buttons
  d.mapBtn.step = step
  d.mapBtn:SetShown(step ~= nil and ns.StepPins ~= nil and ns.StepPins(step) ~= nil)
  d.backBtn:SetShown(step ~= nil and not isCurrent and current ~= nil)
  d.autoBtn.step = step
  d.autoBtn:SetShown(step ~= nil and ns.IsPinned(step) and #(step.options or {}) > 1)
  local x = 0
  for _, b in ipairs({ d.mapBtn, d.shopBtn, d.backBtn, d.autoBtn }) do
    if b:IsShown() then b:ClearAllPoints(); b:SetPoint("BOTTOMLEFT", d, "BOTTOMLEFT", 10 + x, 10); x = x + b:GetWidth() + 6 end
  end
end

---------------------------------------------------------------------------
-- Shopping list
---------------------------------------------------------------------------
local function updateShop()
  if not (shop and shop:IsShown()) then return end
  local g = ns.guides[selected]
  if not g then shop:Hide(); return end
  local lines = { C.gold .. "Rest of the route:" .. C.r, "" }
  local list = ns.ShoppingList(g)
  for _, it in ipairs(list) do
    local col = (it.have >= it.need) and C.green or C.red
    table.insert(lines, ns.IconText(it.id) .. " " .. ns.ItemName(it.id) .. "  " .. col .. it.have .. "/" .. it.need .. C.r
      .. (it.vendor and (C.grey .. "  (vendor)" .. C.r) or ""))
  end
  if #list == 0 then table.insert(lines, C.grey .. "Nothing to buy: this route uses what you gather." .. C.r) end
  table.insert(lines, "")
  table.insert(lines, C.grey .. "Counts use the option chosen in each step." .. C.r)
  shop.text:SetWidth(shop:GetWidth() - 20)
  shop.text:SetText(table.concat(lines, "\n"))
end

function ns.LayoutTabs()
  if not tabs then return end
  local visible = tabKeys()
  local shown = {}
  for _, key in ipairs(visible) do shown[key] = true end
  for key, t in pairs(tabs) do if not shown[key] then t:Hide() end end
  local perRow = (#visible > 7) and math.ceil(#visible / 2) or math.max(#visible, 1)
  local gap = 3
  local w = math.min(150, math.floor((f:GetWidth() - 24 - gap * (perRow - 1)) / perRow))
  for i, key in ipairs(visible) do
    local t = tabs[key]
    t:Show()
    t:ClearAllPoints()
    t:SetWidth(w)
    local col, row = (i - 1) % perRow, math.floor((i - 1) / perRow)
    t:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 12 + col * (w + gap), 6 - row * 32)
    if key == selected then
      t:SetBackdropColor(0.25, 0.18, 0.02, 1); t:SetBackdropBorderColor(1, 0.82, 0, 1)
      t.text:SetTextColor(1, 0.82, 0)
      t:SetHeight(34)
    else
      t:SetBackdropColor(0.06, 0.06, 0.08, 0.95); t:SetBackdropBorderColor(0.45, 0.45, 0.45, 0.9)
      local gg = ns.guides[key]
      local sk = gg and ns.Skill(gg.skills[1]) or { known = true }
      if sk.known or (gg and #gg.skills > 1) then t.text:SetTextColor(0.9, 0.9, 0.9) else t.text:SetTextColor(0.55, 0.55, 0.55) end
      t:SetHeight(30)
    end
  end
end

function ns.ToggleShop(force)
  if force ~= nil then shop:SetShown(force) else shop:SetShown(not shop:IsShown()) end
  updateShop()
end

---------------------------------------------------------------------------
-- Welcome (no professions learned)
---------------------------------------------------------------------------
local function updateWelcome()
  local lines = {
    C.gold .. "Welcome!" .. C.r,
    "",
    "You haven't learned any of the professions this guide covers yet.",
    "Visit a trainer and the guide picks up from there. A tab appears for each profession you learn.",
    "",
    C.gold .. "Where to train:" .. C.r,
  }
  for _, key in ipairs(ns.guideOrder) do
    local g = ns.guides[key]
    if g.capitalTrainer then
      table.insert(lines, "   |T" .. g.icon .. ":16|t  " .. C.white .. g.name .. C.r .. ":  " .. ns.FText(g.capitalTrainer))
    end
  end
  table.insert(lines, "")
  table.insert(lines, "• Starting-zone towns have trainers too. A city guard can mark any trainer on your map.")
  table.insert(lines, "• Starting on Zephras Isle? The quest Harvesting Windstones in Thendal Village can teach Mining, Herbalism or Skinning.")
  table.insert(lines, "• Cooking, Fishing and First Aid don't use your two profession slots, so any character can learn them.")
  table.insert(lines, "• Not sure where to start? Fishing and Cooking together is an easy first pick.")
  welcome.text:SetWidth(welcome:GetWidth() - 30)
  welcome.text:SetText(table.concat(lines, "\n"))
end

---------------------------------------------------------------------------
-- Update
---------------------------------------------------------------------------
function ns.UpdateMain()
  if not (f and f:IsShown()) then return end
  local visible = tabKeys()
  local empty = (#visible == 0)
  if not empty then
    local ok = false
    for _, k in ipairs(visible) do if k == selected then ok = true end end
    if not ok then selected = visible[1]; ns.char.activeGuide = selected end
  end
  welcome:SetShown(empty)
  for _, w in ipairs({ bars[1], bars[2], treePanel, detail, f.source }) do w:SetShown(not empty) end
  if empty then shop:Hide() end
  ns.LayoutTabs()
  if empty then updateWelcome(); return end
  local checked = ns.guides[selected] and ns.guides[selected].checked or ns.Camp.checked
  f.source:SetText("Updated " .. (checked or "?") .. "  •  /fpg for commands")
  updateBars()
  updateTree()
  updateDetail()
  updateShop()
end

---------------------------------------------------------------------------
-- Build
---------------------------------------------------------------------------
local function button(parent, text, w)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(w, 24); b:SetText(text)
  return b
end

local function build()
  f = CreateFrame("Frame", "ForeverProfGuideFrame", UIParent, "BackdropTemplate")
  f:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark", edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
                  tile = true, tileSize = 32, edgeSize = 24, insets = { left = 6, right = 6, top = 6, bottom = 6 } })
  local sz = ns.db.mainSize2
  f:SetSize(sz and sz[1] or 1000, sz and sz[2] or 680)
  f:SetFrameStrata("HIGH")
  local pos = ns.db.mainPos
  if pos then f:SetPoint(pos[1], UIParent, pos[2], pos[3], pos[4]) else f:SetPoint("CENTER") end
  f:SetMovable(true); f:SetResizable(true); f:EnableMouse(true); f:SetClampedToScreen(true)
  if f.SetClampRectInsets then f:SetClampRectInsets(0, 0, 0, -70) end
  if f.SetResizeBounds then f:SetResizeBounds(820, 520, 1500, 1200) end
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); savePos(self, "mainPos") end)
  f:SetScript("OnShow", function() ns.RequestRefresh() end)
  f:SetScript("OnSizeChanged", function() if f:IsShown() then ns.UpdateMain() end end)
  f:Hide()
  tinsert(UISpecialFrames, "ForeverProfGuideFrame")

  local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", 0, -14)
  title:SetText("|TInterface\\Icons\\INV_Misc_Fish_02:18|t Forever Profession Guide")

  local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
  close:SetPoint("TOPRIGHT", -4, -4)

  local grip = CreateFrame("Button", nil, f)
  grip:SetSize(16, 16); grip:SetPoint("BOTTOMRIGHT", -6, 6)
  grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  grip:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
  grip:SetScript("OnMouseUp", function()
    f:StopMovingOrSizing(); savePos(f, "mainPos")
    ns.db.mainSize2 = { math.floor(f:GetWidth()), math.floor(f:GetHeight()) }
  end)

  -- Tabs hang off the bottom edge, one per guide.
  tabs = {}
  local tabList = {}
  for _, key in ipairs(ns.guideOrder) do table.insert(tabList, { key = key, icon = ns.guides[key].icon, name = ns.guides[key].name }) end
  table.insert(tabList, { key = "camp", icon = CAMP_ICON, name = "Camp" })
  for _, entry in ipairs(tabList) do
    local key = entry.key
    local g = entry
    local t = CreateFrame("Button", nil, f, "BackdropTemplate")
    t:SetBackdrop(BACKDROP)
    t:SetHeight(30)
    t:SetFrameLevel(f:GetFrameLevel() + 3)
    t.icon = t:CreateTexture(nil, "ARTWORK")
    t.icon:SetSize(16, 16); t.icon:SetTexture(g.icon)
    t.text = t:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    t.text:SetText(g.name)
    t.text:SetPoint("CENTER", 9, -1)
    t.icon:SetPoint("RIGHT", t.text, "LEFT", -4, 0)
    t:SetScript("OnClick", function() ns.selectedStep = nil; ns.detailInfo = nil; ns.ShowMain(key) end)
    t:SetScript("OnEnter", function(self) if key ~= selected then self:SetBackdropBorderColor(1, 0.82, 0, 0.9) end end)
    t:SetScript("OnLeave", function() ns.LayoutTabs() end)
    tabs[key] = t
  end

  bars = { makeBar(f), makeBar(f) }
  bars[1]:SetPoint("TOPLEFT", 42, -44); bars[1]:SetPoint("TOPRIGHT", -18, -44)
  bars[2]:SetPoint("TOPLEFT", bars[1], "BOTTOMLEFT", 0, -6); bars[2]:SetPoint("TOPRIGHT", bars[1], "BOTTOMRIGHT", 0, -6)

  -- Left: the tree
  treePanel = CreateFrame("Frame", nil, f, "BackdropTemplate")
  treePanel:SetBackdrop(BACKDROP)
  treePanel:SetBackdropColor(0.06, 0.06, 0.08, 0.9); treePanel:SetBackdropBorderColor(0.3, 0.3, 0.34, 1)
  treeScroll = CreateFrame("ScrollFrame", nil, treePanel, "UIPanelScrollFrameTemplate")
  treeScroll:SetPoint("TOPLEFT", 6, -6)
  treeScroll:SetPoint("BOTTOMRIGHT", -28, 6)
  treeContent = CreateFrame("Frame", nil, treeScroll)
  treeContent:SetSize(10, 10)
  treeScroll:SetScrollChild(treeContent)
  ns.InitTree(treeContent)
  listContent = CreateFrame("Frame", nil, treeScroll)
  listContent:SetSize(10, 10)
  listContent:Hide()

  viewBar = CreateFrame("Frame", nil, treePanel)
  viewBar:SetPoint("TOPLEFT", 8, -6); viewBar:SetPoint("TOPRIGHT", -8, -6); viewBar:SetHeight(26)
  viewBar.route = button(viewBar, "Route", 120)
  viewBar.route:SetPoint("LEFT", 0, 0)
  viewBar.route:SetScript("OnClick", function() ns.views[selected] = "route"; ns.detailInfo = nil; ns.UpdateMain() end)
  viewBar.recipes = button(viewBar, "Recipes", 150)
  viewBar.recipes:SetPoint("LEFT", viewBar.route, "RIGHT", 6, 0)
  viewBar.recipes:SetScript("OnClick", function() ns.views[selected] = "recipes"; ns.detailInfo = nil; ns.UpdateMain() end)
  tip(viewBar.recipes, "Recipe collection", "Every learnable recipe, which ones you know, and where to get the rest.")

  -- Right: the detail panel
  detail = CreateFrame("Frame", nil, f, "BackdropTemplate")
  detail:SetBackdrop(BACKDROP)
  detail:SetBackdropColor(0.07, 0.07, 0.09, 0.95); detail:SetBackdropBorderColor(0.55, 0.46, 0.2, 1)
  detail:SetPoint("TOPLEFT", treePanel, "TOPRIGHT", 10, 0)
  detail:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 44)
  local d = detail
  d.scroll = CreateFrame("ScrollFrame", nil, d, "UIPanelScrollFrameTemplate")
  d.scroll:SetPoint("TOPLEFT", 12, -12)
  d.scroll:SetPoint("BOTTOMRIGHT", -30, 44)
  d.inner = CreateFrame("Frame", nil, d.scroll)
  d.inner:SetSize(10, 10)
  d.scroll:SetScrollChild(d.inner)
  local function fs(font, anchor, gap)
    local t = d.inner:CreateFontString(nil, "OVERLAY", font)
    if anchor then t:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -gap) else t:SetPoint("TOPLEFT", 0, 0) end
    t:SetJustifyH("LEFT")
    return t
  end
  d.label = fs("GameFontNormalSmall")
  d.title = fs("GameFontNormalHuge", d.label, 6)
  d.now = fs("GameFontHighlight", d.title, 6)
  d.alerts = fs("GameFontHighlight", d.now, 10); d.alerts:SetSpacing(3)
  d.body = fs("GameFontHighlight", d.alerts, 10); d.body:SetSpacing(4)
  d.catchTitle = fs("GameFontNormal", d.body, 20)
  d.catch = fs("GameFontHighlight", d.catchTitle, 6); d.catch:SetSpacing(4)
  d.catchBg = d.inner:CreateTexture(nil, "BACKGROUND")
  d.catchBg:SetColorTexture(0.06, 0.13, 0.17, 0.9)
  d.catchBg:SetPoint("TOPLEFT", d.catchTitle, "TOPLEFT", -6, 6)
  d.catchBg:SetPoint("BOTTOMRIGHT", d.catch, "BOTTOMRIGHT", 6, -8)

  d.mapBtn = button(d, "Show on map", 110)
  d.mapBtn:SetScript("OnClick", function(self) if self.step then ns.ShowStepOnMap(self.step) end end)
  tip(d.mapBtn, "Show on map", "Opens the world map with this step's spots, trainers and vendors. Click a pin to set a waypoint.")
  d.shopBtn = button(d, "Shopping list", 110)
  d.shopBtn:SetScript("OnClick", function() ns.ToggleShop() end)
  d.backBtn = button(d, "Back to now", 100)
  d.backBtn:SetScript("OnClick", function() ns.SelectStep(nil) end)
  d.autoBtn = button(d, "Let guide pick", 110)
  d.autoBtn:SetScript("OnClick", function(self) if self.step then ns.ClearChoice(self.step) end end)
  tip(d.autoBtn, "Let the guide pick", "Unlock your choice. The guide uses whichever option you have materials for.")

  -- Footer
  local cbT = checkbox(f, "Tracker", "tracker")
  cbT:SetPoint("BOTTOMLEFT", 14, 12)
  local cbB = checkbox(f, "Count bank", "includeBank")
  cbB:SetPoint("LEFT", cbT.label, "RIGHT", 10, -1)
  local cbP = checkbox(f, "Map pins", "mapPins", function() if ns.RefreshMapPins then ns.RefreshMapPins() end end)
  cbP:SetPoint("LEFT", cbB.label, "RIGHT", 10, -1)
  tip(cbP, "Map pins", "Show your current step's spots, trainers and vendors whenever you open the world map.")
  local cbG = checkbox(f, "Sizzle!", "minigame")
  cbG:SetPoint("LEFT", cbP.label, "RIGHT", 10, -1)
  tip(cbG, "Sizzle! mini-game", "Pops up while you craft (not while fishing). Just for fun.")
  local cbA = checkbox(f, "All tabs", "showAll")
  cbA:SetPoint("LEFT", cbG.label, "RIGHT", 10, -1)
  tip(cbA, "Show all tabs", "Also show guides for professions you haven't learned, to plan ahead.")

  local src = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  src:SetPoint("BOTTOMRIGHT", -30, 18)
  f.source = src

  shop = CreateFrame("Frame", nil, f, "BackdropTemplate")
  shop:SetBackdrop(BACKDROP)
  shop:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
  shop:SetPoint("TOPLEFT", f, "TOPRIGHT", -4, -40)
  shop:SetSize(320, 460)
  shop.text = shop:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  shop.text:SetPoint("TOPLEFT", 10, -10); shop.text:SetJustifyH("LEFT"); shop.text:SetSpacing(3)
  shop:SetScript("OnShow", updateShop)
  shop:Hide()

  welcome = CreateFrame("Frame", nil, f, "BackdropTemplate")
  welcome:SetBackdrop(BACKDROP)
  welcome:SetBackdropColor(0.1, 0.08, 0, 0.9); welcome:SetBackdropBorderColor(1, 0.82, 0, 1)
  welcome:SetPoint("TOPLEFT", 16, -44); welcome:SetPoint("BOTTOMRIGHT", -16, 44)
  welcome.text = welcome:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  welcome.text:SetPoint("TOPLEFT", 15, -15); welcome.text:SetJustifyH("LEFT"); welcome.text:SetSpacing(5)
  welcome:Hide()
end

function ns.ShowMain(key)
  if not f then build() end
  selected = key or selected or ns.char.activeGuide or ns.TrackedGuideKey()
  if selected ~= "camp" and not ns.guides[selected] then selected = ns.guideOrder[1] end
  -- asking for an untrained guide (e.g. /fpg mining) shows it, so turn on all tabs
  if key and key ~= "camp" and not ns.GuideKnown(ns.guides[key]) and not ns.db.showAll then ns.db.showAll = true end
  ns.char.activeGuide = selected
  f:Show()
  ns.UpdateMain()
end

function ns.ToggleMain()
  if f and f:IsShown() then f:Hide() else ns.ShowMain() end
end

ns.OnRefresh(function() ns.UpdateMain() end)
