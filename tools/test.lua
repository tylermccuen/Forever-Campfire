-- Offline test: stub the WoW API, load the addon in TOC order, run scenarios.
-- Run: texlua tools/test.lua ForeverCampfire
local dir = arg[1] or "ForeverCampfire"
local fails = 0
local function check(cond, msg) if cond then print("ok   " .. msg) else fails = fails + 1; print("FAIL " .. msg) end end

-- ---------- mock widgets ----------
local function mock()
  local o = { shown = false, scripts = {} }
  return setmetatable(o, { __index = function(t, k)
    if k == "Show" then return function(s) s.shown = true; if s.scripts.OnShow then s.scripts.OnShow(s) end end end
    if k == "Hide" then return function(s) s.shown = false end end
    if k == "SetShown" then return function(s, v) if v then s:Show() else s:Hide() end end end
    if k == "IsShown" then return function(s) return s.shown end end
    if k == "SetScript" then return function(s, n, fn) s.scripts[n] = fn end end
    if k == "HookScript" then return function() end end
    if k == "SetText" then return function(s, v) s.text = v end end
    if k == "GetText" then return function(s) return s.text end end
    if k == "GetChecked" then return function() return true end end
    if k == "GetPoint" then return function() return "CENTER", nil, "CENTER", 0, 0 end end
    if k:match("^Create") or k == "GetFontString" then return function() return mock() end end
    if k:match("Width$") or k:match("Height$") then return function() return 200 end end
    if k == "GetFrameLevel" then return function() return 1 end end
    if k == "GetCenter" then return function() return 100, 100 end end
    return function() end
  end })
end
CreateFrame = function() return mock() end
UIParent, Minimap, GameTooltip, ItemRefTooltip = mock(), mock(), mock(), mock()
UISpecialFrames = {}; tinsert = table.insert
GameTooltip_Hide = function() end
SlashCmdList = {}
local printed = {}
DEFAULT_CHAT_FRAME = { AddMessage = function(_, m) table.insert(printed, m); print("     chat: " .. m) end }
C_Timer = nil
GetTime = function() return 1000 end

-- ---------- game state ----------
local S = { faction = os.getenv("FAC") or "Horde", level = 30, profs = {}, bags = {}, quests = {}, hour = 9, pole = true, lure = false }
UnitFactionGroup = function() return S.faction end
UnitLevel = function() return S.level end
local LINES = { cooking = { "Cooking", 185 }, fishing = { "Fishing", 356 }, mining = { "Mining", 186 }, herbalism = { "Herbalism", 182 },
  skinning = { "Skinning", 393 }, firstaid = { "First Aid", 129 }, alchemy = { "Alchemy", 171 }, blacksmithing = { "Blacksmithing", 164 },
  enchanting = { "Enchanting", 333 }, engineering = { "Engineering", 202 }, leatherworking = { "Leatherworking", 165 }, tailoring = { "Tailoring", 197 } }
local profList = {}
GetProfessions = function()
  profList = {}
  for k in pairs(S.profs) do table.insert(profList, k) end
  table.sort(profList)
  return 1, 2, 3, 4, 5, 6   -- the real API returns at most 5; extra indices are fine for the test
end
GetProfessionInfo = function(i)
  local k = profList[i]
  if not k then return nil end
  local p = S.profs[k]
  return LINES[k][1], 0, p[1], p[2], 0, 0, LINES[k][2]
