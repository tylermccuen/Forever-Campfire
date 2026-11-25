--[[ Cooking 1-300 for WoW Forever.
Route checked 2026-11-24.

STEP FORMAT (shared by every guide, see README.md "Adding a profession"):
  id        unique within the guide (saved choices use it, so don't rename)
  kind      "learn" (done when the profession is known)
            "train" (done when the skill cap reaches `max`)
            "quest" (done when `quest` is completed or the cap reaches `max`)
            "level" (done when skill reaches `to`)
  title, from, to, max, quest, skill (defaults to the guide's first skill)
  requires  { level = N, skill = N }  shown as blockers until met
  notes     list of text values (string, {H=,A=}, or {"text", f="Horde"})
  f         on an option / buy / gather entry: only for that faction ("Horde"/"Alliance")
  options   alternative recipes / routes; the addon auto-picks the one you
            have materials for, and the player can pin one.
              { label, recipe, product, count, mats = {{itemID, perCraft}},
                recipeFrom = text, recipeItem = "Recipe: ..." }
  gather    items to have before a quest/hand-in: {{id = , count = , note = }}
  buy       vendor items the step wants: {{id = , count = , note = }}
  soft      list of item IDs: step also counts as done when none are left in
            your bags ("cook all of your X" steps)
  secondary { otherSkill = target } shown as "behind" in combined guides
  lure      recommended lure item ID (fishing)
  nightfin  true: warn while Nightfin Snapper don't bite (12:00-18:00)
]]
local _, ns = ...

local TRAINERS = {
  H = "Zamja (Orgrimmar), Eunice Burch (Undercity), Aska Mistrunner (Thunder Bluff), Cook Torka (Razor Hill), Pyall Silentstride (Bloodhoof Village), William Pickman (Brill inn), Nyalah Brightfire / Zerril Softbreeze (Zephras Isle)",
  A = "Stephen Ryback (Stormwind), Daryl Riknussun (Ironforge), Alegorn (Darnassus), Tomas (Goldshire inn), Gremlock Pilsnor (Kharanos), Zarrin (Dolanaar), Nyalah Brightfire / Zerril Softbreeze (Zephras Isle)",
}

ns.RegisterGuide({
  key = "cooking",
  recipePrefix = "Recipe: ",
  capitalTrainer = { H = "Zamja in Orgrimmar", A = "Stephen Ryback in Stormwind" },
  name = "Cooking",
  skills = { "cooking" },
  icon = "Interface\\Icons\\INV_Misc_Food_15",
  checked = "2026-11-24",
  -- What to do when you hit each cap (keyed by the cap you are stuck at).
  rankUps = {
    [75]  = { name = "Journeyman Cooking", skill = 50, how = { H = "Train it at any Cooking trainer, such as Zamja in Orgrimmar", A = "Train it at any Cooking trainer, such as Stephen Ryback in Stormwind" } },
    [150] = { name = "Expert Cooking", skill = 125, book = 16072,
              how = { H = "Read the Expert Cookbook (Wulan, Shadowprey Village, Desolace)", A = "Read the Expert Cookbook (Shandrina, Mystral Lake, Ashenvale)" } },
    [225] = { name = "Artisan Cooking", skill = 225, level = 35, how = "Quest Clamlette Surprise from Dirge Quikcleave in Gadgetzan" },
  },
  steps = {
    { id = "learn", kind = "learn", title = "Learn Cooking",
      notes = {
        "Cooking doesn't use one of your two profession slots.",
        "You also learn Basic Campfire Kit. Kits need Simple Wood and Flint and Tinder. The Flint and Tinder is only needed to craft kits, so it can stay in the bank.",
        { H = "Trainers: " .. TRAINERS.H, A = "Trainers: " .. TRAINERS.A },
      } },

    { id = "c1", kind = "level", from = 1, to = 50, title = "Cook starter fish",
      options = {
        { label = "A", recipe = "Brilliant Smallfish", product = 6290, count = 55, mats = { { 6291, 1 } },
          recipeFrom = { H = "Sewa / Naal Mistrunner (Thunder Bluff), Lizbeth Cromwell / Ronald Burch (Undercity), Harn Longcast (Mulgore), Martine Tramblay (Tirisfal)",
                         A = "Catherine Leland (Stormwind), Tharynn Bouden (Elwynn), Gretta Ganter (Dun Morogh), Khara Deepwater (Loch Modan), Nyoma (Teldrassil)" } },
        { label = "B", recipe = "Slitherskin Mackerel", product = 787, count = 55, mats = { { 6303, 1 } },
          recipeFrom = { H = "Zansoa (Durotar), Martine Tramblay (Tirisfal)", A = "Tansy Puddlefizz (Ironforge), Nessa Shadowsong (Teldrassil), Kriggon Talsone (Westfall)" } },
      },
      notes = { "Buy whichever raw fish is cheaper.", "Once a recipe turns yellow, not every craft gives a point. Have a few spare." } },

    { id = "jm", kind = "train", max = 150, title = "Train Journeyman Cooking", requires = { skill = 50 },
      notes = { "Without it you stop gaining skill at 75, even if you keep cooking.", { H = "Trainers: " .. TRAINERS.H, A = "Trainers: " .. TRAINERS.A } } },

    { id = "c2", kind = "level", from = 50, to = 100, title = "Cook Longjaw or Albacore",
      options = {
        { label = "A", recipe = "Longjaw Mud Snapper", product = 4592, count = 55, mats = { { 6289, 1 } },
          recipeFrom = { H = "Harn Longcast (Mulgore), Naal Mistrunner (Thunder Bluff), Lizbeth Cromwell (Undercity), Killian Sanatha (Silverpine)",
                         A = "Tharynn Bouden (Elwynn), Tansy Puddlefizz (Ironforge), Khara Deepwater (Loch Modan), Nyoma (Teldrassil)" } },
        { label = "B", recipe = "Rainbow Fin Albacore", product = 5095, count = 55, mats = { { 6361, 1 } },
          recipeFrom = { H = "Zansoa (Durotar), Shankys (Orgrimmar), Ronald Burch (Undercity), Killian Sanatha (Silverpine), Kilxx (Ratchet)",
                         A = "Catherine Leland (Stormwind), Heldan Galesong (Darkshore), Nessa Shadowsong (Teldrassil), Kriggon Talsone (Westfall), Stuart Fleming (Wetlands), Kilxx (Ratchet)" } },
      } },

    { id = "c3", kind = "level", from = 100, to = 150, title = "Cook Bristle Whisker Catfish",
      options = {
        { label = "A", recipe = "Bristle Whisker Catfish", product = 4593, count = 53, mats = { { 6308, 1 } },
          recipeFrom = { H = "Naal Mistrunner (Thunder Bluff), Ronald Burch (Undercity), Derak Nightfall (Hillsbrad), Kilxx (Ratchet)",
                         A = "Catherine Leland (Stormwind), Lindea Rabonne (Hillsbrad), Kilxx (Ratchet)" } },
      },
      notes = { "Recipe is taught at Cooking 100." } },

    { id = "expert", kind = "train", max = 225, title = "Get the Expert Cookbook", requires = { skill = 125 },
      notes = {
        { H = "Buy the Expert Cookbook from Wulan, top floor of the eastern building in Shadowprey Village (Desolace).",
          A = "Buy the Expert Cookbook from Shandrina at Mystral Lake (Ashenvale)." },
        "Read it at 125. Without it you stop gaining skill at 150."
      },
      gather = { { id = 16072, count = 1, note = "then read it" } } },

    { id = "c4", kind = "level", from = 150, to = 175, title = "Cook Goblin Deviled Clams",
      options = {
        { label = "A", recipe = "Goblin Deviled Clams", product = 5527, count = 28, mats = { { 5504, 1 }, { 2692, 1 } },
          recipeFrom = "Your Cooking trainer" },
      },
      notes = { "Buy Hot Spices from the Cooking Supply vendor near your trainer. Skip the Auction House." } },

    { id = "c5", kind = "level", from = 175, to = 225, title = "Cook Roast Raptor or Trout",
      options = {
        { label = "A", recipe = "Roast Raptor", product = 12210, count = 55, mats = { { 12184, 1 }, { 2692, 1 } },
          recipeFrom = { H = "Keena (Arathi), Ogg'marr (Dustwallow), Nerrist (Stranglethorn)", A = "Hammon Karwn (Arathi), Helenia Olden (Dustwallow)" } },
        { label = "B", recipe = "Mithril Headed Trout", recipeItem = "Recipe: Mithril Head Trout", product = 8364, count = 55, mats = { { 8365, 1 } },
          recipeFrom = { H = "Wik'Tar (Ashenvale), Wulan (Desolace), Shankys (Orgrimmar), Lizbeth Cromwell (Undercity), Kelsey Yance (Booty Bay)",
                         A = "Heldan Galesong (Darkshore), Lindea Rabonne (Hillsbrad), Tansy Puddlefizz (Ironforge), Stuart Fleming (Wetlands), Kelsey Yance (Booty Bay)" } },
      },
      notes = { "Roast Raptor is usually cheaper.", "The Roast Raptor recipe binds when picked up." } },

    { id = "artisan", kind = "quest", quest = 6610, max = 300, title = "Artisan quest: Clamlette Surprise",
      requires = { level = 35, skill = 225 },
      gather = {
        { id = 12207, count = 12, note = "Auction House, or Rocs in Tanaris" },
        { id = 7974,  count = 10, note = "Auction House, or Big-mouth Clams in Tanaris" },
        { id = 8932,  count = 20, note = { H = "Innkeeper Abeqwa, Freewind Post", A = "Ben Trias (Stormwind) or Dwane Wertle (Dustwallow)" } },
      },
      notes = {
        "Get all three items first.",
        "Then hand them to Dirge Quikcleave in Gadgetzan (Tanaris).",
        "Before leaving Tanaris, buy two recipes from Gikkix in Steamwheedle Port: Spotted Yellowtail and Nightfin Soup.",
        "No ! over his head? Turn on low-level quest tracking.",
      },
      recipes = { "Recipe: Spotted Yellowtail", "Recipe: Nightfin Soup" } },

    { id = "c6", kind = "level", from = 225, to = 285, title = "Cook Yellowtail or Redgill",
      options = {
        { label = "A", recipe = "Spotted Yellowtail", product = 6887, count = 72, mats = { { 4603, 1 } }, recipeFrom = "Gikkix (Steamwheedle Port, Tanaris)" },
        { label = "B", recipe = "Filet of Redgill", product = 13930, count = 72, mats = { { 13758, 1 } }, recipeFrom = "Kelsey Yance (Booty Bay)" },
      },
      notes = { "Buy whichever fish is cheaper." } },

    { id = "c7", kind = "level", from = 285, to = 300, title = "Cook Nightfin Soup", nightfin = true,
      options = {
        { label = "A", recipe = "Nightfin Soup", product = 13931, count = 18, mats = { { 13759, 1 }, { 159, 1 } }, recipeFrom = "Gikkix (Steamwheedle Port, Tanaris)" },
      },
      notes = { "Buy Refreshing Spring Water from any innkeeper." } },
  },
})
