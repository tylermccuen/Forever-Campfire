-- The skill tree: rank bands from top to bottom. The rank you're in opens as a
-- tree (forks for recipe options, gates for rank-ups); finished and future ranks
-- fold into one slim tile each. Built from the guide data, so it works for every
-- profession without extra layout data.
local _, ns = ...
local C = ns.C

local content
local tiles, lines, bandFrames, folds = {}, {}, {}, {}
local nTiles, nLines, nBands, nFolds = 0, 0, 0, 0
ns.treeOpen = {}       -- [guideKey .. rank] = true/false, set by clicking a band
ns.treeCurrentY = 0    -- y of the current tile, for scrolling to it

local COL = {
  done    = { bg = { 0.06, 0.12, 0.07 }, edge = { 0.25, 0.55, 0.30 }, title = { 0.78, 0.92, 0.80 }, sub = { 0.60, 0.68, 0.60 }, line = { 0.25, 0.55, 0.30 } },
  current = { bg = { 0.17, 0.13, 0.03 }, edge = { 0.91, 0.76, 0.35 }, title = { 0.96, 0.85, 0.54 }, sub = { 0.89, 0.84, 0.68 }, line = { 0.91, 0.76, 0.35 } },
  todo    = { bg = { 0.09, 0.09, 0.12 }, edge = { 0.30, 0.30, 0.34 }, title = { 0.81, 0.79, 0.72 }, sub = { 0.60, 0.58, 0.54 }, line = { 0.30, 0.29, 0.26 } },
  gate    = { bg = { 0.12, 0.10, 0.16 }, edge = { 0.42, 0.35, 0.60 }, title = { 0.82, 0.78, 0.94 }, sub = { 0.66, 0.62, 0.78 }, line = { 0.30, 0.29, 0.26 } },
  alt     = { bg = { 0.08, 0.08, 0.10 }, edge = { 0.26, 0.25, 0.22 }, title = { 0.62, 0.60, 0.56 }, sub = { 0.52, 0.50, 0.47 }, line = { 0.26, 0.25, 0.22 } },
}

---------------------------------------------------------------------------
-- Pools
---------------------------------------------------------------------------
local function newLine()
  nLines = nLines + 1
  local t = lines[nLines]
  if not t then
    t = content.lineLayer:CreateTexture(nil, "ARTWORK")
    lines[nLines] = t
  end
  t:Show()
  return t
end

local function line(x, y, w, h, col)
  local t = newLine()
  t:ClearAllPoints()
  t:SetPoint("TOPLEFT", content, "TOPLEFT", x, -y)
  t:SetSize(math.max(w, 2), math.max(h, 2))
  t:SetColorTexture(col[1], col[2], col[3], 1)
end

local function tileTooltip(self)
  GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
  GameTooltip:SetText(self.tTitle or "", 1, 0.82, 0, 1, true)
  if self.optIdx then
    GameTooltip:AddLine("Click: use this one and lock it in.", 1, 1, 1, true)
    GameTooltip:AddLine("Right-click: let the guide pick again.", 0.7, 0.7, 0.7, true)
  else
    GameTooltip:AddLine("Click for details.", 1, 1, 1, true)
  end
  GameTooltip:Show()
end

local function newTile()
  nTiles = nTiles + 1
  local b = tiles[nTiles]
  if not b then
    b = CreateFrame("Button", nil, content, "BackdropTemplate")
    b:SetBackdrop(ns.BACKDROP)
    b:SetFrameLevel(content:GetFrameLevel() + 6)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(34, 34); b.icon:SetPoint("LEFT", 9, 0)
    b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
    b.check = b:CreateTexture(nil, "OVERLAY")
    b.check:SetSize(16, 16); b.check:SetPoint("TOPRIGHT", -5, -5)
    b.title = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.title:SetPoint("TOPLEFT", b.icon, "TOPRIGHT", 8, 1); b.title:SetJustifyH("LEFT")
    b.title:SetWordWrap(false)
    b.sub = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.sub:SetPoint("TOPLEFT", b.title, "BOTTOMLEFT", 0, -3); b.sub:SetJustifyH("LEFT")
    b.sub:SetWordWrap(false)
    b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    b:SetScript("OnClick", function(self, button)
      if self.optIdx then
        if button == "RightButton" then ns.ClearChoice(self.step) else ns.SetChoice(self.step, self.optIdx) end
      end
      ns.SelectStep(self.step)
    end)
    b:SetScript("OnEnter", tileTooltip)
    b:SetScript("OnLeave", GameTooltip_Hide)
    tiles[nTiles] = b
  end
  b:Show()
  return b
