-- The Recipes view (a profession's full recipe collection) and the Camp view
-- (campfires and each of your professions' camp items, tier 1 to 3).
local _, ns = ...
local C = ns.C

ns.recipeFilter = "all"   -- all / missing / now

---------------------------------------------------------------------------
-- A small canvas with pools, one per view
---------------------------------------------------------------------------
local function newCanvas(content)
  local cv = { content = content, rows = {}, texts = {}, tiles = {}, lines = {}, buttons = {}, n = {} }
  cv.lineLayer = CreateFrame("Frame", nil, content)
  cv.lineLayer:SetAllPoints(content)
  cv.lineLayer:SetFrameLevel(content:GetFrameLevel() + 2)
  return cv
end

local function reset(cv)
  for _, pool in pairs({ cv.rows, cv.texts, cv.tiles, cv.lines, cv.buttons }) do for _, o in ipairs(pool) do o:Hide() end end
  cv.n = { rows = 0, texts = 0, tiles = 0, lines = 0, buttons = 0 }
end

local function take(cv, kind, make)
  cv.n[kind] = cv.n[kind] + 1
  local o = cv[kind][cv.n[kind]]
  if not o then o = make(); cv[kind][cv.n[kind]] = o end
  o:Show()
  return o
end

local function text(cv, x, y, w, str, font)
  local t = take(cv, "texts", function() local f = cv.content:CreateFontString(nil, "OVERLAY", "GameFontNormal"); f:SetJustifyH("LEFT"); return f end)
  t:SetFontObject(font or "GameFontNormal")
  t:ClearAllPoints(); t:SetPoint("TOPLEFT", cv.content, "TOPLEFT", x, -y)
  t:SetWidth(w); t:SetText(str)
  return t
end

local function line(cv, x, y, w, h, r, g, b)
  local t = take(cv, "lines", function() return cv.lineLayer:CreateTexture(nil, "ARTWORK") end)
  t:ClearAllPoints(); t:SetPoint("TOPLEFT", cv.content, "TOPLEFT", x, -y)
  t:SetSize(math.max(w, 2), math.max(h, 2)); t:SetColorTexture(r, g, b, 1)
end

local function smallButton(cv, x, y, w, label, active, onClick)
  local b = take(cv, "buttons", function()
    local bt = CreateFrame("Button", nil, cv.content, "UIPanelButtonTemplate")
    bt:SetHeight(22); bt:SetFrameLevel(cv.content:GetFrameLevel() + 5)
    bt:SetScript("OnClick", function(self) if self.fn then self.fn() end end)
    return bt
  end)
  b:ClearAllPoints(); b:SetPoint("TOPLEFT", cv.content, "TOPLEFT", x, -y)
  b:SetWidth(w); b:SetText(active and (C.gold .. label .. C.r) or label); b.fn = onClick
  if active then b:LockHighlight() else b:UnlockHighlight() end
end

local function row(cv, x, y, w, h)
  local b = take(cv, "rows", function()
    local r = CreateFrame("Button", nil, cv.content, "BackdropTemplate")
    r:SetBackdrop(ns.BACKDROP)
    r:SetFrameLevel(cv.content:GetFrameLevel() + 4)
    r.icon = r:CreateTexture(nil, "ARTWORK"); r.icon:SetSize(16, 16); r.icon:SetPoint("TOPLEFT", 10, -9)
    r.title = r:CreateFontString(nil, "OVERLAY", "GameFontNormal"); r.title:SetPoint("TOPLEFT", r.icon, "TOPRIGHT", 8, 1); r.title:SetJustifyH("LEFT"); r.title:SetWordWrap(false)
    r.right = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); r.right:SetPoint("TOPRIGHT", -10, -10)
    r.sub = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); r.sub:SetPoint("TOPLEFT", r.title, "BOTTOMLEFT", 0, -3); r.sub:SetJustifyH("LEFT"); r.sub:SetWordWrap(false)
    r.src = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); r.src:SetPoint("TOPLEFT", r.sub, "BOTTOMLEFT", 0, -3); r.src:SetJustifyH("LEFT"); r.src:SetWordWrap(false)
    r:SetScript("OnClick", function(self) if self.info then ns.ShowInfo(self.info) end end)
    return r
  end)
  b:ClearAllPoints(); b:SetPoint("TOPLEFT", cv.content, "TOPLEFT", x, -y)
  b:SetSize(w, h)
  b.title:SetWidth(w - 90); b.sub:SetWidth(w - 40); b.src:SetWidth(w - 40)
  b.title:SetWordWrap(false); b.src:SetText(""); b.src:SetWordWrap(false)
  return b
end

local function paint(f, bg, edge)
  f:SetBackdropColor(bg[1], bg[2], bg[3], 0.95)
  f:SetBackdropBorderColor(edge[1], edge[2], edge[3], 1)
