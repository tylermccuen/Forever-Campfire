-- Forever Profession Guide: shared namespace, saved settings, helpers.
local ADDON, ns = ...
ns.ADDON = ADDON
local getMeta = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
ns.VERSION = (getMeta and getMeta(ADDON, "Version")) or "dev"

ns.guides = {}       -- key -> guide
ns.guideOrder = {}   -- ordered keys (tab order)
ns.listeners = {}    -- functions called after every refresh

-- Every profession the addon knows about. A guide only needs to name its skill key.
-- "line" is the Blizzard skill line ID, used to find the profession regardless of client language.
ns.SKILLS = {
  cooking        = { line = 185, name = "Cooking" },
  fishing        = { line = 356, name = "Fishing" },
  firstaid       = { line = 129, name = "First Aid" },
  alchemy        = { line = 171, name = "Alchemy" },
  blacksmithing  = { line = 164, name = "Blacksmithing" },
  enchanting     = { line = 333, name = "Enchanting" },
  engineering    = { line = 202, name = "Engineering" },
  herbalism      = { line = 182, name = "Herbalism" },
  leatherworking = { line = 165, name = "Leatherworking" },
  mining         = { line = 186, name = "Mining" },
  skinning       = { line = 393, name = "Skinning" },
  tailoring      = { line = 197, name = "Tailoring" },
}

ns.RANK_NAMES = { [75] = "Apprentice", [150] = "Journeyman", [225] = "Expert", [300] = "Artisan" }

local DEFAULTS = {
  tracker = true,        -- small on-screen tracker
  trackerLocked = false,
  tooltips = true,       -- "needed for step X" lines in item tooltips
  announce = true,       -- chat message when a step finishes
  vendorAlerts = true,   -- chat message when a vendor sells something the route needs
  includeBank = false,   -- count bank items as "have"
  hideDone = false,      -- hide finished steps in the list
  showAll = false,
  mapPins = true,        -- draw the current step's pins on the world map       -- show tabs for professions you haven't learned
  trackerScale = 1,
  minimap = { hide = false, angle = 200 },
  minigame = true,       -- Sizzle! mini-game while crafting
  minigameBest = 0,
}

local CHAR_DEFAULTS = {
  activeGuide = nil,     -- tab last opened
  trackerGuide = "auto", -- "auto" follows the skill you last leveled
  lastActive = nil,
  choice = {},           -- [guideKey.."/"..stepId] = option index
  expanded = {},
}

local function fill(dst, src)
  for k, v in pairs(src) do
    if dst[k] == nil then
      if type(v) == "table" then dst[k] = {}; fill(dst[k], v) else dst[k] = v end
    elseif type(v) == "table" and type(dst[k]) == "table" then
      fill(dst[k], v)
    end
  end
end

function ns.InitDB()
  ForeverProfGuideDB = ForeverProfGuideDB or {}
  ForeverProfGuideCharDB = ForeverProfGuideCharDB or {}
  fill(ForeverProfGuideDB, DEFAULTS)
  fill(ForeverProfGuideCharDB, CHAR_DEFAULTS)
  ns.db = ForeverProfGuideDB
  ns.char = ForeverProfGuideCharDB
end

-- Guides register themselves from the Data files.
function ns.RegisterGuide(g)
  assert(g.key and g.steps, "guide needs key and steps")
  ns.guides[g.key] = g
  table.insert(ns.guideOrder, g.key)
  for i, step in ipairs(g.steps) do
    step.index = i
    step.guide = g
    step.skill = step.skill or g.skills[1]
  end
end

-- Short constructors for crafting data files.
--   ns.Craft(id, from, to, title, options, notes, extra)  -> "level" step
--   ns.Opt(label, recipe, count, mats, extra)             -> one recipe option
--   ns.Train(id, max, title, skill, level, notes)         -> "train" step
local function merge(t, extra) if extra then for k, v in pairs(extra) do t[k] = v end end return t end
function ns.Craft(id, from, to, title, options, notes, extra)
  return merge({ id = id, kind = "level", from = from, to = to, title = title, options = options, notes = notes }, extra)
end
function ns.Opt(label, recipe, count, mats, extra)
  return merge({ label = label, recipe = recipe, product = recipe, count = count, mats = mats }, extra)
end
function ns.Train(id, max, title, skill, level, notes, extra)
  return merge({ id = id, kind = "train", max = max, title = title, requires = { skill = skill, level = level }, notes = notes }, extra)
end

---------------------------------------------------------------------------
-- Text helpers
---------------------------------------------------------------------------
ns.C = {
  gold = "|cffffd100", green = "|cff40ff40", red = "|cffff5050", grey = "|cff9d9d9d",
  white = "|cffffffff", blue = "|cff66bbff", orange = "|cffff9933", yellow = "|cffffff66",
  r = "|r",
}