end

local function newBand()
  nBands = nBands + 1
  local f = bandFrames[nBands]
  if not f then
    f = CreateFrame("Frame", nil, content, "BackdropTemplate")
    f:SetBackdrop(ns.BACKDROP)
    f:SetFrameLevel(content:GetFrameLevel() + 1)
    f.head = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.head:SetPoint("TOPLEFT", 12, -9); f.head:SetJustifyH("LEFT")
    f.fold = CreateFrame("Button", nil, f)
    f.fold:SetSize(60, 18); f.fold:SetPoint("TOPRIGHT", -8, -6)
    f.fold.text = f.fold:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    f.fold.text:SetPoint("RIGHT"); f.fold.text:SetText("fold ^")
    f.fold:SetScript("OnClick", function(self) ns.treeOpen[self.key] = false; ns.UpdateMain() end)
    bandFrames[nBands] = f
  end
  f:Show()
  return f
end

local function newFold()
  nFolds = nFolds + 1
  local b = folds[nFolds]
  if not b then
    b = CreateFrame("Button", nil, content, "BackdropTemplate")
    b:SetBackdrop(ns.BACKDROP)
    b:SetFrameLevel(content:GetFrameLevel() + 6)
    b.icon = b:CreateTexture(nil, "ARTWORK")
    b.icon:SetSize(16, 16); b.icon:SetPoint("LEFT", 12, 0)
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("LEFT", b.icon, "RIGHT", 8, 0); b.text:SetJustifyH("LEFT")
    b.right = b:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    b.right:SetPoint("RIGHT", -12, 0)
    b:SetScript("OnClick", function(self) ns.treeOpen[self.key] = true; ns.UpdateMain() end)
    folds[nFolds] = b
  end
  b:Show()
  return b
end

local function paint(frame, col)
  frame:SetBackdropColor(col.bg[1], col.bg[2], col.bg[3], 0.95)
  frame:SetBackdropBorderColor(col.edge[1], col.edge[2], col.edge[3], 1)
end

---------------------------------------------------------------------------
-- Tile content
---------------------------------------------------------------------------
local function stepIcon(step, opt)
  if step.kind == "learn" then return (ns.guides[step.skill] and ns.guides[step.skill].icon) or step.guide.icon end
  if step.kind == "train" then return "Interface\\Icons\\INV_Misc_Book_11" end
  if step.kind == "quest" then return "Interface\\Icons\\INV_Misc_Note_01" end
  if opt and opt.mats and opt.mats[1] then return ns.ItemIcon(opt.mats[1][1]) end
  if opt and opt.buy and opt.buy[1] then return ns.ItemIcon(opt.buy[1].id) end
  if step.catch and step.catch[1] then return ns.ItemIcon(step.catch[1][1]) end
  return (ns.guides[step.skill] and ns.guides[step.skill].icon) or step.guide.icon
end

