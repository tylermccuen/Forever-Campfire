-- Item tooltips ("needed for step X"), vendor alerts, and UI start-up.
local _, ns = ...
local C = ns.C

---------------------------------------------------------------------------
-- Index: item -> where the guides use it
---------------------------------------------------------------------------
local uses = {}       -- id -> list of { step, opt, kind, count }
local usesByName = {}

local function addUse(ref, use)
  local name = ns.ItemName(ref)
  local id = ns.IdOf(ref)
  local list = (id and uses[id]) or usesByName[name] or {}
  table.insert(list, use)
  if id then uses[id] = list end
  usesByName[name] = list
end

-- Item uses are indexed per guide when the guide is built, so tooltips cover
-- your own professions (and any you preview) without loading the rest.
local function indexGuide(g)
  for _, step in ipairs(g.steps) do
    for _, opt in ipairs(step.options or {}) do
      for _, m in ipairs(opt.mats or {}) do addUse(m[1], { step = step, opt = opt, kind = "mat" }) end
      for _, b in ipairs(opt.buy or {}) do addUse(b.id, { step = step, kind = "buy", count = b.count }) end
    end
    for _, gth in ipairs(step.gather or {}) do addUse(gth.id, { step = step, kind = "gather", count = gth.count }) end
    for _, b in ipairs(step.buy or {}) do addUse(b.id, { step = step, kind = "buy", count = b.count }) end
    for _, c in ipairs(step.catch or {}) do addUse(c[1], { step = step, kind = "catch" }) end
  end
end

local function buildIndex()
  for _, key in ipairs(ns.guideOrder) do
    if ns.IsGuideBuilt(key) then indexGuide(ns.guides[key]) end
  end
  table.insert(ns.guideBuilt, indexGuide)
end

local function tooltipLines(tt, id, name)
  if not ns.db.tooltips then return end
  local colLine = ns.CollectionTooltipLine and ns.CollectionTooltipLine(name)
  if colLine then tt:AddLine("|TInterface\\Icons\\Spell_Fire_Fire:12|t " .. colLine); tt:Show() end
  local list = (id and uses[id]) or (name and usesByName[name])
  if not list then return end
  local shown, seen = 0, {}
  for _, u in ipairs(list) do
    local step = u.step
    local g = step.guide
    local skip = ns.IsStepDone(step) or seen[step] or shown >= 3
    -- only the guides that have a tab for this character (no doubles)
    if not ns.GuideActive(g.key) then skip = true end
    if not skip then
      local label = ns.SkillDisplayName(step.skill) .. " " .. (step.from and (step.from .. "-" .. step.to) or step.title)
      local txt
      if u.kind == "mat" then
        local chosen = ns.ChosenOption(step)
        if u.opt.count then
          local need = 0
          for _, n in ipairs(ns.OptionNeeds(step, u.opt)) do if (id and ns.IdOf(n.id) == id) or ns.ItemName(n.id) == name then need = n.need end end
          txt = label .. ": " .. u.opt.recipe .. "  " .. ns.Have(id or name, need)
        else
          txt = label .. ": cook into " .. u.opt.recipe
        end
        if chosen ~= u.opt then txt = txt .. C.grey .. " (alt. option)" .. C.r end
      elseif u.kind == "gather" or u.kind == "buy" then
        txt = label .. ": need " .. ns.Have(id or name, u.count)
      else
        txt = label .. ": you'll catch these here"
      end
      if shown == 0 then tt:AddLine("|TInterface\\Icons\\Spell_Fire_Fire:12|t " .. C.gold .. "Forever Campfire" .. C.r) end
      tt:AddLine("  " .. txt, 1, 1, 1)
      shown = shown + 1
      seen[step] = true
    end
  end
  if shown > 0 then tt:Show() end
end

-- Skinning skill needed for a mob of this level.
function ns.SkinningNeeded(level)
  if level <= 10 then return 1 end
  if level <= 20 then return (level - 10) * 10 end
  return level * 5
end

local function unitLine(tt, unit)
  if not (ns.db.tooltips and unit) then return end
  local sk = ns.Skill("skinning")
  if not sk.known then return end
  local ok, ctype = pcall(UnitCreatureType, unit)
  if not ok or (ctype ~= "Beast" and ctype ~= "Dragonkin") then return end
  if UnitIsPlayer(unit) then return end
  local ok2, lvl = pcall(UnitLevel, unit)
  if not ok2 or type(lvl) ~= "number" or lvl < 1 then return end
  local need = ns.SkinningNeeded(lvl)
  local col = (sk.rank >= need) and C.green or C.red
  tt:AddLine("|T" .. ns.guides.skinning.icon .. ":12|t Skinning: needs " .. col .. need .. C.r .. " (you have " .. sk.rank .. ")", 1, 1, 1)
end