end
C_Container = {
  GetContainerNumSlots = function(bag) return bag == 0 and 30 or 0 end,
  GetContainerItemInfo = function(bag, slot)
    local i = 0
    for id, n in pairs(S.bags) do
      i = i + 1
      if i == slot then
        if type(id) == "string" then return { itemID = 900000 + i, stackCount = n, hyperlink = "|Hitem:9|h[" .. id .. "]|h" } end
        return { itemID = id, stackCount = n, hyperlink = "|Hitem:" .. id .. "|h[x]|h" }
      end
    end
  end,
}
C_QuestLog = { IsQuestFlaggedCompleted = function(id) return S.quests[id] end }
GetGameTime = function() return S.hour, 30 end
GetInventoryItemID = function() return S.pole and 6256 or nil end
C_Item = { GetItemInfoInstant = function() return 6256, "", "", "", 0, 2, 20 end, GetItemCount = function() return 0 end }
GetWeaponEnchantInfo = function() return S.lure end
GetMerchantNumItems = function() return #S.merchant end
GetMerchantItemInfo = function(i) return S.merchant[i].name end
GetMerchantItemID = function(i) return S.merchant[i].id end

-- ---------- load addon ----------
local ns = {}
for line in io.lines(dir .. "/ForeverCampfire.toc") do
  if not line:match("^#") and line:match("%.lua$") then
    local path = dir .. "/" .. line:gsub("\\", "/")
    local chunk = assert(loadfile(path))
    chunk("ForeverCampfire", ns)
  end