local function subText(step, state, opt, isNext)
  local blockers = ns.StepBlockers(step)
  local range = ns.RangeText(step)
  if #step.guide.skills > 1 then range = ns.SkillDisplayName(step.skill) .. " " .. range end
  if state == "done" then return range .. " · done" end
  if state == "current" then
    if #blockers > 0 then return C.red .. blockers[1] .. C.r end
    if step.kind == "level" then
      if opt and opt.count then return range .. " · about " .. ns.CraftsLeft(step, opt) .. " left" end
      local sk = ns.Skill(step.skill)
      return range .. " · " .. (step.to - math.max(sk.rank, step.from)) .. " to go"
    end
    return range .. " · do this now"
  end
  if step.requires and step.requires.skill then return range .. " · at " .. step.requires.skill end
  return range .. (isNext and " · next" or "")
end

local function fillTile(b, step, state, opt, optIdx, chosen, isNext, w, h)
  b.step, b.optIdx = step, optIdx
  b:SetSize(w, h)
  local kind = state
  if (step.kind == "train" or step.kind == "quest") and state == "todo" then kind = "gate" end
  if optIdx and not chosen then kind = "alt" end
  paint(b, COL[kind])
  local col = COL[kind]
  local title = optIdx and (opt.label .. " · " .. (opt.name or opt.recipe)) or step.title
  b.tTitle = title
  b.title:SetText(title)
  b.title:SetTextColor(col.title[1], col.title[2], col.title[3])
  b.title:SetWidth(w - 67)
  local sub
  if optIdx and not chosen then
    sub = (state == "done") and "not used" or ("other option" .. (ns.IsPinned(step) and "" or " · click to use"))
  else
    sub = subText(step, state, opt, isNext)
    if optIdx and ns.IsPinned(step) and state ~= "done" then sub = sub .. " · locked" end
  end
  b.sub:SetText(sub)
  b.sub:SetTextColor(col.sub[1], col.sub[2], col.sub[3])
  b.sub:SetWidth(w - 67)
  b.icon:SetTexture(stepIcon(step, opt))
  b.icon:SetDesaturated(kind == "alt" or kind == "todo")
  b.check:SetTexture(state == "done" and (not optIdx or chosen) and "Interface\\RaidFrame\\ReadyCheck-Ready" or nil)
  if ns.selectedStep == step and state ~= "current" and (not optIdx or chosen) then
    b:SetBackdropBorderColor(1, 1, 1, 1)
  end
end

---------------------------------------------------------------------------
-- Layout
---------------------------------------------------------------------------
function ns.InitTree(parentContent)
  content = parentContent
  content.lineLayer = CreateFrame("Frame", nil, content)
  content.lineLayer:SetAllPoints(content)
  content.lineLayer:SetFrameLevel(content:GetFrameLevel() + 3)
end