function ns.Faction()
  if not ns.faction then
    ns.faction = UnitFactionGroup and UnitFactionGroup("player") or "Alliance"
    if ns.faction ~= "Horde" and ns.faction ~= "Alliance" then ns.faction = "Alliance" end
  end
  return ns.faction
end

-- A text value in the data can be:
--   "plain string"
--   { H = "horde text", A = "alliance text" }
--   { "text", f = "Horde" }   (only shown to that faction)
-- Returns nil when the entry is not for this faction.
function ns.FText(v)
  if v == nil then return nil end
  if type(v) == "string" then return v end
  local fac = ns.Faction()
  if v.f then
    if v.f == fac then return v[1] end
    return nil
  end
  if v.H or v.A then
    return (fac == "Horde") and v.H or v.A
  end
  return v[1]
end

function ns.Print(msg)
  local f = DEFAULT_CHAT_FRAME
  if f then f:AddMessage("|cff33ff99Profession Guide|r: " .. msg) end
end

---------------------------------------------------------------------------
-- Items: names, icons, counts
---------------------------------------------------------------------------
ns.Items = ns.Items or {}       -- filled by Data/Items.lua: id -> name
ns.itemByName = {}

-- Item references in the data are either an item ID or an exact item name.
-- ns.IdOf turns a known name into its ID (for icons and bank counts).
function ns.IdOf(ref)
  if type(ref) == "number" then return ref end
  if not ns.idByName then
    ns.idByName = {}
    for id, name in pairs(ns.Items) do ns.idByName[name] = id end
  end
  return ns.idByName[ref]
end

function ns.ItemName(id)
  if type(id) == "string" then return id end
  local n = ns.Items[id]
  if not n and C_Item and C_Item.GetItemNameByID then n = C_Item.GetItemNameByID(id) end
  return n or ("item " .. tostring(id))
end

function ns.ItemIcon(id)
  if type(id) == "string" then
    local known = ns.IdOf(id)
    if known then id = known
    else
      local ok, icon = pcall(function() return C_Item and C_Item.GetItemIconByID and C_Item.GetItemIconByID(id) end)
      return (ok and icon) or 134400
    end
  end
  local icon
  if C_Item and C_Item.GetItemIconByID then icon = C_Item.GetItemIconByID(id)
  elseif GetItemIcon then icon = GetItemIcon(id) end
  return icon or 134400 -- question mark
end

function ns.IconText(id, size)
  return "|T" .. tostring(ns.ItemIcon(id)) .. ":" .. (size or 14) .. "|t"
end

-- Bag scan: counts by item ID and by name, so a wrong ID in the data still
-- finds the item as long as the name matches.
ns.bagById, ns.bagByName = {}, {}

function ns.ScanBags()
  local byId, byName = {}, {}
  local lastBag = (NUM_TOTAL_EQUIPPED_BAG_SLOTS or NUM_BAG_SLOTS or 4)
  if C_Container and C_Container.GetContainerNumSlots then
    for bag = 0, lastBag do
      local slots = C_Container.GetContainerNumSlots(bag) or 0
      for slot = 1, slots do
        local info = C_Container.GetContainerItemInfo(bag, slot)
        if info and info.itemID then
          local n = info.stackCount or 1
          byId[info.itemID] = (byId[info.itemID] or 0) + n
          local name = info.hyperlink and info.hyperlink:match("%[(.-)%]")
          if name then byName[name] = (byName[name] or 0) + n end
        end
      end
    end
  end
  ns.bagById, ns.bagByName = byId, byName
end

local function apiCount(id, bank)
  if C_Item and C_Item.GetItemCount then return C_Item.GetItemCount(id, bank) or 0 end
  if GetItemCount then return GetItemCount(id, bank) or 0 end
  return 0
end

function ns.Count(ref)
  local id = ns.IdOf(ref)
  if not id then
    -- name only: bags by name (bank not countable without an ID)
    return ns.bagByName[ref] or 0
  end
  local have = ns.bagById[id]
  if not have or have == 0 then
    local name = ns.Items[id]
    have = (name and ns.bagByName[name]) or 0
  end
  if ns.db and ns.db.includeBank then
    local bank = apiCount(id, true) - apiCount(id, false)
    if bank > 0 then have = have + bank end
  end
  return have
end

function ns.IsVendorItem(ref)
  local id = ns.IdOf(ref)
  return (id and ns.VendorItems[id]) or (type(ref) == "string" and ns.VendorNames[ref]) or false
end

function ns.Have(id, need)
  local have = ns.Count(id)
  local col = (have >= need) and ns.C.green or ns.C.red
  return col .. have .. "/" .. need .. ns.C.r, have
end
