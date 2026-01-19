local StormXP = LibStub("AceAddon-3.0"):GetAddon("StormXP")
local LSM = LibStub("LibSharedMedia-3.0")

function StormXP:DecToHex(r, g, b)
    return string.format("%02x%02x%02x", (r or 1)*255, (g or 1)*255, (b or 1)*255)
end

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

function StormXP:FormatNumber(number)
    local fmt = self.db.profile.textRaw.format

    if fmt == "COMPACT" then
        if number >= 1000000000 then return string.format("%.1fB", number / 1000000000) end
        if number >= 1000000 then return string.format("%.1fM", number / 1000000) end
        if number >= 1000 then return string.format("%.1fK", number / 1000) end
        return tostring(number)
    end

    local sep = self.db.profile.textRaw.separator
    if not sep or sep == "NONE" then return tostring(number) end

    local formatted = tostring(number)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1'..sep..'%2')
        if k == 0 then break end
    end
    return formatted
end

function StormXP:FormatTime(seconds)
    if seconds == math.huge then return "Inf" end
    if seconds < 60 then return string.format("%ds", seconds) end
    if seconds < 3600 then return string.format("%dm %ds", math.floor(seconds/60), seconds % 60) end
    return string.format("%dh %dm", math.floor(seconds/3600), math.floor((seconds % 3600)/60))
end

function StormXP:ScanQuestXP()
    local numEntries = C_QuestLog.GetNumQuestLogEntries()
    local currentQuestXP = 0

    for i = 1, numEntries do
        local info = C_QuestLog.GetInfo(i)
        if info and not info.isHeader and not info.isHidden then
            local xp = GetQuestLogRewardXP(info.questID)
            if xp and xp > 0 then
                currentQuestXP = currentQuestXP + xp
            end
        end
    end
    return currentQuestXP
end
