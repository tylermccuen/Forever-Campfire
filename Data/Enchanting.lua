-- Enchanting 1-300 for WoW Forever.
-- Route checked 2026-11-24.
local _, ns = ...

-- The header is all the addon needs until this guide is opened or its
-- profession is learned; the rest is built on first use.
ns.LazyGuide({
  key = "enchanting",
  capitalTrainer = { H = "Jhag in Orgrimmar", A = "Betty Quin in Stormwind (Mage Quarter)" },
  name = "Enchanting",
  skills = { "enchanting" },
  icon = "Interface\\Icons\\Trade_Engraving",
}, function()
local Craft, Opt, Train = ns.Craft, ns.Opt, ns.Train

ns.RegisterGuide({
  key = "enchanting",
  checked = "2026-11-24",
  verb = "Make",
  buyLabel = "Materials for this step:",
  rankUps = {
    [75]  = { name = "Journeyman Enchanting", skill = 50, level = 10, how = { H = "Godan (Orgrimmar), Lavinia Crowe (Undercity) or Teg Dawnstrider (Thunder Bluff)", A = "Lucan Cordell (Stormwind), Gimble Thistlefuzz (Ironforge) or Taladan (Darnassus)" } },
    [150] = { name = "Expert Enchanting", skill = 125, level = 20, how = { H = "Hgarth at Sun Rock Retreat, Stonetalon Mountains (50 silver)", A = "Kitta Firewind at the top of the Tower of Azora, Elwynn Forest (50 silver)" } },
    [225] = { name = "Artisan Enchanting", skill = 200, level = 35, how = "Annora in Uldaman (the only Artisan trainer)" },
  },
  steps = {
    { id = "learn", kind = "learn", title = "Learn Enchanting",
      notes = {
        { H = "Trainers: Jhag (Orgrimmar), Malcomb Wynn (Undercity), Mot Dawnstrider (Thunder Bluff), Pa'zula (Sen'jin Village), Vance Undergloom (Brill inn, upstairs)",
          A = "Trainers: Betty Quin (Stormwind), Thonys Pillarstone (Ironforge), Lalina Summermoon (Darnassus), Alanna Raveneye (Oracle Glade, Teldrassil)" },
        "Zephras Isle: Eaysaa Brightgust (Valanaar) or Nasalanna Windsinger (Shen'dar Village).",
        "Disenchant is in the Enchanting part of the Professions window, not your spellbook. It gives points up to 60.",
        "Tailoring pairs well: you can disenchant what you sew.",
      } },

    Craft("e1", 1, 2, "Make a Runed Copper Rod", { Opt("A", "Runed Copper Rod", 1, { { "Copper Rod", 1 }, { "Mote of Magic", 1 } }) },
      { "Copper Rod and Mote of Magic: the Enchanting Supply vendor by your trainer." }),
    Craft("e2", 2, 20, "Enchant Bracer - Inferior Stamina", { Opt("A", "Enchant Bracer - Inferior Stamina", 18, { { "Mote of Magic", 1 } }) },
      { "Disenchanting gives points until 20, so disenchant first to save crafts." }),
    Craft("e3", 20, 70, "Inferior Stamina or Minor Deflect", {
      Opt("A", "Enchant Chest - Inferior Stamina", 50, { { "Strange Dust", 1 } }),
      Opt("B", "Enchant Bracer - Minor Deflect", 50, { { "Lesser Magic Essence", 1 } },
        { notes = { "Right-click a Greater Magic Essence to split it into 3 Lesser." } }),
    }),
    Train("jm", 150, "Train Journeyman Enchanting", 50, 10,
      { { H = "Godan (Orgrimmar), Lavinia Crowe (Undercity) or Teg Dawnstrider (Thunder Bluff).", A = "Lucan Cordell (Stormwind), Gimble Thistlefuzz (Ironforge) or Taladan (Darnassus)." },
        "No points above 75 without it. Don't go AFK." }),
    Craft("e4", 70, 109, "Minor Absorption, or the Strange Dust path", {
      Opt("A", "Enchant Chest - Minor Absorption", 49, { { "Lesser Magic Essence", 1 } }),
      Opt("B", "Strange Dust path", nil, nil, {
        product = false, verb = "Make", now = "Strange Dust path: Chest Inferior Stamina to 85, Bracer Minor Stamina to 100, Cloak Minor Protection to 109.",
        buy = { { id = "Strange Dust", count = 69 } },
        notes = { "70-85: 21 Enchant Chest - Inferior Stamina (1 Strange Dust).", "85-100: 15 Enchant Bracer - Minor Stamina (2 Strange Dust).", "100-109: 9 Enchant Cloak - Minor Protection (2 Strange Dust)." } }),
    }),
    Craft("e5", 109, 110, "Make a Runed Silver Rod", { Opt("A", "Runed Silver Rod", 1, { { "Silver Rod", 1 }, { "Strange Dust", 3 }, { "Lesser Magic Essence", 4 }, { "Shadowgem", 1 } }) },
      { "Silver Rods are made by Blacksmiths: buy one on the Auction House." }),
    Craft("e6", 110, 125, "Greater Magic Wands, or Minor Protection", {
      Opt("A", "Greater Magic Wand", 23, { { "Simple Wood", 1 }, { "Lesser Magic Essence", 2 } }),
      Opt("B", "Enchant Cloak - Minor Protection", 29, { { "Strange Dust", 2 } }, { notes = { "Strange Dust path: these take you to 130. Yellow the whole way." } }),
    }),
    Craft("e7", 125, 150, "Lesser Intellect, or Minor Stamina boots", {
      Opt("A", "Enchant 2H Weapon - Lesser Intellect", 37, { { "Lesser Magic Essence", 4 } },
        { notes = { { H = "Formula from Kithas (Orgrimmar), Nata Dawnstrider (Thunder Bluff) or Leo Sarn (Silverpine). 5 silver.", A = "Formula from Tilli Thistlefuzz (Ironforge). 5 silver." } } }),
      Opt("B", "Enchant Boots - Minor Stamina", 25, { { "Strange Dust", 4 } },
        { notes = { "If 20 Soul Dust costs less than 80 Strange Dust, make Enchant Bracer - Lesser Stamina instead (1 Soul Dust)." } }),
    }, nil, { recipes = { "Formula: Enchant 2H Weapon - Lesser Intellect" } }),
    Train("exp", 225, "Train Expert Enchanting", 125, 20,
      { { H = "Hgarth at Sun Rock Retreat (Stonetalon Mountains), on the cliff above the village. 50 silver.", A = "Kitta Firewind at the top of the Tower of Azora (Elwynn Forest). 50 silver." },
        "Buy the Minor Mana Oil and Lesser Wizard Oil formulas before you leave.",
        { H = "Maple Seed: Jeeda. Leaded Vial: Kulwia. Both in Sun Rock Retreat.", A = "Maple Seed and Leaded Vial: Dawn Brightstar at the Tower of Azora." } }),
    Craft("e8", 150, 151, "Make a Runed Golden Rod", { Opt("A", "Runed Golden Rod", 1, { { "Golden Rod", 1 }, { "Iridescent Pearl", 1 }, { "Greater Astral Essence", 1 }, { "Soul Dust", 1 } }) },
      { "Golden Rods are made by Blacksmiths: Auction House." }),
    Craft("e9", 151, 165, "Make Minor Mana Oil", { Opt("A", "Minor Mana Oil", 16, { { "Soul Dust", 1 }, { "Maple Seed", 2 }, { "Leaded Vial", 1 } }) },
      nil, { recipes = { "Formula: Minor Mana Oil", "Formula: Lesser Wizard Oil" } }),
    Craft("e10", 165, 200, "Enchant Boots - Lesser Agility", { Opt("A", "Enchant Boots - Lesser Agility", 44, { { "Soul Dust", 1 } }) },
      { "Yellow from 180. Make extras if you fall short.", "Vision Dust cheap? From 185 you can make Enchant Bracer - Strength (1 Vision Dust) instead." }),
    Craft("e11", 200, 201, "Make a Runed Truesilver Rod", { Opt("A", "Runed Truesilver Rod", 1, { { "Truesilver Rod", 1 }, { "Black Pearl", 1 }, { "Greater Mystic Essence", 1 }, { "Vision Dust", 1 } }) }),
    Craft("e12", 201, 220, "Make Lesser Wizard Oil", { Opt("A", "Lesser Wizard Oil", 25, { { "Vision Dust", 1 }, { "Stranglethorn Seed", 2 }, { "Leaded Vial", 1 } }) },
      { "Stranglethorn Seed: Reagent vendors. Leaded Vial: Alchemy Supply vendors." }),
    Craft("e13", 220, 225, "Enchant Cloak - Greater Defense", { Opt("A", "Enchant Cloak - Greater Defense", 5, { { "Vision Dust", 1 } }) }),
    Train("art", 300, "Train Artisan Enchanting (Uldaman)", 200, 35, {
      "Annora in Uldaman is the only Artisan trainer. Use the back entrance in the Badlands.",
      "She only appears after every mob near her is dead. Bring a group or a level 60 friend.",
      "Learn everything from her before leaving: recipes from 230 up are only taught there (about 12 gold total).",
    }),
    Craft("e14", 225, 250, "Enchant Gloves - Agility", { Opt("A", "Enchant Gloves - Agility", 34, { { "Vision Dust", 1 } }) },
      { "Yellow from 230. Make extras if you fall short." }),
    Craft("e15", 250, 270, "Lesser Mana Oil, or Greater Strength", {
      Opt("A", "Lesser Mana Oil", 26, { { "Dream Dust", 1 }, { "Purple Lotus", 1 }, { "Crystal Vial", 1 } }, { notes = { "Formula from Kania (Silithus, upstairs in the inn)." } }),
      Opt("B", "Enchant Bracer - Greater Strength", 23, { { "Dream Dust", 1 }, { "Lesser Nether Essence", 2 } }, { notes = { "No Purple Lotus? Use this." } }),
    }, nil, { recipes = { "Formula: Lesser Mana Oil", "Formula: Wizard Oil" } }),
    Craft("e16", 270, 275, "Enchant Shield - Greater Stamina", { Opt("A", "Enchant Shield - Greater Stamina", 5, { { "Dream Dust", 6 } }) },
      { { H = "Formula from Daniel Bartlett (Undercity). Binds when picked up.", A = "Formula from Mythrin'dir (Darnassus). Binds when picked up." } },
      { recipes = { "Formula: Enchant Shield - Greater Stamina" } }),
    Craft("e17", 275, 295, "Wizard Oil, or more Shields", {
      Opt("A", "Wizard Oil", 26, { { "Illusion Dust", 3 }, { "Firebloom", 2 }, { "Crystal Vial", 1 } }, { notes = { "Formula from Kania (Silithus)." } }),
      Opt("B", "Enchant Shield - Greater Stamina", 23, { { "Dream Dust", 6 } }, { notes = { "If Illusion Dust is expensive." } }),
    }),
    Craft("e18", 295, 299, "More Shield - Greater Stamina", { Opt("A", "Enchant Shield - Greater Stamina", 8, { { "Dream Dust", 6 } }) },
      { "Wizard Oil selling well? Keep making oils instead (about 15)." }),
    Craft("e19", 299, 300, "Make a Runed Arcanite Rod", {
      Opt("A", "Runed Arcanite Rod", 1, { { "Arcanite Rod", 1 }, { "Golden Pearl", 1 }, { "Illusion Dust", 10 }, { "Greater Eternal Essence", 4 }, { "Small Brilliant Shard", 4 }, { "Large Brilliant Shard", 2 } }) },
      { "Formula from Lorelae Wintersong in Nighthaven (Moonglade). Most 300 recipes need this rod.",
        "Don't need it yet? One more Shield gets the last point." },
      { recipes = { "Formula: Runed Arcanite Rod" } }),
  },
})
end)