local function hookTooltips()
  if TooltipDataProcessor and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt, data)
      if tt ~= GameTooltip and tt ~= ItemRefTooltip then return end
      local id = data and data.id
      local name = tt.GetItem and select(1, tt:GetItem())
      tooltipLines(tt, id, name)
    end)
    if Enum.TooltipDataType.Unit then
      TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tt)
        if tt ~= GameTooltip then return end
        local _, unit = tt:GetUnit()
        if InCombatLockdown and InCombatLockdown() then return end
        unitLine(tt, unit)
      end)
    end
  elseif GameTooltip and GameTooltip.HookScript then
    GameTooltip:HookScript("OnTooltipSetItem", function(tt)
      local name, link = tt:GetItem()
      local id = link and tonumber(link:match("item:(%d+)"))
      tooltipLines(tt, id, name)
    end)
  end
end

---------------------------------------------------------------------------
-- Vendor alerts: tell the player when a vendor sells something the route needs.
---------------------------------------------------------------------------
local function upcomingSteps()
  local out = {}
  for _, key in ipairs(ns.guideOrder) do
    local g = ns.guides[key]
    local n = 0
    for _, step in ipairs(ns.GuideKnown(g) and g.steps or {}) do
      if not ns.IsStepDone(step) then
        table.insert(out, step); n = n + 1
        if n >= 4 then break end
      end
    end
  end
  return out
end

function ns.OnMerchant()
  if not (ns.db.vendorAlerts and GetMerchantNumItems) then return end
  ns.ScanBags()
  local wantRecipe, wantItem = {}, {}
  for _, step in ipairs(upcomingSteps()) do
    for _, r in ipairs(step.recipes or {}) do wantRecipe[r] = wantRecipe[r] or step end
    for _, opt in ipairs(step.options or {}) do
      if opt.product and not opt.verb and step.guide.recipePrefix then local rn = opt.recipeItem or (step.guide.recipePrefix .. opt.recipe); wantRecipe[rn] = wantRecipe[rn] or step end
      if opt.count and opt == ns.ChosenOption(step) then
        for _, n in ipairs(ns.OptionNeeds(step, opt)) do
          if ns.IsVendorItem(n.id) then wantItem[n.id] = (wantItem[n.id] or 0) + n.need end
        end
      end
    end
    for _, b in ipairs(step.buy or {}) do wantItem[b.id] = (wantItem[b.id] or 0) + b.count end
    for _, gth in ipairs(step.gather or {}) do if ns.IsVendorItem(gth.id) then wantItem[gth.id] = (wantItem[gth.id] or 0) + gth.count end end
  end
  local said = {}
  for i = 1, GetMerchantNumItems() do
    local name
    if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
      local info = C_MerchantFrame.GetItemInfo(i); name = info and info.name
    else
      name = GetMerchantItemInfo(i)
    end
    local id = GetMerchantItemID and GetMerchantItemID(i)
    if name and not said[name] and ns.CollectionTooltipLine then
      local camp = ns.CampItemForBlueprint(name)
      local recipeName = name:match("^Recipe: (.+)$")
      if camp and ns.Skill(camp.key).known and ns.KnowsRecipe(camp.key, camp.item.name) ~= true then
        said[name] = true
        ns.Print("This vendor sells a camp plan: " .. C.gold .. name .. C.r .. " (" .. ns.SkillDisplayName(camp.key) .. " tier " .. camp.item.tier .. ", skill " .. camp.item.skill .. ").")
      elseif recipeName and ns.Collections and ns.Collections.cooking and ns.KnowsRecipe("cooking", recipeName) == false then
        said[name] = true
        ns.Print("New for your recipe collection: " .. C.gold .. name .. C.r .. ".")
      end
    end
    if name and wantRecipe[name] and not said[name] then
      said[name] = true
      ns.Print("This vendor sells " .. C.gold .. name .. C.r .. " (for " .. wantRecipe[name].title .. "). Grab it if you don't have it yet.")
    end
    local itemId = (id and wantItem[id] and id)
    if not itemId and name then
      for wid in pairs(wantItem) do if ns.ItemName(wid) == name or (id and ns.IdOf(wid) == id) then itemId = wid end end
    end
    if itemId and not said[itemId] then
      said[itemId] = true
      local need, have = wantItem[itemId], ns.Count(itemId)
      if have < need then
        ns.Print("This vendor sells " .. ns.IconText(itemId) .. " " .. C.gold .. ns.ItemName(itemId) .. C.r
          .. ": you need " .. C.white .. (need - have) .. C.r .. " more (have " .. have .. "/" .. need .. ").")
      end
    end
  end
end

---------------------------------------------------------------------------
-- Start-up
---------------------------------------------------------------------------
function ns.InitUI()
  buildIndex()
  hookTooltips()
  if ns.InitMinimap then ns.InitMinimap() end
  if ns.InitMiniGame then ns.InitMiniGame() end
  if ns.InitMapPins then pcall(ns.InitMapPins) end
  ns.RequestRefresh()
end
