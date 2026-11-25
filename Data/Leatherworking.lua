-- Leatherworking 1-300 for WoW Forever.
-- Route checked 2026-11-24.
local _, ns = ...

-- The header is all the addon needs until this guide is opened or its
-- profession is learned; the rest is built on first use.
ns.LazyGuide({
  key = "leatherworking",
  capitalTrainer = { H = "Karolek in Orgrimmar", A = "Simon Tanner in Stormwind" },
  name = "Leatherworking",
  skills = { "leatherworking" },
  icon = "Interface\\Icons\\Trade_LeatherWorking",
}, function()
local Craft, Opt, Train = ns.Craft, ns.Opt, ns.Train

ns.RegisterGuide({
  key = "leatherworking",
  checked = "2026-11-24",
  verb = "Make",
  buyLabel = "Materials for this step:",
  rankUps = {
    [75]  = { name = "Journeyman Leatherworking", skill = 50, level = 10, how = { H = "Karolek (Orgrimmar), Arthur Moore (Undercity) or Tarn (Thunder Bluff)", A = "Simon Tanner (Stormwind), Fimble Finespindle (Ironforge) or Faldron (Darnassus)" } },
    [150] = { name = "Expert Leatherworking", skill = 125, level = 20, how = { H = "Una in Thunder Bluff (50 silver)", A = "Telonis in Darnassus (50 silver)" } },
    [225] = { name = "Artisan Leatherworking", skill = 200, level = 35, how = { H = "Hahrana Ironhide in Camp Mojache (Feralas)", A = "Drakk Stonehand in Aerie Peak (The Hinterlands)" } },
  },
  steps = {
    { id = "learn", kind = "learn", title = "Learn Leatherworking",
      notes = {
        "No level requirement. Every capital has a trainer.",
        { H = "Nearby trainers: Kamari (The Drag, Orgrimmar), Chaw Stronghide (Bloodhoof Village), Shelene Rhobart (southeast of Brill)",
          A = "Nearby trainers: Adele Fielder (by Crystal Lake, Elwynn), Gretta Finespindle (Ironforge), Nadyia Maneweaver (road to Darnassus)" },
        "Zephras Isle: Emerii Tallgust (Valanaar) or Indari Sunseam (Shen'dar Village).",
        "Thread, dye and salt: the Leatherworking Supply vendor by your trainer.",
        { H = "No supply vendor near the Tirisfal trainer: Abigail Shiel in Brill sells Salt and Coarse Thread.", A = "No supply vendor near the Elwynn trainer: Tharynn Bouden in Goldshire sells Salt and Coarse Thread." },
        "Skinning pairs well: leather is most of the cost.",
      } },

    Craft("l1", 1, 30, "Make Light Leather", { Opt("A", "Light Leather", 35, { { "Ruined Leather Scraps", 3 } }) }),
    Craft("l2", 30, 40, "Make Cured Light Hide", {
      Opt("A", "Cured Light Hide", 10, { { "Light Hide", 1 }, { "Salt", 1 } }, { notes = { "Keep them for Embossed Leather Pants at 70." } }),
      Opt("B", "Light Armor Kit", 14, { { "Light Leather", 1 } }, { notes = { "Use this if you have no hides." } }),
    }),
    Craft("l3", 40, 60, "Make Embossed Leather Gloves", { Opt("A", "Embossed Leather Gloves", 20, { { "Light Leather", 3 }, { "Coarse Thread", 2 } }) }),
    Train("jm", 150, "Train Journeyman Leatherworking", 50, 10,
      { { H = "Karolek (Orgrimmar), Arthur Moore (Undercity) or Tarn (Thunder Bluff).", A = "Simon Tanner (Stormwind), Fimble Finespindle (Ironforge) or Faldron (Darnassus)." } }),
    Craft("l4", 60, 70, "Make more Embossed Leather Gloves", { Opt("A", "Embossed Leather Gloves", 10, { { "Light Leather", 3 }, { "Coarse Thread", 2 } }) }),
    Craft("l5", 70, 80, "Make Embossed Leather Pants", {
      Opt("A", "Embossed Leather Pants", 10, { { "Cured Light Hide", 1 }, { "Light Leather", 6 }, { "Coarse Thread", 2 } }, { notes = { "Vendors pay more for these than for the gloves." } }),
      Opt("B", "Embossed Leather Gloves", 14, { { "Light Leather", 3 }, { "Coarse Thread", 2 } }, { notes = { "Use this if you have no hides." } }),
    }),
    Craft("l6", 80, 95, "Make Cured Medium Hide", {
      Opt("A", "Cured Medium Hide", 20, { { "Medium Hide", 1 }, { "Salt", 1 } }, { notes = { "Keep all 20 for Dark Leather Belts at 105." } }),
      Opt("B", "Fine Leather Belt", 19, { { "Light Leather", 6 }, { "Coarse Thread", 2 } }, { notes = { "Use this if you have no hides." } }),
    }),
    Craft("l7", 95, 105, "Make Fine Leather Belts", { Opt("A", "Fine Leather Belt", 22, { { "Light Leather", 6 }, { "Coarse Thread", 2 } }) },
      { "Keep 20 belts for Dark Leather Belts." }),
    Craft("l8", 105, 125, "Make Dark Leather Belts", {
      Opt("A", "Dark Leather Belt", 20, { { "Fine Leather Belt", 1 }, { "Cured Medium Hide", 1 }, { "Fine Thread", 2 }, { "Gray Dye", 1 } }),
      Opt("B", "Dark Leather Pants", 16, { { "Medium Leather", 12 }, { "Gray Dye", 1 }, { "Fine Thread", 1 } },
        { notes = { "No hides? Make Dark Leather Pants to 120, then 5 Hillman's Leather Gloves to 125." } }),
    }),
    Craft("l9", 125, 130, "Make Heavy Leather", { Opt("A", "Heavy Leather", 8, { { "Medium Leather", 5 } }) }),
    Train("exp", 225, "Train Expert Leatherworking", 125, 20, { { H = "Una in Thunder Bluff (50 silver).", A = "Telonis in Darnassus (50 silver)." } }),
    Craft("l10", 130, 143, "Make Cured Heavy Hide", {
      Opt("A", "Cured Heavy Hide", 25, { { "Heavy Hide", 1 }, { "Salt", 3 } }, { notes = { "Keep 15 for Barbaric Shoulders and 10 for Guardian Gloves." } }),
      Opt("B", "Hillman's Leather Gloves", 21, { { "Medium Leather", 14 }, { "Fine Thread", 4 } }, { notes = { "Use this if you have no heavy hides. These take you to 150." } }),
    }),
    Craft("l11", 143, 150, "Make Hillman's Leather Gloves", { Opt("A", "Hillman's Leather Gloves", 8, { { "Medium Leather", 14 }, { "Fine Thread", 4 } }) }),
    Craft("l12", 150, 165, "Make Barbaric Shoulders", {
      Opt("A", "Barbaric Shoulders", 15, { { "Heavy Leather", 8 }, { "Cured Heavy Hide", 1 }, { "Fine Thread", 2 } }),
      Opt("B", "Barbaric Leggings", 15, { { "Heavy Leather", 10 }, { "Moss Agate", 1 }, { "Fine Thread", 2 } },
        { notes = { { H = "Use this if you have no hides. Pattern from Jandia at Freewind Post (Thousand Needles).", A = "Use this if you have no hides. Pattern from Lardan in Astranaar (Ashenvale)." } } }),
    }, nil, { recipes = { "Pattern: Barbaric Leggings" } }),
    Craft("l13", 165, 175, "Make Guardian Gloves", {
      Opt("A", "Guardian Gloves", 10, { { "Heavy Leather", 4 }, { "Cured Heavy Hide", 1 }, { "Silken Thread", 1 } }),
      Opt("B", "Barbaric Harness", 10, { { "Heavy Leather", 14 }, { "Fine Thread", 2 }, { "Iron Buckle", 1 } }, { notes = { "Use this if you have no hides." } }),
    }),
    Craft("l14", 175, 185, "Make Barbaric Harness", {
      Opt("A", "Barbaric Harness", 10, { { "Heavy Leather", 14 }, { "Fine Thread", 2 }, { "Iron Buckle", 1 } }, { notes = { "Iron Buckles are made by Blacksmiths: buy them on the Auction House." } }),
      Opt("B", "Thick Armor Kit", 10, { { "Thick Leather", 5 }, { "Silken Thread", 1 } }, { notes = { "Use this if you have no Iron Buckles." } }),
    }),
    Craft("l15", 185, 205, "Make Nightscape Headbands", { Opt("A", "Nightscape Headband", 22, { { "Thick Leather", 5 }, { "Silken Thread", 2 } }) }),
    Train("art", 300, "Train Artisan Leatherworking", 200, 35,
      { { H = "Hahrana Ironhide in Camp Mojache (Feralas).", A = "Drakk Stonehand in Aerie Peak (The Hinterlands)." },
        "The next recipes are only taught by the Artisan trainers.", "At 225 and level 40 you can pick Dragonscale, Elemental or Tribal." }),
    Craft("l16", 205, 235, "Make Nightscape Pants", { Opt("A", "Nightscape Pants", 36, { { "Thick Leather", 14 }, { "Silken Thread", 4 } }) },
      { "Vendors pay more for these than for Nightscape Boots." }),
    Craft("l17", 235, 265, "Make Wicked Leather Gauntlets", {
      Opt("A", "Wicked Leather Gauntlets", 36, { { "Rugged Leather", 8 }, { "Black Dye", 1 }, { "Rune Thread", 1 } },
        { notes = { { H = "Pattern from Werg Thickblade (Tirisfal Glades).", A = "Pattern from Leonard Porter (Western Plaguelands)." } } }),
      Opt("B", "Blue Suede Shoes", 36, { { "Rugged Leather", 8 }, { "Blue Dye", 1 }, { "Rune Thread", 1 } },
        { notes = { "Needs Pattern: Blue Suede Shoes. Saves about 13 gold." } }),
    }, { "Have Pattern: Wicked Leather Headband? Make 20 gauntlets to 255, then 10 headbands. They sell better and disenchant to Illusion Dust." },
      { recipes = { "Pattern: Wicked Leather Gauntlets" } }),
    Craft("l18", 265, 300, "Make Runic Leather Headbands", { Opt("A", "Runic Leather Headband", 49, { { "Rugged Leather", 14 }, { "Runecloth", 10 }, { "Rune Thread", 1 } }) },
      { "Pattern from Jase Farlane at Light's Hope Chapel (Eastern Plaguelands).",
        "Yellow from 285, green from 295. Make a few extra if you fall short.",
        "Cheaper with a bracer pattern: Tooled Leather Bracers or Blue Suede Bracers can replace most headbands." },
      { recipes = { "Pattern: Runic Leather Headband" } }),
  },
})
end)
