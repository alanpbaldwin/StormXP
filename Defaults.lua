local StormXP = LibStub("AceAddon-3.0"):GetAddon("StormXP")

local CONSTANTS = {
    DEFAULT_WIDTH = 1200,
    DEFAULT_HEIGHT = 30,
    DEFAULT_TEXTURE = "Blizzard",
    DEFAULT_FONT = "Friz Quadrata TT",
    COLOR_XP = {0.506, 0.345, 0.984, 0.8},
    COLOR_RESTED = {0.31, 0.565, 1.0, 0.8},
    COLOR_QUEST = {1.0, 0.592, 0.0, 0.8},
    COLOR_REP = {0.0, 1.0, 0.0, 1.0},
    COLOR_HONOR = {1.0, 0.0, 0.0, 1.0},
    COLOR_BACK = {0.0, 0.0, 0.0, 0.6},
}

-- Expose constants if needed elsewhere
StormXP.constants = CONSTANTS

StormXP.defaults = {
    profile = {
        enabled = true,
        enableLDB = true,
        minimap = { hide = false },
        mode = "AUTO", -- AUTO, XP, REP, HONOR
        locked = false,
        scale = 1,
        alpha = 1,
        showTooltip = true,
        endgame = "NONE",
        -- Dimensions & Position
        width = CONSTANTS.DEFAULT_WIDTH,
        height = CONSTANTS.DEFAULT_HEIGHT,
        point = "BOTTOM",
        relPoint = "BOTTOM",
        x = 0,
        y = -20,
        strata = "MEDIUM",

        -- Textures
        texture = CONSTANTS.DEFAULT_TEXTURE,

        -- Colors (R, G, B, A)
        colorXP = CONSTANTS.COLOR_XP,
        colorRested = CONSTANTS.COLOR_RESTED,
        colorQuest = CONSTANTS.COLOR_QUEST,
        colorRep = CONSTANTS.COLOR_REP,
        colorHonor = CONSTANTS.COLOR_HONOR,
        colorBack = CONSTANTS.COLOR_BACK,

        -- Session Data
        session = {
            gainedXP = 0,
            startTime = 0,
            startXP = 0,
        },

        -- Text Elements
        textLevel = {
            enabled = true,
            font = "Friz Quadrata TT",
            size = 12,
            outline = "OUTLINE",
            color = {1, 1, 1, 1},
            point = "LEFT",
            x = 10,
            y = 0,
        },
        textPercent = {
            enabled = true,
            showQuestXP = true,
            font = "Friz Quadrata TT",
            size = 12,
            outline = "OUTLINE",
            color = {1, 1, 1, 1},
            point = "RIGHT",
            x = -10,
            y = 0,
        },
        textRaw = {
            enabled = true,
            font = "Friz Quadrata TT",
            size = 12,
            outline = "OUTLINE",
            color = {1, 1, 1, 1},
            point = "CENTER",
            x = 0,
            y = 0,
            separator = ",",
            format = "FULL",
        },
        textSession = {
            enabled = true,
            font = "Friz Quadrata TT",
            size = 10,
            outline = "OUTLINE",
            color = {1, 1, 1, 1},
            point = "BOTTOMLEFT",
            relPoint = "BOTTOMRIGHT",
            x = 2,
            y = 0,
        },
        textLevelTime = {
            enabled = true,
            font = "Friz Quadrata TT",
            size = 10,
            outline = "OUTLINE",
            color = {1, 1, 1, 1},
            point = "TOPLEFT",
            relPoint = "TOPRIGHT",
            x = 2,
            y = 0,
        },
        textTTL = {
            enabled = true,
            font = "Friz Quadrata TT",
            size = 10,
            outline = "OUTLINE",
            color = {1, 1, 1, 1},
            point = "TOPLEFT",
            relPoint = "BOTTOMLEFT",
            x = 0,
            y = -2,
        },
        textRested = {
            enabled = true,
            font = "Friz Quadrata TT",
            size = 10,
            outline = "OUTLINE",
            color = {1, 1, 1, 1}, -- Value Color (White)
            point = "TOPRIGHT",
            relPoint = "BOTTOMRIGHT",
            x = 0,
            y = -14,
        },

        -- Custom Labels
        labels = {
            level = "Level ",
            session = "Session: ",
            ttl = "TTL: ",
            rested = "Rested: ",
        },

        -- Misc
        autoHideMax = true,

        -- Segment Markers
        segments = {
            enabled = true,
            minorStep = 10, -- 10%
            majorStep = 25, -- 25%
            major = true,
            minorEnabled = true,
            color = {0, 0, 0, 0.5},
            colorMajor = {1, 1, 1, 0.8},
            width = 1,
            widthMajor = 2,
        }
    }
}
