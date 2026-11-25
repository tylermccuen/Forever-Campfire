-- Camping: campfires and every profession's camp items (tier 1 to 3).
-- Checked 2026-11-24. Tier 1 is learned at skill 20 from the trainer or the
-- Camping 101 quest; tiers 2 and 3 need a Blueprint (mostly dungeon boss drops).
-- Each tier replaces the one before it.
local _, ns = ...

local function T(tier, name, skill, effect, mats, learn, station)
  return { tier = tier, name = name, skill = skill, effect = effect, mats = mats, learn = learn, station = station }
end
local T1LEARN = "Trainer at skill 20, or the Camping 101 quest in the starting zones"

ns.Camp = {
  checked = "2026-11-24",
  rules = {
    "Someone places a campfire. Everyone at it can add one camp item from their profession.",
    "Sit (/sit) by the fire for about a minute to get Camp Benefits: every item's buff, for 1 hour.",
    "Placing an item puts all your camp items on a 1-hour cooldown.",
    "Camp buffs are weaker versions of class buffs and don't stack with them.",
    "Basic Campfire holds 3 items, Journeyman 5, Expert 10.",
    "Anyone at the camp can use a crafting station someone else placed, without the skill.",
    "Stations are sold on the Auction House too: you only need the skill to place one.",
  },
  fires = {
    T(1, "Basic Campfire Kit", 1, "Campfire with 3 item slots", { { "Simple Wood", 1 } }, "Comes with Cooking"),
    T(2, "Journeyman Campfire Kit", 90, "Campfire with 5 item slots", { { "Star Wood", 1 } }, "Blueprint: Journeyman Campfire, from Lord Serpentis (Wailing Caverns)"),
    T(3, "Expert Campfire Kit", 200, "Campfire with 10 item slots (used at Cooking 220)", { { "Thick Logs", 1 } }, "Blueprint: Expert Campfire, drop location not known yet"),
  },
  items = {
    alchemy = {
      T(1, "Mana Well", 20, "Mana regeneration (not with Blessing of Wisdom)", { { "Peacebloom", 1 }, { "Empty Vial", 1 } }, T1LEARN),
      T(2, "Fermenter", 140, "Station for some Alchemy recipes", { { "Leaded Vial", 1 }, { "Kingsblood", 1 }, { "Swiftthistle", 1 } }, "Blueprint from Rath'mael (Ruins of Lordaeron)", true),
      T(3, "Alchemy Laboratory", 300, "Station for some Alchemy recipes", { { "Lich's Index Finger", 1 }, { "Crystal Vial", 1 }, { "Dreamfoil", 2 } }, "Blueprint from Ras Frostwhisper (Scholomance)", true),
    },
    blacksmithing = {
      T(1, "Sharpening Wheel", 20, "Strength (not with Strength of Earth Totem)", { { "Rough Stone", 1 }, { "Copper Bar", 1 } }, T1LEARN),
      T(2, "Anvil", 140, "An anvil at camp", { { "Bronze Bar", 5 }, { "Coarse Grinding Stone", 2 }, { "Medium Leather", 2 } }, "Blueprint from Gilnid (The Deadmines)", true),
      T(3, "Master Forge", 300, "Station for many Blacksmithing recipes", { { "Golem Heart", 1 }, { "Thorium Bar", 5 }, { "Rugged Leather", 2 } }, "Blueprint from Golem Lord Argelmach (Blackrock Depths)", true),
    },
    enchanting = {
      T(1, "Enchanted Lute", 20, "Armor, all stats and resistances (not with Mark of the Wild)", { { "Simple Wood", 1 }, { "Strange Dust", 1 } }, T1LEARN),
      T(2, "Arcane Salvager", 140, "Better disenchanting", { { "Vision Dust", 2 }, { "Lesser Nether Essence", 1 } }, "Blueprint from Shade of the Archmage (City of Dalaran)"),
      T(3, "Arcane Forge", 300, "Station for some Enchanting recipes", { { "Maker's Spark", 1 }, { "Large Brilliant Shard", 2 }, { "Greater Eternal Essence", 4 } }, "Blueprint from Nanaya (Kalimdor)", true),
    },
    engineering = {
      T(1, "Reagent Bot", 20, "Vendor with class reagents and profession supplies for the camp", { { "Handful of Copper Bolts", 1 }, { "Copper Tube", 1 } }, T1LEARN),
      T(2, "Repair Bot", 140, "Repairs for everyone at the camp", { { "Whirring Bronze Gizmo", 2 }, { "Bronze Tube", 1 }, { "Heavy Leather", 1 } }, "Blueprint from Sneed (The Deadmines)"),
      T(3, "Anarchist's Workbench", 300, "Station for some Engineering recipes", { { "Essence of Anarchy", 1 }, { "Thorium Widget", 2 } }, "Blueprint from Ezra Grimm (Stratholme)", true),
    },
    leatherworking = {
      T(1, "Camp Tent", 20, "Rested XP, up to 5% of a level once an hour", { { "Light Leather", 5 } }, T1LEARN),
      T(2, "Tanning Rack", 125, "Station for many Leatherworking recipes", { { "Medium Leather", 5 }, { "Fine Thread", 3 }, { "Simple Wood", 2 } }, "Blueprint from Razorclaw the Butcher (Shadowfang Keep)", true),
      T(3, "Sewing Machine", 300, "Station for many Leatherworking recipes", { { "Undeath Engine", 1 }, { "Rugged Leather", 5 }, { "Rune Thread", 1 } }, "Blueprint from Vectus (Scholomance)", true),
    },
    tailoring = {
      T(1, "Faction Banner", 20, "Spirit for your faction (not with Divine Spirit)", { { "Bolt of Linen Cloth", 1 }, { "Coarse Thread", 1 } }, T1LEARN),
      T(2, "Spinning Wheel", 140, "Station for many Tailoring recipes", { { "Simple Wood", 2 }, { "Bolt of Silk Cloth", 5 }, { "Fine Thread", 3 } }, "Blueprint from Unstable Sentinel (City of Dalaran)", true),
      T(3, "Loom", 300, "Station for many Tailoring recipes", { { "Bottled Screams", 1 }, { "Bolt of Runecloth", 4 }, { "Simple Wood", 4 } }, "Blueprint from Baroness Anastari (Stratholme)", true),
    },
    herbalism = {
      T(1, "Incense Candle", 20, "Intellect (not with Arcane Intellect)", { { "Peacebloom", 1 }, { "Silverleaf", 1 } }, T1LEARN),
      T(2, "Greenhouse", 140, "Grows herbs from seeds you plant", { { "Simple Wood", 2 }, { "Arthas' Tears", 1 }, { "Purple Lotus", 1 } }, "Blueprint from Shadetooth (Excavation Site, Wetlands)"),
      T(3, "Seed Hybridizer", 300, "Multiplies seeds or combines them into rarer ones", { { "Mountain Silversage", 4 }, { "Crystal Vial", 1 }, { "Runecloth", 2 } }, "Blueprint: source not known yet"),
    },
    mining = {
      T(1, "Lodestone", 20, "Melee attack power (not with Blessing of Might)", { { "Rough Stone", 1 }, { "Copper Bar", 1 } }, T1LEARN),
      T(2, "Rock Garden", 140, "Spawns a common mining node over time, plus the Lodestone buff", { { "Heavy Stone", 2 }, { "Iron Ore", 1 }, { "Silver Bar", 1 } }, "Blueprint from Relic Guardian (Excavation Site, Wetlands)"),
      T(3, "Molten Foundry", 300, "Needed for Smelt Heavy Thorium", { { "Thorium Bar", 5 }, { "Dense Stone", 2 }, { "Truesilver Bar", 1 } }, "Blueprint from Ambassador Flamelash (Blackrock Depths)", true),
    },
    skinning = {
      T(1, "Camp Chair", 20, "+2% crit (not with Moonkin Aura)", { { "Light Leather", 3 }, { "Simple Wood", 2 } }, T1LEARN),
      T(2, "Field Guide", 140, "A book anyone can read to learn Track Beasts", { { "Medium Leather", 3 }, { "Slimy Murloc Scale", 2 }, { "Fine Thread", 1 } }, "Blueprint from Lady Anacondra (Wailing Caverns)"),
      T(3, "Trapper's Workbench", 300, "A workbench with a trap", { { "Simple Wood", 2 }, { "Heavy Leather", 4 }, { "Iron Bar", 1 } }, "Blueprint from The Beast (Upper Blackrock Spire) or Houndmaster Loksey (Scarlet Monastery)"),
    },
    cooking = {
      T(1, "Basic Campfire Kit", 1, "Cooking's tier 1 is the campfire itself", { { "Simple Wood", 1 } }, "Comes with Cooking"),
      T(2, "Cookie's Feast", 140, "Stamina food for everyone at the camp", { { "Mystery Meat", 2 }, { "Heavy Kodo Meat", 1 }, { "Soothing Spices", 1 } }, "Blueprint from Cookie (The Deadmines)"),
      T(3, "Iron Oven", 300, "Needed for the most advanced Cooking recipes", { { "Simple Flour", 10 }, { "Refreshing Spring Water", 5 }, { "Soothing Spices", 4 } }, "Blueprint from Quartermaster Zigris (Lower Blackrock Spire)", true),
    },
    firstaid = {
      T(1, "First Aid Kit", 20, "Stamina (not with Power Word: Fortitude)", { { "Linen Bandage", 3 }, { "Refreshing Spring Water", 1 } }, T1LEARN),
      T(2, "Toxin Study", 140, "Healing potions and anti-venom", { { "Anti-Venom", 1 }, { "Mageweave Bandage", 2 }, { "Simple Wood", 2 } }, "Blueprint from Commander Springvale (Shadowfang Keep)"),
      T(3, "Plague Doctor's Laboratory", 300, "Healing potions and poultices", { { "Simple Wood", 2 }, { "Strong Anti-Venom", 2 }, { "Heavy Runecloth Bandage", 5 } }, "Blueprint from Doctor Theolen Krastinov (Scholomance)"),
    },
    fishing = {
      T(1, "Fish Bowl", 20, "+8% all stats (not with Blessing of Kings)", { { "Raw Brilliant Smallfish", 1 }, { "Empty Vial", 1 } }, T1LEARN),
      T(2, "Fishing Rack", 140, "Uncommon fish for 1 hour, plus lures", { { "Simple Wood", 2 }, { "Crystal Vial", 1 }, { "Raw Mithril Head Trout", 2 } }, "Blueprint from Gelihast (Blackfathom Deeps)"),
      T(3, "Fishing Hut", 300, "Rare fish for 1 hour, plus lures", { { "Simple Wood", 5 }, { "Bolt of Runecloth", 2 }, { "Seasonal Fish Steaks", 1 } }, "Blueprint from Jammal'an the Prophet (Sunken Temple)"),
    },
  },
  order = { "cooking", "fishing", "firstaid", "alchemy", "blacksmithing", "enchanting", "engineering", "herbalism", "leatherworking", "mining", "skinning", "tailoring" },
}
