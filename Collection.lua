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
