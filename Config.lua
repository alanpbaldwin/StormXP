local StormXP = LibStub("AceAddon-3.0"):GetAddon("StormXP")
local LSM = LibStub("LibSharedMedia-3.0")

local function GetTextOptions(key, extra)
    local options = {
        enabled = {
            type = 'toggle',
            name = 'Enable',
            order = 1,
            get = function(info) return StormXP.db.profile[key].enabled end,
            set = function(info, val) StormXP.db.profile[key].enabled = val; StormXP:ApplySettings() end,
        },
        font = {
            type = 'select',
            dialogControl = 'LSM30_Font',
            name = 'Font',
            order = 2,
            values = LSM:HashTable("font"),
            get = function(info) return StormXP.db.profile[key].font end,
            set = function(info, val) StormXP.db.profile[key].font = val; StormXP:ApplySettings() end,
        },
        size = {
            type = 'range',
            name = 'Size',
            order = 3,
            min = 8, max = 32, step = 1,
            get = function(info) return StormXP.db.profile[key].size end,
            set = function(info, val) StormXP.db.profile[key].size = val; StormXP:ApplySettings() end,
        },
        outline = {
            type = 'select',
            name = 'Outline',
            order = 4,
            values = {["NONE"] = "None", ["OUTLINE"] = "Outline", ["THICKOUTLINE"] = "Thick Outline"},
            get = function(info) return StormXP.db.profile[key].outline end,
            set = function(info, val) StormXP.db.profile[key].outline = val; StormXP:ApplySettings() end,
        },
        color = {
            type = 'color',
            name = 'Color',
            order = 5,
            hasAlpha = true,
            get = function(info) return unpack(StormXP.db.profile[key].color) end,
            set = function(info, r, g, b, a) StormXP.db.profile[key].color = {r, g, b, a}; StormXP:ApplySettings() end,
        },
        x = {
            type = 'range',
            name = 'X Offset',
            order = 6,
            min = -500, max = 500, step = 1,
            get = function(info) return StormXP.db.profile[key].x end,
            set = function(info, val) StormXP.db.profile[key].x = val; StormXP:ApplySettings() end,
        },
        y = {
            type = 'range',
            name = 'Y Offset',
            order = 7,
            min = -50, max = 50, step = 1,
            get = function(info) return StormXP.db.profile[key].y end,
            set = function(info, val) StormXP.db.profile[key].y = val; StormXP:ApplySettings() end,
        },
    }

    if extra then
        for k, v in pairs(extra) do options[k] = v end
    end

    return options
end

