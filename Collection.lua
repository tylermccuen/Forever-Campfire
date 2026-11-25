-- Learns which recipes this character knows by reading the profession window
-- when it opens (the game only shares recipe lists then). Saved per character.
local _, ns = ...
local C = ns.C

local function skillKeyForOpenWindow()
  if C_TradeSkillUI and C_TradeSkillUI.GetBaseProfessionInfo then
    local ok, info = pcall(C_TradeSkillUI.GetBaseProfessionInfo)
    if ok and type(info) == "table" then
      for key, s in pairs(ns.SKILLS) do
        if info.professionID == s.line or info.professionName == s.name or info.professionName == ns.SkillDisplayName(key) then return key end
      end
    end
  end
  if GetTradeSkillLine then
    local name = GetTradeSkillLine()
    for key, s in pairs(ns.SKILLS) do
      if name == s.name or name == ns.SkillDisplayName(key) then return key end
    end
  end
  return nil
end

function ns.ScanKnownRecipes()
  local key = skillKeyForOpenWindow()
  if not key then return end
  local known, n = {}, 0
  if C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs and C_TradeSkillUI.GetRecipeInfo then
    local ok, ids = pcall(C_TradeSkillUI.GetAllRecipeIDs)
    if ok and ids then
      for _, id in ipairs(ids) do
        local ok2, info = pcall(C_TradeSkillUI.GetRecipeInfo, id)
        if ok2 and info and info.learned and info.name then known[info.name] = true; n = n + 1 end
      end
    end
  elseif GetNumTradeSkills and GetTradeSkillInfo then
    for i = 1, GetNumTradeSkills() do
      local name, kind = GetTradeSkillInfo(i)
      if name and kind ~= "header" then known[name] = true; n = n + 1 end
    end
  end
  if n == 0 then return end
  ns.char.known = ns.char.known or {}
  local first = not ns.char.known[key]
  ns.char.known[key] = known
  ns.knownVersion = (ns.knownVersion or 0) + 1   -- views redraw when this changes
  if first then ns.Print("Read your " .. ns.SkillDisplayName(key) .. " recipes (" .. n .. " known). The Recipes and Camp views now show what you have.") end
  ns.RequestRefresh()
end

-- true / false, or nil when this profession's window hasn't been opened yet.
function ns.KnowsRecipe(skillKey, name)
  local k = ns.char and ns.char.known and ns.char.known[skillKey]
  if not k then return nil end
  return k[name] and true or false
end

function ns.CollectionCounts(col)
  local have, total = 0, 0
  for _, r in ipairs(col.recipes) do
    total = total + 1
    if ns.KnowsRecipe(col.skill, r.name) then have = have + 1 end
  end
  return have, total
end

-- A camp item whose Blueprint this is (name "Blueprint: X" or "Blueprint: X Kit"), for a profession you know.
function ns.CampItemForBlueprint(itemName)
  local base = itemName and itemName:match("^Blueprint: (.+)$")
  if not base or not ns.Camp then return nil end
  local function check(key, it)
    if it.name == base or it.name == base .. " Kit" then return { key = key, item = it } end
  end
  for _, f in ipairs(ns.Camp.fires) do local r = check("cooking", f); if r then return r end end
  for key, items in pairs(ns.Camp.items) do
    for _, it in ipairs(items) do local r = check(key, it); if r then return r end end
  end
  return nil
end

-- Tooltip line for recipe and blueprint items: in your collection or not.
function ns.CollectionTooltipLine(itemName)
  if not itemName then return nil end
  local camp = ns.CampItemForBlueprint(itemName)
  if camp then
    local sk = ns.Skill(camp.key)
    local k = ns.KnowsRecipe(camp.key, camp.item.name)
    local who = ns.SkillDisplayName(camp.key)
    if k == true then return C.green .. "Camp: you already have the " .. camp.item.name .. C.r end
    return C.orange .. "Camp tier " .. camp.item.tier .. " for " .. who .. " (skill " .. camp.item.skill .. ")" .. (sk.known and "" or ": you don't have " .. who) .. C.r
  end
  local base = itemName:match("^Recipe: (.+)$")
  if not base then return nil end
  for _, col in pairs(ns.Collections or {}) do
    for _, r in ipairs(col.recipes) do
      if r.name == base then
        local k = ns.KnowsRecipe(col.skill, r.name)
        if k == true then return C.green .. "Already in your " .. ns.SkillDisplayName(col.skill) .. " collection" .. C.r end
        if k == false then return C.orange .. "Not in your collection yet (needs " .. ns.SkillDisplayName(col.skill) .. " " .. r.skill .. ")" .. C.r end
        return C.grey .. "Open your " .. ns.SkillDisplayName(col.skill) .. " window once to check your collection" .. C.r
      end
    end
  end
  return nil
