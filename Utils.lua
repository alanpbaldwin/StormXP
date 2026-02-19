local StormXP = LibStub("AceAddon-3.0"):GetAddon("StormXP")
local LSM = LibStub("LibSharedMedia-3.0")

-- Cache frequently used globals
local tostring = tostring
local math_huge = math.huge
local math_floor = math.floor
local string_format = string.format
local string_gsub = string.gsub
local C_QuestLog = C_QuestLog
local GetQuestLogRewardXP = GetQuestLogRewardXP

--- Converts float RGB (0-1) to a 6-character hex string.
function StormXP:DecToHex(r, g, b)
    return string_format("%02x%02x%02x", (r or 1)*255, (g or 1)*255, (b or 1)*255)
end

--- Fetches a LibSharedMedia asset, falling back to Blizzard defaults.
function StormXP:GetMedia(mediaType, name)
    local media = LSM:Fetch(mediaType, name)
    if not media then
        if mediaType == "statusbar" then
            return "Interface\\TargetingFrame\\UI-StatusBar"
        elseif mediaType == "font" then
            return "Fonts\\FRIZQT__.TTF"
        end
    end
    return media
end

--- Formats a number using the profile's format (FULL with separator or COMPACT).
function StormXP:FormatNumber(number)
    local fmt = self.db.profile.textRaw.format

    if fmt == "COMPACT" then
        if number >= 1000000000 then return string_format("%.1fB", number / 1000000000) end
        if number >= 1000000 then return string_format("%.1fM", number / 1000000) end
        if number >= 1000 then return string_format("%.1fK", number / 1000) end
        return tostring(number)
    end

    local sep = self.db.profile.textRaw.separator
    if not sep or sep == "NONE" then return tostring(number) end

    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string_gsub(formatted, "^(-?%d+)(%d%d%d)", '%1'..sep..'%2')
        if k == 0 then break end
    end
    return formatted
end

--- Formats seconds into a human-readable string (e.g. "1h 23m", "45s").
function StormXP:FormatTime(seconds)
    if seconds == math_huge then return "Inf" end
    if seconds < 60 then return string_format("%ds", seconds) end
    if seconds < 3600 then return string_format("%dm %ds", math_floor(seconds/60), seconds % 60) end
    return string_format("%dh %dm", math_floor(seconds/3600), math_floor((seconds % 3600)/60))
end

--- Scans the quest log and totals XP from completed (ready to turn in) quests.
function StormXP:ScanQuestXP()
    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    local currentQuestXP = 0

    for i = 1, numEntries do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader and not info.isHidden and C_QuestLog.IsComplete(info.questID) then
            local xp = GetQuestLogRewardXP(info.questID)
            if xp and xp > 0 then
                currentQuestXP = currentQuestXP + xp
            end
        end
    end
    return currentQuestXP
end
