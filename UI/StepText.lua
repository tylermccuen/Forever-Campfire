-- Builds the text shown for a step in the detail panel.
local _, ns = ...
local C = ns.C
local CHECK = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14|t"

-- Splits "Label: A (x), B (y), C" into a gold label and one entry per line,
-- so long trainer / vendor lists are easy to scan. Short text is left alone.
local function splitTop(text)
  local parts, depth, cur = {}, 0, ""
  for ch in text:gmatch(".") do
    if ch == "(" then depth = depth + 1 elseif ch == ")" then depth = depth - 1 end
    if ch == "," and depth == 0 then table.insert(parts, cur); cur = "" else cur = cur .. ch end
  end
  table.insert(parts, cur)
  for i, p in ipairs(parts) do parts[i] = p:gsub("^%s+", ""):gsub("%s+$", "") end
  return parts
end

local function addList(add, label, text, bullet)
  if not text then return end
  local lbl, rest = text:match("^([^:]+): (.+)$")
  if label then lbl, rest = label, text end
  if lbl and #lbl <= 45 and rest then
    local parts = splitTop(rest)
    local hasParens = rest:find("(", 1, true)
    if #parts >= 4 or (#parts >= 3 and hasParens) then
      add(C.gold .. lbl .. ":" .. C.r)
      for _, p in ipairs(parts) do add("     - " .. p) end
      return
    end
    if label then add(C.gold .. lbl .. ": " .. C.r .. rest); return end
  end
  add((bullet and "• " or "") .. text)
end

-- Builds the expanded text of a step.
function ns.StepBody(step)
  local lines = {}
  local function add(s) if s then table.insert(lines, s) end end
  local state = ns.StepState(step)

  for _, b in ipairs(ns.StepBlockers(step)) do add(C.red .. b .. C.r) end

  local opt = ns.ChosenOption(step)
  if opt then
    local kind = opt.verb and (opt.verb .. ": ") or (opt.product and "Recipe: " or "Route: ")
    local hdr = C.gold .. kind .. C.r .. C.white .. (opt.product and opt.recipe or (opt.name or opt.recipe)) .. C.r
    if opt.count and opt.count > 1 then hdr = hdr .. C.grey .. "  (about " .. opt.count .. " crafts in all)" .. C.r end
    add(hdr)
    local prep = (state ~= "done") and ns.PrepSteps and ns.PrepSteps(step, opt)
    if opt.recipeFrom then addList(add, "Recipe from", ns.FText(opt.recipeFrom))
    elseif opt.product and not (prep and prep[1] and prep[1].kind == "recipe") then add(ns.LearnLine(step.skill, opt.recipe)) end
    if prep and #prep > 1 then
      -- "go to" steps in order: recipe, vendor, materials, craft
      add(C.gold .. "Step by step:" .. C.r)
      local first = true
      for i, p in ipairs(prep) do
        if p.done then
          add("   " .. CHECK .. " " .. C.grey .. p.text .. C.r)
        else
          add("   " .. (first and C.white or C.grey) .. i .. ". " .. C.r .. (first and C.white or "") .. p.text .. (first and C.r or ""))
          if p.hint then add("        " .. C.grey .. p.hint .. C.r) end
          first = false
        end
      end
    end
    if opt.mats and state == "done" then
      -- finished steps still list what the recipe takes, so you can plan ahead
      add(C.gold .. "Materials per craft:" .. C.r)
      for _, m in ipairs(opt.mats) do
        local line = "   " .. ns.IconText(m[1]) .. "  " .. ns.ItemName(m[1]) .. "  " .. C.white .. "x" .. m[2] .. C.r
        if opt.count and opt.count > 1 then line = line .. C.grey .. "  (" .. (opt.count * m[2]) .. " for the whole step)" .. C.r end
        add(line)
      end
    elseif opt.mats then
      local needs = ns.OptionNeeds(step, opt)
      for k, n in ipairs(needs) do
        if not opt.count and k > 1 then
          add("   " .. ns.IconText(n.id) .. "  " .. ns.ItemName(n.id) .. ": " .. C.white .. ns.Count(n.id) .. C.r .. " in bags (one per craft)")
        elseif opt.count then
          local per = opt.mats[k] and opt.mats[k][2]
          add("   " .. ns.IconText(n.id) .. "  " .. ns.ItemName(n.id) .. "  " .. ns.Have(n.id, n.need)
            .. (per and (C.grey .. "  (" .. per .. " per craft)" .. C.r) or ""))
        else
          add("   " .. ns.IconText(n.id) .. "  " .. ns.ItemName(n.id) .. ": " .. C.white .. ns.Count(n.id) .. C.r .. " in bags. Cook them all.")
        end
      end
      if step.kind == "level" and state == "current" and opt.count then
        local left = ns.CraftsLeft(step, opt)
        if opt.count > 1 then add(C.yellow .. "About " .. left .. (left == 1 and " craft" or " crafts") .. " left" .. C.r) end
      end
    end
    if opt.buy and state ~= "done" then
      add(C.gold .. (opt.buyLabel or step.guide.buyLabel or "Buy on the Auction House:") .. C.r)
      for _, b in ipairs(opt.buy) do
        add("   " .. ns.IconText(b.id) .. "  " .. ns.ItemName(b.id) .. "  " .. ns.Have(b.id, b.count))
      end
    end
    for _, n in ipairs(opt.notes or {}) do
      local t = ns.FText(n)
      if t then add("• " .. t) end
    end
  end

  if step.catch and state ~= "done" then
    add(C.gold .. (step.guide.catchLabel or "You'll catch:") .. C.r)
    for _, c in ipairs(step.catch) do
      local s = "   " .. ns.IconText(c[1]) .. "  " .. ns.ItemName(c[1]) .. ": " .. C.white .. ns.Count(c[1]) .. C.r .. " in bags"
      if #step.catch > 3 then s = "   " .. ns.IconText(c[1]) .. "  " .. ns.ItemName(c[1]) .. " " .. C.grey .. "(" .. ns.Count(c[1]) .. ")" .. C.r end
      if c[2] and c[2] > 0 then s = s .. C.grey .. " (about " .. c[2] .. " expected)" .. C.r end
      add(s)
    end
  end
  if step.lure then add(C.gold .. "Lure: " .. C.r .. ns.IconText(step.lure) .. "  " .. ns.ItemName(step.lure) .. "  " .. C.grey .. "(" .. ns.Count(step.lure) .. " in bags)" .. C.r) end

  if step.gather then
    add(" ")
    add(C.gold .. "Have before you go:" .. C.r)
    for _, g in ipairs(step.gather) do
      local note = ns.FText(g.note)
      add("   " .. ns.IconText(g.id) .. "  " .. ns.ItemName(g.id) .. "  " .. ns.Have(g.id, g.count) .. (note and (C.grey .. "  " .. note .. C.r) or ""))
    end
  end
  if step.buy then
    add(C.gold .. "Buy:" .. C.r)
    for _, b in ipairs(step.buy) do
      local note = ns.FText(b.note)
      add("   " .. ns.IconText(b.id) .. "  " .. ns.ItemName(b.id) .. "  " .. ns.Have(b.id, b.count) .. (note and (C.grey .. "  " .. note .. C.r) or ""))
    end
  end
  for _, n in ipairs(step.notes or {}) do
    local t = ns.FText(n)
    if t then addList(add, nil, t, true) end
  end
  return table.concat(lines, "\n")
end


function ns.RangeText(step)
  if step.kind == "level" then return step.from .. "-" .. step.to end
  if step.kind == "train" then return "cap " .. step.max end
  if step.kind == "quest" then return "quest" end
  return ""
end