function StormXP:GetOptions()
    local options = {
        name = "StormXP",
        handler = StormXP,
        type = 'group',
        args = {
            general_tab = {
                type = 'group',
                name = 'General Settings',
                order = 1,
                args = {
                    general = {
                        type = 'group',
                        name = 'General Options',
                        order = 1,
                        inline = true,
                        args = {
                            enabled = {
                                type = 'toggle',
                                name = 'Enable',
                                order = 1,
                                get = function(info) return self.db.profile.enabled end,
                                set = function(info, val) self.db.profile.enabled = val; self:ApplySettings() end,
                            },
                            minimap = {
                                type = 'toggle',
                                name = 'Show Minimap Icon',
                                order = 1.5,
                                get = function(info) return not self.db.profile.minimap.hide end,
                                set = function(info, val)
                                    self.db.profile.minimap.hide = not val
                                    local icon = LibStub:GetLibrary("LibDBIcon-1.0", true)
                                    if icon then icon:Refresh("StormXP", self.db.profile.minimap) end
                                end,
                            },
                            enableLDB = {
                                type = 'toggle',
                                name = 'Enable Data Broker',
                                desc = 'Enable LDB data source (Requires UI Reload).',
                                order = 1.6,
                                get = function(info) return self.db.profile.enableLDB end,
                                set = function(info, val) self.db.profile.enableLDB = val end,
                            },
                            locked = {
                                type = 'toggle',
                                name = 'Lock Frame',
                                desc = 'Lock the frame to prevent accidental movement.',
                                order = 2,
                                get = function(info) return self.db.profile.locked end,
                                set = function(info, val) self.db.profile.locked = val; self:ApplySettings() end,
                            },
                            mode = {
                                type = 'select',
                                name = 'Tracking Mode',
                                desc = 'Select what to track. "Auto" tracks XP until Max Level, then switches based on settings.',
                                order = 3,
                                values = {["AUTO"] = "Auto", ["XP"] = "Experience", ["REP"] = "Reputation", ["HONOR"] = "Honor"},
                                get = function(info) return self.db.profile.mode end,
                                set = function(info, val) self.db.profile.mode = val; self:UpdateBar() end,
                            },
                            autoHideMax = {
                                type = 'toggle',
                                name = 'Auto-Hide at Max Level',
                                order = 3.1,
                                hidden = function() return self.db.profile.mode ~= "AUTO" end,
                                get = function(info) return self.db.profile.autoHideMax end,
                                set = function(info, val) self.db.profile.autoHideMax = val; self:UpdateBar() end,
                            },
                            endgame = {
                                type = 'select',
                                name = 'Max Level Tracking',
                                desc = 'Select what to track when you reach max level (Auto Mode).',
                                order = 3.2,
                                hidden = function() return self.db.profile.mode ~= "AUTO" end,
                                values = {["NONE"] = "None", ["REP"] = "Reputation", ["HONOR"] = "Honor"},
                                get = function(info) return self.db.profile.endgame end,
                                set = function(info, val) self.db.profile.endgame = val; self:UpdateBar() end,
                            },
                            showTooltip = {
                                type = 'toggle',
                                name = 'Show Tooltip',
                                desc = 'Display a detailed tooltip when hovering over the bar.',
                                order = 3.5,
                                get = function(info) return self.db.profile.showTooltip end,
                                set = function(info, val) self.db.profile.showTooltip = val end,
                            },
                            scale = {
                                type = 'range',
                                name = 'Scale',
                                order = 4,
                                min = 0.5, max = 2.0, step = 0.01,
                                get = function(info) return self.db.profile.scale end,
                                set = function(info, val) self.db.profile.scale = val; self:ApplySettings() end,
                            },
                            alpha = {
                                type = 'range',
                                name = 'Alpha',
                                order = 5,
                                min = 0.1, max = 1.0, step = 0.01,
                                get = function(info) return self.db.profile.alpha end,
                                set = function(info, val) self.db.profile.alpha = val; self:ApplySettings() end,
                            },
                        }
                    },
                    position = {
                        type = 'group',
                        name = 'Size and Position',
                        order = 2,
                        inline = true,
                        args = {
                            width = {
                                type = 'range',
                                name = 'Width',
                                order = 1,
                                min = 100, max = 2000, step = 1,
                                get = function(info) return self.db.profile.width end,
                                set = function(info, val) self.db.profile.width = val; self:ApplySettings() end,
                            },
                            height = {
                                type = 'range',
                                name = 'Height',
                                order = 2,
                                min = 5, max = 100, step = 1,
                                get = function(info) return self.db.profile.height end,
                                set = function(info, val) self.db.profile.height = val; self:ApplySettings() end,
                            },
                            x = {
                                type = 'range',
                                name = 'X Offset',
                                order = 3,
                                min = -2000, max = 2000, step = 1,
                                get = function(info) return self.db.profile.x end,
                                set = function(info, val) self.db.profile.x = val; self:ApplySettings() end,
                            },
                            y = {
                                type = 'range',
                                name = 'Y Offset',
                                order = 4,
                                min = -1000, max = 1000, step = 1,
                                get = function(info) return self.db.profile.y end,
                                set = function(info, val) self.db.profile.y = val; self:ApplySettings() end,
                            }
                        }
                    },
                }
            },
            colors = {
                type = 'group',
                name = 'Bar Colors/Texture',
                order = 3,
                args = {
                    texture = {
                        type = 'select',
                        dialogControl = 'LSM30_Statusbar',
                        name = 'Bar Texture',
                        values = LSM:HashTable("statusbar"),
                        get = function(info) return self.db.profile.texture end,
                        set = function(info, val) self.db.profile.texture = val; self:ApplySettings() end,
                    },
                    colorXP = {
                        type = 'color',
                        name = 'XP Color',
                        hasAlpha = true,
                        get = function(info) return unpack(self.db.profile.colorXP) end,
                        set = function(info, r, g, b, a) self.db.profile.colorXP = {r, g, b, a}; self:ApplySettings() end,
                    },
                    colorRested = {
                        type = 'color',
                        name = 'Rested Color',
                        hasAlpha = true,
                        get = function(info) return unpack(self.db.profile.colorRested) end,
                        set = function(info, r, g, b, a) self.db.profile.colorRested = {r, g, b, a}; self:ApplySettings() end,
                    },
                    colorQuest = {
                        type = 'color',
                        name = 'Completed Quest XP Color',
                        hasAlpha = true,
                        get = function(info) return unpack(self.db.profile.colorQuest) end,
                        set = function(info, r, g, b, a) self.db.profile.colorQuest = {r, g, b, a}; self:ApplySettings() end,
                    },
                    colorRep = {
                        type = 'color',
                        name = 'Reputation Color',
                        hasAlpha = true,
                        get = function(info) return unpack(self.db.profile.colorRep) end,
                        set = function(info, r, g, b, a) self.db.profile.colorRep = {r, g, b, a}; self:ApplySettings() end,
                    },
                    colorHonor = {
                        type = 'color',
                        name = 'Honor Color',
                        hasAlpha = true,
                        get = function(info) return unpack(self.db.profile.colorHonor) end,
                        set = function(info, r, g, b, a) self.db.profile.colorHonor = {r, g, b, a}; self:ApplySettings() end,
                    },
                    colorBack = {
                        type = 'color',
                        name = 'Background Color',
                        hasAlpha = true,
                        get = function(info) return unpack(self.db.profile.colorBack) end,
                        set = function(info, r, g, b, a) self.db.profile.colorBack = {r, g, b, a}; self:ApplySettings() end,
                    },
                }
            },
            text = {
                type = 'group',
                name = 'Text Settings',
                order = 4,
                childGroups = "tab",
                args = {
                    level = {
                        type = 'group',
                        name = 'Player Level',
                        order = 1,
                        args = GetTextOptions("textLevel", {
                            prefix = {
                                type = 'input',
                                name = 'Label Prefix',
                                desc = 'Text to display before the level number.',
                                order = 0.5,
                                get = function(info) return StormXP.db.profile.labels.level end,
                                set = function(info, val) StormXP.db.profile.labels.level = val; StormXP:UpdateBar() end,
                            }
                        })
                    },
                    percent = {
                        type = 'group',
                        name = 'XP%',
                        order = 2,
                        args = GetTextOptions("textPercent", {
                            showQuestXP = {
                                type = 'toggle',
                                name = 'Show Completed Quest XP',
                                desc = 'Show projected XP percentage from completed quests ready to turn in.',
                                order = 1.5,
                                get = function(info) return StormXP.db.profile.textPercent.showQuestXP end,
                                set = function(info, val) StormXP.db.profile.textPercent.showQuestXP = val; StormXP:UpdateBar() end,
                            }
                        })
                    },
                    raw = {
                        type = 'group',
                        name = 'XP Value',
                        order = 3,
                        args = GetTextOptions("textRaw", {
                            format = {
                                type = 'select',
                                name = 'Format',
                                order = 7.5,
                                values = {["FULL"] = "Full (1,234)", ["COMPACT"] = "Compact (1.2K)"},
                                get = function(info) return StormXP.db.profile.textRaw.format end,
                                set = function(info, val) StormXP.db.profile.textRaw.format = val; StormXP:UpdateBar() end,
                            },
                            separator = {
                                type = 'select',
                                name = 'Separator',
                                order = 8,
                                values = {[","] = "Comma (,)", ["."] = "Dot (.)", [" "] = "Space ( )", ["NONE"] = "None"},
                                hidden = function() return StormXP.db.profile.textRaw.format == "COMPACT" end,
                                get = function(info) return StormXP.db.profile.textRaw.separator end,
                                set = function(info, val) StormXP.db.profile.textRaw.separator = val; StormXP:ApplySettings() end,
                            }
                        })
                    },
                    session = {
                        type = 'group',
                        name = 'Session Time',
                        order = 4,
                        args = GetTextOptions("textSession", {
                            label = {
                                type = 'input',
                                name = 'Label',
                                order = 0.5,
                                get = function(info) return StormXP.db.profile.labels.session end,
                                set = function(info, val) StormXP.db.profile.labels.session = val; StormXP:UpdateBar() end,
                            }
                        })
                    },
                    levelTime = {
                        type = 'group',
                        name = 'Level Time',
                        order = 5,
                        args = GetTextOptions("textLevelTime")
                    },
                    ttl = {
                        type = 'group',
                        name = 'Time to Level',
                        order = 6,
                        args = GetTextOptions("textTTL", {
                            label = {
                                type = 'input',
                                name = 'Label',
                                order = 0.5,
                                get = function(info) return StormXP.db.profile.labels.ttl end,
                                set = function(info, val) StormXP.db.profile.labels.ttl = val; StormXP:UpdateBar() end,
                            }
                        })
                    },
                    rested = {
                        type = 'group',
                        name = 'Rested %',
                        order = 7,
                        args = GetTextOptions("textRested", {
                            label = {
                                type = 'input',
                                name = 'Label',
                                order = 0.5,
                                get = function(info) return StormXP.db.profile.labels.rested end,
                                set = function(info, val) StormXP.db.profile.labels.rested = val; StormXP:UpdateBar() end,
                            }
                        })
                    }
                }
            },
            segments = {
                type = 'group',
                name = 'Segments',
                order = 6,
                args = {
                    enabled = {
                        type = 'toggle',
                        name = 'Enable',
                        order = 1,
                        get = function(info) return StormXP.db.profile.segments.enabled end,
                        set = function(info, val) StormXP.db.profile.segments.enabled = val; StormXP:ApplySettings() end,
                    },
                    minor = {
                        type = 'group',
                        name = 'Minor Markers',
                        order = 3,
                        inline = true,
                        args = {
                            enabled = {
                                type = 'toggle',
                                name = 'Enable',
                                order = 0.5,
                                get = function(info) return StormXP.db.profile.segments.minorEnabled end,
                                set = function(info, val) StormXP.db.profile.segments.minorEnabled = val; StormXP:ApplySettings() end,
                            },
                            step = {
                                type = 'range',
                                name = 'Step (%)',
                                desc = 'Distance between minor markers.',
                                order = 1,
                                min = 1, max = 25, step = 1,
                                get = function(info) return StormXP.db.profile.segments.minorStep end,
                                set = function(info, val) StormXP.db.profile.segments.minorStep = val; StormXP:ApplySettings() end,
                            },
                            width = {
                                type = 'range',
                                name = 'Width',
                                order = 2,
                                min = 1, max = 5, step = 1,
                                get = function(info) return StormXP.db.profile.segments.width end,
                                set = function(info, val) StormXP.db.profile.segments.width = val; StormXP:ApplySettings() end,
                            },
                            color = {
                                type = 'color',
                                name = 'Color',
                                order = 3,
                                hasAlpha = true,
                                get = function(info) return unpack(StormXP.db.profile.segments.color) end,
                                set = function(info, r, g, b, a) StormXP.db.profile.segments.color = {r, g, b, a}; StormXP:ApplySettings() end,
                            }
                        }
                    },
                    major = {
                        type = 'group',
                        name = 'Major Markers',
                        order = 4,
                        inline = true,
                        args = {
                            enabled = {
                                type = 'toggle',
                                name = 'Enable',
                                order = 1,
                                get = function(info) return StormXP.db.profile.segments.major end,
                                set = function(info, val) StormXP.db.profile.segments.major = val; StormXP:ApplySettings() end,
                            },
                            step = {
                                type = 'range',
                                name = 'Step (%)',
                                desc = 'Distance between major markers.',
                                order = 2,
                                min = 5, max = 50, step = 5,
                                get = function(info) return StormXP.db.profile.segments.majorStep end,
                                set = function(info, val) StormXP.db.profile.segments.majorStep = val; StormXP:ApplySettings() end,
                            },
                            width = {
                                type = 'range',
                                name = 'Width',
                                order = 3,
                                min = 1, max = 10, step = 1,
                                get = function(info) return StormXP.db.profile.segments.widthMajor end,
                                set = function(info, val) StormXP.db.profile.segments.widthMajor = val; StormXP:ApplySettings() end,
                            },
                            color = {
                                type = 'color',
                                name = 'Color',
                                order = 4,
                                hasAlpha = true,
                                get = function(info) return unpack(StormXP.db.profile.segments.colorMajor) end,
                                set = function(info, r, g, b, a) StormXP.db.profile.segments.colorMajor = {r, g, b, a}; StormXP:ApplySettings() end,
                            }
                        }
                    }
                }
            }
        }
    }

    -- Register Profiles Table
    options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db)

    return options
end