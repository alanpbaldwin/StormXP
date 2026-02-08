local StormXP = LibStub("AceAddon-3.0"):GetAddon("StormXP")

-----------------------------------------------------------------------
-- FRAME CREATION
-----------------------------------------------------------------------

function StormXP:OnTooltipEnter(frame, tooltip)

    local tt = tooltip or GameTooltip

    

    if not tooltip then

        if not self.db.profile.showTooltip then return end

        tt:SetOwner(frame, "ANCHOR_CURSOR")

    end



    local name = UnitName("player")

    local _, class = UnitClass("player")

    local color = RAID_CLASS_COLORS[class] or {r=1, g=1, b=1}

    tt:AddLine(name, color.r, color.g, color.b) 

    

    local level = UnitLevel("player")

    tt:AddLine("Level " .. level, 1, 1, 1)

    

    local _, _, _, _, _, _, mode = self:GetModeData()

    

    tt:AddLine(" ") -- Spacer

    

    if mode == "REP" then

        local data = C_Reputation.GetWatchedFactionData()

        if data then

            local rankName = _G["FACTION_STANDING_LABEL"..data.reaction] or "Unknown"

            local curr = data.currentReactionThreshold

            local max = data.nextReactionThreshold

            local pct = (max > 0) and (curr / max) * 100 or 0

            

            tt:AddLine(data.name, 1, 0.82, 0) -- Faction Name

            tt:AddDoubleLine("Rank:", rankName, 1, 1, 1, 1, 1, 1)

            tt:AddDoubleLine("Progress:", string.format("%s / %s (%.1f%%)", self:FormatNumber(curr), self:FormatNumber(max), pct), 1, 1, 1, 1, 1, 1)

        else

            tt:AddLine("No Faction Watched", 1, 0, 0)

        end

    elseif mode == "HONOR" then

        local curr = UnitHonor("player")

        local max = UnitHonorMax("player")

        local honorLevel = UnitHonorLevel("player")

        local pct = (max > 0) and (curr / max) * 100 or 0

        

        tt:AddLine("Honor", 1, 0.82, 0)

        tt:AddDoubleLine("Honor Level:", honorLevel, 1, 1, 1, 1, 1, 1)

        tt:AddDoubleLine("Progress:", string.format("%s / %s (%.1f%%)", self:FormatNumber(curr), self:FormatNumber(max), pct), 1, 1, 1, 1, 1, 1)

    else

        -- XP Mode

        local currXP = UnitXP("player")

        local maxXP = UnitXPMax("player")

        local restedXP = GetXPExhaustion() or 0

        local questXP = self.questXP

        local pct = (maxXP > 0) and (currXP / maxXP) * 100 or 0

        

        tt:AddDoubleLine("Experience:", string.format("%s / %s (%.1f%%)", self:FormatNumber(currXP), self:FormatNumber(maxXP), pct), 1, 1, 1, 1, 1, 1)

        

        if restedXP > 0 then

            local restedPct = (maxXP > 0) and (restedXP / maxXP) * 100 or 0

            local r, g, b = unpack(self.db.profile.colorRested)

            tt:AddDoubleLine("Rested:", string.format("%s (%.1f%%)", self:FormatNumber(restedXP), restedPct), r, g, b, 1, 1, 1)

        end

        

        if questXP > 0 then

            local questPct = (maxXP > 0) and (questXP / maxXP) * 100 or 0

            local r, g, b = unpack(self.db.profile.colorQuest)

            tt:AddDoubleLine("Completed Quests:", string.format("+%s (+%.1f%%)", self:FormatNumber(questXP), questPct), r, g, b, 1, 1, 1)

        end

    end

    

    tt:AddLine(" ")

    tt:AddLine("Session Statistics", 1, 0.82, 0)

    

    local duration = GetTime() - self.session.startTime

    local xpPerHour = 0

    if duration > 0 then xpPerHour = (self.session.gained / duration) * 3600 end

    

    tt:AddDoubleLine("Time Played:", self:FormatTime(duration), 1, 1, 1, 1, 1, 1)

    

    -- Only show XP Gained/TTL if in XP mode

    if mode == "XP" or mode == "NONE" then

        tt:AddDoubleLine("XP Gained:", self:FormatNumber(self.session.gained), 1, 1, 1, 1, 1, 1)

        tt:AddDoubleLine("XP / Hour:", self:FormatNumber(xpPerHour), 1, 1, 1, 1, 1, 1)

        

        if xpPerHour > 0 then

            local currXP = UnitXP("player")

            local maxXP = UnitXPMax("player")

            local needed = maxXP - currXP

            local ttl = (needed / xpPerHour) * 3600

            tt:AddDoubleLine("Time to Level:", self:FormatTime(ttl), 1, 1, 1, 1, 1, 1)

        else

            tt:AddDoubleLine("Time to Level:", "N/A", 1, 1, 1, 0.5, 0.5, 0.5)

        end

    end

    

    tt:Show()

end

