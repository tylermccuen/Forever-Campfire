-- Draws the guide's pins and circles on the in-game world map.
-- Shows the pins for the step you picked with "Map" (or, by default, your current step).
-- Click a pin to set a waypoint (Blizzard's, plus TomTom if installed).
local _, ns = ...
local C = ns.C

local overlay, pool = nil, {}
local zoneIndex           -- zone name -> uiMapID
ns.mapStep = nil          -- step chosen with a Map button (nil = follow the current step)

---------------------------------------------------------------------------
-- Zone names -> map IDs (looked up from the game, so no hard-coded IDs)
---------------------------------------------------------------------------
local function buildZoneIndex()
  zoneIndex = {}
  if not (C_Map and C_Map.GetMapInfo and C_Map.GetMapChildrenInfo) then return end
  local start = (C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player"))
    or (C_Map.GetFallbackWorldMapID and C_Map.GetFallbackWorldMapID()) or 947
  -- climb to the top of the map tree, then list everything under it
  local id, guard = start, 0
  while id and guard < 10 do
    local info = C_Map.GetMapInfo(id)
    if not info or not info.parentMapID or info.parentMapID == 0 then break end
    id = info.parentMapID; guard = guard + 1
  end
  local ok, children = pcall(C_Map.GetMapChildrenInfo, id, nil, true)
  if ok and children then
    for _, m in ipairs(children) do
      if m.name and not zoneIndex[m.name] then zoneIndex[m.name] = m.mapID end
    end
  end
end

function ns.MapIDForZone(name)
  if not zoneIndex or not next(zoneIndex) then buildZoneIndex() end
  return zoneIndex[name]
end

---------------------------------------------------------------------------
-- Which pins to draw
---------------------------------------------------------------------------
local function activeStep()
  if ns.mapStep then return ns.mapStep end
  if not (ns.db and ns.db.mapPins) then return nil end
  local key = ns.TrackedGuideKey and ns.TrackedGuideKey()
  local g = key and ns.guides[key]
  return g and ns.CurrentStep(g)
end

---------------------------------------------------------------------------
-- Waypoints
---------------------------------------------------------------------------
function ns.SetWaypoint(p)
  local mapID = ns.MapIDForZone(p.zone)
  if not mapID then ns.Print("Can't find the zone \"" .. p.zone .. "\" on your map."); return end
  local x, y = p.x / 100, p.y / 100
  local set = false
  if C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates then
    local ok = pcall(function()
      if C_Map.CanSetUserWaypointOnMap and not C_Map.CanSetUserWaypointOnMap(mapID) then error("no") end
      C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x, y))
      if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
    end)
    set = ok
  end
  if TomTom and TomTom.AddWaypoint then
    pcall(TomTom.AddWaypoint, TomTom, mapID, x, y, { title = p.label, persistent = false, minimap = true, world = true })
    set = true
  end
  if set then
    ns.Print("Waypoint: " .. C.gold .. p.label .. C.r .. " (" .. p.zone .. " " .. p.x .. ", " .. p.y .. ")")
  else
    ns.Print(p.label .. ": " .. p.zone .. " " .. p.x .. ", " .. p.y)
  end
end

---------------------------------------------------------------------------
-- Drawing
---------------------------------------------------------------------------
local KIND_COLOR = { npc = { 1, 0.82, 0 }, spot = { 0.3, 0.85, 1 }, area = { 0.3, 0.85, 1 } }
local CIRCLE = "Interface\\CHARACTERFRAME\\TempPortraitAlphaMask"

local function canvasScale()
  local sc = WorldMapFrame and WorldMapFrame.ScrollContainer
  if sc and sc.GetCanvasScale then
    local ok, s = pcall(sc.GetCanvasScale, sc)
    if ok and s and s > 0 then return s end
  end
  return 1
end

local function getPin(i)
  if pool[i] then return pool[i] end
  local b = CreateFrame("Button", nil, overlay)
  b.area = b:CreateTexture(nil, "BACKGROUND")
  b.area:SetTexture(CIRCLE)
  b.ring = b:CreateTexture(nil, "BORDER")
  b.ring:SetTexture(CIRCLE)
  b.dot = b:CreateTexture(nil, "ARTWORK")
  b.dot:SetTexture(CIRCLE)
  b.icon = b:CreateTexture(nil, "OVERLAY")
  b.num = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  b:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(self.pin.label, 1, 0.82, 0, 1, true)
    GameTooltip:AddLine(self.step.title, 0.8, 0.8, 0.8, true)
    GameTooltip:AddLine(self.pin.zone .. "  " .. self.pin.x .. ", " .. self.pin.y, 1, 1, 1)
    GameTooltip:AddLine("Click: set a waypoint", 0.5, 1, 0.5)
    GameTooltip:Show()
  end)
  b:SetScript("OnLeave", GameTooltip_Hide)
  b:SetScript("OnClick", function(self) ns.SetWaypoint(self.pin) end)
  pool[i] = b
  return b
end

