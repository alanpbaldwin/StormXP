local StormXP = LibStub("AceAddon-3.0"):NewAddon("StormXP", "AceEvent-3.0", "AceConsole-3.0", "AceTimer-3.0")

-- Cache frequently used globals
local GetTime = GetTime
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local UnitLevel = UnitLevel
local UnitHonor = UnitHonor
local UnitHonorMax = UnitHonorMax
local UnitHonorLevel = UnitHonorLevel
local GetMaxLevelForPlayerExpansion = GetMaxLevelForPlayerExpansion or function() return 80 end
local RequestTimePlayed = RequestTimePlayed
local C_Reputation = C_Reputation
local C_MajorFactions = C_MajorFactions
local string_format = string.format

local EMPTY_COLOR = {0, 0, 0, 0}

-- Addon Compartment handler (must be global per TOC spec)
function StormXP_OnAddonCompartmentClick(_, button)
    if button == "RightButton" then
        StormXP:ChatHandler()
    else
        StormXP.db.profile.enabled = not StormXP.db.profile.enabled
        StormXP:ApplySettings()
    end
end

function StormXP:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("StormXPDB", self.defaults, true)
    self.db.RegisterCallback(self, "OnProfileChanged", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileCopied", "ApplySettings")
    self.db.RegisterCallback(self, "OnProfileReset", "ApplySettings")

    -- Register Options
    if self.GetOptions then
        LibStub("AceConfig-3.0"):RegisterOptionsTable("StormXP", self:GetOptions())
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions("StormXP", "StormXP")
        LibStub("AceConfigDialog-3.0"):AddToBlizOptions("StormXP", "Profiles", "StormXP", "profiles")
    end

    -- LDB Support
    local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
    if ldb and self.db.profile.enableLDB then
        self.ldb = ldb:NewDataObject("StormXP", {
            type = "data source",
            text = "StormXP",
            icon = "Interface\\Icons\\inv_misc_book_09",
            OnTooltipShow = function(tt) self:OnTooltipEnter(nil, tt) end,
            OnClick = function(_, button)
                if button == "RightButton" then
                    self:ChatHandler() -- Open Config
                else
                    self.db.profile.enabled = not self.db.profile.enabled
                    self:ApplySettings()
                end
            end,
        })

        local icon = LibStub:GetLibrary("LibDBIcon-1.0", true)
        if icon then
            icon:Register("StormXP", self.ldb, self.db.profile.minimap)
        end
    end

    -- Runtime Session Tracking
    self.session = {
        startTime = GetTime(),
        gained = 0
    }

    self.levelTime = {
        total = 0,
        level = 0,
        lastUpdate = GetTime()
    }

    self.questXP = 0

    self:CreateBar()
    self:RegisterChatCommand("sxp", "ChatHandler")
    self:RegisterChatCommand("stormxp", "ChatHandler")
end

function StormXP:OnEnable()
    self:RegisterEvent("PLAYER_XP_UPDATE")
    self:RegisterEvent("PLAYER_LEVEL_UP")
    self:RegisterEvent("UPDATE_EXHAUSTION")
    self:RegisterEvent("QUEST_LOG_UPDATE")
    self:RegisterEvent("TIME_PLAYED_MSG")
    self:RegisterEvent("UPDATE_FACTION")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")

    RequestTimePlayed()

    -- Initialize tracking baselines
    self.lastXP = UnitXP("player")
    self.lastMaxXP = UnitXPMax("player")
    self.questXP = self:ScanQuestXP()

    self:UpdateBar()

    -- Start Timer Loop
    if self.timer then self:CancelTimer(self.timer) end
    self.timer = self:ScheduleRepeatingTimer("UpdateTimers", 1)
end

function StormXP:ChatHandler(input)
    if input == "reset" then
        self:ResetSession()
    else
        LibStub("AceConfigDialog-3.0"):Open("StormXP")
    end
end

function StormXP:ResetSession()
    self.session.startTime = GetTime()
    self.session.gained = 0
    self.lastXP = UnitXP("player")
    self:UpdateBar()
    self:Print("Session statistics reset.")
end

-----------------------------------------------------------------------
-- LOGIC & DATA PROCESSING
-----------------------------------------------------------------------

--- Resolves the current tracking mode without fetching data.
-- @return mode (string) "XP", "REP", "HONOR", or "NONE"
function StormXP:GetActiveMode()
    local mode = self.db.profile.mode
    local isMax = (UnitLevel("player") == GetMaxLevelForPlayerExpansion())

    if mode == "AUTO" then
        if isMax then
            if self.db.profile.autoHideMax then return "NONE" end
            mode = self.db.profile.endgame
        else
            mode = "XP"
        end
    end
    return mode or "NONE"
end

-- Sync player level time with server message
function StormXP:TIME_PLAYED_MSG(_, total, level)
    self.levelTime.total = total
    self.levelTime.level = level
    self.levelTime.lastUpdate = GetTime()
end

--- Updates session-based text elements (session time, level time, TTL).
-- Called every 1s by ScheduleRepeatingTimer.
function StormXP:UpdateTimers()
    local mode = self:GetActiveMode()
    local isXP = (mode == "XP")
    local now = GetTime()

    -- 1. Session Time (Total time since login or reset)
    if isXP and self.db.profile.textSession.enabled then
        local sessionDur = now - self.session.startTime
        self.sessionText:SetText(self.db.profile.labels.session .. self:FormatTime(sessionDur))
        self.sessionText:Show()
    else
        self.sessionText:Hide()
    end

    -- 2. Level Time (Total time spent on the current level)
    if isXP and self.db.profile.textLevelTime.enabled then
        local elapsedSinceUpdate = now - self.levelTime.lastUpdate
        local currentLevelTime = self.levelTime.level + elapsedSinceUpdate
        self.levelTimeText:SetText(self.db.profile.labels.levelTime .. self:FormatTime(currentLevelTime))
        self.levelTimeText:Show()
    else
        self.levelTimeText:Hide()
    end

    -- 3. Time to Level (TTL) calculation based on session XP/hour
    if isXP and self.db.profile.textTTL.enabled then
        local duration = now - self.session.startTime
        if self.session.gained > 0 and duration > 0 then
            local xph = (self.session.gained / duration) * 3600
            local currXP = UnitXP("player")
            local maxXP = UnitXPMax("player")
            local needed = maxXP - currXP
            local ttl = (needed / xph) * 3600
            self.ttlText:SetText(self.db.profile.labels.ttl .. self:FormatTime(ttl))
        else
             self.ttlText:SetText(self.db.profile.labels.ttl .. "...")
        end
        self.ttlText:Show()
    else
        self.ttlText:Hide()
    end
end

--- Updates the LibDataBroker data object text and icon.
function StormXP:UpdateLDB()
    if not self.ldb then return end

    local curr, max, label, _, _, _, mode = self:GetModeData()
    local pct = (max > 0) and (curr / max) * 100 or 0

    if mode == "XP" then
        self.ldb.text = string_format("%.1f%%", pct)
        self.ldb.icon = "Interface\\Icons\\inv_misc_book_09"
    elseif mode == "REP" then
        self.ldb.text = string_format("%s: %.1f%%", label, pct)
        self.ldb.icon = "Interface\\Icons\\achievement_reputation_01"
    elseif mode == "HONOR" then
        self.ldb.text = string_format("%s: %.1f%%", label, pct)
        self.ldb.icon = "Interface\\Icons\\achievement_pvp_o_15"
    else
        self.ldb.text = "StormXP"
        self.ldb.icon = "Interface\\Icons\\inv_misc_book_09"
    end
end

--- Calculates the data required to render the bar based on the current tracking mode.
-- @return curr (number) Current value
-- @return max (number) Maximum value
-- @return label (string) Text for the level/faction label
-- @return color (table) RGBA color table
-- @return showRested (boolean) Whether rested XP is relevant
-- @return showQuest (boolean) Whether quest XP is relevant
-- @return mode (string) The resolved active mode (XP, REP, HONOR, or NONE)
function StormXP:GetModeData()
    local mode = self.db.profile.mode
    local isMax = (UnitLevel("player") == GetMaxLevelForPlayerExpansion())

    -- Step 1: Resolve AUTO mode logic
    -- If AUTO, we use XP until the player hits max level, then switch to the 'endgame' preference.
    if mode == "AUTO" then
        if isMax then
            if self.db.profile.autoHideMax then
                return 0, 1, "", EMPTY_COLOR, false, false, "NONE"
            end
            mode = self.db.profile.endgame -- Resolves to REP, HONOR, or NONE
        else
            mode = "XP"
        end
    end

    local curr, max, label, color, showRested, showQuest

    -- Step 2: Fetch data based on resolved mode
    if mode == "REP" then
        local data = C_Reputation.GetWatchedFactionData()
        if data then
            curr, max = data.currentReactionThreshold, data.nextReactionThreshold
            if max == 0 then max = 1; curr = 1 end

            local rankSuffix = ""
            -- Priority 1: Check for Modern Renown (Major Faction)
            if data.factionID and C_MajorFactions then
                local majorData = C_MajorFactions.GetMajorFactionData(data.factionID)
                if majorData then
                    rankSuffix = " " .. majorData.renownLevel
                end
            end

            -- Priority 2: Fallback to standard Reaction Label (Honored, Exalted, etc.)
            if rankSuffix == "" and data.reaction then
                local standing = _G["FACTION_STANDING_LABEL"..data.reaction]
                if standing then
                    rankSuffix = " " .. standing
                end
            end

            label = data.name .. rankSuffix
        else
            curr, max = 0, 1
            label = "No Faction"
        end
        color = self.db.profile.colorRep
        showRested = false
        showQuest = false

    elseif mode == "HONOR" then
        curr = UnitHonor("player")
        max = UnitHonorMax("player")
        label = "Honor " .. UnitHonorLevel("player")
        color = self.db.profile.colorHonor
        showRested = false
        showQuest = false

    elseif mode == "XP" then
        curr = UnitXP("player")
        max = UnitXPMax("player")
        label = string_format("%s%d", self.db.profile.labels.level, UnitLevel("player"))
        color = self.db.profile.colorXP
        showRested = true
        showQuest = true

    else -- "NONE" mode: Hide the bar elements
        return 0, 1, "", EMPTY_COLOR, false, false, "NONE"
    end

    -- Safety check to prevent division by zero in UI elements
    if max == 0 then max = 1 end

    return curr, max, label, color, showRested, showQuest, mode
end

function StormXP:PLAYER_XP_UPDATE()
    local currXP = UnitXP("player")
    if self.lastXP then
        local diff = currXP - self.lastXP
        if diff > 0 then
            self.session.gained = self.session.gained + diff
        end
    end
    self.lastXP = currXP
    self:UpdateBar()
end

function StormXP:PLAYER_LEVEL_UP()
    if self.lastXP and self.lastMaxXP then
        local remainder = self.lastMaxXP - self.lastXP
        if remainder > 0 then
            self.session.gained = self.session.gained + remainder
        end
    end

    self.lastXP = 0
    self.lastMaxXP = UnitXPMax("player")

    -- Reset level timer on level up
    self.levelTime.level = 0
    self.levelTime.lastUpdate = GetTime()
    RequestTimePlayed() -- Sync with server

    self:UpdateBar()
end

function StormXP:UPDATE_EXHAUSTION()
    self:UpdateBar()
end

function StormXP:UPDATE_FACTION()
    self:UpdateBar()
end

function StormXP:PLAYER_REGEN_ENABLED()
    if self.needsApplySettings then
        self.needsApplySettings = nil
        self:ApplySettings()
    end
end

function StormXP:UpdateQuestXP()
    self.questXP = self:ScanQuestXP()
    self:UpdateBar()
end

function StormXP:QUEST_LOG_UPDATE()
    if self.questTimer then self:CancelTimer(self.questTimer) end
    self.questTimer = self:ScheduleTimer("UpdateQuestXP", 0.5)
end
