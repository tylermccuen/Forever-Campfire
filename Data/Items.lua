-- Item names used by the guides. Counting falls back to these names if an ID
-- turns out to differ in WoW Forever, so keep the names exact.
local _, ns = ...
ns.Items = ns.Items or {}
local I = ns.Items

-- Fish (raw / cooked)
I[6291]  = "Raw Brilliant Smallfish";     I[6290]  = "Brilliant Smallfish"
I[6303]  = "Raw Slitherskin Mackerel";    I[787]   = "Slitherskin Mackerel"
I[6289]  = "Raw Longjaw Mud Snapper";     I[4592]  = "Longjaw Mud Snapper"
I[6361]  = "Raw Rainbow Fin Albacore";    I[5095]  = "Rainbow Fin Albacore"
I[6308]  = "Raw Bristle Whisker Catfish"; I[4593]  = "Bristle Whisker Catfish"
I[8365]  = "Raw Mithril Head Trout";      I[8364]  = "Mithril Headed Trout"
I[4603]  = "Raw Spotted Yellowtail";      I[6887]  = "Spotted Yellowtail"
I[13758] = "Raw Redgill";                 I[13930] = "Filet of Redgill"
I[13759] = "Raw Nightfin Snapper";        I[13931] = "Nightfin Soup"
I[6362]  = "Raw Rockscale Cod"

-- Other cooking materials
I[5504]  = "Tangy Clam Meat";  I[5527]  = "Goblin Deviled Clams"
I[2692]  = "Hot Spices"
I[12184] = "Raptor Flesh";     I[12210] = "Roast Raptor"
I[12207] = "Giant Egg"
I[7974]  = "Zesty Clam Meat"
I[8932]  = "Alterac Swiss"
I[159]   = "Refreshing Spring Water"
I[4470]  = "Simple Wood"
I[4471]  = "Flint and Tinder"

-- Fishing gear and lures
I[6256]  = "Fishing Pole"
I[6529]  = "Shiny Bauble"
I[6530]  = "Nightcrawlers"
I[6532]  = "Bright Baubles"
I[6533]  = "Aquadynamic Fish Attractor"

-- Artisan Fishing quest fish (Nat Pagle, Angler Extreme)
I[16967] = "Feralas Ahi"
I[16968] = "Sar'theris Striker"
I[16969] = "Savage Coast Blue Sailfin"
I[16970] = "Misty Reed Mahi Mahi"

-- Mining: tool, ores, bars
I[2901]  = "Mining Pick"
I[2770]  = "Copper Ore";  I[2771] = "Tin Ore";  I[2775] = "Silver Ore";  I[2772] = "Iron Ore"
I[2776]  = "Gold Ore";    I[3858] = "Mithril Ore";  I[7911] = "Truesilver Ore";  I[10620] = "Thorium Ore"
I[2840]  = "Copper Bar";  I[3576] = "Tin Bar";  I[2841] = "Bronze Bar";  I[2842] = "Silver Bar"

-- Herbalism
I[2447]  = "Peacebloom";  I[765]  = "Silverleaf";  I[2449] = "Earthroot"
I[785]   = "Mageroyal";   I[2450] = "Briarthorn";  I[3820] = "Stranglekelp"
I[2453]  = "Bruiseweed";  I[3355] = "Wild Steelbloom";  I[3356] = "Kingsblood";  I[3357] = "Liferoot"
I[3818]  = "Fadeleaf";    I[3821] = "Goldthorn";  I[3358] = "Khadgar's Whisker"
I[8831]  = "Purple Lotus";  I[4625] = "Firebloom";  I[8838] = "Sungrass";  I[8845] = "Ghost Mushroom"
I[13464] = "Golden Sansam";  I[8846] = "Gromsblood";  I[13463] = "Dreamfoil"
I[13465] = "Mountain Silversage";  I[13466] = "Plaguebloom"

-- Skinning: tool, leather
I[7005]  = "Skinning Knife"
I[2934]  = "Ruined Leather Scraps";  I[2318] = "Light Leather";  I[783] = "Light Hide"
I[2319]  = "Medium Leather";  I[4234] = "Heavy Leather";  I[4304] = "Thick Leather";  I[8170] = "Rugged Leather"

-- Rank-up books
I[16072] = "Expert Cookbook"
I[16083] = "Expert Fishing - The Bass and You"