end

local ev = CreateFrame("Frame")
for _, e in ipairs({ "TRADE_SKILL_SHOW", "TRADE_SKILL_LIST_UPDATE", "TRADE_SKILL_DATA_SOURCE_CHANGED", "NEW_RECIPE_LEARNED" }) do
  pcall(ev.RegisterEvent, ev, e)
end
ev:SetScript("OnEvent", function()
  if not ns.char then return end
  if C_Timer and C_Timer.After then C_Timer.After(0.5, function() pcall(ns.ScanKnownRecipes) end) else pcall(ns.ScanKnownRecipes) end
end)


-- One line saying where a route recipe is learned, or that you know it already.
-- Uses Data/RecipeSources.lua, or the profession's recipe collection (Cooking).
function ns.LearnLine(skillKey, recipe)
  local C = ns.C
  if not skillKey or not recipe then return nil end
  if ns.KnowsRecipe(skillKey, recipe) == true then return C.green .. "You know this recipe." .. C.r end
  local prof = ns.SkillDisplayName(skillKey)
  local kind, skill, item, who
  local list = ns.RecipeSources[skillKey]
  local src = list and list[recipe]
  if src then
    if src[1] == "start" then kind = "start"
    elseif src[1] == "trainer" then kind, skill, who = "trainer", src[2], src.who
    else kind, item, skill = "item", src[1], src[2] end
  else
    local col = ns.Collections and ns.Collections[skillKey]
    if not col then return nil end
    for _, r in ipairs(col.recipes) do
      if r.name == recipe then
        if r.source == "Trainer" then kind, skill = "trainer", r.skill
        elseif r.source:find("^Known with") then kind = "start"
        else kind, item, skill = "other", r.source, r.skill end
        break
      end
    end
  end
  local L = C.gold .. "Learn: " .. C.r
  if kind == "start" then return L .. "you know it as soon as you learn " .. prof .. "." end
  if kind == "trainer" then
    return L .. "from " .. (ns.FText(who) or ("your " .. prof .. " trainer")) .. (skill and (" at " .. skill) or "") .. "."
  end
  if kind == "item" then
    return L .. C.white .. item .. C.r .. (skill and (", usable at " .. skill) or "") .. ". Trainers don't teach it."
  end
  if kind == "other" then return L .. item .. (skill and (C.grey .. " (skill " .. skill .. ")" .. C.r) or "") end
  return nil
end


-- Where a route recipe comes from (Data/RecipeSources.lua), or nil.
function ns.RecipeSource(skillKey, recipe)
  local list = skillKey and ns.RecipeSources[skillKey]
  return list and list[recipe]
end

---------------------------------------------------------------------------
-- "Go to" steps: what to do, in order, before and while crafting a step.
-- For a crafting step's chosen option this returns a list of
--   { kind = "recipe" | "vendor" | "gather" | "craft", text = "...", done = bool, hint = "..." }
-- 1. get the recipe (go to the vendor or trainer), 2. buy vendor materials,
-- 3. gather or buy the rest, 4. craft. Steps with nothing to do are left out,
-- except the craft itself.
---------------------------------------------------------------------------
local function joinNames(list)
  local parts = {}
  for _, n in ipairs(list) do table.insert(parts, n.need .. " " .. ns.ItemName(n.id)) end
  return table.concat(parts, ", ")
end

