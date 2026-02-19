std = "lua51"
max_line_length = false
exclude_files = { "Libs/**/*" }

read_globals = {
    -- Ace3 / Libraries
    "LibStub",

    -- WoW Frames & UI
    "CreateFrame", "UIParent", "GameTooltip",
    "InCombatLockdown", "RAID_CLASS_COLORS",

    -- WoW Unit API
    "UnitXP", "UnitXPMax", "UnitLevel",
    "UnitHonor", "UnitHonorMax", "UnitHonorLevel",
    "UnitName", "UnitClass",

    -- WoW Misc API
    "GetTime", "GetXPExhaustion", "GetQuestLogRewardXP",
    "GetMaxLevelForPlayerExpansion", "RequestTimePlayed",

    -- C_ Namespaces
    "C_Reputation", "C_MajorFactions", "C_QuestLog",
}

globals = {
    "StormXP_OnAddonCompartmentClick",
}

files["Config.lua"] = {
    ignore = { "212/info" },
}

files["Utils.lua"] = {
    ignore = { "212/self" },
}