-- Crafting materials (for icons and bank counts; data can use names directly)
I[2589] = "Linen Cloth";  I[2592] = "Wool Cloth";  I[4306] = "Silk Cloth";  I[4338] = "Mageweave Cloth";  I[14047] = "Runecloth"
I[2996] = "Bolt of Linen Cloth";  I[2997] = "Bolt of Woolen Cloth";  I[4305] = "Bolt of Silk Cloth";  I[4339] = "Bolt of Mageweave";  I[14048] = "Bolt of Runecloth"
I[2835] = "Rough Stone";  I[2836] = "Coarse Stone";  I[2838] = "Heavy Stone";  I[7912] = "Solid Stone";  I[12365] = "Dense Stone"
I[3575] = "Iron Bar";  I[3577] = "Gold Bar";  I[3859] = "Steel Bar";  I[3860] = "Mithril Bar";  I[12359] = "Thorium Bar";  I[6037] = "Truesilver Bar"
I[2880] = "Weak Flux";  I[3466] = "Strong Flux";  I[3857] = "Coal"
I[4232] = "Medium Hide";  I[4235] = "Heavy Hide";  I[8169] = "Thick Hide";  I[8171] = "Rugged Hide"
I[4289] = "Salt";  I[2320] = "Coarse Thread";  I[2321] = "Fine Thread";  I[4291] = "Silken Thread";  I[8343] = "Heavy Silken Thread";  I[14341] = "Rune Thread"
I[4340] = "Gray Dye";  I[6260] = "Blue Dye";  I[2604] = "Red Dye";  I[2325] = "Black Dye";  I[2605] = "Green Dye";  I[6261] = "Orange Dye"
I[3371] = "Empty Vial";  I[3372] = "Leaded Vial";  I[8925] = "Crystal Vial";  I[2678] = "Mild Spices"
I[10940] = "Strange Dust";  I[10938] = "Lesser Magic Essence";  I[10939] = "Greater Magic Essence";  I[11083] = "Soul Dust"
I[11137] = "Vision Dust";  I[11176] = "Dream Dust";  I[16204] = "Illusion Dust";  I[11174] = "Lesser Nether Essence"
I[6359] = "Firefin Snapper";  I[6371] = "Fire Oil";  I[13422] = "Stonescale Eel";  I[13423] = "Stonescale Oil";  I[8839] = "Blindweed"
I[5956] = "Blacksmith Hammer";  I[6219] = "Arclight Spanner";  I[6217] = "Copper Rod";  I[4359] = "Handful of Copper Bolts"
I[4357] = "Rough Blasting Powder";  I[4364] = "Coarse Blasting Powder";  I[4377] = "Heavy Blasting Powder";  I[10505] = "Solid Blasting Powder";  I[15992] = "Dense Blasting Powder"
I[4371] = "Bronze Tube";  I[4375] = "Whirring Bronze Gizmo";  I[4382] = "Bronze Framework";  I[10559] = "Mithril Tube";  I[10560] = "Unstable Trigger";  I[10561] = "Mithril Casing"
I[2862] = "Rough Sharpening Stone";  I[3470] = "Rough Grinding Stone";  I[3478] = "Coarse Grinding Stone";  I[3486] = "Heavy Grinding Stone";  I[7966] = "Solid Grinding Stone"
I[4234] = "Heavy Leather";  I[4265] = "Heavy Armor Kit";  I[4231] = "Cured Light Hide";  I[4233] = "Cured Medium Hide";  I[4236] = "Cured Heavy Hide"
I[1179] = "Ice Cold Milk";  I[3820] = "Stranglekelp";  I[3356] = "Kingsblood";  I[3357] = "Liferoot"

-- Items sold by vendors (used for vendor alerts and the shopping list tag)
ns.VendorNames = {
  ["Mote of Magic"] = true, ["Maple Seed"] = true, ["Stranglethorn Seed"] = true, ["Bottle of Dalaran Noir"] = true,
  ["Soothing Spices"] = true, ["Simple Wood"] = true,
}
ns.VendorItems = { [2692] = true, [8932] = true, [159] = true, [6530] = true, [6532] = true, [6529] = true, [4471] = true, [2901] = true, [7005] = true, [6256] = true,
  [2880] = true, [3466] = true, [3857] = true, [4289] = true, [2320] = true, [2321] = true, [4291] = true, [8343] = true, [14341] = true,
  [4340] = true, [6260] = true, [2604] = true, [2325] = true, [2605] = true, [6261] = true, [3371] = true, [3372] = true, [8925] = true,
  [2678] = true, [5956] = true, [6217] = true }