function ns.LayoutTree(guide, W)
  for _, t in ipairs(tiles) do t:Hide() end
  for _, t in ipairs(lines) do t:Hide() end
  for _, t in ipairs(bandFrames) do t:Hide() end
  for _, t in ipairs(folds) do t:Hide() end
  nTiles, nLines, nBands, nFolds = 0, 0, 0, 0

  local bands = ns.Bands(guide)
  local current = ns.CurrentStep(guide)
  local cx = math.floor(W / 2)
  local y = 8
  local prevCol
  local anyCurrent = false
  for _, b in ipairs(bands) do if b.current then anyCurrent = true end end
  ns.treeCurrentY = 0
  local seenCurrent = false

  for bi, band in ipairs(bands) do
    local key = guide.key .. band.rank
    local open = ns.treeOpen[key]
    if open == nil then open = band.current or (not anyCurrent and bi == #bands) end
    local bcol = band.done and COL.done or (band.current and COL.current or COL.todo)

    if bi > 1 then line(cx - 1, y, 2, 14, prevCol or COL.todo.line); y = y + 14 end

    local label = string.upper(band.info.name)
    local range = band.info.from .. "-" .. band.info.to
    local status = band.done and "done" or (band.current and "you are here" or (#band.steps .. (#band.steps == 1 and " step" or " steps")))

    if not open then
      local f = newFold()
      f.key = key
      f:ClearAllPoints(); f:SetPoint("TOPLEFT", content, "TOPLEFT", 8, -y)
      f:SetSize(W - 16, 40)
      paint(f, bcol)
      f.icon:SetTexture(band.done and "Interface\\RaidFrame\\ReadyCheck-Ready" or (band.current and "Interface\\RaidFrame\\ReadyCheck-Waiting" or "Interface\\LFGFrame\\UI-LFG-ICON-LOCK"))
      f.text:SetText(label .. C.grey .. "  " .. range .. " · " .. status .. C.r)
      f.text:SetTextColor(bcol.title[1], bcol.title[2], bcol.title[3])
      f.right:SetText("open")
      y = y + 40
      prevCol = bcol.line
    else
      local frame = newBand()
      frame.fold.key = key
      local top = y
      frame.head:SetText(label .. C.grey .. "  " .. range .. " · " .. status .. C.r)
      frame.head:SetTextColor(bcol.title[1], bcol.title[2], bcol.title[3])
      y = y + 36
      local first = true
      local afterCurrent = false
      for _, step in ipairs(band.steps) do
        local state = (step == current) and "current" or (ns.IsStepDone(step) and "done" or "todo")
        local isNext = afterCurrent and state == "todo"
        if step == current then afterCurrent = true; seenCurrent = true elseif state == "todo" then afterCurrent = false end
        local rowCol = COL[state].line
        local opts = ns.Options(step)
        if not first then line(cx - 1, y, 2, 18, rowCol); y = y + 18 end
        if #opts > 1 then
          local n = #opts
          local gap = 16
          local tw = math.min(230, math.floor((W - 40 - (n - 1) * gap) / n))
          local total = n * tw + (n - 1) * gap
          local x0 = cx - math.floor(total / 2)
          local _, chosenIdx = ns.ChosenOption(step)
          local c1 = x0 + math.floor(tw / 2)
          local cn = x0 + (n - 1) * (tw + gap) + math.floor(tw / 2)
          -- fork
          if not first then line(cx - 1, y, 2, 8, rowCol) end
          line(c1, y + 8, cn - c1, 2, COL.todo.line)
          for j = 1, n do
            local cxj = x0 + (j - 1) * (tw + gap) + math.floor(tw / 2)
            line(cxj - 1, y + 8, 2, 12, (j == chosenIdx) and rowCol or COL.alt.line)
          end
          local rowTop = y + 20
          for j, opt in ipairs(opts) do
            local t = newTile()
            t:ClearAllPoints(); t:SetPoint("TOPLEFT", content, "TOPLEFT", x0 + (j - 1) * (tw + gap), -rowTop)
            fillTile(t, step, state, opt, j, j == chosenIdx, isNext, tw, 64)
          end
          if state == "current" then ns.treeCurrentY = rowTop end
          local bottom = rowTop + 64
          -- merge
          for j = 1, n do
            local cxj = x0 + (j - 1) * (tw + gap) + math.floor(tw / 2)
            line(cxj - 1, bottom, 2, 12, (j == chosenIdx) and rowCol or COL.alt.line)
          end
          line(c1, bottom + 12, cn - c1, 2, COL.todo.line)
          y = bottom + 14
        else
          local tw = math.min(280, W - 60)
          local t = newTile()
          t:ClearAllPoints(); t:SetPoint("TOPLEFT", content, "TOPLEFT", cx - math.floor(tw / 2), -y)
          fillTile(t, step, state, opts[1], nil, true, isNext, tw, 56)
          if state == "current" then ns.treeCurrentY = y end
          y = y + 56
        end
        first = false
        prevCol = rowCol
      end
      y = y + 12
      frame:ClearAllPoints(); frame:SetPoint("TOPLEFT", content, "TOPLEFT", 8, -top)
      frame:SetSize(W - 16, y - top)
      paint(frame, band.current and { bg = { 0.10, 0.09, 0.05 }, edge = COL.current.edge } or { bg = { 0.07, 0.07, 0.09 }, edge = bcol.edge })
      prevCol = bcol.line
    end
  end
  return y + 8
end
