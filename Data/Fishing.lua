-- Fishing 1-300 for WoW Forever.
-- Route checked 2026-11-24.
-- Step format: see Data/Cooking.lua.
local _, ns = ...

-- The header is all the addon needs until this guide is opened or its
-- profession is learned; the rest is built on first use.
ns.LazyGuide({
  key = "fishing",
  capitalTrainer = { H = "Lumak in Orgrimmar", A = "Arnold Leland in Stormwind" },
  name = "Fishing",
  skills = { "fishing" },
  icon = "Interface\\Icons\\Trade_Fishing",
}, function()
local TRAINERS = {
  H = "Lumak (Orgrimmar), Armand Cromwell (Undercity), Kah Mistrunner (Thunder Bluff), Lau'Tiki (Sen'jin Village coast), Uthan Stillwater (Stonebull Lake, Mulgore), Clyde Kellen (Brightwater Lake, Tirisfal), Baelann Swiftcurrent or Fenn Fairweather (Zephras Isle)",
  A = "Arnold Leland (Stormwind), Grimnur Stonebrand (Ironforge), Astaia (Darnassus), Lee Brown (Crystal Lake, Elwynn), Paxton Ganter (Iceflow Lake, Dun Morogh), Androl Oakhand (Rut'theran Village), Baelann Swiftcurrent or Fenn Fairweather (Zephras Isle)",
}
local SUPPLY = {
  H = "Zansoa (Sen'jin), Wunna Darkmane (Bloodhoof), Martine Tramblay (Death's Watch, Tirisfal), Shankys (Orgrimmar), Lizbeth Cromwell (Undercity), Sewa Mistrunner (Thunder Bluff), Wik'Tar (Zoram'gar, Ashenvale), Katoom the Angler (Revantusk)",
  A = "Tharynn Bouden (Goldshire), Gretta Ganter (Iceflow Lake), Nessa Shadowsong (Rut'theran), Catherine Leland (Stormwind), Tansy Puddlefizz (Ironforge), Voloren (Darnassus), Khara Deepwater (Loch Modan), Stuart Fleming (Menethil), Vernon Hale (Lake Everstill), Lindea Rabonne (Southshore)",
}

ns.RegisterGuide({
  key = "fishing",
  checked = "2026-11-24",
  rankUps = {
    [75]  = { name = "Journeyman Fishing", skill = 50, level = 10, how = "Train it at your Fishing trainer" },
    [150] = { name = "Expert Fishing", skill = 125, level = 20, book = 16083, how = "Read Expert Fishing - The Bass and You (Old Man Heming, Booty Bay)" },
    [225] = { name = "Artisan Fishing", skill = 225, level = 35, how = "Quest Nat Pagle, Angler Extreme (Nat Pagle, Tidefury Cove, Dustwallow Marsh)" },
  },
  steps = {
    { id = "learn", kind = "learn", title = "Learn Fishing, get a pole",
      notes = {
        "No level requirement. A city guard can mark the trainer on your map.",
        { H = "Trainers: " .. TRAINERS.H, A = "Trainers: " .. TRAINERS.A },
        { H = "Fishing Pole and Shiny Bauble: " .. SUPPLY.H, A = "Fishing Pole and Shiny Bauble: " .. SUPPLY.A },
        "Open Professions, click the hammer button (not the Fishing tab) and drag Fishing to your action bar.",
        "Cast, then right-click the bobber when it splashes.",
      },
      buy = { { id = 6256, count = 1 }, { id = 6529, count = 1 } } },

    { id = "f1", kind = "level", from = 1, to = 75, title = "Fish in your starting zone", lure = 6529,
      notes = {
        "Any lake, pond or river in a starting zone. Capital cities don't count.",
        { H = "Zones: Durotar, Mulgore, Tirisfal Glades, Zephras Isle", A = "Zones: Elwynn Forest, Dun Morogh, Teldrassil, Zephras Isle" },
      } },

    { id = "jm", kind = "train", max = 150, title = "Train Journeyman Fishing", requires = { skill = 50, level = 10 },
      notes = { "Back to your Fishing trainer.", { H = "Trainers: " .. TRAINERS.H, A = "Trainers: " .. TRAINERS.A } } },

    { id = "f2", kind = "level", from = 75, to = 150, title = "Fish in a city or nearby zone", lure = 6530,
      notes = {
        { H = "Where: Orgrimmar, Undercity, Thunder Bluff, The Barrens, Silverpine Forest",
          A = "Where: Stormwind, Darnassus, Ironforge, Darkshore, Loch Modan, Westfall" },
        "Fish keep escaping? Use Nightcrawlers."
      } },

    { id = "expert", kind = "train", max = 225, title = "Get the Expert Fishing book", requires = { skill = 125, level = 20 },
      notes = {
        "Buy Expert Fishing - The Bass and You from Old Man Heming in Booty Bay.",
        "He's at the bottom of town, by the fishing sign. The Auction House sells it too.",
        "Buy a stack of Bright Baubles from him before leaving.",
      },
      gather = { { id = 16083, count = 1, note = "then read it" } },
      buy = { { id = 6532, count = 10 } } },

    { id = "f3", kind = "level", from = 150, to = 225, title = "Fish in Dustwallow Marsh", lure = 6532,
      notes = {
        "Use Bright Baubles. The Artisan quest starts here too.",
        "Also good: Alterac Mountains, Arathi Highlands, Desolace, Stranglethorn Vale, Swamp of Sorrows, Thousand Needles",
      } },

    { id = "artisan", kind = "quest", quest = 6607, max = 300, title = "Artisan quest: Nat Pagle, Angler Extreme",
      requires = { level = 35, skill = 225 },
      gather = {
        { id = 16969, count = 1, note = "Stranglethorn Vale: the west coast, away from Grom'gol." },
        { id = 16968, count = 1, note = { H = "Desolace coast near Shadowprey Village", A = "Desolace: the water around the northern coast tower" } },
        { id = 16970, count = 1, note = "Swamp of Sorrows: Misty Reed Strand (fish from the small islands)" },
        { id = 16967, count = 1, note = "Feralas: the Verdantis River, just west of the road bridge. Use a lure." },
      },
      notes = { "Quest giver: Nat Pagle, Tidefury Cove, Dustwallow Marsh.", "Only catching trout and catfish? Move to another spot." } },

    { id = "f4", kind = "level", from = 225, to = 300, title = "Fish high-level zones", lure = 6532,
      notes = { "Where: Felwood, Feralas, The Hinterlands, Tanaris, Un'Goro Crater, Western Plaguelands",
        "Use Bright Baubles or most fish get away.", } },
  },
})
end)
