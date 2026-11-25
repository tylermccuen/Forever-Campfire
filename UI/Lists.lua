-- The Recipes view (a profession's full recipe collection) and the Camp view
-- (campfires and each of your professions' camp items, tier 1 to 3).
local _, ns = ...
local C = ns.C

ns.recipeFilter = "all"   -- all / missing / now

---------------------------------------------------------------------------
-- A small canvas with pools, one per view
---------------------------------------------------------------------------
-- Each view draws on its own layer, so switching views never leaves the
-- other view's rows behind.
local canvases = {}
ns.listCanvases = canvases   -- for the offline test
local function newCanvas(content)
  local cv = { content = content, rows = {}, texts = {}, tiles = {}, lines = {}, buttons = {}, n = {} }
  cv.root = CreateFrame("Frame", nil, content)
  cv.root:SetAllPoints(content)
  cv.lineLayer = CreateFrame("Frame", nil, cv.root)
  cv.lineLayer:SetAllPoints(content)
  cv.lineLayer:SetFrameLevel(content:GetFrameLevel() + 2)
  table.insert(canvases, cv)
  return cv
end

local function reset(cv)
  for _, other in ipairs(canvases) do if other ~= cv then other.root:Hide() end end
  cv.root:Show()
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
  local t = take(cv, "texts", function() local f = cv.root:CreateFontString(nil, "OVERLAY", "GameFontNormal"); f:SetJustifyH("LEFT"); return f end)
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
    local bt = CreateFrame("Button", nil, cv.root, "UIPanelButtonTemplate")
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
    local r = CreateFrame("Button", nil, cv.root, "BackdropTemplate")
    r:SetBackdrop(ns.BACKDROP)
    r:SetFrameLevel(cv.content:GetFrameLevel() + 4)
    r.icon = r:CreateTexture(nil, "ARTWORK"); r.icon:SetSize(16, 16); r.icon:SetPoint("TOPLEFT", 10, -9)
    r.title = r:CreateFontString(nil, "OVERLAY", "GameFontNormal"); r.title:SetPoint("TOPLEFT", r.icon, "TOPRIGHT", 8, 1); r.title:SetJustifyH("LEFT"); r.title:SetWordWrap(false)
    r.right = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); r.right:SetPoint("TOPRIGHT", -10, -10)
    r.sub = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); r.sub:SetPoint("TOPLEFT", r.title, "BOTTOMLEFT", 0, -3); r.sub:SetJustifyH("LEFT"); r.sub:SetWordWrap(false)
    r.src = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); r.src:SetPoint("TOPLEFT", r.sub, "BOTTOMLEFT", 0, -4); r.src:SetJustifyH("LEFT"); r.src:SetWordWrap(false)
    r.src2 = r:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall"); r.src2:SetPoint("TOPLEFT", r.src, "BOTTOMLEFT", 0, -2); r.src2:SetJustifyH("LEFT"); r.src2:SetWordWrap(false)
    r:SetScript("OnClick", function(self)
      local info = self.info or (self.makeInfo and self.makeInfo(self.data))
      if info then ns.ShowInfo(info) end
    end)
    return r
  end)
  b:ClearAllPoints(); b:SetPoint("TOPLEFT", cv.content, "TOPLEFT", x, -y)
  b:SetSize(w, h)
  b.title:SetWidth(w - 90); b.sub:SetWidth(w - 40); b.src:SetWidth(w - 40)
  b.info, b.makeInfo, b.data = nil, nil, nil
  b.title:SetWordWrap(false); b.src:SetText(""); b.src:SetWordWrap(false); b.src2:SetText(""); b.src2:SetWidth(w - 40)
  if b.title.SetMaxLines then b.title:SetMaxLines(1); b.src:SetMaxLines(1) end
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
local ROW_H, ROW_STEP = 40, 44

-- Detail text for one recipe, made when the row is clicked.
local function recipeInfo(d)
  local r, col, known = d.r, d.col, d.known
  local sk = ns.Skill(col.skill)
  local status = (known and (C.green .. "You know this recipe." .. C.r))
    or (known == false and ((sk.rank >= r.skill) and (C.gold .. "You can learn this now." .. C.r) or (C.grey .. "Needs " .. ns.SkillDisplayName(col.skill) .. " " .. r.skill .. " (you have " .. sk.rank .. ")." .. C.r)))
    or (C.grey .. "Open your " .. ns.SkillDisplayName(col.skill) .. " window to check if you know it." .. C.r)
  local body = { C.gold .. "How to get it: " .. C.r .. r.source, C.gold .. "Needs: " .. C.r .. r.reagents }
  if r.effect then table.insert(body, C.gold .. "Effect: " .. C.r .. r.effect) end
  if r.new then table.insert(body, C.yellow .. "New in WoW Forever." .. C.r) end
  if r.tag then table.insert(body, C.orange .. r.tag .. C.r) end
  return { label = string.upper(d.band) .. " RECIPE", title = r.name, now = status .. "  " .. C.grey .. "Skill " .. r.skill .. C.r, body = table.concat(body, "\n") }
