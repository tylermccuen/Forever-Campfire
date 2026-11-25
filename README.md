# Forever Campfire

Leveling guide for every WoW Forever profession (Cooking, Fishing, First Aid, Mining, Herbalism, Skinning, Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking, Tailoring) that follows your skill as you level.

## In game
- **Fish button on the minimap** (or the addon compartment): left-click opens the guide, right-click shows/hides the tracker, drag to move.
- `/fc` opens the guide. `/fc cooking`, `/fc fishing`, `/fc both`, `/fc mining`, `/fc herbalism`, `/fc skinning`, `/fc tailoring` (any profession name), `/fc map`, `/fc pins`, `/fc catches`, `/fc shop`, `/fc sizzle`, `/fc tracker`, `/fc lock`, `/fc minimap`, `/fc mem`, `/fc reset`.

## What it does
- **Skill tree layout**: each guide is drawn as a tree, rank by rank (Apprentice, Journeyman, Expert, Artisan). The rank you're in is open: steps run top to bottom, recipe choices fork into A/B tiles and join again, and rank-up steps show as purple gates. Finished and future ranks fold into one slim tile each (click to open). Click any tile to see it in the detail panel on the right; click an option tile to use that recipe (right-click to let the guide pick again).
- **Recipes** (Cooking and Fish + Cook): switch the left panel from Route to Recipes to see all 123 Cooking recipes by rank, with where each comes from, reagents, and food effects. Open your Cooking window once and it marks which ones you know (green), which you can learn now (gold), and which need more skill (grey). Filters: All, Missing, Can learn now. Recipe items in tooltips and at vendors say whether they're new for your collection.
- **Camp tab**: your campfire upgrade path (Basic, Journeyman, Expert) and, for every profession you know, its camp items from tier 1 to tier 3: buff, skill, materials (have/need), and which boss drops each Blueprint. Camp plans at vendors and in tooltips are flagged too.
- **Catch Log** (fishing guides): counts every fish you reel in on this character: total, fish per skill point, "next point in about N", streak and best streak, fish per rank, best catch, and milestones (100 / 500 / 1,000 fish, 10 in a row, all of Nat Pagle's fish, Artisan angler). Shown in the detail panel and on the tracker; `/fc catches` prints it.
- Tabs along the bottom, only for professions your character has learned. Know both Fishing and Cooking and they merge into one Fish + Cook tab. Tick **All tabs** to browse the rest (they wrap onto two rows). A new character with none of them sees a welcome screen with where to train.
- Reads your Cooking and Fishing skill and jumps to the step you're on. Steps you've finished are ticked, and the current one is outlined in gold.
- **NOW box**: what to do right now, about how many crafts are left, and which materials you're short.
- **Step by step crafting**: each crafting step lists what to do in order: go to the vendor or trainer for the recipe, buy vendor materials, gather or buy the rest, then craft. Where to buy each recipe item is in `Data/RecipeSources.lua` (`at`, `get`, `bop`, `pin`).
- **Alerts**: you've hit a skill cap (and how to train past it), you're too low level for the next rank, you have the Expert book unread in your bags, there's no lure on your pole, Nightfin Snapper won't bite at this hour (12:00-18:00), and in Fish + Cook mode, when one skill is falling behind.
- **Recipe options**: picks the option you have materials for. Click an option button to lock in your choice (`>` means locked, `*` means auto).
- **Map pins (Fishing, Cooking, Fish + Cook)**: the addon draws its own pins and circles on the world map for trainers, vendors, fishing spots and the Artisan quest fish. Use the **Map** button on a step or **Show on map** in the NOW box. Click a pin to set a waypoint (TomTom too, if installed). The current step's pins show whenever you open the map; `/fc pins` turns that off. Pin data is in `Data/MapPins.lua`.
- **Shopping list** for the rest of the route, checked against your bags (and bank, if you tick it).
- **Tooltips**: items the route uses show which step needs them and how many you have. With Skinning, beasts show the skill needed to skin them.
- **Gathering**: warns when your Mining Pick or Skinning Knife isn't in your bags, or Find Minerals / Find Herbs is off. Mining offers a "smelt Auction House ore" option for 1-125.
- **Vendor alerts**: when a vendor sells a recipe or supply the route needs, a chat message tells you how many you still need.
- **Tracker**: a small movable panel. It follows the profession you last gained a point in; right-click it to pick one.
- **Sizzle!**: a little timing mini-game that pops up while you craft from a profession window (never while fishing). Left-click inside the gold zone to build a combo; right-drag to move it. It's just for fun and doesn't change anything about the craft. Turn it off with the checkbox at the bottom of the guide.

## Adding a profession (same layout)
1. Add `Data/<Profession>.lua` in two parts (see `Data/Mining.lua`):
   ```lua
   ns.LazyGuide({ key = "mining", name = "Mining", skills = { "mining" }, icon = "...", capitalTrainer = { H = "...", A = "..." } }, function()
     -- locals the guide uses go in here too
     ns.RegisterGuide({ key = "mining", checked = "...", rankUps = { ... }, steps = { ... } })
   end)
   ```
   The header is all that exists until the guide is needed (its profession is known, its tab is opened, or "All tabs" is ticked). The function then runs once. This keeps memory low however many guides are added. The skill keys for every profession are already in `ns.SKILLS` (`Core.lua`).
2. Write the steps in the format described at the top of `Data/Cooking.lua`: `learn` / `train` / `level` / `quest` kinds, `options` with `mats`, plus `gather`, `buy`, `notes`, and `requires`.
3. Add item names to `Data/Items.lua`. Item counting falls back to these names if an ID turns out to be wrong.
4. Crafting guides use the short helpers `ns.Craft`, `ns.Opt` and `ns.Train` from `Core.lua` (see `Data/Tailoring.lua`), and can list materials by exact item name instead of ID. Gathering guides can also set `gatherVerb`, `catchLabel`, `tool` and `tracking` (see `Data/Mining.lua`).
5. List the file in `ForeverCampfire.toc` after the other Data files. The new tab, tracker, tooltips, shopping list and vendor alerts all work without further changes.
6. Set `verb = "Craft"` (or "Smelt", "Brew"...) on the guide so the NOW box doesn't say "Cook".

Where each route recipe is learned lives in `Data/RecipeSources.lua` (trainer, known from the start, or a recipe item and its skill). Add new route recipes there too; the offline test fails if a route recipe has no source.

Other big data works the same way: `ns.Lazy("Camp", function() return {...} end)` builds `ns.Camp` the first time it's read, and `ns.LazyCollection(header, function() return recipes end)` does the same for a recipe collection. Long lists (the Recipes view) only draw the rows on screen, so a collection can hold hundreds of recipes.

Test offline: `texlua tools/test.lua ForeverCampfire`. `/fc mem` shows the addon's memory in game and which guides are loaded.
