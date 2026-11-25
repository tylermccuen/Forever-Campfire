-- Forever Campfire: skill detection, step progress, alerts, events.
local ADDON, ns = ...
local C = ns.C

ns.skills = {}  -- key -> { known, rank, max }

---------------------------------------------------------------------------
-- Skill detection
---------------------------------------------------------------------------
local displayNames = {}
function ns.SkillDisplayName(key)
  if displayNames[key] then return displayNames[key] end
  local info = ns.SKILLS[key]
  local n
  if C_TradeSkillUI and C_TradeSkillUI.GetTradeSkillDisplayName then
    local ok, res = pcall(C_TradeSkillUI.GetTradeSkillDisplayName, info.line)
    if ok and type(res) == "string" and res ~= "" then n = res end
  end
  displayNames[key] = n or info.name
  return displayNames[key]
end

function ns.ScanSkills()
  local found = {}
  local function put(line, name, rank, max)
    for key, info in pairs(ns.SKILLS) do
      if (line and line == info.line) or (name and (name == info.name or name == ns.SkillDisplayName(key))) then
        found[key] = { known = true, rank = rank or 0, max = max or 0 }
      end
    end
  end
  if GetProfessions and GetProfessionInfo then
    local list = { GetProfessions() }
    for i = 1, 6 do
      local idx = list[i]
      if idx then
        local name, _, rank, max, _, _, line = GetProfessionInfo(idx)
        put(line, name, rank, max)
      end
    end
  end
  if GetNumSkillLines and GetSkillLineInfo then
    for i = 1, GetNumSkillLines() do
      local name, header, _, rank, _, _, max = GetSkillLineInfo(i)
      if name and not header then put(nil, name, rank, max) end
    end
  end
  -- Last resort: ask by skill line (modern API), for anything still missing.
  if C_TradeSkillUI and C_TradeSkillUI.GetProfessionInfoBySkillLineID then
    for key, info in pairs(ns.SKILLS) do
      if not found[key] then
        local ok, p = pcall(C_TradeSkillUI.GetProfessionInfoBySkillLineID, info.line)
        if ok and type(p) == "table" and (p.maxSkillLevel or 0) > 0 then
          found[key] = { known = true, rank = p.skillLevel or 0, max = p.maxSkillLevel }
        end
      end
    end
  end
  return found
end

function ns.Skill(key)
  return ns.skills[key] or { known = false, rank = 0, max = 0 }
end

function ns.RankName(max)
  return ns.RANK_NAMES[max] or ""
end

---------------------------------------------------------------------------
-- Steps
---------------------------------------------------------------------------
local function questDone(id)
  if not id then return false end
  if C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted then return C_QuestLog.IsQuestFlaggedCompleted(id) and true or false end
  if IsQuestFlaggedCompleted then return IsQuestFlaggedCompleted(id) and true or false end
  return false
end

function ns.IsStepDone(step)
  local sk = ns.Skill(step.skill)
  if step.kind == "learn" then return sk.known end
  if not sk.known then return false end
  if step.kind == "train" then return sk.max >= step.max end
  if step.kind == "quest" then
    local q = step.quest
    if type(q) == "table" then q = (ns.Faction() == "Horde") and q.H or q.A end
    return questDone(q) or sk.max >= (step.max or 300)
  end
  if sk.rank >= step.to then return true end
  if step.soft and sk.rank >= (step.from or 0) and sk.rank > 1 then
    for _, id in ipairs(step.soft) do
      if ns.Count(id) > 0 then return false end
    end
    return true
  end
  return false
end

-- Drop options / buy / gather entries meant for the other faction (field f = "Horde"/"Alliance").
function ns.ApplyFaction(g)
  local fac = ns.Faction()
  local function keep(list)
    if not list then return nil end
    local out = {}
    for _, e in ipairs(list) do if not e.f or e.f == fac then table.insert(out, e) end end
    return out
  end
  for _, step in ipairs(g.steps) do
    step.options = keep(step.options)
    step.buy = keep(step.buy)
    step.gather = keep(step.gather)
    if step.options and #step.options == 0 then step.options = nil end
  end
end

