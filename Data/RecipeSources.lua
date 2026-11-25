-- Where each recipe on the crafting routes is learned, from the Forever client
-- data. Shown under "Recipe:" in a step as a "Learn:" line.
--   START          known as soon as you learn the profession
--   T              taught by trainers (a number after it is the skill it's taught at)
--   "Item name", N a recipe item (plans, pattern, formula, schematic, manual) usable at skill N
-- Optional `who` replaces "your <profession> trainer".
-- Checked 2026-11-25. Cooking uses its recipe collection instead.
local _, ns = ...

ns.Lazy("RecipeSources", function()
  local START, T = "start", "trainer"
  return {
    checked = "2026-11-25",

    firstaid = {
      ["Linen Bandage"] = { START },
      ["Heavy Linen Bandage"] = { T }, ["Minor Healing Potion"] = { T }, ["Simple Poultice"] = { T },
      ["Healing Potion"] = { T }, ["Wool Bandage"] = { T }, ["Heavy Wool Bandage"] = { T }, ["Silk Bandage"] = { T },
      ["Heavy Silk Bandage"] = { "Manual: Heavy Silk Bandage", 180 },
      ["Mageweave Bandage"] = { "Manual: Mageweave Bandage", 210 },
      ["Heavy Mageweave Bandage"] = { T, 240, who = "the doctor from the Triage quest" },
      ["Runecloth Bandage"] = { T, 260, who = "the doctor from the Triage quest" },
      ["Heavy Runecloth Bandage"] = { T, 290, who = "the doctor from the Triage quest" },
      ["Major Healing Potion"] = { "Manual: Major Healing Potion", 275 },
    },

    alchemy = {
      ["Elixir of Minor Force"] = { START }, ["Elixir of Minor Defense"] = { START },
      ["Minor Mana Potion"] = { T }, ["Elixir of Minor Fortitude"] = { T, 50 }, ["Elixir of Wisdom"] = { T },
      ["Lesser Mana Potion"] = { T },
      ["Fire Oil"] = { T }, ["Elixir of Fire Power"] = { T }, ["Mana Potion"] = { T },
      ["Elixir of Greater Intellect"] = { T, 235 }, ["Stonescale Oil"] = { T, 250 },
      ["Nature Protection Potion"] = { "Recipe: Nature Protection Potion", 190 },
      ["Elixir of Greater Defense"] = { "Recipe: Elixir of Superior Defense", 265 },
      ["Superior Mana Potion"] = { "Recipe: Superior Mana Potion", 260 },
    },

    blacksmithing = {
      ["Rough Sharpening Stone"] = { START },
      ["Rough Grinding Stone"] = { T }, ["Coarse Grinding Stone"] = { T }, ["Silver Rod"] = { T },
      ["Runed Copper Belt"] = { T }, ["Rough Bronze Leggings"] = { T }, ["Patterned Bronze Bracers"] = { T },
      ["Heavy Grinding Stone"] = { T }, ["Silvered Bronze Gauntlets"] = { T }, ["Bronze Warhammer"] = { T },
      ["Green Iron Bracers"] = { T }, ["Solid Grinding Stone"] = { T }, ["Golden Scale Bracers"] = { T },
      ["Mithril Plate Pants"] = { T }, ["Heavy Mithril Axe"] = { T }, ["Mithril Coif"] = { T },
      ["Dense Sharpening Stone"] = { T }, ["Heavy Mithril Boots"] = { T },
      ["Mithril Spurs"] = { "Plans: Mithril Spurs", 210 },
      ["Imperial Plate Belt"] = { "Plans: Imperial Plate Belt", 240 },
      ["Imperial Plate Bracers"] = { "Plans: Imperial Plate Bracers", 245 },
      ["Thorium Belt"] = { "Plans: Thorium Belt", 225 },
      ["Radiant Boots"] = { "Plans: Radiant Boots", 265 },
      ["Radiant Leggings"] = { "Plans: Radiant Leggings", 280 },
      ["Thorium Leggings"] = { "Plans: Thorium Leggings", 275 },
      ["Imperial Plate Boots"] = { "Plans: Imperial Plate Boots", 270 },
      ["Imperial Plate Leggings"] = { "Plans: Imperial Plate Leggings", 280 },
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
      ["Enchant 2H Weapon - Lesser Intellect"] = { "Formula: Enchant 2H Weapon - Lesser Intellect", 100 },
      ["Enchant Boots - Minor Stamina"] = { "Formula: Enchant Boots - Minor Stamina", 125 },
      ["Minor Mana Oil"] = { "Formula: Minor Mana Oil", 150 },
      ["Lesser Wizard Oil"] = { "Formula: Lesser Wizard Oil", 200 },
      ["Lesser Mana Oil"] = { "Formula: Lesser Mana Oil", 250 },
      ["Enchant Shield - Greater Stamina"] = { "Formula: Enchant Shield - Greater Stamina", 265 },
      ["Wizard Oil"] = { "Formula: Wizard Oil", 275 },
      ["Runed Arcanite Rod"] = { "Formula: Runed Arcanite Rod", 290 },
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
      ["Thorium Widget"] = { "Schematic: Thorium Widget", 260 },
      ["Thorium Grenade"] = { "Schematic: Thorium Grenade", 260 },
      ["Thorium Tube"] = { "Schematic: Thorium Tube", 275 },
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
      ["Barbaric Leggings"] = { "Pattern: Barbaric Leggings", 145 },
      ["Wicked Leather Gauntlets"] = { "Pattern: Wicked Leather Gauntlets", 235 },
      ["Wicked Leather Headband"] = { "Pattern: Wicked Leather Headband", 255 },
      ["Blue Suede Shoes"] = { "Pattern: Blue Suede Shoes", 235 },
      ["Runic Leather Headband"] = { "Pattern: Runic Leather Headband", 265 },
    },

    tailoring = {
      ["Bolt of Linen Cloth"] = { START },
      ["Linen Belt"] = { T }, ["Bolt of Woolen Cloth"] = { T }, ["Woolen Cape"] = { T },
      ["Double-stitched Woolen Shoulders"] = { T }, ["Bolt of Silk Cloth"] = { T }, ["Azure Silk Hood"] = { T },
      ["Small Silk Pack"] = { T }, ["Bolt of Mageweave"] = { T }, ["Crimson Silk Vest"] = { T },
      ["Crimson Silk Pantaloons"] = { T }, ["Black Mageweave Leggings"] = { T },
      ["Black Mageweave Shoulders"] = { T }, ["Bolt of Runecloth"] = { T }, ["Red Mageweave Bag"] = { T },
      ["Runecloth Belt"] = { T },
      ["Runecloth Gloves"] = { "Pattern: Runecloth Gloves", 230 },
      ["Brightcloth Cloak"] = { "Pattern: Brightcloth Cloak", 230 },
      ["Runecloth Cuffs"] = { "Pattern: Runecloth Cuffs", 250 },
      ["Runecloth Shoulders"] = { "Pattern: Runecloth Shoulders", 260 },
    },
  }
end)
