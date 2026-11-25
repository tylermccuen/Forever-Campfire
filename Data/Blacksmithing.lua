-- Blacksmithing 1-300 for WoW Forever.
-- Route checked 2026-11-24.
local _, ns = ...

-- The header is all the addon needs until this guide is opened or its
-- profession is learned; the rest is built on first use.
ns.LazyGuide({
  key = "blacksmithing",
  capitalTrainer = { H = "Ug'thok in Orgrimmar", A = "Dane Lindgren in Stormwind" },
  name = "Blacksmithing",
  skills = { "blacksmithing" },
  icon = "Interface\\Icons\\Trade_BlackSmithing",
}, function()
local Craft, Opt, Train = ns.Craft, ns.Opt, ns.Train

local APPRENTICE = {
  H = "Trainers: Ug'thok (Orgrimmar), Basil Frye (Undercity), Thrag Stonehoof (Thunder Bluff), Dwukk (Razor Hill forge), Angus Hammerhand (Bandarion Keep, Tirisfal)",
  A = "Trainers: Dane Lindgren (Stormwind), Groum Stonebeard (Ironforge), Smith Argus (Goldshire), Tognus Flintfire (Kharanos), Delfrum Flintbeard (Auberdine)",
}
local JOURNEYMAN = {
  H = "Journeyman trainers: Snarl (Orgrimmar), James Van Brunt (Undercity), Karn Stonehoof (Thunder Bluff), Angus Hammerhand (Tirisfal), Daeann Steelwind (Valanaar)",
  A = "Journeyman trainers: Therum Deepforge (Stormwind), Rotgath Stonebeard (Ironforge), Daeann Steelwind (Valanaar)",
}

ns.RegisterGuide({
  key = "blacksmithing",
  checked = "2026-11-24",
  verb = "Make",
  buyLabel = "Materials for this step:",
  tool = 5956,
  rankUps = {
    [75]  = { name = "Journeyman Blacksmithing", skill = 50, level = 10, how = { H = "Snarl (Orgrimmar), James Van Brunt (Undercity) or Karn Stonehoof (Thunder Bluff)", A = "Therum Deepforge (Stormwind) or Rotgath Stonebeard (Ironforge)" } },
    [150] = { name = "Expert Blacksmithing", skill = 125, level = 20, how = { H = "Saru Steelfury in Orgrimmar (50 silver)", A = "Bengus Deepforge in Ironforge (50 silver)" } },
    [225] = { name = "Artisan Blacksmithing", skill = 200, level = 35, how = "Brikk Keencraft in Booty Bay" },
  },
  steps = {
    { id = "learn", kind = "learn", title = "Learn Blacksmithing, buy a hammer",
      notes = {
        "No level requirement. Every capital has a trainer except Darnassus.",
        APPRENTICE,
        "Zephras Isle: Daeann Steelwind (Valanaar) or Aedi Thriceforged (Shen'dar Village).",
        { H = "Blacksmith Hammer: Sumi (Orgrimmar), Samuel Van Brunt (Undercity), Taur Stonehoof (Thunder Bluff), Flakk (Razor Hill), Abigail Shiel (Brill)",
          A = "Blacksmith Hammer: Kaita Deepforge (Stormwind), Thurgrum Deepforge (Ironforge), Tharynn Bouden (Goldshire), Thrawn Boltar (Kharanos), Elisa Steelhand (Auberdine)" },
        { "Tirisfal: nobody near Angus Hammerhand sells the hammer, so buy one first.", f = "Horde" },
        "Mining pairs well: Blacksmithing uses a lot of ore.",
      },
      buy = { { id = 5956, count = 1 } } },

    Craft("s1", 1, 25, "Make Rough Sharpening Stones", { Opt("A", "Rough Sharpening Stone", 30, { { "Rough Stone", 1 } }) }),
    Craft("s2", 25, 50, "Make Rough Grinding Stones", { Opt("A", "Rough Grinding Stone", 30, { { "Rough Stone", 2 } }) },
      { "Keep 10 for Silver Rods at 75." }),
    Craft("s3", 50, 75, "Make Coarse Grinding Stones", { Opt("A", "Coarse Grinding Stone", 36, { { "Coarse Stone", 2 } }) },
      { "Make all 36 and keep them: bracers at 95 and 112 use them." }),
    Train("jm", 150, "Train Journeyman Blacksmithing", 50, 10, { JOURNEYMAN }),
    Craft("s4", 75, 80, "Make Silver Rods", {
      Opt("A", "Silver Rod", 5, { { "Silver Bar", 1 }, { "Rough Grinding Stone", 2 } }),
      Opt("B", "Runed Copper Belt", 5, { { "Copper Bar", 10 } }, { notes = { "Use this if a Silver Bar costs more than 10 Copper Bars." } }),
    }),
    Craft("s5", 80, 95, "Make Rough Bronze Leggings", { Opt("A", "Rough Bronze Leggings", 15, { { "Bronze Bar", 6 } }) }),
    Craft("s6", 95, 100, "Make Patterned Bronze Bracers", { Opt("A", "Patterned Bronze Bracers", 5, { { "Bronze Bar", 5 }, { "Coarse Grinding Stone", 2 } }) }),
    Craft("s7", 100, 112, "Make Heavy Grinding Stones", { Opt("A", "Heavy Grinding Stone", 20, { { "Heavy Stone", 3 } }) },
      { "Keep all 20 for Golden Scale Bracers at 180." }),
    Craft("s8", 112, 125, "Make more Patterned Bronze Bracers", { Opt("A", "Patterned Bronze Bracers", 13, { { "Bronze Bar", 5 }, { "Coarse Grinding Stone", 2 } }) }),
    Train("exp", 225, "Train Expert Blacksmithing", 125, 20,
      { { H = "Saru Steelfury in Orgrimmar (50 silver).", A = "Bengus Deepforge in Ironforge (50 silver)." }, "No skill points above 150 until you learn it." }),
    Craft("s9", 125, 140, "Make Silvered Bronze Gauntlets", {
      Opt("A", "Silvered Bronze Gauntlets", 15, { { "Bronze Bar", 8 }, { "Silver Bar", 1 }, { "Coarse Grinding Stone", 2 } },
        { notes = { "Make 30 more Coarse Grinding Stones first (60 Coarse Stone)." } }),
      Opt("B", "Bronze Warhammer", 15, { { "Bronze Bar", 8 }, { "Strong Flux", 1 }, { "Medium Leather", 1 } },
        { notes = { "Use this if Silver Bars are expensive. Strong Flux: the Blacksmithing Supply vendor by your trainer." } }),
    }),
    Craft("s10", 140, 175, "Make Green Iron Bracers", { Opt("A", "Green Iron Bracers", 40, { { "Iron Bar", 6 }, { "Green Dye", 1 } }) },
      { { H = "Only the Expert trainer teaches it. Green Dye: Tamar in Orgrimmar.", A = "Only the Expert trainer teaches it. Green Dye: Bombus Finespindle in Ironforge." } }),
    Craft("s11", 175, 180, "Make Solid Grinding Stones", { Opt("A", "Solid Grinding Stone", 8, { { "Solid Stone", 4 } }) },
      { "Keep all 8 for 210." }),
    Craft("s12", 180, 195, "Make Golden Scale Bracers", { Opt("A", "Golden Scale Bracers", 20, { { "Steel Bar", 5 }, { "Heavy Grinding Stone", 2 } }) },
      { "Use your 20 Heavy Grinding Stones, then make 20 more (60 Heavy Stone).",
        "Mining 165? Smelt your own Steel Bars from 1 Iron Bar and 1 Coal each. Coal: the Blacksmithing Supply vendor.",
        { "Keep 6 if you might pick Armorsmithing.", f = "Alliance" } }),
    Craft("s13", 195, 210, "Make Mithril Plate Pants", { Opt("A", "Mithril Plate Pants", 17, { { "Mithril Bar", 12 } }) },
      { "Vendors pay more for these than for Heavy Mithril Gauntlets.", "At 200 and level 40 you can pick Armorsmithing or Weaponsmithing. It's optional." }),
    Train("art", 300, "Train Artisan Blacksmithing", 200, 35, { "Brikk Keencraft in Booty Bay (both factions). Expert trainers don't teach the recipes after this." }),
    Craft("s14", 210, 225, "Make Mithril Spurs or Heavy Mithril gear", {
      Opt("A", "Mithril Spurs", 15, { { "Mithril Bar", 4 }, { "Solid Grinding Stone", 3 } },
        { notes = { "Needs Plans: Mithril Spurs (world drop, Auction House). Saves about 130 Thorium Bars and 150 Mithril Bars overall." } }),
      Opt("B", "Mithril Coif", 10, { { "Mithril Bar", 10 }, { "Mageweave Cloth", 6 } },
        { notes = { "No Spurs plans? Make 6 Heavy Mithril Axes to 215 (12 Mithril Bars, 2 Citrines, 1 Solid Grinding Stone and 4 Heavy Leather each), then Mithril Coifs to 225.",
                    "Only Brikk teaches the Coif. Keep 2 for Armorsmithing and 2 axes for Weaponsmithing." } }),
    }),
    Craft("s15", 225, 235, "Make Dense Sharpening Stones", { Opt("A", "Dense Sharpening Stone", 16, { { "Dense Stone", 1 } }) }),
    Craft("s16", 235, 245, "Make more Spurs, or Boots and a Belt", {
      Opt("A", "Mithril Spurs", 28, { { "Mithril Bar", 4 }, { "Solid Grinding Stone", 3 } }),
      Opt("B", "Heavy Mithril Boots", 11, { { "Mithril Bar", 14 }, { "Thick Leather", 4 } },
        { notes = { "Heavy Mithril Boots to 240 (keep 2 for Armorsmithing), then 5 Imperial Plate Belts to 245 (22 Thorium Bars, 6 Rugged Leather and 1 Aquamarine each).",
                    "The Imperial Plate Belt comes from a quest from Derotain Mudsipper in Tanaris (level 50). Do A Blue Light Bargain first. Bring 40 Thorium Bars for both the belt and bracer quests." } }),
    }),
    Craft("s17", 245, 270, "Make Imperial Plate Bracers", { Opt("A", "Imperial Plate Bracers", 27, { { "Thorium Bar", 20 }, { "Star Ruby", 1 } }) },
      { "From the Imperial Plate Bracers quest from Derotain Mudsipper in Tanaris (level 50). The quest takes 20 Thorium Bars.",
        "Have Plans: Thorium Belt? Make 16 Thorium Belts to 255 first (12 Thorium Bars and 4 Red Power Crystals each)." }),
    Craft("s18", 270, 300, "Finish with Radiant, Thorium or Imperial plate", {
      Opt("A", "Radiant Boots", 22, { { "Thorium Bar", 14 }, { "Heart of Fire", 4 } },
        { notes = { "Usually the cheapest. Radiant Boots to 290, then 10 Radiant Leggings (20 Thorium Bars and 4 Hearts of Fire each).", "Needs Plans: Radiant Boots and Plans: Radiant Leggings (Auction House)." } }),
      Opt("B", "Thorium Leggings", 27, { { "Thorium Bar", 26 }, { "Red Power Crystal", 4 } },
        { notes = { "11 more Imperial Plate Bracers to 275 first. Needs Plans: Thorium Leggings (Auction House)." } }),
      Opt("C", "Imperial Plate Boots", 20, { { "Thorium Bar", 34 }, { "Star Ruby", 1 }, { "Aquamarine", 1 } },
        { notes = { "No plans needed: quests from Derotain Mudsipper in Tanaris. Then 10 Imperial Plate Leggings (44 Thorium Bars and 2 Star Rubies each).", "The most Thorium of the three." } }),
    }, { "Blessed Plate plans (rare drops) can also level you here and sell well." }),
  },
})
end)