-- Reasons the player can't do the step yet (level / skill).
function ns.StepBlockers(step)
  local out = {}
  local r = step.requires
  if not r then return out end
  local lvl = UnitLevel and UnitLevel("player") or 60
  if r.level and lvl < r.level then
    table.insert(out, "Needs character level " .. r.level .. " (you are " .. lvl .. ")")
  end
  if r.skill then
    local sk = ns.Skill(step.skill)
    if sk.rank < r.skill then
      table.insert(out, "Needs " .. ns.SkillDisplayName(step.skill) .. " " .. r.skill .. " (you have " .. sk.rank .. ")")
    end
  end
  return out
end

local function waitingForSkill(step)
  if step.kind ~= "train" and step.kind ~= "quest" then return false end
  local r = step.requires
  local sk = ns.Skill(step.skill)
  return r and r.skill and sk.known and sk.rank < r.skill and sk.rank < sk.max
end

function ns.CurrentStep(guide)
  local waiting
  for _, step in ipairs(guide.steps) do
    if not ns.IsStepDone(step) then
      if not waitingForSkill(step) then return step end
      waiting = waiting or step
    end
  end
  return waiting
end

function ns.StepState(step)
  if ns.IsStepDone(step) then return "done" end
  if ns.CurrentStep(step.guide) == step then return "current" end
  return "todo"
end

---------------------------------------------------------------------------
-- Rank bands for the skill tree: Apprentice / Journeyman / Expert / Artisan.
-- A step's band never goes backwards along the route, so combined guides
-- (Fish + Cook) group by how far along the route you are.
---------------------------------------------------------------------------
ns.BAND_INFO = {
  { name = "Apprentice", from = 1, to = 75 },
  { name = "Journeyman", from = 75, to = 150 },
  { name = "Expert", from = 150, to = 225 },
  { name = "Artisan", from = 225, to = 300 },
}

local function stepRank(step)
  if step.kind == "learn" then return 1 end
  if step.kind == "train" or step.kind == "quest" then
    local m = step.max or 300
    return (m <= 75 and 1) or (m <= 150 and 2) or (m <= 225 and 3) or 4
  end
  local f = step.from or 1
  return (f < 75 and 1) or (f < 150 and 2) or (f < 225 and 3) or 4
end

