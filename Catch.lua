-- Catch Log: counts what you actually catch while fishing, per character.
-- Total fish, fish per skill point, fish per rank, streaks, best catch, milestones.
local _, ns = ...
local C = ns.C

local NAT_FISH = { ["Feralas Ahi"] = true, ["Sar'theris Striker"] = true, ["Savage Coast Blue Sailfin"] = true, ["Misty Reed Mahi Mahi"] = true }
local MILESTONES = {
  { id = "first", text = "First fish", test = function(c) return c.total >= 1 end },
  { id = "c100", text = "100 fish", test = function(c) return c.total >= 100 end },
  { id = "c500", text = "500 fish", test = function(c) return c.total >= 500 end },
  { id = "c1000", text = "1,000 fish", test = function(c) return c.total >= 1000 end },
  { id = "streak10", text = "10 in a row", test = function(c) return c.bestStreak >= 10 end },
  { id = "nat", text = "All of Nat's fish", test = function(c) local n = 0; for _ in pairs(c.nat) do n = n + 1 end; return n >= 4 end },
  { id = "artisan", text = "Artisan angler", test = function() return ns.Skill("fishing").rank >= 300 end },
}
ns.CATCH_MILESTONES = MILESTONES

local function data()
  local c = ns.char.catch
  if not c then
    c = { total = 0, items = 0, byRank = {}, streak = 0, bestStreak = 0, nat = {}, got = {},
          points = 0, pointsCatches = 0, sincePoint = 0, today = { day = "", count = 0 } }
    ns.char.catch = c
  end
  return c
end
ns.CatchData = data

local function rankName()
  local max = ns.Skill("fishing").max
  return ns.RANK_NAMES[max] or "Apprentice"
end

local function today()
  return (date and date("%Y-%m-%d")) or "?"
end

local function checkMilestones()
  local c = data()
  for _, m in ipairs(MILESTONES) do
    if not c.got[m.id] and m.test(c) then
      c.got[m.id] = true
      ns.Print("|TInterface\\Icons\\INV_Misc_Fish_02:14|t Catch Log: " .. C.gold .. m.text .. C.r .. "!")
      if PlaySound and SOUNDKIT and SOUNDKIT.UI_EPICLOOT_TOAST then pcall(PlaySound, SOUNDKIT.UI_EPICLOOT_TOAST) end
    end
  end
end

-- One fishing loot window = one catch.
function ns.OnFishingLoot()
  local c = data()
  c.total = c.total + 1
  c.streak = c.streak + 1
  if c.streak > c.bestStreak then c.bestStreak = c.streak end
  c.sincePoint = c.sincePoint + 1
  local r = rankName()
  c.byRank[r] = (c.byRank[r] or 0) + 1
  local d = today()
  if c.today.day ~= d then c.today = { day = d, count = 0 } end
  c.today.count = c.today.count + 1
  local n = GetNumLootItems and GetNumLootItems() or 0
  for i = 1, n do
    local _, name, qty, _, quality = GetLootSlotInfo(i)
    if name then
      c.items = c.items + (qty or 1)
      if NAT_FISH[name] then c.nat[name] = true end
      if quality and (not c.best or quality > c.best.q) then c.best = { name = name, q = quality } end
    end
  end
  checkMilestones()
  ns.RequestRefresh()
end

function ns.OnFishEscaped()
  data().streak = 0
end

-- Called by the engine when a skill goes up.
function ns.OnSkillUp(key, old, new)
  if key ~= "fishing" or not ns.char then return end
  local c = data()
  if c.sincePoint > 0 then
    c.points = c.points + (new - old)
    c.pointsCatches = c.pointsCatches + c.sincePoint
  end
  c.sincePoint = 0
  checkMilestones()
end

function ns.CatchPerPoint()
  local c = data()
  if c.points < 1 then return nil end
  return c.pointsCatches / c.points
end

-- Lines for the detail panel's Catch Log card.
function ns.CatchLines()
  local c = data()
  if c.total == 0 then
    return { C.grey .. "No catches logged yet. Every fish you reel in from now on is counted here." .. C.r }
  end
  local out = {}
  local per = ns.CatchPerPoint()
  table.insert(out, C.gold .. c.total .. C.r .. " fish caught" .. (per and (" · " .. string.format("%.1f", per) .. " per skill point") or ""))
  local nextIn = per and math.max(1, math.floor(per - c.sincePoint + 0.5)) or nil
  table.insert(out, "Streak " .. c.streak .. " (best " .. c.bestStreak .. ")" .. (nextIn and (" · next point in about " .. nextIn) or "")
    .. " · today " .. ((c.today.day == today()) and c.today.count or 0))
  local ranks = {}
  for _, r in ipairs({ "Apprentice", "Journeyman", "Expert", "Artisan" }) do
    if c.byRank[r] then table.insert(ranks, r .. " " .. c.byRank[r]) end
  end
  if #ranks > 0 then table.insert(out, "Fish per rank: " .. table.concat(ranks, " · ")) end
  if c.best then
    local qc = (ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[c.best.q] and ITEM_QUALITY_COLORS[c.best.q].hex) or C.white
    table.insert(out, "Best catch: " .. qc .. c.best.name .. C.r)
  end
  local got = {}
  for _, m in ipairs(MILESTONES) do if c.got[m.id] then table.insert(got, m.text) end end
  if #got > 0 then table.insert(out, C.green .. table.concat(got, " · ") .. C.r) end
  return out
end

-- Short line for the tracker.
function ns.CatchTrackerLine()
  local c = data()
  if c.total == 0 then return nil end
  local per = ns.CatchPerPoint()
  return C.blue .. "Today " .. ((c.today.day == today()) and c.today.count or 0) .. " · streak " .. c.streak
    .. (per and (" · " .. string.format("%.1f", per) .. "/point") or "") .. C.r
end

---------------------------------------------------------------------------
-- Events
---------------------------------------------------------------------------
local ev = CreateFrame("Frame")
for _, e in ipairs({ "LOOT_READY", "LOOT_OPENED", "UI_ERROR_MESSAGE", "UI_INFO_MESSAGE" }) do pcall(ev.RegisterEvent, ev, e) end
local lastLoot = 0
ev:SetScript("OnEvent", function(_, event, a1, a2)
  if not ns.char then return end
  if event == "LOOT_READY" or event == "LOOT_OPENED" then
    if IsFishingLoot and IsFishingLoot() then
      local now = GetTime and GetTime() or 0
      if now - lastLoot > 0.5 then   -- both events fire for one loot window
        lastLoot = now
        ns.OnFishingLoot()
      end
    end
  else
    local msg = (type(a2) == "string" and a2) or (type(a1) == "string" and a1) or nil
    if msg and ((ERR_FISH_ESCAPED and msg == ERR_FISH_ESCAPED) or (ERR_FISH_NOT_HOOKED and msg == ERR_FISH_NOT_HOOKED)) then
      ns.OnFishEscaped()
    end
  end
end)
