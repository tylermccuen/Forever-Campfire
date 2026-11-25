-- Mining 1-300 for WoW Forever.
-- Route checked 2026-11-24.
-- Step format: see Data/Cooking.lua. Gathering guides also use:
--   gatherVerb  word for the NOW box ("Mine until Mining 65")
--   catchLabel  heading for the `catch` list
--   tool        item that must be in your bags
--   tracking    name of the tracking ability to switch on
--   option.name / option.verb / option.now / option.buy  (see README)
local _, ns = ...

-- The header is all the addon needs until this guide is opened or its
-- profession is learned; the rest is built on first use.
ns.LazyGuide({
  key = "mining",
  capitalTrainer = { H = "Makaru in Orgrimmar", A = "Gelman Stonehand in Stormwind" },
  name = "Mining",
  skills = { "mining" },
  icon = "Interface\\Icons\\Trade_Mining",
}, function()
local TRAINERS = {
  H = "Trainers: Makaru (Orgrimmar), Brom Killian (Undercity), Brek Stonehoof (Thunder Bluff), Krunn (Razor Hill)",
  A = "Trainers: Gelman Stonehand (Stormwind), Geofram Bouldertoe (Ironforge), Yarr Hammerstone (Steelgrill's Depot), Kurdram Stonehammer (Auberdine)",
}
local PICKS = {
  H = "Mining Pick: Flakk (Razor Hill), Wunna Darkmane (Bloodhoof Village), Abigail Shiel (Brill), Gorina (Valley of Honor), Elizabeth Van Talen (Rogues' Quarter), Kurm Stonehoof (Thunder Bluff)",
  A = "Mining Pick: Tharynn Bouden (Goldshire), Thrawn Boltar (Kharanos), Narret Shadowgrove (Dolanaar), Brooke Stonebraid (Stormwind), Thurgrum Deepforge (Ironforge), Mythrin'dir (Darnassus)",
}

ns.RegisterGuide({
  key = "mining",
  checked = "2026-11-24",
  gatherVerb = "Mine",
  catchLabel = "You'll gather:",
  tool = 2901,
  tracking = "Find Minerals",
  rankUps = {
    [75]  = { name = "Journeyman Mining", skill = 50, how = "Train it at a main Mining trainer (starting-zone trainers stop at 75)" },
    [150] = { name = "Expert Mining", skill = 125, how = "Train it at a main Mining trainer" },
    [225] = { name = "Artisan Mining", skill = 200, how = "Train it at a main Mining trainer" },
  },
  steps = {
    { id = "learn", kind = "learn", title = "Learn Mining, buy a Mining Pick",
      notes = {
        "Every capital has a Mining trainer except Darnassus. A guard can mark it on your map.",
        TRAINERS,
        "Zephras Isle: do the quest Harvesting Windstones in Thendal Village and pick Mining for Dummies.",
        PICKS,
        "The pick only needs to be in your bags.",
        "Turn on Find Minerals in the Professions window. It turns off when you die, and you can't track herbs at the same time.",
      },
      buy = { { id = 2901, count = 1 } } },

    { id = "m1", kind = "level", from = 1, to = 65, title = "Mine Copper",
      catch = { { 2770, 0 } },
      options = {
        { label = "A", name = "Mine it yourself", recipe = "Mine it yourself",
          notes = {
            { H = "Best zone: Durotar. Smelt at Razor Hill after one or two laps.", A = "Best zone: Elwynn Forest. Smelt in Goldshire after one lap." },
            { "Durotar has a cave with 5 Copper Veins that respawn very fast.", f = "Horde" },
            { "Also good: Mulgore (forge at Bael'dun Digsite, watch for hostile dwarves) or Tirisfal Glades (smelt in Brill).", f = "Horde" },
            { "Also good: Dun Morogh (smelt in Kharanos; both caves respawn very fast).", f = "Alliance" },
            { "Teldrassil has no forge. The nearest is the Warrior's Terrace in Darnassus.", f = "Alliance" },
            "Zephras Isle (both factions): veins respawn very fast. Smelt at Shen'dar Village.",
          } },
        { label = "B", name = "Smelt Auction House ore", verb = "Smelt", recipe = "Copper Bars", product = 2840, count = 140, mats = { { 2770, 1 } },
          notes = { "Faster if you have gold: bar and ore prices are often close.", "Keep 70 Copper Bars for Bronze later." } },
      } },

    { id = "jm", kind = "train", max = 150, title = "Train Journeyman Mining", requires = { skill = 50 },
      notes = { "Starting-zone trainers only teach up to 75. Use a main trainer.", TRAINERS } },

    { id = "m2", kind = "level", from = 65, to = 125, title = "Mine Tin and Silver",
      catch = { { 2771, 0 }, { 2775, 0 } },
      options = {
        { label = "A", name = "Mine it yourself", recipe = "Mine it yourself",
          notes = {
            "Tin Veins from 65, Silver Veins from 75.",
            { H = "Best: the Silverpine Forest cave (mobs level 21-22) or Hillsbrad Foothills (mobs 22-26).",
              A = "Best: the Wetlands cave, by far. Tin and Incendicite respawn very fast. Mobs are about level 20." },
            "Also fine: Westfall cave, The Barrens, Ashenvale (quiet), Stonetalon Mountains.",
            "Mobs respawn fast too, so it helps to outlevel them.",
            "Smelt your Copper and Tin and make Bronze before leaving. Bronze stops giving points around 105.",
          } },
        { label = "B", name = "Smelt Auction House ore", verb = "Smelt",
          now = "Smelt Tin, then Bronze, then Silver. Details in the step below.",
          buy = { { id = 2771, count = 70 }, { id = 2775, count = 45 } },
          notes = {
            "65-75: learn Smelt Tin and Smelt Bronze. Smelt all 70 Tin Bars, even after the recipe turns grey at 75.",
            "75-105: smelt 70 Bronze Bars from your Copper and Tin Bars. Buy extra if you stop short.",
            "105-120: learn Smelt Silver and smelt 35-45 Silver Bars.",
            "From 120, mine Iron instead. The last few Silver points are expensive.",
          } },
      } },

    { id = "exp", kind = "train", max = 225, title = "Train Expert Mining", requires = { skill = 125 },
      notes = { TRAINERS } },

    { id = "m3", kind = "level", from = 125, to = 175, title = "Mine Iron and Gold",
      catch = { { 2772, 0 }, { 2776, 0 } },
      notes = {
        "Iron Deposits from 125, Gold Veins from 155.",
        "Around level 30, Thousand Needles is the safest.",
        "Higher level or mounted: Arathi Highlands. Check the back of each cave.",
        { "Low-level Alliance players: go around Hammerfall to the south.", f = "Alliance" },
        "Optional: smelt about 20 Iron Ore to 135 first.",
        "At 155, learn Smelt Gold. About 22 Gold Ore takes you to 175. Each bar gives a point until 170.",
      } },

    { id = "m4", kind = "level", from = 175, to = 225, title = "Mine Mithril",
      catch = { { 3858, 0 } },
      notes = {
        "Mithril Deposits from 175.",
        "Where: The Hinterlands or Tanaris.",
        "The Hinterlands: skip the elite route if you're below level 60.",
        "Tanaris: below level 60, skip the four marked caves.",
      } },

    { id = "art", kind = "train", max = 300, title = "Train Artisan Mining", requires = { skill = 200 },
      notes = { "Train it before you reach 225, or you'll have to fly back.", TRAINERS } },

    { id = "m5", kind = "level", from = 225, to = 245, title = "Mine Mithril and Truesilver",
      catch = { { 3858, 0 }, { 7911, 0 } },
      notes = { "Truesilver Deposits from 230.", "Same zones: The Hinterlands or Tanaris." } },

    { id = "m6", kind = "level", from = 245, to = 275, title = "Mine Small Thorium",
      catch = { { 10620, 0 }, { 7911, 0 } },
      notes = {
        "Small Thorium Veins from 245.",
        "Where: Un'Goro Crater, Blasted Lands or Felwood.",
        "Un'Goro caves are full of mobs. Go in only at 60 with good gear, or with stealth.",
        { "You can't mine inside the Garrison Armory in Blasted Lands.", f = "Alliance" },
        "Felwood: the small marked cave is worth it. Skip the Jaedenar caves.",
      } },

    { id = "m7", kind = "level", from = 275, to = 300, title = "Mine Rich Thorium",
      catch = { { 10620, 0 } },
      notes = {
        "Rich Thorium Veins from 275.",
        "Where: Un'Goro Crater, Burning Steppes, Eastern Plaguelands or Winterspring.",
        "Un'Goro: skip the elite stretch unless you have stealth.",
        "Burning Steppes caves are full of level 50 mobs.",
      } },
  },
})
end)