function StormXP:CreateBar()
    -- Main Container (Movable)
    local f = CreateFrame("Frame", "StormXP_Bar", UIParent)
    f:SetSize(self.db.profile.width, self.db.profile.height)
    f:SetPoint(self.db.profile.point, UIParent, self.db.profile.relPoint, self.db.profile.x, self.db.profile.y)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        local point, _, relPoint, x, y = f:GetPoint()
        self.db.profile.point = point
        self.db.profile.relPoint = relPoint
        self.db.profile.x = x
        self.db.profile.y = y
    end)

    -- Background
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(unpack(self.db.profile.colorBack))
    self.bg = bg

    -- Main XP Bar
    local xp = CreateFrame("StatusBar", nil, f)
    xp:SetAllPoints()
    xp:SetStatusBarTexture(self:GetMedia("statusbar", self.db.profile.texture))
    xp:SetStatusBarColor(unpack(self.db.profile.colorXP))
    xp:SetFrameLevel(f:GetFrameLevel() + 3) -- XP on Top
    self.barXP = xp

    -- Rested XP Bar (Overlay)
    local rested = CreateFrame("StatusBar", nil, f)
    rested:SetAllPoints()
    rested:SetStatusBarTexture(self:GetMedia("statusbar", self.db.profile.texture))
    rested:SetStatusBarColor(unpack(self.db.profile.colorRested))
    rested:SetFrameLevel(f:GetFrameLevel() + 2) -- Rested below XP
    self.barRested = rested

    -- Quest XP Bar (Overlay)
    local quest = CreateFrame("StatusBar", nil, f)
    quest:SetAllPoints()
    quest:SetStatusBarTexture(self:GetMedia("statusbar", self.db.profile.texture))
    quest:SetStatusBarColor(unpack(self.db.profile.colorQuest))
    quest:SetFrameLevel(f:GetFrameLevel() + 1) -- Quest below Rested
    self.barQuest = quest

    -- Text Elements (Parented to XP bar to ensure they draw ON TOP)
    self.levelText = xp:CreateFontString(nil, "OVERLAY")
    self.percentText = xp:CreateFontString(nil, "OVERLAY")
    self.rawText = xp:CreateFontString(nil, "OVERLAY")
    self.sessionText = xp:CreateFontString(nil, "OVERLAY")
    self.levelTimeText = xp:CreateFontString(nil, "OVERLAY")
    self.ttlText = xp:CreateFontString(nil, "OVERLAY")
    self.restedText = xp:CreateFontString(nil, "OVERLAY")

    -- Segment Lines
    self.segmentLines = {}

    -- Tooltip
    f:SetScript("OnEnter", function() self:OnTooltipEnter(f) end)
    f:SetScript("OnLeave", function() GameTooltip:Hide() end)

    self.frame = f
    self:ApplySettings()
end

function StormXP:UpdateSegments()
    local db = self.db.profile.segments
    local totalWidth = self.db.profile.width

    -- Hide all existing
    for _, line in ipairs(self.segmentLines) do
        line:Hide()
    end

    if not db.enabled then return end

    local lineIdx = 1
    -- Iterate percentage from step to 100 (exclusive of 0 and 100)
    for p = db.minorStep, 99.9, db.minorStep do
        local line = self.segmentLines[lineIdx]
        if not line then
            line = self.barXP:CreateTexture(nil, "OVERLAY")
            line:SetTexture("Interface\\Buttons\\WHITE8x8")
            self.segmentLines[lineIdx] = line
        end

        line:Show()

        -- Check Major
        -- Floating point modulo safety: check if remainder is very small or very close to step
        local rem = p % db.majorStep
        local isMajor = db.major and (rem < 0.1 or math.abs(rem - db.majorStep) < 0.1)

        if isMajor then
            line:SetWidth(db.widthMajor or 2)
            line:SetColorTexture(unpack(db.colorMajor))
        else
            line:SetWidth(db.width or 1)
            line:SetColorTexture(unpack(db.color))
        end

        line:SetHeight(self.db.profile.height)
        line:ClearAllPoints()

        local xPos = (p / 100) * totalWidth
        line:SetPoint("LEFT", self.barXP, "LEFT", xPos, 0)

        lineIdx = lineIdx + 1
    end
end

