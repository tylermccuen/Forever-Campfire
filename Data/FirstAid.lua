-- First Aid 1-300 for WoW Forever.
-- Route checked 2026-11-24.
-- Crafting step helpers (ns.Craft / ns.Opt / ns.Train) are in Core.lua.
local _, ns = ...
local Craft, Opt, Train = ns.Craft, ns.Opt, ns.Train

local TRAINERS = {
  H = "Trainers: Arnok (Orgrimmar), Mary Edras (Undercity), Pand Stonebinder (Thunder Bluff), Rawrk (Razor Hill barracks), Vira Younghoof (Bloodhoof Village inn), Nurse Neela (Brill inn)",
  A = "Trainers: Shaina Fuller (Stormwind), Nissa Firestone (Ironforge), Dannelor (Darnassus), Michelle Belle (Goldshire inn, upstairs), Thamner Pol (Kharanos), Byancie (Dolanaar)",
}
local BOOKS = { H = "Balai Lok'Wein in Dustwallow Marsh (Brackenwall Village)", A = "Deneb Walker in Arathi Highlands (Refuge Pointe)" }

ns.RegisterGuide({
  key = "firstaid",
  capitalTrainer = { H = "Arnok in Orgrimmar", A = "Shaina Fuller in Stormwind" },
  name = "First Aid",
  skills = { "firstaid" },
  icon = "Interface\\Icons\\Spell_Holy_SealOfSacrifice",
  checked = "2026-11-24",
  verb = "Make",
  buyLabel = "Materials for this step:",
  rankUps = {
    [75]  = { name = "Journeyman First Aid", skill = 50, how = "Train it at your First Aid trainer" },
    [150] = { name = "Expert First Aid", skill = 125, book = "Expert First Aid - Under Wraps",
              how = { H = "Buy and read Expert First Aid - Under Wraps from Balai Lok'Wein (Dustwallow Marsh)", A = "Buy and read Expert First Aid - Under Wraps from Deneb Walker (Arathi Highlands)" } },
    [225] = { name = "Artisan First Aid", skill = 225, level = 35,
              how = { H = "Quest Triage from Doctor Gregory Victor in Hammerfall (Arathi Highlands)", A = "Quest Triage from Doctor Gustaf VanHowzen in Theramore (Dustwallow Marsh)" } },
  },
  steps = {
    { id = "learn", kind = "learn", title = "Learn First Aid",
      notes = {
        "First Aid doesn't use one of your two profession slots.",
        "In WoW Forever, First Aid also makes the healing potions.",
        TRAINERS,
        "Zephras Isle: Melasa Fairmend (Valanaar) or Naleeia Tattermend (Shen'dar Village).",
      } },

    Craft("a1", 1, 40, "Make Linen Bandages", {
      Opt("A", "Linen Bandage", 50, { { "Linen Cloth", 1 } }),
      Opt("B", "Minor Healing Potion", 86, { { "Peacebloom", 1 }, { "Mild Spices", 1 }, { "Empty Vial", 1 } },
        { notes = { "Takes you all the way to 75. Spices and vials are sold by trade and cooking vendors." } }),
    }),
    Craft("a2", 40, 75, "Make Heavy Linen Bandages", {
      Opt("A", "Heavy Linen Bandage", 47, { { "Linen Cloth", 2 } }),
      Opt("B", "Minor Healing Potion", 86, { { "Peacebloom", 1 }, { "Mild Spices", 1 }, { "Empty Vial", 1 } }),
    }),

    Train("jm", 150, "Train Journeyman First Aid", 50, nil, { "Without it you stop gaining skill at 75.", TRAINERS }),

    Craft("a3", 75, 80, "Make a few more Heavy Linen Bandages", { Opt("A", "Heavy Linen Bandage", 13, { { "Linen Cloth", 2 } }) }),
    Craft("a4", 80, 115, "Make Wool Bandages", {
      Opt("A", "Wool Bandage", 52, { { "Wool Cloth", 1 } }),
      Opt("B", "Simple Poultice", 54, { { "Spider Ichor", 1 }, { "Mild Spices", 1 }, { "Bottle of Dalaran Noir", 1 } },
        { notes = { "From 90 to 125. Dalaran Noir: innkeepers and barkeeps in the capitals and Booty Bay." } }),
    }),
    Craft("a5", 115, 150, "Make Heavy Wool Bandages", {
      Opt("A", "Heavy Wool Bandage", 51, { { "Wool Cloth", 2 } }),
      Opt("B", "Healing Potion", 31, { { "Bruiseweed", 1 }, { "Hot Spices", 1 }, { "Leaded Vial", 1 } },
        { notes = { "From 125 to 150." } }),
    }, { "Learn Silk Bandage from your trainer before you leave. It's the last recipe trainers teach." }),

    { id = "expert", kind = "train", max = 225, title = "Get the Expert First Aid book", requires = { skill = 125 },
      notes = {
        { H = "Sold by Balai Lok'Wein in Dustwallow Marsh. No level requirement.", A = "Sold by Deneb Walker in Arathi Highlands. No level requirement." },
        "Buy all three books there: Expert First Aid - Under Wraps, Manual: Heavy Silk Bandage and Manual: Mageweave Bandage.",
        "Low level? The Auction House sells them too.",
      },
      gather = { { id = "Expert First Aid - Under Wraps", count = 1, note = "then read it" },
                 { id = "Manual: Heavy Silk Bandage", count = 1, note = "read at 180" },
                 { id = "Manual: Mageweave Bandage", count = 1, note = "read at 210" } },
      recipes = { "Expert First Aid - Under Wraps", "Manual: Heavy Silk Bandage", "Manual: Mageweave Bandage" } },

    Craft("a6", 150, 180, "Make Silk Bandages", { Opt("A", "Silk Bandage", 44, { { "Silk Cloth", 1 } }) }),
    Craft("a7", 180, 210, "Make Heavy Silk Bandages", { Opt("A", "Heavy Silk Bandage", 44, { { "Silk Cloth", 2 } }) },
      { "Read Manual: Heavy Silk Bandage first." }),
    Craft("a8", 210, 225, "Make Mageweave Bandages", { Opt("A", "Mageweave Bandage", 19, { { "Mageweave Cloth", 1 } }) },
      { "Read Manual: Mageweave Bandage first.", "You can't pass 225 until level 35." }),

    { id = "triage", kind = "quest", quest = { H = 6622, A = 6624 }, max = 300, title = "Artisan quest: Triage",
      requires = { level = 35, skill = 225 },
      notes = {
        { H = "Doctor Gregory Victor in Hammerfall (Arathi Highlands).", A = "Doctor Gustaf VanHowzen in Theramore (Dustwallow Marsh)." },
        "Heal 15 patients with the quest's own bandages. Critical patients first.",
        "Turn on health bars (Ctrl+V) and stand in the middle of the room.",
        "Hand it in the moment you've saved 15, or it can fail.",
        "Bring about 90 Mageweave Cloth and 70 Runecloth: the doctor teaches the next recipes.",
        "Quest not showing? Someone else may be talking to him. Wait and try again.",
      },
      gather = { { id = "Mageweave Cloth", count = 90 }, { id = "Runecloth", count = 70 } } },

    Craft("a9", 225, 240, "Make Mageweave Bandages", { Opt("A", "Mageweave Bandage", 26, { { "Mageweave Cloth", 1 } }) }),
    Craft("a10", 240, 260, "Make Heavy Mageweave Bandages", { Opt("A", "Heavy Mageweave Bandage", 30, { { "Mageweave Cloth", 2 } }) },
      { "The doctor teaches it at 240." }),
    Craft("a11", 260, 290, "Make Runecloth Bandages", {
      Opt("A", "Runecloth Bandage", 44, { { "Runecloth", 1 } }),
      Opt("B", "Major Healing Potion", 30, { { "Golden Sansam", 1 }, { "Soothing Spices", 3 }, { "Crystal Vial", 1 } },
        { notes = { "From 275 to 300 instead of bandages.", "Manual: Major Healing Potion: Auction House, or Pexmit in Mount Hyjal (8 gold)." } }),
    }, { "The doctor teaches it at 260." }),
    Craft("a12", 290, 300, "Make Heavy Runecloth Bandages", { Opt("A", "Heavy Runecloth Bandage", 12, { { "Runecloth", 2 } }) },
      { "The doctor teaches it at 290." }),
  },
})