end

-- The second line of a recipe row never changes, so it's made once.
local function recipeSub(r)
  if not r.sub then
    local bits = { r.source }
    if r.effect then table.insert(bits, C.blue .. r.effect .. C.r) end
    if r.new then table.insert(bits, C.yellow .. "New in Forever" .. C.r) end
    if r.tag then table.insert(bits, C.orange .. r.tag .. C.r) end
    if r.camp then table.insert(bits, C.orange .. "Camp item" .. C.r) end
    r.sub = table.concat(bits, " · ")
  end
  return r.sub
end

-- What the list looks like (positions and text), rebuilt only when the filter,
-- skill, known recipes or width change. Drawing then only touches what's in view.
local model, modelKey
local function buildModel(W, col)
  local sk = ns.Skill(col.skill)
  local scanned = ns.char.known and ns.char.known[col.skill]
  local have, total = ns.CollectionCounts(col)
  local m = { texts = {}, buttons = {}, rows = {} }
  local function T(x, y, w, str, font) table.insert(m.texts, { x, y, w, str, font }) end
  local y = 10
  if scanned then
    T(12, y, W - 24, C.gold .. "Collected " .. have .. " / " .. total .. C.r .. C.grey .. "  " .. col.title .. C.r, "GameFontNormalLarge")
  else
    T(12, y, W - 24, C.gold .. total .. " " .. col.title .. C.r .. "\n" .. C.grey .. "Open your " .. ns.SkillDisplayName(col.skill) .. " window once so the guide can see which ones you know." .. C.r, "GameFontNormal")
  end
  y = y + (scanned and 30 or 44)
  local fw = math.floor((W - 40) / 3)
  m.buttons = {
    { 12, y, fw, "All", "all" },
    { 12 + fw + 8, y, fw, "Missing", "missing" },
    { 12 + 2 * (fw + 8), y, fw, "Can learn now", "now" },
  }
  y = y + 34
  for rank = 1, 4 do
    local list, got, count = {}, 0, 0
    for _, r in ipairs(col.recipes) do
      if rankOf(r.skill) == rank then
        count = count + 1
        local known = ns.KnowsRecipe(col.skill, r.name)
        if known then got = got + 1 end
        local show = (ns.recipeFilter == "all")
          or (ns.recipeFilter == "missing" and known ~= true)
          or (ns.recipeFilter == "now" and known ~= true and sk.rank >= r.skill)
        if show then table.insert(list, { r = r, known = known }) end
      end
    end
    local info = ns.BAND_INFO[rank]
    T(12, y, W - 24, string.upper(info.name) .. C.grey .. "  " .. info.from .. "-" .. info.to .. (scanned and (" · " .. got .. " / " .. count) or (" · " .. count .. " recipes")) .. C.r)
    y = y + 22
    if #list == 0 then
      T(20, y, W - 40, C.grey .. "Nothing here for this filter." .. C.r, "GameFontHighlightSmall")
      y = y + 22
    end
    for _, e in ipairs(list) do
      e.y, e.col, e.band = y, col, info.name
      e.style = (e.known and GREEN) or ((sk.rank >= e.r.skill) and GOLD or GREY)
      table.insert(m.rows, e)
      y = y + ROW_STEP
    end
    y = y + 10
  end
  T(12, y, W - 24, C.grey .. "Recipe list checked " .. col.checked .. ". Some sources aren't confirmed yet." .. C.r, "GameFontDisableSmall")
  m.height = y + 30
  return m
end

local function setFilter(f) ns.recipeFilter = f; ns.UpdateMain() end
local filterFns = { all = function() setFilter("all") end, missing = function() setFilter("missing") end, now = function() setFilter("now") end }