function StormXP:ApplySettings()
    local db = self.db.profile

    self.frame:SetSize(db.width, db.height)
    self.frame:ClearAllPoints()
    self.frame:SetPoint(db.point, UIParent, db.relPoint, db.x, db.y)

    self.frame:SetScale(db.scale)
    self.frame:SetAlpha(db.alpha)

    -- Lock Logic
    self.frame:EnableMouse(true) -- Always enabled for Tooltips
    if db.locked then
        self.frame:SetMovable(false)
        self.frame:RegisterForDrag() -- Unregister dragging
    else
        self.frame:SetMovable(true)
        self.frame:RegisterForDrag("LeftButton")
    end

    self.bg:SetColorTexture(unpack(db.colorBack))

    local tex = self:GetMedia("statusbar", db.texture)
    self.barXP:SetStatusBarTexture(tex)
    self.barXP:SetStatusBarColor(unpack(db.colorXP))

    self.barRested:SetStatusBarTexture(tex)
    self.barRested:SetStatusBarColor(unpack(db.colorRested))

    self.barQuest:SetStatusBarTexture(tex)
    self.barQuest:SetStatusBarColor(unpack(db.colorQuest))

    -- Apply Text Settings
    local function ApplyText(str, cfg)
        if cfg.enabled then
            str:Show()
            str:SetFont(self:GetMedia("font", cfg.font), cfg.size, cfg.outline)
            -- Only set base color if NOT rested text (which uses split coloring)
            if str ~= self.restedText then
                str:SetTextColor(unpack(cfg.color))
            end
            str:ClearAllPoints()
            -- Always anchor to barXP to ensure relative positioning works with the parent
            str:SetPoint(cfg.point, self.barXP, cfg.relPoint or cfg.point, cfg.x, cfg.y)
        else
            str:Hide()
        end
    end

    ApplyText(self.levelText, db.textLevel)
    ApplyText(self.percentText, db.textPercent)
    ApplyText(self.rawText, db.textRaw)
    ApplyText(self.sessionText, db.textSession)
    ApplyText(self.levelTimeText, db.textLevelTime)
    ApplyText(self.ttlText, db.textTTL)
    ApplyText(self.restedText, db.textRested)

    if db.enabled then self.frame:Show() else self.frame:Hide() end

    self:UpdateSegments()
    self:UpdateBar()
end

function StormXP:UpdateStatusBars(curr, max, barColor, showRested, showQuest)
    self.barXP:SetMinMaxValues(0, max)
    self.barXP:SetValue(curr)
    self.barXP:SetStatusBarColor(unpack(barColor))

    if showRested then
        local restedXP = GetXPExhaustion() or 0
        self.barRested:Show()
        self.barRested:SetMinMaxValues(0, max)
        self.barRested:SetValue(math.min(max, curr + restedXP))
    else
        self.barRested:Hide()
    end

    if showQuest then
        local questXP = self.questXP
        self.barQuest:Show()
        self.barQuest:SetMinMaxValues(0, max)
        self.barQuest:SetValue(math.min(max, curr + questXP))
    else
        self.barQuest:Hide()
    end

    if showRested or showQuest then
        local base = self.frame:GetFrameLevel()
        self.barXP:SetFrameLevel(base + 10)

        local restedXP = (showRested and GetXPExhaustion()) or 0
        local questXP = (showQuest and self.questXP) or 0

        if restedXP < questXP then
            self.barRested:SetFrameLevel(base + 6)
            self.barQuest:SetFrameLevel(base + 5)
        else
            self.barQuest:SetFrameLevel(base + 6)
            self.barRested:SetFrameLevel(base + 5)
        end
    end
end

function StormXP:UpdateTextElements(curr, max, label, showRested, showQuest)
    self.levelText:SetText(label)
    self.rawText:SetText(string.format("%s / %s", self:FormatNumber(curr), self:FormatNumber(max)))

    local pct = (curr / max) * 100
    local showQuestText = showQuest and self.db.profile.textPercent.showQuestXP

    if showQuestText then
        local questXP = self.questXP
        if questXP > 0 then
            local questPct = (questXP / max) * 100
            self.percentText:SetText(string.format("%.1f%% (%.1f%%)", pct, questPct))
        else
            self.percentText:SetText(string.format("%.1f%%", pct))
        end
    else
        self.percentText:SetText(string.format("%.1f%%", pct))
    end

    if showRested and self.db.profile.textRested.enabled then
        local restedXP = GetXPExhaustion() or 0
        if restedXP > 0 then
            local restedPct = (restedXP / max) * 100
            self.restedText:Show()

            local rBar, gBar, bBar = unpack(self.db.profile.colorRested)
            local rVal, gVal, bVal = unpack(self.db.profile.textRested.color)
            local hexBar = self:DecToHex(rBar, gBar, bBar)
            local hexVal = self:DecToHex(rVal, gVal, bVal)

            self.restedText:SetText(string.format("|cff%s%s|r|cff%s%.0f%%|r",
                hexBar, self.db.profile.labels.rested, hexVal, restedPct))
        else
            self.restedText:Hide()
        end
    else
        self.restedText:Hide()
    end
end

function StormXP:UpdateBar()
    if not self.db.profile.enabled then
        self.frame:Hide()
        return
    end

    local curr, max, label, color, showRested, showQuest, activeMode = self:GetModeData()

    if activeMode == "NONE" then
        self.frame:Hide()
        return
    end

        self.frame:Show()
        
        self:UpdateStatusBars(curr, max, color, showRested, showQuest)
        self:UpdateTextElements(curr, max, label, showRested, showQuest)
        
        -- Update Broker Display if available
        if self.UpdateLDB then self:UpdateLDB() end
    end
