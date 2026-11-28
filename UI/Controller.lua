-- Controller support.
-- Every action a controller player needs is a key binding (Bindings.xml), so
-- it can go on a gamepad button in the game's Keybindings menu or in
-- ConsolePort. The window itself never grabs gamepad buttons, so jumping and
-- abilities keep working while it's open.
local _, ns = ...

BINDING_HEADER_FORECAMP = "Forever Campfire"
BINDING_NAME_FORECAMP_TOGGLE = "Open or close the guide"
BINDING_NAME_FORECAMP_NEXTTAB = "Next tab"
BINDING_NAME_FORECAMP_PREVTAB = "Previous tab"
BINDING_NAME_FORECAMP_NEXTSTEP = "Next step (or scroll down)"
BINDING_NAME_FORECAMP_PREVSTEP = "Previous step (or scroll up)"
BINDING_NAME_FORECAMP_NOW = "Back to the step you're on"
BINDING_NAME_FORECAMP_OPTION = "Switch recipe option"
BINDING_NAME_FORECAMP_VIEW = "Switch Route and Recipes"
BINDING_NAME_FORECAMP_SHOP = "Shopping list"
BINDING_NAME_FORECAMP_TRACKER = "Show or hide the tracker"
BINDING_NAME_FORECAMP_TRACKERNEXT = "Tracker: next profession"
BINDING_NAME_FORECAMP_SIZZLE = "Sizzle! (flip)"

local actions = {
  toggle = function() ns.ToggleMain() end,
  nexttab = function() ns.NavTab(1) end,
  prevtab = function() ns.NavTab(-1) end,
  nextstep = function() ns.NavStep(1) end,
  prevstep = function() ns.NavStep(-1) end,
  now = function() ns.NavNow() end,
  option = function() ns.NavOption() end,
  view = function() ns.NavView() end,
  shop = function() ns.ToggleShop() end,
  tracker = function() ns.db.tracker = not ns.db.tracker; ns.RequestRefresh() end,
  trackernext = function() ns.CycleTrackerGuide() end,
  sizzle = function() ns.SizzleHit() end,
}

function ForeverCampfire_Binding(action)
  if not ns.db then return end   -- before the addon has loaded its settings
  local fn = actions[action]
  if fn then fn() end
end

-- ConsolePort's on-screen cursor only visits frames it knows about. Each of
-- our windows registers itself when it's first built; without ConsolePort
-- this does nothing.
function ns.RegisterControllerFrame(frame)
  local CP = rawget(_G, "ConsolePort")
  if not (CP and CP.AddInterfaceCursorFrame and frame) then return end
  pcall(CP.AddInterfaceCursorFrame, CP, frame)
end