-- viewTop/viewH: the part of the list on screen (rows outside it aren't drawn).
function ns.LayoutRecipes(content, W, col, viewTop, viewH)
  recipesCv = recipesCv or newCanvas(content)
  local cv = recipesCv
  local key = table.concat({ col.skill, ns.recipeFilter, ns.Skill(col.skill).rank, ns.knownVersion or 0, W }, "|")
  if key ~= modelKey or model.col ~= col then model, modelKey = buildModel(W, col), key; model.col = col end
  local top = viewTop or 0
  local bottom = top + (viewH or 100000)
  local first = math.floor(top / ROW_STEP)
  local drawKey = key .. "|" .. first
  if cv.drawn == drawKey and cv.root:IsShown() then return model.height end
  cv.drawn = drawKey
  reset(cv)
  for _, t in ipairs(model.texts) do text(cv, t[1], t[2], t[3], t[4], t[5]) end
  for _, bt in ipairs(model.buttons) do smallButton(cv, bt[1], bt[2], bt[3], bt[4], ns.recipeFilter == bt[5], filterFns[bt[5]]) end
  local margin = 6 * ROW_STEP
  for _, e in ipairs(model.rows) do
    if e.y + ROW_H >= top - margin and e.y <= bottom + margin then
      local r, style = e.r, e.style
      local b = row(cv, 8, e.y, W - 16, ROW_H)
      paint(b, style.bg, style.edge)
      b.icon:SetTexture(e.known and "Interface\\RaidFrame\\ReadyCheck-Ready" or (e.known == false and "Interface\\RaidFrame\\ReadyCheck-NotReady" or "Interface\\RaidFrame\\ReadyCheck-Waiting"))
      b.title:SetText(r.name)
      b.title:SetTextColor(style.title[1], style.title[2], style.title[3])
      b.right:SetText(r.skill)
      b.sub:SetText(recipeSub(r))
      b.makeInfo, b.data = recipeInfo, e
    end
  end
  return model.height
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

-- Where a tile's plan comes from, as two short lines: "Drop: Cookie" / "The Deadmines".
local function tileSource(learn)
  local s = ns.CampShortSource(learn)
  local who = s:match("^Drop: (.+)$")
  if not who or who == "not known yet" then return s, nil end
  local boss, place, rest = who:match("^(.-) %((.-)%)(.*)$")
  if not boss then return s, nil end
  if rest and rest:find("%S") then place = place .. ", or another" end
  return "Drop: " .. boss, place
end

local TILE_GAP, TILE_H = 12, 100

-- Detail text for a camp tile, made when it's clicked (so bag counts are current).
local function campTileInfo(d)
  local profName, skillKey, it = d[1], d[2], d[3]
  local sk = ns.Skill(skillKey)
  return campInfo(profName, skillKey, it, campState(skillKey, it, sk), sk)
end

local function tierRow(cv, y, W, profName, skillKey, items)
  local sk = ns.Skill(skillKey)
  local gap = TILE_GAP
  local tw = math.floor((W - 16 - 2 * gap) / 3)
  local h = TILE_H
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
    local style = (state == "have") and GREEN or (((state == "ready") or (i == nextIdx and sk.known)) and GOLD or GREY)
    if state == "locked" and i ~= nextIdx then style = GREY end
    paint(b, style.bg, style.edge)
    b.icon:SetTexture(state == "have" and "Interface\\RaidFrame\\ReadyCheck-Ready" or (state == "ready" and "Interface\\RaidFrame\\ReadyCheck-Waiting" or "Interface\\LFGFrame\\UI-LFG-ICON-LOCK"))
    local textW = tw - 20
    b.title:SetText((it.name:gsub(" Kit$", ""))); b.title:SetWidth(tw - 40)
    b.title:SetWordWrap(true)
    if b.title.SetMaxLines then b.title:SetMaxLines(2) end
    b.title:SetTextColor(style.title[1], style.title[2], style.title[3])
    b.right:SetText("")
    b.sub:ClearAllPoints(); b.sub:SetPoint("TOPLEFT", b, "TOPLEFT", 10, -42)
    b.sub:SetText(C.grey .. "Tier " .. it.tier .. " · skill " .. it.skill .. C.r); b.sub:SetWidth(textW)
    b.src:SetWidth(textW); b.src2:SetWidth(textW)
    if state == "have" then
      b.src:SetText(C.green .. "You have this" .. C.r)
    else
      local l1, l2 = tileSource(it.learn)
      b.src:SetText(((state == "ready") and C.gold or C.grey) .. l1 .. C.r)
      b.src:SetWordWrap(true)
      if b.src.SetMaxLines then b.src:SetMaxLines(2) end
      b.src2:SetText(l2 and (C.grey .. l2 .. C.r) or "")
    end
    b.makeInfo, b.data = campTileInfo, { profName, skillKey, it }
  end
  return y + h
end

local function campKey(W)
  local parts = { W, ns.knownVersion or 0, ns.db.showAll and 1 or 0 }
  for _, k in ipairs(ns.Camp.order) do
    local sk = ns.Skill(k)
    parts[#parts + 1] = sk.known and sk.rank or -1
  end
  return table.concat(parts, "|")
end

function ns.LayoutCamp(content, W)
  campCv = campCv or newCanvas(content)
  local cv = campCv
  local key = campKey(W)
  if cv.drawn == key and cv.root:IsShown() then return cv.height end
  cv.drawn = key
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
  cv.height = y + 30
  return cv.height
end

function ns.CampRulesInfo()
  local body = {}
  for _, r in ipairs(ns.Camp.rules) do table.insert(body, "• " .. r) end
  table.insert(body, " ")
  table.insert(body, C.gold .. "Tier 1" .. C.r .. " items: skill 20, from your trainer or the Camping 101 quest.")
  table.insert(body, C.gold .. "Tier 2 and 3" .. C.r .. ": skill 140 and 300, from a Blueprint (mostly dungeon boss drops).")
  return { label = "CAMPING", title = "How camping works", now = C.grey .. "Pick an item on the left to see how to get it." .. C.r, body = table.concat(body, "\n") }
end
