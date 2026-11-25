-- Skinning 1-300 for WoW Forever.
-- Route checked 2026-11-24.
-- Step format: see Data/Cooking.lua and Data/Mining.lua.
local _, ns = ...

-- The header is all the addon needs until this guide is opened or its
-- profession is learned; the rest is built on first use.
ns.LazyGuide({
  key = "skinning",
  capitalTrainer = { H = "Thuwd in Orgrimmar", A = "Maris Granger in Stormwind" },
  name = "Skinning",
  skills = { "skinning" },
  icon = "Interface\\Icons\\INV_Misc_Pelt_Wolf_01",
}, function()
local TRAINERS = {
  H = "Trainers: Thuwd (Orgrimmar), Killian Hagey (Undercity), Mooranta (Thunder Bluff), Yonn Deepcut (Bloodhoof Village), Rand Rhobart (Tirisfal Glades)",
  A = "Trainers: Maris Granger (Stormwind), Balthus Stoneflayer (Ironforge), Eladriel (Darnassus), Helene Peltskinner (Goldshire), Radnaal Maneweaver (Teldrassil)",
}

ns.RegisterGuide({
  key = "skinning",
  checked = "2026-11-24",
  gatherVerb = "Skin",
  catchLabel = "You'll gather:",
  tool = 7005,
  rankUps = {
    [75]  = { name = "Journeyman Skinning", skill = 50, how = "Train it at a main Skinning trainer (starting-zone trainers stop at 75)" },
    [150] = { name = "Expert Skinning", skill = 125, how = "Train it at a main Skinning trainer" },
    [225] = { name = "Artisan Skinning", skill = 200, how = "Train it at a main Skinning trainer" },
  },
  steps = {
    { id = "learn", kind = "learn", title = "Learn Skinning, buy a Skinning Knife",
      notes = {
        TRAINERS,
        "Zephras Isle: do the quest Harvesting Windstones in Thendal Village and pick Pelt Collecting for Beginners.",
        "Skinning Knife: Leatherworking Supply vendors near your trainer, or most General Goods vendors. It only needs to be in your bags.",
        "Rule of thumb: from mob level 20, you need 5 times the mob's level. Hover a beast to see what it needs.",
        { "The Barrens quest Unwelcome Guests can reward a Keen Skinning Knife (+3).", f = "Horde" },
      },
      buy = { { id = 7005, count = 1 } } },

    { id = "s1", kind = "level", from = 1, to = 75, title = "Skin in your starting zone",
      catch = { { 2934, 0 }, { 2318, 0 }, { 783, 0 } },
      notes = {
        "Skin everything you kill while leveling there.",
        "Catching up on a higher-level character? Mottled Boars in the Valley of Trials (Durotar), or Young Wolves and Timber Wolves in Northshire Valley.",
      } },

    { id = "jm", kind = "train", max = 150, title = "Train Journeyman Skinning", requires = { skill = 50 },
      notes = { "Starting-zone trainers only teach up to 75. Use a main trainer.", TRAINERS } },

    { id = "s2", kind = "level", from = 75, to = 130, title = "Skin in The Barrens or Loch Modan",
      catch = { { 2318, 0 }, { 2319, 0 } },
      options = {
        { label = "A", name = "The Barrens", recipe = "The Barrens",
          notes = {
            "West of Northwatch Hold: Sunscale Scytheclaw, Zhevra Charger and Ornery Plainstrider.",
            "Kill level 16-17 mobs until 80, then add level 18 ones.",
            "You can stay here all the way to 150. The last 10 points are green, but respawns are fast.",
          } },
        { label = "B", name = "Loch Modan", recipe = "Loch Modan",
          notes = {
            "Elder Mountain Boar, Black Bear Patriarch and Loch Crocolisk (level 16-17).",
            "Loch Crocolisks are skinnable. Pull them when you reach the shore.",
            "Stay until 130: most Wetlands raptors need 130.",
          } },
      } },

    { id = "s3", kind = "level", from = 130, to = 150, title = "Skin Wetlands raptors",
      catch = { { 2319, 0 } },
      notes = { "Mottled Scytheclaws and Mottled Razormaws (level 25-27).", "Go to Whelgar's Excavation Site. A few are always there." } },

    { id = "exp", kind = "train", max = 225, title = "Train Expert Skinning", requires = { skill = 125 },
      notes = { "Train it before you reach 150.", TRAINERS } },

    { id = "s4", kind = "level", from = 150, to = 225, title = "Skin Hillsbrad yetis or Duskwood worgen",
      catch = { { 2319, 0 }, { 4234, 0 } },
      options = {
        { label = "A", name = "Hillsbrad Foothills", recipe = "Hillsbrad Foothills",
          notes = {
            { H = "Ride from Tarren Mill to the front of the yeti cave.", A = "Ride from Southshore to the front of the yeti cave." },
            "150-160: Vicious Gray Bears and Starving Mountain Lions outside (level 22-24).",
            "160-225: Cave Yetis and Ferocious Yetis inside Foothill Caverns (level 30-32). They respawn fast, so you can stay inside.",
          } },
        { label = "B", name = "Duskwood", recipe = "Duskwood",
          notes = {
            { H = "Reach Duskwood from Grom'gol.", A = "Duskwood: the Rotting Orchard." },
            "Nightbane Worgen, Shadow Weavers and Dark Runners (level 26-29).",
            "Clear outside and inside Roland's Doom, then the Rotting Orchard while they respawn.",
          } },
      } },

    { id = "art", kind = "train", max = 300, title = "Train Artisan Skinning", requires = { skill = 200 },
      notes = { "Train it before you reach 225.", TRAINERS } },

    { id = "s5", kind = "level", from = 225, to = 280, title = "Skin yetis in Feralas",
      catch = { { 4304, 0 } },
      notes = {
        { H = "Fly to Camp Mojache, then ride to Feral Scar Vale in southern Feralas.", A = "Fly to Feathermoon Stronghold, then ride to Feral Scar Vale in southern Feralas." },
        "Feral Scar Yetis, Enraged Feral Scars and Hulking Feral Scars (level 43-46).",
        "Hulking Feral Scars need 230.",
      } },

    { id = "s6", kind = "level", from = 280, to = 300, title = "Skin dinosaurs in Un'Goro Crater",
      catch = { { 4304, 0 }, { 8170, 0 } },
      notes = {
        "Fly to Marshal's Refuge and skin the dinosaurs in western Un'Goro.",
        "Diemetradons, Pterrordaxes, Elder Diemetradons and Frenzied Pterrordaxes (level 50-55).",
      } },
  },
})
end)
