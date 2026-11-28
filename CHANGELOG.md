# Forever Campfire

## 0.6.2

- Fixed: the close button didn't work during combat.
- Fixed: opening Recipes after the Camp tab drew both on top of each other.
- Camp tab: roomier tiles, names wrap instead of cutting off, and each tile shows the boss and dungeon on their own lines.
- Uses about a third less memory: guides for professions you don't have aren't loaded until you open them.
- The recipe list only draws what's on screen and no longer redraws on every bag change, so the window stays smooth.
- Fixed: the resize corner could make the window jump to a huge size. The window now stays between its minimum size and your screen size, and a window saved too big shrinks back.
- Resizing redraws the window at most 10 times a second, so dragging the corner stays smooth.
- Proofread every guide: full sentences instead of fragments, proper plurals in material counts, and the same wording for the same advice across professions.
- Fixed: Sizzle! didn't pop up when crafting. It now notices the profession window on every client, and it also starts for crafts with no cast bar.
- Bigger item icons in material lists, the shopping list and alerts, with more space between lines so they no longer run into the text. Step tiles have bigger icons too.
- Every crafting step now has a "Learn:" line: whether the recipe comes from your trainer (and at what skill), comes with the profession, or needs a plans, pattern, formula, schematic or manual item. Once you know a recipe, it says so instead.
- Finished steps still list each recipe's materials, so you can look back and plan ahead. Every material line also says how many one craft takes.
- New `/fc mem` shows how much memory the addon uses.

## 0.6.1

First public release.

- Step-by-step leveling guides for every WoW Forever profession: Cooking, Fishing, Fish + Cook, First Aid, Mining, Herbalism, Skinning, Alchemy, Blacksmithing, Enchanting, Engineering, Leatherworking and Tailoring.
- Skill tree layout: the rank you're in opens as a tree, recipe choices fork into options, finished and future ranks fold away.
- Reads your skill and shows what to do now, how many crafts are left and which materials you're short.
- Tabs only for the professions your character knows. A welcome screen for new characters.
- Camp tab: campfire upgrades and every profession's camp items from tier 1 to tier 3, showing which boss drops each Blueprint right on the tile, plus materials.
- Cooking recipe collection: every learnable recipe, which ones you know, and where to get the rest.
- Map pins for Fishing and Cooking trainers, vendors and fishing spots, with click-to-waypoint (TomTom supported).
- Catch Log: counts your fish, fish per skill point, streaks and milestones.
- Alerts for skill caps, missing tools and lures, unread books and Nightfin hours.
- Shopping list, item tooltips, vendor alerts, a movable tracker and a fish minimap button.
- Sizzle!, a small optional mini-game while you craft.
