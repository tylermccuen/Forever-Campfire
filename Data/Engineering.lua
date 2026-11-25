-- Engineering 1-300 for WoW Forever.
-- Route checked 2026-11-24.
local _, ns = ...

-- The header is all the addon needs until this guide is opened or its
-- profession is learned; the rest is built on first use.
ns.LazyGuide({
  key = "engineering",
  capitalTrainer = { H = "Thund in Orgrimmar", A = "Sprite Jumpsprocket in Stormwind (Dwarven District)" },
  name = "Engineering",
  skills = { "engineering" },
  icon = "Interface\\Icons\\Trade_Engineering",
}, function()
local Craft, Opt, Train = ns.Craft, ns.Opt, ns.Train

ns.RegisterGuide({
  key = "engineering",
  checked = "2026-11-24",
  verb = "Make",
  buyLabel = "Materials for this step:",
  tool = 5956,
  rankUps = {
    [75]  = { name = "Journeyman Engineering", skill = 50, level = 10, how = { H = "Nogg (Orgrimmar) or Franklin Lloyd (Undercity)", A = "Lilliam Sparkspindle (Stormwind), Trixie Quikswitch (Ironforge) or Finbus Geargrind (Duskwood)" } },
    [150] = { name = "Expert Engineering", skill = 125, level = 20, how = { H = "Roxxik in Orgrimmar (50 silver)", A = "Springspindle Fizzlegear in Ironforge (50 silver)" } },
    [225] = { name = "Artisan Engineering", skill = 200, level = 35, how = "Buzzek Bracketswing in Gadgetzan, or Kaylaena Springwhisper in Mount Hyjal" },
  },
  steps = {
    { id = "learn", kind = "learn", title = "Learn Engineering, buy a hammer",
      notes = {
        "No level requirement. Starting in Orgrimmar or Ironforge saves trips: Expert is taught there too.",
        { H = "Trainers: Thund (Orgrimmar), Graham Van Talen (Undercity, Rogues' Quarter), Mukdrak (Razor Hill)",
          A = "Trainers: Sprite Jumpsprocket (Stormwind), Jemma Quikswitch (Ironforge), Bronk Guzzlegear (Steelgrill's Depot), Jenna Lemkenilli (Auberdine)" },
        "Zephras Isle: the Strange Hermit in Shadowgale Forest.",
        "Buy a Blacksmith Hammer first. Most recipes need it.",
        "Mining pairs best: almost every recipe uses stone and bars.",
        "Gnomes don't get the +15 Engineering bonus in Forever.",
      },
      buy = { { id = 5956, count = 1 } } },

    Craft("g1", 1, 35, "Make Rough Blasting Powder", { Opt("A", "Rough Blasting Powder", 56, { { "Rough Stone", 1 } }) }, { "Keep it all for bombs." }),
    Craft("g2", 35, 55, "Make Handfuls of Copper Bolts", { Opt("A", "Handful of Copper Bolts", 28, { { "Copper Bar", 1 } }) }, { "Keep all 28 for bombs." }),
    Craft("g3", 55, 56, "Make an Arclight Spanner", { Opt("A", "Arclight Spanner", 1, { { "Copper Bar", 6 } }) }, { "Keep it: later recipes need it." }),
    Craft("g4", 56, 75, "Make Rough Copper Bombs", { Opt("A", "Rough Copper Bomb", 28, { { "Copper Bar", 1 }, { "Handful of Copper Bolts", 1 }, { "Rough Blasting Powder", 2 }, { "Linen Cloth", 1 } }) },
      { "Don't go AFK: you may hit 75 before Journeyman." }),
    Train("jm", 150, "Train Journeyman Engineering", 50, 10,
      { { H = "Nogg (Orgrimmar) or Franklin Lloyd (Undercity).", A = "Lilliam Sparkspindle (Stormwind), Trixie Quikswitch (Ironforge) or Finbus Geargrind (Duskwood)." } }),
    Craft("g5", 75, 90, "Make Coarse Blasting Powder", { Opt("A", "Coarse Blasting Powder", 51, { { "Coarse Stone", 1 } }) }, { "Keep all 51 for dynamite." }),
    Craft("g6", 90, 100, "Make Coarse Dynamite", { Opt("A", "Coarse Dynamite", 17, { { "Coarse Blasting Powder", 3 }, { "Linen Cloth", 1 } }) },
      { "Green at 97. Short of 100? Move on to Silver Contacts." }),
    Craft("g7", 100, 105, "Make Silver Contacts", {
      Opt("A", "Silver Contact", 5, { { "Silver Bar", 1 } }),
      Opt("B", "Flying Tiger Goggles", 5, { { "Light Leather", 6 }, { "Tigerseye", 2 } }, { notes = { "Use this if Silver Bars are expensive." } }),
    }),
    Craft("g8", 105, 125, "Make Bronze Tubes", { Opt("A", "Bronze Tube", 25, { { "Bronze Bar", 2 }, { "Weak Flux", 1 } }) },
      { "Keep 10 for scopes. Weak Flux: the Engineering Supply vendor by your trainer." }),
    Craft("g9", 125, 135, "Make Standard Scopes", {
      Opt("A", "Standard Scope", 10, { { "Bronze Tube", 1 }, { "Moss Agate", 1 } }),
      Opt("B", "Heavy Blasting Powder", 10, { { "Heavy Stone", 1 } }, { notes = { "Use this if you have no Moss Agate or it's expensive." } }),
    }),
    Craft("g10", 135, 150, "Heavy Blasting Powder, then Gizmos", {
      Opt("A", "Heavy Blasting Powder and Whirring Bronze Gizmo", nil, nil, {
        product = false, verb = "Make", now = "Make 40 Heavy Blasting Powder, then 15 Whirring Bronze Gizmos (2 Bronze Bars and 1 Wool Cloth each).",
        buy = { { id = "Heavy Stone", count = 40 }, { id = "Bronze Bar", count = 30 }, { id = "Wool Cloth", count = 15 } },
        notes = { "Make them in this order. Keep 30 powder and all gizmos for the sheep at 160, and 10 powder for grenades at 190." } }),
    }),
    Train("exp", 225, "Train Expert Engineering", 125, 20, { { H = "Roxxik in Orgrimmar (50 silver).", A = "Springspindle Fizzlegear in Ironforge (50 silver)." } }),
    Craft("g11", 150, 160, "Make Bronze Frameworks", { Opt("A", "Bronze Framework", 15, { { "Bronze Bar", 2 }, { "Medium Leather", 1 }, { "Wool Cloth", 1 } }) },
      { "Keep all 15 for sheep. You'll likely pass 160 here." }),
    Craft("g12", 160, 175, "Make Explosive Sheep", { Opt("A", "Explosive Sheep", 15, { { "Heavy Blasting Powder", 2 }, { "Whirring Bronze Gizmo", 1 }, { "Bronze Framework", 1 }, { "Wool Cloth", 2 } }) },
      { "Keep 5: Goblin Engineering may need them." }),
    Craft("g13", 175, 190, "Make Solid Blasting Powder", { Opt("A", "Solid Blasting Powder", 31, { { "Solid Stone", 2 } }) }, { "Keep it all." }),
    Craft("g14", 190, 195, "Micro-Adjustor, then Iron Grenades", {
      Opt("A", "Gyromatic Micro-Adjustor and Iron Grenade", nil, nil, {
        product = false, verb = "Make", now = "Make 1 Gyromatic Micro-Adjustor (4 Steel Bars), then Iron Grenades until 195.",
        buy = { { id = "Steel Bar", count = 4 }, { id = "Iron Bar", count = 10 }, { id = "Heavy Blasting Powder", count = 10 }, { id = "Silk Cloth", count = 10 } },
        notes = { "Keep the Micro-Adjustor: later recipes need it." } }),
    }),
    Craft("g15", 195, 200, "Make Mithril Tubes", { Opt("A", "Mithril Tube", 6, { { "Mithril Bar", 3 } }) },
      { "Keep all 6: Gnomish Engineering may need them.", "At 200 and level 30 you can pick Gnomish or Goblin Engineering." }),
    Train("art", 300, "Train Artisan Engineering", 200, 35,
      { "Buzzek Bracketswing in Gadgetzan, by the mailbox outside the inn. Or Kaylaena Springwhisper in Mount Hyjal.", "Go as soon as you hit 200: the Artisan trainer teaches the recipes from here on." }),
    Craft("g16", 200, 215, "Make Unstable Triggers", { Opt("A", "Unstable Trigger", 21, { { "Mithril Bar", 1 }, { "Mageweave Cloth", 1 }, { "Solid Blasting Powder", 1 } }) },
      { "Keep 20 for bombs at 238." }),
    Craft("g17", 215, 238, "Make Mithril Casings", { Opt("A", "Mithril Casing", 40, { { "Mithril Bar", 3 } }) },
      { "Keep all 40. No points above 225 without Artisan." }),
    Craft("g18", 238, 250, "Make Hi-Explosive Bombs", { Opt("A", "Hi-Explosive Bomb", 20, { { "Mithril Casing", 2 }, { "Unstable Trigger", 1 }, { "Solid Blasting Powder", 2 } }) }),
    Craft("g19", 250, 260, "Make Dense Blasting Powder", { Opt("A", "Dense Blasting Powder", 44, { { "Dense Stone", 2 } }) }, { "Keep it." }),
    Craft("g20", 260, 280, "Make Thorium Widgets", { Opt("A", "Thorium Widget", 20, { { "Thorium Bar", 3 }, { "Runecloth", 1 } }) },
      { { H = "Schematic from Sovik in Orgrimmar.", A = "Schematic from Gearcutter Cogspinner in Ironforge." },
        "PvP realm? Make 10 widgets and 10 Thorium Grenades instead (same vendors sell the grenade schematic)." },
      { recipes = { "Schematic: Thorium Widget", "Schematic: Thorium Grenade" } }),
    Craft("g21", 280, 300, "Make Thorium Tubes", { Opt("A", "Thorium Tube", 21, { { "Thorium Bar", 6 } }) },
      { "Schematic from Xizzer Fizzbolt in Everlook (Winterspring) or Kor'gar in Riverglades. Binds when picked up.",
        "Yellow from 295. Make a few extra if you fall short.",
        "Have the Thorium Shells schematic? Make 5 tubes to 285, then 15 Thorium Shells, then 12 more tubes." },
      { recipes = { "Schematic: Thorium Tube" } }),
  },
})
end)