end
check(#ns.guideOrder == 13, "13 guides registered")
ns.eventFrame.scripts.OnEvent(ns.eventFrame, "ADDON_LOADED", "ForeverCampfire")
check(ns.db and ns.char, "saved variables initialised")

local function refresh() ns.Refresh() end
local function cur(k) local s = ns.CurrentStep(ns.guides[k]); return s and s.id end

-- Scenario 1: nothing learned
refresh()
check(cur("cooking") == "learn" and cur("fishing") == "learn", "fresh char: learn steps first")
check(#ns.VisibleGuides() == 0, "fresh char: no tabs")
check(ns.TrackedGuideKey() == nil, "fresh char: tracker has nothing to follow")
ns.ShowMain(); ns.UpdateTracker()
check(true, "fresh char: welcome screen and tracker build without errors")
S.profs.fishing = { 1, 75 }; refresh()
local v = table.concat(ns.VisibleGuides(), ",")
check(v == "fishing", "only Fishing learned: just the Fishing tab (" .. v .. ")")
S.profs.cooking = { 1, 75 }; S.profs.mining = { 1, 75 }; refresh()
v = table.concat(ns.VisibleGuides(), ",")
check(v == "both,mining", "Fishing + Cooking learned: Fish + Cook replaces both tabs (" .. v .. ")")
ns.char.lastActive = "cooking"
check(ns.TrackedGuideKey() == "both", "tracker follows Fish + Cook when both are known")
ns.char.lastActive = nil
S.profs.fishing = nil; S.profs.cooking = nil; S.profs.mining = nil; refresh()

-- Scenario 2: cooking 30/75, with smallfish
S.profs.cooking = { 30, 75 }; S.bags = { [6291] = 20 }
refresh()
check(cur("cooking") == "c1", "cooking 30 -> step c1")
local step = ns.CurrentStep(ns.guides.cooking)
local opt = ns.ChosenOption(step)
check(opt.recipe == "Brilliant Smallfish", "auto-picks option with mats in bags")
check(ns.CraftsLeft(step, opt) == math.ceil(55 * 20 / 49), "crafts left scales with skill")
print("     now: " .. ns.NowText(ns.guides.cooking))

-- Scenario 3: capped at 75 -> train step + cap alert
S.profs.cooking = { 75, 75 }
refresh()
check(cur("cooking") == "jm", "capped at 75 -> train Journeyman")
local hasCap = false
for _, a in ipairs(ns.Alerts(ns.guides.cooking)) do if a.text:match("capped") then hasCap = true end end
check(hasCap, "cap alert shown")

-- Scenario 4: step completion announcement
S.profs.cooking = { 99, 150 }; ns.char.trackerGuide = "cooking"
refresh()
printed = {}
S.profs.cooking = { 100, 150 }
refresh()
check(cur("cooking") == "c3", "cooking 100 -> c3")
check(#printed == 1 and printed[1]:match("Done"), "announced step completion")

-- Scenario 5: expert book in bags at 130/150
S.profs.cooking = { 130, 150 }; S.bags = { [16072] = 1 }
refresh()
local bookAlert = false
for _, a in ipairs(ns.Alerts(ns.guides.cooking)) do if a.text:match("Expert Cookbook") then bookAlert = true end end
check(bookAlert, "reminds to read Expert Cookbook")

-- Scenario 6: artisan quest blocked by level
S.profs.cooking = { 225, 225 }; S.level = 30; S.bags = { [12207] = 12 }
refresh()
check(cur("cooking") == "artisan", "225/225 -> artisan quest step")
check(#ns.StepBlockers(ns.CurrentStep(ns.guides.cooking)) == 1, "level 30 blocks artisan quest")
S.quests[6610] = true; S.level = 40
refresh()
check(cur("cooking") == "c6", "quest done -> c6")

-- Scenario 7: fishing lure + nightfin warnings
S.profs.fishing = { 260, 300 }; S.hour = 14; S.lure = false
refresh()
local lure, night = false, false
for _, a in ipairs(ns.Alerts(ns.guides.fishing)) do if a.text:match("lure") then lure = true end end
check(lure, "no-lure warning while fishing")
S.profs.cooking = { 290, 300 }; refresh()
for _, a in ipairs(ns.Alerts(ns.guides.cooking)) do if a.text:match("Nightfin") then night = true end end
check(night, "Nightfin bite-time warning at 14:00")

-- Scenario 8: combined guide soft step + secondary
S.profs.fishing = { 140, 150 }; S.profs.cooking = { 60, 150 }; S.bags = {}
refresh()
check(cur("both") == "fexp", "combined: no Longjaw left -> soft step done, next is Booty Bay")

-- Scenario 9: shopping list from 1
S.profs.cooking = { 1, 75 }; S.bags = { [2692] = 10 }
refresh()
local list = ns.ShoppingList(ns.guides.cooking)
local spices
for _, it in ipairs(list) do if it.id == 2692 then spices = it end end
check(spices and spices.need == 28 + 55 and spices.have == 10, "shopping list: Hot Spices 83 needed, 10 had")

-- Scenario 10: vendor alert
S.merchant = { { name = "Recipe: Roast Raptor", id = 12232 }, { name = "Hot Spices", id = 2692 } }
S.profs.cooking = { 140, 150 }; S.bags = {}; refresh()
printed = {}
ns.OnMerchant()
check(#printed == 2, "vendor alert for recipe and Hot Spices")

-- Scenario 12: mining
S.profs.mining = { 30, 75 }; S.bags = {}; refresh()
check(cur("mining") == "m1", "mining 30 -> Mine Copper")
local ms = ns.CurrentStep(ns.guides.mining)
check(ns.ChosenOption(ms).name == "Mine it yourself", "no ore in bags -> mining route option")
local toolAlert = false
for _, a in ipairs(ns.Alerts(ns.guides.mining)) do if a.text:match("Mining Pick") then toolAlert = true end end
check(toolAlert, "warns when Mining Pick is missing")
S.bags = { [2770] = 120, [2901] = 1 }; refresh()
check(ns.ChosenOption(ns.CurrentStep(ns.guides.mining)).verb == "Smelt", "lots of Copper Ore -> smelting option")
print("     now: " .. ns.NowText(ns.guides.mining))
-- train step waits until you have the skill for it
S.profs.mining = { 118, 150 }; S.bags = { [2901] = 1 }; refresh()
check(cur("mining") == "m2", "mining 118/150: keep mining, Expert training not yet")
S.profs.mining = { 126, 150 }; refresh()
check(cur("mining") == "exp", "mining 126/150 -> train Expert")
S.profs.mining = nil

-- Scenario 13: skinning numbers + herbalism
check(ns.SkinningNeeded(16) == 60 and ns.SkinningNeeded(30) == 150 and ns.SkinningNeeded(5) == 1, "skinning formula")
S.profs.herbalism = { 205, 225 }; refresh()
check(cur("herbalism") == "art", "herbalism 205/225 -> train Artisan")
S.profs.herbalism = nil; refresh()

-- Scenario 14: crafting guides
S.profs = { firstaid = { 30, 75 } }; S.bags = { ["Linen Cloth"] = 20 }; refresh()
check(cur("firstaid") == "a1", "first aid 30 -> Linen Bandages")
check(ns.Count("Linen Cloth") == 20, "counts items listed by name")
check(ns.ChosenOption(ns.CurrentStep(ns.guides.firstaid)).recipe == "Linen Bandage", "first aid picks bandages when you have cloth")
S.bags = { ["Spider Ichor"] = 54, ["Mild Spices"] = 54, ["Bottle of Dalaran Noir"] = 54 }
S.profs.firstaid = { 95, 150 }; refresh()
check(ns.ChosenOption(ns.CurrentStep(ns.guides.firstaid)).recipe == "Simple Poultice", "first aid switches to Simple Poultice when you have its materials")
S.profs.firstaid = { 225, 225 }; S.level = 40; refresh()
check(cur("firstaid") == "triage", "first aid 225/225 -> Triage quest")
S.quests[FAC_Q or 6622] = true; S.quests[6624] = true; refresh()
check(cur("firstaid") == "a9", "Triage done (faction quest ID) -> next step")
S.profs = { tailoring = { 145, 150 }, enchanting = { 1, 75 } }; S.bags = {}; refresh()
v = table.concat(ns.VisibleGuides(), ",")
check(v == "enchanting,tailoring", "crafting tabs follow learned professions (" .. v .. ")")
check(cur("tailoring") == "exp", "tailoring 145/150 -> train Expert")
print("     now: " .. ns.NowText(ns.guides.tailoring))
S.profs.tailoring = { 152, 225 }; refresh()
print("     now: " .. ns.NowText(ns.guides.tailoring))
for _, k in ipairs({ "alchemy", "blacksmithing", "enchanting", "engineering", "leatherworking", "tailoring", "firstaid" }) do
  local okAll = true
  for _, st in ipairs(ns.guides[k].steps) do
    local ok, err = pcall(ns.StepBody, st)
    if not ok then okAll = false; print("     " .. k .. "/" .. st.id .. ": " .. tostring(err)) end
  end
  check(okAll, k .. ": every step renders")
end
ns.db.showAll = true; ns.ShowMain("tailoring"); ns.db.showAll = false
check(true, "13 tabs in two rows build without errors")
S.profs = { cooking = { 290, 300 }, fishing = { 260, 300 } }; S.level = 60; S.quests = {}; refresh()

-- Scenario 15: map pins
local stepIds = {}
for gk, g in pairs(ns.guides) do for _, st in ipairs(g.steps) do stepIds[gk .. "/" .. st.id] = true end end
local badKeys = {}
for gk, list in pairs(ns.Pins) do for sid, pins in pairs(list) do
  if not stepIds[gk .. "/" .. sid] then table.insert(badKeys, gk .. "/" .. sid) end
  for _, p in ipairs(pins) do
    if not (p.zone and p.x and p.y and p.label and p.x > 0 and p.x < 100 and p.y > 0 and p.y < 100) then table.insert(badKeys, gk .. "/" .. sid .. " bad pin") end
  end
end end
check(#badKeys == 0, "every pin belongs to a real step and has valid coordinates " .. table.concat(badKeys, " "))
-- fake map API
local ZONES = { "Elwynn Forest", "Stormwind City", "Mulgore", "Thunder Bluff", "Dustwallow Marsh", "Feralas", "Desolace", "Swamp of Sorrows", "Stranglethorn Vale" }
C_Map = {
  GetBestMapForUnit = function() return 1001 end,
  GetMapInfo = function(id) if id == 1 then return { parentMapID = 0 } end return { parentMapID = 1 } end,
  GetMapChildrenInfo = function() local t = {} for i, z in ipairs(ZONES) do t[i] = { name = z, mapID = 1000 + i } end return t end,
}
local shownMap
WorldMapFrame = mock()
WorldMapFrame.ScrollContainer = mock(); WorldMapFrame.ScrollContainer.Child = mock()
WorldMapFrame.GetMapID = function() return shownMap end
WorldMapFrame.SetMapID = function(_, id) shownMap = id end
OpenWorldMap = function(id) WorldMapFrame.shown = true; shownMap = id end
hooksecurefunc = function() end
ns.InitMapPins()
S.profs = { fishing = { 260, 300 } }; S.level = 60; refresh()
local fart
for _, st in ipairs(ns.guides.fishing.steps) do if st.id == "artisan" then fart = st end end
check(#ns.StepPins(fart) == 5, "Artisan fishing step has Nat Pagle + 4 fish spots")
ns.ShowStepOnMap(fart)
check(shownMap == 1005, "Show on map opens Dustwallow Marsh (Nat Pagle) first")
local f4
for _, st in ipairs(ns.guides.fishing.steps) do if st.id == "f4" then f4 = st end end
local fac = S.faction
check(#ns.StepPins(f4) == 2, "faction-only pins are filtered (" .. fac .. ")")
ns.SetWaypoint(ns.StepPins(f4)[1])
check(true, "waypoint without TomTom or Blizzard waypoints just prints coordinates")
WorldMapFrame = nil

-- Scenario 16: skill tree bands and layout for every guide
local b = ns.Bands(ns.guides.cooking)
local ranks = {}
for _, band in ipairs(b) do table.insert(ranks, band.rank) end
check(table.concat(ranks, ",") == "1,2,3,4", "cooking splits into Apprentice/Journeyman/Expert/Artisan (" .. table.concat(ranks, ",") .. ")")
check(b[2].steps[1].id == "jm", "Journeyman band opens with the Train Journeyman gate")
local mono = true
for _, k in ipairs(ns.guideOrder) do
  local last = 0
  for _, band in ipairs(ns.Bands(ns.guides[k])) do if band.rank < last then mono = false end; last = band.rank end
end
check(mono, "bands never go backwards in any guide (combined guide included)")
local layoutOK = true
for _, skill in ipairs({ {1,75}, {120,150}, {300,300} }) do
  S.profs = {}; for k in pairs(LINES) do S.profs[k] = skill end
  S.level = 60; refresh()
  for _, k in ipairs(ns.guideOrder) do
    ns.treeOpen = {}
    local ok, h = pcall(ns.LayoutTree, ns.guides[k], 560)
    if not ok or type(h) ~= "number" or h < 40 then layoutOK = false; print("     tree " .. k .. ": " .. tostring(h)) end
  end
end
check(layoutOK, "tree lays out for all 13 guides at skill 1, 120 and 300")
S.profs = { cooking = { 60, 150 } }; S.bags = { [6289] = 30 }; refresh()
ns.treeOpen = {}
local cur = ns.CurrentStep(ns.guides.cooking)
check(cur.id == "c2" and #ns.Options(cur) == 2, "current cooking step is a fork with 2 recipes")

-- Scenario 17: Catch Log
ns.char.catch = nil
S.profs = { fishing = { 50, 75 } }; refresh()
GetNumLootItems = function() return 1 end
GetLootSlotInfo = function() return 0, "Raw Brilliant Smallfish", 1, nil, 1 end
for i = 1, 10 do ns.OnFishingLoot() end
ns.OnSkillUp("fishing", 50, 51)
for i = 1, 3 do ns.OnFishingLoot() end
ns.OnFishEscaped()
local c = ns.CatchData()
check(c.total == 13 and c.items == 13, "Catch Log counts catches and items")
check(ns.CatchPerPoint() == 10, "Catch Log: fish per skill point")
check(c.streak == 0 and c.bestStreak == 13, "escaped fish resets the streak, best streak kept")
check(c.got.first and c.byRank.Apprentice == 13, "first-fish milestone and per-rank count")
GetLootSlotInfo = function() return 0, "Feralas Ahi", 1, nil, 1 end
ns.OnFishingLoot()
check(c.nat["Feralas Ahi"], "Catch Log remembers Nat Pagle's quest fish")
check(#ns.CatchLines() >= 3, "Catch Log card has lines")

-- Scenario 18: recipe collection, camp view, tooltips
check(#ns.Collections.cooking.recipes >= 120, "cooking collection has " .. #ns.Collections.cooking.recipes .. " recipes")
local names, dup = {}, nil
for _, r in ipairs(ns.Collections.cooking.recipes) do if names[r.name] then dup = r.name end; names[r.name] = true end
check(dup == nil, "no duplicate recipe names " .. tostring(dup))
S.profs = { cooking = { 230, 300 }, fishing = { 150, 225 }, tailoring = { 145, 225 } }; refresh()
ns.char.known = nil
check(ns.KnowsRecipe("cooking", "Roasted Boar Meat") == nil, "unknown until the Cooking window is opened")
C_TradeSkillUI = {
  GetBaseProfessionInfo = function() return { professionID = 185, professionName = "Cooking" } end,
  GetAllRecipeIDs = function() return { 1, 2, 3 } end,
  GetRecipeInfo = function(id) return ({ { name = "Roasted Boar Meat", learned = true }, { name = "Spotted Yellowtail", learned = false }, { name = "Basic Campfire Kit", learned = true } })[id] end,
}
ns.ScanKnownRecipes()
check(ns.KnowsRecipe("cooking", "Roasted Boar Meat") == true and ns.KnowsRecipe("cooking", "Spotted Yellowtail") == false, "scan reads known and missing recipes")
local have, total = ns.CollectionCounts(ns.Collections.cooking)
check(have == 2, "collection count after scan (" .. have .. "/" .. total .. ")")
local tl = ns.CollectionTooltipLine("Recipe: Spotted Yellowtail")
check(tl and tl:find("Not in your collection"), "recipe tooltip says it's missing")
local bl = ns.CollectionTooltipLine("Blueprint: Spinning Wheel")
check(bl and bl:find("Camp tier 2"), "blueprint tooltip names the camp tier")
check(ns.CampItemForBlueprint("Blueprint: Journeyman Campfire").item.tier == 2, "campfire blueprint maps to the Journeyman Campfire Kit")
local okR = true
for _, flt in ipairs({ "all", "missing", "now" }) do
  ns.recipeFilter = flt
  local ok, h = pcall(ns.LayoutRecipes, mock(), 560, ns.Collections.cooking)
  if not ok or h < 100 then okR = false; print("     recipes " .. flt .. ": " .. tostring(h)) end
end
ns.recipeFilter = "all"
check(okR, "Recipes view lays out with every filter")
local okC, hC = pcall(ns.LayoutCamp, mock(), 560)
check(okC and hC > 200, "Camp view lays out (" .. tostring(hC) .. ")")
local campProfs = 0
for k in pairs(ns.Camp.items) do campProfs = campProfs + 1 end
check(campProfs == 12, "camp items for all 12 professions")
ns.ShowMain("camp"); ns.ShowMain("both"); ns.views.both = "recipes"; ns.UpdateMain(); ns.views.both = "route"
check(true, "Camp tab and Recipes view open without errors")
C_TradeSkillUI = nil

-- Scenario 11: UI builds and updates without errors
for _, k in ipairs(ns.guideOrder) do ns.ShowMain(k) end; ns.ToggleShop(true); ns.UpdateTracker()
ns.ShowMiniGame()
check(true, "UI builds for all tabs, shop, tracker, mini-game")
SlashCmdList.FOREVERCAMPFIRE("help")

print(fails == 0 and "ALL PASSED" or (fails .. " FAILED"))
os.exit(fails == 0 and 0 or 1)
