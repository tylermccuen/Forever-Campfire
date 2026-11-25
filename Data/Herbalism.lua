-- Herbalism 1-300 for WoW Forever.
-- Route checked 2026-11-24.
-- Step format: see Data/Cooking.lua and Data/Mining.lua.
local _, ns = ...

-- The header is all the addon needs until this guide is opened or its
-- profession is learned; the rest is built on first use.
ns.LazyGuide({
  key = "herbalism",
  capitalTrainer = { H = "Jandi in Orgrimmar", A = "Tannysa in Stormwind" },
  name = "Herbalism",
  skills = { "herbalism" },
  icon = "Interface\\Icons\\Spell_Nature_NatureTouchGrow",
}, function()
local TRAINERS = {
  H = "Trainers: Jandi (Orgrimmar), Martha Alliestar (Undercity), Komin Winterhoof (Thunder Bluff), Mishiki (Sen'jin Village), Faruza (Brill)",
  A = "Trainers: Tannysa (Stormwind), Reyna Stonebranch (Ironforge), Firodren Mooncaller (Darnassus), Herbalist Pomeroy (Elwynn Forest), Malorne Bladeleaf (Dolanaar)",
}

ns.RegisterGuide({
  key = "herbalism",
  checked = "2026-11-24",
  gatherVerb = "Pick herbs",
  catchLabel = "You'll gather:",
  tracking = "Find Herbs",
  rankUps = {
    [75]  = { name = "Journeyman Herbalism", skill = 50, how = "Train it at a main Herbalism trainer (starting-zone trainers stop at 75)" },
    [150] = { name = "Expert Herbalism", skill = 125, how = "Train it at a main Herbalism trainer" },
    [225] = { name = "Artisan Herbalism", skill = 200, how = "Train it at a main Herbalism trainer" },
  },
  steps = {
    { id = "learn", kind = "learn", title = "Learn Herbalism",
      notes = {
        "A city guard can mark the Herbalism trainer on your map.",
        TRAINERS,
        "Zephras Isle: do the quest Harvesting Windstones in Thendal Village and pick Wild Harvest.",
        "Turn on Find Herbs in the Professions window. It turns off when you die, and you can't track minerals at the same time.",
        "No tool needed.",
      } },

    { id = "h1", kind = "level", from = 1, to = 70, title = "Pick herbs in your starting zone",
      catch = { { 2447, 0 }, { 765, 0 }, { 2449, 0 } },
      notes = {
        { H = "Where: Durotar, Mulgore, Tirisfal Glades, Zephras Isle", A = "Where: Elwynn Forest, Dun Morogh, Teldrassil, Zephras Isle" },
        "Earthroot from 15.",
        "Respawns are fast. Without a mount, just pick what you see.",
      } },

    { id = "jm", kind = "train", max = 150, title = "Train Journeyman Herbalism", requires = { skill = 50 },
      notes = { "Starting-zone trainers only teach up to 75. Use a main trainer.", TRAINERS } },

    { id = "h2", kind = "level", from = 70, to = 115, title = "Pick in Silverpine, Loch Modan or Darkshore",
      catch = { { 785, 0 }, { 2450, 0 }, { 3820, 0 } },
      notes = {
        "Stranglekelp from 85.",
        "Silverpine Forest: run small circles in the south. Fast respawns.",
        "Loch Modan: an easy route, a few fewer herbs than Darkshore.",
        "Darkshore: herbs everywhere.",
      } },

    { id = "exp", kind = "train", max = 225, title = "Train Expert Herbalism", requires = { skill = 125 },
      notes = { TRAINERS } },

    { id = "h3", kind = "level", from = 115, to = 170, title = "Pick in Hillsbrad Foothills or Stonetalon",
      catch = { { 2453, 0 }, { 3355, 0 }, { 3356, 0 }, { 3357, 0 } },
      notes = {
        "Kingsblood from 125, Liferoot from 150.",
        "Hillsbrad Foothills: run the full loop so herbs have time to respawn.",
        "The lowest-level area has mobs around level 14-15. Busier areas have more Kingsblood.",
      } },

    { id = "h4", kind = "level", from = 170, to = 205, title = "Pick in Stranglethorn Vale or Arathi Highlands",
      catch = { { 3356, 0 }, { 3357, 0 }, { 3818, 0 }, { 3821, 0 }, { 3358, 0 } },
      notes = { "Khadgar's Whisker from 185." } },

    { id = "art", kind = "train", max = 300, title = "Train Artisan Herbalism", requires = { skill = 200 },
      notes = { "Train it before leaving: Tanaris and Searing Gorge have no trainer.", TRAINERS } },

    { id = "h5", kind = "level", from = 205, to = 230, title = "Pick in Tanaris or Searing Gorge",
      catch = { { 8831, 0 }, { 4625, 0 } },
      notes = { "Neither zone has a Herbalism trainer." } },

    { id = "h6", kind = "level", from = 230, to = 270, title = "Pick in The Hinterlands",
      catch = { { 8838, 0 }, { 8831, 0 }, { 8845, 0 }, { 13464, 0 } },
      notes = { "Ghost Mushroom from 245, in the cave." } },

    { id = "h7", kind = "level", from = 270, to = 300, title = "Pick in Felwood",
      catch = { { 8838, 0 }, { 8846, 0 }, { 13464, 0 }, { 13463, 0 }, { 13465, 0 }, { 13466, 0 } },
      notes = {
        "Short a few points for a herb? Goldthorn Tea gives +15 Herbalism (recipe from Henry Stern in Razorfen Downs, Cooking 175).",
        "Other bonuses: Enchant Gloves - Herbalism (+2) or Advanced Herbalism (+5), Herbalist's Gloves (+5).",
      } },
  },
})
end)