function ns.RefreshMapPins()
  if not overlay then return end
  for _, b in ipairs(pool) do b:Hide() end
  local step = activeStep()
  if not (step and WorldMapFrame and WorldMapFrame:IsShown()) then return end
  local pins = ns.StepPins(step)
  if not pins then return end
  local mapID = WorldMapFrame.GetMapID and WorldMapFrame:GetMapID()
  local child = WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child
  if not (mapID and child) then return end
  local w, h = child:GetWidth(), child:GetHeight()
  local scale = canvasScale()
  local size = 22 / scale
  local i = 0
  for n, p in ipairs(pins) do
    if ns.MapIDForZone(p.zone) == mapID then
      i = i + 1
      local b = getPin(i)
      b.pin, b.step = p, step
      local col = KIND_COLOR[p.kind] or KIND_COLOR.npc
      b:ClearAllPoints()
      b:SetPoint("CENTER", child, "TOPLEFT", p.x / 100 * w, -p.y / 100 * h)
      b:SetSize(size, size)
      if p.kind == "area" then
        local d = (p.r or 3) / 100 * w * 2
        b.area:ClearAllPoints(); b.area:SetPoint("CENTER"); b.area:SetSize(d, d)
        b.area:SetVertexColor(col[1], col[2], col[3], 0.28); b.area:Show()
      else
        b.area:Hide()
      end
      b.ring:ClearAllPoints(); b.ring:SetAllPoints(); b.ring:SetVertexColor(0, 0, 0, 0.85)
      b.dot:ClearAllPoints(); b.dot:SetPoint("TOPLEFT", 2 / scale, -2 / scale); b.dot:SetPoint("BOTTOMRIGHT", -2 / scale, 2 / scale)
      b.dot:SetVertexColor(col[1], col[2], col[3], 1)
      b.icon:ClearAllPoints(); b.icon:SetPoint("TOPLEFT", 4 / scale, -4 / scale); b.icon:SetPoint("BOTTOMRIGHT", -4 / scale, 4 / scale)
      local gicon = (ns.guides[step.skill] and ns.guides[step.skill].icon) or step.guide.icon
      b.icon:SetTexture(p.kind == "npc" and gicon or "Interface\\Icons\\INV_Misc_Fish_02")
      b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
      b.num:SetText(n)
      b.num:ClearAllPoints(); b.num:SetPoint("BOTTOMLEFT", b, "TOPRIGHT", -4 / scale, -6 / scale)
      if b.num.SetScale then pcall(b.num.SetScale, b.num, 1 / scale) end
      b:SetFrameLevel(overlay:GetFrameLevel() + (p.kind == "area" and 1 or 5))
      b:Show()
    end
  end
end

-- Open the map on this step's pins: the player's zone if it has one, else the first pin.
function ns.ShowStepOnMap(step)
  local pins = ns.StepPins(step)
  if not pins then ns.Print("No map pins for this step."); return end
  ns.mapStep = step
  local here = C_Map and C_Map.GetBestMapForUnit and C_Map.GetBestMapForUnit("player")
  local target
  for _, p in ipairs(pins) do
    local id = ns.MapIDForZone(p.zone)
    if id and id == here then target = id; break end
  end
  if not target then
    for _, p in ipairs(pins) do target = ns.MapIDForZone(p.zone); if target then break end end
  end
  if not target then ns.Print("Couldn't find these zones on your map."); return end
  if WorldMapFrame and not WorldMapFrame:IsShown() then
    if OpenWorldMap then pcall(OpenWorldMap, target) elseif ToggleWorldMap then ToggleWorldMap() end
  end
  if WorldMapFrame and WorldMapFrame.SetMapID then pcall(WorldMapFrame.SetMapID, WorldMapFrame, target) end
  ns.RefreshMapPins()
  -- list the zones in chat so pins elsewhere aren't missed
  local zones, seen = {}, {}
  for _, p in ipairs(pins) do if not seen[p.zone] then seen[p.zone] = true; table.insert(zones, p.zone) end end
  if #zones > 1 then ns.Print("Pins for " .. C.gold .. step.title .. C.r .. " in: " .. table.concat(zones, ", ")) end
end

function ns.InitMapPins()
  if not (WorldMapFrame and WorldMapFrame.ScrollContainer and WorldMapFrame.ScrollContainer.Child) then return end
  overlay = CreateFrame("Frame", nil, WorldMapFrame.ScrollContainer.Child)
  overlay:SetAllPoints(WorldMapFrame.ScrollContainer.Child)
  overlay:SetFrameLevel(WorldMapFrame.ScrollContainer.Child:GetFrameLevel() + 20)
  if WorldMapFrame.OnMapChanged then hooksecurefunc(WorldMapFrame, "OnMapChanged", ns.RefreshMapPins) end
  if WorldMapFrame.OnCanvasScaleChanged then hooksecurefunc(WorldMapFrame, "OnCanvasScaleChanged", ns.RefreshMapPins) end
  WorldMapFrame:HookScript("OnShow", ns.RefreshMapPins)
  WorldMapFrame:HookScript("OnHide", function() ns.mapStep = nil end)
end

ns.OnRefresh(function() if WorldMapFrame and WorldMapFrame:IsShown() then ns.RefreshMapPins() end end)