end

local GREEN = { bg = { 0.06, 0.12, 0.07 }, edge = { 0.25, 0.55, 0.30 }, title = { 0.78, 0.92, 0.80 } }
local GOLD  = { bg = { 0.17, 0.13, 0.03 }, edge = { 0.91, 0.76, 0.35 }, title = { 0.96, 0.85, 0.54 } }
local GREY  = { bg = { 0.09, 0.09, 0.12 }, edge = { 0.30, 0.30, 0.34 }, title = { 0.70, 0.68, 0.62 } }

local function rankOf(skill)
  return (skill < 75 and 1) or (skill < 150 and 2) or (skill < 225 and 3) or 4
end

local function matsLines(mats)
  local out = {}
  for _, m in ipairs(mats) do
    table.insert(out, "   " .. ns.IconText(m[1]) .. " " .. ns.ItemName(m[1]) .. "  " .. ns.Have(m[1], m[2]))
  end
  return out
end

---------------------------------------------------------------------------
-- Recipes view
---------------------------------------------------------------------------
local recipesCv
function ns.LayoutRecipes(content, W, col)
  recipesCv = recipesCv or newCanvas(content)
  local cv = recipesCv
  reset(cv)
  local sk = ns.Skill(col.skill)
  local scanned = ns.char.known and ns.char.known[col.skill]
  local have, total = ns.CollectionCounts(col)
  local y = 10
  if scanned then
    text(cv, 12, y, W - 24, C.gold .. "Collected " .. have .. " / " .. total .. C.r .. C.grey .. "  " .. col.title .. C.r, "GameFontNormalLarge")
  else
    text(cv, 12, y, W - 24, C.gold .. total .. " " .. col.title .. C.r .. "\n" .. C.grey .. "Open your " .. ns.SkillDisplayName(col.skill) .. " window once so the guide can see which ones you know." .. C.r, "GameFontNormal")
  end
  y = y + (scanned and 30 or 44)
  local fw = math.floor((W - 40) / 3)
  smallButton(cv, 12, y, fw, "All", ns.recipeFilter == "all", function() ns.recipeFilter = "all"; ns.UpdateMain() end)
  smallButton(cv, 12 + fw + 8, y, fw, "Missing", ns.recipeFilter == "missing", function() ns.recipeFilter = "missing"; ns.UpdateMain() end)
  smallButton(cv, 12 + 2 * (fw + 8), y, fw, "Can learn now", ns.recipeFilter == "now", function() ns.recipeFilter = "now"; ns.UpdateMain() end)
  y = y + 34

  for rank = 1, 4 do
    local list, got = {}, 0
    for _, r in ipairs(col.recipes) do
      if rankOf(r.skill) == rank then
        local known = ns.KnowsRecipe(col.skill, r.name)
        if known then got = got + 1 end
        local show = (ns.recipeFilter == "all")
          or (ns.recipeFilter == "missing" and known ~= true)
          or (ns.recipeFilter == "now" and known ~= true and sk.rank >= r.skill)
        if show then table.insert(list, { r = r, known = known }) end
      end
    end
    local info = ns.BAND_INFO[rank]
    local count = 0
    for _, r in ipairs(col.recipes) do if rankOf(r.skill) == rank then count = count + 1 end end
    text(cv, 12, y, W - 24, string.upper(info.name) .. C.grey .. "  " .. info.from .. "-" .. info.to .. (scanned and (" · " .. got .. " / " .. count) or (" · " .. count .. " recipes")) .. C.r)
    y = y + 22
    if #list == 0 then
      text(cv, 20, y, W - 40, C.grey .. "Nothing here for this filter." .. C.r, "GameFontHighlightSmall")
      y = y + 22
    end
    for _, e in ipairs(list) do
      local r = e.r
      local b = row(cv, 8, y, W - 16, 40)
      local style = (e.known and GREEN) or ((sk.rank >= r.skill) and GOLD or GREY)
      paint(b, style.bg, style.edge)
      b.icon:SetTexture(e.known and "Interface\\RaidFrame\\ReadyCheck-Ready" or (e.known == false and "Interface\\RaidFrame\\ReadyCheck-NotReady" or "Interface\\RaidFrame\\ReadyCheck-Waiting"))
      b.title:SetText(r.name)
      b.title:SetTextColor(style.title[1], style.title[2], style.title[3])
      b.right:SetText(tostring(r.skill))
      local bits = { r.source }
      if r.effect then table.insert(bits, C.blue .. r.effect .. C.r) end
      if r.new then table.insert(bits, C.yellow .. "New in Forever" .. C.r) end
      if r.tag then table.insert(bits, C.orange .. r.tag .. C.r) end
      if r.camp then table.insert(bits, C.orange .. "Camp item" .. C.r) end
      b.sub:SetText(table.concat(bits, " · "))
      local status = (e.known and (C.green .. "You know this recipe." .. C.r))
        or (e.known == false and ((sk.rank >= r.skill) and (C.gold .. "You can learn this now." .. C.r) or (C.grey .. "Needs " .. ns.SkillDisplayName(col.skill) .. " " .. r.skill .. " (you have " .. sk.rank .. ")." .. C.r)))
        or (C.grey .. "Open your " .. ns.SkillDisplayName(col.skill) .. " window to check if you know it." .. C.r)
      local body = { C.gold .. "How to get it: " .. C.r .. r.source, C.gold .. "Needs: " .. C.r .. r.reagents }
      if r.effect then table.insert(body, C.gold .. "Effect: " .. C.r .. r.effect) end
      if r.new then table.insert(body, C.yellow .. "New in WoW Forever." .. C.r) end
      if r.tag then table.insert(body, C.orange .. r.tag .. C.r) end
      b.info = { label = string.upper(info.name) .. " RECIPE", title = r.name, now = status .. "  " .. C.grey .. "Skill " .. r.skill .. C.r, body = table.concat(body, "\n") }
      y = y + 44
    end
    y = y + 10
  end
  text(cv, 12, y, W - 24, C.grey .. "Recipe list checked " .. col.checked .. ". Some sources aren't confirmed yet." .. C.r, "GameFontDisableSmall")
  return y + 30
