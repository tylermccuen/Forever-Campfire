-- "Sizzle!": a tiny timing mini-game that pops up while you craft (any profession
-- window cast, e.g. Cook / Create All). Never while fishing: Fishing is a channeled
-- spell, so it doesn't fire UNIT_SPELLCAST_START. Purely for fun, no effect on crafts.
local _, ns = ...
local C = ns.C

local g, ev
local W = 230           -- bar width
local ZONE = 40         -- gold zone width
local HIDE_AFTER = 5    -- seconds after the last craft
local lastCast, pos, dir, speed, zoneX = 0, 0, 1, 140, 90
local score, combo, cooldown = 0, 0, 0

local function professionWindowOpen()
  return (ProfessionsFrame and ProfessionsFrame:IsShown()) or (TradeSkillFrame and TradeSkillFrame:IsShown())
end

local function newZone()
  zoneX = math.random(10, W - ZONE - 10)
  g.zone:ClearAllPoints()
  g.zone:SetPoint("LEFT", g.bar, "LEFT", zoneX, 0)
  g.perfect:ClearAllPoints()
  g.perfect:SetPoint("CENTER", g.zone, "CENTER")
end

local function feedback(text, r, gg, b)
  g.msg:SetText(text); g.msg:SetTextColor(r, gg, b)
  g.msg:SetAlpha(1); g.msgFade = 1.2
end

local function updateScore()
  g.score:SetText("Score " .. C.white .. score .. C.r .. "   Combo " .. C.white .. "x" .. combo .. C.r
    .. "   Best " .. C.gold .. (ns.db.minigameBest or 0) .. C.r)
end

local function flip()
  if cooldown > 0 then return end
  cooldown = 0.35
  local center = zoneX + ZONE / 2
  local d = math.abs(pos - center)
  if d <= 5 then
    combo = combo + 1; score = score + 3 * combo
    feedback("PERFECT!", 1, 0.82, 0)
    if PlaySound and SOUNDKIT and SOUNDKIT.IG_QUEST_LIST_COMPLETE then pcall(PlaySound, SOUNDKIT.IG_QUEST_LIST_COMPLETE) end
  elseif d <= ZONE / 2 then
    combo = combo + 1; score = score + combo
    feedback("Nice!", 0.4, 1, 0.4)
  else
    combo = 0
    feedback("Burnt...", 1, 0.3, 0.3)
  end
  speed = math.min(320, 140 + combo * 15)
  if score > (ns.db.minigameBest or 0) then ns.db.minigameBest = score end
  updateScore()
  newZone()
end

local function build()
  g = CreateFrame("Button", "ForeverProfGuideSizzle", UIParent, "BackdropTemplate")
  g:SetBackdrop(ns.BACKDROP)
  g:SetBackdropColor(0.12, 0.05, 0, 0.92); g:SetBackdropBorderColor(1, 0.5, 0.1, 1)
  g:SetSize(W + 30, 96)
  g:SetFrameStrata("DIALOG")
  local p = ns.db.minigamePos
  if p then g:SetPoint(p[1], UIParent, p[2], p[3], p[4]) else g:SetPoint("CENTER", UIParent, "CENTER", 0, -180) end
  g:SetMovable(true); g:EnableMouse(true); g:SetClampedToScreen(true)
  g:RegisterForDrag("RightButton")
  g:RegisterForClicks("LeftButtonDown")
  g:SetScript("OnDragStart", g.StartMoving)
  g:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local a, _, b, x, y = self:GetPoint(); ns.db.minigamePos = { a, b, x, y }
  end)
  g:SetScript("OnClick", flip)

  local title = g:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 10, -8)
  title:SetText("|TInterface\\Icons\\INV_Misc_Food_15:14|t Sizzle!  " .. C.grey .. "click in the gold" .. C.r)

  local close = CreateFrame("Button", nil, g, "UIPanelCloseButton")
  close:SetSize(22, 22); close:SetPoint("TOPRIGHT", -2, -2)
  close:SetScript("OnClick", function() g:Hide(); lastCast = 0 end)

  g.bar = CreateFrame("Frame", nil, g)
  g.bar:SetSize(W, 16); g.bar:SetPoint("TOP", 0, -30)
  local bg = g.bar:CreateTexture(nil, "BACKGROUND"); bg:SetAllPoints(); bg:SetColorTexture(0.25, 0.1, 0.05, 1)
  g.zone = g.bar:CreateTexture(nil, "BORDER"); g.zone:SetSize(ZONE, 16); g.zone:SetColorTexture(1, 0.7, 0.1, 0.8)
  g.perfect = g.bar:CreateTexture(nil, "ARTWORK"); g.perfect:SetSize(10, 16); g.perfect:SetColorTexture(1, 1, 0.6, 1)
  g.marker = g.bar:CreateTexture(nil, "OVERLAY"); g.marker:SetSize(4, 24); g.marker:SetColorTexture(1, 1, 1, 1)

  g.msg = g:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  g.msg:SetPoint("TOP", g.bar, "BOTTOM", 0, -6)
  g.score = g:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  g.score:SetPoint("BOTTOM", 0, 8)

  g:SetScript("OnUpdate", function(self, elapsed)
    pos = pos + dir * speed * elapsed
    if pos >= W then pos = W; dir = -1 elseif pos <= 0 then pos = 0; dir = 1 end
    g.marker:ClearAllPoints(); g.marker:SetPoint("CENTER", g.bar, "LEFT", pos, 0)
    if cooldown > 0 then cooldown = cooldown - elapsed end
    if self.msgFade then
      self.msgFade = self.msgFade - elapsed
      self.msg:SetAlpha(math.max(0, self.msgFade))
      if self.msgFade <= 0 then self.msgFade = nil end
    end
    if lastCast > 0 and GetTime() - lastCast > HIDE_AFTER then self:Hide() end
  end)
  g:SetScript("OnShow", function()
    score, combo, speed = 0, 0, 140
    g.msg:SetText("")
    updateScore(); newZone()
  end)
  g:Hide()
end

local function onCast(unit)
  if unit ~= "player" or not ns.db.minigame then return end
  if InCombatLockdown and InCombatLockdown() then return end
  if not professionWindowOpen() then return end
  if not g then build() end
  lastCast = GetTime()
  if not g:IsShown() then g:Show() end
end

function ns.InitMiniGame()
  ev = CreateFrame("Frame")
  pcall(ev.RegisterEvent, ev, "UNIT_SPELLCAST_START")
  pcall(ev.RegisterEvent, ev, "PLAYER_REGEN_DISABLED")
  ev:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_REGEN_DISABLED" then if g then g:Hide() end return end
    onCast(unit)
  end)
end

-- /fpg sizzle lets people try it without crafting
function ns.ShowMiniGame()
  if not g then build() end
  lastCast = GetTime() + 25
  g:Show()
end
