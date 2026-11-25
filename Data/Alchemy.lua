-- Alchemy 1-300 for WoW Forever.
-- Route checked 2026-11-24.
local _, ns = ...

-- The header is all the addon needs until this guide is opened or its
-- profession is learned; the rest is built on first use.
ns.LazyGuide({
  key = "alchemy",
  capitalTrainer = { H = "Whuut in Orgrimmar", A = "Tel'Athir in Stormwind" },
  name = "Alchemy",
  skills = { "alchemy" },
  icon = "Interface\\Icons\\Trade_Alchemy",
}, function()
local Craft, Opt, Train = ns.Craft, ns.Opt, ns.Train

local APPRENTICE = {
  H = "Trainers: Whuut (Orgrimmar), Doctor Martin Felben (Undercity), Kray (Thunder Bluff), Miao'zan (Sen'jin Village), Carolai Anise (Brill)",
  A = "Trainers: Tel'Athir (Stormwind), Vosur Brakthel (Ironforge), Milla Fairancora (Darnassus), Alchemist Mallory (Elwynn Forest), Cyndra Kindwhisper (Dolanaar)",
}
local JOURNEYMAN = {
  H = "Journeyman trainers: Yelmak (Orgrimmar), Doctor Marsh (Undercity), Bena Winterhoof (Thunder Bluff)",
  A = "Journeyman trainers: Lilyssia Nightbreeze (Stormwind), Tally Berryfizz (Ironforge), Sylvanna Forestmoon (Darnassus)",
}

ns.RegisterGuide({
  key = "alchemy",
  checked = "2026-11-24",
  verb = "Make",
  buyLabel = "Materials for this step:",
  rankUps = {
    [75]  = { name = "Journeyman Alchemy", skill = 50, level = 10, how = { H = "Yelmak (Orgrimmar), Doctor Marsh (Undercity) or Bena Winterhoof (Thunder Bluff)", A = "Lilyssia Nightbreeze (Stormwind), Tally Berryfizz (Ironforge) or Sylvanna Forestmoon (Darnassus)" } },
    [150] = { name = "Expert Alchemy", skill = 125, level = 20, how = { H = "Doctor Herbert Halsey in Undercity (50 silver)", A = "Ainethil in Darnassus (50 silver)" } },
    [225] = { name = "Artisan Alchemy", skill = 200, level = 35, how = { H = "Rogvar in Stonard (Swamp of Sorrows)", A = "Kylanna Windwhisper in Feathermoon Stronghold (Feralas)" } },
  },
  steps = {
    { id = "learn", kind = "learn", title = "Learn Alchemy",
      notes = { "No level requirement.", APPRENTICE, "Zephras Isle: Iaadaria Bitterwind or Valiena Swiftgale (Valanaar), Nyassa Swiftdraught (Shen'dar Village).",
                "Herbalism pairs well: picking your own herbs saves a lot of gold.", "Vials: Alchemy Supply or Trade Supply vendors." } },

    Craft("b1", 1, 10, "Make Elixir of Minor Force", { Opt("A", "Elixir of Minor Force", 9, { { "Silverleaf", 1 }, { "Empty Vial", 1 } }) }),
    Craft("b2", 10, 55, "Make Elixir of Minor Defense", { Opt("A", "Elixir of Minor Defense", 45, { { "Silverleaf", 1 }, { "Peacebloom", 1 }, { "Empty Vial", 1 } }) }),
    Train("jm", 150, "Train Journeyman Alchemy", 50, 10, { "Starting-zone trainers only teach up to 50. Without Journeyman you stop gaining skill at 75.", JOURNEYMAN }),
    Craft("b3", 55, 65, "Make Minor Mana Potions", { Opt("A", "Minor Mana Potion", 10, { { "Mageroyal", 1 }, { "Peacebloom", 1 }, { "Empty Vial", 1 } }) }),
    Craft("b4", 65, 90, "Make Elixir of Minor Fortitude", { Opt("A", "Elixir of Minor Fortitude", 28, { { "Earthroot", 2 }, { "Peacebloom", 1 }, { "Empty Vial", 1 } }) },
      { "Train Journeyman before 75. Don't go AFK while crafting." }),
    Craft("b5", 90, 120, "Make Elixir of Wisdom", { Opt("A", "Elixir of Wisdom", 30, { { "Mageroyal", 1 }, { "Briarthorn", 2 }, { "Empty Vial", 1 } }) }),
    Craft("b6", 120, 130, "Make Lesser Mana Potions", { Opt("A", "Lesser Mana Potion", 10, { { "Mageroyal", 1 }, { "Stranglekelp", 1 }, { "Empty Vial", 1 } }) },
      { "You can keep making these to 145, but Fire Oil is cheaper from 130." }),
    Craft("b7", 130, 150, "Make Fire Oil", { Opt("A", "Fire Oil", 20, { { "Firefin Snapper", 2 }, { "Empty Vial", 1 } }) },
      { "Each craft makes 2 oils. Keep 30 for the next step." }),
    Train("exp", 225, "Train Expert Alchemy", 125, 20, { { H = "Doctor Herbert Halsey in Undercity (50 silver).", A = "Ainethil in Darnassus (50 silver)." } }),
    Craft("b8", 150, 165, "Make Elixir of Fire Power", { Opt("A", "Elixir of Fire Power", 15, { { "Fire Oil", 2 }, { "Kingsblood", 1 }, { "Leaded Vial", 1 } }) }),
    Craft("b9", 165, 195, "Make Mana Potions", { Opt("A", "Mana Potion", 36, { { "Stranglekelp", 1 }, { "Kingsblood", 1 }, { "Leaded Vial", 1 } }) }),
    Craft("b10", 195, 225, "Make Nature Protection Potions", { Opt("A", "Nature Protection Potion", 36, { { "Liferoot", 1 }, { "Stranglekelp", 1 }, { "Leaded Vial", 1 } }) },
      { { H = "Recipe: Nature Protection Potion (190) from Bronk (Feralas), Glyx Brewright (Stranglethorn) or Alchemist Pestlezugg (Tanaris).",
          A = "Recipe: Nature Protection Potion (190) from Logannas (Feralas), Glyx Brewright (Stranglethorn) or Alchemist Pestlezugg (Tanaris)." },
        "It binds when picked up: buy it on the character leveling Alchemy." },
      { recipes = { "Recipe: Nature Protection Potion" } }),
    Train("art", 300, "Train Artisan Alchemy", 200, 35, { { H = "Rogvar in Stonard (Swamp of Sorrows).", A = "Kylanna Windwhisper in Feathermoon Stronghold (Feralas)." } }),
    Craft("b11", 225, 235, "Keep making Nature Protection Potions", { Opt("A", "Nature Protection Potion", 26, { { "Liferoot", 1 }, { "Stranglekelp", 1 }, { "Leaded Vial", 1 } }) },
      { "Optional: Transmute: Iron to Gold or Mithril to Truesilver (Alchemist Pestlezugg, Tanaris) gives a point each until 240. Each has a 1-hour cooldown." }),
    Craft("b12", 235, 250, "Make Elixir of Greater Intellect", { Opt("A", "Elixir of Greater Intellect", 15, { { "Blindweed", 1 }, { "Khadgar's Whisker", 1 }, { "Crystal Vial", 1 } }) },
      { "Learn it from your Alchemy trainer once you reach 235. There's no recipe to buy.",
        { H = "Rogvar in Stonard (Swamp of Sorrows) teaches it.", A = "Kylanna Windwhisper in Feathermoon Stronghold (Feralas) teaches it." } }),
    Craft("b13", 250, 260, "Make Stonescale Oil", {
      Opt("A", "Stonescale Oil", 47, { { "Stonescale Eel", 1 }, { "Leaded Vial", 1 } }, { notes = { "Learn it from your Alchemy trainer at 250.", "Each craft makes 2 oils. Keep them all: you need 88." } }),
      Opt("B", "Elixir of Greater Intellect", 21, { { "Blindweed", 1 }, { "Khadgar's Whisker", 1 }, { "Crystal Vial", 1 } },
        { notes = { "If Stonescale Eel is expensive: make these to 265, then Superior Mana Potions to 300." } }),
    }),
    Craft("b14", 260, 265, "Make a few more Elixirs of Greater Intellect", { Opt("A", "Elixir of Greater Intellect", 10, { { "Blindweed", 1 }, { "Khadgar's Whisker", 1 }, { "Crystal Vial", 1 } }) }),
    Craft("b15", 265, 300, "Make Elixir of Greater Defense", {
      Opt("A", "Elixir of Greater Defense", 44, { { "Stonescale Oil", 2 }, { "Sungrass", 1 }, { "Crystal Vial", 1 } },
        { notes = { { H = "The recipe item is named Recipe: Elixir of Superior Defense. Kor'geld (Orgrimmar) sells it.", A = "The recipe item is named Recipe: Elixir of Superior Defense. Soolie Berryfizz (Ironforge) sells it." },
                    "Yellow from 280. Make a few extra if you fall short." } }),
      Opt("B", "Superior Mana Potion", 55, { { "Sungrass", 2 }, { "Blindweed", 2 }, { "Crystal Vial", 1 } },
        { notes = { { H = "Recipe from Algernon (Undercity).", A = "Recipe from Ulthir (Darnassus)." }, "Use this if you skipped Stonescale Oil." } }),
    }, nil, { recipes = { "Recipe: Elixir of Superior Defense", "Recipe: Superior Mana Potion" } }),
  },
})
end)