end

---------------------------------------------------------------------------
-- Camp view
---------------------------------------------------------------------------
local campCv

local function campState(skillKey, item, sk)
  local known = ns.KnowsRecipe(skillKey, item.name)
  if known then return "have" end
  if skillKey == "cooking" and item.tier == 1 and sk.known then return "have" end   -- comes with Cooking
  if sk.known and sk.rank >= item.skill then return "ready" end
  return "locked"
end

local function campInfo(profName, skillKey, item, state, sk)
  local status = (state == "have" and (C.green .. "You can make this." .. C.r))
    or (state == "ready" and (C.gold .. "Your skill is high enough: get the plan." .. C.r))
    or (C.grey .. "Needs " .. profName .. " " .. item.skill .. (sk.known and (" (you have " .. sk.rank .. ")") or "") .. "." .. C.r)
  local body = { C.gold .. "Where: " .. C.r .. ns.CampShortSource(item.learn), C.grey .. item.learn .. C.r, C.gold .. "Effect: " .. C.r .. item.effect, " ", C.gold .. "Materials:" .. C.r }
  for _, l in ipairs(matsLines(item.mats)) do table.insert(body, l) end
  if item.station then table.insert(body, " "); table.insert(body, C.blue .. "Crafting station. Anyone at the camp can use it, and it sells on the Auction House." .. C.r) end
  if item.tier > 1 then table.insert(body, C.grey .. "Replaces the tier " .. (item.tier - 1) .. " item." .. C.r) end
  return { label = string.upper(profName) .. " · TIER " .. item.tier, title = item.name, now = status, body = table.concat(body, "\n") }
end

-- Where an item comes from, short enough for a tile: "Drop: Cookie (The Deadmines)".
function ns.CampShortSource(learn)
  if learn:find("not known yet") then return "Drop: not known yet" end
  local who = learn:match("^Blueprint from (.+)$") or learn:match(", from (.+)$")
  if who then return "Drop: " .. who end
  if learn:find("Camping 101") then return "Trainer or Camping 101" end
  return learn
end

-- Two short lines for a tile: "Drop: Cookie" / "The Deadmines".
local function tileSource(learn)
  local s = ns.CampShortSource(learn)
  local who = s:match("^Drop: (.+)$")
  if not who or who == "not known yet" then return s end
  local boss, place, rest = who:match("^(.-) %((.-)%)(.*)$")
  if not boss then return s end
  if rest and rest:find("%S") then place = place .. ", or another" end
  return "Drop: " .. boss .. "\n" .. place
end