function ns.Bands(guide)
  local bands, cur = {}, 0
  local current = ns.CurrentStep(guide)
  for _, step in ipairs(guide.steps) do
    local r = math.max(cur, stepRank(step))
    cur = r
    local b = bands[#bands]
    if not b or b.rank ~= r then
      b = { rank = r, info = ns.BAND_INFO[r], steps = {}, done = true }
      table.insert(bands, b)
    end
    table.insert(b.steps, step)
    if not ns.IsStepDone(step) then b.done = false end
    if step == current then b.current = true end
  end
  return bands
end

-- Options after the faction filter, as shown in the tree.
function ns.Options(step) return step.options or {} end

-- Option choice: pinned by the player, otherwise the one whose materials you have most of.
local function choiceKey(step) return step.guide.key .. "/" .. step.id end

function ns.SetChoice(step, idx)
  ns.char.choice[choiceKey(step)] = idx
  ns.RequestRefresh()
end

function ns.ClearChoice(step)
  ns.char.choice[choiceKey(step)] = nil
  ns.RequestRefresh()
end

function ns.IsPinned(step)
  return ns.char.choice[choiceKey(step)] ~= nil
end

function ns.ChosenOption(step)
  local opts = step.options
  if not opts then return nil, nil end
  local pinned = ns.char.choice[choiceKey(step)]
  if pinned and opts[pinned] then return opts[pinned], pinned end
  local best, bestIdx, bestScore = opts[1], 1, -1
  for i, opt in ipairs(opts) do
    local score
    local reqs = {}
    for _, m in ipairs(opt.mats or {}) do table.insert(reqs, { m[1], (opt.count or 1) * m[2] }) end
    for _, b in ipairs(opt.buy or {}) do table.insert(reqs, { b.id, b.count }) end
    if #reqs == 0 then
      score = 0.5
    else
      score = 0
      for _, r in ipairs(reqs) do score = score + math.min(ns.Count(r[1]) / r[2], 1) end
      score = score / #reqs
      if score == 0 then score = -0.5 end
    end
    if score > bestScore then best, bestIdx, bestScore = opt, i, score end
  end
  return best, bestIdx
end

-- How many crafts are left for an option, given current skill.
function ns.CraftsLeft(step, opt)
  if step.kind ~= "level" then return 0 end
  local rank = ns.Skill(step.skill).rank
  if rank >= step.to then return 0 end
  local span = step.to - step.from
  local left = step.to - math.max(rank, step.from)
  if opt and opt.count then
    if rank <= step.from then return opt.count end
    return math.ceil(opt.count * left / span)
  end
  return left
end

-- Materials still needed for a step's chosen option: list of { id, need }.
function ns.OptionNeeds(step, opt)
  local out = {}
  if not (opt and opt.mats) then return out end
  local crafts = ns.CraftsLeft(step, opt)
  for _, m in ipairs(opt.mats) do
    table.insert(out, { id = m[1], need = crafts * m[2] })
  end
  return out
end

-- Shopping list for everything from the current step to the end.
function ns.ShoppingList(guide)
  local need, order = {}, {}
  local function add(id, n)
    if n <= 0 then return end
    if not need[id] then need[id] = 0; table.insert(order, id) end
    need[id] = need[id] + n
  end
  for _, step in ipairs(guide.steps) do
    if not ns.IsStepDone(step) then
      local opt = ns.ChosenOption(step)
      if opt and opt.count then
        for _, n in ipairs(ns.OptionNeeds(step, opt)) do add(n.id, n.need) end
      end
      if step.gather then for _, g in ipairs(step.gather) do add(g.id, g.count) end end
      if step.buy then for _, b in ipairs(step.buy) do add(b.id, b.count) end end
      if opt and opt.buy then for _, b in ipairs(opt.buy) do add(b.id, b.count) end end
    end
  end
  local list = {}
  for _, id in ipairs(order) do
    local have = ns.Count(id)
    table.insert(list, { id = id, need = need[id], have = have, vendor = ns.IsVendorItem(id) })
  end
  return list
end

---------------------------------------------------------------------------
-- Alerts: the "you should do this now" warnings
---------------------------------------------------------------------------
local function poleEquipped()
  local id = GetInventoryItemID and GetInventoryItemID("player", 16)
  if not id then return false end
  local classID, subID
  if C_Item and C_Item.GetItemInfoInstant then
    local _, _, _, _, _, c, s = C_Item.GetItemInfoInstant(id); classID, subID = c, s
  elseif GetItemInfoInstant then
    local _, _, _, _, _, c, s = GetItemInfoInstant(id); classID, subID = c, s
  end
  return classID == 2 and subID == 20
end

-- true / false, or nil if the game doesn't tell us.
function ns.TrackingActive(name)
  if not (C_Minimap and C_Minimap.GetNumTrackingTypes and C_Minimap.GetTrackingInfo) then return nil end
  local ok, n = pcall(C_Minimap.GetNumTrackingTypes)
  if not ok or not n then return nil end
  for i = 1, n do
    local ok2, a, _, c = pcall(C_Minimap.GetTrackingInfo, i)
    if ok2 then
      local tName, active
      if type(a) == "table" then tName, active = a.name, a.active else tName, active = a, c end
      if tName == name then return active and true or false end
    end
  end
  return nil
end

function ns.NightfinHours()
  if not GetGameTime then return false end
  local h, m = GetGameTime()
  return h >= 12 and h < 18, string.format("%02d:%02d", h, m)
end

-- Returns list of { kind = "warn"|"info", text = "..." }
function ns.Alerts(guide)
  local out = {}
  local function add(kind, text) table.insert(out, { kind = kind, text = text }) end
  local step = ns.CurrentStep(guide)
  local lvl = UnitLevel and UnitLevel("player") or 60

  for _, key in ipairs(guide.skills) do
    local sk = ns.Skill(key)
    local name = ns.SkillDisplayName(key)
    local ru = guide.rankUps and guide.rankUps[sk.max]
    -- combined guide: use the single-profession guide's rank-up data
    if not ru and ns.guides[key] and ns.guides[key].rankUps then ru = ns.guides[key].rankUps[sk.max] end
    if sk.known and ru then
      if sk.rank >= sk.max then
        local how = ns.FText(ru.how) or ""
        if ru.level and lvl < ru.level then
          add("warn", name .. " is capped at " .. sk.max .. ". " .. ru.name .. " needs level " .. ru.level .. ".")
        else
          add("warn", name .. " is capped at " .. sk.max .. "! " .. how .. ".")
        end
      elseif ru.book and sk.rank >= ru.skill and ns.Count(ru.book) > 0 then
        add("warn", "Read " .. ns.ItemName(ru.book) .. " in your bags now.")
      elseif sk.rank >= sk.max - 5 then
        add("info", name .. " is close to its cap (" .. sk.rank .. "/" .. sk.max .. "). Next: " .. ru.name .. ".")
      end
    end
  end

  local gsk = ns.Skill(guide.skills[1])
  if guide.tool and gsk.known and ns.Count(guide.tool) == 0 then
    add("warn", "No " .. ns.IconText(guide.tool) .. " " .. ns.ItemName(guide.tool) .. " in your bags. You can't gather without it.")
  end
  if guide.tracking and gsk.known and ns.TrackingActive(guide.tracking) == false then
    add("info", "Turn on " .. guide.tracking .. " (Professions window) to see nodes on the minimap.")
  end

  if step then
    for _, b in ipairs(ns.StepBlockers(step)) do add("warn", b) end

    if step.skill == "fishing" and ns.Skill("fishing").known and step.kind == "level" then
      if not poleEquipped() then
        add("info", "Equip your fishing pole.")
      elseif GetWeaponEnchantInfo and not GetWeaponEnchantInfo() and step.lure then
        add("warn", "No lure on your pole. Use " .. ns.IconText(step.lure) .. " " .. ns.ItemName(step.lure)
          .. " (" .. ns.Count(step.lure) .. " in bags).")
      end
    end

    if step.nightfin then
      local bad, t = ns.NightfinHours()
      if bad then add("info", "Raw Nightfin Snapper don't bite from 12:00 to 18:00 (server time is " .. t .. ").") end
    end

    if step.secondary then
      for key, target in pairs(step.secondary) do
        local sk = ns.Skill(key)
        if sk.known and sk.rank < target then
          add("info", ns.SkillDisplayName(key) .. " is behind the route: " .. sk.rank .. ", aim for " .. target .. " here.")
        end
      end
    end
  end
  return out
end

-- One-line "do this now" summary for the tracker and the header.
function ns.NowText(guide)
  local step = ns.CurrentStep(guide)
  if not step then return C.green .. "All done: " .. guide.name .. " is maxed!" .. C.r end
  local sk = ns.Skill(step.skill)
  local skillName = ns.SkillDisplayName(step.skill)
  if step.kind == "learn" then return "Learn " .. skillName .. " at a trainer. Names are in the step below." end
  if step.kind == "train" then return step.title .. "." end
  if step.kind == "quest" then
    local missing = 0
    for _, g in ipairs(step.gather or {}) do if ns.Count(g.id) < g.count then missing = missing + 1 end end
    if missing > 0 then return "Collect the items below for the quest (" .. missing .. " still missing)." end
    return "You have everything. Go hand in the quest!"
  end
  local opt = ns.ChosenOption(step)
  local toGo = step.to - math.max(sk.rank, step.from)
  if opt and opt.now then return opt.now end
  if opt and opt.product then
    local crafts = ns.CraftsLeft(step, opt)
    local txt
    if opt.count == 1 then txt = (opt.verb or step.guide.verb or "Cook") .. " one " .. opt.recipe
    else txt = (opt.verb or step.guide.verb or "Cook") .. " " .. (opt.count and ("about " .. crafts .. " more ") or "") .. opt.recipe end
    local short
    for _, n in ipairs(ns.OptionNeeds(step, opt)) do
      local have = ns.Count(n.id)
      if opt.count and have < n.need then short = (short and short .. ", " or "") .. (n.need - have) .. " " .. ns.ItemName(n.id) end
      if not opt.count then txt = txt .. " (" .. have .. " " .. ns.ItemName(n.id) .. ")" end
    end
    if opt.count ~= 1 then txt = txt .. " until " .. step.to end
    txt = txt .. "."
    if short then txt = txt .. " " .. C.red .. "Missing: " .. short .. C.r end
    return txt
  end
  return (step.guide.gatherVerb or "Fish") .. " until " .. skillName .. " " .. step.to .. " (" .. toGo .. " to go)."
end

---------------------------------------------------------------------------
-- Refresh pipeline
---------------------------------------------------------------------------
ns.lastCurrent = {}
local initialized = false

function ns.OnRefresh(fn) table.insert(ns.listeners, fn) end

function ns.Refresh()
  ns.pending = false
  ns.ScanBags()
  local new = ns.ScanSkills()
  for key, s in pairs(new) do
    local old = ns.skills[key]
    if initialized and old and old.rank and s.rank > old.rank then
      ns.char.lastActive = key
      if ns.OnSkillUp then ns.OnSkillUp(key, old.rank, s.rank, s.max) end
    end
  end
  ns.skills = new

  for _, key in ipairs(ns.guideOrder) do
    local g = ns.guides[key]
    -- only guides for professions you have (or are previewing) are worked out
    local cur = (ns.GuideKnown(g) or (ns.db.showAll and ns.IsGuideBuilt(key))) and ns.CurrentStep(g) or nil
    local prev = ns.lastCurrent[key]
    if initialized and prev ~= cur and prev and ns.IsStepDone(prev) and ns.db.announce then
      local relevant = (key == ns.TrackedGuideKey())
      if relevant then
        local function nm(s) return (#g.skills > 1 and (ns.SkillDisplayName(s.skill) .. ": ") or "") .. s.title end
        ns.Print(C.green .. "Done: " .. nm(prev) .. C.r .. (cur and (". Next: " .. C.gold .. nm(cur) .. C.r) or ""))
        if PlaySound and SOUNDKIT and SOUNDKIT.UI_QUEST_ROLLING_FORWARD_01 then pcall(PlaySound, SOUNDKIT.UI_QUEST_ROLLING_FORWARD_01) end
      end
    end
    ns.lastCurrent[key] = cur
  end
  initialized = true
  for _, fn in ipairs(ns.listeners) do fn() end
end

function ns.RequestRefresh()
  if ns.pending then return end
  ns.pending = true
  if C_Timer and C_Timer.After then C_Timer.After(0.2, ns.Refresh) else ns.Refresh() end
end

-- A guide counts as "trained" when the character knows any of its professions.
function ns.GuideKnown(g)
  for _, key in ipairs(g.skills) do
    if ns.Skill(key).known then return true end
  end
  return false
end

-- A combined guide (more than one skill) replaces its single guides once the
-- character knows all of its skills; until then only the single guides show.
local function combinedFor(key)
  for _, k in ipairs(ns.guideOrder) do
    local g = ns.guides[k]
    if #g.skills > 1 then
      for _, s in ipairs(g.skills) do if s == key then return g end end
    end
  end
end

local function knowsAll(g)
  for _, s in ipairs(g.skills) do if not ns.Skill(s).known then return false end end
  return true
end

function ns.GuideActive(key)
  local g = ns.guides[key]
  if #g.skills > 1 then return knowsAll(g) end
  if not ns.Skill(key).known then return false end
  local combo = combinedFor(key)
  return not (combo and knowsAll(combo))
end

function ns.VisibleGuides()
  local out = {}
  for _, key in ipairs(ns.guideOrder) do
    if ns.db.showAll or ns.GuideActive(key) then table.insert(out, key) end
  end
  return out
end

-- Which guide the tracker shows.
function ns.TrackedGuideKey()
  local pick = ns.char and ns.char.trackerGuide or "auto"
  if pick ~= "auto" and ns.guides[pick] then return pick end
  local last = ns.char and ns.char.lastActive
  if last and ns.guides[last] then
    if ns.GuideActive(last) then return last end
    local combo = combinedFor(last)
    if combo and ns.GuideActive(combo.key) then return combo.key end
  end
  -- otherwise: the known profession with a guide that is furthest from 300
  local best, bestRank
  for _, key in ipairs(ns.guideOrder) do
    local g = ns.guides[key]
    if ns.GuideActive(key) then
      local rank = 300
      for _, s in ipairs(g.skills) do rank = math.min(rank, ns.Skill(s).rank) end
      if rank < 300 and (not bestRank or rank < bestRank) then best, bestRank = key, rank end
    end
  end
  if best then return best end
  for _, key in ipairs(ns.guideOrder) do
    if ns.GuideKnown(ns.guides[key]) then return key end
  end
  return nil
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local ev = CreateFrame("Frame")
ns.eventFrame = ev
local EVENTS = {
  "PLAYER_ENTERING_WORLD", "SKILL_LINES_CHANGED", "CHAT_MSG_SKILL", "TRADE_SKILL_LIST_UPDATE",
  "BAG_UPDATE_DELAYED", "PLAYER_LEVEL_UP", "QUEST_TURNED_IN", "UNIT_INVENTORY_CHANGED",
  "PLAYER_EQUIPMENT_CHANGED", "MERCHANT_SHOW", "LEARNED_SPELL_IN_SKILL_LINE", "LEARNED_SPELL_IN_TAB",
}
ev:RegisterEvent("ADDON_LOADED")
ev:SetScript("OnEvent", function(self, event, arg1)
  if event == "ADDON_LOADED" then
    if arg1 ~= ADDON then return end
    self:UnregisterEvent("ADDON_LOADED")
    ns.InitDB()
    ns.factionReady = true
    for _, key in ipairs(ns.guideOrder) do
      if ns.IsGuideBuilt(key) then ns.ApplyFaction(ns.guides[key]) end
    end
    for _, e in ipairs(EVENTS) do pcall(self.RegisterEvent, self, e) end
    if ns.InitUI then ns.InitUI() end
    if C_Timer and C_Timer.NewTicker then C_Timer.NewTicker(20, ns.RequestRefresh) end -- lure expiry, game clock
    return
  end
  if event == "UNIT_INVENTORY_CHANGED" and arg1 ~= "player" then return end
  if event == "MERCHANT_SHOW" then
    if ns.OnMerchant then ns.OnMerchant() end
    return
  end
  ns.RequestRefresh()
end)

---------------------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------------------
SLASH_FOREVERCAMPFIRE1 = "/fc"
SLASH_FOREVERCAMPFIRE2 = "/campfire"
SlashCmdList.FOREVERCAMPFIRE = function(msg)
  msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
  if msg == "" then ns.ToggleMain()
  elseif msg == "cooking" or msg == "cook" then ns.ShowMain("cooking")
  elseif msg == "fishing" or msg == "fish" then ns.ShowMain("fishing")
  elseif msg == "both" then ns.ShowMain("both")
  elseif ns.guides[msg] then ns.ShowMain(msg)
  elseif msg == "mine" then ns.ShowMain("mining")
  elseif msg == "herb" or msg == "herbs" then ns.ShowMain("herbalism")
  elseif msg == "skin" then ns.ShowMain("skinning")
  elseif msg == "tracker" then ns.db.tracker = not ns.db.tracker; ns.RequestRefresh()
  elseif msg == "lock" then ns.db.trackerLocked = not ns.db.trackerLocked; ns.Print("Tracker " .. (ns.db.trackerLocked and "locked" or "unlocked"))
  elseif msg == "minimap" then ns.db.minimap.hide = not ns.db.minimap.hide; if ns.UpdateMinimap then ns.UpdateMinimap() end
  elseif msg == "catches" or msg == "catch" or msg == "log" then
    for _, l in ipairs(ns.CatchLines()) do ns.Print(l) end
  elseif msg == "map" then
    local key = ns.TrackedGuideKey()
    local step = key and ns.CurrentStep(ns.guides[key])
    if step and ns.ShowStepOnMap then ns.ShowStepOnMap(step) else ns.Print("No map pins for your current step.") end
  elseif msg == "pins" then ns.db.mapPins = not ns.db.mapPins; ns.Print("Map pins for your current step: " .. (ns.db.mapPins and "on" or "off")); if ns.RefreshMapPins then ns.RefreshMapPins() end
  elseif msg == "sizzle" or msg == "game" then if ns.ShowMiniGame then ns.ShowMiniGame() end
  elseif msg == "shop" then ns.ShowMain(); if ns.ToggleShop then ns.ToggleShop(true) end
  elseif msg == "mem" or msg == "memory" then
    local upd = (C_AddOns and C_AddOns.UpdateAddOnMemoryUsage) or UpdateAddOnMemoryUsage
    local get = (C_AddOns and C_AddOns.GetAddOnMemoryUsage) or GetAddOnMemoryUsage
    if upd and get then
      upd()
      local built = {}
      for _, key in ipairs(ns.guideOrder) do if ns.IsGuideBuilt(key) then table.insert(built, ns.guides[key].name) end end
      ns.Print(string.format("Memory: %.0f KB. Guides loaded: %s.", get(ADDON), (#built > 0 and table.concat(built, ", ") or "none")))
    end
  elseif msg == "reset" then
    ns.char.choice = {}; ns.db.trackerPos = nil; ns.db.mainPos = nil; ns.db.mainSize = nil; ns.db.mainSize2 = nil
    ns.Print("Reset recipe choices and window positions. /reload to re-center windows.")
    ns.RequestRefresh()
  else
    ns.Print("/fc — open guide | cooking | fishing | both | mining | herbalism | skinning | shop | map | pins | catches | sizzle | tracker | lock | minimap | mem | reset")
  end
end