-- The recipe part on its own: { text, done, hint } or nil when nothing needs doing.
function ns.RecipePrep(step, opt)
  if not (opt and opt.product and opt.recipe) or opt.recipeFrom then return nil end
  local skillKey = step.skill
  local src = ns.RecipeSource(skillKey, opt.recipe)
  if not src or src[1] == "start" then return nil end
  local known = ns.KnowsRecipe(skillKey, opt.recipe)
  local prof = ns.SkillDisplayName(skillKey)
  local rank = ns.Skill(skillKey).rank
  local usable = src[2]
  local later = usable and rank < usable and (" (usable at " .. usable .. ")") or ""
  if src[1] == "trainer" then
    -- trainer recipes are only shown when the profession window says you don't have it
    if known ~= false then return nil end
    local who = ns.FText(src.who) or ns.FText(step.guide.capitalTrainer) or ("your " .. prof .. " trainer")
    return { kind = "recipe", done = false, text = "Go to " .. who .. " and learn " .. opt.recipe .. later .. "." }
  end
  local item = src[1]
  if known == true then return { kind = "recipe", done = true, text = "Learn " .. opt.recipe .. " (" .. item .. ")." } end
  if ns.Count(item) > 0 then
    return { kind = "recipe", done = false, text = "Use " .. item .. " in your bags to learn it" .. later .. "." }
  end
  local at, get = ns.FText(src.at), ns.FText(src.get)
  local text
  if at then text = "Go to " .. at .. " and buy " .. item .. "."
  elseif get then text = "Get " .. item .. ": " .. get .. "."
  else text = "Get " .. item .. " (vendor or Auction House)." end
  if usable and rank < usable then text = text .. " Usable at " .. usable .. "." end
  local hint
  if src.bop then hint = "Binds when picked up: buy it on the character that crafts." end
  if known == nil then
    hint = (hint and (hint .. " ") or "") .. "Already have it? Open your " .. prof .. " window and this ticks off."
  end
  return { kind = "recipe", done = false, text = text, hint = hint, maybe = (known == nil) }
end

function ns.PrepSteps(step, opt)
  if step.kind ~= "level" or not (opt and opt.product) then return nil end
  local out = {}
  local r = ns.RecipePrep(step, opt)
  if r then table.insert(out, r) end
  if opt.count then
    local vendor, other, vendorAll, otherAll = {}, {}, {}, {}
    for _, n in ipairs(ns.OptionNeeds(step, opt)) do
      if n.need > 0 then
        local isVendor = ns.IsVendorItem(n.id)
        table.insert(isVendor and vendorAll or otherAll, n)
        local short = n.need - ns.Count(n.id)
        if short > 0 then table.insert(isVendor and vendor or other, { id = n.id, need = short }) end
      end
    end
    if #vendorAll > 0 then
      table.insert(out, { kind = "vendor", done = #vendor == 0,
        text = (#vendor == 0) and ("Vendor materials: you have them (" .. joinNames(vendorAll) .. ").")
          or ("Buy from a vendor: " .. joinNames(vendor) .. ".") })
    end
    if #otherAll > 0 then
      table.insert(out, { kind = "gather", done = #other == 0,
        text = (#other == 0) and ("Materials: you have them (" .. joinNames(otherAll) .. ").")
          or ("Gather or buy on the Auction House: " .. joinNames(other) .. ".") })
    end
  end
  local verb = opt.verb or step.guide.verb or "Cook"
  local crafts = ns.CraftsLeft(step, opt)
  local what = (opt.count == 1) and (verb .. " one " .. opt.recipe)
    or (verb .. " " .. (opt.count and ("about " .. crafts .. " ") or "") .. opt.recipe .. " until " .. step.to)
  table.insert(out, { kind = "craft", done = ns.IsStepDone(step), text = what .. "." })
  return out
end

-- The first "go to" step that isn't done yet, if it comes before crafting.
function ns.NextPrep(step, opt)
  for _, p in ipairs(ns.PrepSteps(step, opt) or {}) do
    if p.kind == "craft" then return nil end
    if not p.done and p.kind == "recipe" then return p end
  end
  return nil
end