local function tierRow(cv, y, W, profName, skillKey, items)
  local sk = ns.Skill(skillKey)
  local gap = 22
  local tw = math.floor((W - 16 - 2 * gap) / 3)
  local h = 96
  -- which one is next: the first tier you don't have yet
  local nextIdx
  for i, it in ipairs(items) do if campState(skillKey, it, sk) ~= "have" then nextIdx = i; break end end
  for i, it in ipairs(items) do
    local x = 8 + (i - 1) * (tw + gap)
    if i > 1 then
      local st = campState(skillKey, items[i - 1], sk)
      local c = (st == "have") and GREEN.edge or GREY.edge
      line(cv, x - gap, y + math.floor(h / 2) - 1, gap, 2, c[1], c[2], c[3])
    end
    local state = campState(skillKey, it, sk)
    local b = row(cv, x, y, tw, h)
    local style = (state == "have" and GREEN) or ((state == "ready" or i == nextIdx and sk.known) and GOLD or GREY)
    if state == "locked" and i ~= nextIdx then style = GREY end
    paint(b, style.bg, style.edge)
    b.icon:SetTexture(state == "have" and "Interface\\RaidFrame\\ReadyCheck-Ready" or (state == "ready" and "Interface\\RaidFrame\\ReadyCheck-Waiting" or "Interface\\LFGFrame\\UI-LFG-ICON-LOCK"))
    b.title:SetText(it.name:gsub(" Kit$", "")); b.title:SetWidth(tw - 38)
    b.title:SetWordWrap(true)
    if b.title.SetMaxLines then b.title:SetMaxLines(2) end
    b.title:SetTextColor(style.title[1], style.title[2], style.title[3])
    b.right:SetText("")
    b.sub:SetText("T" .. it.tier .. " · skill " .. it.skill .. ((state == "have") and " · have" or ((state == "ready") and " · get it" or "")))
    b.sub:SetWidth(tw - 20)
    b.src:SetText((state == "have") and "" or (C.grey .. tileSource(it.learn) .. C.r))
    b.src:SetWidth(tw - 20)
    b.src:SetWordWrap(true)
    if b.src.SetMaxLines then b.src:SetMaxLines(2) end
    b.info = campInfo(profName, skillKey, it, state, sk)
  end
  return y + h
end

function ns.LayoutCamp(content, W)
  campCv = campCv or newCanvas(content)
  local cv = campCv
  reset(cv)
  local y = 10
  local cook = ns.Skill("cooking")
  local fire = ns.Camp.fires[1]
  for _, f in ipairs(ns.Camp.fires) do
    if ns.KnowsRecipe("cooking", f.name) or (cook.known and cook.rank >= f.skill and f.tier == 1) then fire = f end
  end
  local nextFire
  for _, f in ipairs(ns.Camp.fires) do if f.tier == fire.tier + 1 then nextFire = f end end
  local head = cook.known
    and (C.gold .. "Your campfire: " .. fire.name:gsub(" Kit", "") .. C.r .. C.grey .. (nextFire and ("  ·  next: " .. nextFire.name:gsub(" Kit", "") .. " at Cooking " .. nextFire.skill) or "  ·  best campfire") .. C.r)
    or (C.gold .. "Campfires come from Cooking." .. C.r .. C.grey .. "  Learn it, or camp with a friend who has it." .. C.r)
  text(cv, 12, y, W - 24, head, "GameFontNormal")
  y = y + 26
  text(cv, 12, y, W - 24, "CAMPFIRE" .. C.grey .. "  Cooking " .. (cook.known and cook.rank or "not learned") .. C.r)
  y = y + 22
  y = tierRow(cv, y, W, "Cooking", "cooking", ns.Camp.fires) + 18

  local shown = 0
  for _, key in ipairs(ns.Camp.order) do
    local sk = ns.Skill(key)
    if (sk.known or ns.db.showAll) and ns.Camp.items[key] then
      shown = shown + 1
      local g = ns.guides[key]
      local name = ns.SkillDisplayName(key)
      text(cv, 12, y, W - 24, (g and ("|T" .. g.icon .. ":16|t ") or "") .. string.upper(name) .. C.grey .. "  " .. (sk.known and (sk.rank .. " / " .. sk.max) or "not learned") .. C.r)
      y = y + 22
      y = tierRow(cv, y, W, name, key, ns.Camp.items[key]) + 18
    end
  end
  if shown == 0 then
    text(cv, 12, y, W - 24, C.grey .. "Learn a profession to see its camp items here. Tick All tabs to preview them all." .. C.r)
    y = y + 30
  end
  text(cv, 12, y, W - 24, C.grey .. "Click an item for materials and where its plan drops. Camp data checked " .. ns.Camp.checked .. "." .. C.r, "GameFontDisableSmall")
  return y + 30
end

function ns.CampRulesInfo()
  local body = {}
  for _, r in ipairs(ns.Camp.rules) do table.insert(body, "• " .. r) end
  table.insert(body, " ")
  table.insert(body, C.gold .. "Tier 1" .. C.r .. " items: skill 20, from your trainer or the Camping 101 quest.")
  table.insert(body, C.gold .. "Tier 2 and 3" .. C.r .. ": skill 140 and 300, from a Blueprint (mostly dungeon boss drops).")
  return { label = "CAMPING", title = "How camping works", now = C.grey .. "Pick an item on the left to see how to get it." .. C.r, body = table.concat(body, "\n") }
end
