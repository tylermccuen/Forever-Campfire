-- Fishing + Cooking together, 1-300: cook what you catch.
-- Route checked 2026-11-24.
-- Step format: see Data/Cooking.lua. Extra field here:
--   catch = {{itemID, expected}}  fish the step expects you to catch (shown with bag counts)
-- Steps without `count` in their options mean "cook all of them".
local _, ns = ...

-- The header is all the addon needs until this guide is opened or its
-- profession is learned; the rest is built on first use.
ns.LazyGuide({
  key = "both",
  capitalTrainer = false,   -- no trainer of its own (the welcome screen lists Fishing and Cooking)
  name = "Fish + Cook",
  skills = { "fishing", "cooking" },
  icon = "Interface\\Icons\\INV_Misc_Fish_02",
}, function()
ns.RegisterGuide({
  key = "both",
  recipePrefix = "Recipe: ",
  checked = "2026-11-24",
  steps = {
    { id = "learnf", kind = "learn", skill = "fishing", title = "Learn Fishing",
      notes = {
        { H = "Best start: Mulgore. Everything is close together.", A = "Best start: Elwynn Forest. Everything is close together." },
        { H = "Trainer: Uthan Stillwater, Stonebull Lake", A = "Trainer: Lee Brown, Crystal Lake (east of Goldshire)" },
        { H = "Buy from Harn Longcast (Bloodhoof Village): Fishing Pole, Shiny Bauble, Recipe: Brilliant Smallfish, Recipe: Longjaw Mud Snapper",
          A = "Buy from Tharynn Bouden (Goldshire): Fishing Pole, Shiny Bauble, Recipe: Brilliant Smallfish, Recipe: Longjaw Mud Snapper" },
        { "Or Durotar: trainer Lau'Tiki south of Sen'jin. Zansoa sells gear and Recipe: Slitherskin Mackerel.", f = "Horde" },
        { "Or Tirisfal: trainer Clyde Kellen at Brightwater Lake. Martine Tramblay (Death's Watch) sells Recipe: Brilliant Smallfish.", f = "Horde" },
        { "Or Dun Morogh: trainer Paxton Ganter at Iceflow Lake. Gretta Ganter sells Recipe: Brilliant Smallfish.", f = "Alliance" },
        { "Or Teldrassil: trainer Astaia in Darnassus. Nyoma (Dolanaar) sells both recipes. Gear from Narret Shadowgrove.", f = "Alliance" },
        "Or Zephras Isle (both factions): trainer Fenn Fairweather (Shen'dar) or Baelann Swiftcurrent (Valanaar).",
        "Buy any Aquadynamic Fish Attractors you see. You'll want them in Feralas."
      },
      buy = { { id = 6256, count = 1 }, { id = 6529, count = 1 } },
      recipes = { "Recipe: Brilliant Smallfish", "Recipe: Longjaw Mud Snapper", "Recipe: Slitherskin Mackerel" } },

    { id = "f75", kind = "level", skill = "fishing", from = 1, to = 75, title = "Fish your starter lake", lure = 6529,
      catch = { { 6291, 45 }, { 6289, 30 } },
      notes = {
        { H = "Where: Stonebull Lake (Mulgore).", A = "Where: Crystal Lake, east of Goldshire." },
        { H = "Started in Durotar? Fish next to Lau'Tiki instead (about 70 Slitherskin Mackerel).", A = "Started in Teldrassil? Fish Lake Al'Ameth, south of Dolanaar." },
        "Keep every fish: they're your Cooking materials.",
      } },

    { id = "fjm", kind = "train", skill = "fishing", max = 150, title = "Train Journeyman Fishing", requires = { skill = 50, level = 10 },
      notes = { "Same trainer you learned Fishing from." } },

    { id = "f130", kind = "level", skill = "fishing", from = 75, to = 130, title = "Fish in your capital",
      catch = { { 6291, 20 }, { 6289, 60 }, { 6308, 30 } },
      notes = {
        { H = "Where: the Thunder Bluff pond by the Auction House. Also fine: Undercity canals, Valley of Honor pond (Orgrimmar).",
          A = "Where: Stormwind City canals." },
        { H = "Buy Recipe: Bristle Whisker Catfish from Naal Mistrunner (Thunder Bluff) or Ronald Burch (Undercity).",
          A = "Buy Recipe: Bristle Whisker Catfish from Catherine Leland (Stormwind)." },
        { "Also buy 20 Alterac Swiss from Ben Trias (Stormwind). You need them for the Artisan Cooking quest.", f = "Alliance" },
      },
      recipes = { "Recipe: Bristle Whisker Catfish" },
      buy = { { id = 8932, count = 20, note = "for Clamlette Surprise later", f = "Alliance" } } },

    { id = "learnc", kind = "learn", skill = "cooking", title = "Learn Cooking",
      notes = { { H = "Trainers: Aska Mistrunner (Thunder Bluff), Eunice Burch (Undercity), Zamja (Orgrimmar)", A = "Trainer: Stephen Ryback (Stormwind)" } } },

    { id = "c50", kind = "level", skill = "cooking", from = 1, to = 50, title = "Cook your smallfish",
      options = {
        { label = "A", recipe = "Brilliant Smallfish", product = 6290, mats = { { 6291, 1 } } },
        { label = "B", recipe = "Slitherskin Mackerel", product = 787, mats = { { 6303, 1 } } },
      },
      notes = { "A few points short of 50? Catch and cook more." } },

    { id = "cjm", kind = "train", skill = "cooking", max = 150, title = "Train Journeyman Cooking", requires = { skill = 50 },
      notes = { "Same Cooking trainer." } },

    { id = "c100", kind = "level", skill = "cooking", from = 50, to = 100, title = "Cook your Longjaw", soft = { 6289 },
      options = { { label = "A", recipe = "Longjaw Mud Snapper", product = 4592, mats = { { 6289, 1 } } } },
      notes = { "You may not reach 100 yet. That's fine: more Longjaw comes later." } },

    { id = "fexp", kind = "train", skill = "fishing", max = 225, title = "Booty Bay: Expert Fishing book", requires = { skill = 125, level = 20 },
      notes = {
        "Take the boat from Ratchet to Booty Bay.",
        "Buy and read Expert Fishing - The Bass and You from Old Man Heming.",
        "Buy Recipe: Mithril Head Trout and Recipe: Filet of Redgill from Kelsey Yance.",
      },
      gather = { { id = 16083, count = 1, note = "then read it" } },
      recipes = { "Recipe: Mithril Head Trout", "Recipe: Filet of Redgill" } },

    { id = "f205", kind = "level", skill = "fishing", from = 130, to = 205, title = "Fish to 205, buy the Expert Cookbook", lure = 6530,
      catch = { { 6289, 95 }, { 6308, 145 } },
      options = {
        { label = "A", recipe = "Stonetalon, then Desolace", f = "Horde",
          notes = { "Fly from Ratchet to Sun Rock Retreat. Buy 7 Nightcrawlers from Kulwia. Save 5 for the Artisan quest.",
                    "Fish open water with a Nightcrawler until 205.",
                    "Fly to Shadowprey Village (Desolace). Buy the Expert Cookbook from Wulan, top floor of the eastern building.",
                    "Also buy 20 Alterac Swiss from Innkeeper Sikewa." } },
        { label = "B", recipe = "Mystral Lake, Ashenvale", f = "Alliance",
          notes = { "Fly to Astranaar and ride southeast to Mystral Lake.",
                    "Buy the Expert Cookbook and 7 Nightcrawlers from Shandrina. Save 5 Nightcrawlers.",
                    "Fish Mystral Lake with a Nightcrawler until 205.",
                    "No Alterac Swiss yet? You need 20 for the Artisan Cooking quest (Ben Trias, Stormwind)." } },
      } },

    { id = "cexp", kind = "train", skill = "cooking", max = 225, title = "Read the Expert Cookbook", requires = { skill = 125 },
      notes = { "Read it at 125. Without it you stop gaining skill at 150." },
      gather = { { id = 16072, count = 1, note = "then read it" } } },

    { id = "c175", kind = "level", skill = "cooking", from = 100, to = 175, title = "Cook Longjaw, then Catfish", soft = { 6289, 6308 },
      options = { { label = "A", recipe = "Bristle Whisker Catfish", product = 4593, mats = { { 6308, 1 } } } },
      notes = { "Below 100? Cook Longjaw Mud Snapper first, then all your Bristle Whisker Catfish." } },

    { id = "f225", kind = "level", skill = "fishing", from = 205, to = 225, title = "Fish Dustwallow Marsh", lure = 6530,
      notes = {
        { H = "Out of Nightcrawlers? Kilxx in Ratchet sells them.", A = "Out of Nightcrawlers? Helenia Olden in Dustwallow sells them." },
        "Fish the swamp, not the ocean.", "Keep a Nightcrawler on your pole or fish escape.",
      } },

    { id = "fart", kind = "quest", skill = "fishing", quest = 6607, max = 300, title = "Artisan quest: Nat Pagle, Angler Extreme",
      requires = { level = 35, skill = 225 },
      gather = {
        { id = 16969, count = 1, note = "Stranglethorn west coast (Savage Coast)" },
        { id = 16968, count = 1, note = { H = "Desolace coast", A = "Desolace: northern coast tower" } },
        { id = 16970, count = 1, note = "Swamp of Sorrows, Misty Reed Strand islands" },
        { id = 16967, count = 1, note = { H = "Verdantis River, Feralas. Lure needed (Bright Bauble from Sheendra Tallgrass)", A = "Verdantis River, Feralas. Lure needed (Bright Bauble from Vivianna)" } },
      },
      notes = { "Quest giver: Nat Pagle in Tidefury Cove (Dustwallow Marsh).", "Only catching trout and catfish? Move to another spot." } },

    { id = "f255", kind = "level", skill = "fishing", from = 225, to = 255, title = "Keep fishing Dustwallow Marsh", lure = 6530,
      secondary = { cooking = 225 },
      catch = { { 8365, 0 } },
      notes = { "Swamp water, not the ocean. The ocean gives Rockscale Cod instead of trout.",
                { H = "Cook at Brackenwall Village or on a campfire.", A = "Cook at Theramore Isle or on a campfire." } } },

    { id = "c225", kind = "level", skill = "cooking", from = 175, to = 225, title = "Cook Mithril Headed Trout",
      options = { { label = "A", recipe = "Mithril Headed Trout", product = 8364, mats = { { 8365, 1 } } } },
      notes = { "Still below 175? Cook Bristle Whisker Catfish first. Keep extra trout for later." } },

    { id = "cart", kind = "quest", skill = "cooking", quest = 6610, max = 300, title = "Artisan quest: Clamlette Surprise",
      requires = { level = 35, skill = 225 },
      gather = {
        { id = 12207, count = 12, note = "Rocs, Fire Rocs, Searing Rocs in Tanaris" },
        { id = 7974,  count = 10, note = "Big-mouth Clams from Steeljaw Snappers / Surf Gliders in Tanaris" },
        { id = 8932,  count = 20, note = "bought earlier" },
      },
      notes = { "Hand in to Dirge Quikcleave in Gadgetzan.", "Then buy Recipe: Nightfin Soup from Gikkix in Steamwheedle Port." },
      recipes = { "Recipe: Nightfin Soup" } },

    { id = "f300", kind = "level", skill = "fishing", from = 255, to = 300, title = "Fish Feralas", lure = 6532, nightfin = true,
      catch = { { 13758, 0 }, { 13759, 18 } },
      notes = {
        { H = "Fly to Camp Mojache. Buy 12 Bright Baubles from Sheendra Tallgrass.", A = "Fly to Feathermoon Stronghold. Buy 12 Bright Baubles from Vivianna." },
        "Any Feralas lake or river except Jademir Lake.", "Put on a new bauble every 10 minutes.",
      },
      buy = { { id = 6532, count = 12 } } },

    { id = "c250", kind = "level", skill = "cooking", from = 225, to = 250, title = "Cook leftover trout", soft = { 8365 },
      options = { { label = "A", recipe = "Mithril Headed Trout", product = 8364, mats = { { 8365, 1 } } } } },

    { id = "c285", kind = "level", skill = "cooking", from = 250, to = 285, title = "Cook Filet of Redgill",
      options = { { label = "A", recipe = "Filet of Redgill", product = 13930, mats = { { 13758, 1 } } } } },

    { id = "c300", kind = "level", skill = "cooking", from = 285, to = 300, title = "Cook Nightfin Soup", nightfin = true,
      options = { { label = "A", recipe = "Nightfin Soup", product = 13931, mats = { { 13759, 1 }, { 159, 1 } } } },
      buy = { { id = 159, count = 20, note = "any innkeeper" } },
      notes = { "Short of 300? Cook leftover Redgill, fish more Nightfin outside 12:00-18:00, or buy some on the Auction House." } },
  },
})
end)
