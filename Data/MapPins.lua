-- Map pins for the Fishing, Cooking and Fish + Cook guides.
-- Drawn by the addon on the in-game world map (no images).
-- Coordinates checked 2026-11-24: trainers and vendors from two Forever trainer lists
-- that agree; Artisan quest fish from player reports.
--
-- P(zone, x, y, label, kind, faction, radius)
--   zone     exact in-game zone name ("Elwynn Forest", "Stormwind City")
--   kind     "npc" (trainer/vendor/quest), "spot" (fish here), "area" (fish anywhere in the circle)
--   faction  "Horde" / "Alliance" / nil for both
--   radius   for "area": circle radius in % of the map width
local _, ns = ...

local function P(zone, x, y, label, kind, faction, radius)
  return { zone = zone, x = x, y = y, label = label, kind = kind or "npc", f = faction, r = radius }
end
local H, A = "Horde", "Alliance"

-- Built the first time the world map draws pins (ns.Pins).
ns.Lazy("Pins", function()

-- Fishing trainers -----------------------------------------------------------
local FISH_TRAINERS = {
  P("Orgrimmar", 69.7, 29.3, "Lumak (Fishing trainer)", "npc", H),
  P("Undercity", 81.0, 29.5, "Armand Cromwell (Fishing trainer)", "npc", H),
  P("Thunder Bluff", 56.4, 47.6, "Kah Mistrunner (Fishing trainer)", "npc", H),
  P("Durotar", 53.2, 81.5, "Lau'Tiki (Fishing trainer)", "npc", H),
  P("Mulgore", 44.2, 63.9, "Uthan Stillwater (Fishing trainer)", "npc", H),
  P("Tirisfal Glades", 67.1, 51.0, "Clyde Kellen (Fishing trainer)", "npc", H),
  P("Stormwind City", 55.1, 69.6, "Arnold Leland (Fishing trainer)", "npc", A),
  P("Ironforge", 48.5, 6.2, "Grimnur Stonebrand (Fishing trainer)", "npc", A),
  P("Darnassus", 47.5, 56.5, "Astaia (Fishing trainer)", "npc", A),
  P("Elwynn Forest", 47.6, 62.3, "Lee Brown (Fishing trainer)", "npc", A),
  P("Dun Morogh", 35.6, 40.4, "Paxton Ganter (Fishing trainer)", "npc", A),
  P("Teldrassil", 55.8, 93.5, "Androl Oakhand (Fishing trainer)", "npc", A),
  P("Zephras Isle", 63.2, 75.7, "Baelann Swiftcurrent (Fishing trainer, supplies)"),
  P("Zephras Isle", 45.0, 48.4, "Fenn Fairweather (Fishing trainer)"),
}

-- Fishing supply vendors (pole and baubles) ---------------------------------------
local FISH_SUPPLY = {
  P("Durotar", 56.0, 73.4, "Zansoa (fishing supplies, Slitherskin recipe)", "npc", H),
  P("Mulgore", 46.6, 59.2, "Harn Longcast (fishing supplies, recipes)", "npc", H),
  P("Tirisfal Glades", 65.8, 59.6, "Martine Tramblay (fishing supplies, recipes)", "npc", H),
  P("Orgrimmar", 70.0, 29.4, "Shankys (fishing supplies)", "npc", H),
  P("Undercity", 81.2, 30.8, "Lizbeth Cromwell (fishing supplies, recipes)", "npc", H),
  P("Thunder Bluff", 55.8, 47.6, "Sewa Mistrunner (fishing supplies, recipes)", "npc", H),
  P("Elwynn Forest", 41.8, 67.0, "Tharynn Bouden (fishing supplies, recipes)", "npc", A),
  P("Teldrassil", 56.2, 92.4, "Nessa Shadowsong (fishing supplies, recipes)", "npc", A),
  P("Stormwind City", 45.8, 58.2, "Catherine Leland (fishing supplies, recipes)", "npc", A),
  P("Ironforge", 48.2, 8.2, "Tansy Puddlefizz (fishing supplies, recipes)", "npc", A),
  P("Loch Modan", 40.4, 39.4, "Khara Deepwater (fishing supplies, recipes)", "npc", A),
}

-- Fish right here: starting-zone trainers stand at the water -------------------------
local STARTER_WATER = {
  P("Durotar", 53.2, 81.5, "Fish here: the coast by Lau'Tiki", "spot", H),
  P("Mulgore", 44.2, 63.9, "Fish here: Stonebull Lake", "spot", H),
  P("Tirisfal Glades", 67.1, 51.0, "Fish here: Brightwater Lake", "spot", H),
  P("Elwynn Forest", 47.6, 62.3, "Fish here: Crystal Lake", "spot", A),
  P("Dun Morogh", 35.6, 40.4, "Fish here: Iceflow Lake", "spot", A),
  P("Teldrassil", 55.8, 93.5, "Fish here: Rut'theran Village shore", "spot", A),
  P("Zephras Isle", 63.2, 75.7, "Fish here: by the Valanaar trainer", "spot"),
  P("Zephras Isle", 45.0, 48.4, "Fish here: by the Shen'dar trainer", "spot"),
}

local CAPITAL_WATER = {
  P("Orgrimmar", 69.7, 29.3, "Fish here: Valley of Honor pond", "spot", H),
  P("Thunder Bluff", 56.4, 47.6, "Fish here: Thunder Bluff pond", "spot", H),
  P("Undercity", 81.0, 29.5, "Fish here: Undercity canals", "spot", H),
  P("Stormwind City", 55.1, 69.6, "Fish here: Stormwind canals", "spot", A),
  P("Darnassus", 47.5, 56.5, "Fish here: Temple Gardens", "spot", A),
  P("Ironforge", 48.5, 6.2, "Fish here: The Forlorn Cavern", "spot", A),
  P("Loch Modan", 40.5, 39.4, "Fish here: The Loch", "spot", A),
}

local BOOTY_BAY = {
  P("Stranglethorn Vale", 27.4, 77.0, "Old Man Heming (Expert Fishing book, Bright Baubles)"),
  P("Stranglethorn Vale", 27.5, 77.2, "Myizz Luckycatch (Fishing trainer)"),
  P("Stranglethorn Vale", 28.2, 74.4, "Kelsey Yance (Mithril Head Trout and Filet of Redgill recipes)"),
}

local NAT_PAGLE = P("Dustwallow Marsh", 58.6, 60.0, "Nat Pagle (Artisan Fishing quest)")
local QUEST_FISH = {
  NAT_PAGLE,
  P("Stranglethorn Vale", 34.0, 33.0, "Savage Coast Blue Sailfin", "area", nil, 2.5),
  P("Desolace", 25.0, 77.0, "Sar'theris Striker", "area", nil, 2.5),
  P("Swamp of Sorrows", 90.0, 72.0, "Misty Reed Mahi Mahi (stay in Misty Reed Strand)", "area", nil, 2.5),
  P("Feralas", 62.0, 52.0, "Feralas Ahi: Verdantis River (lure needed)", "area", nil, 2.5),
}

-- Cooking --------------------------------------------------------------------
local COOK_TRAINERS = {
  P("Orgrimmar", 57.4, 53.8, "Zamja (Cooking trainer)", "npc", H),
  P("Undercity", 62.6, 44.8, "Eunice Burch (Cooking trainer)", "npc", H),
  P("Thunder Bluff", 51.0, 52.3, "Aska Mistrunner (Cooking trainer)", "npc", H),
  P("Durotar", 51.1, 42.5, "Cook Torka (Cooking trainer)", "npc", H),
  P("Mulgore", 45.1, 61.5, "Pyall Silentstride (Cooking trainer)", "npc", H),
  P("Tirisfal Glades", 61.8, 51.5, "William Pickman (Cooking trainer)", "npc", H),
  P("Stormwind City", 78.3, 53.1, "Stephen Ryback (Cooking trainer)", "npc", A),
  P("Ironforge", 60.4, 38.1, "Daryl Riknussun (Cooking trainer)", "npc", A),
  P("Darnassus", 48.9, 21.3, "Alegorn (Cooking trainer)", "npc", A),
  P("Elwynn Forest", 44.3, 66.0, "Tomas (Cooking trainer)", "npc", A),
  P("Dun Morogh", 47.6, 52.4, "Gremlock Pilsnor (Cooking trainer)", "npc", A),
  P("Teldrassil", 57.1, 61.2, "Zarrin (Cooking trainer)", "npc", A),
  P("Zephras Isle", 60.6, 72.7, "Nyalah Brightfire (Cooking trainer)"),
  P("Zephras Isle", 43.8, 43.9, "Zerril Softbreeze (Cooking trainer)"),
}

local RECIPES_1_100 = {
  P("Thunder Bluff", 55.8, 47.6, "Sewa Mistrunner (Brilliant Smallfish)", "npc", H),
  P("Thunder Bluff", 51.0, 52.8, "Naal Mistrunner (Smallfish, Longjaw, Catfish)", "npc", H),
  P("Undercity", 81.2, 30.8, "Lizbeth Cromwell (Smallfish, Longjaw)", "npc", H),
  P("Undercity", 62.6, 43.6, "Ronald Burch (Smallfish, Albacore, Catfish)", "npc", H),
  P("Mulgore", 46.6, 59.2, "Harn Longcast (Smallfish, Longjaw)", "npc", H),
  P("Tirisfal Glades", 65.8, 59.6, "Martine Tramblay (Smallfish, Mackerel)", "npc", H),
  P("Durotar", 56.0, 73.4, "Zansoa (Mackerel, Albacore)", "npc", H),
  P("Orgrimmar", 70.0, 29.4, "Shankys (Albacore)", "npc", H),
  P("Silverpine Forest", 33.0, 17.8, "Killian Sanatha (Longjaw, Albacore)", "npc", H),
  P("Stormwind City", 45.8, 58.2, "Catherine Leland (Smallfish, Albacore, Catfish)", "npc", A),
  P("Elwynn Forest", 41.8, 67.0, "Tharynn Bouden (Smallfish, Longjaw)", "npc", A),
  P("Ironforge", 48.2, 8.2, "Tansy Puddlefizz (Mackerel, Longjaw)", "npc", A),
  P("Loch Modan", 40.4, 39.4, "Khara Deepwater (Smallfish, Longjaw)", "npc", A),
  P("Teldrassil", 57.2, 61.2, "Nyoma (Smallfish, Longjaw)", "npc", A),
  P("Teldrassil", 56.2, 92.4, "Nessa Shadowsong (Mackerel, Albacore)", "npc", A),
  P("Westfall", 36.2, 90.0, "Kriggon Talsone (Mackerel, Albacore)", "npc", A),
}

local RECIPES_CATFISH = {
  P("Thunder Bluff", 51.0, 52.8, "Naal Mistrunner (Bristle Whisker Catfish)", "npc", H),
  P("Undercity", 62.6, 43.6, "Ronald Burch (Bristle Whisker Catfish)", "npc", H),
  P("Hillsbrad Foothills", 63.0, 19.6, "Derak Nightfall (Bristle Whisker Catfish)", "npc", H),
  P("Stormwind City", 45.8, 58.2, "Catherine Leland (Bristle Whisker Catfish)", "npc", A),
  P("Hillsbrad Foothills", 50.6, 61.0, "Lindea Rabonne (Bristle Whisker Catfish)", "npc", A),
  P("The Barrens", 62.8, 38.2, "Kilxx in Ratchet (Bristle Whisker Catfish, Nightcrawlers)"),
}

local RECIPES_TROUT = {
  P("Orgrimmar", 70.0, 29.4, "Shankys (Mithril Head Trout)", "npc", H),
  P("Undercity", 81.2, 30.8, "Lizbeth Cromwell (Mithril Head Trout)", "npc", H),
  P("Ashenvale", 11.8, 34.0, "Wik'Tar (Mithril Head Trout)", "npc", H),
  P("Desolace", 26.2, 69.8, "Wulan (Mithril Head Trout)", "npc", H),
  P("Ironforge", 48.2, 8.2, "Tansy Puddlefizz (Mithril Head Trout)", "npc", A),
  P("Hillsbrad Foothills", 50.6, 61.0, "Lindea Rabonne (Mithril Head Trout)", "npc", A),
  P("Wetlands", 8.2, 58.6, "Stuart Fleming (Mithril Head Trout)", "npc", A),
  P("Darkshore", 37.0, 56.2, "Heldan Galesong (Mithril Head Trout)", "npc", A),
  P("Stranglethorn Vale", 28.2, 74.4, "Kelsey Yance (Mithril Head Trout, Filet of Redgill)"),
}

local EXPERT_COOKBOOK = {
  P("Desolace", 26.2, 69.8, "Wulan (Expert Cookbook), top floor of the eastern building", "npc", H),
  P("Ashenvale", 49.6, 67.0, "Shandrina (Expert Cookbook, Nightcrawlers)", "npc", A),
}

local CLAMLETTE = {
  P("Tanaris", 52.6, 28.1, "Dirge Quikcleave (Clamlette Surprise)"),
  P("Stormwind City", 66.4, 73.7, "Ben Trias (Alterac Swiss)", "npc", A),
}

local function join(...)
  local out = {}
  for _, list in ipairs({ ... }) do
    if list.zone then table.insert(out, list) else for _, p in ipairs(list) do table.insert(out, p) end end
  end
  return out
end

return {
  fishing = {
    learn  = join(FISH_TRAINERS, FISH_SUPPLY),
    f1     = STARTER_WATER,
    jm     = FISH_TRAINERS,
    f2     = join(CAPITAL_WATER, FISH_SUPPLY),
    expert = BOOTY_BAY,
    f3     = { NAT_PAGLE, P("Dustwallow Marsh", 58.6, 60.0, "Fish the swamp water around here, not the ocean", "area", nil, 6) },
    artisan = QUEST_FISH,
    f4     = { P("Feralas", 62.0, 52.0, "Verdantis River (any Feralas water except Jademir Lake)", "area", nil, 3),
               P("Feralas", 46.3, 41.7, "Vivianna (Bright Baubles)", "npc", A),
               P("The Hinterlands", 80.5, 81.5, "Katoom the Angler (fishing supplies)", "npc", H) },
  },
  cooking = {
    learn = COOK_TRAINERS,
    c1 = RECIPES_1_100,
    jm = COOK_TRAINERS,
    c2 = RECIPES_1_100,
    c3 = RECIPES_CATFISH,
    expert = EXPERT_COOKBOOK,
    c4 = COOK_TRAINERS,
    c5 = RECIPES_TROUT,
    artisan = CLAMLETTE,
    c6 = { P("Stranglethorn Vale", 28.2, 74.4, "Kelsey Yance (Filet of Redgill)") },
  },
  both = {
    learnf = join(STARTER_WATER, FISH_SUPPLY),
    f75 = STARTER_WATER,
    fjm = FISH_TRAINERS,
    f130 = join(CAPITAL_WATER, RECIPES_CATFISH, { P("Stormwind City", 66.4, 73.7, "Ben Trias (Alterac Swiss)", "npc", A) }),
    learnc = COOK_TRAINERS,
    cjm = COOK_TRAINERS,
    fexp = BOOTY_BAY,
    f205 = { P("Stonetalon Mountains", 45.0, 59.0, "Kulwia in Sun Rock Retreat (Nightcrawlers)", "npc", H),
             P("Desolace", 26.2, 69.8, "Wulan (Expert Cookbook)", "npc", H),
             P("Ashenvale", 49.6, 67.0, "Shandrina (Expert Cookbook, Nightcrawlers)", "npc", A),
             P("Ashenvale", 49.6, 67.0, "Fish here: Mystral Lake", "spot", A) },
    f225 = { NAT_PAGLE, P("Dustwallow Marsh", 58.6, 60.0, "Fish the swamp water around here, not the ocean", "area", nil, 6),
             P("The Barrens", 62.8, 38.2, "Kilxx in Ratchet (Nightcrawlers)", "npc", H) },
    fart = QUEST_FISH,
    f255 = { P("Dustwallow Marsh", 58.6, 60.0, "Keep fishing the swamp water, not the ocean", "area", nil, 6) },
    cart = { P("Tanaris", 52.6, 28.1, "Dirge Quikcleave (Clamlette Surprise)") },
    f300 = { P("Feralas", 62.0, 52.0, "Verdantis River (any Feralas water except Jademir Lake)", "area", nil, 3),
             P("Feralas", 46.3, 41.7, "Vivianna (Bright Baubles)", "npc", A) },
  },
}
end)

-- Pins for a step, for this character's faction.
function ns.StepPins(step)
  local g = ns.Pins[step.guide.key]
  local list = g and g[step.id]
  if not list then return nil end
  local fac, out = ns.Faction(), {}
  for _, p in ipairs(list) do
    if not p.f or p.f == fac then table.insert(out, p) end
  end
  return (#out > 0) and out or nil
end
