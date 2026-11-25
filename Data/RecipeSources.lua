-- Where each recipe on the crafting routes is learned, from the Forever client
-- data. Shown under "Recipe:" in a step as a "Learn:" line.
--   START          known as soon as you learn the profession
--   T              taught by trainers (a number after it is the skill it's taught at)
--   "Item name", N a recipe item (plans, pattern, formula, schematic, manual) usable at skill N
-- Optional `who` replaces "your <profession> trainer" (text or { H =, A = }).
-- For recipe items, where to get the item, shown as a "go to" step before the craft:
--   at   = vendor and place, as "Name in Place" (text or { H =, A = }): "Go to <at> and buy <item>."
--   get  = anything else (text or { H =, A = }): "Get <item>: <get>."
--   bop  = true when it binds on pickup (buy it on the character that crafts)
--   pin  = key into ns.Pins.recipes for map pins of the vendor
-- Checked 2026-11-25. Cooking uses its recipe collection instead.
local _, ns = ...

ns.Lazy("RecipeSources", function()
  local START, T = "start", "trainer"
  local AH, AH_DROP = "the Auction House", "the Auction House (world drop)"
  local FA_BOOKS = { H = "Balai Lok'Wein in Dustwallow Marsh", A = "Deneb Walker in Arathi Highlands" }
  local ALC_ART = { H = "Rogvar in Stonard (Swamp of Sorrows)", A = "Kylanna Windwhisper in Feathermoon Stronghold (Feralas)" }
  local IMPERIAL = "a quest from Derotain Mudsipper in Tanaris (level 50)"
  local ENCH_EXPERT = { H = "the supply vendor by the Expert trainer in Sun Rock Retreat (Stonetalon Mountains)",
                        A = "the supply vendor by the Expert trainer at the Tower of Azora (Elwynn Forest)" }
  return {
    checked = "2026-11-25",

    firstaid = {
      ["Linen Bandage"] = { START },
      ["Heavy Linen Bandage"] = { T }, ["Minor Healing Potion"] = { T }, ["Simple Poultice"] = { T },
      ["Healing Potion"] = { T }, ["Wool Bandage"] = { T }, ["Heavy Wool Bandage"] = { T }, ["Silk Bandage"] = { T },
      ["Heavy Silk Bandage"] = { "Manual: Heavy Silk Bandage", 180, at = FA_BOOKS },
      ["Mageweave Bandage"] = { "Manual: Mageweave Bandage", 210, at = FA_BOOKS },
      ["Heavy Mageweave Bandage"] = { T, 240, who = "the doctor from the Triage quest" },
      ["Runecloth Bandage"] = { T, 260, who = "the doctor from the Triage quest" },
      ["Heavy Runecloth Bandage"] = { T, 290, who = "the doctor from the Triage quest" },
      ["Major Healing Potion"] = { "Manual: Major Healing Potion", 275, get = "the Auction House, or Pexmit in Mount Hyjal (8 gold)" },
    },

    alchemy = {
      ["Elixir of Minor Force"] = { START }, ["Elixir of Minor Defense"] = { START },
      ["Minor Mana Potion"] = { T }, ["Elixir of Minor Fortitude"] = { T, 50 }, ["Elixir of Wisdom"] = { T },
      ["Lesser Mana Potion"] = { T },
      ["Fire Oil"] = { T }, ["Elixir of Fire Power"] = { T }, ["Mana Potion"] = { T },
      ["Elixir of Greater Intellect"] = { T, 235, who = ALC_ART }, ["Stonescale Oil"] = { T, 250, who = ALC_ART },
      ["Nature Protection Potion"] = { "Recipe: Nature Protection Potion", 190, bop = true,
        at = { H = "Bronk in Camp Mojache (Feralas), Glyx Brewright (Stranglethorn) or Alchemist Pestlezugg (Tanaris)",
               A = "Logannas in Feathermoon Stronghold (Feralas), Glyx Brewright (Stranglethorn) or Alchemist Pestlezugg (Tanaris)" } },
      ["Elixir of Greater Defense"] = { "Recipe: Elixir of Superior Defense", 265, at = { H = "Kor'geld in Orgrimmar", A = "Soolie Berryfizz in Ironforge" } },
      ["Superior Mana Potion"] = { "Recipe: Superior Mana Potion", 260, at = { H = "Algernon in Undercity (the Apothecarium)", A = "Ulthir in Darnassus (Craftsmen's Terrace)" },
        pin = "Recipe: Superior Mana Potion" },
    },

    blacksmithing = {
      ["Rough Sharpening Stone"] = { START },
      ["Rough Grinding Stone"] = { T }, ["Coarse Grinding Stone"] = { T }, ["Silver Rod"] = { T },
      ["Runed Copper Belt"] = { T }, ["Rough Bronze Leggings"] = { T }, ["Patterned Bronze Bracers"] = { T },
      ["Heavy Grinding Stone"] = { T }, ["Silvered Bronze Gauntlets"] = { T }, ["Bronze Warhammer"] = { T },
      ["Green Iron Bracers"] = { T }, ["Solid Grinding Stone"] = { T }, ["Golden Scale Bracers"] = { T },
      ["Mithril Plate Pants"] = { T }, ["Heavy Mithril Axe"] = { T }, ["Mithril Coif"] = { T },
      ["Dense Sharpening Stone"] = { T }, ["Heavy Mithril Boots"] = { T },
      ["Mithril Spurs"] = { "Plans: Mithril Spurs", 210, get = AH_DROP },
      ["Imperial Plate Belt"] = { "Plans: Imperial Plate Belt", 240, get = IMPERIAL },
      ["Imperial Plate Bracers"] = { "Plans: Imperial Plate Bracers", 245, get = IMPERIAL },
      ["Thorium Belt"] = { "Plans: Thorium Belt", 225, get = AH },
      ["Radiant Boots"] = { "Plans: Radiant Boots", 265, get = AH },
      ["Radiant Leggings"] = { "Plans: Radiant Leggings", 280, get = AH },
      ["Thorium Leggings"] = { "Plans: Thorium Leggings", 275, get = AH },
      ["Imperial Plate Boots"] = { "Plans: Imperial Plate Boots", 270, get = IMPERIAL },
      ["Imperial Plate Leggings"] = { "Plans: Imperial Plate Leggings", 280, get = IMPERIAL },
    },

    enchanting = {
      ["Runed Copper Rod"] = { START }, ["Enchant Bracer - Inferior Stamina"] = { START },
      ["Enchant Bracer - Minor Deflect"] = { START },
      ["Enchant Chest - Inferior Stamina"] = { T }, ["Enchant Chest - Minor Absorption"] = { T },
      ["Enchant Bracer - Minor Stamina"] = { T }, ["Runed Silver Rod"] = { T }, ["Greater Magic Wand"] = { T },
      ["Enchant Bracer - Lesser Stamina"] = { T }, ["Runed Golden Rod"] = { T },
      ["Enchant Boots - Lesser Agility"] = { T }, ["Enchant Bracer - Strength"] = { T },
      ["Runed Truesilver Rod"] = { T }, ["Enchant Cloak - Greater Defense"] = { T },
      ["Enchant Gloves - Agility"] = { T }, ["Enchant Bracer - Greater Strength"] = { T },
      ["Enchant Cloak - Minor Protection"] = { "Formula: Imbue Cloak - Protection", 90 },
      ["Enchant 2H Weapon - Lesser Intellect"] = { "Formula: Enchant 2H Weapon - Lesser Intellect", 100,
        at = { H = "Kithas in Orgrimmar, Nata Dawnstrider in Thunder Bluff or Leo Sarn in Silverpine", A = "Tilli Thistlefuzz in Ironforge" } },
      ["Enchant Boots - Minor Stamina"] = { "Formula: Enchant Boots - Minor Stamina", 125 },
      ["Minor Mana Oil"] = { "Formula: Minor Mana Oil", 150, get = ENCH_EXPERT },
      ["Lesser Wizard Oil"] = { "Formula: Lesser Wizard Oil", 200, get = ENCH_EXPERT },
      ["Lesser Mana Oil"] = { "Formula: Lesser Mana Oil", 250, at = "Kania in Silithus (upstairs in the inn)" },
      ["Enchant Shield - Greater Stamina"] = { "Formula: Enchant Shield - Greater Stamina", 265, bop = true,
        at = { H = "Daniel Bartlett in Undercity", A = "Mythrin'dir in Darnassus" } },
      ["Wizard Oil"] = { "Formula: Wizard Oil", 275, at = "Kania in Silithus (upstairs in the inn)" },
      ["Runed Arcanite Rod"] = { "Formula: Runed Arcanite Rod", 290, at = "Lorelae Wintersong in Nighthaven (Moonglade)" },
    },

    engineering = {
      ["Rough Blasting Powder"] = { START },
      ["Handful of Copper Bolts"] = { T }, ["Arclight Spanner"] = { T }, ["Rough Copper Bomb"] = { T },
      ["Coarse Blasting Powder"] = { T }, ["Coarse Dynamite"] = { T }, ["Silver Contact"] = { T },
      ["Flying Tiger Goggles"] = { T }, ["Bronze Tube"] = { T }, ["Standard Scope"] = { T },
      ["Heavy Blasting Powder"] = { T }, ["Whirring Bronze Gizmo"] = { T },
      ["Heavy Blasting Powder and Whirring Bronze Gizmo"] = { T },
      ["Bronze Framework"] = { T }, ["Explosive Sheep"] = { T }, ["Solid Blasting Powder"] = { T },
      ["Gyromatic Micro-Adjustor"] = { T }, ["Iron Grenade"] = { T },
      ["Gyromatic Micro-Adjustor and Iron Grenade"] = { T },
      ["Mithril Tube"] = { T }, ["Unstable Trigger"] = { T }, ["Mithril Casing"] = { T },
      ["Hi-Explosive Bomb"] = { T }, ["Dense Blasting Powder"] = { T },
      ["Thorium Widget"] = { "Schematic: Thorium Widget", 260, at = { H = "Sovik in Orgrimmar", A = "Gearcutter Cogspinner in Ironforge" } },
      ["Thorium Grenade"] = { "Schematic: Thorium Grenade", 260, at = { H = "Sovik in Orgrimmar", A = "Gearcutter Cogspinner in Ironforge" } },
      ["Thorium Tube"] = { "Schematic: Thorium Tube", 275, bop = true, at = "Xizzer Fizzbolt in Everlook (Winterspring) or Kor'gar in Riverglades" },
      ["Thorium Shells"] = { "Schematic: Thorium Shells", 285 },
    },

    leatherworking = {
      ["Light Leather"] = { START }, ["Light Armor Kit"] = { START },
      ["Cured Light Hide"] = { T }, ["Embossed Leather Gloves"] = { T }, ["Embossed Leather Pants"] = { T },
      ["Cured Medium Hide"] = { T }, ["Fine Leather Belt"] = { T }, ["Dark Leather Belt"] = { T },
      ["Dark Leather Pants"] = { T }, ["Hillman's Leather Gloves"] = { T }, ["Heavy Leather"] = { T },
      ["Cured Heavy Hide"] = { T }, ["Barbaric Shoulders"] = { T }, ["Guardian Gloves"] = { T },
      ["Barbaric Harness"] = { T }, ["Thick Armor Kit"] = { T }, ["Nightscape Headband"] = { T },
      ["Nightscape Pants"] = { T },
      ["Barbaric Leggings"] = { "Pattern: Barbaric Leggings", 145,
        at = { H = "Jandia at Freewind Post (Thousand Needles)", A = "Lardan in Astranaar (Ashenvale)" } },
      ["Wicked Leather Gauntlets"] = { "Pattern: Wicked Leather Gauntlets", 235,
        at = { H = "Werg Thickblade in Tirisfal Glades", A = "Leonard Porter in Western Plaguelands" } },
      ["Wicked Leather Headband"] = { "Pattern: Wicked Leather Headband", 255 },
      ["Blue Suede Shoes"] = { "Pattern: Blue Suede Shoes", 235 },
      ["Runic Leather Headband"] = { "Pattern: Runic Leather Headband", 265, at = "Jase Farlane at Light's Hope Chapel (Eastern Plaguelands)" },
    },

    tailoring = {
      ["Bolt of Linen Cloth"] = { START },
      ["Linen Belt"] = { T }, ["Bolt of Woolen Cloth"] = { T }, ["Woolen Cape"] = { T },
      ["Double-stitched Woolen Shoulders"] = { T }, ["Bolt of Silk Cloth"] = { T }, ["Azure Silk Hood"] = { T },
      ["Small Silk Pack"] = { T }, ["Bolt of Mageweave"] = { T }, ["Crimson Silk Vest"] = { T },
      ["Crimson Silk Pantaloons"] = { T }, ["Black Mageweave Leggings"] = { T },
      ["Black Mageweave Shoulders"] = { T }, ["Bolt of Runecloth"] = { T }, ["Red Mageweave Bag"] = { T },
      ["Runecloth Belt"] = { T },
      ["Runecloth Gloves"] = { "Pattern: Runecloth Gloves", 230, at = "Qia in Everlook (Winterspring), in the left corner of the bank" },
      ["Brightcloth Cloak"] = { "Pattern: Brightcloth Cloak", 230 },
      ["Runecloth Cuffs"] = { "Pattern: Runecloth Cuffs", 250, bop = true, at = "Pexmit in Mount Hyjal (hard to find)" },
      ["Runecloth Shoulders"] = { "Pattern: Runecloth Shoulders", 260, get = AH_DROP },
    },
  }
end)
